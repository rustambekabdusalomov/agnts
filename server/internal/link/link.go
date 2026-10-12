// Package link is agnts-link, the connector a team runs inside its own
// network. It connects out to agnts (nothing comes in), opens connections
// agnts asks for to the hosts the team allowed, and relays webhooks from
// its GitLab or Jira to agnts.
package link

import (
	"bufio"
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strings"
	"sync"
	"time"

	"github.com/hashicorp/yamux"

	"agnts/internal/privnet"
)

// Config configures agnts-link.
type Config struct {
	URL   string // agnts's link endpoint, e.g. https://api.agnts.uz/link
	Token string
	// Allow is the team's own list of hosts (gitlab.corp.local),
	// domains (.corp.local) and ranges (10.0.0.0/8) agnts may reach.
	// Nothing else is dialed, whatever agnts asks.
	Allow []string
	// HooksAddr is where webhooks for agnts are accepted (:8080); empty
	// turns the relay off.
	HooksAddr string
	Version   string
	// Dial connects to an allowed address (tests replace it).
	Dial func(ctx context.Context, network, addr string) (net.Conn, error)
	// Resolver resolves allowed names (nil: the system's).
	Resolver *net.Resolver
}

// Link is a running agnts-link.
type Link struct {
	cfg     Config
	log     *slog.Logger
	hosts   []string // exact hosts and ".domains"
	ranges  []netip.Prefix
	mu      sync.Mutex
	session *yamux.Session
}

// New checks cfg and returns a link.
func New(cfg Config, log *slog.Logger) (*Link, error) {
	u, err := url.Parse(cfg.URL)
	if err != nil || (u.Scheme != "https" && u.Scheme != "http") || u.Host == "" {
		return nil, errors.New("AGNTS_LINK_URL must be the https URL agnts shows (…/link)")
	}
	if !strings.HasPrefix(cfg.Token, privnet.LinkTokenPrefix) {
		return nil, errors.New("AGNTS_LINK_TOKEN must be the lnk_… token agnts showed")
	}
	l := &Link{cfg: cfg, log: log}
	for _, a := range cfg.Allow {
		a = privnet.NormalizeHost(a)
		if a == "" {
			continue
		}
		if p, err := netip.ParsePrefix(a); err == nil {
			l.ranges = append(l.ranges, p.Masked())
		} else if ad, err := netip.ParseAddr(a); err == nil {
			l.ranges = append(l.ranges, netip.PrefixFrom(ad, ad.BitLen()))
		} else {
			l.hosts = append(l.hosts, strings.TrimPrefix(a, "*"))
		}
	}
	if len(l.hosts) == 0 && len(l.ranges) == 0 {
		return nil, errors.New("AGNTS_LINK_ALLOW is empty: list the hosts and ranges agnts may reach (gitlab.corp.local,10.20.0.0/16)")
	}
	if l.cfg.Dial == nil {
		d := &net.Dialer{Timeout: 15 * time.Second}
		l.cfg.Dial = d.DialContext
	}
	if l.cfg.Resolver == nil {
		l.cfg.Resolver = net.DefaultResolver
	}
	return l, nil
}

// Run keeps a session to agnts open until ctx ends, reconnecting with
// backoff, and serves the webhook relay.
func (l *Link) Run(ctx context.Context) error {
	if l.cfg.HooksAddr != "" {
		srv := &http.Server{Addr: l.cfg.HooksAddr, Handler: http.HandlerFunc(l.relay), ReadHeaderTimeout: 10 * time.Second}
		go func() {
			<-ctx.Done()
			_ = srv.Close()
		}()
		go func() {
			l.log.Info("webhook relay listening", "addr", l.cfg.HooksAddr)
			if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
				l.log.Error("webhook relay", "err", err)
			}
		}()
	}
	backoff := time.Second
	for ctx.Err() == nil {
		started := time.Now()
		err := l.session1(ctx)
		if ctx.Err() != nil {
			return nil
		}
		var fatal *fatalError
		if errors.As(err, &fatal) {
			return err
		}
		if time.Since(started) > time.Minute {
			backoff = time.Second
		}
		l.log.Warn("disconnected from agnts; reconnecting", "err", err, "in", backoff)
		select {
		case <-ctx.Done():
			return nil
		case <-time.After(backoff):
		}
		backoff = min(backoff*2, time.Minute)
	}
	return nil
}

type fatalError struct{ msg string }

func (e *fatalError) Error() string { return e.msg }

