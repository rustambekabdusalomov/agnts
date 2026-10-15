package apiclient

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"

	"agnts/internal/domain"
)

// MaxSpecBytes caps a fetched spec (and every page fetched to find it).
const MaxSpecBytes = 5 << 20

// maxFollows caps the links followed from a docs page to its spec;
// well-known paths tried at the end do not count.
const maxFollows = 3

// Page is one fetched URL.
type Page struct {
	URL         string // after redirects
	Status      int
	ContentType string
	Body        []byte
	// Challenge is the auth scheme a 401 asks for (WWW-Authenticate:
	// "basic" for a login and password, "bearer"), lower case.
	Challenge string
}

// Getter fetches a URL (same host only, at most MaxSpecBytes).
type Getter func(ctx context.Context, u string) (Page, error)

// Choice is one spec a docs page offers.
type Choice struct {
	Name string `json:"name,omitempty"`
	URL  string `json:"url"`
}

// Found is what discovery found: a spec, or the specs a page offers.
type Found struct {
	URL     string   `json:"url,omitempty"`
	Spec    []byte   `json:"-"`
	Choices []Choice `json:"choices,omitempty"`
}

// AuthError is the spec URL refusing the request (401 or 403): it needs a
// token, or refused the one given.
type AuthError struct {
	Status int
	// Login: it asked for a login and password (HTTP Basic).
	Login bool
}

func (e *AuthError) Error() string {
	if e.Login {
		return fmt.Sprintf("the spec URL answered %d: it asks for a login and password", e.Status)
	}
	return fmt.Sprintf("the spec URL answered %d: it needs a token", e.Status)
}

// ErrNoSpec is discovery finding nothing.
var ErrNoSpec = errors.New("no Swagger or OpenAPI spec found at this URL: give the spec's own URL (…/openapi.json, …/swagger.json, …/v3/api-docs) or upload the file")

// IsSpec reports whether b is a Swagger 2.0 or OpenAPI 3.x document (JSON
// or YAML).
func IsSpec(b []byte) bool {
	t := bytes.TrimSpace(b)
	if len(t) == 0 {
		return false
	}
	if t[0] == '{' {
		var top map[string]json.RawMessage
		if json.Unmarshal(t, &top) != nil {
			return false
		}
		var v string
		if raw, ok := top["openapi"]; ok && json.Unmarshal(raw, &v) == nil && strings.HasPrefix(v, "3") {
			return true
		}
		if raw, ok := top["swagger"]; ok && json.Unmarshal(raw, &v) == nil && strings.HasPrefix(v, "2") {
			return true
		}
		return false
	}
	return yamlSpec.Match(t[:min(len(t), 64<<10)])
}

var yamlSpec = regexp.MustCompile(`(?m)^(openapi\s*:\s*['"]?3|swagger\s*:\s*['"]?2)`)

var (
	// Swagger UI's config: SwaggerUIBundle({ url: "...", urls: [{url, name}], configUrl: "..." }).
	uiURLs      = regexp.MustCompile(`(?s)\burls\s*:\s*\[(.*?)\]`)
	uiURLsEntry = regexp.MustCompile(`(?s)\{[^{}]*?\burl\s*:\s*["']([^"']+)["'][^{}]*?\}`)
	uiName      = regexp.MustCompile(`\bname\s*:\s*["']([^"']+)["']`)
	uiURL       = regexp.MustCompile(`(?:^|[,{\s])url\s*:\s*["']([^"']+)["']`)
	uiConfigURL = regexp.MustCompile(`\bconfigUrl\s*:\s*["']([^"']+)["']`)
	initScript  = regexp.MustCompile(`<script[^>]+src\s*=\s*["']([^"']*swagger-initializer\.js[^"']*)["']`)
	redocSpec   = regexp.MustCompile(`(?i)(?:spec-url\s*=\s*["']([^"']+)["']|Redoc\.init\(\s*["']([^"']+)["'])`)
	specLink    = regexp.MustCompile(`(?i)<link[^>]+href\s*=\s*["']([^"']+\.(?:json|ya?ml))["']`)
	// specInScript is a spec-looking URL written anywhere in a script, for
	// configs that pick the URL in code (url: someVariable).
	specInScript = regexp.MustCompile("(?i)(?:https?://|/)[^\\s\"'`,;()<>=]*(?:openapi|swagger|api-docs)[^\\s\"'`,;()<>=]*")
)

