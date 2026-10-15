package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// SwaggerSuites runs saved Swagger test suites (the orchestrator).
type SwaggerSuites interface {
	SaveSuiteFromTicket(ctx context.Context, in orchestrator.SuiteInput) (domain.SwaggerSuite, error)
	UpdateSuite(ctx context.Context, id int64, in orchestrator.SuiteInput) (domain.SwaggerSuite, error)
	Suites(ctx context.Context) ([]domain.SwaggerSuite, error)
	Suite(ctx context.Context, id int64) (domain.SwaggerSuite, error)
	DeleteSuite(ctx context.Context, id int64) error
	RunSuite(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error)
	RotateSuiteHook(ctx context.Context, id int64) (string, error)
	RunSuiteByHook(ctx context.Context, tok string) (domain.Ticket, error)
}

func (s *Server) suitesReady(w http.ResponseWriter) bool {
	if s.opt.Suites == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "Swagger test suites are not available on this server")
		return false
	}
	return true
}

func toSuite(su domain.SwaggerSuite) gen.SwaggerSuite {
	return gen.SwaggerSuite{Id: su.ID, Name: su.Name, SpecUrl: nonEmpty(su.SpecURL), BaseUrl: su.BaseURL, Operations: len(su.Operations),
		WriteEnabled: su.WriteEnabled, AuthKind: gen.ApiAuthKind(su.Auth.Kind), HasToken: su.HasSecret, RepoId: su.RepoID,
		Schedule: gen.SwaggerSuiteSchedule(su.Schedule), Hour: su.Hour, Enabled: su.Enabled, HookSet: su.HookSet,
		LastRunAt: su.LastRunAt, NextRunAt: su.NextRunAt, LastTicketKey: nonEmpty(su.LastTicketKey), CreatedAt: su.CreatedAt}
}

func suiteInput(req gen.SwaggerSuiteInput, cur *domain.SwaggerSuite) orchestrator.SuiteInput {
	in := orchestrator.SuiteInput{FromTicket: deref(req.FromTicket), Name: deref(req.Name), Enabled: true, Credential: req.Token, Hour: 6}
	if cur != nil {
		in.Name, in.Schedule, in.Hour, in.Enabled = cur.Name, cur.Schedule, cur.Hour, cur.Enabled
		if req.Name != nil {
			in.Name = *req.Name
		}
	}
	if req.Schedule != nil {
		in.Schedule = domain.SuiteSchedule(*req.Schedule)
	}
	if req.Hour != nil {
		in.Hour = *req.Hour
	}
	if req.Enabled != nil {
		in.Enabled = *req.Enabled
	}
	return in
}

// ListSwaggerSuites implements gen.ServerInterface.
func (s *Server) ListSwaggerSuites(w http.ResponseWriter, r *http.Request) {
	if !s.suitesReady(w) {
		return
	}
	list, err := s.opt.Suites.Suites(r.Context())
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := make([]gen.SwaggerSuite, 0, len(list))
	for _, su := range list {
		out = append(out, toSuite(su))
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateSwaggerSuite implements gen.ServerInterface.
func (s *Server) CreateSwaggerSuite(w http.ResponseWriter, r *http.Request) {
	if !s.suitesReady(w) {
		return
	}
	var req gen.SwaggerSuiteInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if req.FromTicket == nil || *req.FromTicket == "" {
		writeError(w, http.StatusBadRequest, "bad_request", "fromTicket is required: a suite keeps a Swagger test ticket's test")
		return
	}
	su, err := s.opt.Suites.SaveSuiteFromTicket(r.Context(), suiteInput(req, nil))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toSuite(su))
}

// GetSwaggerSuite implements gen.ServerInterface.
func (s *Server) GetSwaggerSuite(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.suitesReady(w) {
		return
	}
	su, err := s.opt.Suites.Suite(r.Context(), id)
	if err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSuite(su))
}

// UpdateSwaggerSuite implements gen.ServerInterface.
func (s *Server) UpdateSwaggerSuite(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.suitesReady(w) {
		return
	}
	var req gen.SwaggerSuiteInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	cur, err := s.opt.Suites.Suite(r.Context(), id)
	if err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	su, err := s.opt.Suites.UpdateSuite(r.Context(), id, suiteInput(req, &cur))
	if err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSuite(su))
}

// DeleteSwaggerSuite implements gen.ServerInterface.
func (s *Server) DeleteSwaggerSuite(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.suitesReady(w) {
		return
	}
	if err := s.opt.Suites.DeleteSuite(r.Context(), id); err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// RunSwaggerSuite implements gen.ServerInterface.
func (s *Server) RunSwaggerSuite(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.suitesReady(w) {
		return
	}
	t, err := s.opt.Suites.RunSuite(r.Context(), id, origin(r))
	if err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// RotateSwaggerSuiteHook implements gen.ServerInterface.
func (s *Server) RotateSwaggerSuiteHook(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.suitesReady(w) {
		return
	}
	tok, err := s.opt.Suites.RotateSuiteHook(r.Context(), id)
	if err != nil {
		s.writeSuiteError(w, r, err)
		return
	}
	base := ""
	if s.opt.PublicURL != nil {
		base = strings.TrimSuffix(s.opt.PublicURL.String(), "/")
	}
	writeJSON(w, http.StatusOK, map[string]string{"url": base + "/webhooks/swagger-suite/" + tok})
}

func (s *Server) writeSuiteError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such suite")
	case errors.Is(err, orchestrator.ErrSuiteBusy):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	default:
		s.writeUseCaseError(w, r, err)
	}
}

// suiteHook runs a suite from a deploy pipeline: POST
// /webhooks/swagger-suite/{token}, no session; the token names the suite.
func (s *Server) suiteHook(w http.ResponseWriter, r *http.Request) {
	if ok, _ := s.hookLimiter.allow(r.RemoteAddr, time.Now()); !ok {
		writeError(w, http.StatusTooManyRequests, "too_many_requests", "too many hook calls: wait a few minutes")
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
	defer cancel()
	t, err := s.opt.Suites.RunSuiteByHook(ctx, chi.URLParam(r, "token"))
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such hook")
	case errors.Is(err, orchestrator.ErrSuiteBusy):
		writeJSON(w, http.StatusAccepted, map[string]string{"status": "busy", "ticket": t.Key})
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case err != nil:
		s.writeInternal(w, r, err)
	default:
		writeJSON(w, http.StatusAccepted, map[string]string{"status": "started", "ticket": t.Key})
	}
}
