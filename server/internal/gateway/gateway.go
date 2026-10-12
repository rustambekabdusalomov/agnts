// Package gateway is the service that holds every workspace's private
// network tunnel: WireGuard (in user space, on a gVisor netstack),
// OpenVPN (through the workspace's sidecar container) and agnts-link
// connector sessions. The egress proxy and agnts dial through it with an
// HTTP CONNECT naming the workspace; nothing else can (the shared gateway
// secret). It is the only process that opens the sealed VPN configs.
package gateway

import (
	"bufio"
	"bytes"
	"context"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"agnts/internal/privnet"
	"agnts/internal/secret"
)

// Config configures the gateway.
type Config struct {
	Secret string // shared with agnts and the egress proxy
	// AgntsURL is agnts's internal listener (http://agnts:8081): the
	// networks come from /gateway/networks, reports go to /gateway/report.
	AgntsURL string
	// HooksURL is agnts's main listener (http://agnts:8080), where webhooks
	// relayed by agnts-link are delivered.
	HooksURL string
	// SyncEvery is how often the networks are read again.
	SyncEvery time.Duration
	// SidecarPort is the SOCKS port of the OpenVPN sidecars; the status
	// page is on the next port.
	SidecarPort int
}

// Gateway holds the tunnels.
type Gateway struct {
	cfg Config
	box *secret.Box
	log *slog.Logger
	hc  *http.Client

	mu      sync.Mutex
	entries map[int64]*entry       // by network
	links   map[int64]*linkSession // by network

	dialMu sync.Mutex
	dials  []privnet.Dial
}

type entry struct {
	net privnet.Network
	tun tunnel
	err error // why the tunnel could not start
}

// tunnel dials through one private network.
type tunnel interface {
	Dial(ctx context.Context, addr string) (net.Conn, string, error)
	Status(ctx context.Context) privnet.Status
	Close()
}

// New returns a gateway; box opens the network secrets.
func New(cfg Config, box *secret.Box, log *slog.Logger) *Gateway {
	if cfg.SyncEvery <= 0 {
		cfg.SyncEvery = 15 * time.Second
	}
	if cfg.SidecarPort == 0 {
		cfg.SidecarPort = 1080
	}
	return &Gateway{cfg: cfg, box: box, log: log, hc: &http.Client{Timeout: 15 * time.Second},
		entries: map[int64]*entry{}, links: map[int64]*linkSession{}}
}

// Run reads the networks and reports statuses until ctx ends.
func (g *Gateway) Run(ctx context.Context) {
	sync := time.NewTicker(g.cfg.SyncEvery)
	report := time.NewTicker(10 * time.Second)
	defer sync.Stop()
	defer report.Stop()
	g.syncOnce(ctx)
	for {
		select {
		case <-ctx.Done():
			g.closeAll()
			return
		case <-sync.C:
			g.syncOnce(ctx)
		case <-report.C:
			g.reportOnce(ctx)
		}
	}
}

func (g *Gateway) closeAll() {
	g.mu.Lock()
	defer g.mu.Unlock()
	for _, e := range g.entries {
		if e.tun != nil {
			e.tun.Close()
		}
	}
	for _, l := range g.links {
		_ = l.sess.Close()
	}
}

func (g *Gateway) syncOnce(ctx context.Context) {
	nets, err := g.fetch(ctx)
	if err != nil {
		if ctx.Err() == nil {
			g.log.Warn("gateway: read the networks", "err", err)
		}
		return
	}
	want := map[int64]privnet.Network{}
	for _, n := range nets {
		if n.Enabled && n.ID > 0 {
			want[n.ID] = n
		}
	}
	g.mu.Lock()
	var stale []tunnel
	restarted := map[int64]bool{}
	for id, e := range g.entries {
		n, ok := want[id]
		if !ok || n.Version != e.net.Version || n.Kind != e.net.Kind || n.Workspace != e.net.Workspace {
			if e.tun != nil {
				stale = append(stale, e.tun)
			}
			delete(g.entries, id)
			restarted[id] = true
		}
	}
	// A changed or reconnected connector drops its session; agnts-link
	// connects again within seconds.
	for id, l := range g.links {
		if n, ok := want[id]; !ok || restarted[id] || n.Kind != privnet.KindConnector || n.TokenHash != l.tokenHash {
			_ = l.sess.Close()
			delete(g.links, id)
		}
	}
	var start []privnet.Network
	for id, n := range want {
		if _, ok := g.entries[id]; !ok {
			start = append(start, n)
		}
	}
	g.mu.Unlock()
	for _, t := range stale {
		t.Close()
	}
	for _, n := range start {
		e := &entry{net: n}
		e.tun, e.err = g.open(ctx, n)
		if e.err != nil {
			g.log.Warn("gateway: start a tunnel", "workspace", n.Workspace, "network", n.ID, "kind", n.Kind, "err", e.err)
		} else {
			g.log.Info("gateway: tunnel started", "workspace", n.Workspace, "network", n.ID, "kind", n.Kind)
		}
		g.mu.Lock()
		if old, ok := g.entries[n.ID]; ok && old.tun != nil {
			old.tun.Close()
		}
		g.entries[n.ID] = e
		g.mu.Unlock()
	}
}

