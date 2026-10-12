package gateway

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/netip"
	"strconv"
	"strings"
	"sync"
	"time"

	"golang.zx2c4.com/wireguard/conn"
	"golang.zx2c4.com/wireguard/device"
	"golang.zx2c4.com/wireguard/tun/netstack"

	"agnts/internal/privnet"
)

// wgTunnel is a WireGuard peer in user space: the packets go over UDP from
// the gateway, and TCP runs on a gVisor netstack of its own, so the
// gateway needs no privileges and workspaces with the same ranges never
// meet.
type wgTunnel struct {
	dev     *device.Device
	tnet    *netstack.Net
	dns     bool
	started time.Time

	mu    sync.Mutex
	since *time.Time
}

// handshakeFresh is how old the last handshake may be for the tunnel to
// count as up (WireGuard rekeys every two minutes while in use).
const handshakeFresh = 3 * time.Minute

func newWGTunnel(ctx context.Context, network int64, cfg privnet.WireGuard, log *slog.Logger) (*wgTunnel, error) {
	uapi, err := cfg.UAPI(func(hostport string) (string, error) { return resolveEndpoint(ctx, hostport) })
	if err != nil {
		return nil, err
	}
	tun, tnet, err := netstack.CreateNetTUN(cfg.Addresses, cfg.DNS, cfg.MTU)
	if err != nil {
		return nil, fmt.Errorf("create the tunnel: %w", err)
	}
	logger := &device.Logger{
		Verbosef: func(string, ...any) {},
		Errorf: func(format string, args ...any) {
			log.Debug("wireguard", "network", network, "msg", fmt.Sprintf(format, args...))
		},
	}
	dev := device.NewDevice(tun, conn.NewDefaultBind(), logger)
	if err := dev.IpcSet(uapi); err != nil {
		dev.Close()
		return nil, fmt.Errorf("configure the tunnel: %w", err)
	}
	if err := dev.Up(); err != nil {
		dev.Close()
		return nil, fmt.Errorf("bring the tunnel up: %w", err)
	}
	return &wgTunnel{dev: dev, tnet: tnet, dns: len(cfg.DNS) > 0, started: time.Now()}, nil
}

// resolveEndpoint turns a peer's host:port into ip:port (IPv4 first).
func resolveEndpoint(ctx context.Context, hostport string) (string, error) {
	host, port, err := net.SplitHostPort(hostport)
	if err != nil {
		return "", err
	}
	if a, err := netip.ParseAddr(host); err == nil {
		return netip.AddrPortFrom(a, mustPort(port)).String(), nil
	}
	c, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	addrs, err := net.DefaultResolver.LookupNetIP(c, "ip", host)
	if err != nil {
		return "", err
	}
	if len(addrs) == 0 {
		return "", errors.New("no address")
	}
	best := addrs[0]
	for _, a := range addrs {
		if a.Unmap().Is4() {
			best = a.Unmap()
			break
		}
	}
	return netip.AddrPortFrom(best, mustPort(port)).String(), nil
}

func mustPort(p string) uint16 {
	n, _ := strconv.ParseUint(p, 10, 16)
	return uint16(n)
}

func (t *wgTunnel) Dial(ctx context.Context, addr string) (net.Conn, string, error) {
	host, _, err := privnet.SplitHostPort(addr)
	if err != nil {
		return nil, "", err
	}
	if _, err := netip.ParseAddr(host); err != nil && !t.dns {
		return nil, "", fmt.Errorf("%s is a name, and the WireGuard config has no DNS line to resolve it inside the tunnel: add DNS = <your DNS server> or route the address", host)
	}
	c, err := t.tnet.DialContext(ctx, "tcp", addr)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, "", fmt.Errorf("%s did not answer through the tunnel (is the peer up, and does AllowedIPs cover it?)", addr)
		}
		return nil, "", fmt.Errorf("dial %s through WireGuard: %w", addr, err)
	}
	resolved := ""
	if ta, ok := c.RemoteAddr().(*net.TCPAddr); ok {
		resolved = ta.IP.String()
	}
	return c, resolved, nil
}

func (t *wgTunnel) Status(context.Context) privnet.Status {
	var last time.Time
	if cfg, err := t.dev.IpcGet(); err == nil {
		sc := bufio.NewScanner(strings.NewReader(cfg))
		for sc.Scan() {
			if v, ok := strings.CutPrefix(sc.Text(), "last_handshake_time_sec="); ok {
				if n, err := strconv.ParseInt(v, 10, 64); err == nil && n > 0 {
					if ts := time.Unix(n, 0); ts.After(last) {
						last = ts
					}
				}
			}
		}
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	st := privnet.Status{}
	if !last.IsZero() {
		hs := last.UTC()
		st.Handshake = &hs
	}
	switch {
	case !last.IsZero() && time.Since(last) < handshakeFresh:
		if t.since == nil {
			now := time.Now().UTC()
			t.since = &now
		}
		st.State, st.Since = privnet.StateUp, t.since
	case time.Since(t.started) > time.Minute:
		t.since = nil
		st.State = privnet.StateError
		if last.IsZero() {
			st.Error = "no handshake with the peer: check the endpoint, the keys, and that the peer accepts UDP from this server"
		} else {
			st.Error = "no handshake for " + time.Since(last).Round(time.Second).String()
		}
	default:
		st.State = privnet.StateConnecting
	}
	return st
}

func (t *wgTunnel) Close() { t.dev.Close() }
