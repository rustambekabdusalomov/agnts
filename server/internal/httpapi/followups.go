package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// FollowUpTickets is the follow-up part of the ticket use cases.
type FollowUpTickets interface {
	ListFollowUps(ctx context.Context, key string) (orchestrator.FollowUps, error)
	SetFollowUps(ctx context.Context, key string, on *bool, origin domain.Origin) (domain.Ticket, error)
	AcceptSuggestions(ctx context.Context, key string, in []orchestrator.AcceptInput, origin domain.Origin) ([]orchestrator.AcceptResult, error)
	DismissSuggestion(ctx context.Context, key string, id int64, origin domain.Origin) (domain.Suggestion, error)
	SuggestFromFinding(ctx context.Context, key string, index int, origin domain.Origin) (domain.Suggestion, error)
}

// followUpsMode reads a per-ticket mode: nil follows the settings.
func followUpsMode(m gen.FollowUpsMode) (*bool, bool) {
	on, off := true, false
	switch m {
	case gen.FollowUpsModeInherit:
		return nil, true
	case gen.FollowUpsModeOn:
		return &on, true
	case gen.FollowUpsModeOff:
		return &off, true
	}
	return nil, false
}

func toFollowUpsMode(on *bool) gen.FollowUpsMode {
	switch {
	case on == nil:
		return gen.FollowUpsModeInherit
	case *on:
		return gen.FollowUpsModeOn
	}
	return gen.FollowUpsModeOff
}

func toSuggestion(x domain.Suggestion, parent domain.TicketState) gen.FollowUpSuggestion {
	out := gen.FollowUpSuggestion{
		Id: x.ID, Source: gen.FollowUpSuggestionSource(x.Source), Type: gen.FollowUpSuggestionType(x.Type), Revision: x.Revision,
		Title: x.Title, Description: x.Description, Serves: x.Serves, Kind: gen.TicketKind(x.Kind),
		Priority: gen.FollowUpSuggestionPriority(x.Priority), Status: gen.FollowUpSuggestionStatus(x.Status),
		Ready: x.Ready(parent), DecidedAt: x.DecidedAt, CreatedAt: x.CreatedAt,
	}
	if x.ChildKey != "" {
		c := x.ChildKey
		out.ChildKey = &c
	}
	if len(x.After) > 0 {
		after := x.After
		out.After = &after
	}
	if len(x.RepoIDs) > 0 {
		out.RepoIds = ptr(x.RepoIDs)
	}
	return out
}

func toFollowUps(f orchestrator.FollowUps, enabled bool, parent domain.TicketState) gen.FollowUps {
	out := gen.FollowUps{Enabled: enabled, Suggestions: make([]gen.FollowUpSuggestion, len(f.Suggestions)),
		Children: make([]gen.FollowUpTicket, len(f.Children))}
	for i, x := range f.Suggestions {
		out.Suggestions[i] = toSuggestion(x, parent)
	}
	for i, c := range f.Children {
		held := c.Held
		out.Children[i] = gen.FollowUpTicket{Key: c.Key, Title: c.Title, State: gen.TicketState(c.State), Kind: gen.TicketKind(kindOrCode(c.Kind)),
			Source: gen.FollowUpTicketSource(c.Source), Held: &held}
	}
	return out
}

// userError reports whether err is the caller's doing, not the server's.
func userError(err error) bool {
	return errors.Is(err, orchestrator.ErrInvalid) || errors.Is(err, domain.ErrConflict) || errors.Is(err, domain.ErrNotFound)
}

func kindOrCode(k domain.TicketKind) domain.TicketKind {
	if k == "" {
		return domain.KindCode
	}
	return k
}

// ListFollowUps implements gen.ServerInterface.
func (s *Server) ListFollowUps(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	v, err := s.opt.Tickets.View(r.Context(), key)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toFollowUps(v.FollowUps, v.FollowUpsOn, v.Ticket.State))
}

// SetFollowUps implements gen.ServerInterface.
func (s *Server) SetFollowUps(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.FollowUpsSetting
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	on, ok := followUpsMode(req.Mode)
	if !ok {
		writeError(w, http.StatusBadRequest, "bad_request", "mode must be inherit, on or off")
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetFollowUps(ctx, key, on, origin(r))
	})
}

// AcceptFollowUps implements gen.ServerInterface.
func (s *Server) AcceptFollowUps(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.AcceptFollowUps
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if len(req.Items) == 0 || len(req.Items) > 20 {
		writeError(w, http.StatusBadRequest, "bad_request", "pick between 1 and 20 suggestions")
		return
	}
	start := req.Start != nil && *req.Start
	in := make([]orchestrator.AcceptInput, len(req.Items))
	for i, it := range req.Items {
		a := orchestrator.AcceptInput{ID: it.Id, Start: start}
		if it.Target != nil {
			a.Target = string(*it.Target)
		}
		if it.Title != nil {
			a.Title = *it.Title
		}
		if it.Description != nil {
			a.Description = *it.Description
		}
		if it.Kind != nil {
			a.Kind = string(*it.Kind)
		}
		if it.Priority != nil {
			a.Priority = string(*it.Priority)
		}
		if it.RepoId != nil {
			a.RepoID = *it.RepoId
		}
		if it.RepoIds != nil {
			a.RepoIDs = *it.RepoIds
		}
		if it.GroupId != nil {
			a.GroupID = *it.GroupId
		}
		in[i] = a
	}
	res, err := s.opt.Tickets.AcceptSuggestions(r.Context(), key, in, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := gen.AcceptFollowUpsResult{Results: make([]gen.AcceptFollowUpResult, len(res))}
	for i, x := range res {
		out.Results[i] = gen.AcceptFollowUpResult{Id: x.ID}
		if x.Err != nil {
			msg := x.Err.Error()
			if !userError(x.Err) {
				s.opt.Log.Error("accept follow-up", "ticket", key, "suggestion", x.ID, "err", x.Err)
			}
			out.Results[i].Error = &msg
			continue
		}
		t := toTicket(*x.Ticket)
		out.Results[i].Ticket = &t
	}
	writeJSON(w, http.StatusOK, out)
}

// DismissFollowUp implements gen.ServerInterface.
func (s *Server) DismissFollowUp(w http.ResponseWriter, r *http.Request, key gen.TicketKey, id int64) {
	x, err := s.opt.Tickets.DismissSuggestion(r.Context(), key, id, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSuggestion(x, domain.StateDone))
}

// FollowUpFromFinding implements gen.ServerInterface.
func (s *Server) FollowUpFromFinding(w http.ResponseWriter, r *http.Request, key gen.TicketKey, index int) {
	x, err := s.opt.Tickets.SuggestFromFinding(r.Context(), key, index, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	t, err := s.opt.Tickets.View(r.Context(), key)
	state := domain.StateDone
	if err == nil {
		state = t.Ticket.State
	}
	writeJSON(w, http.StatusCreated, toSuggestion(x, state))
}
