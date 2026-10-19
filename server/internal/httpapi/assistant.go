package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strconv"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Assistant answers a person's questions about their workspace. Every call
// acts for the person in ctx: conversations are theirs alone.
type Assistant interface {
	AssistantReady() bool
	Ask(ctx context.Context, conversationID int64, question, lang string) (domain.AssistantConversation, error)
	AssistantConversations(ctx context.Context) ([]domain.AssistantConversation, error)
	AssistantConversation(ctx context.Context, id int64) (domain.AssistantConversation, error)
	DeleteAssistantConversation(ctx context.Context, id int64) error
	RateAnswer(ctx context.Context, messageID int64, rating int, comment string, share bool) (domain.AssistantMessage, error)
	AssistantStats(ctx context.Context, days int) (domain.AssistantStats, error)
	AssistantRated(ctx context.Context, rating int) ([]domain.AssistantRated, error)
	ConfirmAssistantAction(ctx context.Context, id string) (domain.AssistantAction, error)
	CancelAssistantAction(ctx context.Context, id string) (domain.AssistantAction, error)
}

func (s *Server) assistantReady(w http.ResponseWriter) bool {
	if s.opt.Assistant == nil || !s.opt.Assistant.AssistantReady() {
		writeError(w, http.StatusNotImplemented, "not_implemented", "the assistant is not available")
		return false
	}
	return true
}

func (s *Server) writeAssistantError(w http.ResponseWriter, r *http.Request, err error) {
	var rl *orchestrator.RateLimitedError
	switch {
	case errors.As(err, &rl):
		w.Header().Set("Retry-After", strconv.Itoa(int(rl.RetryAfter.Seconds())+1))
		writeError(w, http.StatusTooManyRequests, "rate_limited", rl.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such conversation")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func askLang(l *gen.AssistantLanguage) string {
	if l == nil {
		return ""
	}
	return string(*l)
}

// ListAssistantConversations implements gen.ServerInterface.
func (s *Server) ListAssistantConversations(w http.ResponseWriter, r *http.Request) {
	if !s.assistantReady(w) {
		return
	}
	cs, err := s.opt.Assistant.AssistantConversations(r.Context())
	if err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	out := make([]gen.AssistantConversation, len(cs))
	for i, c := range cs {
		out[i] = toConversation(c)
	}
	writeJSON(w, http.StatusOK, out)
}

// StartAssistantConversation implements gen.ServerInterface.
func (s *Server) StartAssistantConversation(w http.ResponseWriter, r *http.Request) {
	s.ask(w, r, 0)
}

// AskAssistant implements gen.ServerInterface.
func (s *Server) AskAssistant(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	s.ask(w, r, id)
}

func (s *Server) ask(w http.ResponseWriter, r *http.Request, conversation int64) {
	if !s.assistantReady(w) {
		return
	}
	var req gen.AssistantAsk
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if req.Lang != nil && !req.Lang.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "lang is en, ru or uz")
		return
	}
	c, err := s.opt.Assistant.Ask(r.Context(), conversation, req.Question, askLang(req.Lang))
	if err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	writeJSON(w, http.StatusAccepted, toConversation(c))
}

// GetAssistantConversation implements gen.ServerInterface.
func (s *Server) GetAssistantConversation(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.assistantReady(w) {
		return
	}
	c, err := s.opt.Assistant.AssistantConversation(r.Context(), id)
	if err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toConversation(c))
}

// DeleteAssistantConversation implements gen.ServerInterface.
func (s *Server) DeleteAssistantConversation(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.assistantReady(w) {
		return
	}
	if err := s.opt.Assistant.DeleteAssistantConversation(r.Context(), id); err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// RateAssistantAnswer implements gen.ServerInterface.
func (s *Server) RateAssistantAnswer(w http.ResponseWriter, r *http.Request, id gen.MessageID) {
	if !s.assistantReady(w) {
		return
	}
	var req gen.AssistantRating
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Rating.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "rating is 1, -1 or 0")
		return
	}
	comment, share := "", false
	if req.Comment != nil {
		comment = *req.Comment
	}
	if req.Share != nil {
		share = *req.Share
	}
	m, err := s.opt.Assistant.RateAnswer(r.Context(), id, int(req.Rating), comment, share)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no such answer")
			return
		}
		s.writeAssistantError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toAssistantMessage(m))
}

// ConfirmAssistantAction implements gen.ServerInterface.
func (s *Server) ConfirmAssistantAction(w http.ResponseWriter, r *http.Request, id gen.ActionID) {
	s.assistantAction(w, r, id, s.opt.Assistant.ConfirmAssistantAction)
}

// CancelAssistantAction implements gen.ServerInterface.
func (s *Server) CancelAssistantAction(w http.ResponseWriter, r *http.Request, id gen.ActionID) {
	s.assistantAction(w, r, id, s.opt.Assistant.CancelAssistantAction)
}

func (s *Server) assistantAction(w http.ResponseWriter, r *http.Request, id string, do func(context.Context, string) (domain.AssistantAction, error)) {
	if !s.assistantReady(w) {
		return
	}
	a, err := do(r.Context(), id)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such action")
	case errors.Is(err, postgres.ErrExpired):
		writeError(w, http.StatusConflict, "conflict", "this action expired, or was already confirmed or declined; ask again")
	case errors.Is(err, domain.ErrForbidden):
		writeError(w, http.StatusForbidden, "forbidden", "viewers can see this workspace but not change it")
	case err != nil:
		s.writeAssistantError(w, r, err)
	default:
		writeJSON(w, http.StatusOK, toAssistantAction(a))
	}
}

