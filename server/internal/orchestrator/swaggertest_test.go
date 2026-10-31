package orchestrator_test

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"io"
	"log/slog"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/apiclient"
	"agnts/internal/domain"
	"agnts/internal/guard"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

const usersSpec = `{"openapi":"3.0.3","info":{"title":"Users API","version":"1"},
"servers":[{"url":"https://api.prod.example"}],
"components":{"securitySchemes":{"bearer":{"type":"http","scheme":"bearer"}},
  "schemas":{"User":{"type":"object","required":["id"],"properties":{"id":{"type":"integer"}}}}},
"security":[{"bearer":[]}],
"paths":{
  "/users":{"get":{"responses":{"200":{"description":"ok","content":{"application/json":{"schema":{"type":"array","items":{"$ref":"#/components/schemas/User"}}}}}}},
           "post":{"responses":{"201":{"description":"created"}}}},
  "/users/{id}":{"parameters":[{"name":"id","in":"path","required":true,"schema":{"type":"integer"}}],
    "get":{"responses":{"200":{"description":"ok","content":{"application/json":{"schema":{"$ref":"#/components/schemas/User"}}}},"404":{"description":"missing"}}}}}}`

const swaggerToken = "tok-0123456789-secret"

type swaggerHarness struct {
	*harness
	tests  *postgres.SwaggerTests
	suites *postgres.SwaggerSuites
	pool   *pgxpool.Pool
}

func newSwaggerHarness(t *testing.T) *swaggerHarness {
	t.Helper()
	h := newHarness(t)
	pool := pgtest.Open(t)
	box, err := secret.NewBox(bytes.Repeat([]byte{3}, 32))
	if err != nil {
		t.Fatal(err)
	}
	tests := postgres.NewSwaggerTests(pool, box)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: h.git, Host: h.host, Homes: &memHomes{}, Settings: h.settings, Usage: h.usage,
		Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker}, SwaggerTests: tests,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	suites := postgres.NewSwaggerSuites(pool, box)
	h.o.SetSwaggerSuites(suites)
	return &swaggerHarness{harness: h, tests: tests, suites: suites, pool: pool}
}

func (h *swaggerHarness) create(write bool) domain.Ticket {
	h.t.Helper()
	tk, err := h.o.CreateSwaggerTest(h.ctx, orchestrator.SwaggerTestInput{
		Spec: []byte(usersSpec), BaseURL: "http://203.0.113.7:8080", Operations: []string{"GET /users", "GET /users/{id}", "POST /users"},
		WriteEnabled: write, NotProduction: write, Auth: domain.APIAuth{Kind: domain.AuthBearer}, Credential: swaggerToken,
		Notes: "user 42 is a test account",
	}, domain.OriginWeb)
	if err != nil {
		h.t.Fatal(err)
	}
	return tk
}

// exchange is one log line as agnts-api writes it.
func exchange(id, method, path string, status int, body string) string {
	b, _ := json.Marshal(domain.APIExchange{ID: id, Method: method, URL: "http://203.0.113.7:8080" + path, Status: status,
		RespHeaders: map[string]string{"Content-Type": "application/json"}, RespBody: body,
		ReqHeaders: map[string]string{"Authorization": "Bearer " + swaggerToken}})
	return string(b)
}

func swaggerFiles(results string) map[string]string {
	log := strings.Join([]string{
		exchange("r-001", "GET", "/users", 200, `[{"id":"7"}]`), // id as a string: the schema check finds it
		exchange("r-002", "GET", "/users/42", 200, `{"id":42,"echo":"`+swaggerToken+`"}`),
		exchange("r-003", "GET", "/users/999999", 500, `{"trace":"boom"}`),
	}, "\n")
	return map[string]string{
		apiclient.LogPath:     log,
		apiclient.ResultsPath: results,
		apiclient.ReportPath:  "# Users API\n\nThe token " + swaggerToken + " worked.\n",
		apiclient.PlanPath:    `{"cases":[{"id":"users-list","method":"GET","path":"/users"}]}`,
	}
}

const goodResults = `{"status":"done","summary":"4 cases","cases":[
 {"id":"users-list","operation":"GET /users","case":"happy path","verdict":"pass","requests":["r-001"]},
 {"id":"users-get","operation":"GET /users/{id}","case":"known id","verdict":"pass","requests":["r-002"]},
 {"id":"users-unknown","operation":"GET /users/{id}","case":"unknown id","expected":"404","verdict":"fail","reason":"500","requests":["r-003"]},
 {"id":"users-claimed","operation":"GET /users/{id}","case":"made up","verdict":"fail","reason":"no evidence","requests":["r-999"]},
 {"id":"users-create","operation":"POST /users","case":"create","verdict":"skipped","reason":"write requests are off"}]}`