func (g *Gateway) open(ctx context.Context, n privnet.Network) (tunnel, error) {
	switch n.Kind {
	case privnet.KindConnector:
		return &linkTunnel{g: g, id: n.ID}, nil
	case privnet.KindOpenVPN:
		return newOVPNTunnel(n.ID, g.cfg.Secret, g.cfg.SidecarPort), nil
	case privnet.KindWireGuard:
		sec, err := g.open1(n)
		if err != nil {
			return nil, err
		}
		cfg, err := privnet.ParseWireGuard(sec.Config)
		if err != nil {
			return nil, err
		}
		return newWGTunnel(ctx, n.ID, cfg, g.log)
	}
	return nil, fmt.Errorf("unknown kind %q", n.Kind)
}

func (g *Gateway) open1(n privnet.Network) (privnet.Secret, error) {
	var s privnet.Secret
	if len(n.Secret) == 0 {
		return s, errors.New("no config saved")
	}
	pt, err := g.box.Open(n.Secret, privnet.SecretAAD(n.Workspace, n.ID))
	if err != nil {
		return s, errors.New("the config cannot be opened: does the gateway have the same AGNTS_ENC_KEY as agnts?")
	}
	return s, json.Unmarshal(pt, &s)
}

func (g *Gateway) fetch(ctx context.Context) ([]privnet.Network, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, g.cfg.AgntsURL+"/gateway/networks", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+g.cfg.Secret)
	resp, err := g.hc.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("status %d", resp.StatusCode)
	}
	var nets []privnet.Network
	return nets, json.NewDecoder(io.LimitReader(resp.Body, 32<<20)).Decode(&nets)
}

// Statuses reports every tunnel's state.
func (g *Gateway) Statuses(ctx context.Context) []privnet.Status {
	g.mu.Lock()
	list := make([]*entry, 0, len(g.entries))
	for _, e := range g.entries {
		list = append(list, e)
	}
	g.mu.Unlock()
	out := make([]privnet.Status, 0, len(list))
	for _, e := range list {
		var st privnet.Status
		if e.err != nil {
			st = privnet.Status{State: privnet.StateError, Error: e.err.Error()}
		} else {
			c, cancel := context.WithTimeout(ctx, 4*time.Second)
			st = e.tun.Status(c)
			cancel()
		}
		st.Network, st.Workspace, st.Version = e.net.ID, e.net.Workspace, e.net.Version
		out = append(out, st)
	}
	return out
}

func (g *Gateway) reportOnce(ctx context.Context) {
	g.dialMu.Lock()
	dials := g.dials
	g.dials = nil
	g.dialMu.Unlock()
	rep := privnet.Report{Statuses: g.Statuses(ctx), Dials: dials}
	b, _ := json.Marshal(rep)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, g.cfg.AgntsURL+"/gateway/report", bytes.NewReader(b))
	if err != nil {
		return
	}
	req.Header.Set("Authorization", "Bearer "+g.cfg.Secret)
	req.Header.Set("Content-Type", "application/json")
	resp, err := g.hc.Do(req)
	if err == nil {
		_ = resp.Body.Close()
		if resp.StatusCode == http.StatusNoContent || resp.StatusCode == http.StatusOK {
			return
		}
		err = fmt.Errorf("status %d", resp.StatusCode)
	}
	if ctx.Err() == nil {
		g.log.Warn("gateway: report", "err", err)
	}
	// Keep the connections for the next report (up to a limit).
	g.dialMu.Lock()
	if len(g.dials)+len(dials) <= 5000 {
		g.dials = append(dials, g.dials...)
	}
	g.dialMu.Unlock()
}

func (g *Gateway) record(d privnet.Dial) {
	d.At = time.Now().UTC()
	g.dialMu.Lock()
	defer g.dialMu.Unlock()
	if len(g.dials) < 5000 {
		g.dials = append(g.dials, d)
	}
}