// wellKnown are the paths frameworks serve their spec at (FastAPI,
// Springdoc, Swashbuckle and others).
var wellKnown = []string{"/openapi.json", "/v3/api-docs", "/swagger.json", "/v2/api-docs", "/swagger/v1/swagger.json", "/openapi.yaml",
	"/swagger/doc.json", "/api-docs", "/api/openapi.json", "/docs/openapi.json"}

// Discover finds the spec behind start: the response itself, Swagger UI's
// config (in swagger-initializer.js, or inline in older pages), Springdoc's
// swagger-config, a Redoc spec-url or a <link> to the spec, and last the
// usual paths. A page offering several specs returns them as choices.
func Discover(ctx context.Context, get Getter, start string) (Found, error) {
	su, err := url.Parse(start)
	if err != nil || (su.Scheme != "http" && su.Scheme != "https") || su.Host == "" {
		return Found{}, errors.New("the spec URL must be an http:// or https:// URL")
	}
	d := &discovery{get: get, ctx: ctx}
	page, err := get(ctx, start)
	if err != nil {
		return Found{}, err
	}
	if f, ok, err := d.page(page); ok || err != nil {
		return f, err
	}
	if page.Status == http.StatusUnauthorized || page.Status == http.StatusForbidden {
		return Found{}, &AuthError{Status: page.Status, Login: page.Challenge == "basic"}
	}
	if page.Status >= 400 && page.Status != 404 {
		return Found{}, fmt.Errorf("the spec URL answered %d", page.Status)
	}
	// The usual paths, under the page's directory and at the root.
	base, _ := url.Parse(page.URL)
	tried := map[string]bool{page.URL: true}
	for _, prefix := range prefixes(base.Path) {
		for _, p := range wellKnown {
			u := (&url.URL{Scheme: base.Scheme, Host: base.Host, Path: prefix + p}).String()
			if tried[u] {
				continue
			}
			tried[u] = true
			pg, err := get(ctx, u)
			if err != nil || pg.Status != 200 {
				continue
			}
			if IsSpec(pg.Body) {
				return Found{URL: pg.URL, Spec: pg.Body}, nil
			}
		}
	}
	return Found{}, ErrNoSpec
}

// prefixes are the path prefixes to try the usual spec paths under: the
// page's directory (without /swagger-ui, /docs, ...) and the root.
func prefixes(p string) []string {
	dir := p
	if i := strings.LastIndex(dir, "/"); i >= 0 {
		dir = dir[:i]
	}
	for _, suffix := range []string{"/swagger-ui", "/swagger", "/docs", "/redoc", "/api-docs"} {
		dir = strings.TrimSuffix(dir, suffix)
	}
	if dir == "" || dir == "/" {
		return []string{""}
	}
	return []string{dir, ""}
}

type discovery struct {
	get     Getter
	ctx     context.Context
	follows int
}

// page looks at a fetched page: a spec, a swagger-config, or a docs page
// that points at one.
func (d *discovery) page(p Page) (Found, bool, error) {
	if p.Status == 200 && IsSpec(p.Body) {
		return Found{URL: p.URL, Spec: p.Body}, true, nil
	}
	if p.Status != 200 {
		return Found{}, false, nil
	}
	if f, ok, err := d.swaggerConfig(p); ok || err != nil {
		return f, ok, err
	}
	body := string(p.Body)
	if f, ok, err := d.uiConfig(p.URL, body); ok || err != nil {
		return f, ok, err
	}
	if m := initScript.FindStringSubmatch(body); m != nil {
		if js, err := d.follow(p.URL, m[1]); err == nil && js.Status == 200 {
			if f, ok, err := d.uiConfig(js.URL, string(js.Body)); ok || err != nil {
				return f, ok, err
			}
		}
	}
	// Springdoc keeps the config at /v3/api-docs/swagger-config.
	if strings.Contains(body, "swagger-ui") || strings.Contains(body, "SwaggerUIBundle") {
		base, _ := url.Parse(p.URL)
		for _, prefix := range prefixes(base.Path) {
			if pg, err := d.follow(p.URL, prefix+"/v3/api-docs/swagger-config"); err == nil {
				if f, ok, err := d.swaggerConfig(pg); ok || err != nil {
					return f, ok, err
				}
			}
			if d.follows >= maxFollows {
				break
			}
		}
	}
	for _, re := range []*regexp.Regexp{redocSpec, specLink} {
		if m := re.FindStringSubmatch(body); m != nil {
			target := m[1]
			if target == "" && len(m) > 2 {
				target = m[2]
			}
			if f, ok, err := d.resolve(p.URL, target); ok || err != nil {
				return f, ok, err
			}
		}
	}
	return Found{}, false, nil
}

