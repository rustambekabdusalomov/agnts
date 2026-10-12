package egress

import (
	"bufio"
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"
)

func TestAllowed(t *testing.T) {
	p := New([]string{"api.anthropic.com", "*.githubusercontent.com", ".npmjs.org"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	for host, want := range map[string]bool{
		"api.anthropic.com": true, "API.anthropic.com.": true, "evil-api.anthropic.com": false,
		"objects.githubusercontent.com": true, "githubusercontent.com": false, "registry.npmjs.org": true,
		"example.com": false, "1.2.3.4": false, "anthropic.com": false,
	} {
		if got := p.Allowed(host); got != want {
			t.Errorf("%s: %v", host, got)
		}
	}
}

func TestConnectThroughProxy(t *testing.T) {
	upstream := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = io.WriteString(w, "hello") }))
	defer upstream.Close()
	_, port, _ := net.SplitHostPort(strings.TrimPrefix(upstream.URL, "https://"))

	p := New([]string{"allowed.test"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	p.ports[port] = true
	// Resolve the allowed name to the test server.
	p.dial = func(ctx context.Context, network, addr string) (net.Conn, error) {
		var d net.Dialer
		return d.DialContext(ctx, network, "127.0.0.1:"+port)
	}
	proxy := httptest.NewServer(p)
	defer proxy.Close()
	pu, _ := url.Parse(proxy.URL)
	client := &http.Client{Transport: &http.Transport{Proxy: http.ProxyURL(pu), TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}} //nolint:gosec // test server

	resp, err := client.Get("https://allowed.test:" + port + "/")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(resp.Body)
	_ = resp.Body.Close()
	if string(b) != "hello" {
		t.Fatalf("body %q", b)
	}
	if resp, err := client.Get("https://blocked.test:" + port + "/"); err == nil {
		_ = resp.Body.Close()
		t.Fatal("blocked host reached")
	}
}

func TestExtraAllowList(t *testing.T) {
	p := New([]string{"github.com"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	if p.Allowed("staging.acme.com") {
		t.Fatal("allowed before the extra list")
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "staging.acme.com\n# note\n.acme.dev\n")
	}))
	defer srv.Close()
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	go func() { p.Follow(ctx, srv.URL, time.Hour); close(done) }()
	deadline := time.Now().Add(5 * time.Second)
	for !p.Allowed("staging.acme.com") && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	cancel()
	<-done
	if !p.Allowed("staging.acme.com") || !p.Allowed("api.acme.dev") || !p.Allowed("github.com") {
		t.Fatal("extra list not applied")
	}
	if p.Allowed("10.0.0.1") || p.Allowed("acme.com") {
		t.Fatal("too much allowed")
	}
	p.SetExtra(nil)
	if p.Allowed("staging.acme.com") {
		t.Fatal("extra list not replaced")
	}
}

type fakeRouter struct {
	asked []string
}

func (f *fakeRouter) Route(_ context.Context, ip, host string, port int) (Private, bool, error) {
	f.asked = append(f.asked, ip+" "+host)
	if host == "gitlab.corp.local" || host == "10.20.0.5" {
		return Private{Workspace: 42, Ticket: "PAY-7"}, true, nil
	}
	return Private{}, false, nil
}

func TestPrivateNetwork(t *testing.T) {
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "inside "+r.Host)
	}))
	defer upstream.Close()
	p := New([]string{"github.com"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	router := &fakeRouter{}
	var via []string
	p.SetPrivate(router, func(ctx context.Context, pr Private, target string) (net.Conn, error) {
		via = append(via, fmt.Sprintf("%d %s %s", pr.Workspace, pr.Ticket, target))
		var d net.Dialer
		return d.DialContext(ctx, "tcp", strings.TrimPrefix(upstream.URL, "http://"))
	})
	p.dial = func(context.Context, string, string) (net.Conn, error) {
		return nil, errors.New("no internet in tests")
	}
	proxy := httptest.NewServer(p)
	defer proxy.Close()
	pu, _ := url.Parse(proxy.URL)
	client := &http.Client{Transport: &http.Transport{Proxy: http.ProxyURL(pu)}}

	// Plain http through the proxy and CONNECT (an http URL over a tunnel).
	resp, err := client.Get("http://gitlab.corp.local/api/v4/version")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(resp.Body)
	_ = resp.Body.Close()
	if string(b) != "inside gitlab.corp.local" {
		t.Fatalf("body %q", b)
	}
	conn, err := net.Dial("tcp", strings.TrimPrefix(proxy.URL, "http://"))
	if err != nil {
		t.Fatal(err)
	}
	_, _ = io.WriteString(conn, "CONNECT 10.20.0.5:443 HTTP/1.1\r\nHost: 10.20.0.5:443\r\n\r\n")
	cr, err := http.ReadResponse(bufio.NewReader(conn), &http.Request{Method: http.MethodConnect})
	if err != nil {
		t.Fatal(err)
	}
	_ = cr.Body.Close()
	if cr.StatusCode != http.StatusOK {
		t.Fatalf("CONNECT to a routed address: %v", cr.Status)
	}
	_ = conn.Close()

	// Not routed and not allowed: refused. Allowed hosts never ask the router.
	resp, err = client.Get("http://jira.other.local/")
	if err != nil {
		t.Fatal(err)
	}
	_ = resp.Body.Close()
	if resp.StatusCode != http.StatusForbidden {
		t.Errorf("unrouted host: %d", resp.StatusCode)
	}
	if resp, err := client.Get("http://github.com/"); err == nil {
		_ = resp.Body.Close()
	}
	for _, a := range router.asked {
		if strings.HasSuffix(a, " github.com") {
			t.Error("the router was asked about an allowlisted host")
		}
	}
	if len(via) != 2 || via[0] != "42 PAY-7 gitlab.corp.local:80" || via[1] != "42 PAY-7 10.20.0.5:443" {
		t.Errorf("gateway dials %v", via)
	}
}