func (g *Gateway) authorized(r *http.Request) bool {
	h := r.Header.Get("Proxy-Authorization")
	if h == "" {
		h = r.Header.Get("Authorization")
	}
	tok, ok := strings.CutPrefix(h, "Bearer ")
	return ok && g.cfg.Secret != "" && subtle.ConstantTimeCompare([]byte(tok), []byte(g.cfg.Secret)) == 1
}

// ServeHTTP serves CONNECT host:port for the workspace in the
// X-Agnts-Workspace header, through the network in X-Agnts-Network. The
// gateway picks the network again from the workspace's routes and refuses
// a request whose network differs (a caller with stale routes), so traffic
// can only enter the tunnel its routes lead to.
func (g *Gateway) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodConnect {
		http.Error(w, "CONNECT only", http.StatusMethodNotAllowed)
		return
	}
	if !g.authorized(r) {
		http.Error(w, "not authorized", http.StatusProxyAuthRequired)
		return
	}
	ws, ok := privnet.ParseWorkspace(r.Header.Get(privnet.HeaderWorkspace))
	if !ok {
		http.Error(w, "no workspace", http.StatusBadRequest)
		return
	}
	host, port, err := privnet.SplitHostPort(r.Host)
	if err != nil {
		http.Error(w, "bad target", http.StatusBadRequest)
		return
	}
	asked, _ := privnet.ParseWorkspace(r.Header.Get(privnet.HeaderNetwork)) // 0: let the gateway pick
	d := privnet.Dial{Workspace: ws, Ticket: r.Header.Get(privnet.HeaderTicket), Source: r.Header.Get(privnet.HeaderSource), Target: r.Host}
	refuse := func(status int, msg string) {
		d.Error = msg
		g.record(d)
		http.Error(w, msg, status)
	}
	e, picked, has := g.pick(ws, host, port)
	switch {
	case !has:
		refuse(http.StatusForbidden, "this workspace has no private network turned on")
		return
	case e == nil:
		refuse(http.StatusForbidden, r.Host+" is not on the routes of any of the workspace's private networks")
		return
	case asked != 0 && asked != picked:
		refuse(http.StatusConflict, r.Host+" goes through another of the workspace's networks now: the routes changed, try again")
		return
	}
	d.Network = picked
	if e.err != nil {
		refuse(http.StatusServiceUnavailable, "the tunnel of "+e.net.Name+" is not running: "+e.err.Error())
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
	up, resolved, err := e.tun.Dial(ctx, r.Host)
	cancel()
	if err != nil {
		refuse(http.StatusBadGateway, err.Error())
		return
	}
	hj, ok := w.(http.Hijacker)
	if !ok {
		_ = up.Close()
		http.Error(w, "hijacking not supported", http.StatusInternalServerError)
		return
	}
	client, buf, err := hj.Hijack()
	if err != nil {
		_ = up.Close()
		return
	}
	var resp strings.Builder
	resp.WriteString("HTTP/1.1 200 Connection Established\r\n")
	if resolved != "" {
		fmt.Fprintf(&resp, "%s: %s\r\n", privnet.HeaderResolved, resolved)
	}
	fmt.Fprintf(&resp, "%s: %d\r\n", privnet.HeaderNetwork, e.net.ID)
	fmt.Fprintf(&resp, "%s: %s\r\n\r\n", privnet.HeaderVia, e.net.Kind)
	if _, err := io.WriteString(client, resp.String()); err != nil {
		_ = client.Close()
		_ = up.Close()
		return
	}
	cc := bufferedConn(client, buf.Reader)
	d.OK = true
	d.BytesOut, d.BytesIn = privnet.Splice(cc, up)
	g.record(d)
}

// pick finds the network of workspace ws that carries host:port, and
// whether the workspace has a network at all (has).
func (g *Gateway) pick(ws int64, host string, port int) (e *entry, id int64, has bool) {
	g.mu.Lock()
	defer g.mu.Unlock()
	var sets []privnet.RouteSet
	for _, x := range g.entries {
		if x.net.Workspace == ws {
			sets = append(sets, privnet.RouteSet{ID: x.net.ID, Name: x.net.Name, Routes: x.net.Routes})
		}
	}
	id, ok := privnet.Pick(sets, host, port)
	if !ok {
		return nil, 0, len(sets) > 0
	}
	return g.entries[id], id, true
}

// bufferedConn keeps bytes a reader already took from conn.
func bufferedConn(c net.Conn, r *bufio.Reader) net.Conn {
	if r.Buffered() > 0 {
		return &privnet.BufConn{Conn: c, R: r}
	}
	return c
}
