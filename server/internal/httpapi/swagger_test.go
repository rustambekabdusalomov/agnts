package httpapi

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"agnts/internal/apiclient"
	"agnts/internal/apispec"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type fakeSwagger struct {
	specCred *apiclient.Credential
	created  orchestrator.SwaggerTestInput
	uploaded int
	rerunTok *string
}

const tinySpec = `{"openapi":"3.0.3","info":{"title":"Shop","version":"1"},"servers":[{"url":"https://shop.example"}],
"components":{"securitySchemes":{"key":{"type":"apiKey","in":"header","name":"X-Key"}}},
"paths":{"/orders":{"get":{"responses":{"200":{"description":"ok"}}}},"/auth/logout":{"get":{"responses":{"204":{"description":"bye"}}}}}}`

func (f *fakeSwagger) FetchSpec(_ context.Context, u string, cred *apiclient.Credential) (orchestrator.SpecResult, error) {
	f.specCred = cred
	switch {
	case strings.Contains(u, "locked") && (cred == nil || cred.Value != "ann:pw:1"):
		return orchestrator.SpecResult{}, fmt.Errorf("%w: it answered 401", orchestrator.ErrSpecNeedsLogin)
	case strings.Contains(u, "private") && cred == nil:
		return orchestrator.SpecResult{}, fmt.Errorf("%w: it answered 401", orchestrator.ErrSpecNeedsAuth)
	case strings.Contains(u, "private"):
		d, err := apispec.Parse([]byte(tinySpec), u)
		return orchestrator.SpecResult{URL: u, Doc: d, Ref: "up-auth"}, err
	case strings.Contains(u, "limit"):
		return orchestrator.SpecResult{}, orchestrator.ErrSpecFetchLimit
	case strings.Contains(u, "docs"):
		return orchestrator.SpecResult{URL: u, Choices: []apiclient.Choice{{Name: "v1", URL: u + "/v1.json"}}}, nil
	}
	d, err := apispec.Parse([]byte(tinySpec), u)
	return orchestrator.SpecResult{URL: u, Doc: d}, err
}

func (f *fakeSwagger) UploadSpec(_ context.Context, raw []byte) (string, orchestrator.SpecResult, error) {
	f.uploaded = len(raw)
	d, err := apispec.Parse([]byte(tinySpec), "")
	return "up-1", orchestrator.SpecResult{Doc: d}, err
}

func (f *fakeSwagger) CreateSwaggerTest(_ context.Context, in orchestrator.SwaggerTestInput, _ domain.Origin) (domain.Ticket, error) {
	f.created = in
	return domain.Ticket{Key: "TASK-9", Kind: domain.KindSwaggerTest, State: domain.StateCoding, Title: "t", Source: domain.SourceLocal}, nil
}

func (f *fakeSwagger) RerunSwaggerTest(_ context.Context, key string, cred *string, _ domain.Origin) (domain.Ticket, error) {
	f.rerunTok = cred
	return domain.Ticket{Key: key, Kind: domain.KindSwaggerTest, State: domain.StateCoding, Title: "t", Source: domain.SourceLocal}, nil
}

func (f *fakeSwagger) SwaggerResultsOf(_ context.Context, key string) (orchestrator.SwaggerView, error) {
	if key != "TASK-9" {
		return orchestrator.SwaggerView{}, domain.ErrNotFound
	}
	run := &domain.SwaggerRun{RunID: 4, CreatedAt: time.Now(), Results: domain.SwaggerResults{Status: "done", Summary: "2 cases", Cases: []domain.APICase{
		{ID: "a", Operation: "GET /orders", Case: "list", Verdict: domain.VerdictFail, Requests: []string{"r-001"}, Source: domain.CaseBySchema},
		{ID: "b", Operation: "GET /orders", Case: "list", Verdict: domain.VerdictPass, Requests: []string{"r-001"}, Source: domain.CaseByClaude},
	}}, Log: []domain.APIExchange{{ID: "r-001", Method: "GET", URL: "https://shop.example/orders", Status: 200, RespBody: `{"secret":"x"}`}}}
	return orchestrator.SwaggerView{Test: domain.SwaggerTest{BaseURL: "https://shop.example", Operations: []string{"GET /orders"},
		Auth: domain.APIAuth{Kind: domain.AuthHeader, Name: "X-Key"}, HasSecret: true}, Run: run,
		Previous: &domain.APICounts{Passed: 2}, NewFailures: []string{"GET /orders · list"}}, nil
}

