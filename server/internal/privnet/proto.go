package privnet

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Headers of a CONNECT to the gateway.
const (
	HeaderWorkspace = "X-Agnts-Workspace"
	HeaderNetwork   = "X-Agnts-Network"
	HeaderTicket    = "X-Agnts-Ticket"
	HeaderSource    = "X-Agnts-Source"
	// Answered by the gateway on success.
	HeaderResolved = "X-Agnts-Resolved"
	HeaderVia      = "X-Agnts-Via"
)

// DialRequest asks the gateway for a connection through a workspace's tunnel.
type DialRequest struct {
	Workspace int64
	Network   int64  // the network Pick chose; the gateway checks it again
	Target    string // host:port
	Ticket    string
	Source    string // run, server or test
}

// DialInfo is what the gateway said about the connection.
type DialInfo struct {
	Resolved string // the address the name resolved to on the tunnel's side
	Via      Kind
	Network  int64 // the network that carried it
}

// GatewayError is a refusal or failure the gateway explained.
type GatewayError struct {
	Status  int
	Message string
}

func (e *GatewayError) Error() string { return e.Message }

// DialGateway opens a connection to req.Target through the gateway at addr
// (host:port), authenticated with the shared gateway secret.
func DialGateway(ctx context.Context, addr, secret string, req DialRequest) (net.Conn, DialInfo, error) {
	var d net.Dialer
	conn, err := d.DialContext(ctx, "tcp", addr)
	if err != nil {
		return nil, DialInfo{}, fmt.Errorf("the gateway is not reachable: %w", err)
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(dl)
	} else {
		_ = conn.SetDeadline(time.Now().Add(45 * time.Second))
	}
	stop := context.AfterFunc(ctx, func() { _ = conn.SetDeadline(time.Unix(1, 0)) })
	defer stop()
	var b strings.Builder
	fmt.Fprintf(&b, "CONNECT %s HTTP/1.1\r\nHost: %s\r\nProxy-Authorization: Bearer %s\r\n", req.Target, req.Target, secret)
	fmt.Fprintf(&b, "%s: %d\r\n", HeaderWorkspace, req.Workspace)
	fmt.Fprintf(&b, "%s: %d\r\n", HeaderNetwork, req.Network)
	if req.Ticket != "" {
		fmt.Fprintf(&b, "%s: %s\r\n", HeaderTicket, headerSafe(req.Ticket))
	}
	if req.Source != "" {
		fmt.Fprintf(&b, "%s: %s\r\n", HeaderSource, headerSafe(req.Source))
	}
	b.WriteString("\r\n")
	if _, err := io.WriteString(conn, b.String()); err != nil {
		_ = conn.Close()
		return nil, DialInfo{}, err
	}
	br := bufio.NewReader(conn)
	resp, err := http.ReadResponse(br, &http.Request{Method: http.MethodConnect})
	if err != nil {
		_ = conn.Close()
		if ctx.Err() != nil {
			return nil, DialInfo{}, ctx.Err()
		}
		return nil, DialInfo{}, fmt.Errorf("gateway: %w", err)
	}
	// A 2xx answer to CONNECT has no body (the connection is the tunnel).
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		msg, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		_ = conn.Close()
		return nil, DialInfo{}, &GatewayError{Status: resp.StatusCode, Message: strings.TrimSpace(string(msg))}
	}
	_ = conn.SetDeadline(time.Time{})
	info := DialInfo{Resolved: resp.Header.Get(HeaderResolved), Via: Kind(resp.Header.Get(HeaderVia))}
	info.Network, _ = ParseWorkspace(resp.Header.Get(HeaderNetwork))
	return &BufConn{Conn: conn, R: br}, info, nil
}

func headerSafe(s string) string {
	return strings.Map(func(r rune) rune {
		if r < 0x20 || r == 0x7f {
			return -1
		}
		return r
	}, s)
}

// BufConn is a connection whose first bytes were already read into R.
type BufConn struct {
	net.Conn
	R *bufio.Reader
}

func (c *BufConn) Read(p []byte) (int, error) { return c.R.Read(p) }

// CloseWrite half-closes the connection when the one underneath can.
func (c *BufConn) CloseWrite() error { return closeWrite(c.Conn) }

func closeWrite(c net.Conn) error {
	if cw, ok := c.(interface{ CloseWrite() error }); ok {
		return cw.CloseWrite()
	}
	return nil
}

// Splice copies both ways until both directions end and reports the bytes
// read from a (in) and from b (out).
func Splice(a, b net.Conn) (aToB, bToA int64) {
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		aToB, _ = io.Copy(b, a)
		if closeWrite(b) != nil {
			_ = b.Close()
		}
	}()
	go func() {
		defer wg.Done()
		bToA, _ = io.Copy(a, b)
		if closeWrite(a) != nil {
			_ = a.Close()
		}
	}()
	wg.Wait()
	_ = a.Close()
	_ = b.Close()
	return aToB, bToA
}

// ---- the connector's stream protocol ----
//
// Every yamux stream between the gateway and agnts-link starts with one
// JSON line. The gateway opens "dial" streams; agnts-link answers with a
// reply line, then the stream carries the connection's bytes. agnts-link
// opens "hook" streams for webhooks: an HTTP request follows the line, and
// the gateway writes the HTTP response back.

// Stream operations.
const (
	OpDial = "dial"
	OpHook = "hook"
)

// StreamHeader opens a stream.
type StreamHeader struct {
	Op   string `json:"op"`
	Addr string `json:"addr,omitempty"`
}

// StreamReply answers a dial.
type StreamReply struct {
	OK    bool   `json:"ok"`
	IP    string `json:"ip,omitempty"`
	Error string `json:"error,omitempty"`
}

const maxLine = 4096

// WriteLine writes v as one JSON line.
func WriteLine(w io.Writer, v any) error {
	b, err := json.Marshal(v)
	if err != nil {
		return err
	}
	_, err = w.Write(append(b, '\n'))
	return err
}

// ReadLine reads one JSON line into v.
func ReadLine(r *bufio.Reader, v any) error {
	var line []byte
	for {
		chunk, isPrefix, err := r.ReadLine()
		if err != nil {
			return err
		}
		line = append(line, chunk...)
		if len(line) > maxLine {
			return errors.New("line too long")
		}
		if !isPrefix {
			break
		}
	}
	return json.Unmarshal(line, v)
}

// LinkPath is where agnts-link connects, through Caddy, to the gateway.
const LinkPath = "/link"

// LinkProtocol is the Upgrade token of a connector session.
const LinkProtocol = "agnts-link/1"

// ParseWorkspace reads a positive workspace (or network) id.
func ParseWorkspace(s string) (int64, bool) {
	n, err := strconv.ParseInt(strings.TrimSpace(s), 10, 64)
	return n, err == nil && n > 0
}
