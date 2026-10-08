// Package oauth is a small OAuth 2.1 authorization server for Claude's MCP
// connectors: dynamic client registration, authorization code with PKCE
// (S256 only), refresh token rotation. It also keeps the optional static
// MCP bearer token used by Claude Code and Claude Desktop.
package oauth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Token lifetimes.
const (
	codeTTL    = 5 * time.Minute
	accessTTL  = time.Hour
	refreshTTL = 30 * 24 * time.Hour
)

// Server issues and checks tokens.
type Server struct {
	db            *pgxpool.Pool
	issuer        string   // public URL, e.g. https://agnts.example.com
	redirectHosts []string // hosts allowed in registered redirect URIs
	log           *slog.Logger
	now           func() time.Time
}

// New returns the OAuth server. redirectHosts limits which redirect URIs
// clients may register (Claude's are on claude.ai and claude.com).
func New(db *pgxpool.Pool, issuer string, redirectHosts []string, log *slog.Logger) *Server {
	return &Server{db: db, issuer: strings.TrimRight(issuer, "/"), redirectHosts: redirectHosts, log: log, now: time.Now}
}

// ResourceURL is the MCP endpoint these tokens are for.
func (s *Server) ResourceURL() string { return s.issuer + "/mcp" }

// MetadataURL is where clients discover how to get a token.
func (s *Server) MetadataURL() string { return s.issuer + "/.well-known/oauth-protected-resource" }

func hash(v string) []byte {
	h := sha256.Sum256([]byte(v))
	return h[:]
}

func random(n int) string {
	b := make([]byte, n)
	_, _ = rand.Read(b)
	return base64.RawURLEncoding.EncodeToString(b)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func oauthError(w http.ResponseWriter, status int, code, desc string) {
	writeJSON(w, status, map[string]string{"error": code, "error_description": desc})
}

// ProtectedResource serves RFC 9728 metadata for /mcp.
func (s *Server) ProtectedResource(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"resource":                 s.ResourceURL(),
		"authorization_servers":    []string{s.issuer},
		"bearer_methods_supported": []string{"header"},
		"resource_name":            "agnts",
	})
}

// AuthorizationServer serves RFC 8414 metadata.
func (s *Server) AuthorizationServer(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"issuer":                                s.issuer,
		"authorization_endpoint":                s.issuer + "/oauth/authorize",
		"token_endpoint":                        s.issuer + "/oauth/token",
		"registration_endpoint":                 s.issuer + "/oauth/register",
		"response_types_supported":              []string{"code"},
		"grant_types_supported":                 []string{"authorization_code", "refresh_token"},
		"code_challenge_methods_supported":      []string{"S256"},
		"token_endpoint_auth_methods_supported": []string{"none"},
		"scopes_supported":                      []string{"agnts"},
	})
}

// allowedRedirect accepts https URIs on allowed hosts, and http on loopback
// (Claude Code and Desktop listen locally during sign-in).
func (s *Server) allowedRedirect(raw string) bool {
	u, err := url.Parse(raw)
	if err != nil || u.Host == "" || u.Fragment != "" {
		return false
	}
	host := u.Hostname()
	if u.Scheme == "http" {
		return host == "localhost" || host == "127.0.0.1" || host == "::1"
	}
	if u.Scheme != "https" {
		return false
	}
	for _, h := range s.redirectHosts {
		if host == h || strings.HasSuffix(host, "."+h) {
			return true
		}
	}
	return false
}

// Register implements dynamic client registration (RFC 7591), public clients only.
func (s *Server) Register(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ClientName   string   `json:"client_name"`
		RedirectURIs []string `json:"redirect_uris"`
	}
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 64<<10)).Decode(&req); err != nil {
		oauthError(w, http.StatusBadRequest, "invalid_client_metadata", "invalid JSON")
		return
	}
	if len(req.RedirectURIs) == 0 || len(req.RedirectURIs) > 10 {
		oauthError(w, http.StatusBadRequest, "invalid_redirect_uri", "1 to 10 redirect_uris are required")
		return
	}
	for _, u := range req.RedirectURIs {
		if !s.allowedRedirect(u) {
			oauthError(w, http.StatusBadRequest, "invalid_redirect_uri", "redirect URI not allowed: "+u)
			return
		}
	}
	name := strings.TrimSpace(req.ClientName)
	if len(name) > 100 {
		name = name[:100]
	}
	id := "c_" + random(18)
	uris, _ := json.Marshal(req.RedirectURIs)
	if _, err := s.db.Exec(r.Context(), `INSERT INTO oauth_clients (id, name, redirect_uris) VALUES ($1, $2, $3)`, id, name, uris); err != nil {
		s.log.Error("oauth register", "err", err)
		oauthError(w, http.StatusInternalServerError, "server_error", "")
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{
		"client_id": id, "client_name": name, "redirect_uris": req.RedirectURIs,
		"token_endpoint_auth_method": "none", "grant_types": []string{"authorization_code", "refresh_token"},
		"response_types": []string{"code"},
	})
}