func (l *Link) session1(ctx context.Context) error {
	conn, err := l.connect(ctx)
	if err != nil {
		return err
	}
	cfg := yamux.DefaultConfig()
	cfg.KeepAliveInterval = 20 * time.Second
	cfg.LogOutput = io.Discard
	sess, err := yamux.Server(conn, cfg)
	if err != nil {
		_ = conn.Close()
		return err
	}
	l.mu.Lock()
	l.session = sess
	l.mu.Unlock()
	l.log.Info("connected to agnts", "url", l.cfg.URL)
	defer func() {
		l.mu.Lock()
		if l.session == sess {
			l.session = nil
		}
		l.mu.Unlock()
		_ = sess.Close()
	}()
	go func() {
		<-ctx.Done()
		_ = sess.Close()
	}()
	for {
		st, err := sess.AcceptStream()
		if err != nil {
			return err
		}
		go l.serveStream(st) //nolint:gosec // G118: a stream outlives the accept loop; it has its own deadlines
	}
}

// connect opens the upgraded connection to agnts.
func (l *Link) connect(ctx context.Context) (net.Conn, error) {
	u, _ := url.Parse(l.cfg.URL)
	host := u.Host
	if u.Port() == "" {
		if u.Scheme == "https" {
			host = net.JoinHostPort(u.Hostname(), "443")
		} else {
			host = net.JoinHostPort(u.Hostname(), "80")
		}
	}
	d := &net.Dialer{Timeout: 20 * time.Second, KeepAlive: 30 * time.Second}
	var conn net.Conn
	var err error
	if u.Scheme == "https" {
		td := &tls.Dialer{NetDialer: d, Config: &tls.Config{ServerName: u.Hostname(), MinVersion: tls.VersionTLS12, NextProtos: []string{"http/1.1"}}}
		conn, err = td.DialContext(ctx, "tcp", host)
	} else {
		conn, err = d.DialContext(ctx, "tcp", host)
	}
	if err != nil {
		return nil, err
	}
	_ = conn.SetDeadline(time.Now().Add(30 * time.Second))
	path := u.RequestURI()
	req := fmt.Sprintf("GET %s HTTP/1.1\r\nHost: %s\r\nUpgrade: %s\r\nConnection: Upgrade\r\nAuthorization: Bearer %s\r\nX-Agnts-Link-Version: %s\r\n\r\n",
		path, u.Host, privnet.LinkProtocol, l.cfg.Token, l.cfg.Version)
	if _, err := io.WriteString(conn, req); err != nil {
		_ = conn.Close()
		return nil, err
	}
	br := bufio.NewReader(conn)
	resp, err := http.ReadResponse(br, &http.Request{Method: http.MethodGet})
	if err != nil {
		_ = conn.Close()
		return nil, err
	}
	// A 101 has no body: the connection itself carries the session.
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusSwitchingProtocols {
		msg, _ := io.ReadAll(io.LimitReader(resp.Body, 1024))
		_ = conn.Close()
		text := fmt.Sprintf("agnts answered %s: %s", resp.Status, strings.TrimSpace(string(msg)))
		if resp.StatusCode == http.StatusUnauthorized {
			// A wrong token stays wrong: retrying slowly is still right
			// (the owner may turn the connector on), but say it clearly.
			l.log.Error(text)
		}
		return nil, errors.New(text)
	}
	_ = conn.SetDeadline(time.Time{})
	if br.Buffered() > 0 {
		return &privnet.BufConn{Conn: conn, R: br}, nil
	}
	return conn, nil
}