func TestSwaggerTestRun(t *testing.T) {
	h := newSwaggerHarness(t)
	// The workspace codes with Codex: a Swagger test still runs on Claude.
	h.settings.s.Models.Coding = "codex:gpt-5"
	var req orchestrator.ClaudeRequest
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { req = r }
	tk := h.create(false)
	if tk.State != domain.StateCoding || tk.Held || tk.Kind != domain.KindSwaggerTest {
		t.Fatalf("created %+v", tk)
	}
	h.runner.scripts = []script{{result: ok("s1"), files: swaggerFiles(goodResults)}}
	h.step()
	tk = h.expect(tk.Key, domain.StateWaitingForReview)

	// Inputs: the grant, the files, the credential only in its file.
	if g := h.runner.specs[0].Grants; len(g) != 1 || g[0].Host != "203.0.113.7" || g[0].Port != 8080 {
		t.Errorf("grants = %+v", g)
	}
	if !strings.Contains(h.runner.written[apiclient.AuthPath], swaggerToken) {
		t.Error("the credential file was not written")
	}
	for _, p := range []string{apiclient.SpecPath, apiclient.TestPath} {
		if h.runner.written[p] == "" || strings.Contains(h.runner.written[p], swaggerToken) {
			t.Errorf("%s: %q", p, h.runner.written[p])
		}
	}
	if strings.Contains(h.runner.written[apiclient.SpecPath], `"post"`) && !strings.Contains(h.runner.written[apiclient.SpecPath], `"/users"`) {
		t.Error("the trimmed spec")
	}
	if strings.Contains(h.runner.prompts[0], swaggerToken) || !strings.Contains(h.runner.prompts[0], "agnts-api run") {
		t.Errorf("prompt:\n%s", h.runner.prompts[0])
	}
	if req.Model != orchestrator.SwaggerModel(domain.DefaultAccess()) || req.MaxTurns > orchestrator.SwaggerTurns {
		t.Errorf("model %s, turns %d: Swagger tests run on Claude", req.Model, req.MaxTurns)
	}
	for _, rule := range []string{"Read(//agnts/context/api/.auth)", "Bash(curl *203.0.113.7*)"} {
		if !strings.Contains(req.Settings, rule) {
			t.Errorf("deny rules miss %s: %s", rule, req.Settings)
		}
	}
	gc := guardConfigOf(t, req)
	if gc.API == nil || gc.API.Host != "203.0.113.7" || gc.API.AuthPath != apiclient.AuthPath {
		t.Errorf("guard config: %+v", gc.API)
	}

	// Outputs: checked, redacted, stored.
	v, err := h.o.SwaggerResultsOf(h.ctx, tk.Key)
	if err != nil || v.Run == nil {
		t.Fatal(err)
	}
	ids := map[string]domain.APICase{}
	for _, c := range v.Run.Results.Cases {
		ids[c.ID] = c
	}
	if _, ok := ids["users-claimed"]; ok {
		t.Error("a verdict without a logged request was kept")
	}
	if c, ok := ids["users-create"]; !ok || c.Verdict != domain.VerdictSkipped {
		t.Error("a skipped case was dropped")
	}
	schema := 0
	for _, c := range v.Run.Results.Cases {
		if c.Source == domain.CaseBySchema {
			schema++
		}
	}
	if schema == 0 {
		t.Errorf("agnts's schema check found nothing: %+v", v.Run.Results.Cases)
	}
	all, _ := json.Marshal(v.Run)
	if bytes.Contains(all, []byte(swaggerToken)) {
		t.Error("the token is in the stored results or log")
	}
	res, err := h.store.LatestResult(h.ctx, tk.ID, domain.StageCode)
	if err != nil || strings.Contains(res.Report, swaggerToken) || !strings.Contains(res.Report, domain.Masked) {
		t.Errorf("report: %q %v", res.Report, err)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: tk.Key})
	var sawResults, sawClaudeOnly bool
	for _, e := range evs {
		if strings.Contains(e.Message, swaggerToken) {
			t.Errorf("event %s carries the token", e.Type)
		}
		sawResults = sawResults || (e.Type == domain.EventSwaggerResults && strings.Contains(e.Message, tk.Key+": 2 passed"))
		sawClaudeOnly = sawClaudeOnly || strings.Contains(e.Message, "always run on Claude")
	}
	if !sawResults || !sawClaudeOnly {
		t.Errorf("events: results %v, Claude only %v", sawResults, sawClaudeOnly)
	}

	// Rerun while open: back to work. Approve: done, and the token goes.
	if _, err := h.o.RerunSwaggerTest(h.ctx, tk.Key, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect(tk.Key, domain.StateCoding)
	h.runner.scripts = []script{{result: ok("s2"), files: swaggerFiles(goodResults)}}
	h.step()
	h.expect(tk.Key, domain.StateWaitingForReview)
	if v, _ := h.o.SwaggerResultsOf(h.ctx, tk.Key); v.Previous == nil {
		t.Error("the second run is not compared with the first")
	}
	if _, err := h.o.Approve(h.ctx, tk.Key, nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect(tk.Key, domain.StateDone)
	if st, _ := h.tests.SwaggerTest(h.ctx, tk.ID); st.HasSecret {
		t.Error("a closed test keeps its token")
	}
	if _, err := h.o.RerunSwaggerTest(h.ctx, tk.Key, nil, domain.OriginWeb); err == nil {
		t.Error("a closed test reran without a new token")
	}
	tok := "tok-new-0123456789"
	again, err := h.o.RerunSwaggerTest(h.ctx, tk.Key, &tok, domain.OriginWeb)
	if err != nil || again.Key == tk.Key || again.State != domain.StateCoding {
		t.Fatalf("rerun of a closed test: %+v %v", again, err)
	}
	if v, _ := h.tests.SwaggerTestAuth(h.ctx, again.ID); v != tok {
		t.Errorf("the new ticket's token = %q", v)
	}
}

func TestSwaggerTestAllBlocked(t *testing.T) {
	h := newSwaggerHarness(t)
	tk := h.create(false)
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{
		apiclient.ResultsPath: `{"status":"done","cases":[{"id":"a","operation":"GET /users","verdict":"blocked","reason":"401 on every request: the token expired"}]}`,
	}}}
	h.step()
	tk = h.expect(tk.Key, domain.StateFailed)
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: tk.Key})
	found := false
	for _, e := range evs {
		found = found || strings.Contains(e.Message, "the token expired")
	}
	if !found {
		t.Error("the failure does not say why")
	}
}

