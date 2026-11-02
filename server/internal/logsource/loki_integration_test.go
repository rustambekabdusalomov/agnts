package logsource

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
)

// TestLokiIntegration reads a real Loki. Run with
// AGNTS_TEST_LOKI_URL=http://127.0.0.1:3100 (docker run grafana/loki).
func TestLokiIntegration(t *testing.T) {
	addr := os.Getenv("AGNTS_TEST_LOKI_URL")
	if addr == "" {
		t.Skip("AGNTS_TEST_LOKI_URL not set")
	}
	run := fmt.Sprint(time.Now().UnixNano())
	start := time.Now().Add(-time.Minute)
	lines := []string{
		"level=info msg=\"request served\" path=/",
		"panic: assignment to entry in nil map",
		"",
		"goroutine 1 [running]:",
		"main.applyCoupon(0xc000123456)",
		"\t/app/billing/coupon.go:88 +0x1d",
		`{"level":"info","msg":"incoming","authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"}`,
	}
	var values [][2]string
	for i, l := range lines {
		values = append(values, [2]string{strconv.FormatInt(start.Add(time.Duration(i)*time.Millisecond).UnixNano(), 10), l})
	}
	body, _ := json.Marshal(map[string]any{"streams": []any{map[string]any{
		"stream": map[string]string{"service_name": "api-" + run, "env": "test"}, "values": values}}})
	resp, err := http.Post(addr+"/loki/api/v1/push", "application/json", bytes.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	_ = resp.Body.Close()
	if resp.StatusCode/100 != 2 {
		t.Fatalf("push: %d", resp.StatusCode)
	}
	src := domain.LogSource{Name: "it", Kind: domain.LogLoki, Address: addr, Scope: domain.LogScope{Selector: `{env="test"}`}}
	c, err := Dialer{AllowPrivate: true}.For(1, src)
	if err != nil {
		t.Fatal(err)
	}
	l := &Loki{src: src, c: c}
	ctx := context.Background()
	var res TestResult
	for range 20 { // Loki makes pushed lines queryable within a few seconds
		if res, err = l.Test(ctx); err == nil && res.Sample != "" {
			break
		}
		time.Sleep(time.Second)
	}
	if err != nil || res.Fields.Service != "service_name" {
		t.Fatalf("test %+v %v", res, err)
	}
	svcs, err := l.Discover(ctx)
	if err != nil {
		t.Fatal(err)
	}
	var mine []domain.LogService
	for _, s := range svcs {
		if s.Name == "api-"+run {
			s.Enabled = true
			mine = append(mine, s)
		}
	}
	if len(mine) != 1 {
		t.Fatalf("discover: %+v", svcs)
	}
	l.src.Fields = res.Fields
	b, err := l.Pull(ctx, mine, DefaultFilter(nil), domain.LogCursor{Time: start.Add(-time.Second)}, 1000)
	if err != nil {
		t.Fatal(err)
	}
	// The server-side filter drops the info line; the panic's frames come
	// back through the context read, so the trace is whole.
	var got []string
	for _, e := range b.Entries {
		got = append(got, e.Message)
	}
	joined := strings.Join(got, "\n")
	if !strings.Contains(joined, "panic: assignment") || !strings.Contains(joined, "Bearer eyJ") || strings.Contains(joined, "request served") {
		t.Fatalf("pulled %q", got)
	}
	var hits []domain.LogHit
	for _, ev := range domain.FrameLogs(b.Entries, l.src.Fields) {
		hits = append(hits, domain.DetectLog(ev, domain.LogRules{Key: []byte("k")})...)
	}
	dets := map[string]bool{}
	for _, h := range hits {
		dets[h.Detector] = true
	}
	if !dets["panic"] || !dets["secret"] {
		t.Fatalf("detectors %v", dets)
	}
	if !strings.Contains(joined, "main.applyCoupon") {
		t.Fatalf("the panic's frames were not read: %q", got)
	}
}
