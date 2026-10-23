package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"

	"agnts/internal/accounts"
	"agnts/internal/auth"
	"agnts/internal/auth/authtest"
	"agnts/internal/domain"
	"agnts/internal/google"
	"agnts/internal/secret"
)

type pinger struct{ err error }

func (p pinger) Ping(context.Context) error { return p.err }

type harness struct {
	h          http.Handler
	seed       string
	tickets    *fakeTickets
	workspaces *fakeWorkspaces
	assistant  *fakeAssistant
	swagger    *fakeSwagger
	runs       *fakeRunHistory
	links      *fakeLinks
	// hookWS and hookID are what the test webhook last saw.
	hookWS int64
	hookID string
}

// fakeUsers is the UserStore over the auth test store.
type fakeUsers struct{ *authtest.Users }

func (f fakeUsers) List(ctx context.Context) ([]domain.User, error) {
	var out []domain.User
	for id := int64(1); ; id++ {
		u, err := f.ByID(ctx, id)
		if err != nil {
			return out, nil
		}
		out = append(out, u)
	}
}

func (f fakeUsers) SetAdmin(context.Context, int64, bool) error { return nil }

func (f fakeUsers) LastSignIns(context.Context) (map[int64]time.Time, error) {
	return map[int64]time.Time{1: time.Date(2026, 10, 8, 9, 0, 0, 0, time.UTC)}, nil
}

const password = "a long enough password"

func newHarness(t *testing.T, db Pinger) *harness {
	t.Helper()
	box, err := secret.NewBox(bytes.Repeat([]byte{9}, 32))
	if err != nil {
		t.Fatal(err)
	}
	users := &authtest.Users{}
	svc, err := auth.New(users, &authtest.Sessions{}, box, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	e, err := svc.BeginEnrollment("rustam")
	if err != nil {
		t.Fatal(err)
	}
	h := &harness{seed: e.Secret}
	if _, err := svc.CreateUser(context.Background(), e, password, h.code(t, 0)); err != nil {
		t.Fatal(err)
	}
	pub, _ := url.Parse("https://agnts.example.com")
	site, _ := url.Parse("https://agnts.example.org")
	h.tickets = &fakeTickets{}
	h.workspaces = newFakeWorkspaces()
	h.assistant = &fakeAssistant{}
	h.swagger = &fakeSwagger{}
	h.runs = newFakeRunHistory()
	h.links = &fakeLinks{}
	h.h, err = NewHandler(Options{
		CommitLinks: h.links,
		Auth:        svc,
		Tickets:     h.tickets,
		Assistant:   h.assistant,
		Swagger:     h.swagger,
		Suites:      h.swagger,
		Workspaces:  h.workspaces,
		Users:       fakeUsers{users},
		Feedback:    &fakeFeedback{},
		RunHistory:  h.runs,
		SiteURL:     site,
		Webhooks: map[string]http.Handler{"test": http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			h.hookWS, h.hookID = domain.WorkspaceOf(r.Context()), domain.HookOf(r.Context())
			w.WriteHeader(http.StatusOK)
		})},
		DB:           db,
		Log:          slog.New(slog.NewTextHandler(io.Discard, nil)),
		PublicURL:    pub,
		CookieSecure: true,
		Version:      "test",
		Commit:       "abc",
	})
	if err != nil {
		t.Fatal(err)
	}
	return h
}

// code returns the TOTP code for now + steps*30s. Enrollment uses step 0,
// so a sign-in must use step 1 (still inside the allowed skew).
func (h *harness) code(t *testing.T, steps int) string {
	t.Helper()
	c, err := totp.GenerateCodeCustom(h.seed, time.Now().Add(time.Duration(steps)*30*time.Second),
		totp.ValidateOpts{Period: 30, Digits: otp.DigitsSix, Algorithm: otp.AlgorithmSHA1})
	if err != nil {
		t.Fatal(err)
	}
	return c
}

func (h *harness) do(method, path, body string, hdr map[string]string) *httptest.ResponseRecorder {
	var r io.Reader
	if body != "" {
		r = strings.NewReader(body)
	}
	req := httptest.NewRequest(method, path, r)
	req.RemoteAddr = "203.0.113.7:5555"
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	for k, v := range hdr {
		req.Header.Set(k, v)
	}
	rec := httptest.NewRecorder()
	h.h.ServeHTTP(rec, req)
	return rec
}

