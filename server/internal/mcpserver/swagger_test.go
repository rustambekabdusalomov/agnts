package mcpserver_test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

var (
	testSwagger *postgres.SwaggerTests
	testPool    *pgxpool.Pool
)

func TestAPIResultsTool(t *testing.T) {
	cs, store := setup(t)
	tk, err := store.CreateTicket(testCtx, domain.Ticket{Key: "TASK-1", Source: domain.SourceLocal, Kind: domain.KindSwaggerTest, Title: "API",
		Priority: "medium", State: domain.StateCoding, ResumeState: domain.StateCoding, AfterApprove: "pr"}, domain.Event{Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	if err := testSwagger.SaveSwaggerTest(testCtx, domain.SwaggerTest{TicketID: tk.ID, Spec: json.RawMessage(`{}`), BaseURL: "https://staging.test",
		Operations: []string{"GET /users/{id}"}, Auth: domain.APIAuth{Kind: domain.AuthNone}}, nil); err != nil {
		t.Fatal(err)
	}
	if out, _ := call(t, cs, "get_api_results", map[string]any{"key": "TASK-1"}); out["ran"] != false {
		t.Errorf("before a run: %v", out)
	}
	var runID int64
	if err := testPool.QueryRow(testCtx, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, 'code', 'sonnet') RETURNING id`, tk.ID).Scan(&runID); err != nil {
		t.Fatal(err)
	}
	if err := testSwagger.SaveSwaggerResults(testCtx, domain.SwaggerRun{RunID: runID, TicketID: tk.ID, Results: domain.SwaggerResults{Summary: "2 cases", Cases: []domain.APICase{
		{ID: "a", Operation: "GET /users/{id}", Case: "unknown id", Expected: "404", Verdict: domain.VerdictFail, Reason: "500", Requests: []string{"r-001"}, Source: domain.CaseByClaude},
		{ID: "b", Operation: "GET /users/{id}", Case: "known id", Verdict: domain.VerdictPass, Requests: []string{"r-002"}, Source: domain.CaseByClaude},
	}}, Log: []domain.APIExchange{{ID: "r-001", Method: "GET", URL: "https://staging.test/users/9", Status: 500, RespBody: `{"trace":"boom"}`}}}); err != nil {
		t.Fatal(err)
	}
	out, isErr := call(t, cs, "get_api_results", map[string]any{"key": "TASK-1", "exchanges": true})
	b, _ := json.Marshal(out)
	if isErr || out["failed"] != float64(1) || out["passed"] != float64(1) || !strings.Contains(string(b), `"response_body":"{\"trace\":\"boom\"}"`) {
		t.Errorf("get_api_results: %s", b)
	}
	if out, isErr := call(t, cs, "get_api_results", map[string]any{"key": "PAY-1"}); !isErr {
		t.Errorf("a ticket that is not a Swagger test: %v", out)
	}
}
