package httpapi

import (
	"context"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// fakeCode keeps one Code conversation (id 9) working on VIS-1.
type fakeCode struct {
	starts   []orchestrator.CodeStart
	lastSend orchestrator.CodeSend
	allowed  *bool
}

var codeAt = time.Date(2026, 10, 28, 9, 0, 0, 0, time.UTC)

func (f *fakeCode) CodeReady() bool { return true }

func (f *fakeCode) conv() domain.AssistantConversation {
	return domain.AssistantConversation{ID: 9, Title: "Add a rest timer", Mode: domain.ChatModeCode, CreatedAt: codeAt, UpdatedAt: codeAt,
		Repos: domain.RepoChoice{RepoID: 3}, Quick: true,
		Tickets: []domain.CodeTicket{{Key: "VIS-1", Title: "Add a rest timer", State: domain.StateCoding, Kind: domain.KindCode,
			Repos: []string{"visper"}, Current: true, AttachedAt: codeAt}},
		Messages: []domain.AssistantMessage{{ID: 1, ConversationID: 9, Role: domain.AssistantUser, Text: "Add a rest timer", Status: domain.AssistantDone,
			Lang: "en", TicketKey: "VIS-1", Routed: domain.RoutedCreated, CreatedAt: codeAt}}}
}

func (f *fakeCode) StartCode(_ context.Context, in orchestrator.CodeStart) (domain.AssistantConversation, error) {
	f.starts = append(f.starts, in)
	if in.Repos.Empty() && in.TicketKey == "" {
		return domain.AssistantConversation{}, orchestrator.ErrInvalid
	}
	return f.conv(), nil
}

func (f *fakeCode) SendCode(_ context.Context, id int64, in orchestrator.CodeSend) (domain.AssistantMessage, error) {
	f.lastSend = in
	switch {
	case id != 9:
		return domain.AssistantMessage{}, domain.ErrNotFound
	case in.Text == "while pushing":
		return domain.AssistantMessage{}, &domain.TransitionError{Key: "VIS-1", From: domain.StatePushing, To: domain.StateCoding}
	}
	return domain.AssistantMessage{ID: 2, ConversationID: 9, Role: domain.AssistantUser, Text: in.Text, Status: domain.AssistantDone, Lang: "en",
		TicketKey: "VIS-1", Routed: domain.RoutedQueued, CreatedAt: codeAt}, nil
}

func (f *fakeCode) CodeTimeline(_ context.Context, id int64) (domain.AssistantConversation, []domain.TimelineItem, error) {
	if id != 9 {
		return domain.AssistantConversation{}, nil, domain.ErrNotFound
	}
	c := f.conv()
	ev := domain.Event{ID: 40, TicketKey: "VIS-1", Type: domain.EventClaudeText, Level: domain.LevelInfo, Origin: domain.OriginSystem,
		Message: "Adding the timer.", Data: map[string]any{}, CreatedAt: codeAt.Add(time.Second)}
	return c, []domain.TimelineItem{{At: codeAt, Message: &c.Messages[0]}, {At: ev.CreatedAt, Event: &ev}}, nil
}

func (f *fakeCode) SetCodeRepos(_ context.Context, _ int64, repos domain.RepoChoice) (domain.AssistantConversation, error) {
	c := f.conv()
	c.Repos = repos
	return c, nil
}

func (f *fakeCode) AttachCodeTicket(_ context.Context, _ int64, key string) (domain.AssistantConversation, error) {
	if key != "PAY-1" {
		return domain.AssistantConversation{}, orchestrator.ErrInvalid
	}
	return f.conv(), nil
}

func (f *fakeCode) SendQueuedNow(context.Context, int64) (domain.AssistantConversation, error) {
	return f.conv(), nil
}

func (f *fakeCode) TicketConversation(_ context.Context, key string) (int64, error) {
	if key == "VIS-1" {
		return 9, nil
	}
	return 0, domain.ErrNotFound
}

func (f *fakeCode) approval() domain.CodeApproval {
	return domain.CodeApproval{ID: "ap1", ConversationID: 9, TicketKey: "VIS-1", Tool: "Bash", Command: "npm install left-pad",
		Reason: "installs a dependency", Status: domain.ApprovalPending, ExpiresAt: codeAt.Add(5 * time.Minute)}
}

func (f *fakeCode) CodeApprovals(context.Context, int64) ([]domain.CodeApproval, error) {
	return []domain.CodeApproval{f.approval()}, nil
}

func (f *fakeCode) DecideCodeApproval(_ context.Context, id string, allow bool) (domain.CodeApproval, error) {
	switch id {
	case "gone":
		return domain.CodeApproval{}, domain.ErrConflict
	case "ap1":
		f.allowed = &allow
		a := f.approval()
		a.Status = domain.ApprovalDenied
		if allow {
			a.Status = domain.ApprovalAllowed
		}
		return a, nil
	}
	return domain.CodeApproval{}, domain.ErrNotFound
}

func TestCodeEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	cases := []struct {
		method, path, body string
		want               int
		contains           string
	}{
		{"POST", "/api/assistant/code", `{"text":"Add a rest timer","repos":{"repoId":3},"kind":"auto","quick":true}`, 201, `"mode":"code"`},
		{"POST", "/api/assistant/code", `{"text":"Add a rest timer"}`, 400, `bad_request`},
		{"GET", "/api/assistant/conversations/9/timeline", "", 200, `"routed":"created","shared":false,"speech":"","status":"done","text":"Add a rest timer","ticketKey":"VIS-1"`},
		{"GET", "/api/assistant/conversations/9/timeline", "", 200, `"event":{"createdAt":"2026-10-28T09:00:01Z"`},
		{"GET", "/api/assistant/conversations/9/timeline", "", 200, `"approvals":[{"command":"npm install left-pad"`},
		{"GET", "/api/assistant/conversations/9/timeline", "", 200, `"tickets":[{"attachedAt":"2026-10-28T09:00:00Z","current":true,"key":"VIS-1","kind":"code","moved":false,"repos":["visper"],"state":"coding"`},
		{"GET", "/api/assistant/conversations/10/timeline", "", 404, `not_found`},
		{"POST", "/api/assistant/conversations/9/code", `{"text":"show seconds"}`, 200, `"routed":"queued"`},
		{"POST", "/api/assistant/conversations/9/code", `{"text":"while pushing"}`, 409, `VIS-1 is pushing`},
		{"POST", "/api/assistant/conversations/10/code", `{"text":"x"}`, 404, `not_found`},
		{"PUT", "/api/assistant/conversations/9/repos", `{"groupId":4}`, 200, `"repos":{"groupId":4}`},
		{"PUT", "/api/assistant/conversations/9/ticket", `{"key":"PAY-1"}`, 200, `"id":9`},
		{"PUT", "/api/assistant/conversations/9/ticket", `{"key":"NOPE-1"}`, 400, `bad_request`},
		{"POST", "/api/assistant/conversations/9/send-now", "", 200, `"quick":true`},
		{"GET", "/api/tickets/VIS-1/chat", "", 200, `{"conversationId":9}`},
		{"GET", "/api/tickets/PAY-2/chat", "", 404, `not_found`},
		{"POST", "/api/assistant/approvals/ap1", `{"allow":true}`, 200, `"status":"allowed"`},
		{"POST", "/api/assistant/approvals/gone", `{"allow":true}`, 409, `conflict`},
		{"POST", "/api/assistant/approvals/nope", `{"allow":false}`, 404, `not_found`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, rec.Body, c.want, c.contains)
		}
	}
	if s := h.codeChat.starts[0]; s.Text != "Add a rest timer" || s.Repos.RepoID != 3 || s.Kind != "auto" || !s.Quick {
		t.Errorf("start input: %+v", s)
	}
	if s := h.codeChat.lastSend; s.Text != "x" {
		t.Errorf("send input: %+v", s)
	}
	if h.codeChat.allowed == nil || !*h.codeChat.allowed {
		t.Errorf("decision: %v", h.codeChat.allowed)
	}
}
