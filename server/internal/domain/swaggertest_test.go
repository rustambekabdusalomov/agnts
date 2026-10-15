package domain

import (
	"encoding/base64"
	"net"
	"strings"
	"testing"
	"time"
)

func TestSwaggerResultsNormalize(t *testing.T) {
	r := SwaggerResults{Cases: []APICase{
		{ID: "users-ok", Operation: "GET /users", Verdict: VerdictPass, Requests: []string{"r-1"}},
		{ID: "users-ok", Operation: "GET /users", Verdict: VerdictPass, Requests: []string{"r-1"}},       // repeated id
		{ID: "Bad Id!", Operation: "GET /users", Verdict: VerdictPass, Requests: []string{"r-1"}},        // bad id
		{ID: "orders", Operation: "GET /orders", Verdict: VerdictPass, Requests: []string{"r-1"}},        // not covered
		{ID: "claimed", Operation: "get /users", Verdict: VerdictFail, Requests: []string{"r-9"}},        // not in the log
		{ID: "no-evidence", Operation: "GET /users", Verdict: VerdictFail},                               // no requests
		{ID: "skipped", Operation: "POST /users", Verdict: VerdictSkipped, Reason: "write requests off"}, // kept
		{ID: "weird", Operation: "GET /users", Verdict: "maybe"},
	}}
	r.Normalize([]string{"GET /users", "POST /users"}, map[string]bool{"r-1": true})
	if len(r.Cases) != 2 || r.Cases[0].ID != "users-ok" || r.Cases[1].ID != "skipped" {
		t.Fatalf("cases = %+v", r.Cases)
	}
	if r.Cases[0].Source != CaseByClaude {
		t.Errorf("source = %q", r.Cases[0].Source)
	}
	notes := strings.Join(r.Notes, "\n")
	for _, want := range []string{"no logged request behind the verdict", "an endpoint the test does not cover", "a bad or repeated case id", "an unknown verdict"} {
		if !strings.Contains(notes, want) {
			t.Errorf("notes miss %q: %s", want, notes)
		}
	}
}

func TestSwaggerResultsCap(t *testing.T) {
	var r SwaggerResults
	for i := range MaxAPICases + 5 {
		r.Cases = append(r.Cases, APICase{ID: "c-" + strings.Repeat("a", i%3) + string(rune('a'+i%26)) + "-" + itoa(i), Operation: "GET /x", Verdict: VerdictSkipped})
	}
	r.Normalize([]string{"GET /x"}, nil)
	if len(r.Cases) != MaxAPICases {
		t.Fatalf("kept %d cases", len(r.Cases))
	}
}

func itoa(i int) string {
	s := ""
	for {
		s = string(rune('0'+i%10)) + s
		i /= 10
		if i == 0 {
			return s
		}
	}
}

func TestAllBlocked(t *testing.T) {
	r := SwaggerResults{Cases: []APICase{{Verdict: VerdictBlocked}, {Verdict: VerdictBlocked}}}
	if !r.AllBlocked() {
		t.Error("every case blocked is a blocked run")
	}
	r.Cases = append(r.Cases, APICase{Verdict: VerdictFail})
	if r.AllBlocked() {
		t.Error("a failure is not a blocked run")
	}
	if (SwaggerResults{}).AllBlocked() {
		t.Error("no cases is not a blocked run")
	}
	if got := r.Counts().SummaryLine(); got != "0 passed, 1 failed, 2 blocked" {
		t.Errorf("summary = %q", got)
	}
}

