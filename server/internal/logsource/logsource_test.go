package logsource

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"agnts/internal/domain"
)

var now = time.Date(2026, 11, 2, 10, 0, 0, 0, time.UTC)

func client(t *testing.T, srv *httptest.Server, src domain.LogSource) *Client {
	t.Helper()
	src.Address = srv.URL
	c, err := Dialer{AllowPrivate: true}.For(1, src)
	if err != nil {
		t.Fatal(err)
	}
	return c
}

// fakeLoki answers query_range from entries, honouring start (inclusive),
// end (exclusive), limit and the service matcher.
func fakeLoki(t *testing.T, entries map[string][]time.Time, calls *atomic.Int32) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer tok" || r.Header.Get("X-Scope-OrgID") != "acme" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch r.URL.Path {
		case "/loki/api/v1/labels":
			_, _ = fmt.Fprint(w, `{"status":"success","data":["app","env","level","service_name"]}`)
		case "/loki/api/v1/label/service_name/values":
			_, _ = fmt.Fprint(w, `{"status":"success","data":["api","worker"]}`)
		case "/loki/api/v1/status/buildinfo":
			_, _ = fmt.Fprint(w, `{"version":"3.2.0"}`)
		case "/loki/api/v1/query_range":
			if calls != nil {
				calls.Add(1)
			}
			q := r.URL.Query()
			start, _ := strconv.ParseInt(q.Get("start"), 10, 64)
			end, _ := strconv.ParseInt(q.Get("end"), 10, 64)
			limit, _ := strconv.Atoi(q.Get("limit"))
			type stream struct {
				Stream map[string]string `json:"stream"`
				Values [][2]string       `json:"values"`
			}
			var res []stream
			for svc, ts := range entries {
				if !strings.Contains(q.Get("query"), `"`+svc+`"`) && strings.Contains(q.Get("query"), "service_name") {
					continue
				}
				s := stream{Stream: map[string]string{"service_name": svc, "level": "error"}}
				for _, x := range ts {
					if n := x.UnixNano(); n >= start && n < end && len(s.Values) < limit {
						s.Values = append(s.Values, [2]string{strconv.FormatInt(n, 10), "panic: boom " + svc})
					}
				}
				if len(s.Values) > 0 {
					res = append(res, s)
				}
			}
			b, _ := json.Marshal(map[string]any{"status": "success", "data": map[string]any{"resultType": "streams", "result": res}})
			_, _ = w.Write(b)
		default:
			http.NotFound(w, r)
		}
	}))
}

func lokiSource() domain.LogSource {
	return domain.LogSource{Name: "prod", Kind: domain.LogLoki, Auth: domain.LogAuth{Kind: "bearer", Token: "tok", Tenant: "acme"},
		Fields: domain.LogFields{Service: "service_name", Level: "level"}}
}

