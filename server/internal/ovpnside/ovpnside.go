// Package ovpnside is the OpenVPN sidecar: one container per workspace
// that runs the OpenVPN client in its own network namespace (it alone has
// NET_ADMIN and /dev/net/tun) and lets the gateway in through a SOCKS5
// server, resolving names with the DNS servers the VPN pushes.
package ovpnside

import (
	"bufio"
	"context"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"time"

	"agnts/internal/privnet"
)

// Config configures the sidecar.
type Config struct {
	Secret        privnet.Secret
	SocksPassword string
	SocksAddr     string // :1080
	StatusAddr    string // :1081
	Dir           string // where the config is written (a tmpfs)
	OpenVPN       string // the openvpn binary
}

// Sidecar runs OpenVPN and the SOCKS server.
type Sidecar struct {
	cfg Config
	log *slog.Logger

	mu    sync.Mutex
	state privnet.Status
	dns   []string
	tun   string   // the tunnel device OpenVPN opened
	lines []string // the last lines OpenVPN logged
}

// New returns a sidecar.
func New(cfg Config, log *slog.Logger) *Sidecar {
	if cfg.SocksAddr == "" {
		cfg.SocksAddr = ":1080"
	}
	if cfg.StatusAddr == "" {
		cfg.StatusAddr = ":1081"
	}
	if cfg.Dir == "" {
		cfg.Dir = os.TempDir()
	}
	if cfg.OpenVPN == "" {
		cfg.OpenVPN = "openvpn"
	}
	s := &Sidecar{cfg: cfg, log: log, state: privnet.Status{State: privnet.StateConnecting}}
	s.dns = configDNS(cfg.Secret.Config)
	return s
}

var dnsOption = regexp.MustCompile(`dhcp-option DNS6? ([0-9a-fA-F:.]+)`)

// configDNS reads dhcp-option DNS lines from the config itself.
func configDNS(cfg string) []string {
	var out []string
	for _, m := range dnsOption.FindAllStringSubmatch(cfg, -1) {
		if net.ParseIP(m[1]) != nil {
			out = append(out, m[1])
		}
	}
	return out
}

// Run serves until ctx ends, restarting OpenVPN when it exits.
func (s *Sidecar) Run(ctx context.Context) error {
	o, err := privnet.ParseOpenVPN(s.cfg.Secret.Config)
	if err != nil {
		return fmt.Errorf("config: %w", err)
	}
	conf := filepath.Join(s.cfg.Dir, "client.ovpn")
	if err := os.WriteFile(conf, []byte(s.cfg.Secret.Config), 0o600); err != nil {
		return err
	}
	args := []string{"--config", conf, "--script-security", "1", "--auth-nocache", "--verb", "3", "--connect-retry-max", "3"}
	if !o.HasDev {
		args = append(args, "--dev", "tun")
	}
	if s.cfg.Secret.Username != "" || s.cfg.Secret.Password != "" {
		auth := filepath.Join(s.cfg.Dir, "auth.txt")
		if err := os.WriteFile(auth, []byte(s.cfg.Secret.Username+"\n"+s.cfg.Secret.Password+"\n"), 0o600); err != nil {
			return err
		}
		args = append(args, "--auth-user-pass", auth)
	}

	// OpenVPN's own packets carry a mark and keep the container's way out;
	// everything else goes through the tunnel once it is up (see
	// tunnelEverything). A pushed route for the VPN server's own address
	// (a company that serves GitLab on it) then cannot cut the tunnel off.
	if err := keepTransportOut(ctx); err != nil {
		s.log.Warn("policy routing for the OpenVPN transport; pushed routes to the VPN server's address may break the tunnel", "err", err)
	} else {
		args = append(args, "--mark", transportMark)
	}

	var lc net.ListenConfig
	sl, err := lc.Listen(ctx, "tcp", s.cfg.SocksAddr)
	if err != nil {
		return err
	}
	socks := &privnet.SocksServer{User: "agnts", Password: s.cfg.SocksPassword, Dial: s.dial}
	go func() { _ = socks.Serve(sl) }()
	status := &http.Server{Addr: s.cfg.StatusAddr, Handler: http.HandlerFunc(s.serveStatus), ReadHeaderTimeout: 5 * time.Second}
	go func() { _ = status.ListenAndServe() }()
	defer func() {
		_ = sl.Close()
		_ = status.Close()
	}()

	backoff := 5 * time.Second
	for ctx.Err() == nil {
		started := time.Now()
		err := s.runOpenVPN(ctx, args)
		if ctx.Err() != nil {
			return nil
		}
		s.mu.Lock()
		msg := s.lastError()
		if msg == "" && err != nil {
			msg = err.Error()
		}
		if s.state.State != privnet.StateError || s.state.Error == "" {
			s.state = privnet.Status{State: privnet.StateError, Error: "OpenVPN stopped: " + msg}
		}
		s.mu.Unlock()
		s.log.Warn("openvpn exited", "err", err, "last", msg)
		if time.Since(started) > 5*time.Minute {
			backoff = 5 * time.Second
		}
		select {
		case <-ctx.Done():
			return nil
		case <-time.After(backoff):
		}
		backoff = min(backoff*2, 2*time.Minute)
	}
	return nil
}