func TestRedactor(t *testing.T) {
	const tok = "eyJhbGciOiJIUzI1NiJ9.secret+value/x"
	r := NewRedactor(AuthBearer, "Bearer "+tok)
	cases := map[string]string{
		"exact":       "Bearer " + tok,
		"no prefix":   `{"token":"` + tok + `"}`,
		"url encoded": "https://api.test/x?key=" + strings.ReplaceAll(strings.ReplaceAll(strings.ReplaceAll(tok, "+", "%2B"), "/", "%2F"), "=", "%3D"),
	}
	for name, in := range cases {
		if got := r.String(in); strings.Contains(got, "secret") {
			t.Errorf("%s: %q", name, got)
		}
	}

	b := NewRedactor(AuthBasic, "alice:hunter22")
	enc := base64.StdEncoding.EncodeToString([]byte("alice:hunter22"))
	if got := b.String("Basic " + enc + " and hunter22"); strings.Contains(got, enc) || strings.Contains(got, "hunter22") {
		t.Errorf("basic: %q", got)
	}

	h := r.Headers(map[string]string{"Authorization": "x", "Set-Cookie": "s=1", "Cookie": "c", "X-Key": "k", "Echo": "Bearer " + tok, "Accept": "a"}, "X-Key")
	for _, k := range []string{"Authorization", "Set-Cookie", "Cookie", "X-Key", "Echo"} {
		if h[k] != Masked && !strings.Contains(h[k], Masked) {
			t.Errorf("header %s = %q", k, h[k])
		}
	}
	if h["Accept"] != "a" {
		t.Errorf("Accept = %q", h["Accept"])
	}
	ex := r.Exchange(APIExchange{URL: "https://x/?t=" + tok, RespBody: `{"me":"` + tok + `"}`}, "")
	if strings.Contains(ex.URL+ex.RespBody, tok) {
		t.Errorf("exchange: %+v", ex)
	}
	if got := NewRedactor(AuthBearer, "ab").String("cab"); got != "cab" {
		t.Errorf("a short value masks words: %q", got)
	}
}

func TestSideEffect(t *testing.T) {
	for p, want := range map[string]string{
		"/api/v1/users":         "",
		"/auth/logout":          "logout",
		"/reports/export":       "export",
		"/jobs/{id}/run":        "run",
		"/runtime":              "",
		"/emails/templates":     "",
		"/users/{id}/reset":     "reset",
		"/notifications/unread": "",
	} {
		if got := SideEffect(p, ""); got != want {
			t.Errorf("%s: %q, want %q", p, got, want)
		}
	}
	if got := SideEffect("/x", "sendEmail"); got != "send" {
		t.Errorf("operation id: %q", got)
	}
}

func TestParseBaseURL(t *testing.T) {
	for _, ok := range []string{"https://staging.example.com", "http://203.0.113.7:8080/api/", "https://h.test:8443"} {
		if _, err := ParseBaseURL(ok); err != nil {
			t.Errorf("%s: %v", ok, err)
		}
	}
	for _, bad := range []string{"ftp://x", "https://", "https://u:p@x.test", "https://x.test/?a=1", "x.test", "http://x.test:99999"} {
		if _, err := ParseBaseURL(bad); err == nil {
			t.Errorf("%s: accepted", bad)
		}
	}
	u, _ := ParseBaseURL("http://203.0.113.7:8080/api/")
	if h, p := HostPort(u); h != "203.0.113.7" || p != 8080 || u.Path != "/api" {
		t.Errorf("host %s port %d path %s", h, p, u.Path)
	}
}

func TestAPIAuthValidate(t *testing.T) {
	if err := (APIAuth{Kind: AuthBearer}).Validate(""); err == nil {
		t.Error("bearer without a token")
	}
	if err := (APIAuth{Kind: AuthHeader}).Validate("k"); err == nil {
		t.Error("header key without a name")
	}
	if err := (APIAuth{Kind: AuthHeader, Name: "Host"}).Validate("k"); err == nil {
		t.Error("Host header")
	}
	if err := (APIAuth{Kind: AuthBasic}).Validate("nocolon"); err == nil {
		t.Error("basic without user:password")
	}
	if err := (APIAuth{Kind: AuthBearer}).Validate("a\nb"); err == nil {
		t.Error("line break")
	}
	if err := (APIAuth{Kind: AuthNone}).Validate(""); err != nil {
		t.Error(err)
	}
}

