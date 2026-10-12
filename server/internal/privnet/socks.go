package privnet

import (
	"context"
	"crypto/subtle"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"strconv"
	"syscall"
	"time"
)

// A minimal SOCKS5 (RFC 1928) with username/password auth (RFC 1929) and
// CONNECT only: the gateway's way into an OpenVPN sidecar. Names are sent
// to the sidecar unresolved, so DNS happens inside the tunnel. The sidecar
// puts the address it connected to in the reply's bound address, which is
// how the gateway learns what a name resolved to.

const socksVersion = 5

// SocksDial connects to target through the SOCKS5 server at proxy and
// returns the connection and the address the server connected to.
func SocksDial(ctx context.Context, proxy, user, password, target string) (net.Conn, string, error) {
	host, port, err := SplitHostPort(target)
	if err != nil {
		return nil, "", err
	}
	var d net.Dialer
	c, err := d.DialContext(ctx, "tcp", proxy)
	if err != nil {
		return nil, "", fmt.Errorf("the OpenVPN sidecar is not reachable: %w", err)
	}
	if dl, ok := ctx.Deadline(); ok {
		_ = c.SetDeadline(dl)
	} else {
		_ = c.SetDeadline(time.Now().Add(30 * time.Second))
	}
	stop := context.AfterFunc(ctx, func() { _ = c.SetDeadline(time.Unix(1, 0)) })
	defer stop()
	fail := func(err error) (net.Conn, string, error) {
		_ = c.Close()
		if ctx.Err() != nil {
			return nil, "", ctx.Err()
		}
		return nil, "", err
	}
	if _, err := c.Write([]byte{socksVersion, 1, 2}); err != nil {
		return fail(err)
	}
	var m [2]byte
	if _, err := io.ReadFull(c, m[:]); err != nil {
		return fail(err)
	}
	if m[0] != socksVersion || m[1] != 2 {
		return fail(errors.New("socks: the sidecar refused password auth"))
	}
	if len(user) > 255 || len(password) > 255 {
		return fail(errors.New("socks: credentials too long"))
	}
	auth := append([]byte{1, byte(len(user))}, user...)           //nolint:gosec // G115: checked <= 255 above
	auth = append(append(auth, byte(len(password))), password...) //nolint:gosec // G115: checked <= 255 above
	if _, err := c.Write(auth); err != nil {
		return fail(err)
	}
	if _, err := io.ReadFull(c, m[:]); err != nil {
		return fail(err)
	}
	if m[1] != 0 {
		return fail(errors.New("socks: the sidecar rejected the password"))
	}
	req := []byte{socksVersion, 1, 0}
	if a, err := netip.ParseAddr(host); err == nil {
		if a.Is4() {
			req = append(append(req, 1), a.AsSlice()...)
		} else {
			req = append(append(req, 4), a.AsSlice()...)
		}
	} else {
		if len(host) > 255 {
			return fail(errors.New("socks: host name too long"))
		}
		req = append(append(req, 3, byte(len(host))), host...) //nolint:gosec // G115: checked <= 255 above
	}
	req = binary.BigEndian.AppendUint16(req, uint16(port)) //nolint:gosec // G115: port is 1-65535
	if _, err := c.Write(req); err != nil {
		return fail(err)
	}
	var head [4]byte
	if _, err := io.ReadFull(c, head[:]); err != nil {
		return fail(err)
	}
	bound, err := readSocksAddr(c, head[3])
	if err != nil {
		return fail(err)
	}
	if head[1] != 0 {
		return fail(fmt.Errorf("socks: %s", socksReplies[head[1]]))
	}
	_ = c.SetDeadline(time.Time{})
	return c, bound, nil
}

var socksReplies = map[byte]string{
	1: "general failure", 2: "not allowed", 3: "network unreachable", 4: "host unreachable",
	5: "connection refused", 6: "timed out", 7: "command not supported", 8: "address type not supported",
}

