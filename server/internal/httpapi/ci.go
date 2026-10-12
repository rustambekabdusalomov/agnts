package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"agnts/internal/ciwatch"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

// CI is CI watching (ciwatch.Service).
type CI interface {
	List(ctx context.Context, f domain.CIFilter) ([]domain.CIFailure, error)
	Get(ctx context.Context, id int64) (domain.CIFailure, error)
	ForTicket(ctx context.Context, key string) (domain.CIFailure, error)
	FixIt(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error)
	Mute(ctx context.Context, id int64, mute bool) (domain.CIFailure, error)
	Rerun(ctx context.Context, id int64) error
	Watch(ctx context.Context, repoID int64) (domain.CIWatch, error)
	SetWatch(ctx context.Context, w domain.CIWatch) (domain.CIWatch, error)
	Problem(ctx context.Context, repoID int64) string
	TicketStates(ctx context.Context, fs []domain.CIFailure) map[string]domain.TicketState
}

var _ CI = (*ciwatch.Service)(nil)

func (s *Server) ciReady(w http.ResponseWriter) bool {
	if s.opt.CI == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "CI watching is not available")
		return false
	}
	return true
}

func (s *Server) writeCIError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such CI failure")
	case errors.Is(err, ciwatch.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", strings.TrimPrefix(err.Error(), "invalid: "))
	default:
		s.writeUseCaseError(w, r, err)
	}
}

func toCIFailure(f domain.CIFailure, states map[string]domain.TicketState) gen.CIFailure {
	out := gen.CIFailure{Id: f.ID, RepoId: f.RepoID, Repo: f.RepoName, Branch: f.Branch, Workflow: f.Workflow, Job: f.Job,
		Title: f.Title, Class: f.Class, Status: gen.CIStatus(f.Status), Count: f.Count, FlakyCount: f.FlakyCount,
		FirstSeenAt: f.FirstSeenAt, LastSeenAt: f.LastSeenAt, FirstSha: f.FirstSHA, LastSha: f.LastSHA,
		Occurrences: make([]gen.CIOccurrence, len(f.Occurrences)), TicketKey: f.TicketKey, PrNumber: f.PRNumber, FixedAt: f.FixedAt}
	for i, o := range f.Occurrences {
		out.Occurrences[i] = gen.CIOccurrence{RunId: o.RunID, Url: o.URL, Sha: o.SHA, Job: o.Job, At: o.At}
		if o.Flaky {
			out.Occurrences[i].Flaky = ptr(true)
		}
	}
	if f.FixedSHA != "" {
		out.FixedSha = ptr(f.FixedSHA)
	}
	if f.Sample != "" {
		out.Sample = ptr(f.Sample)
	}
	if st, ok := states[f.TicketKey]; ok {
		out.TicketState = ptr(gen.TicketState(st))
	}
	return out
}

// ListCIFailures implements gen.ServerInterface.
func (s *Server) ListCIFailures(w http.ResponseWriter, r *http.Request, p gen.ListCIFailuresParams) {
	if !s.ciReady(w) {
		return
	}
	var f domain.CIFilter
	if p.RepoId != nil {
		f.RepoID = *p.RepoId
	}
	if p.Status != nil {
		for _, st := range strings.Split(*p.Status, ",") {
			if st = strings.TrimSpace(st); st == "" {
				continue
			}
			if !domain.CIStatus(st).Valid() {
				writeError(w, http.StatusBadRequest, "bad_request", "unknown status "+st)
				return
			}
			f.Statuses = append(f.Statuses, domain.CIStatus(st))
		}
	}
	fs, err := s.opt.CI.List(r.Context(), f)
	if err != nil {
		s.writeCIError(w, r, err)
		return
	}
	states := s.opt.CI.TicketStates(r.Context(), fs)
	out := make([]gen.CIFailure, len(fs))
	for i, x := range fs {
		out[i] = toCIFailure(x, states)
	}
	writeJSON(w, http.StatusOK, out)
}

