// Package egress is a forward proxy with a domain allowlist. Run containers
// sit on an internal Docker network whose only way out is this proxy, so
// code from a ticket can reach the Claude API, the git hosts and package
// registries, and nothing else.
package egress

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"agnts/internal/domain"
)

// DefaultAllow is used when AGNTS_EGRESS_ALLOW is not set.
var DefaultAllow = []string{
	// Claude Code, and git hosts (GitHub release assets carry most
	// prebuilt toolchains: Python, Temurin, aqua and ubi tools).
	"api.anthropic.com", "statsig.anthropic.com", "sentry.io", ".sentry.io",
	"github.com", ".github.com", ".githubusercontent.com", "gitlab.com",
	// mise: its version indexes (mise-versions, mise-java) and the sigstore
	// trust root it checks attestations against
	".jdx.dev", "tuf-repo-cdn.sigstore.dev",
	// Go
	"proxy.golang.org", "sum.golang.org", "storage.googleapis.com", "go.dev", "dl.google.com",
	// JavaScript: Node, npm, Yarn, Bun, Deno, JSR
	"nodejs.org", "registry.npmjs.org", "registry.yarnpkg.com", "repo.yarnpkg.com", "jsr.io", "dl.deno.land",
	// Python
	"pypi.org", "files.pythonhosted.org", "downloads.python.org",
	// Rust (rustup's installer, then its channels)
	"sh.rustup.rs", "static.rust-lang.org", "crates.io", "index.crates.io", "static.crates.io",
	// JVM: Temurin, Maven Central, Gradle, sbt
	"api.adoptium.net", "repo.maven.apache.org", "repo1.maven.org", "plugins.gradle.org", "services.gradle.org",
	"downloads.gradle.org", "dlcdn.apache.org", "archive.apache.org", "repo.scala-sbt.org", "repo.typesafe.com",
	// .NET (dot.net serves the install script)
	"dot.net", "ci.dot.net", "builds.dotnet.microsoft.com", "dotnetcli.azureedge.net", "dotnetcli.blob.core.windows.net", "api.nuget.org",
	// Ruby, PHP
	"rubygems.org", "index.rubygems.org", "repo.packagist.org", "packagist.org",
	// Elixir and Erlang, Dart, Swift, Zig, Haskell, Julia
	"repo.hex.pm", "builds.hex.pm", "hex.pm", "pub.dev", "download.swift.org", "ziglang.org",
	"hackage.haskell.org", "downloads.haskell.org", "julialang-s3.julialang.org", "pkg.julialang.org",
}

// Proxy implements an HTTP forward proxy (CONNECT for https, absolute
// URLs for plain http) restricted to an allowlist.
type Proxy struct {
	allow []string // "host" for an exact match, ".domain" for subdomains
	// extra is the list added in Settings (a staging API for previews),
	// refreshed by Follow.
	extra atomic.Pointer[[]string]
	ports map[string]bool
	log   *slog.Logger
	dial  func(ctx context.Context, network, addr string) (net.Conn, error)
	// router and viaGateway send a run's connections to a host on its
	// workspace's private network through the gateway (nil: none). The
	// router also answers grants: a host one run container alone may reach
	// (a Swagger test's base URL).
	router     Router
	viaGateway GatewayDial
	// lookup and localNets are the resolver and the proxy's own networks,
	// for the address check of granted hosts; tests replace them.
	lookup    func(ctx context.Context, host string) ([]net.IP, error)
	localNets func() []*net.IPNet
}

// Private is a decision to send a connection through one of a
// workspace's private networks, or (Grant) straight out to a host granted
// to that one run container.
type Private struct {
	Workspace int64  `json:"workspace"`
	Network   int64  `json:"network,omitempty"`
	Ticket    string `json:"ticket,omitempty"`
	Grant     bool   `json:"grant,omitempty"`
}

// Router decides whether the run container at clientIP reaches host:port
// through its workspace's private network.
type Router interface {
	Route(ctx context.Context, clientIP, host string, port int) (Private, bool, error)
}