// swaggerConfig reads a Springdoc swagger-config ({url} or {urls}).
func (d *discovery) swaggerConfig(p Page) (Found, bool, error) {
	var cfg struct {
		URL  string   `json:"url"`
		URLs []Choice `json:"urls"`
	}
	if p.Status != 200 || json.Unmarshal(p.Body, &cfg) != nil || (cfg.URL == "" && len(cfg.URLs) == 0) {
		return Found{}, false, nil
	}
	return d.offer(p.URL, cfg.URL, cfg.URLs)
}

// uiConfig reads Swagger UI's config from a page or script.
func (d *discovery) uiConfig(at, body string) (Found, bool, error) {
	i := strings.Index(body, "SwaggerUIBundle(")
	if i < 0 {
		return Found{}, false, nil
	}
	cfg := body[i:]
	if j := strings.Index(cfg, "})"); j > 0 {
		cfg = cfg[:j+1]
	}
	var choices []Choice
	if m := uiURLs.FindStringSubmatch(cfg); m != nil {
		for _, e := range uiURLsEntry.FindAllStringSubmatch(m[1], -1) {
			c := Choice{URL: e[1]}
			if n := uiName.FindStringSubmatch(e[0]); n != nil {
				c.Name = n[1]
			}
			choices = append(choices, c)
		}
		cfg = strings.Replace(cfg, m[0], "", 1)
	}
	single := ""
	if m := uiURL.FindStringSubmatch(cfg); m != nil {
		single = m[1]
	}
	if single == "" && len(choices) == 0 {
		if m := uiConfigURL.FindStringSubmatch(cfg); m != nil {
			pg, err := d.follow(at, m[1])
			if err != nil {
				return Found{}, false, nil
			}
			return d.swaggerConfig(pg)
		}
		return d.scriptURLs(at, body)
	}
	return d.offer(at, single, choices)
}

// scriptURLs tries the spec-looking URLs on the page's host that a script
// mentions, when its config picks the URL in code.
func (d *discovery) scriptURLs(at, body string) (Found, bool, error) {
	base, err := url.Parse(at)
	if err != nil {
		return Found{}, false, nil
	}
	seen := map[string]bool{}
	for _, m := range specInScript.FindAllString(body, 20) {
		u, err := base.Parse(m)
		if err != nil || !sameHost(base, u) || seen[u.String()] || strings.Contains(u.Path, "swagger-ui") || strings.HasSuffix(u.Path, ".js") || strings.HasSuffix(u.Path, ".css") {
			continue
		}
		seen[u.String()] = true
		if d.follows >= maxFollows {
			break
		}
		if f, ok, err := d.resolve(at, u.String()); ok && err == nil {
			return f, true, nil
		}
	}
	return Found{}, false, nil
}

// offer returns the choices a page lists, or follows its one spec.
func (d *discovery) offer(at, single string, choices []Choice) (Found, bool, error) {
	if len(choices) > 1 {
		base, _ := url.Parse(at)
		out := make([]Choice, 0, len(choices))
		for _, c := range choices {
			u, err := base.Parse(c.URL)
			if err != nil || !sameHost(base, u) {
				continue
			}
			out = append(out, Choice{Name: c.Name, URL: u.String()})
		}
		if len(out) > 1 {
			return Found{Choices: out}, true, nil
		}
		if len(out) == 1 {
			single = out[0].URL
		}
	} else if len(choices) == 1 {
		single = choices[0].URL
	}
	if single == "" {
		return Found{}, false, nil
	}
	return d.resolve(at, single)
}