func loginBody(username, pw, code, client string) string {
	b, _ := json.Marshal(map[string]string{"username": username, "password": pw, "code": code, "client": client})
	return string(b)
}

func TestPublicRoutesComeFromSpec(t *testing.T) {
	ops, err := operations()
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]bool{}
	for k, op := range ops {
		if op.public {
			got[k] = true
		}
	}
	want := map[string]bool{"POST /api/auth/login": true, "GET /api/meta": true, "GET /api/auth/signup": true, "POST /api/auth/signup": true,
		"POST /api/auth/verify": true, "POST /api/auth/password/forgot": true, "POST /api/auth/login/totp": true, "POST /api/auth/password/reset": true, "GET /api/invites/{token}": true,
		"POST /api/auth/google": true,
		// Public documents: a guest of the link reads and downloads them (the
		// handlers check the guest's own token).
		"GET /api/public/documents/{token}": true, "GET /api/public/documents/{token}/download": true,
		// Guests of a public link: they say who they are, then comment and are seen.
		"GET /api/public/documents/{token}/info": true, "POST /api/public/documents/{token}/guest": true,
		"GET /api/public/documents/{token}/comments": true, "POST /api/public/documents/{token}/comments": true,
		"PATCH /api/public/documents/{token}/comments/{commentId}": true, "DELETE /api/public/documents/{token}/comments/{commentId}": true,
		"POST /api/public/documents/{token}/presence": true}
	if len(got) != len(want) {
		t.Fatalf("public routes = %v, want %v", got, want)
	}
	for k := range want {
		if !got[k] {
			t.Errorf("%s should be public", k)
		}
	}
	// Every public operation is about accounts, never a workspace's data.
	for k := range got {
		if ops[k].scope != "user" && k != "GET /api/meta" {
			t.Errorf("%s is public but scoped %q", k, ops[k].scope)
		}
	}
	if op := ops["PUT /api/settings"]; op.scope != "workspace" || op.role != "owner" {
		t.Errorf("settings: %+v", op)
	}
	if op := ops["GET /api/platform/overview"]; op.scope != "admin" {
		t.Errorf("platform overview: %+v", op)
	}
}

func TestPrivateByDefault(t *testing.T) {
	h := newHarness(t, pinger{})
	if rec := h.do("GET", "/api/auth/me", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("/auth/me without session: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/auth/logout", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("/auth/logout without session: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/auth/me", "", map[string]string{"Authorization": "Bearer nope"}); rec.Code != http.StatusUnauthorized {
		t.Fatalf("/auth/me with bad token: %d", rec.Code)
	}
	rec := h.do("GET", "/api/meta", "", nil)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"version":"test"`) {
		t.Fatalf("/meta: %d %s", rec.Code, rec.Body)
	}
}

func TestWebLoginSessionLogout(t *testing.T) {
	h := newHarness(t, pinger{})

	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("login: %d %s", rec.Code, rec.Body)
	}
	if strings.Contains(rec.Body.String(), `"token"`) {
		t.Fatal("web login must not return the token in the body")
	}
	cookies := rec.Result().Cookies()
	if len(cookies) != 1 || cookies[0].Name != SessionCookie || !cookies[0].HttpOnly || !cookies[0].Secure ||
		cookies[0].SameSite != http.SameSiteStrictMode {
		t.Fatalf("session cookie: %+v", cookies)
	}
	cookie := map[string]string{"Cookie": SessionCookie + "=" + cookies[0].Value}

	rec = h.do("GET", "/api/auth/me", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"username":"rustam"`) {
		t.Fatalf("/me: %d %s", rec.Code, rec.Body)
	}

	rec = h.do("POST", "/api/auth/logout", "", cookie)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("logout: %d", rec.Code)
	}
	if c := rec.Result().Cookies(); len(c) != 1 || c[0].MaxAge >= 0 {
		t.Fatalf("logout should clear the cookie: %+v", c)
	}
	if rec := h.do("GET", "/api/auth/me", "", cookie); rec.Code != http.StatusUnauthorized {
		t.Fatalf("/me after logout: %d", rec.Code)
	}
}