// GatewayDial connects to target (host:port) through the gateway.
type GatewayDial func(ctx context.Context, p Private, target string) (net.Conn, error)

// SetPrivate turns on route lookups: private networks (when dial is not
// nil) and grants.
func (p *Proxy) SetPrivate(r Router, dial GatewayDial) { p.router, p.viaGateway = r, dial }

// dialerFor is how a connection the router decided on is made.
func (p *Proxy) dialerFor(d Private) (func(ctx context.Context, network, addr string) (net.Conn, error), bool) {
	if d.Grant {
		return p.grantDial, true
	}
	if p.viaGateway == nil {
		return nil, false
	}
	return func(ctx context.Context, _, addr string) (net.Conn, error) { return p.viaGateway(ctx, d, addr) }, true
}

// ErrInternalAddress refuses a granted host that resolves to an address
// inside: loopback, private, CGNAT, link-local, unique-local, multicast,
// or a network the proxy itself is on (agnts's Docker networks).
var ErrInternalAddress = errors.New("resolves to an internal address")

// grantDial connects to a granted host. Grants come from whoever creates
// a ticket, so unlike the admin's allowlist the name is resolved here, every
// address is checked, and the connection goes to the exact address checked:
// a second DNS answer cannot swap in an internal one (DNS rebinding).
func (p *Proxy) grantDial(ctx context.Context, network, addr string) (net.Conn, error) {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return nil, err
	}
	ips, err := p.resolve(ctx, host)
	if err != nil {
		return nil, err
	}
	if len(ips) == 0 {
		return nil, fmt.Errorf("%s: no address", host)
	}
	local := p.ownNets()
	for _, ip := range ips {
		if !domain.IsPublicIP(ip) || inNets(ip, local) {
			p.log.Warn("egress: granted host refused", "host", host, "ip", ip.String())
			return nil, fmt.Errorf("%s %w (%s)", host, ErrInternalAddress, ip)
		}
	}
	var last error
	for _, ip := range ips {
		c, err := p.dial(ctx, network, net.JoinHostPort(ip.String(), port))
		if err == nil {
			return c, nil
		}
		last = err
	}
	return nil, last
}

func (p *Proxy) resolve(ctx context.Context, host string) ([]net.IP, error) {
	if ip := net.ParseIP(strings.Trim(host, "[]")); ip != nil {
		return []net.IP{ip}, nil
	}
	if p.lookup != nil {
		return p.lookup(ctx, host)
	}
	addrs, err := net.DefaultResolver.LookupIPAddr(ctx, host)
	if err != nil {
		return nil, err
	}
	out := make([]net.IP, 0, len(addrs))
	for _, a := range addrs {
		out = append(out, a.IP)
	}
	return out, nil
}

// ownNets are the networks the proxy's interfaces are on.
func (p *Proxy) ownNets() []*net.IPNet {
	if p.localNets != nil {
		return p.localNets()
	}
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return nil
	}
	var out []*net.IPNet
	for _, a := range addrs {
		if n, ok := a.(*net.IPNet); ok {
			out = append(out, n)
		}
	}
	return out
}

func inNets(ip net.IP, nets []*net.IPNet) bool {
	for _, n := range nets {
		if n.Contains(ip) {
			return true
		}
	}
	return false
}

// private asks the router about a connection from r's client; hosts on the
// built-in allowlist never go through a private network.
func (p *Proxy) private(r *http.Request, host string, port int) (Private, bool) {
	if p.router == nil || p.static(host) {
		return Private{}, false
	}
	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return Private{}, false
	}
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()
	d, ok, err := p.router.Route(ctx, ip, host, port)
	if err != nil {
		p.log.Warn("egress: private route lookup", "host", host, "err", err)
		return Private{}, false
	}
	return d, ok
}

// static reports whether host is on the built-in (or configured) list.
func (p *Proxy) static(host string) bool {
	host = strings.ToLower(strings.TrimSuffix(host, "."))
	for _, a := range p.allow {
		if strings.HasPrefix(a, ".") && strings.HasSuffix(host, a) || host == a {
			return true
		}
	}
	return false
}