// Client is a registered client.
type Client struct {
	ID           string
	Name         string
	RedirectURIs []string
}

// ErrInvalidRequest describes a bad authorization request.
var ErrInvalidRequest = errors.New("invalid authorization request")

func (s *Server) client(ctx context.Context, id string) (Client, error) {
	c := Client{ID: id}
	var uris []byte
	err := s.db.QueryRow(ctx, `SELECT name, redirect_uris FROM oauth_clients WHERE id = $1`, id).Scan(&c.Name, &uris)
	if errors.Is(err, pgx.ErrNoRows) {
		return c, fmt.Errorf("%w: unknown client", ErrInvalidRequest)
	}
	if err != nil {
		return c, err
	}
	_ = json.Unmarshal(uris, &c.RedirectURIs)
	return c, nil
}

// AuthRequest is an authorization request awaiting the user's consent.
type AuthRequest struct {
	ClientID      string
	RedirectURI   string
	CodeChallenge string
	Method        string
	State         string
	Resource      string
}

// Check validates a request and returns the client for the consent page.
func (s *Server) Check(ctx context.Context, a AuthRequest) (Client, error) {
	c, err := s.client(ctx, a.ClientID)
	if err != nil {
		return c, err
	}
	if !slices.Contains(c.RedirectURIs, a.RedirectURI) {
		return c, fmt.Errorf("%w: redirect_uri was not registered", ErrInvalidRequest)
	}
	if a.Method != "S256" || len(a.CodeChallenge) < 43 {
		return c, fmt.Errorf("%w: PKCE with S256 is required", ErrInvalidRequest)
	}
	if a.Resource != "" && a.Resource != s.ResourceURL() && a.Resource != s.issuer {
		return c, fmt.Errorf("%w: unknown resource", ErrInvalidRequest)
	}
	return c, nil
}

