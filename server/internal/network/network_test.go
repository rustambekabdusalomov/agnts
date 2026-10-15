package network

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"math/big"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/netroute"
	"agnts/internal/privnet"
	"agnts/internal/runner"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
)

const wg = `[Interface]
PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=
Address = 10.8.0.2/32
DNS = 10.8.0.1

[Peer]
PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=
Endpoint = vpn.corp.com:51820
AllowedIPs = 10.0.0.0/8
`

type harness struct {
	pool   *pgxpool.Pool
	svc    *Service
	box    *secret.Box
	router *netroute.Router
	a, b   context.Context
	wsA    int64
}

func setup(t *testing.T) *harness {
	t.Helper()
	url := os.Getenv("AGNTS_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("AGNTS_TEST_DATABASE_URL not set")
	}
	sys := domain.System(context.Background())
	pool, err := postgres.Open(sys, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if err := postgres.Migrate(sys, pool, "up", slog.New(slog.NewTextHandler(io.Discard, nil))); err != nil {
		t.Fatal(err)
	}
	if _, err := postgres.DetectTenantRole(sys, pool); err != nil {
		t.Fatal(err)
	}
	users, wss := postgres.NewUsers(pool), postgres.NewWorkspaces(pool)
	mk := func(name string) (context.Context, int64) {
		u, err := users.Create(sys, domain.User{Username: fmt.Sprintf("%s-%d", name, time.Now().UnixNano()), PasswordHash: "h"})
		if err != nil {
			t.Fatal(err)
		}
		w, err := wss.Create(sys, postgres.NewWorkspace{Name: name, OwnerID: u.ID})
		if err != nil {
			t.Fatal(err)
		}
		return domain.WithWorkspace(context.Background(), w.ID), w.ID
	}
	key := make([]byte, 32)
	_, _ = rand.Read(key)
	box, _ := secret.NewBox(key)
	router := netroute.New("gateway:3129", "s3cret-s3cret-s3cret-s3cret")
	svc := New(Config{Gateway: "gateway:3129", GatewaySecret: "s3cret-s3cret-s3cret-s3cret", LinkURL: "https://api.example.com/link",
		Reserved: []string{"github.com", "api.example.com"}, Polled: time.Minute},
		postgres.NewPrivateNetworks(pool), box, router, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))
	h := &harness{pool: pool, svc: svc, box: box, router: router}
	h.a, h.wsA = mk("vpn-a")
	h.b, _ = mk("vpn-b")
	return h
}

func ptr(s string) *string { return &s }

func caPEM(t *testing.T) string {
	t.Helper()
	k, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	tmpl := &x509.Certificate{SerialNumber: big.NewInt(1), Subject: pkix.Name{CommonName: "Corp Root CA"}, NotBefore: time.Now(),
		NotAfter: time.Now().Add(365 * 24 * time.Hour), IsCA: true, BasicConstraintsValid: true, KeyUsage: x509.KeyUsageCertSign}
	der, err := x509.CreateCertificate(rand.Reader, tmpl, tmpl, &k.PublicKey, k)
	if err != nil {
		t.Fatal(err)
	}
	return string(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der}))
}