// resolve follows a link that should be the spec (or a swagger-config).
func (d *discovery) resolve(at, target string) (Found, bool, error) {
	pg, err := d.follow(at, target)
	if err != nil {
		return Found{}, false, err
	}
	if pg.Status != 200 {
		return Found{}, false, fmt.Errorf("the spec at %s answered %d", pg.URL, pg.Status)
	}
	if IsSpec(pg.Body) {
		return Found{URL: pg.URL, Spec: pg.Body}, true, nil
	}
	return d.swaggerConfig(pg)
}

// follow fetches target (relative to at), counting the hop.
func (d *discovery) follow(at, target string) (Page, error) {
	if d.follows >= maxFollows {
		return Page{}, fmt.Errorf("gave up after %d links from the docs page", maxFollows)
	}
	d.follows++
	base, err := url.Parse(at)
	if err != nil {
		return Page{}, err
	}
	u, err := base.Parse(target)
	if err != nil {
		return Page{}, err
	}
	if !sameHost(base, u) {
		return Page{}, fmt.Errorf("the spec link %s is on another host: give its URL directly", u)
	}
	return d.get(d.ctx, u.String())
}

func sameHost(a, b *url.URL) bool {
	h1, p1 := domain.HostPort(a)
	h2, p2 := domain.HostPort(b)
	return h1 == h2 && p1 == p2 && a.Scheme == b.Scheme
}

// HTTPGetter fetches through the egress proxy (HTTPS_PROXY), same host as
// start only, at most 3 redirects, bodies capped at MaxSpecBytes. cred, when
// set, goes with every request (they are all to the spec's own host).
func HTTPGetter(start string, transport http.RoundTripper, cred *Credential) Getter {
	origin, _ := url.Parse(start)
	if transport == nil {
		transport = &http.Transport{Proxy: http.ProxyFromEnvironment, TLSHandshakeTimeout: 15 * time.Second, ResponseHeaderTimeout: 30 * time.Second}
	}
	c := &http.Client{Transport: transport, Timeout: 60 * time.Second, CheckRedirect: func(req *http.Request, via []*http.Request) error {
		if len(via) >= 3 {
			return errors.New("more than 3 redirects")
		}
		if !sameHost(origin, req.URL) {
			return fmt.Errorf("redirected to another host (%s): give that URL directly", req.URL.Host)
		}
		return nil
	}}
	return func(ctx context.Context, u string) (Page, error) {
		pu, err := url.Parse(u)
		if err != nil {
			return Page{}, err
		}
		if !sameHost(origin, pu) {
			return Page{}, fmt.Errorf("%s is on another host", u)
		}
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
		if err != nil {
			return Page{}, err
		}
		req.Header.Set("Accept", "application/json, application/yaml, text/html;q=0.9, */*;q=0.5")
		req.Header.Set("User-Agent", "agnts-api (spec fetch)")
		if cred != nil && cred.Value != "" {
			SetAuth(req, *cred)
		}
		resp, err := c.Do(req)
		if err != nil {
			return Page{}, err
		}
		defer func() { _ = resp.Body.Close() }()
		b, err := io.ReadAll(io.LimitReader(resp.Body, MaxSpecBytes+1))
		if err != nil {
			return Page{}, err
		}
		if len(b) > MaxSpecBytes {
			return Page{}, fmt.Errorf("%s is over %d MB", u, MaxSpecBytes>>20)
		}
		challenge, _, _ := strings.Cut(strings.TrimSpace(resp.Header.Get("WWW-Authenticate")), " ")
		return Page{URL: resp.Request.URL.String(), Status: resp.StatusCode, ContentType: resp.Header.Get("Content-Type"), Body: b,
			Challenge: strings.ToLower(challenge)}, nil
	}
}