func TestLokiTestAndDiscover(t *testing.T) {
	srv := fakeLoki(t, map[string][]time.Time{"api": {now.Add(-time.Minute)}}, nil)
	defer srv.Close()
	src := lokiSource()
	src.Fields = domain.LogFields{}
	l := &Loki{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	res, err := l.Test(context.Background())
	if err != nil {
		t.Fatal(err)
	}
	if res.Fields.Service != "service_name" || res.Fields.Level != "level" || res.Version != "3.2.0" || !strings.Contains(res.Sample, "panic") {
		t.Fatalf("test %+v", res)
	}
	svcs, err := l.Discover(context.Background())
	if err != nil || len(svcs) != 2 || svcs[0].Selector != `{service_name="api"}` {
		t.Fatalf("discover %+v %v", svcs, err)
	}
	bad := src
	bad.Auth.Token = "wrong"
	lb := &Loki{src: bad, c: client(t, srv, bad), now: func() time.Time { return now }}
	if _, err := lb.Test(context.Background()); !Unauthorized(err) {
		t.Fatalf("wrong token: %v", err)
	}
}

func TestLokiPullResumesWithoutLossOrRepeats(t *testing.T) {
	// 12 entries for api, 3 for worker, two of api's at the same instant.
	var api []time.Time
	for i := range 11 {
		api = append(api, now.Add(-time.Minute+time.Duration(i)*time.Second))
	}
	api = append(api, api[5]) // same nanosecond as entry 5
	srv := fakeLoki(t, map[string][]time.Time{"api": api, "worker": {now.Add(-50 * time.Second), now.Add(-40 * time.Second), now.Add(-30 * time.Second)}}, nil)
	defer srv.Close()
	src := lokiSource()
	clock := now
	l := &Loki{src: src, c: client(t, srv, src), now: func() time.Time { return clock }}
	svcs := []domain.LogService{{Name: "api", Selector: `{service_name="api"}`, Enabled: true}, {Name: "worker", Selector: `{service_name="worker"}`, Enabled: true}}
	cur := domain.LogCursor{Time: now.Add(-2 * time.Minute)}
	seen := map[string]int{}
	for range 20 {
		b, err := l.Pull(context.Background(), svcs, Filter{Regex: "(?i)panic"}, cur, 4)
		if err != nil {
			t.Fatal(err)
		}
		for _, e := range b.Entries {
			seen[e.Key]++
			if e.Level != "error" || e.Service == "" {
				t.Fatalf("entry %+v", e)
			}
		}
		cur = b.Cursor
		if !b.More {
			break
		}
	}
	total := 0
	for k, n := range seen {
		if n != 1 {
			t.Errorf("entry %s read %d times", k, n)
		}
		total += n
	}
	// The duplicate instant collapses to one key (same time, stream, line).
	if total != 11+3 {
		t.Errorf("read %d entries, want 14", total)
	}
	if !cur.Time.Equal(now.Add(-Lag)) {
		t.Errorf("cursor %v, want now - lag", cur.Time)
	}
}

func TestMergeSelectors(t *testing.T) {
	for _, tc := range [][3]string{
		{`{env="prod"}`, `{app="api"}`, `{env="prod", app="api"}`},
		{"", `{app="api"}`, `{app="api"}`},
		{"", "", `{job=~".+"}`},
	} {
		if got := mergeSelectors(tc[0], tc[1]); got != tc[2] {
			t.Errorf("merge(%q, %q) = %q", tc[0], tc[1], got)
		}
	}
}

func TestElasticPull(t *testing.T) {
	var docs []map[string]any
	for i := range 7 {
		docs = append(docs, map[string]any{"_id": fmt.Sprint("d", i), "@timestamp": now.Add(-time.Minute + time.Duration(i/2)*time.Second).Format(time.RFC3339Nano),
			"message": "panic: x", "service": map[string]any{"name": "api"}, "log": map[string]any{"level": "error"}})
	}
	var bodies []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			_, _ = fmt.Fprint(w, `{"version":{"number":"2.17.0","distribution":"opensearch"}}`)
			return
		}
		b, _ := io.ReadAll(r.Body)
		bodies = append(bodies, string(b))
		var q struct {
			Size  int   `json:"size"`
			Query any   `json:"query"`
			After []any `json:"search_after"`
		}
		_ = json.Unmarshal(b, &q)
		// The fake reads the range's gte and the must_not ids from the body.
		gte := now.Add(-time.Hour)
		var skip []string
		var walk func(v any)
		walk = func(v any) {
			switch x := v.(type) {
			case map[string]any:
				if r, ok := x["@timestamp"].(map[string]any); ok {
					if s, ok := r["gte"].(string); ok {
						gte, _ = time.Parse(time.RFC3339Nano, s)
					}
				}
				if ids, ok := x["ids"].(map[string]any); ok {
					for _, id := range ids["values"].([]any) {
						skip = append(skip, id.(string))
					}
				}
				for _, y := range x {
					walk(y)
				}
			case []any:
				for _, y := range x {
					walk(y)
				}
			}
		}
		walk(q.Query)
		var hits []any
		for _, d := range docs {
			ts, _ := time.Parse(time.RFC3339Nano, d["@timestamp"].(string))
			skipped := false
			for _, s := range skip {
				skipped = skipped || s == d["_id"]
			}
			if ts.Before(gte) || skipped || len(hits) >= q.Size {
				continue
			}
			src := map[string]any{}
			for k, v := range d {
				if k != "_id" {
					src[k] = v
				}
			}
			hits = append(hits, map[string]any{"_id": d["_id"], "_source": src, "sort": []any{ts.UnixMilli()}})
		}
		out, _ := json.Marshal(map[string]any{"hits": map[string]any{"hits": hits}})
		_, _ = w.Write(out)
	}))
	defer srv.Close()
	src := domain.LogSource{Name: "os", Kind: domain.LogOpenSearch, Scope: domain.LogScope{Index: "logs-*"},
		Fields: domain.LogFields{Timestamp: "@timestamp", Message: "message", Level: "log.level", Service: "service.name"}}
	e := &Elastic{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	res, err := e.Test(context.Background())
	if err != nil || res.Version != "opensearch 2.17.0" {
		t.Fatalf("test %+v %v", res, err)
	}
	cur := domain.LogCursor{Time: now.Add(-time.Hour)}
	got := map[string]int{}
	for range 10 {
		b, err := e.Pull(context.Background(), []domain.LogService{{Name: "api", Selector: "api", Enabled: true}}, DefaultFilter(nil), cur, 3)
		if err != nil {
			t.Fatal(err)
		}
		for _, x := range b.Entries {
			got[x.Key]++
			if x.Service != "api" || x.Level != "error" {
				t.Fatalf("entry %+v", x)
			}
		}
		cur = b.Cursor
		if !b.More {
			break
		}
	}
	if len(got) != 7 {
		t.Errorf("read %d documents, want 7: %v", len(got), got)
	}
	for k, n := range got {
		if n != 1 {
			t.Errorf("%s read %d times", k, n)
		}
	}
	if !strings.Contains(bodies[len(bodies)-1], "simple_query_string") {
		t.Error("the search must filter for what the detectors want")
	}
}

