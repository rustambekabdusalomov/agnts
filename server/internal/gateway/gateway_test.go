package gateway

import (
	"bufio"
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strings"
	"sync"
	"testing"
	"time"

	"golang.org/x/crypto/curve25519"
	"golang.zx2c4.com/wireguard/conn"
	"golang.zx2c4.com/wireguard/device"
	"golang.zx2c4.com/wireguard/tun/netstack"

	"agnts/internal/link"
	"agnts/internal/privnet"
	"agnts/internal/secret"
)

const testSecret = "gateway-secret-for-tests-0123456789"

func keypair(t *testing.T) (priv, pub []byte) {
	t.Helper()
	priv = make([]byte, 32)
	if _, err := rand.Read(priv); err != nil {
		t.Fatal(err)
	}
	priv[0] &= 248
	priv[31] = (priv[31] & 127) | 64
	pub, err := curve25519.X25519(priv, curve25519.Basepoint)
	if err != nil {
		t.Fatal(err)
	}
	return priv, pub
}

func freeUDPPort(t *testing.T) int {
	t.Helper()
	c, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = c.Close() }()
	return c.LocalAddr().(*net.UDPAddr).Port
}

// fakeAgnts serves /gateway/networks and collects /gateway/report.
type fakeAgnts struct {
	mu      sync.Mutex
	nets    []privnet.Network
	reports []privnet.Report
}

func (f *fakeAgnts) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if strings.HasPrefix(r.URL.Path, "/gateway/") && r.Header.Get("Authorization") != "Bearer "+testSecret {
		http.Error(w, "no", http.StatusUnauthorized)
		return
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	switch r.URL.Path {
	case "/gateway/networks":
		_ = json.NewEncoder(w).Encode(f.nets)
	case "/gateway/report":
		var rep privnet.Report
		_ = json.NewDecoder(r.Body).Decode(&rep)
		f.reports = append(f.reports, rep)
		w.WriteHeader(http.StatusNoContent)
	case "/webhooks/gitlab/hook123":
		b, _ := io.ReadAll(r.Body)
		w.Header().Set("Content-Type", "text/plain")
		_, _ = fmt.Fprintf(w, "got %s %s token=%s", r.Method, b, r.Header.Get("X-Gitlab-Token"))
	default:
		http.NotFound(w, r)
	}
}

func newGateway(t *testing.T, nets ...privnet.Network) (*Gateway, *fakeAgnts, *httptest.Server, *secret.Box) {
	t.Helper()
	key := make([]byte, 32)
	_, _ = rand.Read(key)
	box, err := secret.NewBox(key)
	if err != nil {
		t.Fatal(err)
	}
	fa := &fakeAgnts{nets: nets}
	agnts := httptest.NewServer(fa)
	t.Cleanup(agnts.Close)
	g := New(Config{Secret: testSecret, AgntsURL: agnts.URL, HooksURL: agnts.URL}, box, slog.New(slog.NewTextHandler(io.Discard, nil)))
	gw := httptest.NewServer(g)
	t.Cleanup(gw.Close)
	t.Cleanup(g.closeAll)
	return g, fa, gw, box
}

func get(t *testing.T, gwAddr string, ws int64, target, path string) (string, privnet.DialInfo, error) {
	t.Helper()
	return getVia(t, gwAddr, ws, 0, target, path)
}

// getVia asks for a given network (0: let the gateway pick).
func getVia(t *testing.T, gwAddr string, ws, network int64, target, path string) (string, privnet.DialInfo, error) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	c, info, err := privnet.DialGateway(ctx, gwAddr, testSecret, privnet.DialRequest{Workspace: ws, Network: network, Target: target, Source: "test", Ticket: "PAY-1"})
	if err != nil {
		return "", info, err
	}
	defer func() { _ = c.Close() }()
	_ = c.SetDeadline(time.Now().Add(10 * time.Second))
	if _, err := fmt.Fprintf(c, "GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n", path, target); err != nil {
		return "", info, err
	}
	resp, err := http.ReadResponse(bufio.NewReader(c), nil)
	if err != nil {
		return "", info, err
	}
	defer func() { _ = resp.Body.Close() }()
	b, err := io.ReadAll(resp.Body)
	return string(b), info, err
}

