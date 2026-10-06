package egress

import (
	"context"
	"crypto/tls"
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