func TestSaveAndIsolation(t *testing.T) {
	h := setup(t)
	routes := []privnet.Route{{Host: "gitlab.corp.local", Ports: []int{443}}, {CIDR: "10.20.0.0/16"}}

	// Bad input is refused with a reason.
	for _, in := range []Input{
		{Name: "Corp", Kind: "ipsec", Routes: routes},
		{Name: "Corp", Kind: privnet.KindWireGuard, Routes: routes},                             // no config
		{Name: "Corp", Kind: privnet.KindWireGuard, Config: ptr("[Interface]"), Routes: routes}, // broken config
		{Name: "Corp", Kind: privnet.KindWireGuard, Config: ptr(wg)},                            // no routes
		{Name: "Corp", Kind: privnet.KindWireGuard, Config: ptr(wg), Routes: []privnet.Route{{Host: "github.com"}}},
		{Name: "Corp", Kind: privnet.KindOpenVPN, Config: ptr("client\nremote vpn 1194\nauth-user-pass\n"), Routes: routes}, // no password
		{Name: "Corp", Kind: privnet.KindWireGuard, Config: ptr(wg), Routes: routes, CAPEM: ptr("not a cert")},
		{Name: "  ", Kind: privnet.KindWireGuard, Config: ptr(wg), Routes: routes}, // no name
	} {
		if _, err := h.svc.Create(h.a, in, domain.OriginWeb); !errors.Is(err, ErrInvalid) {
			t.Errorf("%+v: %v", in.Kind, err)
		}
	}

	ca := caPEM(t)
	saved, err := h.svc.Create(h.a, Input{Name: "Corp", Kind: privnet.KindWireGuard, Enabled: true, Config: ptr(wg), Routes: routes, CAPEM: ptr(ca)}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	v := saved.View
	id := v.ID
	if id == 0 || v.Name != "Corp" || v.Summary != "peer vpn.corp.com:51820" || len(v.Routes) != 2 || v.CA == nil || v.CA.Subjects[0] != "Corp Root CA" || v.Webhooks != "polling" {
		t.Fatalf("view %+v", v)
	}
	if !h.router.Match(h.wsA, "gitlab.corp.local", 443) || h.router.Match(h.wsA, "gitlab.corp.local", 80) {
		t.Error("router not refreshed")
	}
	if got := h.svc.CA(h.a); !strings.Contains(string(got), "BEGIN CERTIFICATE") {
		t.Error("runs get no CA bundle")
	}

	// The other workspace sees nothing and its runs match nothing.
	if o, err := h.svc.List(h.b); err != nil || len(o.Networks) != 0 || !o.Available || o.Max != 5 {
		t.Fatalf("workspace b: %+v %v", o, err)
	}
	if _, err := h.svc.Get(h.b, id); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("workspace b reads a's network: %v", err)
	}
	if _, err := h.svc.Update(h.b, id, Input{Name: "x", Kind: privnet.KindConnector, Routes: routes}, domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("workspace b changes a's network: %v", err)
	}
	if h.svc.CA(h.b) != nil {
		t.Error("workspace b got a's CA")
	}

	// Saving routes only keeps the sealed config.
	saved, err = h.svc.Update(h.a, id, Input{Name: "Corp", Kind: privnet.KindWireGuard, Enabled: true, Routes: routes[:1]}, domain.OriginWeb)
	if err != nil || saved.View.Summary != "peer vpn.corp.com:51820" || len(saved.View.Routes) != 1 {
		t.Fatalf("routes-only save: %+v %v", saved.View, err)
	}

	// The gateway feed carries the config sealed for the network.
	feed := h.internal(t, http.MethodGet, "/gateway/networks", "")
	var nets []privnet.Network
	if err := json.Unmarshal([]byte(feed), &nets); err != nil {
		t.Fatal(err)
	}
	var mine *privnet.Network
	for i := range nets {
		if nets[i].ID == id {
			mine = &nets[i]
		}
	}
	if mine == nil || mine.Workspace != h.wsA || mine.Name != "Corp" || strings.Contains(feed, "PrivateKey") {
		t.Fatalf("feed: %s", feed)
	}
	pt, err := h.box.Open(mine.Secret, privnet.SecretAAD(h.wsA, id))
	if err != nil || !strings.Contains(string(pt), "PrivateKey") {
		t.Fatalf("sealed config: %v", err)
	}
	if _, err := h.box.Open(mine.Secret, privnet.SecretAAD(h.wsA, id+1)); err == nil {
		t.Error("the config opens for another network")
	}

	// A status report for the current version is stored; a stale one is not.
	rep := fmt.Sprintf(`{"statuses":[{"network":%d,"workspace":%d,"version":%q,"state":"up","detail":"ok"},{"network":%d,"workspace":%d,"version":"old","state":"error"}],
		"dials":[{"workspace":%d,"network":%d,"source":"run","ticket":"PAY-1","target":"gitlab.corp.local:443","ok":true,"bytesIn":10,"bytesOut":5,"at":"2026-10-11T10:00:00Z"}]}`,
		id, h.wsA, mine.Version, id, h.wsA, h.wsA, id)
	h.internal(t, http.MethodPost, "/gateway/report", rep)
	if v, _ := h.svc.Get(h.a, id); v.Status != "up" || v.Detail != "ok" {
		t.Errorf("status after report: %+v", v)
	}
	act, err := h.svc.Activity(h.a, 0)
	if err != nil || len(act.Dials) != 1 || act.Dials[0].Ticket != "PAY-1" || act.Dials[0].Network != id {
		t.Errorf("activity %+v %v", act, err)
	}
	if act, _ := h.svc.Activity(h.a, id+1000); len(act.Dials) != 0 {
		t.Error("another network's activity has a's connection")
	}
	if act, _ := h.svc.Activity(h.b, 0); len(act.Dials) != 0 {
		t.Error("workspace b sees a's connections")
	}

	// The egress question: only a's runs reach a's routes, and the answer
	// names the network.
	h.svc.SetRuns(nil, func(ip string) (runner.Identity, bool) {
		if ip == "172.18.0.5" {
			return runner.Identity{Workspace: h.wsA, Ticket: "PAY-1"}, true
		}
		return runner.Identity{}, false
	})
	if got := h.internal(t, http.MethodGet, "/egress/route?ip=172.18.0.5&host=gitlab.corp.local&port=443", ""); !strings.Contains(got, `"ticket":"PAY-1"`) ||
		!strings.Contains(got, fmt.Sprintf(`"network":%d`, id)) {
		t.Errorf("route: %s", got)
	}
	if got := h.internal(t, http.MethodGet, "/egress/route?ip=172.18.0.6&host=gitlab.corp.local&port=443", ""); !strings.Contains(got, "no") {
		t.Errorf("unknown ip routed: %s", got)
	}

	// Switching to the connector makes a token once; rotating replaces it.
	saved, err = h.svc.Update(h.a, id, Input{Name: "Corp", Kind: privnet.KindConnector, Enabled: true, Routes: routes}, domain.OriginWeb)
	if err != nil || !strings.HasPrefix(saved.Token, privnet.LinkTokenPrefix) || !saved.View.TokenSet || saved.View.Webhooks != "relay" {
		t.Fatalf("connector: %+v %v", saved, err)
	}
	again, err := h.svc.Update(h.a, id, Input{Name: "Corp", Kind: privnet.KindConnector, Enabled: true, Routes: routes}, domain.OriginWeb)
	if err != nil || again.Token != "" {
		t.Errorf("a second save made a token: %+v", again)
	}
	tok, err := h.svc.RotateToken(h.a, id, domain.OriginWeb)
	if err != nil || tok == saved.Token {
		t.Errorf("rotate: %v", err)
	}
	if _, err := h.svc.RotateToken(h.b, id, domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("rotate another workspace's network: %v", err)
	}

	// Reconnect: a new version (the gateway restarts the tunnel), status reset.
	before, _ := h.router.Network(h.wsA, id)
	time.Sleep(2 * time.Millisecond)
	v, err = h.svc.Reconnect(h.a, id, domain.OriginWeb)
	after, _ := h.router.Network(h.wsA, id)
	if err != nil || v.Status != "connecting" || after.Version == before.Version {
		t.Errorf("reconnect: %+v %v (version %s -> %s)", v, err, before.Version, after.Version)
	}
	if _, err := h.svc.Reconnect(h.b, id, domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("reconnect another workspace's network: %v", err)
	}

	// Disconnect: off and routing nothing, the config kept; connect turns it back on.
	v, err = h.svc.SetConnected(h.a, id, false, domain.OriginWeb)
	if err != nil || v.Enabled || v.Status != "disabled" || h.router.Match(h.wsA, "gitlab.corp.local", 443) {
		t.Fatalf("disconnect: %+v %v", v, err)
	}
	if _, err := h.svc.Reconnect(h.a, id, domain.OriginWeb); err == nil {
		t.Error("reconnected a disconnected network")
	}
	if _, err := h.svc.SetConnected(h.b, id, true, domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("connect another workspace's network: %v", err)
	}
	v, err = h.svc.SetConnected(h.a, id, true, domain.OriginWeb)
	if err != nil || !v.Enabled || v.Name != "Corp" || !v.TokenSet || !h.router.Match(h.wsA, "gitlab.corp.local", 443) {
		t.Fatalf("connect: %+v %v", v, err)
	}

	if err := h.svc.Delete(h.a, id, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if o, _ := h.svc.List(h.a); len(o.Networks) != 0 || h.router.Match(h.wsA, "gitlab.corp.local", 443) {
		t.Error("still configured after delete")
	}
}

// TestMultipleNetworks keeps several networks in one workspace: names and
// routes may not clash, the most specific route picks the network, runs
// trust every network's CA, and only VPN-reached trackers are polled.
func TestMultipleNetworks(t *testing.T) {
	h := setup(t)
	caA, caB := caPEM(t), caPEM(t)
	office, err := h.svc.Create(h.a, Input{Name: "Office", Kind: privnet.KindWireGuard, Enabled: true, Config: ptr(wg),
		Routes: []privnet.Route{{CIDR: "10.0.0.0/8"}, {Host: ".corp.local"}}, CAPEM: ptr(caA)}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	lab, err := h.svc.Create(h.a, Input{Name: "Lab", Kind: privnet.KindConnector, Enabled: true,
		Routes: []privnet.Route{{CIDR: "10.30.0.0/16"}, {Host: "jira.corp.local"}}, CAPEM: ptr(caB)}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if lab.Token == "" {
		t.Error("a new connector network got no token")
	}

	// Clashes are refused, naming the other network; nesting is fine.
	for _, in := range []Input{
		{Name: "office", Kind: privnet.KindConnector, Routes: []privnet.Route{{Host: "x.other.local"}}}, // the name, in any case
		{Name: "Client", Kind: privnet.KindConnector, Routes: []privnet.Route{{CIDR: "10.0.0.0/8"}}},
		{Name: "Client", Kind: privnet.KindConnector, Routes: []privnet.Route{{Host: "jira.corp.local", Ports: []int{443}}}},
	} {
		if _, err := h.svc.Create(h.a, in, domain.OriginWeb); !errors.Is(err, ErrInvalid) {
			t.Errorf("%s %v: %v", in.Name, in.Routes, err)
		}
	}
	// A disabled network still holds its routes.
	if _, err := h.svc.Update(h.a, lab.View.ID, Input{Name: "Lab", Kind: privnet.KindConnector, Enabled: false,
		Routes: []privnet.Route{{CIDR: "10.30.0.0/16"}, {Host: "jira.corp.local"}}, CAPEM: ptr(caB)}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.svc.Create(h.a, Input{Name: "Client", Kind: privnet.KindConnector, Routes: []privnet.Route{{CIDR: "10.30.0.0/16"}}}, domain.OriginWeb); err == nil ||
		!strings.Contains(err.Error(), `"Lab"`) {
		t.Errorf("a disabled network's route was taken: %v", err)
	}
	if _, err := h.svc.Update(h.a, lab.View.ID, Input{Name: "Lab", Kind: privnet.KindConnector, Enabled: true,
		Routes: []privnet.Route{{CIDR: "10.30.0.0/16"}, {Host: "jira.corp.local"}}, CAPEM: ptr(caB)}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	// The most specific route picks the network.
	for _, c := range []struct {
		host string
		want int64
	}{
		{"10.1.2.3", office.View.ID}, {"10.30.0.9", lab.View.ID},
		{"gitlab.corp.local", office.View.ID}, {"jira.corp.local", lab.View.ID},
	} {
		if n, ok := h.router.Pick(h.wsA, c.host, 443); !ok || n.ID != c.want {
			t.Errorf("%s went through %d, want %d", c.host, n.ID, c.want)
		}
	}
	h.svc.SetRuns(nil, func(string) (runner.Identity, bool) { return runner.Identity{Workspace: h.wsA}, true })
	if got := h.internal(t, http.MethodGet, "/egress/route?ip=1.2.3.4&host=10.30.0.9&port=443", ""); !strings.Contains(got, fmt.Sprintf(`"network":%d`, lab.View.ID)) {
		t.Errorf("egress route: %s", got)
	}

	// Test with a network that is not the one the routes pick says so.
	res, err := h.svc.Test(h.a, "jira.corp.local:443", office.View.ID)
	if err != nil || res.OK || res.NetworkID != lab.View.ID || !strings.Contains(res.Error, "goes through Lab") {
		t.Errorf("test through the wrong network: %+v %v", res, err)
	}

	// Runs trust both networks' CAs.
	if got := string(h.svc.CA(h.a)); strings.Count(got, "BEGIN CERTIFICATE") != 2 {
		t.Errorf("CA bundle has %d certificates", strings.Count(got, "BEGIN CERTIFICATE"))
	}

	// Only a tracker reached through a VPN network is polled faster: a
	// Jira on the connector network relays its webhooks.
	polled := func(u string) bool {
		got := false
		h.svc.PolledBy(func(context.Context) string { return u })(context.Background(), func(ctx context.Context) {
			if domain.WorkspaceOf(ctx) == h.wsA {
				got = true
			}
		})
		return got
	}
	if !polled("https://tracker.corp.local") || polled("https://jira.corp.local") || polled("https://acme.atlassian.net") {
		t.Error("polling follows the wrong networks")
	}

	// The limit.
	for i := 3; i <= 5; i++ {
		if _, err := h.svc.Create(h.a, Input{Name: fmt.Sprintf("N%d", i), Kind: privnet.KindConnector,
			Routes: []privnet.Route{{Host: fmt.Sprintf("h%d.example.local", i)}}}, domain.OriginWeb); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := h.svc.Create(h.a, Input{Name: "N6", Kind: privnet.KindConnector, Routes: []privnet.Route{{Host: "h6.example.local"}}},
		domain.OriginWeb); !errors.Is(err, ErrInvalid) {
		t.Errorf("a sixth network: %v", err)
	}
}

// TestReseal seals a secret of the single-network days again, bound to its
// network, without restarting the tunnel.
func TestReseal(t *testing.T) {
	h := setup(t)
	saved, err := h.svc.Create(h.a, Input{Name: "Corp", Kind: privnet.KindWireGuard, Enabled: true, Config: ptr(wg),
		Routes: []privnet.Route{{CIDR: "10.20.0.0/16"}}}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	id := saved.View.ID
	legacy, err := h.box.Seal([]byte(`{"config":"`+strings.ReplaceAll(wg, "\n", `\n`)+`"}`), privnet.LegacySecretAAD(h.wsA))
	if err != nil {
		t.Fatal(err)
	}
	pool := h.pool
	if _, err := pool.Exec(domain.System(context.Background()), `UPDATE private_networks SET secret_enc = $2, secret_v = 1 WHERE id = $1`, id, legacy); err != nil {
		t.Fatal(err)
	}
	before, _ := h.svc.Get(h.a, id)
	// The gateway does not get a legacy secret: it could not open it.
	var feed []privnet.Network
	if err := json.Unmarshal([]byte(h.internal(t, http.MethodGet, "/gateway/networks", "")), &feed); err != nil {
		t.Fatal(err)
	}
	found := false
	for _, n := range feed {
		if n.ID == id {
			found = true
			if len(n.Secret) != 0 {
				t.Error("legacy secret in the feed")
			}
		}
	}
	if !found {
		t.Error("the network is missing from the feed")
	}
	h.svc.reseal(context.Background())
	var sealed []byte
	var v int
	if err := pool.QueryRow(domain.System(context.Background()), `SELECT secret_enc, secret_v FROM private_networks WHERE id = $1`, id).Scan(&sealed, &v); err != nil {
		t.Fatal(err)
	}
	pt, err := h.box.Open(sealed, privnet.SecretAAD(h.wsA, id))
	if v != 2 || err != nil || !strings.Contains(string(pt), "PrivateKey") {
		t.Fatalf("resealed: v%d %v", v, err)
	}
	if after, _ := h.svc.Get(h.a, id); !after.UpdatedAt.Equal(before.UpdatedAt) {
		t.Error("resealing restarted the tunnel")
	}
}

func (h *harness) internal(t *testing.T, method, path, body string) string {
	t.Helper()
	mux := http.NewServeMux()
	h.svc.Internal(mux)
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("%s %s without the secret: %d", method, path, rec.Code)
	}
	req = httptest.NewRequest(method, path, strings.NewReader(body))
	req.Header.Set("Authorization", "Bearer s3cret-s3cret-s3cret-s3cret")
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	return rec.Body.String()
}
