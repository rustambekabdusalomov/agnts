// Package logsource reads the logging systems people already run (Loki,
// Elasticsearch, OpenSearch, Graylog) and parses what their log shippers
// push to agnts. Every connector returns domain.LogEntry values; what to
// make of them is the logwatch package's job.
package logsource

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/netroute"
)

// Router finds the private network that carries a host for a workspace
// (netroute.Router).
type Router interface {
	Pick(ws int64, host string, port int) (netroute.Network, bool)
	Dial(ctx context.Context, ws, network int64, addr, source string) (net.Conn, error)
}

// routerAdapter drops the dial info netroute returns.
type routerAdapter struct{ r *netroute.Router }

func (a routerAdapter) Pick(ws int64, host string, port int) (netroute.Network, bool) {
	return a.r.Pick(ws, host, port)
}

func (a routerAdapter) Dial(ctx context.Context, ws, network int64, addr, source string) (net.Conn, error) {
	c, _, err := a.r.Dial(ctx, ws, network, addr, source)
	return c, err
}

// NetrouteRouter adapts the installed private-network router; nil when
// there is none.
func NetrouteRouter(r *netroute.Router) Router {
	if r == nil || !r.Enabled() {
		return nil
	}
	return routerAdapter{r}
}

// Errors the client returns before sending anything.
var (
	ErrPrivateAddress = errors.New("the address is on a private network agnts doesn't reach: add a private network with a route to it (Workspace settings → Private networks), or use a push source")
	ErrPlainHTTP      = errors.New("a public address must use https: the credentials would cross the internet in clear")
)

// Dialer opens connections to log sources: through the workspace's
// private network when one has a route to the host, else straight to a
// public address checked when the connection is made (so DNS can't swap
// in a private one after a check).
type Dialer struct {
	Router Router
	// Resolve looks a host up; nil: the system resolver.
	Resolve func(ctx context.Context, host string) ([]net.IP, error)
	// AllowPrivate lets tests reach httptest servers on loopback.
	AllowPrivate bool
	// Allow are hosts (names) and CIDRs the server's operator lets the log
	// watcher reach directly although private, over http too: a logging
	// system next to agnts in its own network.
	Allow   []string
	Timeout time.Duration
}

// Client is an HTTP client for one source, and the private network it
// goes through (nil: none).
type Client struct {
	HTTP      *http.Client
	NetworkID *int64
	Base      *url.URL
}

// MaxBody caps what is read of one response.
const MaxBody = 32 << 20

// ReadBody reads a response body up to MaxBody.
func ReadBody(r io.Reader) ([]byte, error) {
	b, err := io.ReadAll(io.LimitReader(r, MaxBody+1))
	if err != nil {
		return nil, err
	}
	if len(b) > MaxBody {
		return nil, fmt.Errorf("response larger than %d MB", MaxBody>>20)
	}
	return b, nil
}

// For returns a client for src in workspace ws.
func (d Dialer) For(ws int64, src domain.LogSource) (*Client, error) {
	u, err := url.Parse(src.Address)
	if err != nil || u.Host == "" || (u.Scheme != "http" && u.Scheme != "https") {
		return nil, fmt.Errorf("address %q is not an http(s) URL", src.Address)
	}
	host := u.Hostname()
	port := 443
	if u.Scheme == "http" {
		port = 80
	}
	if p := u.Port(); p != "" {
		port, _ = strconv.Atoi(p)
	}
	tlsCfg := &tls.Config{MinVersion: tls.VersionTLS12, ServerName: host}
	out := &Client{Base: u}
	var dial func(ctx context.Context, network, addr string) (net.Conn, error)
	var roots *x509.CertPool
	if n, ok := d.pick(ws, host, port); ok {
		id := n.ID
		out.NetworkID = &id
		roots = n.CA
		dial = func(ctx context.Context, _, addr string) (net.Conn, error) {
			return d.Router.Dial(ctx, ws, id, addr, "logs")
		}
	} else if d.allowedName(host) {
		var dialer net.Dialer
		dial = func(ctx context.Context, network, addr string) (net.Conn, error) {
			return dialer.DialContext(ctx, network, addr)
		}
	} else {
		if u.Scheme == "http" && !d.AllowPrivate && !d.allowedIP(net.ParseIP(host)) {
			return nil, ErrPlainHTTP
		}
		if ip := net.ParseIP(host); ip != nil && !d.AllowPrivate && !domain.IsPublicIP(ip) && !d.allowedIP(ip) {
			return nil, ErrPrivateAddress
		}
		dial = d.publicDial
	}
	if src.CAPEM != "" {
		if roots == nil {
			if roots, err = x509.SystemCertPool(); err != nil || roots == nil {
				roots = x509.NewCertPool()
			}
		} else {
			roots = roots.Clone()
		}
		if !roots.AppendCertsFromPEM([]byte(src.CAPEM)) {
			return nil, errors.New("the CA certificate could not be read")
		}
	}
	tlsCfg.RootCAs = roots
	timeout := d.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	out.HTTP = &http.Client{
		Timeout: timeout,
		Transport: &http.Transport{
			DialContext:           dial,
			TLSClientConfig:       tlsCfg,
			ForceAttemptHTTP2:     true,
			MaxIdleConns:          4,
			IdleConnTimeout:       90 * time.Second,
			TLSHandshakeTimeout:   15 * time.Second,
			ResponseHeaderTimeout: timeout,
		},
		// A redirect to another host would send the credentials there.
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			if len(via) >= 3 || req.URL.Host != u.Host {
				return errors.New("redirect to another host refused")
			}
			return nil
		},
	}
	return out, nil
}

