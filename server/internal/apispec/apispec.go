// Package apispec reads Swagger 2.0 and OpenAPI 3.x specs for Swagger
// tests: the operations, servers and security schemes the form offers, a
// trimmed copy for the run, and agnts's own check of every logged response
// against the spec. External $refs are never fetched.
package apispec

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"slices"
	"sort"
	"strings"

	"github.com/getkin/kin-openapi/openapi2"
	"github.com/getkin/kin-openapi/openapi2conv"
	"github.com/getkin/kin-openapi/openapi3"
	"github.com/oasdiff/yaml"

	"agnts/internal/domain"
)

// MaxBytes caps a spec.
const MaxBytes = 5 << 20

// Doc is a parsed spec.
type Doc struct {
	Title   string `json:"title"`
	Version string `json:"version"`
	// Format is "swagger 2.0" or "openapi 3.x.y": what the file was.
	Format          string           `json:"format"`
	Servers         []Server         `json:"servers"`
	Operations      []Operation      `json:"operations"`
	SecuritySchemes []SecurityScheme `json:"securitySchemes"`
	// JSON is the spec as OpenAPI 3 JSON.
	JSON json.RawMessage `json:"-"`
	t    *openapi3.T
}

// Server is a server the spec names, variables filled with their defaults.
type Server struct {
	URL         string     `json:"url"`
	Description string     `json:"description,omitempty"`
	Variables   []Variable `json:"variables,omitempty"`
}

// Variable is a server URL variable.
type Variable struct {
	Name    string   `json:"name"`
	Default string   `json:"default"`
	Enum    []string `json:"enum,omitempty"`
}

// Operation is one operation the form lists.
type Operation struct {
	Method      string   `json:"method"`
	Path        string   `json:"path"`
	OperationID string   `json:"operationId,omitempty"`
	Summary     string   `json:"summary,omitempty"`
	Tags        []string `json:"tags,omitempty"`
	Deprecated  bool     `json:"deprecated,omitempty"`
	// SideEffect is why a GET, HEAD or OPTIONS probably changes something
	// ("" when it looks harmless); the form leaves it unticked.
	SideEffect string `json:"sideEffect,omitempty"`
	// Security are the scheme names the operation accepts (any one of).
	Security []string `json:"security,omitempty"`
	// Default: the form ticks it (not deprecated, no side effect).
	Default bool `json:"default"`
}

// Key is "METHOD /path".
func (o Operation) Key() string { return o.Method + " " + o.Path }

// SecurityScheme is an auth scheme the spec declares, and the form's auth
// kind for it ("" when agnts cannot use it: OAuth flows, cookies).
type SecurityScheme struct {
	Name     string             `json:"name"`
	Type     string             `json:"type"`
	Scheme   string             `json:"scheme,omitempty"`
	In       string             `json:"in,omitempty"`
	Param    string             `json:"param,omitempty"`
	AuthKind domain.APIAuthKind `json:"authKind,omitempty"`
}

