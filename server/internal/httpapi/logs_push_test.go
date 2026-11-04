package httpapi

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"agnts/internal/logwatch"
)

// pushLogs records what a push handed the log watcher.
type pushLogs struct {
	Logs
	token, format string
	res           logwatch.IngestResult
}

func (p *pushLogs) Push(_ context.Context, token string, _ io.Reader, _, _, format string) (logwatch.IngestResult, error) {
	p.token, p.format = token, format
	return p.res, nil
}

func TestLogsPushOTLP(t *testing.T) {
	logs := &pushLogs{}
	s := &Server{opt: Options{Logs: logs}, pushLimiter: newIPLimiter(120, time.Minute)}
	push := func(path, contentType string) *httptest.ResponseRecorder {
		r := httptest.NewRequest(http.MethodPost, path, strings.NewReader("x"))
		r.Header.Set("Authorization", "Bearer agl_tok")
		r.Header.Set("Content-Type", contentType)
		rec := httptest.NewRecorder()
		s.logsPush(rec, r)
		return rec
	}

	rec := push("/webhooks/logs/v1/logs", "application/x-protobuf")
	if rec.Code != http.StatusOK || logs.format != logwatch.PushOTLP || logs.token != "agl_tok" || rec.Body.Len() != 0 ||
		rec.Header().Get("Content-Type") != "application/x-protobuf" {
		t.Fatalf("protobuf: %d %q %q %x", rec.Code, logs.format, rec.Header().Get("Content-Type"), rec.Body.Bytes())
	}

	logs.res = logwatch.IngestResult{Rejected: 3}
	rec = push("/webhooks/logs/v1/logs", "application/json")
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"rejectedLogRecords":"3"`) {
		t.Fatalf("JSON partial success: %d %s", rec.Code, rec.Body)
	}
	// The plain and Loki paths keep their formats and their 202.
	if rec := push("/webhooks/logs", "application/x-ndjson"); rec.Code != http.StatusAccepted || logs.format != logwatch.PushPlain {
		t.Fatalf("plain: %d %q", rec.Code, logs.format)
	}
	if rec := push("/webhooks/logs/loki/api/v1/push", "application/x-protobuf"); rec.Code != http.StatusAccepted || logs.format != logwatch.PushLoki {
		t.Fatalf("loki: %d %q", rec.Code, logs.format)
	}
}