// allowedName: the operator allows this host name as it is.
func (d Dialer) allowedName(host string) bool {
	for _, a := range d.Allow {
		if !strings.Contains(a, "/") && strings.EqualFold(a, host) {
			return true
		}
	}
	return false
}

// allowedIP: the operator allows a CIDR (or an address) holding ip.
func (d Dialer) allowedIP(ip net.IP) bool {
	if ip == nil {
		return false
	}
	for _, a := range d.Allow {
		if _, n, err := net.ParseCIDR(a); err == nil && n.Contains(ip) {
			return true
		}
		if x := net.ParseIP(a); x != nil && x.Equal(ip) {
			return true
		}
	}
	return false
}

func (d Dialer) pick(ws int64, host string, port int) (netroute.Network, bool) {
	if d.Router == nil {
		return netroute.Network{}, false
	}
	return d.Router.Pick(ws, host, port)
}

// publicDial resolves the host and connects only to a public address.
func (d Dialer) publicDial(ctx context.Context, network, addr string) (net.Conn, error) {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return nil, err
	}
	var ips []net.IP
	if ip := net.ParseIP(host); ip != nil {
		ips = []net.IP{ip}
	} else if d.Resolve != nil {
		ips, err = d.Resolve(ctx, host)
	} else {
		var addrs []net.IPAddr
		addrs, err = net.DefaultResolver.LookupIPAddr(ctx, host)
		for _, a := range addrs {
			ips = append(ips, a.IP)
		}
	}
	if err != nil {
		return nil, err
	}
	if len(ips) == 0 {
		return nil, fmt.Errorf("%s has no address", host)
	}
	for _, ip := range ips {
		if !d.AllowPrivate && !domain.IsPublicIP(ip) && !d.allowedIP(ip) {
			return nil, ErrPrivateAddress
		}
	}
	var dialer net.Dialer
	var last error
	for _, ip := range ips {
		c, err := dialer.DialContext(ctx, network, net.JoinHostPort(ip.String(), port))
		if err == nil {
			return c, nil
		}
		last = err
	}
	return nil, last
}

// Auth adds a source's credentials to a request.
func Auth(req *http.Request, a domain.LogAuth) {
	switch a.Kind {
	case "basic":
		req.SetBasicAuth(a.User, a.Password)
	case "bearer":
		req.Header.Set("Authorization", "Bearer "+a.Token)
	case "apikey":
		req.Header.Set("Authorization", "ApiKey "+a.Token)
	}
	if a.Tenant != "" {
		req.Header.Set("X-Scope-OrgID", a.Tenant)
	}
}

// HTTPError is a non-2xx answer from a source.
type HTTPError struct {
	Status int
	Body   string
}

func (e *HTTPError) Error() string {
	body := e.Body
	if len(body) > 300 {
		body = body[:300] + "…"
	}
	if body == "" {
		return fmt.Sprintf("HTTP %d", e.Status)
	}
	return fmt.Sprintf("HTTP %d: %s", e.Status, body)
}

// Unauthorized reports whether err is the source refusing the
// credentials.
func Unauthorized(err error) bool {
	var h *HTTPError
	return errors.As(err, &h) && (h.Status == http.StatusUnauthorized || h.Status == http.StatusForbidden)
}