// Authorize redirects the browser to the consent page in the admin panel,
// which handles sign-in and calls Approve.
func (s *Server) Authorize(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	if q.Get("response_type") != "code" {
		http.Error(w, "response_type must be code", http.StatusBadRequest)
		return
	}
	a := AuthRequest{ClientID: q.Get("client_id"), RedirectURI: q.Get("redirect_uri"), CodeChallenge: q.Get("code_challenge"),
		Method: q.Get("code_challenge_method"), State: q.Get("state"), Resource: q.Get("resource")}
	if _, err := s.Check(r.Context(), a); err != nil {
		// Never redirect to an unverified URI; show the error here instead.
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Always our own consent page; only the (re-encoded) query varies.
	http.Redirect(w, r, "/oauth/consent?"+q.Encode(), http.StatusFound) //nolint:gosec // G710: fixed same-origin path
}

// Approve issues an authorization code after the signed-in user agreed to
// connect workspace ws, and returns the URL to send the browser to. deny
// returns an access_denied URL.
func (s *Server) Approve(ctx context.Context, userID, ws int64, a AuthRequest, approve bool) (string, error) {
	if _, err := s.Check(ctx, a); err != nil {
		return "", err
	}
	u, _ := url.Parse(a.RedirectURI)
	q := u.Query()
	if a.State != "" {
		q.Set("state", a.State)
	}
	q.Set("iss", s.issuer)
	if !approve {
		q.Set("error", "access_denied")
		u.RawQuery = q.Encode()
		return u.String(), nil
	}
	code := random(32)
	_, err := s.db.Exec(ctx, `INSERT INTO oauth_codes (code_hash, client_id, user_id, redirect_uri, code_challenge, resource, expires_at, workspace_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`, hash(code), a.ClientID, userID, a.RedirectURI, a.CodeChallenge, a.Resource, s.now().Add(codeTTL), ws)
	if err != nil {
		return "", err
	}
	q.Set("code", code)
	u.RawQuery = q.Encode()
	return u.String(), nil
}

// Token implements the token endpoint (form-encoded, public clients).
func (s *Server) Token(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		oauthError(w, http.StatusBadRequest, "invalid_request", "")
		return
	}
	ctx := r.Context()
	clientID := r.PostForm.Get("client_id")
	switch r.PostForm.Get("grant_type") {
	case "authorization_code":
		code := hash(r.PostForm.Get("code"))
		var userID int64
		var ws *int64
		var cid, redirect, challenge string
		var expires time.Time
		err := s.db.QueryRow(ctx, `UPDATE oauth_codes SET used_at = now() WHERE code_hash = $1 AND used_at IS NULL
			RETURNING client_id, user_id, redirect_uri, code_challenge, expires_at, workspace_id`, code).
			Scan(&cid, &userID, &redirect, &challenge, &expires, &ws)
		if errors.Is(err, pgx.ErrNoRows) {
			// Unknown, or used before: a replayed code may be stolen, so
			// revoke the tokens it produced.
			var used string
			if s.db.QueryRow(ctx, `SELECT client_id FROM oauth_codes WHERE code_hash = $1`, code).Scan(&used) == nil {
				_, _ = s.db.Exec(ctx, `DELETE FROM oauth_tokens WHERE client_id = $1`, used)
			}
			oauthError(w, http.StatusBadRequest, "invalid_grant", "the code is invalid or already used")
			return
		}
		if err != nil || s.now().After(expires) || cid != clientID || redirect != r.PostForm.Get("redirect_uri") || ws == nil {
			oauthError(w, http.StatusBadRequest, "invalid_grant", "the code is invalid or expired")
			return
		}
		sum := sha256.Sum256([]byte(r.PostForm.Get("code_verifier")))
		if subtle.ConstantTimeCompare([]byte(base64.RawURLEncoding.EncodeToString(sum[:])), []byte(challenge)) != 1 {
			oauthError(w, http.StatusBadRequest, "invalid_grant", "PKCE verification failed")
			return
		}
		s.issue(ctx, w, cid, userID, *ws)
	case "refresh_token":
		var userID int64
		var ws *int64
		var cid string
		err := s.db.QueryRow(ctx, `DELETE FROM oauth_tokens WHERE token_hash = $1 AND kind = 'refresh' AND expires_at > now()
			RETURNING client_id, user_id, workspace_id`, hash(r.PostForm.Get("refresh_token"))).Scan(&cid, &userID, &ws)
		if err != nil || cid != clientID || ws == nil {
			oauthError(w, http.StatusBadRequest, "invalid_grant", "the refresh token is invalid or expired")
			return
		}
		s.issue(ctx, w, cid, userID, *ws)
	default:
		oauthError(w, http.StatusBadRequest, "unsupported_grant_type", "")
	}
}

func (s *Server) issue(ctx context.Context, w http.ResponseWriter, clientID string, userID, ws int64) {
	access, refresh := "hat_"+random(32), "hrt_"+random(32)
	now := s.now()
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		for _, t := range []struct {
			v, kind string
			ttl     time.Duration
		}{{access, "access", accessTTL}, {refresh, "refresh", refreshTTL}} {
			if _, err := tx.Exec(ctx, `INSERT INTO oauth_tokens (token_hash, kind, client_id, user_id, expires_at, workspace_id) VALUES ($1, $2, $3, $4, $5, $6)`,
				hash(t.v), t.kind, clientID, userID, now.Add(t.ttl), ws); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		s.log.Error("oauth issue", "err", err)
		oauthError(w, http.StatusInternalServerError, "server_error", "")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"access_token": access, "token_type": "Bearer", "expires_in": int(accessTTL.Seconds()),
		"refresh_token": refresh, "scope": "agnts",
	})
}

// staticKey names the settings row (in a workspace) holding a person's
// static token hash; the row without a user is the one from before
// workspaces and acts as the workspace's owner.
const staticKey = "mcp_static_token"

