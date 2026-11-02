package domain

import (
	"regexp"
	"strings"
	"testing"
	"time"
)

var t0 = time.Date(2026, 11, 2, 9, 0, 0, 0, time.UTC)

// lines makes one entry per line, 1 ms apart, as Loki returns a stack
// trace that was written line by line.
func lines(stream string, text string) []LogEntry {
	var out []LogEntry
	for i, l := range strings.Split(text, "\n") {
		out = append(out, LogEntry{Time: t0.Add(time.Duration(i) * time.Millisecond), Service: stream, Stream: stream, Message: l})
	}
	return out
}

const goPanic = `panic: assignment to entry in nil map

goroutine 42 [running]:
main.applyCoupon(0xc000123456, {0xc0000140a0, 0x5})
	/app/billing/coupon.go:88 +0x1d
main.(*Server).checkout(0xc000010000, {0x7f1, 0xc000222000}, 0xc000333000)
	/app/billing/server.go:120 +0x8b
net/http.HandlerFunc.ServeHTTP(0x0?, {0x7f1?, 0xc000222000?}, 0x0?)
	/usr/local/go/src/net/http/server.go:2136 +0x29
exit status 2`

const goPanic2 = `panic: assignment to entry in nil map

goroutine 7 [running]:
main.applyCoupon(0xc000999999, {0xc0000150b0, 0x9})
	/app/billing/coupon.go:91 +0x1d
main.(*Server).checkout(0xc000011111, {0x7f1, 0xc000555000}, 0xc000666000)
	/app/billing/server.go:124 +0x8b
net/http.HandlerFunc.ServeHTTP(0x0?, {0x7f1?, 0xc000222000?}, 0x0?)
	/usr/local/go/src/net/http/server.go:2136 +0x29`

const pyTrace = `ERROR:app:checkout failed
Traceback (most recent call last):
  File "/app/shop/views.py", line 42, in checkout
    total = price / qty
ZeroDivisionError: division by zero`

const javaTrace = `Exception in thread "main" java.lang.IllegalStateException: cart is empty
	at com.acme.shop.Cart.checkout(Cart.java:57)
	at com.acme.shop.Main.main(Main.java:12)
Caused by: java.lang.NullPointerException
	at com.acme.shop.Cart.total(Cart.java:33)
	... 2 more`

func detectAll(t *testing.T, entries []LogEntry, r LogRules) []LogHit {
	t.Helper()
	var hits []LogHit
	for _, ev := range FrameLogs(entries, LogFields{}) {
		if !PassesLogPrefilter(ev, nil) {
			continue
		}
		hits = append(hits, DetectLog(ev, r)...)
	}
	return hits
}

func TestFrameGoPanic(t *testing.T) {
	evs := FrameLogs(lines("api", goPanic), LogFields{})
	if len(evs) != 1 {
		t.Fatalf("events = %d, want 1 (lines joined)", len(evs))
	}
	hits := DetectLog(evs[0], LogRules{})
	if len(hits) != 1 || hits[0].Detector != "panic" || hits[0].Severity != LogHigh {
		t.Fatalf("hits = %+v", hits)
	}
	if hits[0].Title != "panic: assignment to entry in nil map" {
		t.Errorf("title = %q", hits[0].Title)
	}
	other := detectAll(t, lines("api", goPanic2), LogRules{})
	if len(other) != 1 || other[0].Fingerprint != hits[0].Fingerprint {
		t.Errorf("same panic with other addresses, goroutine and lines must share a fingerprint")
	}
}

func TestDifferentPanicsDiffer(t *testing.T) {
	a := detectAll(t, lines("api", goPanic), LogRules{})
	b := detectAll(t, lines("api", strings.Replace(goPanic, "main.applyCoupon", "main.applyGift", 1)), LogRules{})
	if a[0].Fingerprint == b[0].Fingerprint {
		t.Error("panics in different functions must differ")
	}
}

func TestFramePython(t *testing.T) {
	hits := detectAll(t, lines("shop", pyTrace), LogRules{})
	if len(hits) != 1 || hits[0].Detector != "exception" {
		t.Fatalf("hits = %+v", hits)
	}
	if !strings.Contains(hits[0].Title, "ZeroDivisionError: division by zero") {
		t.Errorf("title = %q", hits[0].Title)
	}
}

