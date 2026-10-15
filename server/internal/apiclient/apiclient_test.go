package apiclient

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
)

const token = "s3cr3t-token-value-123"

// fakeAPI is a tiny API: /users (list, create), /users/{id}, /me (echoes
// the token), /limited (429), /forbidden (403).
type fakeAPI struct {
	mu   sync.Mutex
	seen []*http.Request
}

func (f *fakeAPI) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	f.seen = append(f.seen, r)
	f.mu.Unlock()
	w.Header().Set("Content-Type", "application/json")
	if r.Header.Get("Authorization") != "Bearer "+token && r.URL.Path != "/open" {
		w.WriteHeader(401)
		_, _ = io.WriteString(w, `{"error":"unauthorized"}`)
		return
	}
	switch {
	case r.URL.Path == "/users" && r.Method == "POST":
		w.WriteHeader(201)
		_, _ = io.WriteString(w, `{"id":42,"name":"x"}`)
	case r.URL.Path == "/users":
		_, _ = io.WriteString(w, `{"items":[{"id":7},{"id":8}]}`)
	case strings.HasPrefix(r.URL.Path, "/users/"):
		id := strings.TrimPrefix(r.URL.Path, "/users/")
		if id == "999" {
			w.WriteHeader(500)
			_, _ = io.WriteString(w, `{"trace":"boom"}`)
			return
		}
		_, _ = fmt.Fprintf(w, `{"id":%s}`, id)
	case r.URL.Path == "/me":
		_, _ = fmt.Fprintf(w, `{"token":%q}`, token)
	case r.URL.Path == "/limited":
		w.WriteHeader(429)
	case r.URL.Path == "/forbidden":
		w.WriteHeader(403)
	case r.URL.Path == "/elsewhere":
		http.Redirect(w, r, "https://other.example/x", http.StatusFound)
	default:
		w.WriteHeader(404)
	}
}

func setup(t *testing.T, write bool) (*Client, *fakeAPI, Files) {
	t.Helper()
	api := &fakeAPI{}
	srv := httptest.NewServer(api)
	t.Cleanup(srv.Close)
	dir := t.TempDir()
	files := Files{Log: filepath.Join(dir, "log.jsonl"), LastRun: filepath.Join(dir, "last.json")}
	c, err := New(TestConfig{BaseURL: srv.URL, WriteEnabled: write, Auth: domain.APIAuth{Kind: domain.AuthBearer}, Rate: 1000},
		Credential{Kind: domain.AuthBearer, Value: token}, files, srv.Client().Transport)
	if err != nil {
		t.Fatal(err)
	}
	return c, api, files
}

func TestReadOnlyRefusesWrites(t *testing.T) {
	c, api, files := setup(t, false)
	for _, m := range []string{"POST", "PUT", "PATCH", "DELETE"} {
		_, err := c.Do(context.Background(), Request{Method: m, Path: "/users"})
		var ref *Refusal
		if !errors.As(err, &ref) || ref.Verdict != domain.VerdictSkipped {
			t.Errorf("%s: %v", m, err)
		}
	}
	if len(api.seen) != 0 || len(readLog(files.Log)) != 0 {
		t.Errorf("a refused request was sent or logged")
	}
	if _, err := c.Do(context.Background(), Request{Method: "GET", Path: "/users"}); err != nil {
		t.Error(err)
	}
}

