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

// publicRoutes lists the operations the OpenAPI spec marks `security: []`,
// keyed by "METHOD /api/path/{param}". Everything else requires a session:
// a route missing from the spec is private by default.
func publicRoutes() (map[string]bool, error) {
	spec, err := gen.GetSpec()
	if err != nil {
		return nil, err
	}
	public := map[string]bool{}
	for path, item := range spec.Paths.Map() {
		for method, op := range item.Operations() {
			if op.Security != nil && len(*op.Security) == 0 {
				public[method+" /api"+path] = true
			}
		}
	}
	return public, nil
}

// requireAuth runs after routing, so the chi route pattern is known.
func (s *Server) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		if s.public[r.Method+" "+chi.RouteContext(ctx).RoutePattern()] {
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
		next.ServeHTTP(w, r.WithContext(context.WithValue(ctx, userKey, u)))
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