// New returns a proxy for the allowlist. Entries starting with "*." or "."
// match subdomains.
func New(allow []string, log *slog.Logger) *Proxy {
	d := &net.Dialer{Timeout: 15 * time.Second}
	return &Proxy{allow: cleanList(allow), ports: map[string]bool{"443": true, "80": true}, log: log, dial: d.DialContext}
}

func cleanList(allow []string) []string {
	clean := make([]string, 0, len(allow))
	for _, a := range allow {
		a = strings.ToLower(strings.TrimSpace(a))
		a = strings.TrimPrefix(a, "*")
		if a != "" {
			clean = append(clean, a)
		}
	}
	return clean
}

// SetExtra replaces the hosts allowed besides the static list.
func (p *Proxy) SetExtra(allow []string) {
	l := cleanList(allow)
	p.extra.Store(&l)
}

// Follow polls url every interval for the extra allowlist (one host per
// line) until ctx ends. A failed poll keeps the last list.
func (p *Proxy) Follow(ctx context.Context, url string, every time.Duration) {
	c := &http.Client{Timeout: 10 * time.Second}
	var last string
	for {
		if list, err := fetchList(ctx, c, url); err != nil {
			if ctx.Err() == nil {
				p.log.Warn("egress: fetch the extra allowlist", "url", url, "err", err)
			}
		} else {
			if joined := strings.Join(list, ","); joined != last {
				last = joined
				p.log.Info("egress: extra allowlist", "allow", joined)
			}
			p.SetExtra(list)
		}
		select {
		case <-ctx.Done():
			return
		case <-time.After(every):
		}
	}
}

func fetchList(ctx context.Context, c *http.Client, url string) ([]string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	resp, err := c.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("status %d", resp.StatusCode)
	}
	b, err := io.ReadAll(io.LimitReader(resp.Body, 64<<10))
	if err != nil {
		return nil, err
	}
	var out []string
	for _, l := range strings.Split(string(b), "\n") {
		if l = strings.TrimSpace(l); l != "" && !strings.HasPrefix(l, "#") {
			out = append(out, l)
		}
	}
	return out, nil
}

// Allowed reports whether host may be reached.
func (p *Proxy) Allowed(host string) bool {
	host = strings.ToLower(strings.TrimSuffix(host, "."))
	if net.ParseIP(host) != nil {
		return false // names only: an IP bypasses the allowlist
	}
	list := p.allow
	if extra := p.extra.Load(); extra != nil {
		list = append(append([]string{}, p.allow...), (*extra)...)
	}
	for _, a := range list {
		if strings.HasPrefix(a, ".") {
			if strings.HasSuffix(host, a) {
				return true
			}
		} else if host == a {
			return true
		}
	}
	return false
}

func (p *Proxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodConnect {
		p.connect(w, r)
		return
	}
	if r.URL.Scheme != "http" || r.URL.Host == "" {
		http.Error(w, "only proxy requests are served", http.StatusBadRequest)
		return
	}
	host, port := r.URL.Hostname(), r.URL.Port()
	if port == "" {
		port = "80"
	}
	dial := p.dial
	if pn, err := strconv.Atoi(port); err == nil {
		if d, ok := p.private(r, host, pn); ok {
			if dial, ok = p.dialerFor(d); !ok {
				p.deny(w, r.URL.Host)
				return
			}
		} else if !p.Allowed(host) || !p.ports[port] {
			p.deny(w, r.URL.Host)
			return
		}
	} else {
		p.deny(w, r.URL.Host)
		return
	}
	out := r.Clone(r.Context())
	out.RequestURI = ""
	out.Header.Del("Proxy-Authorization")
	out.Header.Del("Proxy-Connection")
	resp, err := (&http.Transport{DialContext: dial, Proxy: nil}).RoundTrip(out)
	if err != nil {
		msg := "upstream error"
		if errors.Is(err, ErrInternalAddress) {
			msg = "agnts egress: " + err.Error()
		}
		http.Error(w, msg, http.StatusBadGateway)
		return
	}
	defer func() { _ = resp.Body.Close() }()
	for k, vs := range resp.Header {
		for _, v := range vs {
			w.Header().Add(k, v)
		}
	}
	w.WriteHeader(resp.StatusCode)
	_, _ = io.Copy(w, resp.Body)
}

