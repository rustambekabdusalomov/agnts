package egress

import (
	"bufio"
	"crypto/tls"
	"encoding/binary"
	"encoding/json"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"testing"
)

// fakeUpstream is a CONNECT or SOCKS5 proxy that sends every tunnel to
// target, whatever host it was asked for, and remembers what was asked.
type fakeUpstream struct {
	ln     net.Listener
	target string
	mu     sync.Mutex
	asked  []string
}

func (f *fakeUpstream) seen() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]string(nil), f.asked...)
}

func startUpstream(t *testing.T, target string, socks bool) *fakeUpstream {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	f := &fakeUpstream{ln: ln, target: target}
	t.Cleanup(func() { _ = ln.Close() })
	go func() {
		for {
			c, err := ln.Accept()
			if err != nil {
				return
			}
			go f.serve(c, socks)
		}
	}()
	return f
}

func (f *fakeUpstream) serve(c net.Conn, socks bool) {
	defer func() { _ = c.Close() }()
	br := bufio.NewReader(c)
	var asked string
	if socks {
		// Greeting: version, methods; then user/password auth (RFC 1929).
		h := make([]byte, 2)
		if _, err := io.ReadFull(br, h); err != nil {
			return
		}
		_, _ = io.ReadFull(br, make([]byte, h[1]))
		_, _ = c.Write([]byte{5, 2})
		v := make([]byte, 2)
		_, _ = io.ReadFull(br, v)
		user := make([]byte, v[1])
		_, _ = io.ReadFull(br, user)
		pl := make([]byte, 1)
		_, _ = io.ReadFull(br, pl)
		pass := make([]byte, pl[0])
		_, _ = io.ReadFull(br, pass)
		if string(user) != "u" || string(pass) != "p" {
			_, _ = c.Write([]byte{1, 1})
			return
		}
		_, _ = c.Write([]byte{1, 0})
		req := make([]byte, 4)
		_, _ = io.ReadFull(br, req)
		if req[3] != 3 { // a domain name
			return
		}
		n := make([]byte, 1)
		_, _ = io.ReadFull(br, n)
		name := make([]byte, n[0])
		_, _ = io.ReadFull(br, name)
		port := make([]byte, 2)
		_, _ = io.ReadFull(br, port)
		asked = net.JoinHostPort(string(name), strconv.Itoa(int(binary.BigEndian.Uint16(port))))
		_, _ = c.Write([]byte{5, 0, 0, 1, 0, 0, 0, 0, 0, 0})
	} else {
		r, err := http.ReadRequest(br)
		if err != nil || r.Method != http.MethodConnect {
			return
		}
		if r.Header.Get("Proxy-Authorization") != "Basic dTpw" { // u:p
			_, _ = io.WriteString(c, "HTTP/1.1 407 Proxy Authentication Required\r\n\r\n")
			return
		}
		asked = r.Host
		_, _ = io.WriteString(c, "HTTP/1.1 200 Connection established\r\n\r\n")
	}
	f.mu.Lock()
	f.asked = append(f.asked, asked)
	f.mu.Unlock()
	up, err := net.Dial("tcp", f.target)
	if err != nil {
		return
	}
	defer func() { _ = up.Close() }()
	go func() { _, _ = io.Copy(up, br) }()
	_, _ = io.Copy(c, up)
}

