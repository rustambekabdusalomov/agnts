package actions_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"agnts/internal/actions"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

func proposals(t *testing.T, list ...string) []domain.AssistantProposal {
	t.Helper()
	var out []domain.AssistantProposal
	for i := 0; i < len(list); i += 2 {
		out = append(out, domain.AssistantProposal{Tool: list[i], Args: json.RawMessage(list[i+1])})
	}
	return out
}

func TestAssistantActions(t *testing.T) {
	ctx, d, pool := setupPool(t)
	box, err := secret.NewBox(bytes.Repeat([]byte{4}, 32))
	if err != nil {
		t.Fatal(err)
	}
	conv := postgres.NewAssistant(pool, box)
	asker, viewer, other := pgtest.User(t, pool, "asker"), pgtest.User(t, pool, "viewer"), pgtest.User(t, pool, "other")
	roles := map[int64]domain.WorkspaceRole{asker: domain.RoleUser, viewer: domain.RoleViewer, other: domain.RoleOwner}
	as := &actions.Assistant{Deps: d, Role: func(_ context.Context, _, user int64) (domain.WorkspaceRole, error) { return roles[user], nil }}
	me := domain.WithActor(ctx, domain.Actor{UserID: asker, Username: "asker"})

	c, err := conv.CreateAssistantConversation(me, asker, "Reject PAY-1")
	if err != nil {
		t.Fatal(err)
	}
	ans, err := conv.AddAssistantMessage(me, domain.AssistantMessage{ConversationID: c.ID, Role: domain.AssistantReply, Status: domain.AssistantPending, Lang: "en"})
	if err != nil {
		t.Fatal(err)
	}

	// A viewer gets no actions, only why.
	if acts, errs := as.Propose(ctx, viewer, ans.ID, proposals(t, actions.RejectTicket, `{"key":"PAY-1"}`)); len(acts) != 0 || len(errs) != 1 ||
		!strings.Contains(errs[0], "Viewers") {
		t.Fatalf("viewer: %v %v", acts, errs)
	}

	acts, errs := as.Propose(me, asker, ans.ID, proposals(t,
		actions.RejectTicket, `{"key":"PAY-1","reason":"not needed"}`,
		actions.StartRun, `{"key":"PAY-404"}`,
		actions.RejectTicket, `{"key":"PAY-1","reason":"not needed"}`, // the same again
		actions.ApproveTicket, `{"key":"PAY-1"}`,
		actions.RetryRun, `{"key":"PAY-1"}`))
	if len(acts) != 3 || len(errs) != 1 || !strings.Contains(errs[0], `start_run: no ticket "PAY-404"`) {
		t.Fatalf("proposed %+v, errors %v", acts, errs)
	}
	reject, approve, retry := acts[0], acts[1], acts[2]
	if reject.Status != domain.ActionProposed || !reject.Destructive || reject.TicketKey != "PAY-1" || !strings.HasPrefix(reject.Summary, "Reject PAY-1") {
		t.Fatalf("reject = %+v", reject)
	}
	ans.Status, ans.Text, ans.ActionErrors = domain.AssistantDone, "Confirm to reject PAY-1.", errs
	if err := conv.FinishAssistantMessage(me, ans, nil); err != nil {
		t.Fatal(err)
	}

	// The conversation shows the cards with its answer.
	got, err := conv.AssistantConversation(me, asker, c.ID)
	if err != nil {
		t.Fatal(err)
	}
	if m := got.Messages[0]; len(m.Actions) != 3 || m.Actions[0].ID != reject.ID || m.Actions[0].ConversationID != c.ID || len(m.ActionErrors) != 1 {
		t.Fatalf("message = %+v", m)
	}

	// Only the asker confirms, and only here: not through MCP.
	if _, err := as.Confirm(ctx, other, reject.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("other confirmed: %v", err)
	}
	if _, err := as.Cancel(ctx, other, reject.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("other cancelled: %v", err)
	}
	if _, err := d.Store.ConfirmPending(ctx, reject.ID, domain.OriginMCP); !errors.Is(err, postgres.ErrExpired) {
		t.Fatalf("confirmed through MCP: %v", err)
	}
	roles[asker] = domain.RoleViewer
	if _, err := as.Confirm(me, asker, reject.ID); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("confirmed as a viewer: %v", err)
	}
	roles[asker] = domain.RoleUser

	done, err := as.Confirm(me, asker, reject.ID)
	if err != nil {
		t.Fatal(err)
	}
	if done.Status != domain.ActionDone || done.Result != "PAY-1 is now rejected." {
		t.Fatalf("confirmed = %+v", done)
	}
	if _, err := as.Confirm(me, asker, reject.ID); !errors.Is(err, postgres.ErrExpired) {
		t.Fatalf("confirmed twice: %v", err)
	}
	var origin string
	if err := pool.QueryRow(ctx, `SELECT origin FROM events WHERE ticket_key = 'PAY-1' ORDER BY id DESC LIMIT 1`).Scan(&origin); err != nil ||
		origin != string(domain.OriginAssistant) {
		t.Fatalf("event origin = %q, %v", origin, err)
	}

	// The ticket moved on: the action fails with the reason, and stays failed.
	failed, err := as.Confirm(me, asker, approve.ID)
	if err != nil {
		t.Fatal(err)
	}
	if failed.Status != domain.ActionFailed || !strings.Contains(failed.Result, "not possible now") {
		t.Fatalf("approve after reject = %+v", failed)
	}

	// Declined, it cannot be confirmed.
	if x, err := as.Cancel(me, asker, retry.ID); err != nil || x.Status != domain.ActionCancelled {
		t.Fatalf("cancel = %+v, %v", x, err)
	}
	if _, err := as.Confirm(me, asker, retry.ID); !errors.Is(err, postgres.ErrExpired) {
		t.Fatalf("confirmed after cancel: %v", err)
	}

	// The next question sees what became of them.
	q, err := conv.AddAssistantMessage(me, domain.AssistantMessage{ConversationID: c.ID, Role: domain.AssistantUser, Text: "and now?", Status: domain.AssistantDone})
	if err != nil {
		t.Fatal(err)
	}
	h, err := conv.AssistantHistory(me, c.ID, q.ID, 6)
	if err != nil || len(h) != 1 || len(h[0].Actions) != 3 || h[0].Actions[0].Status != domain.ActionDone || h[0].Actions[2].Status != domain.ActionCancelled {
		t.Fatalf("history = %+v, %v", h, err)
	}

	// An action nobody confirmed in time expires.
	late, _ := as.Propose(me, asker, ans.ID, proposals(t, actions.RetryRun, `{"key":"PAY-1"}`))
	if _, err := pool.Exec(ctx, `UPDATE pending_actions SET expires_at = now() - interval '1 minute' WHERE id = $1`, late[0].ID); err != nil {
		t.Fatal(err)
	}
	if _, err := as.Confirm(me, asker, late[0].ID); !errors.Is(err, postgres.ErrExpired) {
		t.Fatalf("confirmed late: %v", err)
	}
	if x, err := d.Store.AssistantAction(me, asker, late[0].ID); err != nil || x.Status != domain.ActionExpired {
		t.Fatalf("late = %+v, %v", x, err)
	}

	// Stats count them by what became of them, and the not-offered one.
	st, err := conv.AssistantStats(me, 7)
	if err != nil {
		t.Fatal(err)
	}
	if want := (domain.AssistantActionStats{Proposed: 4, Done: 1, Failed: 1, Cancelled: 1, Expired: 1, NotOffered: 1}); st.Actions != want {
		t.Fatalf("action stats = %+v, want %+v", st.Actions, want)
	}
	if len(st.Versions) != 1 || st.Versions[0].Proposed != 4 || st.Versions[0].Done != 1 {
		t.Fatalf("version stats = %+v", st.Versions)
	}
	// A rated answer shows its actions to the owner.
	if _, err := conv.RateAssistantMessage(me, asker, ans.ID, -1, "should not have offered retry", false); err != nil {
		t.Fatal(err)
	}
	rated, err := conv.AssistantRated(me, 0, 10)
	if err != nil || len(rated) != 1 || len(rated[0].Actions) != 4 || rated[0].Actions[0].Status != domain.ActionDone {
		t.Fatalf("rated = %+v, %v", rated, err)
	}

	// Deleting the conversation deletes its actions.
	if err := conv.DeleteAssistantConversation(me, asker, c.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := d.Store.AssistantAction(me, asker, reject.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("action outlived its conversation: %v", err)
	}
}

func TestAssistantToolsMatchActions(t *testing.T) {
	ctx, d := setup(t)
	for _, tool := range orchestrator.AssistantTools {
		if _, err := d.Prepare(ctx, tool.Name, json.RawMessage(`{}`)); err != nil && strings.Contains(err.Error(), "unknown action") {
			t.Errorf("the prompt offers %s, which is not an action", tool.Name)
		}
	}
	if len(orchestrator.AssistantTools) != 11 {
		t.Errorf("the prompt offers %d actions, want all 11", len(orchestrator.AssistantTools))
	}
}
