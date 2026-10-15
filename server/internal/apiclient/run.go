package apiclient

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/url"
	"regexp"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// Plan is plan.json: the cases to send, in order.
type Plan struct {
	Cases []PlanCase `json:"cases"`
}

// PlanCase is one request and what it expects. Strings may refer to an
// earlier case's response: {{case-id.body.items.0.id}}, {{case-id.status}},
// {{case-id.headers.Location}}.
type PlanCase struct {
	ID        string            `json:"id"`
	Operation string            `json:"operation,omitempty"`
	Case      string            `json:"case,omitempty"`
	Method    string            `json:"method"`
	Path      string            `json:"path"`
	Params    map[string]any    `json:"params,omitempty"`
	Query     map[string]any    `json:"query,omitempty"`
	Headers   map[string]string `json:"headers,omitempty"`
	Body      json.RawMessage   `json:"body,omitempty"`
	Auth      string            `json:"auth,omitempty"`
	Expect    struct {
		Status []int `json:"status,omitempty"`
	} `json:"expect"`
}

// MaxPlanCases caps one plan.
const MaxPlanCases = domain.MaxAPICases

// Outcome is what run did with one case.
type Outcome struct {
	ID       string            `json:"id"`
	Method   string            `json:"method"`
	Path     string            `json:"path"`
	Request  string            `json:"request,omitempty"` // the logged request id
	Status   int               `json:"status,omitempty"`
	Expected []int             `json:"expected,omitempty"`
	Match    *bool             `json:"statusMatches,omitempty"`
	Verdict  domain.APIVerdict `json:"verdict,omitempty"` // skipped or blocked: not sent
	Reason   string            `json:"reason,omitempty"`
	Error    string            `json:"error,omitempty"`
	MS       int64             `json:"ms,omitempty"`
	Body     string            `json:"bodyPreview,omitempty"`
}

var ref = regexp.MustCompile(`\{\{\s*([a-z0-9-]{1,64})\.(status|body|headers)((?:\.[^.{}\s]+)*)\s*\}\}`)

// missingRef is a reference to a response that is not there.
type missingRef struct{ ref string }

func (m missingRef) Error() string { return "needs " + m.ref + ", which no earlier response has" }

// response is what a case got, for later references.
type response struct {
	status  int
	headers map[string]string
	body    any
}

// resolve fills references in s. A string that is a single reference
// keeps the referenced value's type (a number stays a number in a body).
func resolve(s string, got map[string]response) (any, error) {
	m := ref.FindStringSubmatchIndex(s)
	if m == nil {
		return s, nil
	}
	if m[0] == 0 && m[1] == len(s) {
		return lookup(s, got)
	}
	var err error
	out := ref.ReplaceAllStringFunc(s, func(x string) string {
		v, lerr := lookup(x, got)
		if lerr != nil {
			err = lerr
			return ""
		}
		return scalar(v)
	})
	return out, err
}

func lookup(x string, got map[string]response) (any, error) {
	m := ref.FindStringSubmatch(x)
	r, ok := got[m[1]]
	if !ok {
		return nil, missingRef{strings.Trim(x, "{} ")}
	}
	var path []string
	if m[3] != "" {
		path = strings.Split(strings.TrimPrefix(m[3], "."), ".")
	}
	switch m[2] {
	case "status":
		return r.status, nil
	case "headers":
		if len(path) != 1 {
			return nil, missingRef{strings.Trim(x, "{} ")}
		}
		for k, v := range r.headers {
			if strings.EqualFold(k, path[0]) {
				return v, nil
			}
		}
		return nil, missingRef{strings.Trim(x, "{} ")}
	}
	v := r.body
	for _, p := range path {
		switch cur := v.(type) {
		case map[string]any:
			nv, ok := cur[p]
			if !ok {
				return nil, missingRef{strings.Trim(x, "{} ")}
			}
			v = nv
		case []any:
			i, err := strconv.Atoi(p)
			if err != nil || i < 0 || i >= len(cur) {
				return nil, missingRef{strings.Trim(x, "{} ")}
			}
			v = cur[i]
		default:
			return nil, missingRef{strings.Trim(x, "{} ")}
		}
	}
	if v == nil {
		return nil, missingRef{strings.Trim(x, "{} ")}
	}
	return v, nil
}