// Parse reads a spec (JSON or YAML). specURL resolves relative servers;
// "" for an uploaded file.
func Parse(raw []byte, specURL string) (*Doc, error) {
	if len(raw) > MaxBytes {
		return nil, fmt.Errorf("the spec is over %d MB", MaxBytes>>20)
	}
	raw = bytes.TrimSpace(raw)
	if len(raw) == 0 {
		return nil, errors.New("the spec is empty")
	}
	js := raw
	if raw[0] != '{' {
		var err error
		if js, err = yaml.YAMLToJSON(raw); err != nil {
			return nil, fmt.Errorf("the spec is neither JSON nor YAML: %w", err)
		}
	}
	var top struct {
		Swagger string `json:"swagger"`
		OpenAPI string `json:"openapi"`
	}
	if err := json.Unmarshal(js, &top); err != nil {
		return nil, fmt.Errorf("the spec is not a JSON object: %w", err)
	}
	var (
		t      *openapi3.T
		format string
	)
	switch {
	case strings.HasPrefix(top.Swagger, "2"):
		var t2 openapi2.T
		if err := json.Unmarshal(js, &t2); err != nil {
			return nil, fmt.Errorf("read the Swagger 2.0 spec: %w", err)
		}
		if err := refuseExternal(js); err != nil {
			return nil, err
		}
		var err error
		if t, err = openapi2conv.ToV3(&t2); err != nil {
			return nil, fmt.Errorf("convert Swagger 2.0: %w", err)
		}
		if t2.Host == "" {
			// No host: the API is on the spec's own host, under basePath.
			t.Servers = openapi3.Servers{{URL: "/" + strings.TrimPrefix(t2.BasePath, "/")}}
		}
		format = "swagger " + top.Swagger
		// The converted document's refs point into itself; load it again
		// so they are resolved.
		b, err := json.Marshal(t)
		if err != nil {
			return nil, err
		}
		if t, err = load(b); err != nil {
			return nil, err
		}
	case strings.HasPrefix(top.OpenAPI, "3"):
		if err := refuseExternal(js); err != nil {
			return nil, err
		}
		var err error
		if t, err = load(js); err != nil {
			return nil, err
		}
		format = "openapi " + top.OpenAPI
	default:
		return nil, errors.New("not a Swagger 2.0 or OpenAPI 3 spec (no swagger or openapi version at the top)")
	}
	out, err := json.Marshal(t)
	if err != nil {
		return nil, err
	}
	d := &Doc{Format: format, JSON: out, t: t}
	if t.Info != nil {
		d.Title, d.Version = t.Info.Title, t.Info.Version
	}
	d.Servers = servers(t, specURL)
	d.SecuritySchemes = schemes(t)
	d.Operations = operations(t)
	if len(d.Operations) == 0 {
		return nil, errors.New("the spec has no operations")
	}
	return d, nil
}

func load(js []byte) (*openapi3.T, error) {
	l := openapi3.NewLoader()
	l.IsExternalRefsAllowed = false
	l.ReadFromURIFunc = func(*openapi3.Loader, *url.URL) ([]byte, error) {
		return nil, errors.New("agnts does not fetch external $refs: bundle the spec into one file")
	}
	t, err := l.LoadFromData(js)
	if err != nil {
		return nil, fmt.Errorf("read the spec: %w", err)
	}
	return t, nil
}

// refuseExternal refuses a $ref to another file or URL.
func refuseExternal(js []byte) error {
	var v any
	if err := json.Unmarshal(js, &v); err != nil {
		return err
	}
	var bad string
	walk(v, func(m map[string]any) {
		if r, ok := m["$ref"].(string); ok && bad == "" && !strings.HasPrefix(r, "#") {
			bad = r
		}
	})
	if bad != "" {
		return fmt.Errorf("the spec refers to another file (%s); agnts does not fetch external $refs: bundle the spec into one file", bad)
	}
	return nil
}

func walk(v any, fn func(map[string]any)) {
	switch x := v.(type) {
	case map[string]any:
		fn(x)
		for _, e := range x {
			walk(e, fn)
		}
	case []any:
		for _, e := range x {
			walk(e, fn)
		}
	}
}

// servers resolves relative server URLs against the spec's URL and fills
// variables with their defaults.
func servers(t *openapi3.T, specURL string) []Server {
	var base *url.URL
	if specURL != "" {
		base, _ = url.Parse(specURL)
	}
	var out []Server
	for _, s := range t.Servers {
		if s == nil {
			continue
		}
		sv := Server{Description: s.Description}
		u := s.URL
		names := make([]string, 0, len(s.Variables))
		for n := range s.Variables {
			names = append(names, n)
		}
		sort.Strings(names)
		for _, n := range names {
			v := s.Variables[n]
			sv.Variables = append(sv.Variables, Variable{Name: n, Default: v.Default, Enum: v.Enum})
			u = strings.ReplaceAll(u, "{"+n+"}", v.Default)
		}
		if pu, err := url.Parse(u); err == nil && pu.Host == "" && base != nil {
			u = base.ResolveReference(pu).String()
		}
		sv.URL = strings.TrimSuffix(u, "/")
		if sv.URL == "" && base != nil {
			sv.URL = base.Scheme + "://" + base.Host
		}
		if sv.URL != "" {
			out = append(out, sv)
		}
	}
	if len(out) == 0 && base != nil {
		out = append(out, Server{URL: base.Scheme + "://" + base.Host})
	}
	return out
}

