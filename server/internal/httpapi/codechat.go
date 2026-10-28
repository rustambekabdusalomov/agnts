package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// CodeChat is the chat's Code mode: conversations that drive tickets.
// Every call acts for the person in ctx, who must be able to edit (the
// write operations are not open to viewers).
type CodeChat interface {
	CodeReady() bool
	StartCode(ctx context.Context, in orchestrator.CodeStart) (domain.AssistantConversation, error)
	SendCode(ctx context.Context, conversationID int64, in orchestrator.CodeSend) (domain.AssistantMessage, error)
	CodeTimeline(ctx context.Context, conversationID int64) (domain.AssistantConversation, []domain.TimelineItem, error)
	SetCodeRepos(ctx context.Context, conversationID int64, repos domain.RepoChoice) (domain.AssistantConversation, error)
	AttachCodeTicket(ctx context.Context, conversationID int64, key string) (domain.AssistantConversation, error)
	SendQueuedNow(ctx context.Context, conversationID int64) (domain.AssistantConversation, error)
	TicketConversation(ctx context.Context, key string) (int64, error)
	CodeApprovals(ctx context.Context, conversationID int64) ([]domain.CodeApproval, error)
	DecideCodeApproval(ctx context.Context, id string, allow bool) (domain.CodeApproval, error)
}

func (s *Server) codeReady(w http.ResponseWriter) bool {
	if s.opt.Code == nil || !s.opt.Code.CodeReady() {
		writeError(w, http.StatusNotImplemented, "not_implemented", "Code mode is not available")
		return false
	}
	return true
}

func (s *Server) writeCodeError(w http.ResponseWriter, r *http.Request, err error) {
	var te *domain.TransitionError
	switch {
	case errors.Is(err, domain.ErrForbidden):
		writeError(w, http.StatusForbidden, "forbidden", "viewers can see this workspace but not change it")
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such conversation")
	case errors.As(err, &te):
		writeError(w, http.StatusConflict, "conflict", te.Key+" is "+humanState(te.From)+" and cannot take this now")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func humanState(s domain.TicketState) string {
	b := []byte(s)
	for i, c := range b {
		if c == '_' {
			b[i] = ' '
		}
	}
	return string(b)
}

func repoChoice(c *gen.RepoChoice) domain.RepoChoice {
	var out domain.RepoChoice
	if c == nil {
		return out
	}
	if c.RepoId != nil {
		out.RepoID = *c.RepoId
	}
	if c.RepoIds != nil {
		out.RepoIDs = *c.RepoIds
	}
	if c.GroupId != nil {
		out.GroupID = *c.GroupId
	}
	return out
}

// orZero is *p, or T's zero value for nil.
func orZero[T any](p *T) T {
	var z T
	if p == nil {
		return z
	}
	return *p
}

// StartCodeConversation implements gen.ServerInterface.
func (s *Server) StartCodeConversation(w http.ResponseWriter, r *http.Request) {
	if !s.codeReady(w) {
		return
	}
	var req gen.CodeStart
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := orchestrator.CodeStart{Text: orZero(req.Text), Files: orZero(req.Attachments), Repos: repoChoice(req.Repos),
		Quick: orZero(req.Quick), TicketKey: orZero(req.TicketKey)}
	if req.Kind != nil {
		in.Kind = string(*req.Kind)
	}
	c, err := s.opt.Code.StartCode(r.Context(), in)
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toConversation(c))
}

// SendCodeMessage implements gen.ServerInterface.
func (s *Server) SendCodeMessage(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.codeReady(w) {
		return
	}
	var req gen.CodeSend
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := orchestrator.CodeSend{Text: orZero(req.Text), Files: orZero(req.Attachments)}
	for _, a := range orZero(req.Answers) {
		in.Answers = append(in.Answers, domain.Answer{QuestionID: a.QuestionId, Answer: a.Answer})
	}
	m, err := s.opt.Code.SendCode(r.Context(), id, in)
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toAssistantMessage(m))
}

// GetCodeTimeline implements gen.ServerInterface.
func (s *Server) GetCodeTimeline(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.codeReady(w) {
		return
	}
	c, items, err := s.opt.Code.CodeTimeline(r.Context(), id)
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	approvals, err := s.opt.Code.CodeApprovals(r.Context(), id)
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	out := gen.CodeTimeline{Conversation: toConversation(c), Items: make([]gen.TimelineItem, len(items)),
		Approvals: make([]gen.CodeApproval, len(approvals))}
	for i, it := range items {
		x := gen.TimelineItem{At: it.At}
		if it.Message != nil {
			m := toAssistantMessage(*it.Message)
			x.Message = &m
		}
		if it.Event != nil {
			e := toEvent(*it.Event)
			x.Event = &e
		}
		out.Items[i] = x
	}
	for i, a := range approvals {
		out.Approvals[i] = toCodeApproval(a)
	}
	writeJSON(w, http.StatusOK, out)
}