func scalar(v any) string {
	switch x := v.(type) {
	case string:
		return x
	case float64:
		return strconv.FormatFloat(x, 'f', -1, 64)
	case json.Number:
		return x.String()
	case int:
		return strconv.Itoa(x)
	case bool:
		return strconv.FormatBool(x)
	}
	b, _ := json.Marshal(v)
	return string(b)
}

// resolveJSON fills references in every string of a JSON value.
func resolveJSON(v any, got map[string]response) (any, error) {
	switch x := v.(type) {
	case string:
		return resolve(x, got)
	case map[string]any:
		out := make(map[string]any, len(x))
		for k, e := range x {
			r, err := resolveJSON(e, got)
			if err != nil {
				return nil, err
			}
			out[k] = r
		}
		return out, nil
	case []any:
		out := make([]any, len(x))
		for i, e := range x {
			r, err := resolveJSON(e, got)
			if err != nil {
				return nil, err
			}
			out[i] = r
		}
		return out, nil
	}
	return v, nil
}

var planID = regexp.MustCompile(`^[a-z0-9-]{1,64}$`)

var pathParam = regexp.MustCompile(`\{([^{}/]+)\}`)

// build turns a case into a request, filling references and path
// parameters.
func build(pc PlanCase, got map[string]response) (Request, error) {
	r := Request{Case: pc.ID, Method: strings.ToUpper(pc.Method), Auth: pc.Auth, Headers: map[string]string{}, Query: url.Values{}}
	if r.Auth == "" {
		r.Auth = AuthDefault
	}
	p, err := resolve(pc.Path, got)
	if err != nil {
		return r, err
	}
	path := scalar(p)
	var perr error
	path = pathParam.ReplaceAllStringFunc(path, func(m string) string {
		name := m[1 : len(m)-1]
		v, ok := pc.Params[name]
		if !ok {
			perr = fmt.Errorf("no value for the path parameter %s", name)
			return m
		}
		if s, isStr := v.(string); isStr {
			rv, err := resolve(s, got)
			if err != nil {
				perr = err
				return m
			}
			v = rv
		}
		return url.PathEscape(scalar(v))
	})
	if perr != nil {
		return r, perr
	}
	r.Path = path
	for k, v := range pc.Query {
		rv, err := resolveJSON(v, got)
		if err != nil {
			return r, err
		}
		if list, ok := rv.([]any); ok {
			for _, e := range list {
				r.Query.Add(k, scalar(e))
			}
			continue
		}
		r.Query.Set(k, scalar(rv))
	}
	for k, v := range pc.Headers {
		rv, err := resolve(v, got)
		if err != nil {
			return r, err
		}
		r.Headers[k] = scalar(rv)
	}
	if len(pc.Body) > 0 && string(pc.Body) != "null" {
		var b any
		if err := json.Unmarshal(pc.Body, &b); err != nil {
			return r, fmt.Errorf("the body is not JSON: %w", err)
		}
		rb, err := resolveJSON(b, got)
		if err != nil {
			return r, err
		}
		if r.Body, err = json.Marshal(rb); err != nil {
			return r, err
		}
	}
	return r, nil
}

// ParsePlan reads and checks plan.json.
func ParsePlan(b []byte) (Plan, error) {
	var p Plan
	if err := json.Unmarshal(b, &p); err != nil {
		return p, fmt.Errorf("plan.json: %w", err)
	}
	if len(p.Cases) == 0 {
		return p, errors.New("plan.json has no cases")
	}
	if len(p.Cases) > MaxPlanCases {
		return p, fmt.Errorf("plan.json has %d cases; at most %d", len(p.Cases), MaxPlanCases)
	}
	seen := map[string]bool{}
	for i, c := range p.Cases {
		if !planID.MatchString(c.ID) {
			return p, fmt.Errorf("case %d: id %q must be 1-64 of a-z, 0-9 and -", i+1, c.ID)
		}
		if seen[c.ID] {
			return p, fmt.Errorf("case id %s is used twice", c.ID)
		}
		seen[c.ID] = true
		if c.Method == "" || c.Path == "" {
			return p, fmt.Errorf("case %s needs a method and a path", c.ID)
		}
	}
	return p, nil
}