func (f *fakeSwagger) SwaggerExchange(_ context.Context, key, id string) (domain.APIExchange, error) {
	if id != "r-001" {
		return domain.APIExchange{}, domain.ErrNotFound
	}
	return domain.APIExchange{ID: id, Method: "GET", URL: "https://shop.example/orders", Status: 200, RespBody: `{"ok":true}`,
		ReqHeaders: map[string]string{"X-Key": domain.Masked}}, nil
}

func TestSwaggerEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := map[string]string{"Cookie": rec.Result().Cookies()[0].String()}
	big := strings.Repeat(" ", 3<<20) // a 3 MB spec is over the usual 1 MB body limit
	cases := []struct {
		method, path, body string
		want               int
		contains           string
	}{
		{"POST", "/api/swagger-tests/spec", `{"url":"https://shop.example/openapi.json"}`, 200, `"sideEffect":"logout"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://shop.example/openapi.json"}`, 200, `"authKind":"header"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://shop.example/docs"}`, 200, `"choices":[{"name":"v1"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://limit.example/x"}`, 429, `too_many_requests`},
		{"POST", "/api/swagger-tests/spec", `{}`, 400, `bad_request`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://private.example/openapi.json"}`, 400, `"code":"spec_needs_auth"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://locked.example/docs"}`, 400, `"code":"spec_needs_login"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://locked.example/docs","login":{"username":"a:b","password":"x"}}`, 400, `cannot contain a colon`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://locked.example/docs","login":{"username":"ann","password":"pw:1"}}`, 200, `"operations"`},
		{"POST", "/api/swagger-tests/spec", `{"url":"https://private.example/openapi.json","auth":{"kind":"bearer","value":"t-1"}}`, 200, `"specRef":"up-auth"`},
		{"POST", "/api/swagger-tests/spec", `{"spec":"` + big + `x"}`, 200, `"specRef":"up-1"`},
		{"POST", "/api/swagger-tests", `{"specRef":"up-1","baseUrl":"https://staging.shop.example","operations":["GET /orders"],"auth":{"kind":"header","name":"X-Key","value":"k-123"},"writeEnabled":true,"notProduction":true,"start":"queue"}`, 201, `"key":"TASK-9"`},
		{"GET", "/api/tickets/TASK-9/api-results", "", 200, `"newFailures":["GET /orders · list"]`},
		{"GET", "/api/tickets/TASK-9/api-results", "", 200, `"source":"schema"`},
		{"GET", "/api/tickets/TASK-9/api-results", "", 200, `"hasToken":true`},
		{"GET", "/api/tickets/TASK-8/api-results", "", 404, `not_found`},
		{"GET", "/api/tickets/TASK-9/api-results/requests/r-001", "", 200, `"responseBody":"{\"ok\":true}"`},
		{"GET", "/api/tickets/TASK-9/api-results/requests/r-002", "", 404, `no such request`},
		{"POST", "/api/tickets/TASK-9/swagger-test/rerun", `{"token":"t-new"}`, 200, `"key":"TASK-9"`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, truncateTest(rec.Body.String()), c.want, c.contains)
		}
	}
	if in := h.swagger.created; in.SpecRef != "up-1" || in.Credential != "k-123" || in.Auth.Name != "X-Key" || !in.WriteEnabled || !in.NotProduction || in.Start != "queue" {
		t.Errorf("create input: %+v", in)
	}
	if h.swagger.uploaded < 3<<20 {
		t.Errorf("uploaded %d bytes", h.swagger.uploaded)
	}
	if c := h.swagger.specCred; c == nil || c.Value != "t-1" || c.Kind != domain.AuthBearer {
		t.Errorf("spec credential: %+v", c)
	}
	if h.swagger.rerunTok == nil || *h.swagger.rerunTok != "t-new" {
		t.Errorf("rerun token: %v", h.swagger.rerunTok)
	}
	// The results list carries no bodies: one request is fetched at a time.
	rec = h.do("GET", "/api/tickets/TASK-9/api-results", "", cookie)
	if strings.Contains(rec.Body.String(), "secret") {
		t.Error("the results list carries response bodies")
	}
}

func truncateTest(s string) string {
	if len(s) > 300 {
		return s[:300] + "…"
	}
	return s
}

