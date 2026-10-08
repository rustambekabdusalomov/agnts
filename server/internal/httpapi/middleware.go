package httpapi

import (
	"context"
	"errors"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"golang.org/x/time/rate"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

type ctxKey int

const userKey ctxKey = iota

// userFrom returns the signed-in user set by requireAuth.
func userFrom(ctx context.Context) (domain.User, bool) {
	u, ok := ctx.Value(userKey).(domain.User)
	return u, ok
}

// sessionToken reads the session token from the bearer header or the cookie.
func sessionToken(r *http.Request) string {
	if h := r.Header.Get("Authorization"); len(h) > 7 && strings.EqualFold(h[:7], "bearer ") {
		return strings.TrimSpace(h[7:])
	}
	if c, err := r.Cookie(SessionCookie); err == nil {
		return c.Value
	}
	return ""
}

// opInfo is what the spec says about one operation.
type opInfo struct {
	// public operations need no session (`security: []`).
	public bool
	// scope is "workspace" (the default: acts in one workspace), "user"
	// (the person's own account) or "admin" (the operator console).
	scope string
	// role "owner" limits a workspace operation to the workspace's owner.
	role string
	// viewer lets a viewer call an operation that is not a read (x-viewer:
	// leaving, translating for themselves, their own MCP token). Viewers
	// may otherwise only read.
	viewer bool
}

// operations reads every operation's access rules from the spec, keyed by
// "METHOD /api/path/{param}". A route missing from the spec is private by
// default; a route not marked otherwise acts in a workspace.
func operations() (map[string]opInfo, error) {
	spec, err := gen.GetSpec()
	if err != nil {
		return nil, err
	}
	out := map[string]opInfo{}
	for path, item := range spec.Paths.Map() {
		for method, op := range item.Operations() {
			info := opInfo{scope: "workspace"}
			info.public = op.Security != nil && len(*op.Security) == 0
			if v, ok := op.Extensions["x-scope"].(string); ok {
				info.scope = v
			}
			if v, ok := op.Extensions["x-role"].(string); ok {
				info.role = v
			}
			if v, ok := op.Extensions["x-viewer"].(bool); ok {
				info.viewer = v
			}
			out[method+" /api"+path] = info
		}
	}
	return out, nil
}

// wsPrefix is the route pattern prefix of workspace operations.
const wsPrefix = "/api/w/{ws}"

// WorkspaceStore resolves workspaces and memberships.
type WorkspaceStore interface {
	BySlug(ctx context.Context, slug string) (domain.Workspace, error)
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
	ByHookID(ctx context.Context, hookID string) (domain.Workspace, error)
	Default(ctx context.Context) (domain.Workspace, error)
	Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
	Of(ctx context.Context, userID int64) ([]domain.WorkspaceMembership, error)
	Members(ctx context.Context, ws int64) ([]domain.Member, error)
	Invites(ctx context.Context, ws int64) ([]domain.Invite, error)
	Update(ctx context.Context, ws int64, u postgres.WorkspaceUpdate) (domain.Workspace, error)
	SetLastWorkspace(ctx context.Context, userID, ws int64) error
	RevokeInvite(ctx context.Context, ws, id int64) error
	List(ctx context.Context, withDeleted bool) ([]domain.WorkspaceMembership, error)
	SetPlan(ctx context.Context, ws int64, p postgres.PlanUpdate) (domain.Workspace, error)
	SetSuspended(ctx context.Context, ws int64, suspended bool) (domain.Workspace, error)
	Memberships(ctx context.Context) ([]domain.Member, error)
}

// member is the workspace a request acts in and the person's role there.
type member struct {
	w    domain.Workspace
	role domain.WorkspaceRole
}

const memberKey ctxKey = iota + 100

// memberFrom returns the workspace and role set by authorize.
func memberFrom(ctx context.Context) (member, bool) {
	m, ok := ctx.Value(memberKey).(member)
	return m, ok
}

// authorize runs after routing, so the chi route pattern is known. It
// checks the session, and for workspace operations resolves the
// workspace, checks membership and role, and scopes the request's
// database access to that workspace.
func (s *Server) authorize(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		pattern := chi.RouteContext(ctx).RoutePattern()
		inWS := strings.HasPrefix(pattern, wsPrefix+"/")
		key := r.Method + " " + pattern
		if inWS {
			key = r.Method + " /api" + strings.TrimPrefix(pattern, wsPrefix)
		}
		info, known := s.ops[key]
		if !known || (inWS && info.scope != "workspace") {
			writeError(w, http.StatusNotFound, "not_found", "no such endpoint")
			return
		}
		if info.public {
			next.ServeHTTP(w, r)
			return
		}
		u, err := s.opt.Auth.Authenticate(ctx, sessionToken(r))
		if errors.Is(err, domain.ErrUnauthorized) {
			writeError(w, http.StatusUnauthorized, "unauthorized", "sign in required")
			return
		}
		if err != nil {
			s.writeInternal(w, r, err)
			return
		}
		ctx = context.WithValue(ctx, userKey, u)
		ctx = domain.WithActor(ctx, domain.Actor{UserID: u.ID, Username: u.Username})
		switch info.scope {
		case "user":
		case "admin":
			if !u.IsAdmin {
				writeError(w, http.StatusForbidden, "forbidden", "only an Admin can do this")
				return
			}
		default:
			m, status, msg := s.resolveWorkspace(ctx, r, u, inWS)
			if status != 0 {
				writeError(w, status, map[int]string{http.StatusNotFound: "not_found", http.StatusForbidden: "forbidden",
					http.StatusConflict: "no_workspace"}[status], msg)
				return
			}
			if info.role == "owner" && m.role != domain.RoleOwner {
				writeError(w, http.StatusForbidden, "forbidden", "only the workspace's owner can do this")
				return
			}
			read := r.Method == http.MethodGet || r.Method == http.MethodHead
			if m.role == domain.RoleViewer && !read && !info.viewer {
				writeError(w, http.StatusForbidden, "forbidden", "viewers can see this workspace but not change it")
				return
			}
			if m.w.SuspendedAt != nil && !read {
				writeError(w, http.StatusForbidden, "suspended", "this workspace is suspended; contact the platform's Admin")
				return
			}
			ctx = context.WithValue(ctx, memberKey, m)
			ctx = domain.WithWorkspace(ctx, m.w.ID)
		}
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// resolveWorkspace finds the workspace a workspace operation acts in: the
// path's, else the X-Workspace header's, else the person's last one (or
// their only one). It returns a status and message when there is none
// the person may use.
func (s *Server) resolveWorkspace(ctx context.Context, r *http.Request, u domain.User, inWS bool) (member, int, string) {
	if s.opt.Workspaces == nil {
		return member{}, http.StatusConflict, "workspaces are not available"
	}
	slug := ""
	switch {
	case inWS:
		slug = chi.URLParam(r, "ws")
	case r.Header.Get("X-Workspace") != "":
		slug = r.Header.Get("X-Workspace")
	}
	var w domain.Workspace
	var err error
	if slug != "" {
		w, err = s.opt.Workspaces.BySlug(ctx, slug)
	} else {
		w, err = s.lastWorkspace(ctx, u)
	}
	if errors.Is(err, domain.ErrNotFound) {
		if slug == "" {
			return member{}, http.StatusConflict, "you are not a member of any workspace yet: create one or accept an invite"
		}
		return member{}, http.StatusNotFound, "no such workspace"
	}
	if err != nil {
		return member{}, http.StatusInternalServerError, "internal error"
	}
	role, err := s.opt.Workspaces.Role(ctx, w.ID, u.ID)
	if err != nil {
		// Not a member: the workspace might as well not exist. An Admin
		// sees metadata on the console, never tickets.
		return member{}, http.StatusNotFound, "no such workspace"
	}
	return member{w: w, role: role}, 0, ""
}

// lastWorkspace is the workspace the person opened last, else their first.
func (s *Server) lastWorkspace(ctx context.Context, u domain.User) (domain.Workspace, error) {
	if u.LastWorkspaceID != nil {
		if w, err := s.opt.Workspaces.ByID(ctx, *u.LastWorkspaceID); err == nil && w.DeletedAt == nil {
			if _, err := s.opt.Workspaces.Role(ctx, w.ID, u.ID); err == nil {
				return w, nil
			}
		}
	}
	ws, err := s.opt.Workspaces.Of(ctx, u.ID)
	if err != nil {
		return domain.Workspace{}, err
	}
	if len(ws) == 0 {
		return domain.Workspace{}, domain.ErrNotFound
	}
	return ws[0].Workspace, nil
}

// webhookWorkspace scopes a webhook delivery to the workspace its URL
// names (/webhooks/<provider>/<hook id>), or the default workspace for the
// URLs from before workspaces. The handler then checks the delivery's
// signature with that workspace's secret.
func (s *Server) webhookWorkspace(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if s.opt.Workspaces == nil {
			next.ServeHTTP(w, r)
			return
		}
		ctx := r.Context()
		hook := chi.URLParam(r, "hook")
		var ws domain.Workspace
		var err error
		if hook != "" {
			ws, err = s.opt.Workspaces.ByHookID(domain.System(ctx), hook)
		} else {
			ws, err = s.opt.Workspaces.Default(domain.System(ctx))
		}
		if err != nil {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		ctx = domain.WithHook(domain.WithWorkspace(ctx, ws.ID), hook)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// checkOrigin rejects cross-site state-changing requests. SameSite=Strict
// cookies already block them in current browsers; this is defence in depth.
// Native mobile clients send no Origin and are not affected.
func (s *Server) checkOrigin(next http.Handler) http.Handler {
	allowed := s.opt.PublicURL.Scheme + "://" + s.opt.PublicURL.Host
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet, http.MethodHead, http.MethodOptions:
		default:
			if o := r.Header.Get("Origin"); o != "" && o != allowed {
				writeError(w, http.StatusForbidden, "forbidden", "cross-origin request rejected")
				return
			}
			if r.Header.Get("Sec-Fetch-Site") == "cross-site" {
				writeError(w, http.StatusForbidden, "forbidden", "cross-site request rejected")
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

// clientIP sets r.RemoteAddr to the client's IP without a port. agnts is
// reachable only through Caddy, which overwrites X-Forwarded-For with the
// address it saw unless configured to trust upstream proxies; the rightmost
// entry is therefore the one Caddy wrote. Client-supplied entries to the
// left of it are ignored.
func clientIP(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip := r.RemoteAddr
		if host, _, err := net.SplitHostPort(ip); err == nil {
			ip = host
		}
		if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
			parts := strings.Split(xff, ",")
			if last := strings.TrimSpace(parts[len(parts)-1]); net.ParseIP(last) != nil {
				ip = last
			}
		}
		r.RemoteAddr = ip
		next.ServeHTTP(w, r)
	})
}

func (s *Server) logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
		next.ServeHTTP(ww, r)
		if r.URL.Path == "/healthz" && ww.Status() == http.StatusOK {
			return // Docker polls this; keep the log quiet
		}
		s.opt.Log.Info("http",
			"method", r.Method,
			"path", r.URL.Path,
			"status", ww.Status(),
			"bytes", ww.BytesWritten(),
			"duration_ms", time.Since(start).Milliseconds(),
			"ip", r.RemoteAddr,
			"request_id", middleware.GetReqID(r.Context()),
		)
	})
}

// ipLimiter is a per-IP token bucket for sensitive endpoints.
type ipLimiter struct {
	mu      sync.Mutex
	every   rate.Limit
	burst   int
	clients map[string]*limiterEntry
}

type limiterEntry struct {
	lim  *rate.Limiter
	seen time.Time
}

func newIPLimiter(n int, per time.Duration) *ipLimiter {
	return &ipLimiter{every: rate.Every(per / time.Duration(n)), burst: n, clients: map[string]*limiterEntry{}}
}

// allow reports whether ip may proceed, and if not, how long to wait.
func (l *ipLimiter) allow(ip string, now time.Time) (bool, time.Duration) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if len(l.clients) > 10_000 {
		for k, e := range l.clients {
			if now.Sub(e.seen) > time.Hour {
				delete(l.clients, k)
			}
		}
	}
	e, ok := l.clients[ip]
	if !ok {
		e = &limiterEntry{lim: rate.NewLimiter(l.every, l.burst)}
		l.clients[ip] = e
	}
	e.seen = now
	res := e.lim.ReserveN(now, 1)
	if d := res.DelayFrom(now); d > 0 {
		res.CancelAt(now)
		return false, d
	}
	return true, 0
}
