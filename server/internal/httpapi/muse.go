package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/musecredits"
)

// MuseService signs people in to Meta for Muse Code and keeps the free
// credits Admins give them.
type MuseService interface {
	StartLogin(ctx context.Context, ws, user int64) (musecredits.Login, error)
	LoginStatus(id string, ws, user int64) (musecredits.Login, bool)
	Free(ctx context.Context, user int64) (musecredits.FreeCredits, error)
	SetFree(ctx context.Context, user, limit, by int64) (musecredits.FreeCredits, error)
	Usage(ctx context.Context, user int64) (musecredits.Usage, error)
	SetLimit(ctx context.Context, user, limit, by int64) (musecredits.Usage, error)
}

// ModelInfo describes a model listModels offers.
type ModelInfo struct {
	ID, Label, Provider string
	Strong              bool
	InputPerM, OutputPM float64
}

func (s *Server) museOff(w http.ResponseWriter) bool {
	if s.opt.Muse == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "Muse is not available on this server")
		return true
	}
	return false
}

func toMuseLogin(l musecredits.Login) gen.MuseLogin {
	out := gen.MuseLogin{Id: l.ID, UserCode: l.UserCode, VerificationUri: l.VerificationURI, ExpiresAt: l.ExpiresAt,
		Status: gen.MuseLoginStatus(l.Status)}
	if l.VerificationURIComplete != "" {
		out.VerificationUriComplete = &l.VerificationURIComplete
	}
	if l.Error != "" {
		out.Error = &l.Error
	}
	if l.Account != "" {
		out.Account = &l.Account
	}
	return out
}

func toFreeCredits(f musecredits.FreeCredits) gen.FreeCredits {
	return gen.FreeCredits{Limit: f.Limit, Used: f.Used, Remaining: f.Remaining, SetAt: f.SetAt}
}

func toCreditUsage(u musecredits.Usage) gen.CreditUsage {
	return gen.CreditUsage{MonthLimit: u.MonthLimit, MonthUsed: u.MonthUsed, TotalUsed: u.TotalUsed, SetAt: u.SetAt}
}

// StartMyMuseLogin implements gen.ServerInterface.
func (s *Server) StartMyMuseLogin(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	if !s.accessOf(r.Context(), u.ID).Allows(domain.ProviderMuse) {
		writeError(w, http.StatusForbidden, "module_disabled", "Muse is not enabled for you; ask an Admin")
		return
	}
	l, err := s.opt.Muse.StartLogin(r.Context(), 0, u.ID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "muse_login", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toMuseLogin(l))
}

// GetMyMuseLogin implements gen.ServerInterface.
func (s *Server) GetMyMuseLogin(w http.ResponseWriter, r *http.Request, id string) {
	if s.museOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	l, ok := s.opt.Muse.LoginStatus(id, 0, u.ID)
	if !ok {
		writeError(w, http.StatusNotFound, "not_found", "no such sign-in; start again")
		return
	}
	writeJSON(w, http.StatusOK, toMuseLogin(l))
}

// StartWorkspaceMuseLogin implements gen.ServerInterface.
func (s *Server) StartWorkspaceMuseLogin(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	if !s.moduleEnabled(r.Context(), domain.ProviderMuse) {
		writeError(w, http.StatusForbidden, "module_disabled", "Muse is not enabled on this server")
		return
	}
	l, err := s.opt.Muse.StartLogin(r.Context(), m.w.ID, 0)
	if err != nil {
		writeError(w, http.StatusBadRequest, "muse_login", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toMuseLogin(l))
}

// GetWorkspaceMuseLogin implements gen.ServerInterface.
func (s *Server) GetWorkspaceMuseLogin(w http.ResponseWriter, r *http.Request, id string) {
	if s.museOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	l, ok := s.opt.Muse.LoginStatus(id, m.w.ID, 0)
	if !ok {
		writeError(w, http.StatusNotFound, "not_found", "no such sign-in; start again")
		return
	}
	if l.Status == musecredits.LoginConnected {
		s.workspaceChanged(r.Context(), m.w.ID, "the workspace's Muse account was connected")
	}
	writeJSON(w, http.StatusOK, toMuseLogin(l))
}

// GetMyFreeCredits implements gen.ServerInterface.
func (s *Server) GetMyFreeCredits(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	f, err := s.opt.Muse.Free(r.Context(), u.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toFreeCredits(f))
}

// GetMyCreditUsage implements gen.ServerInterface.
func (s *Server) GetMyCreditUsage(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	cu, err := s.opt.Muse.Usage(r.Context(), u.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toCreditUsage(cu))
}

// SetFreeCredits implements gen.ServerInterface.
func (s *Server) SetFreeCredits(w http.ResponseWriter, r *http.Request, id int64) {
	if s.museOff(w) {
		return
	}
	var req struct {
		Limit int64 `json:"limit"`
	}
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	admin, _ := userFrom(r.Context())
	f, err := s.opt.Muse.SetFree(domain.System(r.Context()), id, req.Limit, admin.ID)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such user")
		return
	case err != nil:
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toFreeCredits(f))
}