func TestOtherHostsRefused(t *testing.T) {
	c, api, _ := setup(t, true)
	for _, p := range []string{"https://evil.example/users", "//evil.example/users"} {
		if _, err := c.Do(context.Background(), Request{Method: "GET", Path: p}); err == nil {
			t.Errorf("%s was sent", p)
		}
	}
	resp, err := c.Do(context.Background(), Request{Method: "GET", Path: "/elsewhere"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(resp.Exchange.Error, "not following a redirect") {
		t.Errorf("redirect to another host: %+v", resp.Exchange)
	}
	if len(api.seen) != 1 {
		t.Errorf("sent %d requests", len(api.seen))
	}
}

func TestAuthModes(t *testing.T) {
	c, api, _ := setup(t, false)
	ctx := context.Background()
	for _, mode := range []string{AuthDefault, AuthOmit, AuthWrong} {
		if _, err := c.Do(ctx, Request{Method: "GET", Path: "/users", Auth: mode}); err != nil {
			t.Fatal(err)
		}
	}
	got := []string{api.seen[0].Header.Get("Authorization"), api.seen[1].Header.Get("Authorization"), api.seen[2].Header.Get("Authorization")}
	if got[0] != "Bearer "+token || got[1] != "" || got[2] != "Bearer "+wrongValue {
		t.Errorf("Authorization headers: %q", got)
	}
}

func TestTokenNeverLogged(t *testing.T) {
	c, _, files := setup(t, false)
	resp, err := c.Do(context.Background(), Request{Method: "GET", Path: "/me", Query: url.Values{"t": {token}}})
	if err != nil {
		t.Fatal(err)
	}
	b, _ := os.ReadFile(files.Log)
	if bytes.Contains(b, []byte(token)) || strings.Contains(string(resp.Body), token) {
		t.Errorf("the token is in the log or the output: %s", b)
	}
	if !bytes.Contains(b, []byte(domain.Masked)) {
		t.Errorf("nothing masked: %s", b)
	}
}

func TestAuthFailureCap(t *testing.T) {
	c, _, _ := setup(t, false)
	plan := Plan{}
	for i := range 4 {
		plan.Cases = append(plan.Cases, PlanCase{ID: fmt.Sprintf("no-token-%d", i), Method: "GET", Path: "/open", Auth: AuthOmit})
	}
	out := c.Run(context.Background(), plan)
	for i := range 3 {
		if out[i].Verdict != "" {
			t.Errorf("case %d: %+v", i, out[i])
		}
	}
	if out[3].Verdict != domain.VerdictSkipped || !strings.Contains(out[3].Reason, "auth-failure cap") {
		t.Errorf("4th: %+v", out[3])
	}
}

func TestRunChainsIDs(t *testing.T) {
	c, api, _ := setup(t, true)
	var p Plan
	if err := json.Unmarshal([]byte(`{"cases":[
		{"id":"create","method":"POST","path":"/users","body":{"name":"x"},"expect":{"status":[201]}},
		{"id":"read","method":"GET","path":"/users/{id}","params":{"id":"{{create.body.id}}"},"expect":{"status":[200]}},
		{"id":"list","method":"GET","path":"/users"},
		{"id":"second","method":"GET","path":"/users/{id}","params":{"id":"{{list.body.items.1.id}}"}},
		{"id":"nested","method":"PUT","path":"/users/{id}","params":{"id":"{{create.body.id}}"},"body":{"ref":"{{create.body.id}}","label":"user {{create.body.id}}"}},
		{"id":"missing","method":"GET","path":"/users/{id}","params":{"id":"{{nope.body.id}}"}},
		{"id":"no-field","method":"GET","path":"/users/{id}","params":{"id":"{{create.body.uuid}}"}}
	]}`), &p); err != nil {
		t.Fatal(err)
	}
	out := c.Run(context.Background(), p)
	if out[1].Path != "/users/42" || out[1].Status != 200 || out[1].Match == nil || !*out[1].Match {
		t.Errorf("read: %+v", out[1])
	}
	if out[3].Path != "/users/8" {
		t.Errorf("second: %+v", out[3])
	}
	for _, i := range []int{5, 6} {
		if out[i].Verdict != domain.VerdictBlocked || out[i].Request != "" {
			t.Errorf("%s: %+v", out[i].ID, out[i])
		}
	}
	if len(api.seen) != 5 || api.seen[4].Method != "PUT" || api.seen[4].URL.Path != "/users/42" {
		t.Errorf("sent %d requests, want 5 ending with PUT /users/42", len(api.seen))
	}
}

func TestRunNestedBodyTypes(t *testing.T) {
	got := map[string]response{"create": {status: 201, body: map[string]any{"id": float64(42)}}}
	r, err := build(PlanCase{ID: "x", Method: "post", Path: "/a", Body: json.RawMessage(`{"ref":"{{create.body.id}}","label":"user {{create.body.id}}","s":"{{create.status}}"}`)}, got)
	if err != nil {
		t.Fatal(err)
	}
	if string(r.Body) != `{"label":"user 42","ref":42,"s":201}` {
		t.Errorf("body = %s", r.Body)
	}
}

func TestRunStops(t *testing.T) {
	c, _, _ := setup(t, false)
	p := Plan{Cases: []PlanCase{
		{ID: "a", Method: "GET", Path: "/limited"}, {ID: "b", Method: "GET", Path: "/limited"},
		{ID: "c", Method: "GET", Path: "/limited"}, {ID: "d", Method: "GET", Path: "/users"},
	}}
	out := c.Run(context.Background(), p)
	if out[3].Verdict != domain.VerdictBlocked || !strings.Contains(out[3].Reason, "429") {
		t.Errorf("after three 429s: %+v", out[3])
	}

	c2, _, _ := setup(t, false)
	out = c2.Run(context.Background(), Plan{Cases: []PlanCase{{ID: "a", Method: "GET", Path: "/forbidden"}, {ID: "b", Method: "GET", Path: "/users"}}})
	if out[1].Verdict != domain.VerdictBlocked || !strings.Contains(out[1].Reason, "403") {
		t.Errorf("after a 403 with the token: %+v", out[1])
	}
}

func TestRequestCap(t *testing.T) {
	c, _, _ := setup(t, false)
	c.cfg.MaxRequests = 2
	out := c.Run(context.Background(), Plan{Cases: []PlanCase{{ID: "a", Method: "GET", Path: "/users"}, {ID: "b", Method: "GET", Path: "/users"}, {ID: "c", Method: "GET", Path: "/users"}}})
	if out[2].Verdict != domain.VerdictSkipped || !strings.Contains(out[2].Reason, "request cap") {
		t.Errorf("%+v", out[2])
	}
}

func TestRateLimit(t *testing.T) {
	c, _, _ := setup(t, false)
	c.cfg.Rate = 5
	var slept time.Duration
	c.sleep = func(d time.Duration) { slept += d }
	for range 3 {
		if _, err := c.Do(context.Background(), Request{Method: "GET", Path: "/users"}); err != nil {
			t.Fatal(err)
		}
	}
	if slept < 300*time.Millisecond {
		t.Errorf("waited %s for 3 requests at 5 a second", slept)
	}
}

func TestDefaultTransportUsesProxy(t *testing.T) {
	c, err := New(TestConfig{BaseURL: "https://api.example"}, Credential{Kind: domain.AuthNone}, Files{}, nil)
	if err != nil {
		t.Fatal(err)
	}
	tr, ok := c.http.Transport.(*http.Transport)
	if !ok || tr.Proxy == nil {
		t.Fatal("requests must go through HTTPS_PROXY: Node's and Go's plain clients would fail in a run")
	}
}

func TestThroughProxy(t *testing.T) {
	api := httptest.NewServer(&fakeAPI{})
	defer api.Close()
	var via []string
	proxy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		via = append(via, r.URL.String())
		resp, err := http.DefaultTransport.RoundTrip(r)
		if err != nil {
			w.WriteHeader(502)
			return
		}
		defer func() { _ = resp.Body.Close() }()
		for k, v := range resp.Header {
			w.Header()[k] = v
		}
		w.WriteHeader(resp.StatusCode)
		_, _ = io.Copy(w, resp.Body)
	}))
	defer proxy.Close()
	pu, _ := url.Parse(proxy.URL)
	c, err := New(TestConfig{BaseURL: api.URL, Rate: 1000}, Credential{Kind: domain.AuthBearer, Value: token},
		Files{Log: filepath.Join(t.TempDir(), "log.jsonl")}, &http.Transport{Proxy: http.ProxyURL(pu)})
	if err != nil {
		t.Fatal(err)
	}
	resp, err := c.Do(context.Background(), Request{Method: "GET", Path: "/users"})
	if err != nil || resp.Exchange.Status != 200 || len(via) != 1 {
		t.Fatalf("status %d via %v err %v", resp.Exchange.Status, via, err)
	}
}

