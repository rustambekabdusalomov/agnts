package httpapi

import (
	"context"
	"net/http"
	"strings"
	"unicode/utf8"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// FeedbackStore keeps the feedback people send.
type FeedbackStore interface {
	Create(ctx context.Context, f postgres.Feedback) (postgres.Feedback, error)
	List(ctx context.Context) ([]postgres.Feedback, error)
	SetStatus(ctx context.Context, id int64, status string) (postgres.Feedback, error)
}

func toFeedback(f postgres.Feedback) gen.Feedback {
	out := gen.Feedback{Id: f.ID, Title: f.Title, Description: f.Description, Status: gen.FeedbackStatus(f.Status),
		Sender: f.Sender, CreatedAt: f.CreatedAt, UserId: f.UserID}
	if f.Email != "" {
		e := f.Email
		out.Email = &e
	}
	if f.Workspace != "" {
		w := f.Workspace
		out.Workspace = &w
	}
	return out
}

func (s *Server) feedbackOff(w http.ResponseWriter) bool {
	if s.opt.Feedback == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return true
	}
	return false
}

// SendFeedback implements gen.ServerInterface.
func (s *Server) SendFeedback(w http.ResponseWriter, r *http.Request) {
	if s.feedbackOff(w) || !s.limit(w, r, s.feedbackLimiter, "you sent a lot of feedback just now; try again in a few minutes") {
		return
	}
	u, _ := userFrom(r.Context())
	var req gen.SendFeedbackJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	title, desc := strings.TrimSpace(req.Title), strings.TrimSpace(req.Description)
	if title == "" || desc == "" || utf8.RuneCountInString(title) > 120 || utf8.RuneCountInString(desc) > 5000 {
		writeError(w, http.StatusBadRequest, "bad_request", "a feedback needs a title (up to 120 characters) and a description (up to 5000)")
		return
	}
	f := postgres.Feedback{UserID: &u.ID, Sender: u.DisplayName, Email: u.Email, Title: title, Description: desc}
	if f.Sender == "" {
		f.Sender = u.Username
	}
	// The workspace is context only, and only one the sender is in.
	if slug := deref(req.Workspace); slug != "" && s.opt.Workspaces != nil {
		if ws, err := s.opt.Workspaces.BySlug(r.Context(), slug); err == nil {
			if _, err := s.opt.Workspaces.Role(r.Context(), ws.ID, u.ID); err == nil {
				f.WorkspaceID = &ws.ID
			}
		}
	}
	out, err := s.opt.Feedback.Create(domain.System(r.Context()), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.opt.Log.Info("feedback sent", "feedback", out.ID, "user_id", u.ID)
	writeJSON(w, http.StatusCreated, toFeedback(out))
}

// ListPlatformFeedback implements gen.ServerInterface.
func (s *Server) ListPlatformFeedback(w http.ResponseWriter, r *http.Request) {
	if s.feedbackOff(w) {
		return
	}
	list, err := s.opt.Feedback.List(domain.System(r.Context()))
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.Feedback, 0, len(list))
	for _, f := range list {
		out = append(out, toFeedback(f))
	}
	writeJSON(w, http.StatusOK, out)
}

// UpdatePlatformFeedback implements gen.ServerInterface.
func (s *Server) UpdatePlatformFeedback(w http.ResponseWriter, r *http.Request, id int64) {
	if s.feedbackOff(w) {
		return
	}
	var req gen.UpdatePlatformFeedbackJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Status.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "status is new or done")
		return
	}
	f, err := s.opt.Feedback.SetStatus(domain.System(r.Context()), id, string(req.Status))
	if err != nil {
		s.authError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toFeedback(f))
}
