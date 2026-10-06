// Package egress is a forward proxy with a domain allowlist. Run containers
// sit on an internal Docker network whose only way out is this proxy, so
// code from a ticket can reach the Claude API, the git hosts and package
// registries, and nothing else.
package egress

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

// DefaultAllow is used when AGNTS_EGRESS_ALLOW is not set.
var DefaultAllow = []string{
	"api.anthropic.com", "statsig.anthropic.com", "sentry.io", ".sentry.io",
	"github.com", ".github.com", ".githubusercontent.com", "gitlab.com",
	"proxy.golang.org", "sum.golang.org", "storage.googleapis.com",
	"registry.npmjs.org", "registry.yarnpkg.com",
	"pypi.org", "files.pythonhosted.org",
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
	if !p.Allowed(host) || !p.ports[port] {
		p.deny(w, r.URL.Host)
		return
	}
	out := r.Clone(r.Context())
	out.RequestURI = ""
	out.Header.Del("Proxy-Authorization")
	out.Header.Del("Proxy-Connection")
	resp, err := (&http.Transport{DialContext: p.dial, Proxy: nil}).RoundTrip(out)
	if err != nil {
		http.Error(w, "upstream error", http.StatusBadGateway)
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
	http.Error(w, "agnts egress: "+target+" is not on the allowlist (AGNTS_EGRESS_ALLOW)", http.StatusForbidden)
}

func (p *Proxy) connect(w http.ResponseWriter, r *http.Request) {
	host, port, err := net.SplitHostPort(r.Host)
	if err != nil || !p.Allowed(host) || !p.ports[port] {
		p.deny(w, r.Host)
		return
	}
	upstream, err := p.dial(r.Context(), "tcp", net.JoinHostPort(host, port))
	if err != nil {
		http.Error(w, "upstream unreachable", http.StatusBadGateway)
		return
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
		if c, ok := upstream.(*net.TCPConn); ok {
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
