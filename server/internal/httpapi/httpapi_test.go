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

	"hiro/internal/auth"
	"hiro/internal/auth/authtest"
	"hiro/internal/secret"
)

type pinger struct{ err error }

func (p pinger) Ping(context.Context) error { return p.err }

type harness struct {
	h       http.Handler
	seed    string
	tickets *fakeTickets
}

const password = "a long enough password"

func newHarness(t *testing.T, db Pinger) *harness {
	t.Helper()
	box, err := secret.NewBox(bytes.Repeat([]byte{9}, 32))
	if err != nil {
		t.Fatal(err)
	}
	svc, err := auth.New(&authtest.Users{}, &authtest.Sessions{}, box, time.Hour)
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
	pub, _ := url.Parse("https://hiro.example.com")
	h.tickets = &fakeTickets{}
	h.h, err = NewHandler(Options{
		Auth:         svc,
		Tickets:      h.tickets,
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
	got, err := publicRoutes()
	if err != nil {
		t.Fatal(err)
	}
	want := map[string]bool{"POST /api/auth/login": true, "GET /api/meta": true}
	if len(got) != len(want) {
		t.Fatalf("public routes = %v, want %v", got, want)
	}
	for k := range want {
		if !got[k] {
			t.Errorf("%s should be public", k)
		}
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
	if rec := h.do("POST", "/api/auth/login", body, map[string]string{"Origin": "https://hiro.example.com"}); rec.Code != http.StatusOK {
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
