package egress

import (
	"bufio"
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"

	"golang.org/x/net/proxy"
)

// DefaultUpstreamHosts are the hosts an upstream proxy carries when
// AGNTS_EGRESS_UPSTREAM_HOSTS is not set: Muse's, whose models Meta may
// not serve to the server's own network.
var DefaultUpstreamHosts = []string{"api.meta.ai", "auth.meta.com"}

// Upstream sends connections to some hosts through another proxy (SOCKS5
// or an HTTP proxy that takes CONNECT) instead of dialing them directly.
type Upstream struct {
	url   *url.URL
	hosts []string
	dial  func(ctx context.Context, network, addr string) (net.Conn, error)
}

// ParseUpstream reads AGNTS_EGRESS_UPSTREAM (socks5://[user:pass@]host:port
// or http://[user:pass@]host:port) and the hosts it carries (comma
// separated, "." or "*." for subdomains; empty for DefaultUpstreamHosts).
func ParseUpstream(raw, hosts string) (*Upstream, error) {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil || u.Host == "" || u.Port() == "" {
		return nil, fmt.Errorf("AGNTS_EGRESS_UPSTREAM must be socks5://host:port or http://host:port")
	}
	list := DefaultUpstreamHosts
	if strings.TrimSpace(hosts) != "" {
		list = strings.Split(hosts, ",")
	}
	up := &Upstream{url: u, hosts: cleanList(list)}
	base := &net.Dialer{Timeout: 15 * time.Second}
	switch u.Scheme {
	case "socks5", "socks5h":
		var auth *proxy.Auth
		if u.User != nil {
			pw, _ := u.User.Password()
			auth = &proxy.Auth{User: u.User.Username(), Password: pw}
		}
		d, err := proxy.SOCKS5("tcp", u.Host, auth, base)
		if err != nil {
			return nil, err
		}
		cd, ok := d.(proxy.ContextDialer)
		if !ok {
			return nil, errors.New("socks5 dialer without context")
		}
		up.dial = cd.DialContext
	case "http":
		up.dial = func(ctx context.Context, network, addr string) (net.Conn, error) {
			return connectVia(ctx, base, u, addr)
		}
	default:
		return nil, fmt.Errorf("AGNTS_EGRESS_UPSTREAM: unsupported scheme %q (socks5 or http)", u.Scheme)
	}
	return up, nil
}

// String is the upstream without its password, for logs.
func (u *Upstream) String() string { return u.url.Redacted() + " for " + strings.Join(u.hosts, ",") }

// carries reports whether connections to host go through the upstream.
func (u *Upstream) carries(host string) bool { return matches(u.hosts, strings.ToLower(host)) }

// matches is the allowlist's rule: an exact host, or a subdomain of an
// entry that starts with ".".
func matches(list []string, host string) bool {
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

// SetUpstream routes the hosts u carries through it; the allowlist still
// decides what may be reached at all. The monitor it returns checks the
// upstream every 30 seconds once Run, and serves StatusPath.
func (p *Proxy) SetUpstream(u *Upstream) *Monitor {
	m := NewMonitor(u, 30*time.Second)
	p.monitor = m
	direct := p.dial
	p.dial = func(ctx context.Context, network, addr string) (net.Conn, error) {
		host, _, err := net.SplitHostPort(addr)
		if err == nil && u.carries(host) {
			c, err := u.dial(ctx, network, addr)
			m.carried(err)
			if err != nil {
				p.log.Warn("egress: upstream proxy", "target", addr, "err", err)
				return nil, friendly(err)
			}
			return c, nil
		}
		return direct(ctx, network, addr)
	}
	return m
}

// connectVia opens a tunnel to addr through an HTTP proxy.
func connectVia(ctx context.Context, d *net.Dialer, pu *url.URL, addr string) (net.Conn, error) {
	c, err := d.DialContext(ctx, "tcp", pu.Host)
	if err != nil {
		return nil, err
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = c.SetDeadline(dl)
	} else {
		_ = c.SetDeadline(time.Now().Add(15 * time.Second))
	}
	req := "CONNECT " + addr + " HTTP/1.1\r\nHost: " + addr + "\r\n"
	if pu.User != nil {
		pw, _ := pu.User.Password()
		req += "Proxy-Authorization: Basic " + base64.StdEncoding.EncodeToString([]byte(pu.User.Username()+":"+pw)) + "\r\n"
	}
	if _, err := c.Write([]byte(req + "\r\n")); err != nil {
		_ = c.Close()
		return nil, err
	}
	br := bufio.NewReader(c)
	res, err := http.ReadResponse(br, &http.Request{Method: http.MethodConnect})
	if err != nil {
		_ = c.Close()
		return nil, err
	}
	_ = res.Body.Close()
	if res.StatusCode != http.StatusOK {
		_ = c.Close()
		return nil, fmt.Errorf("upstream proxy refused CONNECT %s: %s", addr, res.Status)
	}
	_ = c.SetDeadline(time.Time{})
	if br.Buffered() > 0 {
		return &bufferedConn{Conn: c, r: br}, nil
	}
	return c, nil
}

type bufferedConn struct {
	net.Conn
	r *bufio.Reader
}

func (b *bufferedConn) Read(p []byte) (int, error) { return b.r.Read(p) }