func TestParseSingle(t *testing.T) {
	r, err := parseSingle([]string{"post", "/users", "--json", `{"a":1}`, "--header", "X-Trace: 1", "--query", "page=2", "--auth", "wrong", "--id", "users-create"})
	if err != nil {
		t.Fatal(err)
	}
	if r.Method != "POST" || string(r.Body) != `{"a":1}` || r.Headers["X-Trace"] != "1" || r.Query.Get("page") != "2" || r.Auth != AuthWrong || r.Case != "users-create" {
		t.Errorf("%+v", r)
	}
	if _, err := parseSingle([]string{"GET", "/x", "--json", "{bad"}); err == nil {
		t.Error("bad JSON accepted")
	}
	if _, err := parseSingle([]string{"POST", "/x", "--body-file", AuthPath}); err == nil {
		t.Error("the credential file was read as a body")
	}
}

func TestDescribe(t *testing.T) {
	spec := []byte(`{"openapi":"3.0.3","paths":{"/users/{id}":{"parameters":[{"$ref":"#/components/parameters/Id"}],"get":{"responses":{"200":{"content":{"application/json":{"schema":{"$ref":"#/components/schemas/User"}}}}}}}},
	"components":{"parameters":{"Id":{"name":"id","in":"path"}},"schemas":{"User":{"properties":{"team":{"$ref":"#/components/schemas/Team"}}},"Team":{"type":"object"},"Unused":{}}}}`)
	b, err := Describe(spec, "GET /users/{id}")
	if err != nil {
		t.Fatal(err)
	}
	s := string(b)
	for _, want := range []string{`"User"`, `"Team"`, `"Id"`} {
		if !strings.Contains(s, want) {
			t.Errorf("missing %s: %s", want, s)
		}
	}
	if strings.Contains(s, "Unused") {
		t.Error("an unused schema is included")
	}
	if _, err := Describe(spec, "POST /users/{id}"); err == nil {
		t.Error("an unknown operation")
	}
}

func TestParsePlan(t *testing.T) {
	for _, bad := range []string{`{"cases":[]}`, `{"cases":[{"id":"A B","method":"GET","path":"/"}]}`, `{"cases":[{"id":"a","method":"GET","path":"/"},{"id":"a","method":"GET","path":"/"}]}`} {
		if _, err := ParsePlan([]byte(bad)); err == nil {
			t.Errorf("accepted %s", bad)
		}
	}
}
