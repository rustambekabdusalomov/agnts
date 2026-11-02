package logwatch

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"sync"
	"time"

	"agnts/internal/domain"
)

// Rate rules: how many signals of a kind within a minute make a burst.
// A burst is one hit; the same key can burst again after the cooldown.
var rateRules = map[domain.LogSignal]struct {
	limit  int
	perIP  bool // count per client address (attacks), else per route
	cool   time.Duration
	detect func(service, route, ip string, n int) domain.LogHit
}{
	domain.SignalServerError: {limit: 20, cool: 10 * time.Minute, detect: func(service, route, _ string, n int) domain.LogHit {
		return domain.LogHit{Category: domain.LogErrors, Detector: "server_errors", Class: domain.LogClassCode, Severity: domain.LogMedium,
			Title: fmt.Sprintf("%d server errors in a minute on %s", n, route), Route: route, Fingerprint: fp("server_errors", route),
			Remediation: "Look at the errors this route logs around these responses; the excerpt has the last ones."}
	}},
	domain.SignalFailedLogin: {limit: 20, perIP: true, cool: 10 * time.Minute, detect: func(service, route, ip string, n int) domain.LogHit {
		return domain.LogHit{Category: domain.LogSecurity, Detector: "brute_force", Class: domain.LogClassAttack, Severity: domain.LogMedium,
			Title: fmt.Sprintf("%d failed logins from one address in a minute (%s)", n, route), Route: route, Fingerprint: fp("brute_force", route),
			Remediation: "Rate-limit this route per address and per account, and lock or slow down an account after repeated failures."}
	}},
	domain.SignalProbe: {limit: 10, perIP: true, cool: 30 * time.Minute, detect: func(service, _, ip string, n int) domain.LogHit {
		return domain.LogHit{Category: domain.LogSecurity, Detector: "scanning", Class: domain.LogClassAttack, Severity: domain.LogLow,
			Title: fmt.Sprintf("a scanner probed %d well-known paths in a minute", n), Route: "probes", Fingerprint: fp("scanning", service),
			Remediation: "Nothing was served, so nothing leaked. If it keeps coming, block the scanners at the proxy and answer unknown paths with a plain 404."}
	}},
}

func fp(parts ...string) string {
	h := sha256.New()
	for _, p := range parts {
		h.Write([]byte(p))
		h.Write([]byte{0})
	}
	return hex.EncodeToString(h.Sum(nil))[:32]
}

// rates counts signals in one-minute windows, in memory: a restart loses
// at most a minute of counting.
type rates struct {
	mu      sync.Mutex
	windows map[string]*window
	cooled  map[string]time.Time
	swept   time.Time
}

type window struct {
	start time.Time
	n     int
}

func newRates() *rates {
	return &rates{windows: map[string]*window{}, cooled: map[string]time.Time{}}
}

// observe counts an event's signal and returns a hit when it makes a
// burst.
func (r *rates) observe(ws int64, ev domain.LogEvent) (domain.LogHit, bool) {
	sig, route := domain.SignalOf(ev)
	rule, ok := rateRules[sig]
	if !ok {
		return domain.LogHit{}, false
	}
	ip := ""
	if ev.Access != nil {
		ip = ev.Access.IP
	}
	who := route
	if rule.perIP && ip != "" {
		who = ip + " " + route
	}
	key := fmt.Sprintf("%d/%s/%s/%s", ws, ev.Service, sig, who)
	r.mu.Lock()
	defer r.mu.Unlock()
	t := ev.Time
	if t.IsZero() {
		t = time.Now()
	}
	r.sweep(t)
	w := r.windows[key]
	if w == nil || t.Sub(w.start) > time.Minute {
		w = &window{start: t}
		r.windows[key] = w
	}
	w.n++
	if w.n < rule.limit {
		return domain.LogHit{}, false
	}
	if until, ok := r.cooled[key]; ok && t.Before(until) {
		return domain.LogHit{}, false
	}
	r.cooled[key] = t.Add(rule.cool)
	h := rule.detect(ev.Service, route, ip, w.n)
	h.Lines = []string{domain.RedactLog(firstLine(ev.Lines))}
	return h, true
}

func firstLine(lines []string) string {
	if len(lines) == 0 {
		return ""
	}
	return lines[0]
}

// sweep drops old windows now and then.
func (r *rates) sweep(now time.Time) {
	if now.Sub(r.swept) < 5*time.Minute {
		return
	}
	r.swept = now
	for k, w := range r.windows {
		if now.Sub(w.start) > 2*time.Minute {
			delete(r.windows, k)
		}
	}
	for k, t := range r.cooled {
		if now.After(t) {
			delete(r.cooled, k)
		}
	}
}
