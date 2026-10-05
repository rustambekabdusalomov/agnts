package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"testing"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
)

type fakeTickets struct {
	lastOrigin domain.Origin
	lastAnswer []domain.Answer
}

func (f *fakeTickets) ticket(key string, s domain.TicketState) (domain.Ticket, error) {
	if key == "NOPE-1" {
		return domain.Ticket{}, domain.ErrNotFound
	}
	return domain.Ticket{Key: key, Title: "t", State: s, Source: domain.SourceJira}, nil
}

func (f *fakeTickets) List(_ context.Context, fl orchestrator.TicketFilter) ([]domain.Ticket, error) {
	t, _ := f.ticket("PAY-1", domain.StateNew)
	if len(fl.States) == 1 && fl.States[0] == domain.StateDone {
		return nil, nil
	}
	return []domain.Ticket{t}, nil
}

func (f *fakeTickets) View(_ context.Context, key string) (orchestrator.TicketView, error) {
	t, err := f.ticket(key, domain.StateWaitingForReview)
	ans := "half up"
	return orchestrator.TicketView{
		Ticket:    t,
		Settings:  domain.DefaultSettings(),
		Questions: []domain.Question{{ID: 9, Position: 1, Text: "Rounding?", Options: []string{"a"}, Answer: &ans}},
		Analysis:  &orchestrator.Analysis{Summary: "s", Plan: []string{"p"}},
		Result: &domain.Result{
			Summary: json.RawMessage(`{"summary":"did it","notes":["n"]}`),
			Tests:   json.RawMessage(`[{"name":"test","command":"go test","exit_code":0,"duration_ms":1200}]`),
			Files:   []domain.FileChange{{Path: "a.go", Add: 1, Diff: "+x"}},
		},
	}, err
}

func (f *fakeTickets) Events(context.Context, orchestrator.EventFilter) ([]domain.Event, error) {
	return []domain.Event{{ID: 5, TicketKey: "PAY-1", Type: "claude_tool", Level: domain.LevelInfo, Origin: domain.OriginSystem, Message: "Read: a.go"}}, nil
}

func (f *fakeTickets) Answer(_ context.Context, key string, as []domain.Answer, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin, f.lastAnswer = o, as
	return f.ticket(key, domain.StateCoding)
}

func (f *fakeTickets) Approve(_ context.Context, key string, _ []string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	if key == "DONE-1" {
		return domain.Ticket{}, &domain.TransitionError{Key: key, From: domain.StateDone, To: domain.StatePushing}
	}
	return f.ticket(key, domain.StatePushing)
}

func (f *fakeTickets) RequestChanges(_ context.Context, key, fb string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	if strings.TrimSpace(fb) == "" {
		return domain.Ticket{}, fmt.Errorf("%w: feedback is required", orchestrator.ErrInvalid)
	}
	return f.ticket(key, domain.StateCoding)
}

func (f *fakeTickets) Reject(_ context.Context, key, _ string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateRejected)
}

func (f *fakeTickets) Retry(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) Start(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) Stop(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	return f.ticket(key, domain.StateFailed)
}

func (f *fakeTickets) Learn(_ context.Context, key string, o domain.Origin) (domain.Ticket, error) {
	f.lastOrigin = o
	t, err := f.ticket(key, domain.StateDone)
	t.LearnState = domain.LearnPending
	return t, err
}

func (f *fakeTickets) SetRepo(_ context.Context, key string, _ int64, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) SetModels(_ context.Context, key string, _ map[string]string, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) CreateTask(_ context.Context, in orchestrator.TaskInput, _ domain.Origin) (domain.Ticket, error) {
	return domain.Ticket{Key: "VIS-1", Title: in.Title, State: domain.StateNew, Source: domain.SourceLocal}, nil
}

func (f *fakeTickets) UpdateTask(_ context.Context, key string, _ orchestrator.TaskInput, _ domain.Origin) (domain.Ticket, error) {
	return f.ticket(key, domain.StateNew)
}

func (f *fakeTickets) DeleteTask(context.Context, string, domain.Origin) error { return nil }

func (f *fakeTickets) Rows(_ context.Context, ts []domain.Ticket) ([]orchestrator.TicketRow, error) {
	out := make([]orchestrator.TicketRow, len(ts))
	for i, t := range ts {
		out[i] = orchestrator.TicketRow{Ticket: t, RepoName: "api"}
	}
	return out, nil
}

func (f *fakeTickets) Wake() {}

func TestTicketEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	if rec := h.do("GET", "/api/tickets", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("tickets without session: %d", rec.Code)
	}
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := map[string]string{"Cookie": rec.Result().Cookies()[0].String()}

	cases := []struct {
		method, path, body string
		want               int
		contains           string
	}{
		{"GET", "/api/tickets", "", 200, `"key":"PAY-1"`},
		{"GET", "/api/tickets?state=done", "", 200, `[]`},
		{"GET", "/api/tickets?state=bogus", "", 400, ``},
		{"GET", "/api/tickets/PAY-1", "", 200, `"checks":[{"command":"go test","durationMs":1200,"exitCode":0,"name":"test"}]`},
		{"GET", "/api/tickets/NOPE-1", "", 404, `not_found`},
		{"GET", "/api/tickets/PAY-1/events?after=4", "", 200, `"message":"Read: a.go"`},
		{"PUT", "/api/tickets/PAY-1/answers", `{"answers":[{"questionId":9,"answer":"half up","note":"n"}]}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/approve", "", 200, `"state":"pushing"`},
		{"POST", "/api/tickets/PAY-1/approve", `{"assignees":["alice"]}`, 200, `"state":"pushing"`},
		{"POST", "/api/tickets/PAY-1/approve", `{"assignees":"alice"}`, 400, `bad_request`},
		{"POST", "/api/tickets/DONE-1/approve", "", 409, `conflict`},
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"  "}`, 400, `feedback is required`},
		{"POST", "/api/tickets/PAY-1/request-changes", `{"feedback":"more tests"}`, 200, `"state":"coding"`},
		{"POST", "/api/tickets/PAY-1/reject", "", 200, `"state":"rejected"`},
		{"POST", "/api/tickets/PAY-1/retry", "", 200, `"state":"new"`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, rec.Body, c.want, c.contains)
		}
	}
	if h.tickets.lastOrigin != domain.OriginWeb || len(h.tickets.lastAnswer) != 1 || h.tickets.lastAnswer[0].Note != "n" {
		t.Errorf("web origin/answers not passed: %v %+v", h.tickets.lastOrigin, h.tickets.lastAnswer)
	}

	// Mobile: a fresh harness, since each TOTP step signs in only once.
	h = newHarness(t, pinger{})
	rec = h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "mobile"), nil)
	var resp struct{ Token string }
	_ = json.Unmarshal(rec.Body.Bytes(), &resp)
	if rec := h.do("POST", "/api/tickets/PAY-1/approve", "", map[string]string{"Authorization": "Bearer " + resp.Token}); rec.Code != 200 {
		t.Fatalf("mobile approve: %d", rec.Code)
	}
	if h.tickets.lastOrigin != domain.OriginMobile {
		t.Errorf("mobile origin: %v", h.tickets.lastOrigin)
	}
}
