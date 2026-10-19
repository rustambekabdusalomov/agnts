package actions

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Assistant holds the writes the assistant proposes on its answers. A
// proposal is checked like an MCP write and stored for the person who
// asked; only their confirm does it.
type Assistant struct {
	Deps
	// Role returns a person's role in a workspace: viewers get no
	// actions. Nil lets everyone act.
	Role func(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
}

var _ orchestrator.AssistantActions = (*Assistant)(nil)

// viewerNote is what a viewer reads instead of an action.
const viewerNote = "Viewers can see this workspace but not change it, so the assistant cannot offer actions to you."

func (a *Assistant) canEdit(ctx context.Context, user int64) (bool, error) {
	if a.Role == nil {
		return true, nil
	}
	r, err := a.Role(ctx, domain.WorkspaceOf(ctx), user)
	if err != nil {
		return false, err
	}
	return r.CanEdit(), nil
}

// Propose checks the run's proposals for answer messageID and stores the
// ones that pass for user to confirm. It returns them, and why the others
// did not pass, in the person's words.
func (a *Assistant) Propose(ctx context.Context, user, messageID int64, ps []domain.AssistantProposal) ([]domain.AssistantAction, []string) {
	if len(ps) == 0 {
		return nil, nil
	}
	if ok, err := a.canEdit(ctx, user); err != nil || !ok {
		return nil, []string{viewerNote}
	}
	var out []domain.AssistantAction
	var errs []string
	seen := map[string]bool{}
	for _, p := range ps {
		prep, err := a.Prepare(ctx, p.Tool, p.Args)
		if err != nil {
			errs = append(errs, fmt.Sprintf("%s: %v", p.Tool, err))
			continue
		}
		if seen[prep.Tool+"\n"+prep.Summary] {
			continue
		}
		seen[prep.Tool+"\n"+prep.Summary] = true
		b := make([]byte, 8)
		_, _ = rand.Read(b)
		act := domain.AssistantAction{ID: hex.EncodeToString(b), MessageID: messageID, Tool: prep.Tool, TicketKey: prep.TicketKey,
			Summary: prep.Summary, Destructive: Destructive(prep.Tool), Status: domain.ActionProposed,
			ExpiresAt: time.Now().Add(domain.AssistantActionTTL)}
		if err := a.Store.CreatePending(ctx, postgres.PendingAction{ID: act.ID, Origin: domain.OriginAssistant, Tool: prep.Tool,
			TicketKey: prep.TicketKey, Args: prep.Args, Summary: prep.Summary, ExpiresAt: act.ExpiresAt, UserID: user, MessageID: messageID}); err != nil {
			errs = append(errs, fmt.Sprintf("%s: could not be stored", p.Tool))
			continue
		}
		out = append(out, act)
	}
	return out, errs
}

// Confirm does one of user's proposed actions, once, as them, and stores
// what happened. An action agnts cannot do now comes back failed with the
// reason; one that is not theirs is domain.ErrNotFound, and an expired or
// used one postgres.ErrExpired.
func (a *Assistant) Confirm(ctx context.Context, user int64, id string) (domain.AssistantAction, error) {
	if ok, err := a.canEdit(ctx, user); err != nil {
		return domain.AssistantAction{}, err
	} else if !ok {
		return domain.AssistantAction{}, domain.ErrForbidden
	}
	pa, err := a.Store.ConfirmAssistantAction(ctx, user, id)
	if err != nil {
		return domain.AssistantAction{}, err
	}
	res, err := a.Execute(ctx, pa, domain.OriginAssistant)
	outcome, result, key := domain.ActionDone, "", ""
	if err != nil {
		outcome, result = domain.ActionFailed, err.Error()
	} else {
		result, key = resultText(pa.Tool, res)
	}
	// The outcome is stored even when the person left while it ran.
	if err := a.Store.FinishAssistantAction(context.WithoutCancel(ctx), id, outcome, result, key); err != nil {
		return domain.AssistantAction{}, err
	}
	return a.Store.AssistantAction(ctx, user, id)
}

// Cancel declines one of user's proposed actions.
func (a *Assistant) Cancel(ctx context.Context, user int64, id string) (domain.AssistantAction, error) {
	if err := a.Store.CancelAssistantAction(ctx, user, id); err != nil {
		return domain.AssistantAction{}, err
	}
	return a.Store.AssistantAction(ctx, user, id)
}

// resultText says what a done action did, and the ticket it made, if any.
func resultText(tool string, res Result) (string, string) {
	switch {
	case tool == AcceptFollowUps:
		var keys []string
		for _, t := range res.Created {
			keys = append(keys, t.Key)
		}
		var parts []string
		if len(keys) > 0 {
			parts = append(parts, "Created "+strings.Join(keys, ", ")+".")
		}
		if len(res.Errors) > 0 {
			parts = append(parts, "Not created: "+strings.Join(res.Errors, "; ")+".")
		}
		return strings.Join(parts, " "), ""
	case res.Ticket == nil:
		return "Done.", ""
	case tool == CreateTask || tool == ImplementTicket:
		return fmt.Sprintf("Created %s (%s).", res.Ticket.Key, stateWords(res.Ticket.State)), res.Ticket.Key
	}
	return fmt.Sprintf("%s is now %s.", res.Ticket.Key, stateWords(res.Ticket.State)), ""
}

func stateWords(s domain.TicketState) string { return strings.ReplaceAll(string(s), "_", " ") }
