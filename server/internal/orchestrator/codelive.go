package orchestrator

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"slices"
	"sync"
	"time"

	"agnts/internal/domain"
)

// A Muse run on a ticket that someone follows in a Code conversation is
// live: their messages go into its running turn (steering), and a tool call
// the guard leaves to a person (adding a dependency) waits for their answer
// in the chat. Both last as long as the run; nothing here is stored.

// EventCodeApproval says a tool call waits for a decision, or was decided
// or ran out of time: the people's open chats refresh. Live only.
const EventCodeApproval = "code_approval"

// codeLive is the live state of Code conversations' runs.
type codeLive struct {
	mu        sync.Mutex
	runs      map[string]*liveRun      // runKey(workspace, ticket) -> its run
	approvals map[string]*liveApproval // approval id -> it
}

// liveRun is a running stage of a ticket with people following it.
type liveRun struct {
	steer  chan string
	owners []CodeOwner
}

// liveApproval is a tool call a run asked the people about.
type liveApproval struct {
	a      domain.CodeApproval
	ws     int64
	owners []CodeOwner
	answer chan bool // gets the first decision
}

// steerBuffer is how many messages may wait for the run loop to take them.
const steerBuffer = 8

// codeLiveFor makes a ticket's Muse run live when people follow the ticket
// in a Code conversation: it returns the request's Steer and Ask (Ask only
// for coding), and the release to call when the run ends. Otherwise all are
// nil (and release does nothing).
func (o *Orchestrator) codeLiveFor(ctx context.Context, t domain.Ticket, stage domain.Stage, model string, readOnly bool) (<-chan string, func(ToolQuestion) <-chan bool, func()) {
	nothing := func() {}
	if o.codeChat == nil || !domain.IsMuse(model) || readOnly || (stage != domain.StageCode && stage != domain.StageAnalyze) {
		return nil, nil, nothing
	}
	owners, err := o.codeChat.CodeOwnersOfTicket(ctx, t.Key)
	if err != nil || len(owners) == 0 {
		return nil, nil, nothing
	}
	ws, key := t.WorkspaceID, runKey(t.WorkspaceID, t.Key)
	r := &liveRun{steer: make(chan string, steerBuffer), owners: owners}
	o.live.mu.Lock()
	if o.live.runs == nil {
		o.live.runs, o.live.approvals = map[string]*liveRun{}, map[string]*liveApproval{}
	}
	o.live.runs[key] = r
	o.live.mu.Unlock()

	var ask func(ToolQuestion) <-chan bool
	if stage == domain.StageCode {
		ask = func(q ToolQuestion) <-chan bool { return o.askOwners(ws, t.Key, owners, q) }
	}
	release := func() {
		o.live.mu.Lock()
		if o.live.runs[key] == r {
			delete(o.live.runs, key)
		}
		var ended []*liveApproval
		for id, a := range o.live.approvals {
			if a.ws == ws && a.a.TicketKey == t.Key {
				delete(o.live.approvals, id)
				if a.a.Status == domain.ApprovalPending {
					a.a.Status = domain.ApprovalExpired
					ended = append(ended, a)
				}
			}
		}
		o.live.mu.Unlock()
		for _, a := range ended {
			o.publishApproval(a)
		}
	}
	return r.steer, ask, release
}

// askOwners puts a tool call to the people following the ticket; the first
// answer goes to the run.
func (o *Orchestrator) askOwners(ws int64, ticketKey string, owners []CodeOwner, q ToolQuestion) <-chan bool {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	a := &liveApproval{ws: ws, owners: owners, answer: make(chan bool, 1), a: domain.CodeApproval{
		ID: "ap_" + hex.EncodeToString(b), ConversationID: owners[0].ConversationID, UserID: owners[0].UserID, TicketKey: ticketKey,
		Tool: q.Tool, Command: q.Command, Path: q.Path, Reason: q.Reason, Status: domain.ApprovalPending,
		ExpiresAt: time.Now().Add(domain.CodeApprovalTTL),
	}}
	o.live.mu.Lock()
	o.live.approvals[a.a.ID] = a
	o.live.mu.Unlock()
	o.publishApproval(a)
	return a.answer
}