// SetCreditLimit implements gen.ServerInterface.
func (s *Server) SetCreditLimit(w http.ResponseWriter, r *http.Request, id int64) {
	if s.museOff(w) {
		return
	}
	var req struct {
		Limit int64 `json:"limit"`
	}
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	admin, _ := userFrom(r.Context())
	u, err := s.opt.Muse.SetLimit(domain.System(r.Context()), id, req.Limit, admin.ID)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such user")
		return
	case err != nil:
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toCreditUsage(u))
}

// ListModels implements gen.ServerInterface: the modules and models the
// viewer may use.
func (s *Server) ListModels(w http.ResponseWriter, r *http.Request) {
	a := s.viewerAccess(r.Context())
	primary := a.Primary()
	if primary == "" {
		primary = domain.DefaultAccess().Primary()
	}
	out := gen.ModelCatalog{Primary: gen.ModelCatalogPrimary(primary), Providers: []gen.ModelCatalogProviders{}, Models: nil}
	for _, p := range a.Modules {
		out.Providers = append(out.Providers, gen.ModelCatalogProviders(p))
	}
	for _, m := range s.models(a) {
		row := struct {
			Id                  gen.Model                      `json:"id"`
			InputPerMillionUSD  *float32                       `json:"inputPerMillionUSD,omitempty"`
			Label               string                         `json:"label"`
			OutputPerMillionUSD *float32                       `json:"outputPerMillionUSD,omitempty"`
			Provider            gen.ModelCatalogModelsProvider `json:"provider"`
			Strong              bool                           `json:"strong"`
		}{Id: m.ID, Label: m.Label, Provider: gen.ModelCatalogModelsProvider(m.Provider), Strong: m.Strong}
		if m.InputPerM > 0 {
			in, outP := float32(m.InputPerM), float32(m.OutputPM)
			row.InputPerMillionUSD, row.OutputPerMillionUSD = &in, &outP
		}
		out.Models = append(out.Models, row)
	}
	if !a.None() {
		// Tiers: the light or strong model of whichever module runs.
		tiers := []struct {
			Id     gen.Model `json:"id"`
			Label  string    `json:"label"`
			Strong bool      `json:"strong"`
		}{{Id: domain.TierLight, Label: "Light, any module"}, {Id: domain.TierStrong, Label: "Strong, any module", Strong: true}}
		out.Tiers = &tiers
	}
	writeJSON(w, http.StatusOK, out)
}

// models lists the models of the modules a person with access a may use.
func (s *Server) models(a domain.Access) []ModelInfo {
	var out []ModelInfo
	for _, p := range a.Modules {
		switch p {
		case domain.ProviderMuse:
			out = append(out,
				ModelInfo{ID: domain.MuseSpark, Label: "Muse Spark", Provider: p, InputPerM: 1.25, OutputPM: 4.25},
				ModelInfo{ID: domain.MuseWonder, Label: "Muse Wonder", Provider: p, Strong: true, InputPerM: 4, OutputPM: 20})
		case domain.ProviderClaude:
			out = append(out,
				ModelInfo{ID: "haiku", Label: "Claude Haiku", Provider: p},
				ModelInfo{ID: "sonnet", Label: "Claude Sonnet", Provider: p},
				ModelInfo{ID: "opus", Label: "Claude Opus", Provider: p, Strong: true})
		}
	}
	return out
}
