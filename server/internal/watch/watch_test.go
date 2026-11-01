package watch

import (
	"bufio"
	"bytes"
	"compress/gzip"
	"context"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
)

func quiet() *slog.Logger { return slog.New(slog.NewTextHandler(io.Discard, nil)) }

func frame(stream byte, s string) []byte {
	h := make([]byte, 8)
	h[0] = stream
	binary.BigEndian.PutUint32(h[4:], uint32(len(s)))
	return append(h, s...)
}

func TestDemux(t *testing.T) {
	var b bytes.Buffer
	b.Write(frame(1, "2026-11-02T09:00:00.1Z first\n2026-11-02T09:00:00.2Z sec"))
	b.Write(frame(2, "ond\n"))
	var got []string
	if err := demux(&b, func(l string) { got = append(got, l) }); err != io.EOF {
		t.Fatal(err)
	}
	if len(got) != 2 || !strings.HasSuffix(got[1], "second") {
		t.Fatalf("%q", got)
	}
	ts, msg := splitTimestamp(got[0])
	if msg != "first" || ts.IsZero() {
		t.Fatalf("%v %q", ts, msg)
	}
}

func TestKeepFiltersAndKeepsContext(t *testing.T) {
	a := New(Config{URL: "x", Token: "agl_x"}, quiet())
	t0 := time.Date(2026, 11, 2, 9, 0, 0, 0, time.UTC)
	at := func(ms int) time.Time { return t0.Add(time.Duration(ms) * time.Millisecond) }
	in := []struct {
		msg  string
		ms   int
		keep bool
	}{
		{"GET / 200 in 3ms", 0, false},
		{"panic: assignment to entry in nil map", 10, true},
		{"goroutine 1 [running]:", 11, true}, // context
		{"main.applyCoupon(0xc000123456)", 12, true},
		{"server listening on :8080", 3000, false}, // after the window
	}
	for _, c := range in {
		if got := a.keep(domain.LogEntry{Time: at(c.ms), Stream: "api", Message: c.msg}); got != c.keep {
			t.Errorf("%q: keep %v", c.msg, got)
		}
	}
}

func TestFilesFollowAcrossRotation(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "app.log")
	if err := os.WriteFile(path, []byte("ERROR old, before the agent\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	a := New(Config{URL: "x", Token: "agl_x"}, quiet())
	tf := &tailed{}
	f, _ := os.Open(path)
	info, _ := f.Stat()
	tf.f, tf.info, tf.offset = f, info, info.Size()
	appendLine := func(s string) {
		w, _ := os.OpenFile(path, os.O_APPEND|os.O_WRONLY, 0o600)
		_, _ = w.WriteString(s)
		_ = w.Close()
	}
	appendLine("ERROR boom one\npartial ERROR")
	if err := a.readFile("app", path, tf); err != nil {
		t.Fatal(err)
	}
	appendLine(" line\n")
	_ = a.readFile("app", path, tf)
	// Rotate: a new, shorter file.
	_ = os.Rename(path, path+".1")
	_ = os.WriteFile(path, []byte("ERROR after rotation\n"), 0o600)
	_ = a.readFile("app", path, tf)
	var msgs []string
	for _, e := range a.queue {
		msgs = append(msgs, e.Message)
	}
	want := []string{"ERROR boom one", "partial ERROR line", "ERROR after rotation"}
	if strings.Join(msgs, "|") != strings.Join(want, "|") {
		t.Fatalf("got %q, want %q", msgs, want)
	}
}

// fakeDocker serves the list, inspect, events and logs of one container.
func fakeDocker(t *testing.T, events []map[string]any) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/_ping":
			fmt.Fprint(w, "OK")
		case r.URL.Path == "/containers/json":
			fmt.Fprint(w, `[{"Id":"abc123def4567890","Names":["/api-1"],"Labels":{"agnts.watch":"logs","com.docker.compose.service":"api"}}]`)
		case strings.HasSuffix(r.URL.Path, "/json"):
			fmt.Fprint(w, `{"Name":"/api-1","Config":{"Tty":false,"Labels":{"com.docker.compose.service":"api","org.opencontainers.image.revision":"3f9c1a2"}},"State":{"ExitCode":2,"OOMKilled":false},"RestartCount":4}`)
		case strings.HasSuffix(r.URL.Path, "/logs"):
			w.Write(frame(2, time.Now().UTC().Format(time.RFC3339Nano)+" panic: boom\n"))
			// Five seconds later: past the panic's context window.
			w.Write(frame(1, time.Now().Add(5*time.Second).UTC().Format(time.RFC3339Nano)+" GET / 200\n"))
		case r.URL.Path == "/events":
			if r.URL.Query().Get("since") == "" {
				t.Error("events must resume from a time")
			}
			enc := json.NewEncoder(w)
			for _, e := range events {
				_ = enc.Encode(e)
			}
			w.(http.Flusher).Flush()
			<-r.Context().Done()
		default:
			http.NotFound(w, r)
		}
	}))
}