func TestSwaggerTestFormChecks(t *testing.T) {
	h := newSwaggerHarness(t)
	base := orchestrator.SwaggerTestInput{Spec: []byte(usersSpec), BaseURL: "https://staging.example", Operations: []string{"GET /users"},
		Auth: domain.APIAuth{Kind: domain.AuthBearer}, Credential: "t-1234"}
	for name, mut := range map[string]func(*orchestrator.SwaggerTestInput){
		"write without confirming": func(in *orchestrator.SwaggerTestInput) { in.WriteEnabled = true },
		"unknown endpoint":         func(in *orchestrator.SwaggerTestInput) { in.Operations = []string{"GET /nope"} },
		"no token":                 func(in *orchestrator.SwaggerTestInput) { in.Credential = "" },
		"bad base URL":             func(in *orchestrator.SwaggerTestInput) { in.BaseURL = "ftp://x" },
		"not a spec":               func(in *orchestrator.SwaggerTestInput) { in.Spec = []byte(`{"a":1}`) },
	} {
		in := base
		mut(&in)
		if _, err := h.o.CreateSwaggerTest(h.ctx, in, domain.OriginWeb); err == nil {
			t.Errorf("%s: accepted", name)
		}
	}
	if _, err := h.o.SetKind(h.ctx, "TASK-1", string(domain.KindSwaggerTest), domain.OriginWeb); err == nil {
		t.Error("a ticket was made a Swagger test without its form")
	}
}

func guardConfigOf(t *testing.T, req orchestrator.ClaudeRequest) guard.Config {
	t.Helper()
	for _, e := range req.Env {
		if v, ok := strings.CutPrefix(e, guard.ConfigEnv+"="); ok {
			b, _ := base64.StdEncoding.DecodeString(v)
			var c guard.Config
			_ = json.Unmarshal(b, &c)
			return c
		}
	}
	t.Fatal("no guard config")
	return guard.Config{}
}

func TestSwaggerTestByInstructions(t *testing.T) {
	h := newSwaggerHarness(t)
	in := orchestrator.SwaggerTestInput{Spec: []byte(usersSpec), BaseURL: "http://203.0.113.7:8080",
		Auth: domain.APIAuth{Kind: domain.AuthBearer}, Credential: swaggerToken}
	if _, err := h.o.CreateSwaggerTest(h.ctx, in, domain.OriginWeb); err == nil || !strings.Contains(err.Error(), "What to test") {
		t.Fatalf("no endpoints and no text: %v", err)
	}
	in.Notes = "Only GET /users/{id}: known and unknown ids."
	tk, err := h.o.CreateSwaggerTest(h.ctx, in, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if st, _ := h.tests.SwaggerTest(h.ctx, tk.ID); !st.ByInstructions() {
		t.Fatalf("ticked: %v", st.Operations)
	}
	h.runner.scripts = []script{{result: ok("s1"), files: swaggerFiles(goodResults)}}
	h.step()
	h.expect(tk.Key, domain.StateWaitingForReview)
	prompt := h.runner.prompts[0]
	for _, want := range []string{"the whole spec (3 endpoints)", "Test those and nothing else", "Only GET /users/{id}"} {
		if !strings.Contains(prompt, want) {
			t.Errorf("prompt misses %q", want)
		}
	}
	// The run sees every operation, and may report on any of them.
	if conf := h.runner.written[apiclient.TestPath]; !strings.Contains(conf, "POST /users") || !strings.Contains(conf, "GET /users/{id}") {
		t.Errorf("test.json: %s", conf)
	}
	v, _ := h.o.SwaggerResultsOf(h.ctx, tk.Key)
	if v.Run == nil || len(v.Run.Results.Cases) == 0 {
		t.Fatal("cases were dropped")
	}

	// A run that tested nothing says why.
	tk2, err := h.o.CreateSwaggerTest(h.ctx, in, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{apiclient.ResultsPath: `{"status":"done","cases":[]}`}}}
	h.step()
	h.expect(tk2.Key, domain.StateFailed)
}
