package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/modules"
)

// ModulesService keeps which coding modules each person may use.
type ModulesService interface {
	Config(ctx context.Context) (domain.ModulesConfig, error)
	SetConfig(ctx context.Context, cfg domain.ModulesConfig) (domain.ModulesConfig, error)
	For(ctx context.Context, user int64) (domain.Access, error)
	User(ctx context.Context, user int64) (modules.UserModules, error)
	SetUser(ctx context.Context, user int64, own []string, by int64) (modules.UserModules, error)
	SetOrder(ctx context.Context, user int64, order []string) (modules.UserModules, error)
}

// accessOf is what person user may use; without a modules service, the
// default access.
func (s *Server) accessOf(ctx context.Context, user int64) domain.Access {
	if s.opt.Modules == nil {
		return domain.DefaultAccess()
	}
	a, err := s.opt.Modules.For(ctx, user)
	if err != nil {
		s.opt.Log.Warn("read modules", "user", user, "err", err)
	}
	return a
}

// viewerAccess is what the signed-in person may use.
func (s *Server) viewerAccess(ctx context.Context) domain.Access {
	u, ok := userFrom(ctx)
	if !ok {
		return domain.DefaultAccess()
	}
	return s.accessOf(ctx, u.ID)
}

// moduleEnabled reports whether the Admin enabled module p on this server.
func (s *Server) moduleEnabled(ctx context.Context, p string) bool {
	if s.opt.Modules == nil {
		return domain.DefaultAccess().Allows(p)
	}
	cfg, err := s.opt.Modules.Config(ctx)
	if err != nil {
		return false
	}
	return domain.ResolveAccess(domain.Ceiling(), cfg, cfg.Enabled).Allows(p)
}

// connProvider is the module a connection request is about: the one asked
// for, else the viewer's default module (Codex has no connection).
func (s *Server) connProvider(ctx context.Context, asked *string) string {
	if asked != nil && (*asked == domain.ProviderMuse || *asked == domain.ProviderClaude) {
		return *asked
	}
	if p := s.viewerAccess(ctx).Primary(); p == domain.ProviderMuse {
		return p
	}
	return domain.ProviderClaude
}

func toModules(list []string) []gen.Module {
	out := make([]gen.Module, 0, len(list))
	for _, p := range list {
		out = append(out, gen.Module(p))
	}
	return out
}

func fromModules(list []gen.Module) []string {
	out := make([]string, 0, len(list))
	for _, p := range list {
		out = append(out, string(p))
	}
	return out
}

func toUserModules(u modules.UserModules) gen.UserModules {
	out := gen.UserModules{Effective: toModules(u.Effective), SetAt: u.SetAt}
	if u.Own != nil {
		own := toModules(u.Own)
		out.Own = &own
	}
	if u.Order != nil {
		order := toModules(u.Order)
		out.Order = &order
	}
	return out
}

func toModulesSettings(c domain.ModulesConfig) gen.ModulesSettings {
	available := toModules(domain.Ceiling())
	return gen.ModulesSettings{Available: &available, Enabled: toModules(c.Enabled), Default: toModules(c.Default)}
}

func (s *Server) modulesOff(w http.ResponseWriter) bool {
	if s.opt.Modules == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "module access is not available on this server")
		return true
	}
	return false
}

func (s *Server) modulesError(w http.ResponseWriter, r *http.Request, err error) {
	var inv *modules.InvalidError
	switch {
	case errors.As(err, &inv):
		writeError(w, http.StatusBadRequest, "bad_request", inv.Msg)
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such user")
	default:
		s.writeInternal(w, r, err)
	}
}

// GetModulesSettings implements gen.ServerInterface.
func (s *Server) GetModulesSettings(w http.ResponseWriter, r *http.Request) {
	if s.modulesOff(w) {
		return
	}
	c, err := s.opt.Modules.Config(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toModulesSettings(c))
}

// SetModulesSettings implements gen.ServerInterface.
func (s *Server) SetModulesSettings(w http.ResponseWriter, r *http.Request) {
	if s.modulesOff(w) {
		return
	}
	var req gen.ModulesSettings
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Modules.SetConfig(r.Context(), domain.ModulesConfig{Enabled: fromModules(req.Enabled), Default: fromModules(req.Default)})
	if err != nil {
		s.modulesError(w, r, err)
		return
	}
	admin, _ := userFrom(r.Context())
	s.opt.Log.Info("modules changed", "by", admin.ID, "enabled", c.Enabled, "default", c.Default)
	if s.opt.Tickets != nil {
		s.opt.Tickets.Wake()
	}
	writeJSON(w, http.StatusOK, toModulesSettings(c))
}

// SetUserModules implements gen.ServerInterface.
func (s *Server) SetUserModules(w http.ResponseWriter, r *http.Request, id int64) {
	if s.modulesOff(w) {
		return
	}
	var req gen.SetUserModulesJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var own []string
	if req.Modules != nil {
		own = fromModules(*req.Modules)
	}
	admin, _ := userFrom(r.Context())
	u, err := s.opt.Modules.SetUser(r.Context(), id, own, admin.ID)
	if err != nil {
		s.modulesError(w, r, err)
		return
	}
	if s.opt.Tickets != nil {
		s.opt.Tickets.Wake()
	}
	writeJSON(w, http.StatusOK, toUserModules(u))
}

// GetMyModules implements gen.ServerInterface.
func (s *Server) GetMyModules(w http.ResponseWriter, r *http.Request) {
	if s.modulesOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	um, err := s.opt.Modules.User(r.Context(), u.ID)
	if err != nil {
		s.modulesError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toUserModules(um))
}

// SetMyModuleOrder implements gen.ServerInterface: a person orders the
// modules an Admin lets them use.
func (s *Server) SetMyModuleOrder(w http.ResponseWriter, r *http.Request) {
	if s.modulesOff(w) {
		return
	}
	var req gen.SetMyModuleOrderJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var order []string
	if req.Order != nil {
		order = fromModules(*req.Order)
	}
	u, _ := userFrom(r.Context())
	um, err := s.opt.Modules.SetOrder(r.Context(), u.ID, order)
	if err != nil {
		s.modulesError(w, r, err)
		return
	}
	if s.opt.Tickets != nil {
		s.opt.Tickets.Wake()
	}
	writeJSON(w, http.StatusOK, toUserModules(um))
}