func (s *Server) writeCIFailure(w http.ResponseWriter, r *http.Request, f domain.CIFailure, err error) {
	if err != nil {
		s.writeCIError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toCIFailure(f, s.opt.CI.TicketStates(r.Context(), []domain.CIFailure{f})))
}

// GetCIFailure implements gen.ServerInterface.
func (s *Server) GetCIFailure(w http.ResponseWriter, r *http.Request, id gen.CIFailureID) {
	if !s.ciReady(w) {
		return
	}
	f, err := s.opt.CI.Get(r.Context(), id)
	s.writeCIFailure(w, r, f, err)
}

// GetTicketCIFailure implements gen.ServerInterface.
func (s *Server) GetTicketCIFailure(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.ciReady(w) {
		return
	}
	f, err := s.opt.CI.ForTicket(r.Context(), key)
	s.writeCIFailure(w, r, f, err)
}

// FixCIFailure implements gen.ServerInterface.
func (s *Server) FixCIFailure(w http.ResponseWriter, r *http.Request, id gen.CIFailureID) {
	if !s.ciReady(w) {
		return
	}
	t, err := s.opt.CI.FixIt(r.Context(), id, origin(r))
	if err != nil {
		s.writeCIError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusOK, t)
}

// MuteCIFailure implements gen.ServerInterface.
func (s *Server) MuteCIFailure(w http.ResponseWriter, r *http.Request, id gen.CIFailureID) {
	if !s.ciReady(w) {
		return
	}
	f, err := s.opt.CI.Mute(r.Context(), id, true)
	s.writeCIFailure(w, r, f, err)
}

// UnmuteCIFailure implements gen.ServerInterface.
func (s *Server) UnmuteCIFailure(w http.ResponseWriter, r *http.Request, id gen.CIFailureID) {
	if !s.ciReady(w) {
		return
	}
	f, err := s.opt.CI.Mute(r.Context(), id, false)
	s.writeCIFailure(w, r, f, err)
}

// RerunCIFailure implements gen.ServerInterface.
func (s *Server) RerunCIFailure(w http.ResponseWriter, r *http.Request, id gen.CIFailureID) {
	if !s.ciReady(w) {
		return
	}
	if err := s.opt.CI.Rerun(r.Context(), id); err != nil {
		if errors.Is(err, domain.ErrNotFound) || errors.Is(err, ciwatch.ErrInvalid) {
			s.writeCIError(w, r, err)
			return
		}
		writeError(w, http.StatusBadGateway, "bad_gateway", err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func toCIWatch(v domain.CIWatch) gen.CIWatch {
	return gen.CIWatch{Enabled: v.Enabled, Branches: nonNil(v.Branches), Ignore: nonNil(v.Ignore), Prs: string(v.PRs), AutoFix: v.AutoFix}
}

// GetRepoCIWatch implements gen.ServerInterface.
func (s *Server) GetRepoCIWatch(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.ciReady(w) {
		return
	}
	v, err := s.opt.CI.Watch(r.Context(), id)
	if err != nil {
		s.writeCIError(w, r, err)
		return
	}
	out := toCIWatch(v)
	if p := s.opt.CI.Problem(r.Context(), id); p != "" {
		out.Problem = &p
	}
	writeJSON(w, http.StatusOK, out)
}

// PutRepoCIWatch implements gen.ServerInterface.
func (s *Server) PutRepoCIWatch(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.ciReady(w) {
		return
	}
	var req gen.CIWatch
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.CI.SetWatch(r.Context(), domain.CIWatch{RepoID: id, Enabled: req.Enabled, Branches: req.Branches,
		Ignore: req.Ignore, PRs: domain.CIPRMode(req.Prs), AutoFix: req.AutoFix})
	if err != nil {
		s.writeCIError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toCIWatch(v))
}
