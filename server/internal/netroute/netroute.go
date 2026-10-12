// Package netroute sends the server's own HTTP calls (GitLab, Jira and
// Plane APIs, git fetch and push) for a host on a workspace's private
// network through the gateway. Transport is the round tripper those
// clients use: it reads the workspace from the request's context and
// falls back to http.DefaultTransport for everything else, so nothing
// changes until a Router is installed.
package netroute

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"net"
	"net/http"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"agnts/internal/domain"
	"agnts/internal/privnet"
)

// Network is what the router knows about one private network.
type Network struct {
	ID      int64
	Name    string
	Kind    privnet.Kind
	Routes  []privnet.Route
	CA      *x509.CertPool // the network's CA bundle added to the system roots; nil: system roots
	Version string
}

// Router decides which requests go through the gateway, and through which
// of the workspace's networks.
type Router struct {
	gateway, secret string
	nets            atomic.Pointer[map[int64][]Network] // by workspace
	mu              sync.Mutex
	transports      map[int64]*netTransport // by network
}

type netTransport struct {
	version string
	t       *http.Transport
}

// New returns a router that dials the gateway at addr (host:port).
func New(gateway, secret string) *Router {
	r := &Router{gateway: gateway, secret: secret, transports: map[int64]*netTransport{}}
	empty := map[int64][]Network{}
	r.nets.Store(&empty)
	return r
}

// Enabled reports whether a gateway is configured.
func (r *Router) Enabled() bool { return r != nil && r.gateway != "" }

// Set replaces every workspace's networks (enabled ones only).
func (r *Router) Set(nets map[int64][]Network) {
	r.nets.Store(&nets)
	live := map[int64]string{}
	for _, list := range nets {
		for _, n := range list {
			live[n.ID] = n.Version
		}
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	for id, t := range r.transports {
		if v, ok := live[id]; !ok || v != t.version {
			t.t.CloseIdleConnections()
			delete(r.transports, id)
		}
	}
}

// Networks returns a workspace's enabled networks.
func (r *Router) Networks(ws int64) []Network {
	return (*r.nets.Load())[ws]
}

// Network returns one of a workspace's enabled networks.
func (r *Router) Network(ws, id int64) (Network, bool) {
	for _, n := range r.Networks(ws) {
		if n.ID == id {
			return n, true
		}
	}
	return Network{}, false
}

// Sets returns a workspace's networks' routes, for privnet.Pick.
func Sets(nets []Network) []privnet.RouteSet {
	out := make([]privnet.RouteSet, 0, len(nets))
	for _, n := range nets {
		out = append(out, privnet.RouteSet{ID: n.ID, Name: n.Name, Routes: n.Routes})
	}
	return out
}

// Pick returns the network that carries host:port for ws: the one with the
// most specific matching route.
func (r *Router) Pick(ws int64, host string, port int) (Network, bool) {
	if r == nil || ws <= 0 || r.gateway == "" {
		return Network{}, false
	}
	nets := r.Networks(ws)
	id, ok := privnet.Pick(Sets(nets), host, port)
	if !ok {
		return Network{}, false
	}
	return r.Network(ws, id)
}

// Match reports whether host:port goes through one of ws's networks.
func (r *Router) Match(ws int64, host string, port int) bool {
	_, ok := r.Pick(ws, host, port)
	return ok
}

// Dial connects to addr through one of ws's networks.
func (r *Router) Dial(ctx context.Context, ws, network int64, addr, source string) (net.Conn, privnet.DialInfo, error) {
	return privnet.DialGateway(ctx, r.gateway, r.secret, privnet.DialRequest{Workspace: ws, Network: network, Target: addr, Source: source})
}

// TLSConfig is the client TLS config for a host on one of ws's networks:
// the system roots plus that network's CA bundle.
func (r *Router) TLSConfig(ws, network int64, serverName string) *tls.Config {
	c := &tls.Config{ServerName: serverName, MinVersion: tls.VersionTLS12}
	if n, ok := r.Network(ws, network); ok && n.CA != nil {
		c.RootCAs = n.CA
	}
	return c
}

func (r *Router) transport(ws int64, n Network) *http.Transport {
	r.mu.Lock()
	defer r.mu.Unlock()
	if t, ok := r.transports[n.ID]; ok && t.version == n.Version {
		return t.t
	}
	t := &http.Transport{
		// A connection pool per network: gitlab.corp.local in one network
		// is not the same server as in another.
		DialContext: func(ctx context.Context, _, addr string) (net.Conn, error) {
			c, _, err := r.Dial(ctx, ws, n.ID, addr, "server")
			return c, err
		},
		TLSClientConfig:       &tls.Config{RootCAs: n.CA, MinVersion: tls.VersionTLS12},
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          20,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   15 * time.Second,
		ExpectContinueTimeout: time.Second,
	}
	r.transports[n.ID] = &netTransport{version: n.Version, t: t}
	return t
}

// RoundTrip sends req through the gateway when its host is on one of the
// workspace's private networks, and directly otherwise.
func (r *Router) RoundTrip(req *http.Request) (*http.Response, error) {
	ws := domain.WorkspaceOf(req.Context())
	if n, ok := r.Pick(ws, req.URL.Hostname(), portOf(req)); ok {
		return r.transport(ws, n).RoundTrip(req)
	}
	return http.DefaultTransport.RoundTrip(req)
}

func portOf(req *http.Request) int {
	if p := req.URL.Port(); p != "" {
		n, _ := strconv.Atoi(p)
		return n
	}
	if req.URL.Scheme == "http" {
		return 80
	}
	return 443
}

var installed atomic.Pointer[Router]

// Install makes Transport route through r.
func Install(r *Router) { installed.Store(r) }

// Installed returns the router Install set, or nil.
func Installed() *Router { return installed.Load() }

type transport struct{}

func (transport) RoundTrip(req *http.Request) (*http.Response, error) {
	if r := installed.Load(); r != nil {
		return r.RoundTrip(req)
	}
	return http.DefaultTransport.RoundTrip(req)
}

// Transport is the round tripper for the server's calls to hosts a
// workspace may keep on its private network.
var Transport http.RoundTripper = transport{}

// Client returns an HTTP client with Transport and a timeout.
func Client(timeout time.Duration) *http.Client {
	return &http.Client{Transport: Transport, Timeout: timeout}
}
