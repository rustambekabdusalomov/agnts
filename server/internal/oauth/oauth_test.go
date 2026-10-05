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
	"os"
	"strings"
	"testing"

	"hiro/internal/store/postgres"
)

func setup(t *testing.T) (*Server, int64) {
	t.Helper()
	dsn := os.Getenv("HIRO_TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("HIRO_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, dsn)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if err := postgres.Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	_, _ = pool.Exec(ctx, `TRUNCATE oauth_clients, oauth_codes, oauth_tokens CASCADE`)
	_, _ = pool.Exec(ctx, `DELETE FROM settings WHERE key = 'mcp_static_token'`)
	var uid int64
	if err := pool.QueryRow(ctx, `INSERT INTO users (username, password_hash, totp_secret_enc) VALUES ('oauth-user', 'h', '\x01')
		ON CONFLICT (username) DO UPDATE SET username = EXCLUDED.username RETURNING id`).Scan(&uid); err != nil {
		t.Fatal(err)
	}
	return New(pool, "https://hiro.example.com", []string{"claude.ai", "claude.com"}, log), uid
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
	s, uid := setup(t)
	ctx := context.Background()

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
	denied, err := s.Approve(ctx, uid, ar, false)
	if err != nil || !strings.Contains(denied, "error=access_denied") || strings.Contains(denied, "code=") {
		t.Fatalf("deny: %s %v", denied, err)
	}

	target, err := s.Approve(ctx, uid, ar, true)
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

	target, _ = s.Approve(ctx, uid, ar, true)
	u, _ = url.Parse(target)
	code = u.Query().Get("code")
	c, tok := exchange(verifier)
	if c != http.StatusOK {
		t.Fatalf("token: %d %v", c, tok)
	}
	access, refresh := tok["access_token"].(string), tok["refresh_token"].(string)
	if !s.Verify(ctx, access) || s.Verify(ctx, refresh) || s.Verify(ctx, "nope") {
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
	if s.Verify(ctx, tok2["access_token"].(string)) {
		t.Fatal("tokens survived a code replay")
	}

	static, err := s.RotateStatic(ctx)
	if err != nil || !s.Verify(ctx, static) {
		t.Fatalf("static: %v", err)
	}
	newer, _ := s.RotateStatic(ctx)
	if s.Verify(ctx, static) || !s.Verify(ctx, newer) {
		t.Fatal("rotation did not replace the static token")
	}
	if err := s.RevokeAll(ctx); err != nil || s.Verify(ctx, newer) {
		t.Fatal("revoke all")
	}
}
