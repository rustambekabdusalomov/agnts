// Package httpapi is the REST adapter: it maps HTTP requests to use cases.
// Routes and models are generated from shared/openapi/openapi.yaml into gen/.
package httpapi

//go:generate go tool oapi-codegen -config gen/oapi-codegen.yaml ../../../shared/openapi/openapi.yaml

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"agnts/internal/accounts"
	"agnts/internal/ai"
	"agnts/internal/auth"
	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/meetings"
	"agnts/internal/network"
)

// SessionCookie is the name of the web session cookie.
const SessionCookie = "hiro_session"

const maxBodyBytes = 1 << 20

// Pinger reports whether a dependency is reachable.
type Pinger interface {
	Ping(ctx context.Context) error
}

// Options configure the HTTP server.
type Options struct {
	// Providers are the coding agents behind the AI gateway: the model
	// catalog lists their models. nil: the built-in Claude and Muse lists.
	Providers *ai.Registry
	Auth      *auth.Service
	Tickets   Tickets
	Admin     *Admin  // Phase 2 pages; nil answers 501
	Broker    *Broker // live event stream; nil answers 501
	Devices   Devices // push registrations
	Lessons   Lessons // Learn pages; nil answers 501
	Rules     Rules   // Rules page; nil answers 501
	Briefs    Briefs  // repository briefs; nil answers 501
	Reviews   Reviews // pull request reviews; nil answers 501
	Pulls     Pulls   // pull request conversations; nil answers 501
	// Drafts asks for reviews from pull request pages and keeps their
	// draft comments; nil answers 501.
	Drafts ReviewDrafts
	CI     CI // CI watching; nil answers 501
	// Logs is the log watcher; nil answers 501.
	Logs Logs
	// Chat is the team chat; nil answers 501.
	Chat Chat
	// EgressURL is the egress proxy (AGNTS_RUN_PROXY), whose status page
	// the platform's Admin sees; "" when there is none.
	EgressURL string
	// CommitLinks reads commits linked to tickets by number; nil answers
	// 501 (and commits show no linked tickets).
	CommitLinks CommitLinks
	OAuth       OAuth        // MCP connector authorization; nil disables /mcp
	MCP         http.Handler // the MCP streamable HTTP handler
	DB          Pinger
	// Webhooks are mounted at /webhooks/{name}/{hook id} (and the URL
	// without a hook id, from before workspaces). They authenticate with
	// provider signatures, not sessions.
	Webhooks map[string]http.Handler
	// Payments are the payment providers' callbacks at /webhooks/{name},
	// for the whole platform (they find their payment by id).
	Payments     map[string]http.Handler
	Log          *slog.Logger
	PublicURL    *url.URL
	CookieSecure bool
	WebDir       string // built admin panel; empty disables static serving
	Version      string
	Commit       string

	// Workspaces resolves the workspace in a request's path and the
	// member's role in it.
	Workspaces WorkspaceStore
	// Users reads accounts (names in lists, the Admin's user list).
	Users UserStore
	// Accounts runs sign-up, invites and members; nil answers 501.
	Accounts *accounts.Service
	// Claude manages Claude connections; nil answers 501.
	Claude ClaudeService
	// Muse signs people in to Meta for Muse and keeps free credits; nil
	// answers 501.
	Muse MuseService
	// Modules keeps which coding modules each person may use; nil gives
	// everyone the default access and answers 501 on its Admin pages.
	Modules ModulesService
	// Queue reports the queue and the server's capacity; nil answers 501.
	Queue QueueReporter
	// Billing runs plans, slots and credits; nil answers 501.
	Billing BillingService
	// EventLog records workspace changes.
	EventLog interface {
		AppendEvent(ctx context.Context, ev domain.Event) error
	}
	// Cloud is the hosted product (stricter rules for new accounts).
	Cloud bool
	// Google is sign-in with Google from the website at /auth/google; nil
	// disables it.
	Google *GoogleSignIn
	// Feedback keeps what people send the Admins; nil answers 501.
	Feedback FeedbackStore
	// RunHistory is the transcripts of every invocation and the Admin
	// audit log; nil answers 501.
	RunHistory RunHistory
	// SiteURL is the public website (AGNTS_SITE_URL); its "Request a
	// connector" form posts to /site/connector-request. Nil turns that off.
	SiteURL *url.URL
	// Network runs the workspace's private network (VPN, agnts-link);
	// nil answers 501.
	Network *network.Service
	// Assistant answers questions about the workspace; nil answers 501.
	Assistant Assistant
	// Code runs the chat's Code mode; nil answers 501.
	Code CodeChat
	// Swagger runs Swagger tests; nil answers 501.
	Swagger Swagger
	// Suites runs saved Swagger test suites; nil answers 501 and turns
	// off the deploy hook at /webhooks/swagger-suite/{token}.
	Suites SwaggerSuites
	// Documents runs the Documents module; nil answers 501.
	Documents *documents.Service
	// Meetings runs video calls; nil (or no LiveKit) answers 501. Its
	// LiveKit server's webhooks come to /webhooks/livekit.
	Meetings *meetings.Service
}