// TestWireGuard runs a real WireGuard handshake between the gateway and a
// peer standing in for a company VPN, both in user space over loopback
// UDP, and fetches a page from a server inside the peer's network.
func TestWireGuard(t *testing.T) {
	gwPriv, gwPub := keypair(t)
	peerPriv, peerPub := keypair(t)
	port := freeUDPPort(t)

	// The company side: 10.99.0.1, an HTTP server on :80 inside its netstack.
	tun, tnet, err := netstack.CreateNetTUN([]netip.Addr{netip.MustParseAddr("10.99.0.1")}, nil, 1420)
	if err != nil {
		t.Fatal(err)
	}
	peer := device.NewDevice(tun, conn.NewDefaultBind(), device.NewLogger(device.LogLevelSilent, ""))
	defer peer.Close()
	if err := peer.IpcSet(fmt.Sprintf("private_key=%s\nlisten_port=%d\npublic_key=%s\nallowed_ip=10.99.0.2/32\n",
		hex.EncodeToString(peerPriv), port, hex.EncodeToString(gwPub))); err != nil {
		t.Fatal(err)
	}
	if err := peer.Up(); err != nil {
		t.Fatal(err)
	}
	l, err := tnet.ListenTCP(&net.TCPAddr{Port: 80})
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = l.Close() }()
	go func() {
		_ = http.Serve(l, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			_, _ = io.WriteString(w, "hello from gitlab.corp at "+r.URL.Path)
		}))
	}()

	conf := fmt.Sprintf("[Interface]\nPrivateKey = %s\nAddress = 10.99.0.2/32\n\n[Peer]\nPublicKey = %s\nEndpoint = 127.0.0.1:%d\nAllowedIPs = 10.99.0.0/24\n",
		base64.StdEncoding.EncodeToString(gwPriv), base64.StdEncoding.EncodeToString(peerPub), port)
	g, fa, gw, box := newGateway(t)
	sealed, err := box.Seal(mustJSON(privnet.Secret{Config: conf}), privnet.SecretAAD(7, 70))
	if err != nil {
		t.Fatal(err)
	}
	// Workspace 7 has two networks: WireGuard for the /24, and a connector
	// (never connected) for one address inside it, which wins for it.
	fa.nets = []privnet.Network{
		{ID: 70, Workspace: 7, Name: "Corp", Kind: privnet.KindWireGuard, Enabled: true, Secret: sealed, Version: "v1",
			Routes: []privnet.Route{{CIDR: "10.99.0.0/24", Ports: []int{80}}}},
		{ID: 71, Workspace: 7, Name: "Lab", Kind: privnet.KindConnector, Enabled: true, TokenHash: "x", Version: "v1",
			Routes: []privnet.Route{{CIDR: "10.99.0.5/32", Ports: []int{80}}}},
	}
	g.syncOnce(context.Background())

	addr := strings.TrimPrefix(gw.URL, "http://")
	body, info, err := get(t, addr, 7, "10.99.0.1:80", "/api/v4/version")
	if err != nil {
		t.Fatal(err)
	}
	if body != "hello from gitlab.corp at /api/v4/version" || info.Via != privnet.KindWireGuard || info.Resolved != "10.99.0.1" || info.Network != 70 {
		t.Fatalf("body %q, info %+v", body, info)
	}
	// Asking for the network Pick chose is fine; asking for another is not.
	if _, _, err := getVia(t, addr, 7, 70, "10.99.0.1:80", "/"); err != nil {
		t.Errorf("the right network: %v", err)
	}
	if _, _, err := getVia(t, addr, 7, 71, "10.99.0.1:80", "/"); err == nil || !strings.Contains(err.Error(), "another of the workspace's networks") {
		t.Errorf("a stale network: %v", err)
	}
	// The more specific route sends 10.99.0.5 to the connector.
	if _, _, err := get(t, addr, 7, "10.99.0.5:80", "/"); err == nil || !strings.Contains(err.Error(), "agnts-link is not connected") {
		t.Errorf("the connector's address: %v", err)
	}

	// Off the routes, another workspace, a wrong secret: refused.
	if _, _, err := get(t, addr, 7, "10.99.0.1:22", "/"); err == nil || !strings.Contains(err.Error(), "not on the routes of any") {
		t.Errorf("port off the routes: %v", err)
	}
	if _, _, err := get(t, addr, 8, "10.99.0.1:80", "/"); err == nil || !strings.Contains(err.Error(), "no private network") {
		t.Errorf("another workspace: %v", err)
	}
	if _, _, err := privnet.DialGateway(context.Background(), addr, "wrong", privnet.DialRequest{Workspace: 7, Target: "10.99.0.1:80"}); err == nil {
		t.Error("a wrong gateway secret was let in")
	}

	sts := g.Statuses(context.Background())
	if len(sts) != 2 {
		t.Fatalf("statuses %+v", sts)
	}
	for _, st := range sts {
		if st.Network == 70 && (st.State != privnet.StateUp || st.Handshake == nil || st.Version != "v1" || st.Workspace != 7) {
			t.Errorf("WireGuard status %+v", st)
		}
		if st.Network == 71 && st.State != privnet.StateConnecting {
			t.Errorf("connector status %+v", st)
		}
	}
	g.reportOnce(context.Background())
	fa.mu.Lock()
	defer fa.mu.Unlock()
	if len(fa.reports) != 1 || len(fa.reports[0].Dials) != 6 {
		t.Fatalf("reports %+v", fa.reports)
	}
	ok := 0
	for _, d := range fa.reports[0].Dials {
		if d.OK {
			ok++
			if d.Ticket != "PAY-1" || d.Source != "test" || d.BytesIn == 0 || d.BytesOut == 0 || d.Target != "10.99.0.1:80" || d.Network != 70 {
				t.Errorf("dial %+v", d)
			}
		}
	}
	if ok != 2 {
		t.Errorf("%d connections made, want 2: %+v", ok, fa.reports[0].Dials)
	}
}