// publishApproval tells each person following the ticket about an approval.
func (o *Orchestrator) publishApproval(a *liveApproval) {
	for _, w := range a.owners {
		o.publish(a.ws, w.UserID, EventCodeApproval, domain.AssistantMessage{ConversationID: w.ConversationID},
			map[string]any{"approval_id": a.a.ID, "ticket_key": a.a.TicketKey, "status": string(a.a.Status)})
	}
}

// steerCode delivers a Code message into the ticket's running turn, when
// its run is live, and reports whether it did.
func (o *Orchestrator) steerCode(ctx context.Context, t domain.Ticket, text string) bool {
	ws, user, err := asker(ctx)
	if err != nil {
		return false
	}
	o.live.mu.Lock()
	r := o.live.runs[runKey(ws, t.Key)]
	o.live.mu.Unlock()
	if r == nil || !slices.ContainsFunc(r.owners, func(w CodeOwner) bool { return w.UserID == user }) {
		return false
	}
	select {
	case r.steer <- text:
		return true
	default:
		return false // the run is not taking messages fast enough: queue it
	}
}

// CodeApprovals returns the tool calls asked about in one of the person's
// Code conversations while its runs go on, newest first.
func (o *Orchestrator) CodeApprovals(ctx context.Context, conversationID int64) ([]domain.CodeApproval, error) {
	if !o.CodeReady() {
		return nil, invalid("Code mode is not available")
	}
	ws, user, err := asker(ctx)
	if err != nil {
		return nil, err
	}
	now := time.Now()
	o.live.mu.Lock()
	defer o.live.mu.Unlock()
	var out []domain.CodeApproval
	for _, a := range o.live.approvals {
		if a.ws != ws || !slices.Contains(a.owners, CodeOwner{ConversationID: conversationID, UserID: user}) {
			continue
		}
		x := a.a
		x.ConversationID, x.UserID = conversationID, user
		if x.Status == domain.ApprovalPending && now.After(x.ExpiresAt) {
			x.Status = domain.ApprovalExpired
		}
		out = append(out, x)
	}
	slices.SortFunc(out, func(a, b domain.CodeApproval) int { return b.ExpiresAt.Compare(a.ExpiresAt) })
	return out, nil
}

// DecideCodeApproval allows or denies a tool call the person was asked
// about. The first decision counts; a later one, or one after the time ran
// out, is domain.ErrConflict.
func (o *Orchestrator) DecideCodeApproval(ctx context.Context, id string, allow bool) (domain.CodeApproval, error) {
	ws, user, err := o.coder(ctx)
	if err != nil {
		return domain.CodeApproval{}, err
	}
	o.live.mu.Lock()
	a := o.live.approvals[id]
	if a == nil || a.ws != ws || !slices.ContainsFunc(a.owners, func(w CodeOwner) bool { return w.UserID == user }) {
		o.live.mu.Unlock()
		return domain.CodeApproval{}, domain.ErrNotFound
	}
	if a.a.Status != domain.ApprovalPending || time.Now().After(a.a.ExpiresAt) {
		o.live.mu.Unlock()
		return a.a, domain.ErrConflict
	}
	a.a.Status = domain.ApprovalDenied
	if allow {
		a.a.Status = domain.ApprovalAllowed
	}
	a.answer <- allow // buffered, and only the first decision gets here
	out := a.a
	o.live.mu.Unlock()
	o.publishApproval(a)
	o.event(ctx, domain.Event{TicketKey: out.TicketKey, Type: domain.EventGuard, Origin: domain.OriginAssistant,
		Message: map[bool]string{true: "allowed in the chat: ", false: "denied in the chat: "}[allow] + firstOf(out.Command, out.Path, out.Tool)})
	return out, nil
}

func firstOf(s ...string) string {
	for _, v := range s {
		if v != "" {
			return v
		}
	}
	return ""
}
