package privnet

import (
	"context"
	"io"
	"net"
	"strings"
	"testing"
	"time"
)

func TestCleanRoutes(t *testing.T) {
	reserved := []string{"github.com", ".githubusercontent.com", "api.agnts.uz"}
	got, err := CleanRoutes([]Route{
		{Host: " GitLab.Corp.Local. ", Ports: []int{443, 443, 8443}},
		{Host: "*.corp.local"},
		{CIDR: "10.20.1.7/16"},
		{Host: "10.1.2.3"},
		{Host: "gitlab.corp.local", Ports: []int{443}}, // duplicate host
	}, reserved)
	if err != nil {
		t.Fatal(err)
	}
	want := []string{"gitlab.corp.local :443 :8443", ".corp.local", "10.20.0.0/16", "10.1.2.3/32"}
	if len(got) != len(want) {
		t.Fatalf("got %v", got)
	}
	for i, w := range want {
		if got[i].String() != w {
			t.Errorf("route %d: got %q, want %q", i, got[i].String(), w)
		}
	}

	for _, bad := range []Route{
		{Host: ".com"},                       // too broad
		{Host: "github.com"},                 // reserved
		{Host: ".github.com"},                // covers a reserved host
		{Host: "x.githubusercontent.com"},    // under a reserved domain
		{CIDR: "8.8.8.0/24"},                 // public
		{CIDR: "0.0.0.0/0"},                  // default route
		{CIDR: "169.254.169.254/32"},         // link-local (metadata)
		{CIDR: "127.0.0.0/8"},                // loopback
		{CIDR: "10.0.0.0/4"},                 // wider than a private range
		{Host: "localhost"},                  // never
		{Host: "a b"},                        // not a name
		{Host: "x.corp", CIDR: "10.0.0.0/8"}, // both
		{},                                   // neither
		{Host: "x.corp", Ports: []int{0}},    // bad port
	} {
		if _, err := CleanRoutes([]Route{bad}, reserved); err == nil {
			t.Errorf("%+v: accepted", bad)
		}
	}
	if _, err := CleanRoutes([]Route{{Host: ".corp"}, {Host: ".lan"}}, nil); err != nil {
		t.Errorf("internal one-label domains: %v", err)
	}
}

func TestMatch(t *testing.T) {
	routes := []Route{
		{Host: "gitlab.corp.local", Ports: []int{443}},
		{Host: ".svc.corp"},
		{CIDR: "10.20.0.0/16", Ports: []int{22, 443}},
	}
	for _, c := range []struct {
		host string
		port int
		want bool
	}{
		{"gitlab.corp.local", 443, true},
		{"GITLAB.corp.local.", 443, true},
		{"gitlab.corp.local", 80, false},
		{"evil-gitlab.corp.local", 443, false},
		{"nexus.svc.corp", 80, true},
		{"svc.corp", 443, true},
		{"nexus.svc.corp", 8081, false},
		{"10.20.3.4", 443, true},
		{"10.20.3.4", 80, false},
		{"10.21.0.1", 443, false},
		{"[fd00::1]", 443, false},
		{"jira.svc.corp.evil.com", 443, false},
	} {
		if got := Match(routes, c.host, c.port); got != c.want {
			t.Errorf("%s:%d: got %v", c.host, c.port, got)
		}
	}
}

const wgConf = `[Interface]
# laptop
PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=
Address = 10.8.0.2/32, fd00::2/128
DNS = 10.8.0.1, corp.local
MTU = 1380
PostUp = iptables -A FORWARD

[Peer]
PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=
PresharedKey = 9FIRkcURtxTHxKhqZ4+6kv/YC3EmtqLAA2JuZovWhdA=
Endpoint = vpn.corp.com:51820
AllowedIPs = 10.8.0.0/24, 10.20.0.0/16
`

