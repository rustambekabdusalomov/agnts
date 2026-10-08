package httpapi

import (
	"github.com/modelcontextprotocol/go-sdk/auth"

	"context"
	"errors"
	"net/http"
	"net/url"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/mcpserver"
	"agnts/internal/oauth"
)

// OAuth is the authorization server behind the Claude connector.
type OAuth interface {
	Check(ctx context.Context, a oauth.AuthRequest) (oauth.Client, error)
	Approve(ctx context.Context, userID, ws int64, a oauth.AuthRequest, approve bool) (string, error)
	Verify(ctx context.Context, token string) (oauth.Principal, bool)
	RotateStatic(ctx context.Context, userID int64) (string, error)
	Status(ctx context.Context, userID, ws int64) (static bool, connections int, err error)
	RevokeAll(ctx context.Context, userID, ws int64) error
	ResourceURL() string
	MetadataURL() string
	ProtectedResource(w http.ResponseWriter, r *http.Request)
	AuthorizationServer(w http.ResponseWriter, r *http.Request)
	Register(w http.ResponseWriter, r *http.Request)
	Authorize(w http.ResponseWriter, r *http.Request)
	Token(w http.ResponseWriter, r *http.Request)
}

// mountMCP adds /mcp (bearer-protected MCP endpoint) and the OAuth routes.
func (s *Server) mountMCP(r interface {
	Get(string, http.HandlerFunc)
	Post(string, http.HandlerFunc)
	Handle(string, http.Handler)
}) {
	o := s.opt.OAuth
	r.Get("/.well-known/oauth-protected-resource", o.ProtectedResource)
	r.Get("/.well-known/oauth-protected-resource/mcp", o.ProtectedResource)
	r.Get("/.well-known/oauth-authorization-server", o.AuthorizationServer)
	limit := newIPLimiter(20, time.Minute) // registration and token calls are rare
	limited := func(h http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, req *http.Request) {
			if ok, _ := limit.allow(req.RemoteAddr, time.Now()); !ok {
				http.Error(w, "too many requests", http.StatusTooManyRequests)
				return
			}
			h(w, req)
		}
	}
	r.Post("/oauth/register", limited(o.Register))
	r.Get("/oauth/authorize", o.Authorize)
	r.Post("/oauth/token", limited(o.Token))
	r.Handle("/mcp", s.mcpAuth(s.opt.MCP))
}

// mcpAuth requires a valid bearer token (OAuth access token or a static
// token) and rate-limits by client address. Tools act in the token's
// workspace and as its person (mcpserver.Scope).
func (s *Server) mcpAuth(next http.Handler) http.Handler {
	limit := newIPLimiter(240, time.Minute)
	verify := func(ctx context.Context, token string, _ *http.Request) (*auth.TokenInfo, error) {
		p, ok := s.opt.OAuth.Verify(domain.System(ctx), token)
		if !ok {
			return nil, auth.ErrInvalidToken
		}
		return mcpserver.TokenInfo(p.UserID, p.WorkspaceID, p.Expires), nil
	}
	protected := auth.RequireBearerToken(verify, &auth.RequireBearerTokenOptions{ResourceMetadataURL: s.opt.OAuth.MetadataURL()})(next)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if ok, wait := limit.allow(r.RemoteAddr, time.Now()); !ok {
			w.Header().Set("Retry-After", strings.TrimSuffix(wait.Round(time.Second).String(), "s"))
			http.Error(w, "too many requests", http.StatusTooManyRequests)
			return
		}
		protected.ServeHTTP(w, r)
	})
}

// GetConsent implements gen.ServerInterface.
func (s *Server) GetConsent(w http.ResponseWriter, r *http.Request, p gen.GetConsentParams) {
	if s.opt.OAuth == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	a := oauth.AuthRequest{ClientID: p.ClientId, RedirectURI: p.RedirectUri, CodeChallenge: p.CodeChallenge, Method: p.CodeChallengeMethod}
	if p.Resource != nil {
		a.Resource = *p.Resource
	}
	c, err := s.opt.OAuth.Check(r.Context(), a)
	if err != nil {
		s.consentError(w, r, err)
		return
	}
	u, _ := url.Parse(a.RedirectURI)
	name := c.Name
	if name == "" {
		name = u.Hostname()
	}
	writeJSON(w, http.StatusOK, map[string]string{"clientName": name, "redirectHost": u.Hostname()})
}

// DecideConsent implements gen.ServerInterface.
func (s *Server) DecideConsent(w http.ResponseWriter, r *http.Request) {
	if s.opt.OAuth == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	u, ok := userFrom(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized", "sign in required")
		return
	}
	var req gen.DecideConsentJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	a := oauth.AuthRequest{ClientID: req.ClientId, RedirectURI: req.RedirectUri, CodeChallenge: req.CodeChallenge, Method: req.CodeChallengeMethod}
	if req.State != nil {
		a.State = *req.State
	}
	if req.Resource != nil {
		a.Resource = *req.Resource
	}
	var ws int64
	if req.Approve {
		slug := deref(req.Workspace)
		if slug == "" || s.opt.Workspaces == nil {
			writeError(w, http.StatusBadRequest, "bad_request", "choose the workspace Claude may act in")
			return
		}
		wsp, err := s.opt.Workspaces.BySlug(r.Context(), slug)
		if err == nil {
			_, err = s.opt.Workspaces.Role(r.Context(), wsp.ID, u.ID)
		}
		if err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", "you are not a member of that workspace")
			return
		}
		ws = wsp.ID
	}
	target, err := s.opt.OAuth.Approve(r.Context(), u.ID, ws, a, req.Approve)
	if err != nil {
		s.consentError(w, r, err)
		return
	}
	s.opt.Log.Info("mcp connection", "approved", req.Approve, "client", req.ClientId, "user_id", u.ID)
	writeJSON(w, http.StatusOK, map[string]string{"redirect": target})
}

func (s *Server) consentError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, oauth.ErrInvalidRequest) {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.writeInternal(w, r, err)
}

// GetMcpSettings implements gen.ServerInterface.
func (s *Server) GetMcpSettings(w http.ResponseWriter, r *http.Request) {
	if s.opt.OAuth == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	u, _ := userFrom(r.Context())
	static, n, err := s.opt.OAuth.Status(r.Context(), u.ID, domain.WorkspaceOf(r.Context()))
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.McpStatus{Url: s.opt.OAuth.ResourceURL(), StaticToken: static, Connections: n})
}

// RotateMcpToken implements gen.ServerInterface.
func (s *Server) RotateMcpToken(w http.ResponseWriter, r *http.Request) {
	if s.opt.OAuth == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	u, _ := userFrom(r.Context())
	tok, err := s.opt.OAuth.RotateStatic(r.Context(), u.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.opt.Log.Info("mcp static token rotated", "origin", origin(r))
	writeJSON(w, http.StatusOK, map[string]string{"token": tok})
}

// RevokeMcp implements gen.ServerInterface.
func (s *Server) RevokeMcp(w http.ResponseWriter, r *http.Request) {
	if s.opt.OAuth == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return
	}
	u, _ := userFrom(r.Context())
	if err := s.opt.OAuth.RevokeAll(r.Context(), u.ID, domain.WorkspaceOf(r.Context())); err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.opt.Log.Warn("all mcp connections revoked", "origin", origin(r))
	w.WriteHeader(http.StatusNoContent)
}