func TestFrameJava(t *testing.T) {
	hits := detectAll(t, lines("shop", javaTrace), LogRules{})
	if len(hits) != 1 {
		t.Fatalf("hits = %+v", hits)
	}
	if hits[0].Title != "java.lang.IllegalStateException: cart is empty" {
		t.Errorf("title = %q", hits[0].Title)
	}
}

func TestJSONEntries(t *testing.T) {
	pino := `{"level":50,"time":1730538000000,"msg":"request failed","err":{"type":"TypeError","message":"Cannot read properties of undefined (reading 'id')","stack":"TypeError: Cannot read properties of undefined (reading 'id')\n    at getUser (/app/src/users.js:14:22)\n    at processTicksAndRejections (node:internal/process/task_queues:95:5)"}}`
	hits := detectAll(t, []LogEntry{{Time: t0, Service: "web", Message: pino}}, LogRules{})
	if len(hits) != 1 || hits[0].Category != LogErrors {
		t.Fatalf("hits = %+v", hits)
	}
	if !strings.Contains(hits[0].Title, "request failed") {
		t.Errorf("title = %q", hits[0].Title)
	}
	info := `{"level":"info","msg":"0 errors in the last batch"}`
	if h := detectAll(t, []LogEntry{{Time: t0, Message: info}}, LogRules{}); len(h) != 0 {
		t.Errorf("an info line that mentions errors is not an error: %+v", h)
	}
}

func TestPlainErrorFingerprintIgnoresValues(t *testing.T) {
	a := detectAll(t, []LogEntry{{Time: t0, Message: `2026-11-02T09:00:01Z ERROR failed to load user "bob" from 10.0.0.5:5432 after 31ms`}}, LogRules{})
	b := detectAll(t, []LogEntry{{Time: t0, Message: `2026-11-02T09:07:44Z ERROR failed to load user "alice" from 10.0.0.9:5432 after 120ms`}}, LogRules{})
	if len(a) != 1 || len(b) != 1 || a[0].Fingerprint != b[0].Fingerprint {
		t.Fatalf("a = %+v, b = %+v", a, b)
	}
	if a[0].Title != `failed to load user "bob" from 10.0.0.5:5432 after 31ms` {
		t.Errorf("title = %q", a[0].Title)
	}
}

const jwt = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"

func TestSecretInLog(t *testing.T) {
	key := []byte("k1")
	line := `{"level":"info","msg":"incoming request","caller":"auth/mw.go:31","headers":{"authorization":"Bearer ` + jwt + `"}}`
	hits := detectAll(t, []LogEntry{{Time: t0, Service: "api", Message: line}}, LogRules{Key: key})
	if len(hits) != 1 {
		t.Fatalf("want one secret hit (the bearer JWT is one secret), got %+v", hits)
	}
	h := hits[0]
	if h.Detector != "secret" || h.Class != LogClassLeak || h.SecretMask != "eyJh…8U" {
		t.Errorf("hit = %+v", h)
	}
	if !strings.Contains(h.Title, "auth/mw.go:31") {
		t.Errorf("title should name the call site: %q", h.Title)
	}
	for _, l := range append(h.Lines, h.Title) {
		if strings.Contains(l, jwt) || strings.Contains(l, "dozjgNry") {
			t.Fatalf("secret leaked into the hit: %q", l)
		}
	}
	again := detectAll(t, []LogEntry{{Time: t0, Service: "api", Message: line}}, LogRules{Key: key})
	other := detectAll(t, []LogEntry{{Time: t0, Service: "api", Message: line}}, LogRules{Key: []byte("k2")})
	if again[0].SecretHMAC != h.SecretHMAC || other[0].SecretHMAC == h.SecretHMAC {
		t.Error("the HMAC is stable per key and differs between keys")
	}
}

func TestSecretNearMisses(t *testing.T) {
	for _, l := range []string{
		`level=warn msg="login failed" reason="password: incorrect"`,
		`password reset requested for user 42`,
		`{"msg":"saved","password":"[redacted]"}`,
		`{"msg":"saved","password":"********"}`,
		`config loaded: secret=${DB_SECRET}`,
		`token refreshed in 31ms`,
		`commit 3f9c1a2b4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a deployed`,
	} {
		for _, h := range detectAll(t, []LogEntry{{Time: t0, Message: l}}, LogRules{}) {
			if h.Detector == "secret" {
				t.Errorf("%q: false secret %+v", l, h)
			}
		}
	}
}