func TestDockerCrashesAndLogs(t *testing.T) {
	now := time.Now()
	ev := func(action string, exit string, dt time.Duration) map[string]any {
		attrs := map[string]any{"name": "api-1", "com.docker.compose.service": "api", "agnts.watch": "logs"}
		if exit != "" {
			attrs["exitCode"] = exit
		}
		return map[string]any{"Action": action, "Actor": map[string]any{"ID": "abc123def4567890", "Attributes": attrs}, "timeNano": now.Add(dt).UnixNano()}
	}
	events := []map[string]any{
		ev("stop", "", 0), ev("die", "143", time.Second), // a deploy: ignored
		ev("die", "2", time.Minute),                      // a crash
		ev("health_status: unhealthy", "", 2*time.Minute),
	}
	srv := fakeDocker(t, events)
	defer srv.Close()
	d, err := newDocker(srv.URL)
	if err != nil {
		t.Fatal(err)
	}
	a := New(Config{URL: "x", Token: "agl_x"}, quiet())
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	go a.watchDocker(ctx, d)
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		a.mu.Lock()
		n := len(a.queue)
		a.mu.Unlock()
		if n >= 3 {
			break
		}
		time.Sleep(20 * time.Millisecond)
	}
	cancel()
	a.mu.Lock()
	defer a.mu.Unlock()
	var msgs []string
	for _, e := range a.queue {
		msgs = append(msgs, e.Service+": "+e.Message)
		if e.Service != "api" {
			t.Errorf("service %q", e.Service)
		}
	}
	joined := strings.Join(msgs, "\n")
	if !strings.Contains(joined, "panic: boom") || strings.Contains(joined, "GET / 200") {
		t.Errorf("logs: %q", msgs)
	}
	if !strings.Contains(joined, "exited with code 2 (4 restarts)") || strings.Contains(joined, "143") {
		t.Errorf("events: %q", msgs)
	}
	if !strings.Contains(joined, "is unhealthy") {
		t.Errorf("health: %q", msgs)
	}
}

func TestFlushPushesNDJSON(t *testing.T) {
	var mu sync.Mutex
	var got []map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer agl_tok" || r.URL.Path != "/webhooks/logs" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		zr, err := gzip.NewReader(r.Body)
		if err != nil {
			t.Error(err)
			return
		}
		sc := bufio.NewScanner(zr)
		mu.Lock()
		for sc.Scan() {
			var m map[string]any
			_ = json.Unmarshal(sc.Bytes(), &m)
			got = append(got, m)
		}
		mu.Unlock()
		w.WriteHeader(http.StatusAccepted)
	}))
	defer srv.Close()
	a := New(Config{URL: srv.URL + "/", Token: "agl_tok"}, quiet())
	a.emit(domain.LogEntry{Service: "api", Stream: "c1", Message: "panic: boom"})
	if err := a.flush(context.Background()); err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 || got[0]["service"] != "api" || got[0]["message"] != "panic: boom" || len(a.queue) != 0 {
		t.Fatalf("pushed %v, queue %d", got, len(a.queue))
	}
	bad := New(Config{URL: srv.URL, Token: "agl_wrong"}, quiet())
	bad.emit(domain.LogEntry{Service: "api", Message: "panic: x"})
	if err := bad.flush(context.Background()); err == nil || len(bad.queue) != 1 {
		t.Fatalf("a refused token keeps the entries: %v %d", err, len(bad.queue))
	}
}

func TestFromEnv(t *testing.T) {
	env := map[string]string{"AGNTS_URL": "https://a", "AGNTS_WATCH_TOKEN": "agl_x", "AGNTS_WATCH_FILES": "nginx=/var/log/nginx/*.log, app=/srv/app/*.log"}
	cfg, err := FromEnv(func(k string) string { return env[k] })
	if err != nil || cfg.Files["nginx"] != "/var/log/nginx/*.log" || cfg.Files["app"] != "/srv/app/*.log" {
		t.Fatalf("%+v %v", cfg, err)
	}
	env["AGNTS_WATCH_FILES"] = "nope"
	if _, err := FromEnv(func(k string) string { return env[k] }); err == nil {
		t.Error("a pair without = must fail")
	}
	if err := New(Config{}, quiet()).Run(context.Background()); err == nil {
		t.Error("no URL and token must fail")
	}
}
