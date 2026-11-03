package egress

import (
	"bufio"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"io"
	"net"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

// StatusPath is where egress answers its own status (a plain request,
// not a proxied one).
const StatusPath = "/_agnts/upstream"

// Monitor checks an upstream proxy: a TLS request to its first host
// through it, and now and then which address the internet sees.
type Monitor struct {
	up    *Upstream
	every time.Duration
	tls   *tls.Config // tests: the check's TLS settings (nil: verified)

	mu      sync.Mutex
	status  UpstreamStatus
	calls   atomic.Int64
	failed  atomic.Int64
	lastErr atomic.Value // string: the last carried connection's error
}

// UpstreamStatus is what the admin panel shows about the upstream.
type UpstreamStatus struct {
	Configured bool         `json:"configured"`
	Via        string       `json:"via,omitempty"`   // the proxy, password left out
	Hosts      []string     `json:"hosts,omitempty"` // what it carries
	Target     string       `json:"target,omitempty"`
	OK         bool         `json:"ok"`
	CheckedAt  *time.Time   `json:"checkedAt,omitempty"`
	LastOKAt   *time.Time   `json:"lastOkAt,omitempty"`
	DownSince  *time.Time   `json:"downSince,omitempty"`
	LatencyMS  int64        `json:"latencyMs"`
	Error      string       `json:"error,omitempty"`
	Exit       *ExitAddress `json:"exit,omitempty"`
	History    []Check      `json:"history"`
	// Calls are the connections runs made through it since egress started;
	// Failed those it could not open, LastCallError the last reason.
	Calls         int64  `json:"calls"`
	Failed        int64  `json:"failed"`
	LastCallError string `json:"lastCallError,omitempty"`
}

// ExitAddress is where traffic through the upstream comes from.
type ExitAddress struct {
	IP      string    `json:"ip"`
	Org     string    `json:"org,omitempty"`
	City    string    `json:"city,omitempty"`
	Country string    `json:"country,omitempty"`
	At      time.Time `json:"at"`
}

// Check is one check's outcome.
type Check struct {
	At time.Time `json:"at"`
	OK bool      `json:"ok"`
	MS int64     `json:"ms"`
}

const (
	monitorHistory = 60 // 30 minutes of checks every 30 s
	exitEvery      = 5 * time.Minute
)

// NewMonitor returns a monitor of u; call Run.
func NewMonitor(u *Upstream, every time.Duration) *Monitor {
	m := &Monitor{up: u, every: every}
	m.status = UpstreamStatus{Configured: true, Via: u.url.Redacted(), Hosts: u.hosts, Target: u.probe(), History: []Check{}}
	return m
}

// probe is the host a check reaches through the upstream: the first one it
// carries that is a name, not a ".domain" suffix.
func (u *Upstream) probe() string {
	for _, h := range u.hosts {
		if !strings.HasPrefix(h, ".") {
			return h
		}
	}
	return ""
}

// Run checks until ctx ends.
func (m *Monitor) Run(ctx context.Context) {
	var exitAt time.Time
	t := time.NewTicker(m.every)
	defer t.Stop()
	for {
		ok := m.check(ctx)
		if ok && (time.Since(exitAt) > exitEvery || m.exitMissing()) {
			if e, err := m.exit(ctx); err == nil {
				exitAt = e.At
				m.mu.Lock()
				m.status.Exit = &e
				m.mu.Unlock()
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

func (m *Monitor) exitMissing() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.status.Exit == nil
}

// check makes one request through the upstream and records it.
func (m *Monitor) check(ctx context.Context) bool {
	target := m.up.probe()
	start := time.Now()
	err := errors.New("no host to check")
	if target != "" {
		err = m.request(ctx, target, "/", nil)
	}
	now := time.Now().UTC()
	ms := time.Since(start).Milliseconds()
	m.mu.Lock()
	defer m.mu.Unlock()
	st := &m.status
	st.CheckedAt, st.LatencyMS = &now, ms
	st.OK = err == nil
	if err == nil {
		st.LastOKAt, st.DownSince, st.Error = &now, nil, ""
	} else {
		st.Error = err.Error()
		if st.DownSince == nil {
			st.DownSince = &now
		}
	}
	st.History = append(st.History, Check{At: now, OK: err == nil, MS: ms})
	if len(st.History) > monitorHistory {
		st.History = st.History[len(st.History)-monitorHistory:]
	}
	return err == nil
}

// exit asks ipinfo.io, through the upstream, which address it sees.
func (m *Monitor) exit(ctx context.Context) (ExitAddress, error) {
	var e ExitAddress
	err := m.request(ctx, "ipinfo.io", "/json", func(r io.Reader) error {
		var v struct{ IP, Org, City, Country string }
		if err := json.NewDecoder(io.LimitReader(r, 64<<10)).Decode(&v); err != nil {
			return err
		}
		e = ExitAddress{IP: v.IP, Org: v.Org, City: v.City, Country: v.Country, At: time.Now().UTC()}
		return nil
	})
	return e, err
}

// request opens host:443 through the upstream, does a TLS handshake and a
// GET; any HTTP answer means the way works. read, if set, reads the body
// of a 200.
func (m *Monitor) request(ctx context.Context, host, path string, read func(io.Reader) error) error {
	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()
	raw, err := m.up.dial(ctx, "tcp", net.JoinHostPort(host, "443"))
	if err != nil {
		return friendly(err)
	}
	defer func() { _ = raw.Close() }()
	if dl, ok := ctx.Deadline(); ok {
		_ = raw.SetDeadline(dl)
	}
	cfg := &tls.Config{ServerName: host, MinVersion: tls.VersionTLS12}
	if m.tls != nil {
		cfg = m.tls.Clone()
		cfg.ServerName = host
	}
	c := tls.Client(raw, cfg)
	if err := c.HandshakeContext(ctx); err != nil {
		return err
	}
	req, _ := http.NewRequestWithContext(ctx, http.MethodGet, "https://"+host+path, nil)
	req.Header.Set("User-Agent", "agnts-egress-check")
	req.Close = true
	if err := req.Write(c); err != nil {
		return err
	}
	res, err := http.ReadResponse(bufio.NewReader(c), req)
	if err != nil {
		return err
	}
	defer func() { _ = res.Body.Close() }()
	if read != nil {
		if res.StatusCode != http.StatusOK {
			return errors.New(res.Status)
		}
		return read(res.Body)
	}
	return nil
}

// friendly says what a failed dial to the upstream usually means.
func friendly(err error) error {
	msg := err.Error()
	switch {
	case strings.Contains(msg, "connection refused"):
		return errors.New("the upstream proxy refused the connection: is the tunnel or proxy running? (" + msg + ")")
	case strings.Contains(msg, "i/o timeout"), strings.Contains(msg, "deadline exceeded"):
		return errors.New("the upstream proxy did not answer in time (" + msg + ")")
	}
	return err
}

// carried counts a connection a run made through the upstream.
func (m *Monitor) carried(err error) {
	m.calls.Add(1)
	if err != nil {
		m.failed.Add(1)
		m.lastErr.Store(err.Error())
	}
}

// Status is the monitor's state now.
func (m *Monitor) Status() UpstreamStatus {
	m.mu.Lock()
	st := m.status
	st.History = append([]Check(nil), m.status.History...)
	m.mu.Unlock()
	st.Calls, st.Failed = m.calls.Load(), m.failed.Load()
	if v, ok := m.lastErr.Load().(string); ok {
		st.LastCallError = v
	}
	return st
}

// serveStatus answers StatusPath.
func (p *Proxy) serveStatus(w http.ResponseWriter) {
	st := UpstreamStatus{History: []Check{}}
	if p.monitor != nil {
		st = p.monitor.Status()
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	_ = json.NewEncoder(w).Encode(st)
}