func TestSecretKinds(t *testing.T) {
	for _, tc := range []struct{ line, kind string }{
		{`connecting to postgres://app:S3cr3tPass@db:5432/shop`, "password in a URL"},
		{`aws: using key AKIAIOSFODNN7EXAMPLE`, "AWS access key"},
		{`login payload {"user":"bob","password":"hunter2hunter2"}`, "password"},
		{`github: ghp_abcdefghijklmnopqrstuvwxyz0123456789 accepted`, "GitHub token"},
	} {
		hits := detectAll(t, []LogEntry{{Time: t0, Message: tc.line}}, LogRules{})
		found := false
		for _, h := range hits {
			if h.Detector == "secret" && h.SecretKind == tc.kind {
				found = true
				for _, l := range h.Lines {
					if strings.Contains(l, "S3cr3tPass") || strings.Contains(l, "hunter2hunter2") || strings.Contains(l, "AKIAIOSFODNN7EXAMPLE") {
						t.Errorf("%s: value in the excerpt: %q", tc.kind, l)
					}
				}
			}
		}
		if !found {
			t.Errorf("%q: want %s, got %+v", tc.line, tc.kind, hits)
		}
	}
}

func TestPersonalData(t *testing.T) {
	hits := detectAll(t, []LogEntry{{Time: t0, Message: `ERROR payment declined for card 4111 1111 1111 1111`}}, LogRules{})
	card := false
	for _, h := range hits {
		if h.Detector == "personal_data" && h.SecretKind == "card number" {
			card = true
		}
		for _, l := range h.Lines {
			if strings.Contains(l, "4111 1111") {
				t.Errorf("card number in the excerpt: %q", l)
			}
		}
	}
	if !card {
		t.Errorf("want a card number hit, got %+v", hits)
	}
	if h := detectAll(t, []LogEntry{{Time: t0, Message: `ERROR order 1234567890123 not found`}}, LogRules{}); len(h) != 1 {
		t.Errorf("an order number that fails Luhn is not a card: %+v", h)
	}
}

func TestURLPasswordIsNotAnEmail(t *testing.T) {
	for _, h := range detectAll(t, []LogEntry{{Time: t0, Message: `INFO connecting to postgres://billing:Sup3rS3cret-2026@db.internal:5432/billing`}}, LogRules{}) {
		if h.Detector == "personal_data" {
			t.Errorf("a URL's password@host is not an email: %+v", h)
		}
	}
}

func TestDebugModeOnlyInProduction(t *testing.T) {
	e := []LogEntry{{Time: t0, Message: `[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.`}}
	if h := detectAll(t, e, LogRules{}); len(h) != 0 {
		t.Errorf("staging: %+v", h)
	}
	h := detectAll(t, e, LogRules{Production: true})
	if len(h) != 1 || h[0].Detector != "debug_mode" || h[0].Class != LogClassConfig {
		t.Errorf("production: %+v", h)
	}
}

func TestExposureAndInjection(t *testing.T) {
	body := `{"level":"error","msg":"query failed","path":"/orders","method":"GET","status":500,"response":{"body":"pq: syntax error at or near \"OR\""},"query":"id=1' OR '1'='1"}`
	hits := detectAll(t, []LogEntry{{Time: t0, Message: body}}, LogRules{})
	var dets []string
	for _, h := range hits {
		dets = append(dets, h.Detector)
	}
	got := strings.Join(dets, ",")
	if !strings.Contains(got, "exposure") || !strings.Contains(got, "injection") {
		t.Errorf("detectors = %s", got)
	}
}

