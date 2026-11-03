package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"agnts/internal/chat"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Chat is the team chat (chat.Service). Domain chat types carry the
// API's JSON names, so handlers write them as they are.
type Chat interface {
	Channels(ctx context.Context) ([]domain.ChatChannel, error)
	CreateChannel(ctx context.Context, name, topic string, agents bool) (domain.ChatChannel, error)
	UpdateChannel(ctx context.Context, id int64, topic *string, agents *bool, archive bool) (domain.ChatChannel, error)
	Messages(ctx context.Context, channel, before, after int64, limit int) ([]domain.ChatMessage, error)
	Message(ctx context.Context, id int64) (domain.ChatMessage, error)
	Send(ctx context.Context, in domain.ChatSend) (domain.ChatMessage, bool, error)
	MarkRead(ctx context.Context, channel, last int64) error
	Act(ctx context.Context, msg int64, in chat.ActInput) (domain.ChatMessage, error)
	RemoveRef(ctx context.Context, msg int64, typ, id string) (domain.ChatMessage, error)
	ToTicket(ctx context.Context, msg int64) error
	Stats(ctx context.Context) (postgres.ChatStats, error)
}

var _ Chat = (*chat.Service)(nil)

func (s *Server) chatReady(w http.ResponseWriter) bool {
	if s.opt.Chat == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "the team chat is not available")
		return false
	}
	return true
}

func (s *Server) writeChatError(w http.ResponseWriter, r *http.Request, err error) {
	msg := err.Error()
	for _, p := range []string{"invalid: ", "settled: ", "busy: ", "limit: "} {
		msg = strings.TrimPrefix(msg, p)
	}
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such channel or message")
	case errors.Is(err, postgres.ErrChatDuplicate):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	case errors.Is(err, chat.ErrSettled), errors.Is(err, chat.ErrBusy):
		writeError(w, http.StatusConflict, "conflict", msg)
	case errors.Is(err, chat.ErrLimit):
		writeError(w, http.StatusTooManyRequests, "limit", msg)
	case errors.Is(err, chat.ErrInvalid), errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", msg)
	default:
		s.writeUseCaseError(w, r, err)
	}
}

// ListChatChannels implements gen.ServerInterface.
func (s *Server) ListChatChannels(w http.ResponseWriter, r *http.Request) {
	if !s.chatReady(w) {
		return
	}
	cs, err := s.opt.Chat.Channels(r.Context())
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	if cs == nil {
		cs = []domain.ChatChannel{}
	}
	writeJSON(w, http.StatusOK, cs)
}

// CreateChatChannel implements gen.ServerInterface.
func (s *Server) CreateChatChannel(w http.ResponseWriter, r *http.Request) {
	if !s.chatReady(w) {
		return
	}
	var req gen.ChatChannelInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Chat.CreateChannel(r.Context(), req.Name, strOr(req.Topic), req.Agents != nil && *req.Agents)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, c)
}

// UpdateChatChannel implements gen.ServerInterface.
func (s *Server) UpdateChatChannel(w http.ResponseWriter, r *http.Request, id gen.ChatChannelID) {
	if !s.chatReady(w) {
		return
	}
	var req gen.ChatChannelUpdate
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Chat.UpdateChannel(r.Context(), id, req.Topic, req.Agents, req.Archive != nil && *req.Archive)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, c)
}

// ListChatMessages implements gen.ServerInterface.
func (s *Server) ListChatMessages(w http.ResponseWriter, r *http.Request, id gen.ChatChannelID, p gen.ListChatMessagesParams) {
	if !s.chatReady(w) {
		return
	}
	var before, after int64
	limit := 50
	if p.Before != nil {
		before = *p.Before
	}
	if p.After != nil {
		after = *p.After
	}
	if p.Limit != nil {
		limit = *p.Limit
	}
	ms, err := s.opt.Chat.Messages(r.Context(), id, before, after, limit)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, ms)
}

// SendChatMessage implements gen.ServerInterface.
func (s *Server) SendChatMessage(w http.ResponseWriter, r *http.Request, id gen.ChatChannelID) {
	if !s.chatReady(w) {
		return
	}
	var req gen.ChatSendRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	m, created, err := s.opt.Chat.Send(r.Context(), domain.ChatSend{ChannelID: id, ClientMsgID: req.ClientMsgId.String(), Body: req.Body, ReplyTo: req.ReplyTo})
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	status := http.StatusOK
	if created {
		status = http.StatusCreated
	}
	writeJSON(w, status, m)
}

// MarkChatRead implements gen.ServerInterface.
func (s *Server) MarkChatRead(w http.ResponseWriter, r *http.Request, id gen.ChatChannelID) {
	if !s.chatReady(w) {
		return
	}
	var req gen.MarkChatReadJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Chat.MarkRead(r.Context(), id, req.LastReadId); err != nil {
		s.writeChatError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ActOnChatCard implements gen.ServerInterface.
func (s *Server) ActOnChatCard(w http.ResponseWriter, r *http.Request, id gen.ChatMessageID) {
	if !s.chatReady(w) {
		return
	}
	var req gen.ChatActionRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := chat.ActInput{Action: string(req.Action), Feedback: strOr(req.Feedback)}
	if d := req.Draft; d != nil {
		in.Draft = &chat.DraftEdit{Title: strOr(d.Title), Description: strOr(d.Description)}
		if d.RepoId != nil {
			in.Draft.RepoID = *d.RepoId
		}
	}
	m, err := s.opt.Chat.Act(r.Context(), id, in)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, m)
}

// RemoveChatRef implements gen.ServerInterface.
func (s *Server) RemoveChatRef(w http.ResponseWriter, r *http.Request, id gen.ChatMessageID) {
	if !s.chatReady(w) {
		return
	}
	var req gen.RemoveChatRefJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	m, err := s.opt.Chat.RemoveRef(r.Context(), id, req.Type, req.Id)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, m)
}

// ChatMessageToTicket implements gen.ServerInterface.
func (s *Server) ChatMessageToTicket(w http.ResponseWriter, r *http.Request, id gen.ChatMessageID) {
	if !s.chatReady(w) {
		return
	}
	if err := s.opt.Chat.ToTicket(r.Context(), id); err != nil {
		s.writeChatError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusAccepted)
}

// GetChatStats implements gen.ServerInterface.
func (s *Server) GetChatStats(w http.ResponseWriter, r *http.Request) {
	if !s.chatReady(w) {
		return
	}
	st, err := s.opt.Chat.Stats(r.Context())
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.ChatStats{Links: st.Links, Answers: st.Answers, Drafts: st.Drafts, MedianMs: st.MedianMS})
}

// GetChatMessage implements gen.ServerInterface.
func (s *Server) GetChatMessage(w http.ResponseWriter, r *http.Request, id gen.ChatMessageID) {
	if !s.chatReady(w) {
		return
	}
	m, err := s.opt.Chat.Message(r.Context(), id)
	if err != nil {
		s.writeChatError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, m)
}