func TestParseWireGuard(t *testing.T) {
	wg, err := ParseWireGuard(wgConf)
	if err != nil {
		t.Fatal(err)
	}
	if len(wg.Addresses) != 2 || len(wg.DNS) != 1 || wg.MTU != 1380 || len(wg.Peers) != 1 || len(wg.Peers[0].AllowedIPs) != 2 {
		t.Fatalf("%+v", wg)
	}
	if s := wg.Summary(); s != "peer vpn.corp.com:51820" {
		t.Errorf("summary %q", s)
	}
	uapi, err := wg.UAPI(func(string) (string, error) { return "203.0.113.5:51820", nil })
	if err != nil {
		t.Fatal(err)
	}
	for _, want := range []string{"private_key=c809f3e5317e95", "endpoint=203.0.113.5:51820", "persistent_keepalive_interval=25",
		"allowed_ip=10.20.0.0/16", "preshared_key="} {
		if !strings.Contains(uapi, want) {
			t.Errorf("uapi lacks %q:\n%s", want, uapi)
		}
	}
	for _, bad := range []string{
		"[Interface]\nAddress = 10.0.0.2/32\n[Peer]\nPublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=\nEndpoint = a:1\nAllowedIPs = 10.0.0.0/8",
		strings.Replace(wgConf, "Endpoint = vpn.corp.com:51820\n", "", 1),
		strings.Replace(wgConf, "PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=", "PrivateKey = short", 1),
		"[Wat]\nx = y",
	} {
		if _, err := ParseWireGuard(bad); err == nil {
			t.Errorf("accepted:\n%s", bad)
		}
	}
}

func TestParseOpenVPN(t *testing.T) {
	ok := "client\ndev tun\nproto udp\nremote vpn.corp.com 1194\nauth-user-pass\n<ca>\n-----BEGIN CERTIFICATE-----\nup /bin/sh\n-----END CERTIFICATE-----\n</ca>\n"
	o, err := ParseOpenVPN(ok)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := ParseOpenVPN(ok + "setenv opt block-outside-dns\n"); err != nil {
		t.Errorf("setenv opt: %v", err)
	}
	if o, err := ParseOpenVPN(strings.Replace(ok, "dev tun\n", "", 1)); err != nil || o.HasDev {
		t.Errorf("no dev line: %+v %v", o, err)
	}
	if !o.NeedsAuth || !o.HasDev || o.Summary() != "remote vpn.corp.com 1194 · username and password" {
		t.Errorf("%+v %q", o, o.Summary())
	}
	for _, bad := range []string{
		ok + "up /tmp/x.sh\n",
		ok + "script-security 2\n",
		ok + "--plugin /x.so\n",
		strings.Replace(ok, "auth-user-pass", "auth-user-pass /etc/creds", 1),
		ok + "ca /etc/ca.pem\n",
		"dev tun\nremote a 1\n",                      // not a client
		"client\ndev tun\n",                          // no remote
		"client\nremote a 1\n<ca>\nno end\n",         // unclosed
		strings.Replace(ok, "dev tun", "dev tap", 1), // bridged
	} {
		if _, err := ParseOpenVPN(bad); err == nil {
			t.Errorf("accepted:\n%s", bad)
		}
	}
}

func TestLinkToken(t *testing.T) {
	tok, hash := NewLinkToken()
	if !strings.HasPrefix(tok, LinkTokenPrefix) || HashToken(tok) != hash || HashToken(tok+"x") == hash {
		t.Fatal(tok, hash)
	}
	if p1 := SidecarPassword("s", 1); p1 == SidecarPassword("s", 2) || p1 != SidecarPassword("s", 1) || p1 == SidecarPassword("t", 1) {
		t.Fatal("sidecar passwords")
	}
}