func TestSignals(t *testing.T) {
	for _, tc := range []struct {
		line   string
		signal LogSignal
		route  string
	}{
		{`203.0.113.9 - - [02/Nov/2026:09:00:00 +0000] "POST /api/login HTTP/1.1" 401 12 "-" "curl"`, SignalFailedLogin, "POST /api/login"},
		{`203.0.113.9 - - [02/Nov/2026:09:00:00 +0000] "GET /.env HTTP/1.1" 404 0 "-" "zgrab"`, SignalProbe, "probes"},
		{`{"method":"GET","path":"/orders/123/items?x=1","status":502,"ip":"10.0.0.1"}`, SignalServerError, "GET /orders/:id/items"},
		{`{"method":"GET","path":"/orders","status":200}`, SignalNone, ""},
	} {
		ev := ParseLogEntry(LogEntry{Time: t0, Message: tc.line}, LogFields{})
		s, r := SignalOf(ev)
		if s != tc.signal || r != tc.route {
			t.Errorf("%q: signal %q route %q, want %q %q", tc.line, s, r, tc.signal, tc.route)
		}
	}
	ev := ParseLogEntry(LogEntry{Time: t0, Message: `203.0.113.9 - - [02/Nov/2026:09:00:00 +0000] "GET /.env HTTP/1.1" 200 312 "-" "zgrab"`}, LogFields{})
	if h, ok := ProbeExposed(ev); !ok || h.Severity != LogHigh {
		t.Errorf("a served /.env is an exposure: %+v %v", h, ok)
	}
}

func TestFilterRegexCoversDetectors(t *testing.T) {
	re := regexp.MustCompile(LogFilterRegex(nil))
	for _, l := range []string{goPanic, pyTrace, javaTrace, `Authorization: Bearer ` + jwt, `postgres://app:S3cr3tPass@db/x`,
		`203.0.113.9 - - [02/Nov/2026:09:00:00 +0000] "POST /api/login HTTP/1.1" 401 12`, `{"status":503,"path":"/x"}`,
		`WARNING: This is a development server.`} {
		if !re.MatchString(strings.Split(l, "\n")[0]) {
			t.Errorf("the backend filter would drop %q", strings.Split(l, "\n")[0])
		}
	}
}

func TestNormalizeLevel(t *testing.T) {
	for in, want := range map[string]string{"50": "error", "60": "fatal", "3": "error", "WARNING": "warn", "Error": "error", "panic": "fatal", "x": ""} {
		if got := NormalizeLevel(in); got != want {
			t.Errorf("NormalizeLevel(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestLogScopeKey(t *testing.T) {
	if got := LogScopeKey(4, "api", []int64{7, 3, 7}); got != "repos:3,7" {
		t.Errorf("scope = %q", got)
	}
	if got := LogScopeKey(4, "api", nil); got != "svc:4/api" {
		t.Errorf("scope = %q", got)
	}
}

func TestLogWatchSettings(t *testing.T) {
	s := DefaultLogWatchSettings()
	if err := s.Validate(); err != nil {
		t.Fatal(err)
	}
	if s.Errors != LogModeReport || s.Security != LogModeReport {
		t.Error("automatic tickets must be off by default")
	}
	s.Overrides = []LogOverride{{RepoID: 3, Errors: LogModeTicket}, {Service: "prod/api", Errors: LogModeOff}}
	if s.ModeFor(LogErrors, "prod/api", []int64{3}) != LogModeOff {
		t.Error("a service override wins over a repository one")
	}
	if s.ModeFor(LogErrors, "prod/web", []int64{3}) != LogModeTicket {
		t.Error("a repository override applies")
	}
	if s.ModeFor(LogSecurity, "prod/web", []int64{3}) != LogModeReport {
		t.Error("the other category keeps the workspace mode")
	}
	bad := DefaultLogWatchSettings()
	bad.Patterns = []LogPattern{{Name: "x", Pattern: "("}}
	bad.Threshold = 0
	if err := bad.Validate(); err == nil {
		t.Error("bad pattern and threshold must fail")
	}
}

func TestLogSourceNormalize(t *testing.T) {
	s := LogSource{Name: " prod ", Kind: LogLoki, Address: "https://loki.acme.com/"}
	if err := s.Normalize(); err != nil {
		t.Fatal(err)
	}
	if s.Address != "https://loki.acme.com" || s.PollSeconds != 15 || s.Environment != "production" {
		t.Errorf("normalized = %+v", s)
	}
	p := LogSource{Name: "ship", Kind: LogPush, Address: "https://x"}
	if err := p.Normalize(); err != nil || p.Address != "" {
		t.Errorf("push: %v %+v", err, p)
	}
	if err := (&LogSource{Name: "x", Kind: LogLoki, Address: "loki:3100"}).Normalize(); err == nil {
		t.Error("an address without a scheme must fail")
	}
	if err := (&LogSource{Name: "x", Kind: LogLoki, Address: "https://x", PollSeconds: 1}).Normalize(); err == nil {
		t.Error("a 1 s poll must fail")
	}
}