func TestUpstreamCarriesOnlyItsHosts(t *testing.T) {
	site := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = io.WriteString(w, "hello") }))
	defer site.Close()
	target := strings.TrimPrefix(site.URL, "https://")
	_, port, _ := net.SplitHostPort(target)

	for _, socks := range []bool{false, true} {
		up := startUpstream(t, target, socks)
		scheme := "http"
		if socks {
			scheme = "socks5"
		}
		u, err := ParseUpstream(scheme+"://u:p@"+up.ln.Addr().String(), "api.meta.ai,.meta.com")
		if err != nil {
			t.Fatal(err)
		}
		if strings.Contains(u.String(), ":p@") {
			t.Fatalf("password in %s", u)
		}
		// "api.meta.ai" does not resolve here: only the upstream can reach it.
		p := New([]string{"api.meta.ai", "localhost"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
		p.ports[port] = true
		p.SetUpstream(u)
		front := httptest.NewServer(p)
		pu, _ := url.Parse(front.URL)
		c := &http.Client{Transport: &http.Transport{Proxy: http.ProxyURL(pu), TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}} //nolint:gosec // test server
		res, err := c.Get("https://api.meta.ai:" + port + "/")
		if err != nil {
			t.Fatalf("%s: through the upstream: %v", scheme, err)
		}
		b, _ := io.ReadAll(res.Body)
		_ = res.Body.Close()
		if string(b) != "hello" || len(up.seen()) != 1 || up.seen()[0] != "api.meta.ai:"+port {
			t.Fatalf("%s: got %q, upstream asked %v", scheme, b, up.seen())
		}
		// Other hosts go direct.
		if res, err := c.Get("https://localhost:" + port + "/"); err != nil {
			t.Fatalf("%s: direct: %v", scheme, err)
		} else {
			_ = res.Body.Close()
		}
		if len(up.seen()) != 1 {
			t.Fatalf("%s: a direct host went through the upstream: %v", scheme, up.seen())
		}
		front.Close()
	}
}

func TestParseUpstream(t *testing.T) {
	for _, bad := range []string{"", "ftp://h:1", "socks5://h", "h:1080"} {
		if _, err := ParseUpstream(bad, ""); err == nil {
			t.Errorf("%q accepted", bad)
		}
	}
	u, err := ParseUpstream("socks5://h:1080", "")
	if err != nil || !u.carries("api.meta.ai") || !u.carries("AUTH.meta.com") || u.carries("api.anthropic.com") {
		t.Fatalf("defaults: %v %v", err, u)
	}
}

func TestMonitor(t *testing.T) {
	site := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = io.WriteString(w, "{}") }))
	defer site.Close()
	up := startUpstream(t, strings.TrimPrefix(site.URL, "https://"), true)
	u, err := ParseUpstream("socks5://u:p@"+up.ln.Addr().String(), "")
	if err != nil {
		t.Fatal(err)
	}
	p := New([]string{"api.meta.ai"}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	m := p.SetUpstream(u)
	m.tls = &tls.Config{InsecureSkipVerify: true} //nolint:gosec // test server
	if !m.check(t.Context()) {
		t.Fatalf("check through a working upstream failed: %+v", m.Status())
	}
	st := m.Status()
	if !st.OK || st.LastOKAt == nil || st.DownSince != nil || st.Target != "api.meta.ai" || len(st.History) != 1 || strings.Contains(st.Via, ":p@") {
		t.Fatalf("up: %+v", st)
	}

	// The tunnel goes away: down, with a reason that says what to look at.
	_ = up.ln.Close()
	m.check(t.Context())
	m.check(t.Context())
	st = m.Status()
	if st.OK || st.DownSince == nil || !strings.Contains(st.Error, "tunnel or proxy running") || len(st.History) != 3 || st.LastOKAt == nil {
		t.Fatalf("down: %+v", st)
	}

	// Served on its path, as a plain request.
	rec := httptest.NewRecorder()
	p.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, StatusPath, nil))
	var got UpstreamStatus
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil || !got.Configured || got.OK || len(got.History) != 3 {
		t.Fatalf("status endpoint: %v %s", err, rec.Body)
	}
	// Without an upstream it says so.
	rec = httptest.NewRecorder()
	New(nil, slog.New(slog.NewTextHandler(io.Discard, nil))).ServeHTTP(rec, httptest.NewRequest(http.MethodGet, StatusPath, nil))
	if !strings.Contains(rec.Body.String(), `"configured":false`) {
		t.Fatalf("no upstream: %s", rec.Body)
	}
}