func (s *Sidecar) runOpenVPN(ctx context.Context, args []string) error {
	cmd := exec.CommandContext(ctx, s.cfg.OpenVPN, args...) //nolint:gosec // G204: our own binary and flags
	// No secrets in OpenVPN's environment: the config is a file.
	cmd.Env = []string{"PATH=/usr/sbin:/usr/bin:/sbin:/bin"}
	out, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	cmd.Stderr = cmd.Stdout
	if err := cmd.Start(); err != nil {
		return err
	}
	s.mu.Lock()
	s.state = privnet.Status{State: privnet.StateConnecting}
	s.mu.Unlock()
	sc := bufio.NewScanner(out)
	for sc.Scan() {
		// OpenVPN's own log (verb 3 prints no keys or passwords) goes to the
		// container's, for docker logs.
		_, _ = fmt.Fprintln(os.Stdout, "openvpn: "+stripTime(sc.Text()))
		if s.observe(sc.Text()) {
			if err := s.tunnelEverything(ctx); err != nil {
				s.log.Warn("route the sidecar's connections through the tunnel", "err", err)
			}
		}
	}
	return cmd.Wait()
}

// observe follows OpenVPN's log for the state, errors and pushed DNS, and
// reports when the tunnel just came up.
func (s *Sidecar) observe(line string) (up bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.lines = append(s.lines, line)
	if len(s.lines) > 30 {
		s.lines = s.lines[len(s.lines)-30:]
	}
	switch {
	case strings.Contains(line, "TUN/TAP device") && strings.Contains(line, "opened"):
		if m := tunName.FindStringSubmatch(line); m != nil {
			s.tun = m[1]
		}
	case strings.Contains(line, "Initialization Sequence Completed"):
		up = true
		now := time.Now().UTC()
		s.state = privnet.Status{State: privnet.StateUp, Since: &now, Handshake: &now}
		if len(s.dns) > 0 {
			s.state.Detail = "DNS " + strings.Join(s.dns, ", ")
		}
	case strings.Contains(line, "AUTH_FAILED"):
		s.state = privnet.Status{State: privnet.StateError, Error: "the VPN server rejected the username or password"}
	case strings.Contains(line, "PUSH_REPLY"):
		if dns := configDNS(line); len(dns) > 0 {
			s.dns = dns
		}
	case strings.Contains(line, "TLS Error") || strings.Contains(line, "Cannot open TUN/TAP") || strings.Contains(line, "RESOLVE: Cannot resolve"):
		s.state = privnet.Status{State: privnet.StateError, Error: strings.TrimSpace(stripTime(line))}
	case strings.Contains(line, "Restart pause") || strings.Contains(line, "SIGUSR1"):
		if s.state.State == privnet.StateUp {
			s.state = privnet.Status{State: privnet.StateConnecting}
		}
	}
	return up
}

var tunName = regexp.MustCompile(`TUN/TAP device (\S+) opened`)

// transportMark marks OpenVPN's own packets (--mark); policyTable routes
// them out of the container as before.
const (
	transportMark = "1"
	policyTable   = "100"
)

