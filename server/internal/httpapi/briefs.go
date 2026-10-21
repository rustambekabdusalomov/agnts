package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Briefs is what the repository page's Brief tab reads and changes.
type Briefs interface {
	RepoBrief(ctx context.Context, repoID int64) (domain.RepoBrief, error)
	SaveBrief(ctx context.Context, repoID int64, text string, arch *string, origin domain.Origin) (domain.RepoBrief, error)
	SurveyBrief(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error)
	ApproveBrief(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error)
	DiscardBriefDraft(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error)
}

func (s *Server) briefAction(w http.ResponseWriter, r *http.Request, f func(context.Context) (domain.RepoBrief, error)) {
	if s.opt.Briefs == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	b, err := f(r.Context())
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such repository")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case err != nil:
		s.writeInternal(w, r, err)
	default:
		writeJSON(w, http.StatusOK, toRepoBrief(b))
	}
}

// GetRepoBrief implements gen.ServerInterface.
func (s *Server) GetRepoBrief(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	s.briefAction(w, r, func(ctx context.Context) (domain.RepoBrief, error) { return s.opt.Briefs.RepoBrief(ctx, id) })
}

// SaveRepoBrief implements gen.ServerInterface.
func (s *Server) SaveRepoBrief(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	var req gen.RepoBriefInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.briefAction(w, r, func(ctx context.Context) (domain.RepoBrief, error) {
		return s.opt.Briefs.SaveBrief(ctx, id, req.Body, req.Architecture, origin(r))
	})
}

// SurveyRepoBrief implements gen.ServerInterface.
func (s *Server) SurveyRepoBrief(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	s.briefAction(w, r, func(ctx context.Context) (domain.RepoBrief, error) {
		return s.opt.Briefs.SurveyBrief(ctx, id, origin(r))
	})
}

// ApproveRepoBrief implements gen.ServerInterface.
func (s *Server) ApproveRepoBrief(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	s.briefAction(w, r, func(ctx context.Context) (domain.RepoBrief, error) {
		return s.opt.Briefs.ApproveBrief(ctx, id, origin(r))
	})
}

// DiscardRepoBriefDraft implements gen.ServerInterface.
func (s *Server) DiscardRepoBriefDraft(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	s.briefAction(w, r, func(ctx context.Context) (domain.RepoBrief, error) {
		return s.opt.Briefs.DiscardBriefDraft(ctx, id, origin(r))
	})
}

func toRepoBrief(b domain.RepoBrief) gen.RepoBrief {
	status := b.Status
	if status == "" {
		status = domain.BriefIdle
	}
	return gen.RepoBrief{RepoId: b.RepoID, RepoName: b.RepoName, Body: b.Body, BodySha: b.BodySHA, Draft: b.Draft,
		DraftSha: b.DraftSHA, Status: gen.RepoBriefStatus(status), MergesSince: b.MergesSince,
		RefreshAfter: domain.BriefRefreshMerges, Error: b.Error, SurveyedAt: b.SurveyedAt, ApprovedAt: b.ApprovedAt,
		UpdatedAt: b.UpdatedAt, Architecture: archText(b.Arch), ArchitectureDraft: archText(b.ArchDraft)}
}

// archText is an architecture as indented JSON for people to read and
// edit, nil for none.
func archText(a *domain.Architecture) *string {
	if a == nil {
		return nil
	}
	b, _ := json.MarshalIndent(a, "", "  ")
	s := string(b)
	return &s
}
