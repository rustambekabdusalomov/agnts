package netroute

import (
	"bufio"
	"context"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/privnet"
)

func TestRoundTripByWorkspace(t *testing.T) {
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "inside "+r.Host)
	}))
	defer upstream.Close()
	_, port, _ := net.SplitHostPort(strings.TrimPrefix(upstream.URL, "http://"))
	pn, _ := strconv.Atoi(port)

	// A gateway that connects every CONNECT to the upstream.
	var connects atomic.Int32
	var lastWS atomic.Value
	gw, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = gw.Close() }()
	go func() {
		for {
			c, err := gw.Accept()
			if err != nil {
				return
			}
			go func() {
				req, err := http.ReadRequest(bufio.NewReader(c))
				if err != nil || req.Header.Get("Proxy-Authorization") != "Bearer s3cret" {
					_ = c.Close()
					return
				}
				connects.Add(1)
				lastWS.Store(req.Header.Get(privnet.HeaderWorkspace) + "/" + req.Header.Get(privnet.HeaderNetwork) + " " + req.Host)
				up, err := net.Dial("tcp", strings.TrimPrefix(upstream.URL, "http://"))
				if err != nil {
					_ = c.Close()
					return
				}
				_, _ = io.WriteString(c, "HTTP/1.1 200 OK\r\n\r\n")
				privnet.Splice(c, up)
			}()
		}
	}()

	r := New(gw.Addr().String(), "s3cret")
	// Two networks in workspace 5: the exact host beats the domain.
	r.Set(map[int64][]Network{5: {
		{ID: 11, Routes: []privnet.Route{{Host: ".corp.local", Ports: []int{pn}}}, Version: "1"},
		{ID: 12, Routes: []privnet.Route{{Host: "gitlab.corp.local", Ports: []int{pn}}}, Version: "1"},
	}})
	Install(r)
	defer Install(nil)
	c := Client(0)

	req, _ := http.NewRequestWithContext(domain.WithWorkspace(context.Background(), 5), http.MethodGet, "http://gitlab.corp.local:"+port+"/x", nil)
	resp, err := c.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(resp.Body)
	_ = resp.Body.Close()
	if string(b) != "inside gitlab.corp.local:"+port || connects.Load() != 1 || lastWS.Load() != "5/12 gitlab.corp.local:"+port {
		t.Fatalf("body %q, connects %d, %v", b, connects.Load(), lastWS.Load())
	}

	// A host only the domain covers goes through the other network.
	req, _ = http.NewRequestWithContext(domain.WithWorkspace(context.Background(), 5), http.MethodGet, "http://jira.corp.local:"+port+"/x", nil)
	resp, err = c.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	_ = resp.Body.Close()
	if connects.Load() != 2 || lastWS.Load() != "5/11 jira.corp.local:"+port {
		t.Fatalf("connects %d, %v", connects.Load(), lastWS.Load())
	}

	// Another workspace, or no workspace, never goes through the gateway.
	for _, ctx := range []context.Context{domain.WithWorkspace(context.Background(), 6), context.Background()} {
		req, _ = http.NewRequestWithContext(ctx, http.MethodGet, upstream.URL+"/direct", nil)
		resp, err := c.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		_ = resp.Body.Close()
	}
	if connects.Load() != 2 {
		t.Errorf("connects %d", connects.Load())
	}
}