func schemes(t *openapi3.T) []SecurityScheme {
	if t.Components == nil {
		return nil
	}
	names := make([]string, 0, len(t.Components.SecuritySchemes))
	for n := range t.Components.SecuritySchemes {
		names = append(names, n)
	}
	sort.Strings(names)
	var out []SecurityScheme
	for _, n := range names {
		r := t.Components.SecuritySchemes[n]
		if r == nil || r.Value == nil {
			continue
		}
		s := r.Value
		ss := SecurityScheme{Name: n, Type: s.Type, Scheme: strings.ToLower(s.Scheme), In: s.In, Param: s.Name}
		switch {
		case s.Type == "http" && ss.Scheme == "bearer":
			ss.AuthKind = domain.AuthBearer
		case s.Type == "http" && ss.Scheme == "basic":
			ss.AuthKind = domain.AuthBasic
		case s.Type == "apiKey" && s.In == "header":
			ss.AuthKind = domain.AuthHeader
			if strings.EqualFold(s.Name, "Authorization") {
				ss.AuthKind = domain.AuthBearer // a pasted "Bearer …" or raw token in Authorization
			}
		case s.Type == "apiKey" && s.In == "query":
			ss.AuthKind = domain.AuthQuery
		case s.Type == "oauth2" || s.Type == "openIdConnect":
			ss.AuthKind = domain.AuthBearer // a token from the flow, pasted
		}
		out = append(out, ss)
	}
	return out
}

func operations(t *openapi3.T) []Operation {
	if t.Paths == nil {
		return nil
	}
	var out []Operation
	paths := t.Paths.Keys()
	sort.Strings(paths)
	for _, p := range paths {
		item := t.Paths.Value(p)
		if item == nil {
			continue
		}
		for _, m := range domain.HTTPMethods {
			op := item.GetOperation(m)
			if op == nil {
				continue
			}
			o := Operation{Method: m, Path: p, OperationID: op.OperationID, Summary: firstLine(op.Summary, op.Description), Tags: op.Tags, Deprecated: op.Deprecated}
			if domain.ReadOnlyMethod(m) {
				o.SideEffect = domain.SideEffect(p, op.OperationID)
			}
			sec := t.Security
			if op.Security != nil {
				sec = *op.Security
			}
			for _, req := range sec {
				for name := range req {
					if !slices.Contains(o.Security, name) {
						o.Security = append(o.Security, name)
					}
				}
			}
			sort.Strings(o.Security)
			o.Default = !o.Deprecated && o.SideEffect == ""
			out = append(out, o)
		}
	}
	return out
}

func firstLine(ss ...string) string {
	for _, s := range ss {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		if i := strings.IndexByte(s, '\n'); i > 0 {
			s = s[:i]
		}
		if len(s) > 160 {
			s = strings.ToValidUTF8(s[:160], "") + "…"
		}
		return s
	}
	return ""
}

// Ops returns the operations as domain operations.
func (d *Doc) Ops() []domain.Operation {
	out := make([]domain.Operation, 0, len(d.Operations))
	for _, o := range d.Operations {
		out = append(out, domain.Operation{Method: o.Method, Path: o.Path})
	}
	return out
}

// Load reads a stored OpenAPI 3 JSON spec back.
func Load(js []byte) (*Doc, error) {
	return Parse(js, "")
}