func TestMobileLoginReturnsBearerToken(t *testing.T) {
	h := newHarness(t, pinger{})
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "mobile"), nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("login: %d %s", rec.Code, rec.Body)
	}
	if len(rec.Result().Cookies()) != 0 {
		t.Fatal("mobile login must not set a cookie")
	}
	var resp struct{ Token string }
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil || resp.Token == "" {
		t.Fatalf("token missing: %s", rec.Body)
	}
	rec = h.do("GET", "/api/auth/me", "", map[string]string{"Authorization": "Bearer " + resp.Token})
	if rec.Code != http.StatusOK {
		t.Fatalf("/me with bearer: %d", rec.Code)
	}
}

func TestLoginErrors(t *testing.T) {
	h := newHarness(t, pinger{})
	cases := []struct {
		name string
		body string
		want int
	}{
		{"malformed json", "{", http.StatusBadRequest},
		{"unknown field", `{"username":"rustam","extra":1}`, http.StatusBadRequest},
		{"short code", loginBody("rustam", password, "123", "web"), http.StatusBadRequest},
		{"bad client", loginBody("rustam", password, "123456", "desktop"), http.StatusBadRequest},
		{"wrong password", loginBody("rustam", "nope", h.code(t, 1), "web"), http.StatusUnauthorized},
	}
	for _, c := range cases {
		if rec := h.do("POST", "/api/auth/login", c.body, nil); rec.Code != c.want {
			t.Errorf("%s: got %d, want %d (%s)", c.name, rec.Code, c.want, rec.Body)
		}
	}
}

func TestLoginRateLimit(t *testing.T) {
	h := newHarness(t, pinger{})
	body := loginBody("rustam", "wrong", "123456", "web")
	for i := range 5 {
		if rec := h.do("POST", "/api/auth/login", body, nil); rec.Code != http.StatusUnauthorized {
			t.Fatalf("attempt %d: %d", i+1, rec.Code)
		}
	}
	rec := h.do("POST", "/api/auth/login", body, nil)
	if rec.Code != http.StatusTooManyRequests || rec.Header().Get("Retry-After") == "" {
		t.Fatalf("6th attempt: %d, Retry-After=%q", rec.Code, rec.Header().Get("Retry-After"))
	}
	// A different client IP has its own budget.
	rec = h.do("POST", "/api/auth/login", body, map[string]string{"X-Forwarded-For": "198.51.100.1"})
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("other IP: %d", rec.Code)
	}
}