// Run sends every case of the plan in order. A case whose reference is
// missing is blocked instead of sent with a hole in it. Three 429s, or a
// 401/403 on a request that carries the credential, stop the batch: the
// remaining cases are blocked (the token expired, or the caller is being
// blocked).
func (c *Client) Run(ctx context.Context, p Plan) []Outcome {
	got := map[string]response{}
	out := make([]Outcome, 0, len(p.Cases))
	tooMany := 0
	stop := ""
	for _, pc := range p.Cases {
		o := Outcome{ID: pc.ID, Method: strings.ToUpper(pc.Method), Path: pc.Path, Expected: pc.Expect.Status}
		if stop != "" {
			o.Verdict, o.Reason = domain.VerdictBlocked, stop
			out = append(out, o)
			continue
		}
		if ctx.Err() != nil {
			o.Verdict, o.Reason = domain.VerdictBlocked, "stopped"
			out = append(out, o)
			continue
		}
		req, err := build(pc, got)
		if err != nil {
			o.Verdict, o.Reason = domain.VerdictBlocked, err.Error()
			out = append(out, o)
			continue
		}
		o.Path = req.Path
		resp, err := c.Do(ctx, req)
		var refusal *Refusal
		switch {
		case errors.As(err, &refusal):
			o.Verdict, o.Reason = refusal.Verdict, refusal.Reason
			out = append(out, o)
			continue
		case err != nil && resp.Exchange.ID == "":
			o.Verdict, o.Reason = domain.VerdictBlocked, err.Error()
			out = append(out, o)
			continue
		}
		ex := resp.Exchange
		o.Request, o.Status, o.MS, o.Error = ex.ID, ex.Status, ex.MS, ex.Error
		o.Body = preview(ex.RespBody, 300)
		if len(pc.Expect.Status) > 0 && ex.Status > 0 {
			m := false
			for _, s := range pc.Expect.Status {
				m = m || s == ex.Status
			}
			o.Match = &m
		}
		r := response{status: ex.Status, headers: ex.RespHeaders}
		_ = json.Unmarshal(resp.Body, &r.body)
		got[pc.ID] = r
		out = append(out, o)

		if ex.Status == 429 {
			tooMany++
			if tooMany >= 3 {
				stop = "stopped after three 429 Too Many Requests: the API is limiting this caller"
			}
		}
		if (ex.Status == 401 || ex.Status == 403) && req.Auth == AuthDefault && c.cred.Kind != domain.AuthNone && c.cred.Kind != "" {
			stop = fmt.Sprintf("stopped after %d on a request with the credential: the token may have expired, lack a scope, or the caller is being blocked", ex.Status)
		}
	}
	return out
}

func preview(s string, n int) string {
	s = strings.Join(strings.Fields(s), " ")
	if len(s) > n {
		return strings.ToValidUTF8(s[:n], "") + "…"
	}
	return s
}

// PrintTable writes a compact table of outcomes for Claude.
func PrintTable(w io.Writer, out []Outcome) {
	for _, o := range out {
		mark := "  "
		switch {
		case o.Verdict != "":
			mark = "--"
		case o.Error != "":
			mark = "!!"
		case o.Match != nil && *o.Match:
			mark = "ok"
		case o.Match != nil:
			mark = "≠ "
		}
		line := fmt.Sprintf("%s %-28s %-7s %s", mark, o.ID, o.Method, o.Path)
		switch {
		case o.Verdict != "":
			line += fmt.Sprintf("  %s: %s", o.Verdict, o.Reason)
		case o.Error != "":
			line += fmt.Sprintf("  %s error: %s", o.Request, o.Error)
		default:
			line += fmt.Sprintf("  %s → %d", o.Request, o.Status)
			if len(o.Expected) > 0 {
				line += fmt.Sprintf(" (expected %v)", o.Expected)
			}
			if o.Body != "" {
				line += "  " + preview(o.Body, 120)
			}
		}
		_, _ = fmt.Fprintln(w, line)
	}
}