// Server implements gen.ServerInterface.
type Server struct {
	opt          Options
	loginLimiter *ipLimiter
	mailLimiter  *ipLimiter
	// feedbackLimiter: a few feedbacks per address every 10 minutes.
	feedbackLimiter *ipLimiter
	// hookLimiter: deploy hook calls per address every 10 minutes.
	hookLimiter *ipLimiter
	// publicLimiter: public document requests per address every minute. A
	// guest's page asks every 10 seconds, and a client's office may share
	// one address.
	publicLimiter *ipLimiter
	// pushLimiter: log pushes per token every minute (a shipper sends a
	// batch every few seconds).
	pushLimiter *ipLimiter
	ops         map[string]opInfo
}

var _ gen.ServerInterface = (*Server)(nil)

// NewHandler returns the root HTTP handler.
func NewHandler(opt Options) (http.Handler, error) {
	ops, err := operations()
	if err != nil {
		return nil, fmt.Errorf("httpapi: load embedded spec: %w", err)
	}
	s := &Server{opt: opt, loginLimiter: newIPLimiter(5, time.Minute), mailLimiter: newIPLimiter(5, 10*time.Minute),
		feedbackLimiter: newIPLimiter(5, 10*time.Minute), hookLimiter: newIPLimiter(30, 10*time.Minute),
		publicLimiter: newIPLimiter(300, time.Minute), pushLimiter: newIPLimiter(120, time.Minute), ops: ops}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(clientIP)
	r.Use(s.logRequests)
	r.Use(middleware.Recoverer)

	r.Get("/healthz", s.healthz)
	if opt.OAuth != nil && opt.MCP != nil {
		s.mountMCP(r)
	}
	for name, h := range opt.Webhooks {
		// Each workspace has its own URL; the one without a hook id is the
		// URL from before workspaces and goes to the default workspace.
		r.With(middleware.RequestSize(maxBodyBytes), s.webhookWorkspace).Handle("/webhooks/"+name+"/{hook}", h)
		r.With(middleware.RequestSize(maxBodyBytes), s.webhookWorkspace).Handle("/webhooks/"+name, h)
	}

	if opt.Suites != nil {
		// A deploy pipeline's call, without a session: the token is the
		// credential and names the suite.
		r.With(middleware.RequestSize(16<<10), middleware.NoCache).Post("/webhooks/swagger-suite/{token}", s.suiteHook)
	}
	if opt.Logs != nil {
		// Log shippers push with a token, without a session.
		push := r.With(middleware.NoCache)
		push.Post("/webhooks/logs", s.logsPush)
		push.Post("/webhooks/logs/loki/api/v1/push", s.logsPush)
		push.Post("/webhooks/logs/{token}", s.logsPush)
		push.Post("/webhooks/logs/{token}/loki/api/v1/push", s.logsPush)
		push.Post("/webhooks/logs/v1/logs", s.logsPush)
		push.Post("/webhooks/logs/{token}/v1/logs", s.logsPush)
	}
	for name, h := range opt.Payments {
		r.With(middleware.RequestSize(maxBodyBytes)).Handle("/webhooks/"+name, h)
	}
	if opt.Meetings != nil && opt.Meetings.Ready() {
		r.With(middleware.RequestSize(maxBodyBytes)).Post("/webhooks/livekit", s.livekitWebhook)
	}
	if opt.SiteURL != nil && opt.Feedback != nil {
		// Called by the website from another origin, without an account:
		// outside /api, with its own CORS answer.
		site := r.With(middleware.RequestSize(16<<10), middleware.NoCache)
		site.Options("/site/connector-request", s.connectorRequestPreflight)
		site.Post("/site/connector-request", s.connectorRequest)
	}
	if opt.Google != nil {
		// A form post from the website, not a JSON API call: outside /api.
		r.With(middleware.RequestSize(16<<10), middleware.NoCache).Post("/auth/google", s.googleSignIn)
	}

	badRequest := func(w http.ResponseWriter, _ *http.Request, err error) {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	}
	notFound := func(w http.ResponseWriter, _ *http.Request) {
		writeError(w, http.StatusNotFound, "not_found", "no such endpoint")
	}
	r.Route("/api", func(api chi.Router) {
		api.Use(bodyLimit)
		api.Use(s.checkOrigin)
		api.Use(middleware.NoCache)
		// Workspace operations under /api/w/{ws}/...; the same operations
		// at /api/... act in the X-Workspace header's workspace, or the
		// last one the person opened (clients from before workspaces).
		api.Route("/w/{ws}", func(wr chi.Router) {
			gen.HandlerWithOptions(s, gen.ChiServerOptions{
				BaseRouter: wr, Middlewares: []gen.MiddlewareFunc{s.authorize}, ErrorHandlerFunc: badRequest,
			})
			wr.NotFound(notFound)
		})
		gen.HandlerWithOptions(s, gen.ChiServerOptions{
			BaseRouter: api, Middlewares: []gen.MiddlewareFunc{s.authorize}, ErrorHandlerFunc: badRequest,
		})
		api.NotFound(notFound)
	})

	if opt.WebDir != "" {
		spa := spaHandler(opt.WebDir)
		// A public document's page: the admin app, kept out of search
		// engines and without a Referer that carries its token.
		r.Get("/d/{token}", func(w http.ResponseWriter, r *http.Request) {
			publicHeaders(w)
			spa.ServeHTTP(w, r)
		})
		// A meeting's link: the admin app's lobby and call page.
		r.Get("/m/{code}", func(w http.ResponseWriter, r *http.Request) {
			publicHeaders(w)
			spa.ServeHTTP(w, r)
		})
		r.NotFound(spa.ServeHTTP)
	}
	return r, nil
}

