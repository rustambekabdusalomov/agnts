package httpapi

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"agnts/internal/egress"
	"agnts/internal/httpapi/gen"
)

func TestPlatformEgress(t *testing.T) {
	eg := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != egress.StatusPath {
			http.NotFound(w, r)
			return
		}
		_, _ = w.Write([]byte(`{"configured":true,"via":"socks5://172.19.0.1:1080","ok":false,"latencyMs":3,"error":"the upstream proxy refused the connection: is the tunnel or proxy running?","history":[{"at":"2026-11-03T14:00:00Z","ok":true,"ms":120}],"calls":7,"failed":2,"exit":{"ip":"82.215.78.90","org":"AS12365 ISP Sarkor Telecom","at":"2026-11-03T14:00:00Z"}}`))
	}))
	defer eg.Close()

	get := func(url string) gen.EgressStatus {
		s := &Server{opt: Options{EgressURL: url}}
		rec := httptest.NewRecorder()
		s.GetPlatformEgress(rec, httptest.NewRequest(http.MethodGet, "/api/platform/egress", nil))
		var out gen.EgressStatus
		if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil || rec.Code != http.StatusOK {
			t.Fatalf("%d %s", rec.Code, rec.Body)
		}
		return out
	}
	out := get(eg.URL)
	if !out.Reachable || out.Upstream == nil || out.Upstream.Ok || out.Upstream.Calls != 7 || out.Upstream.Exit == nil ||
		out.Upstream.Exit.Ip != "82.215.78.90" || len(out.Upstream.History) != 1 || !strings.Contains(*out.Upstream.Error, "tunnel") {
		t.Fatalf("status %+v", out)
	}
	if out := get(""); out.Reachable || out.Error == nil {
		t.Fatalf("no egress: %+v", out)
	}
	eg.Close()
	if out := get(eg.URL); out.Reachable || !strings.Contains(*out.Error, "did not answer") {
		t.Fatalf("egress down: %+v", out)
	}
}