func TestSocks(t *testing.T) {
	echo, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = echo.Close() }()
	go func() {
		for {
			c, err := echo.Accept()
			if err != nil {
				return
			}
			go func() { _, _ = io.Copy(c, c); _ = c.Close() }()
		}
	}()
	var asked string
	srv := &SocksServer{User: "agnts", Password: "pw", Dial: func(ctx context.Context, addr string) (net.Conn, error) {
		asked = addr
		var d net.Dialer
		return d.DialContext(ctx, "tcp", echo.Addr().String())
	}}
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = l.Close() }()
	go func() { _ = srv.Serve(l) }()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	c, bound, err := SocksDial(ctx, l.Addr().String(), "agnts", "pw", "gitlab.corp.local:443")
	if err != nil {
		t.Fatal(err)
	}
	if asked != "gitlab.corp.local:443" || !strings.HasPrefix(bound, "127.0.0.1:") {
		t.Errorf("asked %q, bound %q", asked, bound)
	}
	_, _ = c.Write([]byte("ping"))
	buf := make([]byte, 4)
	if _, err := io.ReadFull(c, buf); err != nil || string(buf) != "ping" {
		t.Errorf("echo: %q %v", buf, err)
	}
	_ = c.Close()

	if _, _, err := SocksDial(ctx, l.Addr().String(), "agnts", "wrong", "x.corp:443"); err == nil {
		t.Error("a wrong password connected")
	}
}

func TestPick(t *testing.T) {
	sets := []RouteSet{
		{ID: 1, Name: "Office", Routes: []Route{{CIDR: "10.0.0.0/8"}, {Host: ".corp.local"}}},
		{ID: 2, Name: "Lab", Routes: []Route{{CIDR: "10.30.0.0/16"}, {Host: ".lab.corp.local"}}},
		{ID: 3, Name: "Client A", Routes: []Route{{Host: "gitlab.lab.corp.local"}, {Host: "nexus.a.local", Ports: []int{8081}}}},
	}
	for _, c := range []struct {
		host string
		port int
		want int64
	}{
		{"10.1.2.3", 443, 1},
		{"10.30.0.5", 443, 2},             // the longer prefix wins
		{"jira.corp.local", 443, 1},       // only the shorter domain matches
		{"ci.lab.corp.local", 443, 2},     // the longer domain wins
		{"gitlab.lab.corp.local", 443, 3}, // an exact host beats any domain
		{"nexus.a.local", 8081, 3},
		{"nexus.a.local", 443, 0}, // not on its ports
		{"example.com", 443, 0},
		{"10.30.0.5", 22, 0},
	} {
		got, ok := Pick(sets, c.host, c.port)
		if ok != (c.want != 0) || got != c.want {
			t.Errorf("Pick(%s:%d) = %d, %v; want %d", c.host, c.port, got, ok, c.want)
		}
	}
	// A tie (never saved, but possible in old data) goes to the lowest id.
	tie := []RouteSet{{ID: 9, Routes: []Route{{Host: "a.local"}}}, {ID: 4, Routes: []Route{{Host: "a.local"}}}}
	if got, _ := Pick(tie, "a.local", 443); got != 4 {
		t.Errorf("tie went to %d, want 4", got)
	}
}

func TestCheckConflicts(t *testing.T) {
	others := []RouteSet{{ID: 1, Name: "Office", Routes: []Route{{CIDR: "10.0.0.0/8"}, {Host: ".corp.local", Ports: []int{443}}}}}
	for _, c := range []struct {
		routes []Route
		bad    bool
	}{
		{[]Route{{CIDR: "10.30.0.0/16"}}, false},                    // nested: the more specific wins
		{[]Route{{Host: "gitlab.corp.local"}}, false},               // a host under the domain
		{[]Route{{CIDR: "10.0.0.0/8", Ports: []int{8443}}}, false},  // same range, other ports
		{[]Route{{Host: ".corp.local", Ports: []int{8080}}}, false}, // same domain, other ports
		{[]Route{{CIDR: "10.0.0.0/8"}}, true},
		{[]Route{{CIDR: "10.0.0.0/8", Ports: []int{80}}}, true},
		{[]Route{{Host: ".corp.local"}}, true}, // default ports include 443
	} {
		err := CheckConflicts(c.routes, others)
		if (err != nil) != c.bad {
			t.Errorf("CheckConflicts(%v) = %v, want conflict %v", c.routes, err, c.bad)
		}
		if err != nil && !strings.Contains(err.Error(), `"Office"`) {
			t.Errorf("the error should name the other network: %v", err)
		}
	}
}
