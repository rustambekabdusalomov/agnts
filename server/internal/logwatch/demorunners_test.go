package logwatch

import (
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
)

// demoRunnerHits runs one of deploy/demo-runners' incident samples through
// what the supervisor does with a batch: framing, the detectors, the probe
// check and the burst counters. It returns the detectors that fired.
func demoRunnerHits(t *testing.T, name string) []string {
	t.Helper()
	raw, err := os.ReadFile(filepath.Join("..", "..", "..", "deploy", "demo-runners", "testdata", name))
	if err != nil {
		t.Fatal(err)
	}
	service, _, _ := strings.Cut(name, ".")
	start := time.Date(2026, 11, 4, 12, 0, 0, 0, time.UTC)
	// Loki applies the backends' filter before agnts sees a line.
	filter := regexp.MustCompile(domain.LogFilterRegex(nil))
	var entries []domain.LogEntry
	for i, line := range strings.Split(strings.TrimRight(string(raw), "\n"), "\n") {
		if !filter.MatchString(line) {
			continue
		}
		entries = append(entries, domain.LogEntry{Time: start.Add(time.Duration(i) * time.Millisecond),
			Service: service, Stream: service, Message: line})
	}
	rules := domain.LogRules{Key: []byte("demo"), Production: true}
	r := newRates()
	seen := map[string]bool{}
	for _, ev := range domain.FrameLogs(entries, domain.LogFields{}) {
		if !domain.PassesLogPrefilter(ev, nil) {
			continue
		}
		for _, h := range domain.DetectLog(ev, rules) {
			seen[h.Detector] = true
		}
		if h, ok := domain.ProbeExposed(ev); ok {
			seen[h.Detector] = true
		}
		if h, ok := r.observe(1, ev); ok {
			seen[h.Detector] = true
		}
	}
	var out []string
	for d := range seen {
		out = append(out, d)
	}
	sort.Strings(out)
	return out
}

// Every incident of deploy/demo-runners is a finding of the kind the demo
// shows (regenerate the samples with `demo-runners print <id>`).
func TestDemoRunnersAreSeen(t *testing.T) {
	want := map[string]string{
		"shop-api.api-1.log":      "panic",
		"shop-api.api-2.log":      "error injection",
		"shop-api.api-3.log":      "error",
		"shop-api.api-4.log":      "secret",
		"shop-api.zero-qty.log":   "", // shows in billing-worker (bw-1)
		"billing-worker.bw-1.log": "panic secret",
		"billing-worker.bw-2.log": "error personal_data",
		"billing-worker.bw-3.log": "secret",
		"billing-worker.bw-4.log": "error",
		"auth-gateway.gw-1.log":   "brute_force personal_data",
		"auth-gateway.gw-2.log":   "personal_data",
		"auth-gateway.scan.log":   "probe_exposed scanning",
		"auth-gateway.gw-4.log":   "debug_mode",
	}
	files, _ := filepath.Glob(filepath.Join("..", "..", "..", "deploy", "demo-runners", "testdata", "*.log"))
	if len(files) != len(want) {
		t.Errorf("%d samples, want %d", len(files), len(want))
	}
	for name, w := range want {
		if got := strings.Join(demoRunnerHits(t, name), " "); got != w {
			t.Errorf("%s: detectors %q, want %q", name, got, w)
		}
	}
}