func TestGraylog(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if u, p, _ := r.BasicAuth(); u != "gltok" || p != "token" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch r.URL.Path {
		case "/api/system":
			_, _ = fmt.Fprint(w, `{"version":"6.1.0"}`)
		case "/api/streams":
			_, _ = fmt.Fprint(w, `{"streams":[{"id":"s1","title":"api"},{"id":"s2","title":"old","disabled":true}]}`)
		case "/api/search/messages":
			if r.Header.Get("X-Requested-By") == "" {
				w.WriteHeader(http.StatusBadRequest)
				return
			}
			_, _ = fmt.Fprintf(w, `{"schema":[{"field":"timestamp"},{"field":"message"},{"field":"source"},{"field":"level"},{"field":"_id"}],
				"datarows":[["%s","panic: x","api-1","3","m1"]]}`, now.Add(-time.Minute).Format(time.RFC3339Nano))
		default:
			http.NotFound(w, r)
		}
	}))
	defer srv.Close()
	src := domain.LogSource{Name: "gl", Kind: domain.LogGraylog, Auth: domain.LogAuth{Kind: "bearer", Token: "gltok"}}
	g := &Graylog{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	if res, err := g.Test(context.Background()); err != nil || res.Version != "6.1.0" {
		t.Fatalf("test %+v %v", res, err)
	}
	svcs, err := g.Discover(context.Background())
	if err != nil || len(svcs) != 1 || svcs[0].Selector != "s1" {
		t.Fatalf("discover %+v %v", svcs, err)
	}
	b, err := g.Pull(context.Background(), svcs, DefaultFilter(nil), domain.LogCursor{Time: now.Add(-time.Hour)}, 100)
	if err != nil || len(b.Entries) != 1 || b.Entries[0].Service != "api" || b.Entries[0].Key != "m1" {
		t.Fatalf("pull %+v %v", b, err)
	}
	if q := luceneQuery(DefaultFilter(nil)); !strings.Contains(q, `"panic"`) || !strings.HasPrefix(q, "level:<=3") {
		t.Errorf("query %q", q)
	}
}