func mustJSON(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}

// TestConnector connects agnts-link to the gateway, dials a server in the
// "company network" through it, and relays a webhook back to agnts.
func TestConnector(t *testing.T) {
	inside := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "jira inside at "+r.URL.Path)
	}))
	defer inside.Close()
	insideAddr := strings.TrimPrefix(inside.URL, "http://")

	_, port, _ := net.SplitHostPort(insideAddr)
	var portN int
	_, _ = fmt.Sscan(port, &portN)
	tok, hash := privnet.NewLinkToken()
	g, fa, gw, _ := newGateway(t)
	n := privnet.Network{ID: 30, Workspace: 3, Name: "Office", Kind: privnet.KindConnector, Enabled: true, TokenHash: hash, Version: "v1",
		Routes: []privnet.Route{{CIDR: "127.0.0.0/8", Ports: []int{portN}}, {Host: "jira.corp.local"}}}
	g.mu.Lock()
	g.entries[30] = &entry{net: n, tun: &linkTunnel{g: g, id: 30}}
	g.mu.Unlock()
	linkSrv := httptest.NewServer(g.LinkHandler())
	defer linkSrv.Close()

	// A wrong token is refused.
	bad, err := link.New(link.Config{URL: linkSrv.URL + "/link", Token: "lnk_wrong", Allow: []string{"127.0.0.1/32"}}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	if err != nil {
		t.Fatal(err)
	}
	badCtx, badCancel := context.WithCancel(context.Background())
	go func() { _ = bad.Run(badCtx) }()

	hooksPort := freeUDPPort(t) // any free port number will do for TCP here too
	l, err := link.New(link.Config{URL: linkSrv.URL + "/link", Token: tok, Allow: []string{"127.0.0.1/32"},
		HooksAddr: fmt.Sprintf("127.0.0.1:%d", hooksPort), Version: "test",
		Resolver: &net.Resolver{PreferGo: true, Dial: func(ctx context.Context, _, _ string) (net.Conn, error) {
			return nil, fmt.Errorf("no DNS in tests")
		}}}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go func() { _ = l.Run(ctx) }()
	deadline := time.Now().Add(5 * time.Second)
	for {
		if st := (&linkTunnel{g: g, id: 30}).Status(context.Background()); st.State == privnet.StateUp {
			if !strings.Contains(st.Detail, "agnts-link test") {
				t.Errorf("detail %q", st.Detail)
			}
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("agnts-link did not connect")
		}
		time.Sleep(50 * time.Millisecond)
	}
	badCancel()

	addr := strings.TrimPrefix(gw.URL, "http://")
	body, info, err := get(t, addr, 3, "127.0.0.1:"+port, "/rest/api/2/myself")
	if err != nil {
		t.Fatal(err)
	}
	if body != "jira inside at /rest/api/2/myself" || info.Via != privnet.KindConnector || info.Resolved != "127.0.0.1" {
		t.Fatalf("body %q info %+v", body, info)
	}
	// On agnts's routes but not on the team's own list: agnts-link refuses.
	if _, _, err := get(t, addr, 3, "127.0.0.2:"+port, "/"); err == nil || !strings.Contains(err.Error(), "not on AGNTS_LINK_ALLOW") {
		t.Errorf("outside AGNTS_LINK_ALLOW: %v", err)
	}

	// A webhook sent to agnts-link inside the network reaches agnts.
	var resp *http.Response
	for i := 0; i < 50; i++ {
		resp, err = http.Post(fmt.Sprintf("http://127.0.0.1:%d/webhooks/gitlab/hook123", hooksPort), "application/json", strings.NewReader(`{"object_kind":"merge_request"}`))
		if err == nil {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(resp.Body)
	_ = resp.Body.Close()
	if resp.StatusCode != http.StatusOK || string(b) != `got POST {"object_kind":"merge_request"} token=` {
		t.Errorf("webhook: %d %q", resp.StatusCode, b)
	}
	// Reconnect (a new version from agnts) drops the session; agnts-link
	// connects again by itself.
	g.mu.Lock()
	first := g.links[30]
	g.mu.Unlock()
	n.Version = "v2"
	fa.mu.Lock()
	fa.nets = []privnet.Network{n}
	fa.mu.Unlock()
	g.syncOnce(context.Background())
	deadline = time.Now().Add(10 * time.Second)
	for {
		g.mu.Lock()
		cur := g.links[30]
		g.mu.Unlock()
		if cur != nil && cur != first {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("agnts-link did not reconnect")
		}
		time.Sleep(50 * time.Millisecond)
	}
	if body, _, err := get(t, addr, 3, "127.0.0.1:"+port, "/again"); err != nil || body != "jira inside at /again" {
		t.Errorf("after reconnect: %q %v", body, err)
	}

	resp, err = http.Get(fmt.Sprintf("http://127.0.0.1:%d/api/v1/me", hooksPort))
	if err != nil {
		t.Fatal(err)
	}
	_ = resp.Body.Close()
	if resp.StatusCode != http.StatusNotFound {
		t.Errorf("a non-webhook path was relayed: %d", resp.StatusCode)
	}
}