// SetCodeRepos implements gen.ServerInterface.
func (s *Server) SetCodeRepos(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.codeReady(w) {
		return
	}
	var req gen.RepoChoice
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.codeConversation(w, r, func(ctx context.Context) (domain.AssistantConversation, error) {
		return s.opt.Code.SetCodeRepos(ctx, id, repoChoice(&req))
	})
}

// AttachCodeTicket implements gen.ServerInterface.
func (s *Server) AttachCodeTicket(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.codeReady(w) {
		return
	}
	var req gen.AttachCodeTicketJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.codeConversation(w, r, func(ctx context.Context) (domain.AssistantConversation, error) {
		return s.opt.Code.AttachCodeTicket(ctx, id, req.Key)
	})
}

// SendCodeQueuedNow implements gen.ServerInterface.
func (s *Server) SendCodeQueuedNow(w http.ResponseWriter, r *http.Request, id gen.ConversationID) {
	if !s.codeReady(w) {
		return
	}
	s.codeConversation(w, r, func(ctx context.Context) (domain.AssistantConversation, error) {
		return s.opt.Code.SendQueuedNow(ctx, id)
	})
}

func (s *Server) codeConversation(w http.ResponseWriter, r *http.Request, f func(context.Context) (domain.AssistantConversation, error)) {
	c, err := f(r.Context())
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toConversation(c))
}

// GetTicketChat implements gen.ServerInterface.
func (s *Server) GetTicketChat(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if s.opt.Code == nil {
		writeError(w, http.StatusNotFound, "not_found", "no conversation works on this ticket")
		return
	}
	id, err := s.opt.Code.TicketConversation(r.Context(), key)
	if errors.Is(err, domain.ErrNotFound) {
		writeError(w, http.StatusNotFound, "not_found", "no conversation of yours works on this ticket")
		return
	}
	if err != nil {
		s.writeCodeError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]int64{"conversationId": id})
}

// DecideCodeApproval implements gen.ServerInterface.
func (s *Server) DecideCodeApproval(w http.ResponseWriter, r *http.Request, id string) {
	if !s.codeReady(w) {
		return
	}
	var req gen.DecideCodeApprovalJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	a, err := s.opt.Code.DecideCodeApproval(r.Context(), id, req.Allow)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such question; the run may have ended")
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", "this was already decided, or its time ran out")
	case err != nil:
		s.writeCodeError(w, r, err)
	default:
		writeJSON(w, http.StatusOK, toCodeApproval(a))
	}
}

func toCodeApproval(a domain.CodeApproval) gen.CodeApproval {
	out := gen.CodeApproval{Id: a.ID, ConversationId: a.ConversationID, TicketKey: a.TicketKey, Tool: a.Tool, Reason: a.Reason,
		Status: gen.CodeApprovalStatus(a.Status), ExpiresAt: a.ExpiresAt}
	if a.Command != "" {
		c := a.Command
		out.Command = &c
	}
	if a.Path != "" {
		p := a.Path
		out.Path = &p
	}
	return out
}

func toCodeTickets(ts []domain.CodeTicket) []gen.CodeTicket {
	out := make([]gen.CodeTicket, len(ts))
	for i, t := range ts {
		repos := t.Repos
		if repos == nil {
			repos = []string{}
		}
		out[i] = gen.CodeTicket{Key: t.Key, Title: t.Title, State: gen.TicketState(t.State), Kind: gen.TicketKind(t.Kind), Repos: repos,
			Current: t.Current, Moved: t.Moved, AttachedAt: t.AttachedAt}
	}
	return out
}

func toRepoChoice(c domain.RepoChoice) *gen.RepoChoice {
	if c.Empty() {
		return nil
	}
	var out gen.RepoChoice
	if c.RepoID != 0 {
		id := c.RepoID
		out.RepoId = &id
	}
	if len(c.RepoIDs) > 0 {
		ids := c.RepoIDs
		out.RepoIds = &ids
	}
	if c.GroupID != 0 {
		g := c.GroupID
		out.GroupId = &g
	}
	return &out
}