func readSocksAddr(r io.Reader, atyp byte) (string, error) {
	var host string
	switch atyp {
	case 1, 4:
		n := 4
		if atyp == 4 {
			n = 16
		}
		b := make([]byte, n)
		if _, err := io.ReadFull(r, b); err != nil {
			return "", err
		}
		a, _ := netip.AddrFromSlice(b)
		host = a.Unmap().String()
	case 3:
		var l [1]byte
		if _, err := io.ReadFull(r, l[:]); err != nil {
			return "", err
		}
		b := make([]byte, l[0])
		if _, err := io.ReadFull(r, b); err != nil {
			return "", err
		}
		host = string(b)
	default:
		return "", errors.New("socks: bad address type")
	}
	var p [2]byte
	if _, err := io.ReadFull(r, p[:]); err != nil {
		return "", err
	}
	return net.JoinHostPort(host, strconv.Itoa(int(binary.BigEndian.Uint16(p[:])))), nil
}

// SocksServer serves SOCKS5 CONNECT for one user and password.
type SocksServer struct {
	User, Password string
	// Dial connects to host:port (a name is resolved by it).
	Dial func(ctx context.Context, addr string) (net.Conn, error)
}

// Serve accepts connections until l is closed.
func (s *SocksServer) Serve(l net.Listener) error {
	for {
		c, err := l.Accept()
		if err != nil {
			return err
		}
		go s.handle(c)
	}
}

func (s *SocksServer) handle(c net.Conn) {
	_ = c.SetDeadline(time.Now().Add(30 * time.Second))
	var head [2]byte
	if _, err := io.ReadFull(c, head[:]); err != nil || head[0] != socksVersion {
		_ = c.Close()
		return
	}
	methods := make([]byte, head[1])
	if _, err := io.ReadFull(c, methods); err != nil {
		_ = c.Close()
		return
	}
	hasPass := false
	for _, m := range methods {
		hasPass = hasPass || m == 2
	}
	if !hasPass {
		_, _ = c.Write([]byte{socksVersion, 0xff})
		_ = c.Close()
		return
	}
	_, _ = c.Write([]byte{socksVersion, 2})
	user, pass, err := readUserPass(c)
	if err != nil {
		_ = c.Close()
		return
	}
	ok := subtle.ConstantTimeCompare([]byte(user), []byte(s.User)) == 1 &&
		subtle.ConstantTimeCompare([]byte(pass), []byte(s.Password)) == 1
	if !ok {
		_, _ = c.Write([]byte{1, 1})
		_ = c.Close()
		return
	}
	_, _ = c.Write([]byte{1, 0})
	var req [4]byte
	if _, err := io.ReadFull(c, req[:]); err != nil {
		_ = c.Close()
		return
	}
	target, err := readSocksAddr(c, req[3])
	if err != nil {
		_ = c.Close()
		return
	}
	if req[1] != 1 {
		_, _ = c.Write([]byte{socksVersion, 7, 0, 1, 0, 0, 0, 0, 0, 0})
		_ = c.Close()
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	up, err := s.Dial(ctx, target)
	cancel()
	if err != nil {
		code := byte(4) // host unreachable
		var ne net.Error
		switch {
		case errors.Is(err, syscall.ECONNREFUSED):
			code = 5
		case errors.As(err, &ne) && ne.Timeout():
			code = 6
		}
		_, _ = c.Write([]byte{socksVersion, code, 0, 1, 0, 0, 0, 0, 0, 0})
		_ = c.Close()
		return
	}
	reply := []byte{socksVersion, 0, 0}
	if ap, err := netip.ParseAddrPort(up.RemoteAddr().String()); err == nil {
		a := ap.Addr().Unmap()
		if a.Is4() {
			reply = append(append(reply, 1), a.AsSlice()...)
		} else {
			reply = append(append(reply, 4), a.AsSlice()...)
		}
		reply = binary.BigEndian.AppendUint16(reply, ap.Port())
	} else {
		reply = append(reply, 1, 0, 0, 0, 0, 0, 0)
	}
	if _, err := c.Write(reply); err != nil {
		_ = c.Close()
		_ = up.Close()
		return
	}
	_ = c.SetDeadline(time.Time{})
	Splice(c, up)
}

func readUserPass(r io.Reader) (string, string, error) {
	var v [2]byte
	if _, err := io.ReadFull(r, v[:]); err != nil || v[0] != 1 {
		return "", "", errors.New("bad auth")
	}
	u := make([]byte, v[1])
	if _, err := io.ReadFull(r, u); err != nil {
		return "", "", err
	}
	var l [1]byte
	if _, err := io.ReadFull(r, l[:]); err != nil {
		return "", "", err
	}
	p := make([]byte, l[0])
	if _, err := io.ReadFull(r, p); err != nil {
		return "", "", err
	}
	return string(u), string(p), nil
}