// keepTransportOut sends packets with the transport mark through the
// container's default route, whatever the main table says later.
func keepTransportOut(ctx context.Context) error {
	out, err := exec.CommandContext(ctx, "ip", "-4", "route", "show", "default").Output()
	if err != nil {
		return fmt.Errorf("read the default route: %w", err)
	}
	f := strings.Fields(string(out)) // default via 172.20.0.1 dev eth0 ...
	var gw, dev string
	for i := 0; i+1 < len(f); i++ {
		switch f[i] {
		case "via":
			gw = f[i+1]
		case "dev":
			dev = f[i+1]
		}
	}
	if gw == "" || dev == "" {
		return fmt.Errorf("no default route (%q)", strings.TrimSpace(string(out)))
	}
	if err := ip(ctx, "route", "replace", "default", "via", gw, "dev", dev, "table", policyTable); err != nil {
		return err
	}
	_ = ip(ctx, "rule", "del", "fwmark", transportMark, "table", policyTable)
	return ip(ctx, "rule", "add", "fwmark", transportMark, "table", policyTable, "priority", "100")
}

// tunnelEverything makes the tunnel the sidecar's default route: what the
// gateway asks for (and the DNS servers the VPN pushed, often outside its
// pushed routes) goes through the VPN, as with OpenVPN Connect.
func (s *Sidecar) tunnelEverything(ctx context.Context) error {
	s.mu.Lock()
	tun := s.tun
	s.mu.Unlock()
	if tun == "" {
		tun = "tun0"
	}
	return ip(ctx, "route", "replace", "default", "dev", tun)
}

func ip(ctx context.Context, args ...string) error {
	out, err := exec.CommandContext(ctx, "ip", args...).CombinedOutput() //nolint:gosec // G204: fixed arguments
	if err != nil {
		return fmt.Errorf("ip %s: %w: %s", strings.Join(args, " "), err, strings.TrimSpace(string(out)))
	}
	return nil
}

var timePrefix = regexp.MustCompile(`^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} `)

func stripTime(l string) string { return timePrefix.ReplaceAllString(l, "") }

func (s *Sidecar) lastError() string {
	for i := len(s.lines) - 1; i >= 0; i-- {
		l := s.lines[i]
		if strings.Contains(l, "ERROR") || strings.Contains(l, "Error") || strings.Contains(l, "error") || strings.Contains(l, "Exiting") {
			return strings.TrimSpace(stripTime(l))
		}
	}
	return ""
}

func (s *Sidecar) dial(ctx context.Context, addr string) (net.Conn, error) {
	s.mu.Lock()
	up := s.state.State == privnet.StateUp
	dns := append([]string(nil), s.dns...)
	s.mu.Unlock()
	if !up {
		return nil, errors.New("the VPN is not connected")
	}
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return nil, err
	}
	d := &net.Dialer{Timeout: 15 * time.Second}
	if net.ParseIP(host) == nil {
		if len(dns) == 0 {
			return nil, fmt.Errorf("%s is a name, and the VPN pushed no DNS server", host)
		}
		r := &net.Resolver{PreferGo: true, Dial: func(ctx context.Context, network, _ string) (net.Conn, error) {
			var nd net.Dialer
			return nd.DialContext(ctx, network, net.JoinHostPort(dns[0], "53"))
		}}
		ips, err := r.LookupIPAddr(ctx, host)
		if err != nil {
			return nil, fmt.Errorf("resolve %s with the VPN's DNS: %w", host, err)
		}
		if len(ips) == 0 {
			return nil, fmt.Errorf("%s has no address", host)
		}
		host = ips[0].IP.String()
	}
	return d.DialContext(ctx, "tcp", net.JoinHostPort(host, port))
}

func (s *Sidecar) serveStatus(w http.ResponseWriter, r *http.Request) {
	tok, _ := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
	if subtle.ConstantTimeCompare([]byte(tok), []byte(s.cfg.SocksPassword)) != 1 {
		http.Error(w, "not authorized", http.StatusUnauthorized)
		return
	}
	s.mu.Lock()
	st := s.state
	s.mu.Unlock()
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(st)
}

// ReadSecret decodes the sidecar's secret from its environment value (the
// JSON of privnet.Secret).
func ReadSecret(v string) (privnet.Secret, error) {
	var s privnet.Secret
	err := json.NewDecoder(io.LimitReader(strings.NewReader(v), 1<<20)).Decode(&s)
	return s, err
}