func TestSwaggerTestValidate(t *testing.T) {
	ops := []Operation{{"GET", "/users"}}
	st := SwaggerTest{BaseURL: "https://x.test", Operations: []string{"GET /users"}}
	if err := st.Validate(ops); err != nil {
		t.Fatal(err)
	}
	st.Operations = []string{"GET /orders"}
	if err := st.Validate(ops); err == nil {
		t.Error("an endpoint missing from the spec")
	}
	st.Operations = nil
	if err := st.Validate(ops); err != nil || !st.ByInstructions() {
		t.Errorf("no endpoints ticked: the ticket's text scopes the test: %v", err)
	}
}

func TestIsPublicIP(t *testing.T) {
	for _, s := range []string{"127.0.0.1", "10.1.2.3", "172.20.0.5", "192.168.1.1", "169.254.169.254", "100.64.0.1", "::1", "fc00::1", "fe80::1", "0.0.0.0", "224.0.0.1", "::ffff:10.0.0.1"} {
		if IsPublicIP(net.ParseIP(s)) {
			t.Errorf("%s is public", s)
		}
	}
	for _, s := range []string{"8.8.8.8", "203.0.113.7", "2606:4700::1111"} {
		if !IsPublicIP(net.ParseIP(s)) {
			t.Errorf("%s is not public", s)
		}
	}
}

func TestCapLog(t *testing.T) {
	big := strings.Repeat("x", 1000)
	log := []APIExchange{{ID: "r-1", RespBody: big}, {ID: "r-2", RespBody: big}, {ID: "r-3", RespBody: big}}
	out := CapLog(log, 1500)
	if len(out) != 3 || out[0].RespBody != "" || !out[0].Truncated || out[2].RespBody == "" {
		t.Fatalf("%+v", out)
	}
}

func TestSuiteNextRun(t *testing.T) {
	now := time.Date(2026, 10, 15, 13, 20, 0, 0, time.UTC) // a Thursday
	if got := ScheduleHourly.NextRun(now, 0); !got.Equal(time.Date(2026, 10, 15, 14, 0, 0, 0, time.UTC)) {
		t.Errorf("hourly: %s", got)
	}
	if got := ScheduleDaily.NextRun(now, 6); !got.Equal(time.Date(2026, 10, 16, 6, 0, 0, 0, time.UTC)) {
		t.Errorf("daily, hour passed: %s", got)
	}
	if got := ScheduleDaily.NextRun(now, 18); !got.Equal(time.Date(2026, 10, 15, 18, 0, 0, 0, time.UTC)) {
		t.Errorf("daily, later today: %s", got)
	}
	if got := ScheduleWeekly.NextRun(now, 6); !got.Equal(time.Date(2026, 10, 19, 6, 0, 0, 0, time.UTC)) {
		t.Errorf("weekly: %s", got)
	}
	if ScheduleOff.NextRun(now, 6) != nil {
		t.Error("off has a next run")
	}
}

func TestBasicCredentials(t *testing.T) {
	enc := base64.StdEncoding.EncodeToString([]byte("docs:s3cret"))
	for in, want := range map[string]string{
		"docs:s3cret":    "docs:s3cret",
		enc:              "docs:s3cret",
		"Basic " + enc:   "docs:s3cret",
		"basic " + enc:   "docs:s3cret",
		"not-a-password": "not-a-password",
	} {
		if got := BasicCredentials(in); got != want {
			t.Errorf("%q: %q", in, got)
		}
	}
	if err := (APIAuth{Kind: AuthBasic}).Validate("Basic " + enc); err != nil {
		t.Errorf("an encoded token: %v", err)
	}
	if err := (APIAuth{Kind: AuthBasic}).Validate("nocolon"); err == nil {
		t.Error("neither user:password nor a token")
	}
	r := NewRedactor(AuthBasic, enc)
	if got := r.String("Authorization: Basic " + enc + " user docs:s3cret"); strings.Contains(got, enc) || strings.Contains(got, "s3cret") {
		t.Errorf("redaction: %q", got)
	}
}