func (f *fakeSwagger) SaveSuiteFromTicket(_ context.Context, in orchestrator.SuiteInput) (domain.SwaggerSuite, error) {
	if in.FromTicket != "TASK-9" {
		return domain.SwaggerSuite{}, domain.ErrNotFound
	}
	return domain.SwaggerSuite{ID: 3, Name: in.Name, BaseURL: "https://staging.test", Operations: []string{"GET /a"}, Schedule: in.Schedule, Hour: in.Hour,
		Enabled: in.Enabled, Auth: domain.APIAuth{Kind: domain.AuthBearer}, HasSecret: true}, nil
}

func (f *fakeSwagger) UpdateSuite(_ context.Context, id int64, in orchestrator.SuiteInput) (domain.SwaggerSuite, error) {
	return domain.SwaggerSuite{ID: id, Name: in.Name, Schedule: in.Schedule, Hour: in.Hour, Enabled: in.Enabled}, nil
}

func (f *fakeSwagger) Suites(context.Context) ([]domain.SwaggerSuite, error) {
	return []domain.SwaggerSuite{{ID: 3, Name: "Shop", Schedule: domain.ScheduleDaily, Hour: 6, Enabled: true, HookSet: true}}, nil
}

func (f *fakeSwagger) Suite(_ context.Context, id int64) (domain.SwaggerSuite, error) {
	if id != 3 {
		return domain.SwaggerSuite{}, domain.ErrNotFound
	}
	return domain.SwaggerSuite{ID: 3, Name: "Shop", Schedule: domain.ScheduleDaily, Hour: 6, Enabled: true}, nil
}

func (f *fakeSwagger) DeleteSuite(_ context.Context, id int64) error {
	if id != 3 {
		return domain.ErrNotFound
	}
	return nil
}

func (f *fakeSwagger) RunSuite(_ context.Context, id int64, _ domain.Origin) (domain.Ticket, error) {
	if id == 4 {
		return domain.Ticket{Key: "TASK-11"}, orchestrator.ErrSuiteBusy
	}
	return domain.Ticket{Key: "TASK-10", Kind: domain.KindSwaggerTest, State: domain.StateCoding, Title: "t", Source: domain.SourceLocal}, nil
}

func (f *fakeSwagger) RotateSuiteHook(context.Context, int64) (string, error) {
	return "agnts_sh_tok", nil
}

func (f *fakeSwagger) RunSuiteByHook(_ context.Context, tok string) (domain.Ticket, error) {
	if tok != "agnts_sh_tok" {
		return domain.Ticket{}, domain.ErrNotFound
	}
	return domain.Ticket{Key: "TASK-12"}, nil
}

func TestSwaggerSuiteEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := map[string]string{"Cookie": rec.Result().Cookies()[0].String()}
	cases := []struct {
		method, path, body string
		hdr                map[string]string
		want               int
		contains           string
	}{
		{"GET", "/api/swagger-suites", "", cookie, 200, `"hookSet":true`},
		{"POST", "/api/swagger-suites", `{"name":"Shop"}`, cookie, 400, `fromTicket is required`},
		{"POST", "/api/swagger-suites", `{"fromTicket":"TASK-9","name":"Shop","schedule":"daily","hour":7}`, cookie, 201, `"schedule":"daily"`},
		{"POST", "/api/swagger-suites", `{"fromTicket":"TASK-1","name":"x"}`, cookie, 404, `no such ticket`},
		{"PATCH", "/api/swagger-suites/3", `{"enabled":false}`, cookie, 200, `"enabled":false`},
		{"PATCH", "/api/swagger-suites/3", `{"schedule":"weekly"}`, cookie, 200, `"name":"Shop"`},
		{"PATCH", "/api/swagger-suites/9", `{"enabled":false}`, cookie, 404, `no such suite`},
		{"POST", "/api/swagger-suites/3/run", "", cookie, 201, `"key":"TASK-10"`},
		{"POST", "/api/swagger-suites/4/run", "", cookie, 409, `still going`},
		{"POST", "/api/swagger-suites/3/hook", "", cookie, 200, `/webhooks/swagger-suite/agnts_sh_tok`},
		{"DELETE", "/api/swagger-suites/3", "", cookie, 204, ``},
		// The deploy hook needs no session.
		{"POST", "/webhooks/swagger-suite/agnts_sh_tok", "", nil, 202, `"ticket":"TASK-12"`},
		{"POST", "/webhooks/swagger-suite/agnts_sh_bad", "", nil, 404, `no such hook`},
		{"GET", "/api/swagger-suites", "", nil, 401, ``},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, c.hdr)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, truncateTest(rec.Body.String()), c.want, c.contains)
		}
	}
}