func TestParsePush(t *testing.T) {
	nd := `{"@timestamp":"2026-11-02T09:00:00Z","service":"api","level":"error","message":"panic: x"}
{"date":1730538000.5,"container_name":"web","log":"{\"level\":\"error\",\"msg\":\"boom\"}"}
`
	es, err := ParsePush(strings.NewReader(nd), "application/x-ndjson", "", "", now)
	if err != nil || len(es) != 2 {
		t.Fatalf("ndjson %+v %v", es, err)
	}
	if es[0].Service != "api" || !es[0].Time.Equal(time.Date(2026, 11, 2, 9, 0, 0, 0, time.UTC)) || es[0].Level != "error" {
		t.Errorf("first %+v", es[0])
	}
	if es[1].Service != "web" || es[1].Message != `{"level":"error","msg":"boom"}` || es[1].Time.Unix() != 1730538000 {
		t.Errorf("docker-wrapped %+v", es[1])
	}
	var gz bytes.Buffer
	zw := gzip.NewWriter(&gz)
	_, _ = zw.Write([]byte(`[{"msg":"a"},{"msg":"b"}]`))
	_ = zw.Close()
	if es, err := ParsePush(&gz, "application/json", "gzip", "svc", now); err != nil || len(es) != 2 || es[0].Service != "svc" {
		t.Fatalf("gzip array %+v %v", es, err)
	}
	if es, err := ParsePush(strings.NewReader("line one\nline two\n"), "text/plain", "", "box", now); err != nil || len(es) != 2 || es[1].Message != "line two" {
		t.Fatalf("text %+v %v", es, err)
	}
	if _, err := ParsePush(bytes.NewReader(make([]byte, MaxPushBody+1)), "text/plain", "", "", now); !errors.Is(err, ErrPushTooLarge) {
		t.Fatalf("oversize: %v", err)
	}
}

func TestDialerRefusesPrivateAndPlainHTTP(t *testing.T) {
	d := Dialer{}
	if _, err := d.For(1, domain.LogSource{Address: "http://loki.acme.com"}); !errors.Is(err, ErrPlainHTTP) {
		t.Errorf("http to a public host: %v", err)
	}
	if _, err := d.For(1, domain.LogSource{Address: "https://10.0.0.5:3100"}); !errors.Is(err, ErrPrivateAddress) {
		t.Errorf("private IP without a network: %v", err)
	}
	if _, err := d.For(1, domain.LogSource{Address: "https://169.254.169.254"}); !errors.Is(err, ErrPrivateAddress) {
		t.Errorf("metadata address: %v", err)
	}
	// A name that resolves to a private address is refused when dialing.
	d.Resolve = func(context.Context, string) ([]net.IP, error) { return []net.IP{net.ParseIP("127.0.0.1")}, nil }
	c, err := d.For(1, domain.LogSource{Address: "https://rebind.example.com"})
	if err != nil {
		t.Fatal(err)
	}
	resp, err := c.HTTP.Get("https://rebind.example.com/")
	if err == nil {
		_ = resp.Body.Close()
	}
	if !errors.Is(err, ErrPrivateAddress) {
		t.Errorf("rebinding to loopback: %v", err)
	}
}

func TestRedirectToOtherHostRefused(t *testing.T) {
	other := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { _, _ = fmt.Fprint(w, "stolen") }))
	defer other.Close()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, strings.Replace(other.URL, "127.0.0.1", "localhost", 1)+"/x", http.StatusFound)
	}))
	defer srv.Close()
	src := domain.LogSource{}
	c := client(t, srv, src)
	if _, err := call(context.Background(), c, domain.LogAuth{Kind: "bearer", Token: "t"}, http.MethodGet, "/", nil, nil, nil); err == nil || !strings.Contains(err.Error(), "redirect") {
		t.Fatalf("redirect: %v", err)
	}
}

func TestDialerOperatorAllowList(t *testing.T) {
	d := Dialer{Allow: []string{"loki", "10.0.0.0/8"}}
	if _, err := d.For(1, domain.LogSource{Address: "http://loki:3100"}); err != nil {
		t.Errorf("an allowed name over http: %v", err)
	}
	if _, err := d.For(1, domain.LogSource{Address: "http://10.0.4.12:3100"}); err != nil {
		t.Errorf("an allowed CIDR over http: %v", err)
	}
	if _, err := d.For(1, domain.LogSource{Address: "https://192.168.1.5"}); !errors.Is(err, ErrPrivateAddress) {
		t.Errorf("outside the list: %v", err)
	}
}
