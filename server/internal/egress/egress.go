// Package egress is a forward proxy with a domain allowlist. Run containers
// sit on an internal Docker network whose only way out is this proxy, so
// code from a ticket can reach the Claude API, the git hosts and package
// registries, and nothing else.
package egress

import (
	"context"
	"io"
	"log/slog"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

// DefaultAllow is used when HIRO_EGRESS_ALLOW is not set.
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
	ports map[string]bool
	log   *slog.Logger
	dial  func(ctx context.Context, network, addr string) (net.Conn, error)
}

// New returns a proxy for the allowlist. Entries starting with "*." or "."
// match subdomains.
func New(allow []string, log *slog.Logger) *Proxy {
	clean := make([]string, 0, len(allow))
	for _, a := range allow {
		a = strings.ToLower(strings.TrimSpace(a))
		a = strings.TrimPrefix(a, "*")
		if a != "" {
			clean = append(clean, a)
		}
	}
	d := &net.Dialer{Timeout: 15 * time.Second}
	return &Proxy{allow: clean, ports: map[string]bool{"443": true, "80": true}, log: log, dial: d.DialContext}
}

// Allowed reports whether host may be reached.
func (p *Proxy) Allowed(host string) bool {
	host = strings.ToLower(strings.TrimSuffix(host, "."))
	if net.ParseIP(host) != nil {
		return false // names only: an IP bypasses the allowlist
	}
	for _, a := range p.allow {
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
	http.Error(w, "hiro egress: "+target+" is not on the allowlist (HIRO_EGRESS_ALLOW)", http.StatusForbidden)
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
