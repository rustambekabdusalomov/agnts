package postgres

import (
	"bytes"
	"encoding/json"
	"errors"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestSwaggerTests(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	box, err := secret.NewBox(bytes.Repeat([]byte{7}, 32))
	if err != nil {
		t.Fatal(err)
	}
	s := NewSwaggerTests(users.db, box)
	agent := NewAgent(users.db)
	tk, err := agent.CreateTicket(ctx, domain.Ticket{Key: "TASK-1", Source: domain.SourceLocal, Kind: domain.KindSwaggerTest, Title: "API",
		Priority: "medium", State: domain.StateCoding, ResumeState: domain.StateCoding, AfterApprove: "pr"},
		domain.Event{TicketKey: "TASK-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	const tok = "tok-super-secret-value"
	cred := tok
	st := domain.SwaggerTest{TicketID: tk.ID, SpecURL: "https://x.test/openapi.json", Spec: json.RawMessage(`{"openapi":"3.0.3"}`),
		BaseURL: "https://staging.x.test", Operations: []string{"GET /users"}, Auth: domain.APIAuth{Kind: domain.AuthBearer}, RateLimit: 3}
	if err := s.SaveSwaggerTest(ctx, st, &cred); err != nil {
		t.Fatal(err)
	}
	got, err := s.SwaggerTest(ctx, tk.ID)
	if err != nil || !got.HasSecret || got.BaseURL != st.BaseURL || len(got.Operations) != 1 || got.RateLimit != 3 || got.Auth.Kind != domain.AuthBearer {
		t.Fatalf("%+v %v", got, err)
	}
	if v, err := s.SwaggerTestAuth(ctx, tk.ID); err != nil || v != tok {
		t.Fatalf("auth = %q %v", v, err)
	}
	var raw []byte
	if err := users.db.QueryRow(ctx, `SELECT auth_sealed FROM swagger_tests WHERE ticket_id = $1`, tk.ID).Scan(&raw); err != nil || bytes.Contains(raw, []byte(tok)) {
		t.Fatalf("the credential is stored in the clear: %v", err)
	}
	if _, err := s.SwaggerTest(other, tk.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace reads the test: %v", err)
	}
	// Saving again without a credential keeps it.
	st.Operations = []string{"GET /users", "GET /orders"}
	if err := s.SaveSwaggerTest(ctx, st, nil); err != nil {
		t.Fatal(err)
	}
	if got, _ := s.SwaggerTest(ctx, tk.ID); !got.HasSecret || len(got.Operations) != 2 {
		t.Fatalf("after save: %+v", got)
	}

	var runID int64
	if err := users.db.QueryRow(ctx, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, 'code', 'sonnet') RETURNING id`, tk.ID).Scan(&runID); err != nil {
		t.Fatal(err)
	}
	res := domain.SwaggerResults{Status: "done", Summary: "s", Cases: []domain.APICase{
		{ID: "a", Operation: "GET /users", Verdict: domain.VerdictPass, Requests: []string{"r-001"}},
		{ID: "b", Operation: "GET /users", Verdict: domain.VerdictFail, Requests: []string{"r-001"}},
	}}
	if err := s.SaveSwaggerResults(ctx, domain.SwaggerRun{RunID: runID, TicketID: tk.ID, Results: res,
		Log: []domain.APIExchange{{ID: "r-001", Method: "GET", URL: "https://staging.x.test/users", Status: 200}}, Plan: json.RawMessage(`{"cases":[]}`)}); err != nil {
		t.Fatal(err)
	}
	run, err := s.SwaggerResults(ctx, tk.ID)
	if err != nil || run.Counts.Passed != 1 || run.Counts.Failed != 1 || len(run.Log) != 1 || len(run.Results.Cases) != 2 || string(run.Plan) == "" {
		t.Fatalf("%+v %v", run, err)
	}
	if _, err := s.SwaggerResultsBefore(ctx, tk.ID, runID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("before the first run: %v", err)
	}

	// Closing the ticket deletes the credential.
	if _, err := agent.Transition(ctx, tk.Key, domain.StateRejected, domain.Event{TicketKey: tk.Key, Type: domain.EventStateChanged}, nil); err != nil {
		t.Fatal(err)
	}
	if got, _ := s.SwaggerTest(ctx, tk.ID); got.HasSecret {
		t.Fatal("a closed ticket keeps its credential")
	}
	if v, err := s.SwaggerTestAuth(ctx, tk.ID); err != nil || v != "" {
		t.Fatalf("after close: %q %v", v, err)
	}
	if err := s.SetSwaggerTestAuth(ctx, tk.ID, "new-token-value"); err != nil {
		t.Fatal(err)
	}
	if v, _ := s.SwaggerTestAuth(ctx, tk.ID); v != "new-token-value" {
		t.Fatalf("set: %q", v)
	}
}
