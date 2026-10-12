package gateway

import (
	"bufio"
	"context"
	"crypto/subtle"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/hashicorp/yamux"

	"agnts/internal/privnet"
)

// linkSession is an agnts-link connected for a workspace.
type linkSession struct {
	sess      *yamux.Session
	tokenHash string
	since     time.Time
	remote    string
	version   string
}

// LinkHandler accepts agnts-link sessions at /link (Caddy routes it from
// the public API domain). The token names the workspace.
func (g *Gateway) LinkHandler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET "+privnet.LinkPath, g.acceptLink)
	return mux
}

func (g *Gateway) acceptLink(w http.ResponseWriter, r *http.Request) {
	if !strings.EqualFold(r.Header.Get("Upgrade"), privnet.LinkProtocol) {
		http.Error(w, "agnts-link connects here", http.StatusUpgradeRequired)
		return
	}
	tok, _ := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
	id, ws, hash := g.linkNetwork(tok)
	if id == 0 {
		time.Sleep(500 * time.Millisecond)
		http.Error(w, "unknown or rotated token, or the connector is turned off in agnts", http.StatusUnauthorized)
		return
	}
	hj, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "hijacking not supported", http.StatusInternalServerError)
		return
	}
	conn, buf, err := hj.Hijack()
	if err != nil {
		return
	}
	if _, err := io.WriteString(conn, "HTTP/1.1 101 Switching Protocols\r\nUpgrade: "+privnet.LinkProtocol+"\r\nConnection: Upgrade\r\n\r\n"); err != nil {
		_ = conn.Close()
		return
	}
	cfg := yamux.DefaultConfig()
	cfg.KeepAliveInterval = 20 * time.Second
	cfg.LogOutput = io.Discard
	sess, err := yamux.Client(bufferedConn(conn, buf.Reader), cfg)
	if err != nil {
		_ = conn.Close()
		return
	}
	remote := r.Header.Get("X-Forwarded-For")
	if remote == "" {
		remote = r.RemoteAddr
	}
	l := &linkSession{sess: sess, tokenHash: hash, since: time.Now().UTC(), remote: remote, version: r.Header.Get("X-Agnts-Link-Version")}
	g.mu.Lock()
	if old, ok := g.links[id]; ok {
		_ = old.sess.Close()
	}
	g.links[id] = l
	g.mu.Unlock()
	g.log.Info("gateway: agnts-link connected", "workspace", ws, "network", id, "remote", remote, "version", l.version)
	go g.serveHooks(ws, id, sess)
	<-sess.CloseChan()
	g.mu.Lock()
	if g.links[id] == l {
		delete(g.links, id)
	}
	g.mu.Unlock()
	g.log.Info("gateway: agnts-link disconnected", "workspace", ws, "network", id)
}

// linkNetwork finds the connector network whose token tok is, and its
// workspace.
func (g *Gateway) linkNetwork(tok string) (id, ws int64, hash string) {
	if !strings.HasPrefix(tok, privnet.LinkTokenPrefix) {
		return 0, 0, ""
	}
	hash = privnet.HashToken(tok)
	g.mu.Lock()
	defer g.mu.Unlock()
	for id, e := range g.entries {
		if e.net.Kind == privnet.KindConnector && e.net.TokenHash != "" &&
			subtle.ConstantTimeCompare([]byte(e.net.TokenHash), []byte(hash)) == 1 {
			return id, e.net.Workspace, hash
		}
	}
	return 0, 0, ""
}

// serveHooks relays the webhooks agnts-link received in the customer's
// network (from a GitLab or Jira that cannot reach agnts) to agnts.
func (g *Gateway) serveHooks(ws, network int64, sess *yamux.Session) {
	for {
		st, err := sess.AcceptStream()
		if err != nil {
			return
		}
		go func() {
			defer func() { _ = st.Close() }()
			_ = st.SetDeadline(time.Now().Add(2 * time.Minute))
			br := bufio.NewReader(st)
			var h privnet.StreamHeader
			if err := privnet.ReadLine(br, &h); err != nil || h.Op != privnet.OpHook {
				return
			}
			resp := g.relayHook(ws, network, br)
			_ = resp.Write(st)
			_ = resp.Body.Close()
		}()
	}
}