func (l *Link) serveStream(st *yamux.Stream) {
	_ = st.SetDeadline(time.Now().Add(30 * time.Second))
	br := bufio.NewReader(st)
	var h privnet.StreamHeader
	if err := privnet.ReadLine(br, &h); err != nil || h.Op != privnet.OpDial {
		_ = st.Close()
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	up, ip, err := l.dialAllowed(ctx, h.Addr)
	cancel()
	if err != nil {
		l.log.Warn("refused or failed", "target", h.Addr, "err", err)
		_ = privnet.WriteLine(st, privnet.StreamReply{Error: err.Error()})
		_ = st.Close()
		return
	}
	if err := privnet.WriteLine(st, privnet.StreamReply{OK: true, IP: ip}); err != nil {
		_ = up.Close()
		_ = st.Close()
		return
	}
	_ = st.SetDeadline(time.Time{})
	l.log.Debug("connected", "target", h.Addr, "ip", ip)
	privnet.Splice(&streamConn{Stream: st, r: br}, up)
}

// dialAllowed connects to addr if the team's list allows it: a listed
// host or domain, or a name whose addresses are all in listed ranges.
// It connects to the address it checked, so a changed DNS answer cannot
// slip past.
func (l *Link) dialAllowed(ctx context.Context, addr string) (net.Conn, string, error) {
	host, port, err := privnet.SplitHostPort(addr)
	if err != nil {
		return nil, "", err
	}
	byName := l.hostAllowed(host)
	if _, err := netip.ParseAddr(host); err != nil && !byName && len(l.ranges) == 0 {
		// Only names are allowed and this is not one of them: refuse
		// without asking DNS.
		return nil, "", fmt.Errorf("%s is not on AGNTS_LINK_ALLOW", host)
	}
	var ips []netip.Addr
	if a, err := netip.ParseAddr(host); err == nil {
		ips = []netip.Addr{a.Unmap()}
	} else {
		found, err := l.cfg.Resolver.LookupNetIP(ctx, "ip", host)
		if err != nil {
			return nil, "", fmt.Errorf("resolve %s: %w", host, err)
		}
		for _, f := range found {
			ips = append(ips, f.Unmap())
		}
	}
	if len(ips) == 0 {
		return nil, "", fmt.Errorf("%s has no address", host)
	}
	for _, ip := range ips {
		if !byName && !l.inRanges(ip) {
			return nil, "", fmt.Errorf("%s (%s) is not on AGNTS_LINK_ALLOW", host, ip)
		}
	}
	var last error
	for _, ip := range ips {
		c, err := l.cfg.Dial(ctx, "tcp", netip.AddrPortFrom(ip, uint16(port)).String()) //nolint:gosec // G115: port is 1-65535
		if err == nil {
			return c, ip.String(), nil
		}
		last = err
	}
	return nil, "", last
}

func (l *Link) hostAllowed(host string) bool {
	if _, err := netip.ParseAddr(host); err == nil {
		return false
	}
	for _, h := range l.hosts {
		if strings.HasPrefix(h, ".") {
			if host == h[1:] || strings.HasSuffix(host, h) {
				return true
			}
		} else if host == h {
			return true
		}
	}
	return false
}

func (l *Link) inRanges(ip netip.Addr) bool {
	for _, p := range l.ranges {
		if p.Contains(ip) {
			return true
		}
	}
	return false
}

// relay forwards a webhook to agnts over the session.
func (l *Link) relay(w http.ResponseWriter, r *http.Request) {
	if !strings.HasPrefix(r.URL.Path, "/webhooks/") {
		http.Error(w, "agnts-link relays webhooks: use the /webhooks/... path agnts shows", http.StatusNotFound)
		return
	}
	l.mu.Lock()
	sess := l.session
	l.mu.Unlock()
	if sess == nil {
		http.Error(w, "agnts-link is not connected to agnts", http.StatusServiceUnavailable)
		return
	}
	st, err := sess.OpenStream()
	if err != nil {
		http.Error(w, "agnts-link is not connected to agnts", http.StatusServiceUnavailable)
		return
	}
	defer func() { _ = st.Close() }()
	_ = st.SetDeadline(time.Now().Add(time.Minute))
	r.Body = http.MaxBytesReader(w, r.Body, 5<<20)
	out := r.Clone(r.Context())
	out.RequestURI = ""
	out.Header.Del("Connection")
	if err := privnet.WriteLine(st, privnet.StreamHeader{Op: privnet.OpHook}); err != nil {
		http.Error(w, "relay failed", http.StatusBadGateway)
		return
	}
	if err := out.Write(st); err != nil {
		http.Error(w, "relay failed", http.StatusBadGateway)
		return
	}
	resp, err := http.ReadResponse(bufio.NewReader(st), out)
	if err != nil {
		http.Error(w, "relay failed", http.StatusBadGateway)
		return
	}
	defer func() { _ = resp.Body.Close() }()
	for k, vs := range resp.Header {
		w.Header()[k] = vs
	}
	w.WriteHeader(resp.StatusCode)
	_, _ = io.Copy(w, io.LimitReader(resp.Body, 1<<20))
	l.log.Info("webhook relayed", "path", r.URL.Path, "status", resp.StatusCode)
}

// streamConn is a yamux stream with bytes already read into r; closing a
// yamux stream ends only its writing half.
type streamConn struct {
	*yamux.Stream
	r *bufio.Reader
}

func (c *streamConn) Read(p []byte) (int, error) { return c.r.Read(p) }
func (c *streamConn) CloseWrite() error          { return c.Close() }
