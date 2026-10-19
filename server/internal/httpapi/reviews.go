package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Reviews is what the Reviews page reads and changes: the sync of the
// pull requests waiting for you, and what agnts learned from your notes.
type Reviews interface {
	SyncReviews(ctx context.Context, origin domain.Origin) (orchestrator.ReviewSync, error)
	OpenPulls(ctx context.Context) (orchestrator.OpenPulls, error)
	Reviewers(ctx context.Context) ([]orchestrator.ReviewerView, []domain.ReviewerNote, error)
	SaveReviewerProfile(ctx context.Context, login, body string) (domain.ReviewerProfile, error)
	AddReviewerNote(ctx context.Context, login, note string) (domain.ReviewerNote, error)
	DeleteReviewerNote(ctx context.Context, id int64) error
	PostPullReview(ctx context.Context, key string, opt orchestrator.PostReviewOptions, origin domain.Origin) (domain.Ticket, orchestrator.PostedReview, error)
}

func (s *Server) reviewsReady(w http.ResponseWriter) bool {
	if s.opt.Reviews == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

func (s *Server) reviewsError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "not found")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

// ListReviewPulls implements gen.ServerInterface.
func (s *Server) ListReviewPulls(w http.ResponseWriter, r *http.Request) {
	if !s.reviewsReady(w) {
		return
	}
	res, err := s.opt.Reviews.OpenPulls(r.Context())
	if err != nil {
		s.reviewsError(w, r, err)
		return
	}
	out := gen.ReviewPullList{Pulls: make([]gen.ReviewPullRow, len(res.Pulls)), Errors: res.Errors}
	if out.Errors == nil {
		out.Errors = []string{}
	}
	for i, p := range res.Pulls {
		row := gen.ReviewPullRow{RepoId: p.Repo.ID, RepoName: p.Repo.Name, Provider: gen.ReviewPullRowProvider(p.Repo.Provider),
			Pull: toPullItem(p.Pull, "", false)}
		if p.Review != nil {
			ref := toPullReviewRef(*p.Review)
			row.Review = &ref
			row.Pull.TicketKey = &ref.Key
		}
		out.Pulls[i] = row
	}
	writeJSON(w, http.StatusOK, out)
}

func toPullReviewRef(t domain.Ticket) gen.PullReviewRef {
	return gen.PullReviewRef{Key: t.Key, State: gen.TicketState(t.State), HeadSha: optStr(t.HeadSHA), CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt}
}

// SyncReviews implements gen.ServerInterface.
func (s *Server) SyncReviews(w http.ResponseWriter, r *http.Request) {
	if !s.reviewsReady(w) {
		return
	}
	res, err := s.opt.Reviews.SyncReviews(r.Context(), origin(r))
	if err != nil {
		s.reviewsError(w, r, err)
		return
	}
	errs := res.Errors
	if errs == nil {
		errs = []string{}
	}
	writeJSON(w, http.StatusOK, gen.ReviewSync{Repos: res.Repos, Open: res.Open, Created: res.Created, Rereview: res.Rereview,
		Closed: res.Closed, Errors: errs})
}

// ListReviewers implements gen.ServerInterface.
func (s *Server) ListReviewers(w http.ResponseWriter, r *http.Request) {
	if !s.reviewsReady(w) {
		return
	}
	vs, notes, err := s.opt.Reviews.Reviewers(r.Context())
	if err != nil {
		s.reviewsError(w, r, err)
		return
	}
	out := gen.Reviewers{Reviewers: []gen.Reviewer{}, Notes: toReviewerNotes(notes)}
	for _, v := range vs {
		x := toReviewer(v.Profile)
		x.Pending = toReviewerNotes(v.Pending)
		out.Reviewers = append(out.Reviewers, x)
	}
	writeJSON(w, http.StatusOK, out)
}

// SaveReviewerProfile implements gen.ServerInterface.
func (s *Server) SaveReviewerProfile(w http.ResponseWriter, r *http.Request, login string) {
	if !s.reviewsReady(w) {
		return
	}
	var req gen.ReviewerProfileInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	p, err := s.opt.Reviews.SaveReviewerProfile(r.Context(), login, req.Profile)
	if err != nil {
		s.reviewsError(w, r, err)
		return
	}
	out := toReviewer(p)
	out.Pending = []gen.ReviewerNote{}
	writeJSON(w, http.StatusOK, out)
}

// AddReviewerNote implements gen.ServerInterface.
func (s *Server) AddReviewerNote(w http.ResponseWriter, r *http.Request) {
	if !s.reviewsReady(w) {
		return
	}
	var req gen.ReviewerNoteInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	n, err := s.opt.Reviews.AddReviewerNote(r.Context(), req.Login, req.Note)
	if err != nil {
		s.reviewsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toReviewerNote(n))
}

// DeleteReviewerNote implements gen.ServerInterface.
func (s *Server) DeleteReviewerNote(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.reviewsReady(w) {
		return
	}
	if err := s.opt.Reviews.DeleteReviewerNote(r.Context(), id); err != nil {
		s.reviewsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func toReviewer(p domain.ReviewerProfile) gen.Reviewer {
	out := gen.Reviewer{Login: p.Login, Profile: p.Body, NotesFolded: p.Notes}
	if !p.UpdatedAt.IsZero() {
		at := p.UpdatedAt
		out.UpdatedAt = &at
	}
	return out
}

func toReviewerNotes(ns []domain.ReviewerNote) []gen.ReviewerNote {
	out := make([]gen.ReviewerNote, 0, len(ns))
	for _, n := range ns {
		out = append(out, toReviewerNote(n))
	}
	return out
}

func toReviewerNote(n domain.ReviewerNote) gen.ReviewerNote {
	out := gen.ReviewerNote{Id: n.ID, Login: n.Login, Kind: gen.ReviewerNoteKind(n.Kind), Note: n.Note, CreatedAt: n.CreatedAt}
	opt := func(s string) *string {
		if s == "" {
			return nil
		}
		return &s
	}
	out.Username, out.RepoName, out.TicketKey, out.PullTitle = opt(n.Username), opt(n.RepoName), opt(n.TicketKey), opt(n.PullTitle)
	return out
}

func toPullRequest(p domain.PullRequest) gen.PullRequest {
	out := gen.PullRequest{Number: p.Number, Url: p.URL, Title: p.Title, Author: p.Author, HeadRef: p.HeadRef, HeadSha: p.HeadSHA,
		BaseRef: p.BaseRef, Draft: p.Draft, State: gen.PullRequestState(p.State), Login: p.Login, Why: gen.PullRequestWhy(p.Why)}
	if out.Why == "" {
		out.Why = gen.PullRequestWhy(domain.PullAssigned)
	}
	if p.Additions > 0 || p.Deletions > 0 {
		add, del := p.Additions, p.Deletions
		out.Additions, out.Deletions = &add, &del
	}
	if !p.UpdatedAt.IsZero() {
		at := p.UpdatedAt
		out.UpdatedAt = &at
	}
	if p.PostedSHA != "" {
		sha := p.PostedSHA
		out.PostedSha = &sha
	}
	out.PostedAt = p.PostedAt
	if p.PostedSHA != "" {
		sha := p.PostedSHA
		out.PostedSha = &sha
	}
	out.PostedAt = p.PostedAt
	return out
}