func staticKeyFor(userID int64) string { return staticKey + ":" + strconv.FormatInt(userID, 10) }

// Principal is who an MCP token acts as, and where.
type Principal struct {
	UserID      int64
	WorkspaceID int64
	Expires     time.Time
}

// Verify returns who an OAuth access token or a static MCP token acts as.
// It reads every workspace's tokens (call it with a system context).
func (s *Server) Verify(ctx context.Context, token string) (Principal, bool) {
	if token == "" {
		return Principal{}, false
	}
	var p Principal
	var ws *int64
	if err := s.db.QueryRow(ctx, `SELECT user_id, workspace_id, expires_at FROM oauth_tokens
		WHERE token_hash = $1 AND kind = 'access' AND expires_at > now()`, hash(token)).Scan(&p.UserID, &ws, &p.Expires); err == nil {
		if ws == nil {
			return Principal{}, false
		}
		p.WorkspaceID = *ws
		return p, true
	}
	if !strings.HasPrefix(token, "hmt_") {
		return Principal{}, false
	}
	var key string
	err := s.db.QueryRow(ctx, `SELECT s.workspace_id, s.key FROM settings s WHERE (s.key = $1 OR s.key LIKE $1 || ':%')
		AND s.value #>> '{}' = $2 LIMIT 1`, staticKey, hex.EncodeToString(hash(token))).Scan(&p.WorkspaceID, &key)
	if err != nil {
		return Principal{}, false
	}
	if uid, ok := strings.CutPrefix(key, staticKey+":"); ok {
		id, err := strconv.ParseInt(uid, 10, 64)
		if err != nil {
			return Principal{}, false
		}
		p.UserID = id
	} else if err := s.db.QueryRow(ctx, `SELECT COALESCE(owner_id, 0) FROM workspaces WHERE id = $1`, p.WorkspaceID).Scan(&p.UserID); err != nil || p.UserID == 0 {
		return Principal{}, false
	}
	// The person must still be a member.
	var member bool
	if err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM memberships WHERE workspace_id = $1 AND user_id = $2)`,
		p.WorkspaceID, p.UserID).Scan(&member); err != nil || !member {
		return Principal{}, false
	}
	p.Expires = s.now().Add(24 * time.Hour)
	return p, true
}

// RotateStatic creates a new static token for the person acting in the
// workspace ctx acts in (shown once) and returns it.
func (s *Server) RotateStatic(ctx context.Context, userID int64) (string, error) {
	tok := "hmt_" + random(32)
	_, err := s.db.Exec(ctx, `INSERT INTO settings (key, value) VALUES ($1, to_jsonb($2::text))
		ON CONFLICT (workspace_id, key) DO UPDATE SET value = to_jsonb($2::text), updated_at = now()`, staticKeyFor(userID), hex.EncodeToString(hash(tok)))
	return tok, err
}

// Status reports the person's static token and live OAuth connections in
// the workspace ctx acts in.
func (s *Server) Status(ctx context.Context, userID, ws int64) (static bool, connections int, err error) {
	var v string
	err = s.db.QueryRow(ctx, `SELECT COALESCE((SELECT value #>> '{}' FROM settings WHERE key = $1), '')`, staticKeyFor(userID)).Scan(&v)
	if err != nil {
		return false, 0, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(DISTINCT client_id) FROM oauth_tokens WHERE kind = 'refresh' AND expires_at > now()
		AND user_id = $1 AND workspace_id = $2`, userID, ws).Scan(&connections)
	return v != "", connections, err
}

// RevokeAll disconnects the person's Claude connections in a workspace and
// removes their static token there.
func (s *Server) RevokeAll(ctx context.Context, userID, ws int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM oauth_tokens WHERE user_id = $1 AND workspace_id = $2`, userID, ws); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `DELETE FROM oauth_codes WHERE user_id = $1 AND workspace_id = $2`, userID, ws); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `DELETE FROM settings WHERE key = $1`, staticKeyFor(userID))
		return err
	})
}

// Prune removes expired codes and tokens.
func (s *Server) Prune(ctx context.Context) {
	_, _ = s.db.Exec(ctx, `DELETE FROM oauth_codes WHERE expires_at < now() - interval '1 day'`)
	_, _ = s.db.Exec(ctx, `DELETE FROM oauth_tokens WHERE expires_at < now()`)
}
