package logsource

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
)

// AWS's Signature V4 test suite, "get-vanilla".
func TestSignV4KnownAnswer(t *testing.T) {
	req, _ := http.NewRequest(http.MethodGet, "https://example.amazonaws.com/", nil)
	at := time.Date(2015, 8, 30, 12, 36, 0, 0, time.UTC)
	signV4(req, nil, "AKIDEXAMPLE", "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY", "", "us-east-1", "service", at)
	want := "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31"
	if got := req.Header.Get("Authorization"); got != want {
		t.Fatalf("got  %s\nwant %s", got, want)
	}
}

func TestDatadogPull(t *testing.T) {
	var body map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("DD-API-KEY") != "api" || r.Header.Get("DD-APPLICATION-KEY") != "app" {
			w.WriteHeader(http.StatusForbidden)
			return
		}
		b, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(b, &body)
		_, _ = fmt.Fprintf(w, `{"data":[{"id":"e1","attributes":{"timestamp":"%s","message":"panic: x","service":"api","status":"error","host":"h1","attributes":{"caller":"x.go:1"}}}]}`,
			now.Add(-time.Minute).Format(time.RFC3339Nano))
	}))
	defer srv.Close()
	src := domain.LogSource{Kind: domain.LogDatadog, Auth: domain.LogAuth{Kind: "apikey", Token: "api", Password: "app"}}
	d := &Datadog{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	b, err := d.Pull(context.Background(), []domain.LogService{{Name: "api", Selector: "api", Enabled: true}}, DefaultFilter(nil), domain.LogCursor{Time: now.Add(-time.Hour)}, 100)
	if err != nil || len(b.Entries) != 1 || b.Entries[0].Service != "api" || b.Entries[0].Level != "error" || !strings.Contains(b.Entries[0].Message, `"caller":"x.go:1"`) {
		t.Fatalf("%+v %v", b, err)
	}
	q := body["filter"].(map[string]any)["query"].(string)
	if !strings.HasPrefix(q, `service:("api")`) || !strings.Contains(q, `"panic"`) {
		t.Errorf("query %q", q)
	}
	bad := src
	bad.Auth.Password = "nope"
	db := &Datadog{src: bad, c: client(t, srv, bad), now: func() time.Time { return now }}
	if _, err := db.Pull(context.Background(), nil, DefaultFilter(nil), domain.LogCursor{Time: now.Add(-time.Hour)}, 100); !Unauthorized(err) {
		t.Errorf("wrong key: %v", err)
	}
}

func TestCloudWatchPull(t *testing.T) {
	var targets []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasPrefix(r.Header.Get("Authorization"), "AWS4-HMAC-SHA256 Credential=AKID/") || r.Header.Get("X-Amz-Security-Token") != "sess" {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = fmt.Fprint(w, `{"__type":"UnrecognizedClientException"}`)
			return
		}
		target := strings.TrimPrefix(r.Header.Get("X-Amz-Target"), "Logs_20140328.")
		targets = append(targets, target)
		switch target {
		case "DescribeLogGroups":
			_, _ = fmt.Fprint(w, `{"logGroups":[{"logGroupName":"/ecs/api"}]}`)
		case "FilterLogEvents":
			var in map[string]any
			_ = json.NewDecoder(r.Body).Decode(&in)
			if !strings.Contains(fmt.Sprint(in["filterPattern"]), `?"panic"`) {
				t.Errorf("pattern %v", in["filterPattern"])
			}
			_, _ = fmt.Fprintf(w, `{"events":[{"eventId":"1","timestamp":%d,"message":"panic: x\n","logStreamName":"s1"}]}`, now.Add(-time.Minute).UnixMilli())
		}
	}))
	defer srv.Close()
	src := domain.LogSource{Kind: domain.LogCloudWatch, Auth: domain.LogAuth{Kind: "aws", User: "AKID", Password: "secret", Tenant: "sess"}}
	w := &CloudWatch{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	svcs, err := w.Discover(context.Background())
	if err != nil || len(svcs) != 1 || svcs[0].Name != "api" || svcs[0].Selector != "/ecs/api" {
		t.Fatalf("discover %+v %v", svcs, err)
	}
	b, err := w.Pull(context.Background(), svcs, DefaultFilter(nil), domain.LogCursor{Time: now.Add(-time.Hour)}, 100)
	if err != nil || len(b.Entries) != 1 || b.Entries[0].Message != "panic: x" || b.Entries[0].Key != "1" {
		t.Fatalf("pull %+v %v", b, err)
	}
	bad := src
	bad.Auth.User = "WRONG"
	wb := &CloudWatch{src: bad, c: client(t, srv, bad), now: func() time.Time { return now }}
	if _, err := wb.Discover(context.Background()); !Unauthorized(err) {
		t.Errorf("wrong key: %v", err)
	}
}

func TestSplunkPull(t *testing.T) {
	var search string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer stok" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch r.URL.Path {
		case "/services/server/info":
			_, _ = fmt.Fprint(w, `{"entry":[{"content":{"version":"9.3.0"}}]}`)
		case "/services/search/jobs/export":
			_ = r.ParseForm()
			search = r.Form.Get("search")
			_, _ = fmt.Fprintf(w, "{\"preview\":false,\"result\":{\"_time\":\"%s\",\"_raw\":\"ERROR boom\",\"_cd\":\"1:2\",\"sourcetype\":\"api\",\"host\":\"h\",\"source\":\"/var/log/api.log\"}}\n",
				now.Add(-time.Minute).Format("2006-01-02T15:04:05.000-07:00"))
		}
	}))
	defer srv.Close()
	src := domain.LogSource{Kind: domain.LogSplunk, Auth: domain.LogAuth{Kind: "bearer", Token: "stok"}, Scope: domain.LogScope{Index: "main"}}
	s := &Splunk{src: src, c: client(t, srv, src), now: func() time.Time { return now }}
	if res, err := s.Test(context.Background()); err != nil || res.Version != "Splunk 9.3.0" {
		t.Fatalf("test %+v %v", res, err)
	}
	b, err := s.Pull(context.Background(), []domain.LogService{{Name: "api", Selector: "api", Enabled: true}}, DefaultFilter(nil), domain.LogCursor{Time: now.Add(-time.Hour)}, 100)
	if err != nil || len(b.Entries) != 1 || b.Entries[0].Message != "ERROR boom" || b.Entries[0].Service != "api" {
		t.Fatalf("pull %+v %v", b, err)
	}
	if !strings.HasPrefix(search, "search index=main earliest=") || !strings.Contains(search, `sourcetype="api"`) || !strings.Contains(search, "| sort 0 _time") {
		t.Errorf("search %q", search)
	}
}
