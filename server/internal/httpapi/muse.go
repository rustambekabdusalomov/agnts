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
	SetFallbackLimit(ctx context.Context, user int64, limit *int64, by int64) (musecredits.Usage, error)
	// Provider is where runs on agnts's credits go; SetProvider makes an
	// Admin's choice (auto, primary, fallback) and tries agnts's Meta
	// account again from the next run.
	Provider(ctx context.Context) (musecredits.ProviderStatus, error)
	SetProvider(ctx context.Context, mode string, by int64) (musecredits.ProviderStatus, error)
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
	out := gen.CreditUsage{MonthLimit: u.MonthLimit, MonthUsed: u.MonthUsed, TotalUsed: u.TotalUsed, SetAt: u.SetAt}
	if f := u.Fallback; f != nil {
		out.Fallback = &gen.FallbackUsage{Provider: f.Provider, MonthLimit: f.MonthLimit, MonthUsed: f.MonthUsed, IsDefault: f.Default, SetAt: f.SetAt}
	}
	return out
}

// StartMyMuseLogin implements gen.ServerInterface.
func (s *Server) StartMyMuseLogin(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
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

// SetFallbackLimit implements gen.ServerInterface.
func (s *Server) SetFallbackLimit(w http.ResponseWriter, r *http.Request, id int64) {
	if s.museOff(w) {
		return
	}
	var req gen.SetFallbackLimitJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	admin, _ := userFrom(r.Context())
	u, err := s.opt.Muse.SetFallbackLimit(domain.System(r.Context()), id, req.Limit, admin.ID)
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

// ListModels implements gen.ServerInterface.
func (s *Server) ListModels(w http.ResponseWriter, r *http.Request) {
	out := gen.ModelCatalog{Primary: gen.ModelCatalogPrimary(domain.PrimaryProvider())}
	for _, p := range domain.EnabledProviders() {
		out.Providers = append(out.Providers, gen.ModelCatalogProviders(p))
	}
	for _, m := range s.models() {
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
	writeJSON(w, http.StatusOK, out)
}

// models lists the models of the enabled providers.
func (s *Server) models() []ModelInfo {
	var out []ModelInfo
	for _, p := range domain.EnabledProviders() {
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

func toMuseProvider(p musecredits.ProviderStatus) gen.MuseProvider {
	out := gen.MuseProvider{Mode: gen.MuseProviderMode(p.Mode)}
	if p.Fallback != "" {
		out.Fallback = &struct {
			Model string `json:"model"`
			Name  string `json:"name"`
		}{Model: p.FallbackModel, Name: p.Fallback}
	}
	if !p.OutUntil.IsZero() {
		out.PrimaryOutUntil, out.PrimaryOutReason = &p.OutUntil, &p.OutReason
	}
	if !p.SetAt.IsZero() {
		out.SetAt = &p.SetAt
	}
	return out
}

// GetMuseProvider implements gen.ServerInterface.
func (s *Server) GetMuseProvider(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	p, err := s.opt.Muse.Provider(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toMuseProvider(p))
}

// SetMuseProvider implements gen.ServerInterface.
func (s *Server) SetMuseProvider(w http.ResponseWriter, r *http.Request) {
	if s.museOff(w) {
		return
	}
	var req gen.SetMuseProviderJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	admin, _ := userFrom(r.Context())
	p, err := s.opt.Muse.SetProvider(r.Context(), string(req.Mode), admin.ID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, toMuseProvider(p))
}