func TestCrossOriginWritesRejected(t *testing.T) {
	h := newHarness(t, pinger{})
	body := loginBody("rustam", password, h.code(t, 1), "web")
	if rec := h.do("POST", "/api/auth/login", body, map[string]string{"Origin": "https://evil.example"}); rec.Code != http.StatusForbidden {
		t.Fatalf("foreign Origin: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/auth/login", body, map[string]string{"Sec-Fetch-Site": "cross-site"}); rec.Code != http.StatusForbidden {
		t.Fatalf("cross-site fetch: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/auth/login", body, map[string]string{"Origin": "https://agnts.example.com"}); rec.Code != http.StatusOK {
		t.Fatalf("same origin: %d %s", rec.Code, rec.Body)
	}
}

func TestClientIPUsesRightmostForwardedFor(t *testing.T) {
	var got string
	h := clientIP(http.HandlerFunc(func(_ http.ResponseWriter, r *http.Request) { got = r.RemoteAddr }))
	for _, c := range []struct{ remote, xff, want string }{
		{"10.0.0.2:1234", "", "10.0.0.2"},
		{"10.0.0.2:1234", "203.0.113.9", "203.0.113.9"},
		{"10.0.0.2:1234", "1.2.3.4, 203.0.113.9", "203.0.113.9"}, // client-supplied 1.2.3.4 ignored
		{"10.0.0.2:1234", "garbage", "10.0.0.2"},
	} {
		req := httptest.NewRequest("GET", "/", nil)
		req.RemoteAddr = c.remote
		if c.xff != "" {
			req.Header.Set("X-Forwarded-For", c.xff)
		}
		h.ServeHTTP(httptest.NewRecorder(), req)
		if got != c.want {
			t.Errorf("remote=%s xff=%q: got %s, want %s", c.remote, c.xff, got, c.want)
		}
	}
}

func TestHealthz(t *testing.T) {
	if rec := newHarness(t, pinger{}).do("GET", "/healthz", "", nil); rec.Code != http.StatusOK {
		t.Fatalf("healthy: %d", rec.Code)
	}
	if rec := newHarness(t, pinger{errors.New("down")}).do("GET", "/healthz", "", nil); rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("db down: %d", rec.Code)
	}
}

type fakeVerifier map[string]google.Identity

func (f fakeVerifier) Verify(_ context.Context, credential string) (google.Identity, error) {
	if id, ok := f[credential]; ok {
		return id, nil
	}
	return google.Identity{}, google.ErrInvalid
}

type fakeGoogleAccounts struct {
	closed bool
	got    accounts.GoogleInput
}

func (f *fakeGoogleAccounts) SignInWithGoogle(_ context.Context, in accounts.GoogleInput) (accounts.GoogleResult, error) {
	switch {
	case f.closed:
		return accounts.GoogleResult{}, domain.ErrForbidden
	case in.Invite == "expired":
		return accounts.GoogleResult{}, auth.Invalid("this invite link is invalid or expired")
	}
	f.got = in
	res := accounts.GoogleResult{Token: "tok", Session: domain.Session{ExpiresAt: time.Now().Add(time.Hour), Client: in.Client}, User: domain.User{ID: 7, Email: in.Email}}
	if in.Invite == "to-acme" {
		res.Workspace = "acme"
	}
	return res, nil
}

func TestGoogleSignIn(t *testing.T) {
	h := newHarness(t, pinger{})
	acc := &fakeGoogleAccounts{}
	site, _ := url.Parse("https://site.example.com")
	pub, _ := url.Parse("https://agnts.example.com")
	handler, err := NewHandler(Options{
		Auth: nil, Tickets: h.tickets, Workspaces: h.workspaces, DB: pinger{}, PublicURL: pub, CookieSecure: true,
		Log:    slog.New(slog.NewTextHandler(io.Discard, nil)),
		Google: &GoogleSignIn{Verifier: fakeVerifier{"good": {Subject: "1", Email: "dev@gmail.com", Name: "Dev"}}, Accounts: acc, SiteURL: site},
	})
	if err != nil {
		t.Fatal(err)
	}
	ip := "203.0.113.8"
	post := func(credential, origin string, invite ...string) *httptest.ResponseRecorder {
		form := url.Values{"credential": {credential}}
		if len(invite) > 0 {
			form.Set("invite", invite[0])
		}
		req := httptest.NewRequest("POST", "/auth/google", strings.NewReader(form.Encode()))
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		if origin != "" {
			req.Header.Set("Origin", origin)
		}
		req.RemoteAddr = ip
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, req)
		return rec
	}

	// Signed in: the session cookie, then the admin panel.
	rec := post("good", "https://site.example.com")
	if rec.Code != http.StatusSeeOther || rec.Header().Get("Location") != "https://agnts.example.com/" {
		t.Fatalf("sign-in: %d %q", rec.Code, rec.Header().Get("Location"))
	}
	c := rec.Result().Cookies()
	if len(c) != 1 || c[0].Name != SessionCookie || c[0].Value != "tok" || !c[0].HttpOnly || !c[0].Secure {
		t.Fatalf("cookie %+v", c)
	}
	if acc.got.Email != "dev@gmail.com" || acc.got.DisplayName != "Dev" || acc.got.Client != domain.ClientWeb {
		t.Fatalf("signed in as %+v", acc.got)
	}

	// With an invite: straight into the workspace they were invited to.
	if rec := post("good", "https://agnts.example.com", "to-acme"); rec.Header().Get("Location") != "https://agnts.example.com/w/acme/dashboard" || acc.got.Invite != "to-acme" {
		t.Fatalf("invite: %q (invite %q)", rec.Header().Get("Location"), acc.got.Invite)
	}
	if rec := post("good", "https://agnts.example.com", "expired"); rec.Header().Get("Location") != "https://agnts.example.com/login?signin=invite" {
		t.Fatalf("bad invite: %q", rec.Header().Get("Location"))
	}

	// Another site, or no Origin at all, cannot sign a visitor in.
	for _, o := range []string{"https://evil.example", ""} {
		if rec := post("good", o); rec.Code != http.StatusForbidden || len(rec.Result().Cookies()) != 0 {
			t.Fatalf("origin %q: %d", o, rec.Code)
		}
	}
	// A token Google does not vouch for goes back to the website.
	if rec := post("forged", "https://site.example.com"); rec.Header().Get("Location") != "https://site.example.com/?signin=failed" {
		t.Fatalf("forged: %d %q", rec.Code, rec.Header().Get("Location"))
	}
	ip, acc.closed = "203.0.113.9", true
	if rec := post("good", "https://site.example.com"); rec.Header().Get("Location") != "https://site.example.com/?signin=closed" {
		t.Fatalf("closed: %q", rec.Header().Get("Location"))
	}
	// Started on the admin panel's sign-in page: back to it.
	if rec := post("good", "https://agnts.example.com"); rec.Header().Get("Location") != "https://agnts.example.com/login?signin=closed" {
		t.Fatalf("closed from the admin panel: %q", rec.Header().Get("Location"))
	}
	// Five attempts a minute from one address.
	ip, acc.closed = "203.0.113.50", false
	for range 5 {
		post("good", "https://site.example.com")
	}
	if rec := post("good", "https://site.example.com"); rec.Header().Get("Location") != "https://site.example.com/?signin=rate_limited" {
		t.Fatalf("rate limit: %q", rec.Header().Get("Location"))
	}
}