func (g *Gateway) relayHook(ws, network int64, br *bufio.Reader) *http.Response {
	answer := func(code int, msg string) *http.Response {
		return &http.Response{StatusCode: code, ProtoMajor: 1, ProtoMinor: 1, Header: http.Header{"Content-Type": {"text/plain"}},
			Body: io.NopCloser(strings.NewReader(msg)), ContentLength: int64(len(msg))}
	}
	in, err := http.ReadRequest(br)
	if err != nil {
		return answer(http.StatusBadRequest, "bad request")
	}
	path := in.URL.Path
	if !strings.HasPrefix(path, "/webhooks/") || strings.Contains(path, "..") {
		return answer(http.StatusNotFound, "agnts-link only relays webhooks (/webhooks/...)")
	}
	body, err := io.ReadAll(io.LimitReader(in.Body, 5<<20))
	if err != nil {
		return answer(http.StatusBadRequest, "bad body")
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
	defer cancel()
	out, err := http.NewRequestWithContext(ctx, in.Method, g.cfg.HooksURL+in.URL.RequestURI(), strings.NewReader(string(body)))
	if err != nil {
		return answer(http.StatusBadRequest, "bad request")
	}
	for k, vs := range in.Header {
		switch http.CanonicalHeaderKey(k) {
		case "Connection", "Keep-Alive", "Proxy-Connection", "Transfer-Encoding", "Upgrade", "Te", "Trailer", "X-Forwarded-For", "X-Real-Ip",
			"X-Agnts-Link-Workspace", "X-Agnts-Link-Network":
			continue
		}
		out.Header[k] = vs
	}
	out.Header.Set("X-Agnts-Link-Workspace", fmt.Sprint(ws))
	out.Header.Set("X-Agnts-Link-Network", fmt.Sprint(network))
	resp, err := g.hc.Do(out)
	if err != nil {
		g.log.Warn("gateway: relay a webhook", "workspace", ws, "path", path, "err", err)
		return answer(http.StatusBadGateway, "agnts is not reachable")
	}
	defer func() { _ = resp.Body.Close() }()
	rb, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	g.record(privnet.Dial{Workspace: ws, Network: network, Source: "webhook", Target: in.Method + " " + path, OK: resp.StatusCode < 400,
		BytesIn: int64(len(body)), BytesOut: int64(len(rb))})
	r := answer(resp.StatusCode, string(rb))
	if ct := resp.Header.Get("Content-Type"); ct != "" {
		r.Header.Set("Content-Type", ct)
	}
	return r
}

// linkTunnel dials through a connector network's agnts-link session.
type linkTunnel struct {
	g  *Gateway
	id int64
}

func (t *linkTunnel) session() *linkSession {
	t.g.mu.Lock()
	defer t.g.mu.Unlock()
	return t.g.links[t.id]
}

func (t *linkTunnel) Dial(ctx context.Context, addr string) (net.Conn, string, error) {
	l := t.session()
	if l == nil {
		return nil, "", errors.New("agnts-link is not connected: start it in your network (Settings → Private networks shows the command)")
	}
	st, err := l.sess.OpenStream()
	if err != nil {
		return nil, "", fmt.Errorf("agnts-link: %w", err)
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = st.SetDeadline(dl)
	}
	stop := context.AfterFunc(ctx, func() { _ = st.SetDeadline(time.Unix(1, 0)) })
	defer stop()
	if err := privnet.WriteLine(st, privnet.StreamHeader{Op: privnet.OpDial, Addr: addr}); err != nil {
		_ = st.Close()
		return nil, "", fmt.Errorf("agnts-link: %w", err)
	}
	br := bufio.NewReader(st)
	var rep privnet.StreamReply
	if err := privnet.ReadLine(br, &rep); err != nil {
		_ = st.Close()
		if ctx.Err() != nil {
			return nil, "", fmt.Errorf("agnts-link did not connect to %s in time", addr)
		}
		return nil, "", fmt.Errorf("agnts-link: %w", err)
	}
	if !rep.OK {
		_ = st.Close()
		return nil, "", fmt.Errorf("agnts-link: %s", rep.Error)
	}
	_ = st.SetDeadline(time.Time{})
	return &StreamConn{Stream: st, R: br}, rep.IP, nil
}

func (t *linkTunnel) Status(context.Context) privnet.Status {
	l := t.session()
	if l == nil {
		return privnet.Status{State: privnet.StateConnecting, Error: "agnts-link is not connected"}
	}
	st := privnet.Status{State: privnet.StateUp, Since: &l.since}
	if rtt, err := l.sess.Ping(); err == nil {
		now := time.Now().UTC()
		st.Handshake = &now
		st.Detail = fmt.Sprintf("%s · %d ms", l.remote, rtt.Milliseconds())
		if l.version != "" {
			st.Detail += " · agnts-link " + l.version
		}
	}
	return st
}

func (t *linkTunnel) Close() {}

// StreamConn is a yamux stream whose first bytes were read into R.
// Closing a yamux stream only ends its writing half, which is what
// CloseWrite means to Splice.
type StreamConn struct {
	*yamux.Stream
	R *bufio.Reader
}

func (c *StreamConn) Read(p []byte) (int, error) { return c.R.Read(p) }

// CloseWrite sends the stream's FIN; reading goes on.
func (c *StreamConn) CloseWrite() error { return c.Close() }