// bodyLimit caps request bodies: uploads may carry one file, everything
// else is small JSON.
func bodyLimit(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		limit := int64(maxBodyBytes)
		if r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/attachments") {
			limit = maxUploadBytes
		}
		if r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/assistant/transcribe") {
			limit = maxVoiceBody
		}
		if r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/swagger-tests/spec") {
			limit = maxSpecBody
		}
		r.Body = http.MaxBytesReader(w, r.Body, limit)
		next.ServeHTTP(w, r)
	})
}

func (s *Server) healthz(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if err := s.opt.DB.Ping(ctx); err != nil {
		s.opt.Log.Warn("health check failed", "err", err)
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "unavailable", "db": "down"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok", "db": "ok"})
}

// GetMeta implements gen.ServerInterface.
func (s *Server) GetMeta(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, gen.Meta{Version: s.opt.Version, Commit: s.opt.Commit})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, code, msg string) {
	writeJSON(w, status, gen.Error{Code: code, Message: msg})
}

// writeInternal logs err and returns a generic 500.
func (s *Server) writeInternal(w http.ResponseWriter, r *http.Request, err error) {
	s.opt.Log.Error("request failed", "err", err, "path", r.URL.Path, "request_id", middleware.GetReqID(r.Context()))
	writeError(w, http.StatusInternalServerError, "internal", "internal error")
}

func decodeJSON(r *http.Request, v any) error {
	return decode(r, v, false)
}

// decodeOptionalJSON is decodeJSON for endpoints whose body may be left out.
func decodeOptionalJSON(r *http.Request, v any) error {
	return decode(r, v, true)
}

func decode(r *http.Request, v any, optional bool) error {
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(v); err != nil {
		if optional && errors.Is(err, io.EOF) {
			return nil
		}
		var tooBig *http.MaxBytesError
		if errors.As(err, &tooBig) {
			return errors.New("request body too large")
		}
		// Say what is wrong (an unknown field, a wrong type, broken syntax):
		// a bare "invalid JSON body" leaves API clients guessing.
		return fmt.Errorf("invalid JSON body: %s", strings.TrimPrefix(err.Error(), "json: "))
	}
	return nil
}