func TestMobileGoogleSignIn(t *testing.T) {
	h := newHarness(t, pinger{})
	acc := &fakeGoogleAccounts{}
	pub, _ := url.Parse("https://agnts.example.com")
	handler, err := NewHandler(Options{
		Auth: nil, Tickets: h.tickets, Workspaces: h.workspaces, DB: pinger{}, PublicURL: pub,
		Log:    slog.New(slog.NewTextHandler(io.Discard, nil)),
		Google: &GoogleSignIn{Verifier: fakeVerifier{"good": {Subject: "1", Email: "dev@gmail.com", Name: "Dev"}}, Accounts: acc},
	})
	if err != nil {
		t.Fatal(err)
	}
	ip := "203.0.113.20"
	post := func(body string) *httptest.ResponseRecorder {
		req := httptest.NewRequest("POST", "/api/auth/google", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		req.RemoteAddr = ip
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, req)
		return rec
	}

	// Signed in: a mobile session, with the token in the body and no cookie.
	rec := post(`{"idToken":"good"}`)
	if rec.Code != http.StatusOK {
		t.Fatalf("sign-in: %d %s", rec.Code, rec.Body)
	}
	var out struct {
		Token string `json:"token"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil || out.Token != "tok" || len(rec.Result().Cookies()) != 0 {
		t.Fatalf("response %s, cookies %v", rec.Body, rec.Result().Cookies())
	}
	if acc.got.Email != "dev@gmail.com" || acc.got.Client != domain.ClientMobile {
		t.Fatalf("signed in as %+v", acc.got)
	}
	if rec := post(`{"idToken":"good","invite":"to-acme"}`); rec.Code != http.StatusOK || acc.got.Invite != "to-acme" {
		t.Fatalf("invite: %d (invite %q)", rec.Code, acc.got.Invite)
	}

	// A token Google does not vouch for, an empty one, and closed sign-up.
	if rec := post(`{"idToken":"forged"}`); rec.Code != http.StatusUnauthorized {
		t.Fatalf("forged: %d", rec.Code)
	}
	if rec := post(`{}`); rec.Code != http.StatusBadRequest {
		t.Fatalf("empty: %d", rec.Code)
	}
	acc.closed = true
	if rec := post(`{"idToken":"good"}`); rec.Code != http.StatusForbidden || !strings.Contains(rec.Body.String(), "signup_closed") {
		t.Fatalf("closed: %d %s", rec.Code, rec.Body)
	}
}

func TestMobileGoogleSignInOff(t *testing.T) {
	h := newHarness(t, pinger{})
	pub, _ := url.Parse("https://agnts.example.com")
	handler, err := NewHandler(Options{Tickets: h.tickets, Workspaces: h.workspaces, DB: pinger{}, PublicURL: pub, Log: slog.New(slog.NewTextHandler(io.Discard, nil))})
	if err != nil {
		t.Fatal(err)
	}
	req := httptest.NewRequest("POST", "/api/auth/google", strings.NewReader(`{"idToken":"x"}`))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("off: %d %s", rec.Code, rec.Body)
	}
}