func toAssistantAction(a domain.AssistantAction) gen.AssistantAction {
	out := gen.AssistantAction{Id: a.ID, MessageId: a.MessageID, ConversationId: a.ConversationID, Tool: gen.AssistantActionTool(a.Tool),
		Summary: a.Summary, Destructive: a.Destructive, Status: gen.AssistantActionStatus(a.Status), ExpiresAt: a.ExpiresAt}
	if a.TicketKey != "" {
		k := a.TicketKey
		out.TicketKey = &k
	}
	if a.Result != "" {
		r := a.Result
		out.Result = &r
	}
	return out
}

// GetAssistantStats implements gen.ServerInterface.
func (s *Server) GetAssistantStats(w http.ResponseWriter, r *http.Request, p gen.GetAssistantStatsParams) {
	if !s.assistantReady(w) {
		return
	}
	days := 7
	if p.Days != nil {
		days = int(*p.Days)
	}
	st, err := s.opt.Assistant.AssistantStats(r.Context(), days)
	if err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	out := gen.AssistantStats{Days: st.Days, Questions: st.Questions, Answered: st.Answered, Failed: st.Failed, People: st.People,
		MedianMs: st.MedianMS, P90Ms: st.P90MS, MedianStartMs: st.StartMS, MedianSnapshotMs: st.SnapshotMS, MedianClaudeMs: st.ClaudeMS, Warm: st.Warm, Up: st.Up, Down: st.Down, Tokens: st.Tokens, CostUsd: st.CostUSD}
	a := &out.Actions
	a.Proposed, a.Done, a.Failed, a.Cancelled, a.Expired, a.NotOffered = st.Actions.Proposed, st.Actions.Done, st.Actions.Failed,
		st.Actions.Cancelled, st.Actions.Expired, st.Actions.NotOffered
	out.Versions = makeLike(out.Versions, len(st.Versions))
	for i, v := range st.Versions {
		x := &out.Versions[i]
		x.Answered, x.Down, x.Failed, x.MedianMs, x.PromptVersion, x.Tokens, x.Up = v.Answered, v.Down, v.Failed, v.MedianMS, v.PromptVersion, v.Tokens, v.Up
		x.Proposed, x.Done = v.Proposed, v.Done
	}
	writeJSON(w, http.StatusOK, out)
}

// ListAssistantRated implements gen.ServerInterface.
func (s *Server) ListAssistantRated(w http.ResponseWriter, r *http.Request, p gen.ListAssistantRatedParams) {
	if !s.assistantReady(w) {
		return
	}
	rating := 0
	if p.Rating != nil {
		rating = map[gen.ListAssistantRatedParamsRating]int{"up": 1, "down": -1}[*p.Rating]
	}
	list, err := s.opt.Assistant.AssistantRated(r.Context(), rating)
	if err != nil {
		s.writeAssistantError(w, r, err)
		return
	}
	out := make([]gen.AssistantRated, len(list))
	for i, x := range list {
		out[i] = gen.AssistantRated{MessageId: x.MessageID, User: x.Username, Question: x.Question, Answer: x.Answer,
			Rating: gen.AssistantRatedRating(x.Rating), Comment: x.Comment, PromptVersion: x.PromptVersion, Shared: x.Shared, RatedAt: x.RatedAt}
		if len(x.Actions) > 0 {
			acts := make([]gen.AssistantAction, len(x.Actions))
			for j, a := range x.Actions {
				acts[j] = toAssistantAction(a)
			}
			out[i].Actions = &acts
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// makeLike makes a slice of n elements of s's type: the generated
// anonymous element types need no spelling out.
func makeLike[S ~[]E, E any](_ S, n int) S { return make(S, n) }

func toConversation(c domain.AssistantConversation) gen.AssistantConversation {
	out := gen.AssistantConversation{Id: c.ID, Title: c.Title, CreatedAt: c.CreatedAt, UpdatedAt: c.UpdatedAt,
		Messages: make([]gen.AssistantMessage, len(c.Messages))}
	for i, m := range c.Messages {
		out.Messages[i] = toAssistantMessage(m)
	}
	return out
}

func toAssistantMessage(m domain.AssistantMessage) gen.AssistantMessage {
	out := gen.AssistantMessage{Id: m.ID, Role: gen.AssistantMessageRole(m.Role), Text: m.Text, Speech: m.Speech,
		Status: gen.AssistantMessageStatus(m.Status), Lang: gen.AssistantLanguage(m.Lang), Rating: gen.AssistantMessageRating(m.Rating),
		Shared: m.Shared, CreatedAt: m.CreatedAt, Links: make([]gen.AssistantLink, 0, len(m.Links))}
	for _, l := range m.Links {
		gl := gen.AssistantLink{Kind: gen.AssistantLinkKind(l.Kind)}
		if l.Key != "" {
			key := l.Key
			gl.Key = &key
		}
		if l.ID > 0 {
			id := l.ID
			gl.Id = &id
		}
		out.Links = append(out.Links, gl)
	}
	if m.Error != "" {
		e := m.Error
		out.Error = &e
	}
	if m.RatingComment != "" {
		c := m.RatingComment
		out.RatingComment = &c
	}
	if len(m.Actions) > 0 {
		acts := make([]gen.AssistantAction, len(m.Actions))
		for i, a := range m.Actions {
			acts[i] = toAssistantAction(a)
		}
		out.Actions = &acts
	}
	if len(m.ActionErrors) > 0 {
		errs := m.ActionErrors
		out.ActionErrors = &errs
	}
	if m.Role == domain.AssistantReply && m.Status == domain.AssistantDone {
		d := m.DurationMS
		out.DurationMs = &d
		if len(m.Files) > 0 {
			f := m.Files
			out.Files = &f
		}
	}
	return out
}
