package oauth

import (
	"context"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/store/postgres/pgtest"
)

func setup(t *testing.T) (*Server, int64, context.Context, int64) {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Exec(t, pool, `TRUNCATE oauth_clients, oauth_codes, oauth_tokens CASCADE`)
	pgtest.Exec(t, pool, `DELETE FROM settings WHERE key LIKE 'mcp_static_token%'`)
	ctx, ws := pgtest.Workspace(t, pool, "oauth")
	uid := pgtest.User(t, pool, "oauth-user")
	pgtest.Exec(t, pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'user') ON CONFLICT DO NOTHING`, ws, uid)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	return New(pool, "https://agnts.example.com", []string{"claude.ai", "claude.com"}, log), uid, ctx, ws
}

func form(h http.HandlerFunc, v url.Values) (int, map[string]any) {
	req := httptest.NewRequest("POST", "/oauth/token", strings.NewReader(v.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	h(rec, req)
	var out map[string]any
	_ = json.Unmarshal(rec.Body.Bytes(), &out)
	return rec.Code, out
}

func TestFullFlow(t *testing.T) {
	s, uid, wctx, ws := setup(t)
	ctx := domain.System(context.Background())
	verify := func(tok string) bool {
		p, ok := s.Verify(ctx, tok)
		return ok && p.UserID == uid && p.WorkspaceID == ws
	}

	// Registration: only allowed redirect hosts.
	reg := func(uri string) (int, map[string]any) {
		body := `{"client_name":"Claude","redirect_uris":["` + uri + `"]}`
		rec := httptest.NewRecorder()
		s.Register(rec, httptest.NewRequest("POST", "/oauth/register", strings.NewReader(body)))
		var out map[string]any
		_ = json.Unmarshal(rec.Body.Bytes(), &out)
		return rec.Code, out
	}
	if c, _ := reg("https://evil.example/cb"); c != http.StatusBadRequest {
		t.Fatalf("foreign redirect registered: %d", c)
	}
	if c, _ := reg("http://claude.ai/cb"); c != http.StatusBadRequest {
		t.Fatalf("http redirect registered: %d", c)
	}
	c, out := reg("https://claude.ai/api/mcp/auth_callback")
	if c != http.StatusCreated {
		t.Fatalf("register: %d %v", c, out)
	}
	clientID := out["client_id"].(string)

	verifier := strings.Repeat("v", 50)
	sum := sha256.Sum256([]byte(verifier))
	ar := AuthRequest{ClientID: clientID, RedirectURI: "https://claude.ai/api/mcp/auth_callback",
		CodeChallenge: base64.RawURLEncoding.EncodeToString(sum[:]), Method: "S256", State: "xyz", Resource: s.ResourceURL()}

	bad := ar
	bad.RedirectURI = "https://claude.ai/other"
	if _, err := s.Check(ctx, bad); !errors.Is(err, ErrInvalidRequest) {
		t.Fatal("unregistered redirect accepted")
	}
	plain := ar
	plain.Method = "plain"
	if _, err := s.Check(ctx, plain); !errors.Is(err, ErrInvalidRequest) {
		t.Fatal("plain PKCE accepted")
	}

	// Denied: redirect carries access_denied and no code.
	denied, err := s.Approve(ctx, uid, ws, ar, false)
	if err != nil || !strings.Contains(denied, "error=access_denied") || strings.Contains(denied, "code=") {
		t.Fatalf("deny: %s %v", denied, err)
	}

	target, err := s.Approve(ctx, uid, ws, ar, true)
	if err != nil {
		t.Fatal(err)
	}
	u, _ := url.Parse(target)
	code := u.Query().Get("code")
	if code == "" || u.Query().Get("state") != "xyz" {
		t.Fatalf("redirect: %s", target)
	}

	exchange := func(verifier string) (int, map[string]any) {
		return form(s.Token, url.Values{"grant_type": {"authorization_code"}, "code": {code}, "client_id": {clientID},
			"redirect_uri": {ar.RedirectURI}, "code_verifier": {verifier}})
	}
	if c, _ := exchange("wrong-verifier-wrong-verifier-wrong-verifier-123"); c != http.StatusBadRequest {
		t.Fatalf("wrong verifier: %d", c)
	}
	// The failed attempt used the code; the real client must start over.
	if c, _ := exchange(verifier); c != http.StatusBadRequest {
		t.Fatalf("a used code was accepted: %d", c)
	}

	target, _ = s.Approve(ctx, uid, ws, ar, true)
	u, _ = url.Parse(target)
	code = u.Query().Get("code")
	c, tok := exchange(verifier)
	if c != http.StatusOK {
		t.Fatalf("token: %d %v", c, tok)
	}
	access, refresh := tok["access_token"].(string), tok["refresh_token"].(string)
	if !verify(access) || verify(refresh) || verify("nope") {
		t.Fatal("verify")
	}

	// Refresh rotates: the old refresh token stops working.
	c, tok2 := form(s.Token, url.Values{"grant_type": {"refresh_token"}, "refresh_token": {refresh}, "client_id": {clientID}})
	if c != http.StatusOK || tok2["access_token"] == access {
		t.Fatalf("refresh: %d %v", c, tok2)
	}
	if c, _ := form(s.Token, url.Values{"grant_type": {"refresh_token"}, "refresh_token": {refresh}, "client_id": {clientID}}); c != http.StatusBadRequest {
		t.Fatal("refresh token reused")
	}

	// Replaying the code revokes what it produced.
	if c, _ := exchange(verifier); c != http.StatusBadRequest {
		t.Fatal("code replay accepted")
	}
	if verify(tok2["access_token"].(string)) {
		t.Fatal("tokens survived a code replay")
	}

	static, err := s.RotateStatic(wctx, uid)
	if err != nil || !verify(static) {
		t.Fatalf("static: %v", err)
	}
	newer, _ := s.RotateStatic(wctx, uid)
	if verify(static) || !verify(newer) {
		t.Fatal("rotation did not replace the static token")
	}
	if on, _, err := s.Status(wctx, uid, ws); err != nil || !on {
		t.Fatalf("status: %v %v", on, err)
	}
	if err := s.RevokeAll(wctx, uid, ws); err != nil || verify(newer) {
		t.Fatal("revoke all")
	}
}