func (p *Proxy) deny(w http.ResponseWriter, target string) {
	p.log.Warn("egress denied", "target", target)
	http.Error(w, "agnts egress: "+target+" is not on the allowlist (AGNTS_EGRESS_ALLOW) or the workspace's private network routes", http.StatusForbidden)
}

func (p *Proxy) connect(w http.ResponseWriter, r *http.Request) {
	host, port, err := net.SplitHostPort(r.Host)
	pn, perr := strconv.Atoi(port)
	if err != nil || perr != nil {
		p.deny(w, r.Host)
		return
	}
	var upstream net.Conn
	if d, ok := p.private(r, host, pn); ok {
		dial, ok := p.dialerFor(d)
		if !ok {
			p.deny(w, r.Host)
			return
		}
		if upstream, err = dial(r.Context(), "tcp", net.JoinHostPort(host, port)); err != nil {
			p.log.Warn("egress: routed connection", "target", r.Host, "workspace", d.Workspace, "grant", d.Grant, "err", err)
			http.Error(w, "agnts egress: "+err.Error(), http.StatusBadGateway)
			return
		}
	} else {
		if !p.Allowed(host) || !p.ports[port] {
			p.deny(w, r.Host)
			return
		}
		if upstream, err = p.dial(r.Context(), "tcp", net.JoinHostPort(host, port)); err != nil {
			http.Error(w, "upstream unreachable", http.StatusBadGateway)
			return
		}
	}
	hj, ok := w.(http.Hijacker)
	if !ok {
		_ = upstream.Close()
		http.Error(w, "hijacking not supported", http.StatusInternalServerError)
		return
	}
	client, buf, err := hj.Hijack()
	if err != nil {
		_ = upstream.Close()
		return
	}
	_, _ = client.Write([]byte("HTTP/1.1 200 Connection Established\r\n\r\n"))
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		if buf.Reader.Buffered() > 0 {
			_, _ = io.CopyN(upstream, buf, int64(buf.Reader.Buffered()))
		}
		_, _ = io.Copy(upstream, client)
		if c, ok := upstream.(interface{ CloseWrite() error }); ok {
			_ = c.CloseWrite()
		}
	}()
	go func() {
		defer wg.Done()
		_, _ = io.Copy(client, upstream)
		_ = client.Close()
	}()
	wg.Wait()
	_ = upstream.Close()
}

// HTTPRouter asks agnts's internal listener (GET url?ip=&host=&port=)
// whether a connection goes through a private network.
type HTTPRouter struct {
	URL, Secret string
	Client      *http.Client
}

// Route implements Router.
func (h HTTPRouter) Route(ctx context.Context, clientIP, host string, port int) (Private, bool, error) {
	q := url.Values{"ip": {clientIP}, "host": {host}, "port": {strconv.Itoa(port)}}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, h.URL+"?"+q.Encode(), nil)
	if err != nil {
		return Private{}, false, err
	}
	req.Header.Set("Authorization", "Bearer "+h.Secret)
	c := h.Client
	if c == nil {
		c = http.DefaultClient
	}
	resp, err := c.Do(req)
	if err != nil {
		return Private{}, false, err
	}
	defer func() { _ = resp.Body.Close() }()
	switch resp.StatusCode {
	case http.StatusOK:
		var d Private
		if err := json.NewDecoder(io.LimitReader(resp.Body, 4096)).Decode(&d); err != nil {
			return Private{}, false, err
		}
		return d, d.Workspace > 0 || d.Grant, nil
	case http.StatusNotFound:
		return Private{}, false, nil
	default:
		return Private{}, false, fmt.Errorf("route lookup: status %d", resp.StatusCode)
	}
}
