package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// ReviewDrafts is what the draft comments of pull request reviews need:
// asking for a review from the pull request page, and deciding on and
// publishing its comments.
type ReviewDrafts interface {
	ReviewPull(ctx context.Context, repoID int64, number int, opt orchestrator.ReviewPullOptions, origin domain.Origin) (domain.Ticket, error)
	TicketDrafts(ctx context.Context, key string) ([]domain.ReviewDraft, error)
	AddDraftComment(ctx context.Context, key string, c domain.NewPRComment) (domain.ReviewDraft, error)
	UpdateDraft(ctx context.Context, key string, id int64, ch orchestrator.DraftChange, origin domain.Origin) (domain.ReviewDraft, error)
	DeleteDraft(ctx context.Context, key string, id int64) error
	AcceptAllDrafts(ctx context.Context, key, minSeverity string) ([]domain.ReviewDraft, error)
	PublishDrafts(ctx context.Context, key string, opt orchestrator.PublishOptions, origin domain.Origin) (domain.Ticket, orchestrator.PostedReview, error)
}

func (s *Server) draftsReady(w http.ResponseWriter) bool {
	if s.opt.Drafts == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

func (s *Server) draftsError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, orchestrator.ErrHost):
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "not found")
	default:
		s.writeUseCaseError(w, r, err)
	}
}

func toReviewDraft(d domain.ReviewDraft) gen.ReviewDraft {
	out := gen.ReviewDraft{Id: d.ID, Kind: gen.ReviewDraftKind(d.Kind), Key: d.Key, Severity: optStr(d.Severity), Category: optStr(d.Category),
		Title: optStr(d.Title), Pass: optStr(d.Pass), Path: optStr(d.Path), Line: optInt(d.Line), HeadSha: d.HeadSHA, Body: d.Body,
		Edited: d.Edited, State: gen.ReviewDraftState(d.State), DismissReason: optStr(d.DismissReason), Error: optStr(d.Error),
		Author: optStr(d.Author), DecidedBy: optStr(d.Decider), DecidedAt: d.DecidedAt, CreatedAt: d.CreatedAt, UpdatedAt: d.UpdatedAt}
	if d.Confidence > 0 {
		c := float32(d.Confidence)
		out.Confidence = &c
	}
	return out
}

func toReviewDrafts(ds []domain.ReviewDraft) []gen.ReviewDraft {
	out := make([]gen.ReviewDraft, len(ds))
	for i, d := range ds {
		out[i] = toReviewDraft(d)
	}
	return out
}

// ReviewRepoPull implements gen.ServerInterface.
func (s *Server) ReviewRepoPull(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.draftsReady(w) {
		return
	}
	var req gen.ReviewRepoPullJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var opt orchestrator.ReviewPullOptions
	if req.Focus != nil {
		opt.Focus = *req.Focus
	}
	if req.Deep != nil {
		opt.Deep = string(*req.Deep)
	}
	t, err := s.opt.Drafts.ReviewPull(r.Context(), id, number, opt, origin(r))
	var exists *orchestrator.ReviewExistsError
	if errors.As(err, &exists) {
		writeJSON(w, http.StatusConflict, map[string]string{"code": "review_exists", "message": err.Error(), "ticketKey": exists.Key})
		return
	}
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// ListReviewDrafts implements gen.ServerInterface.
func (s *Server) ListReviewDrafts(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.draftsReady(w) {
		return
	}
	ds, err := s.opt.Drafts.TicketDrafts(r.Context(), key)
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toReviewDrafts(ds))
}

// AddReviewDraft implements gen.ServerInterface.
func (s *Server) AddReviewDraft(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.draftsReady(w) {
		return
	}
	var req gen.AddReviewDraftJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c := domain.NewPRComment{Body: req.Body}
	if req.Path != nil {
		c.Path = *req.Path
	}
	if req.Line != nil {
		c.Line = *req.Line
	}
	if req.HeadSha != nil {
		c.HeadSHA = *req.HeadSha
	}
	d, err := s.opt.Drafts.AddDraftComment(r.Context(), key, c)
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toReviewDraft(d))
}

// UpdateReviewDraft implements gen.ServerInterface.
func (s *Server) UpdateReviewDraft(w http.ResponseWriter, r *http.Request, key gen.TicketKey, draftID gen.DraftID) {
	if !s.draftsReady(w) {
		return
	}
	var req gen.UpdateReviewDraftJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	ch := orchestrator.DraftChange{Body: req.Body, Reason: req.DismissReason}
	if req.State != nil {
		st := string(*req.State)
		ch.State = &st
	}
	d, err := s.opt.Drafts.UpdateDraft(r.Context(), key, draftID, ch, origin(r))
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toReviewDraft(d))
}

// DeleteReviewDraft implements gen.ServerInterface.
func (s *Server) DeleteReviewDraft(w http.ResponseWriter, r *http.Request, key gen.TicketKey, draftID gen.DraftID) {
	if !s.draftsReady(w) {
		return
	}
	if err := s.opt.Drafts.DeleteDraft(r.Context(), key, draftID); err != nil {
		s.draftsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AcceptAllReviewDrafts implements gen.ServerInterface.
func (s *Server) AcceptAllReviewDrafts(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.draftsReady(w) {
		return
	}
	var req gen.AcceptAllReviewDraftsJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	min := ""
	if req.MinSeverity != nil {
		min = string(*req.MinSeverity)
	}
	ds, err := s.opt.Drafts.AcceptAllDrafts(r.Context(), key, min)
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toReviewDrafts(ds))
}

// PublishReviewDrafts implements gen.ServerInterface.
func (s *Server) PublishReviewDrafts(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.draftsReady(w) {
		return
	}
	var req gen.PublishReviewDraftsJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	opt := orchestrator.PublishOptions{RequestChanges: req.RequestChanges != nil && *req.RequestChanges}
	t, did, err := s.opt.Drafts.PublishDrafts(r.Context(), key, opt, origin(r))
	if err != nil {
		s.draftsError(w, r, err)
		return
	}
	out := gen.PublishedReview{Summary: gen.PublishedReviewSummary(did.Summary), Inline: did.Inline, Still: did.Still, Resolved: did.Resolved,
		Ticket: toTicket(t)}
	if rows, err := s.opt.Tickets.Rows(r.Context(), []domain.Ticket{t}); err == nil && len(rows) > 0 {
		out.Ticket = toTicketRow(rows[0])
	}
	writeJSON(w, http.StatusOK, out)
}
