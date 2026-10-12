package gateway

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strconv"

	"agnts/internal/privnet"
)

// ovpnTunnel dials through an OpenVPN network's sidecar, a container agnts
// runs with the OpenVPN client and a SOCKS5 server on the sidecar network.
type ovpnTunnel struct {
	id             int64
	socks, status  string
	user, password string
	hc             *http.Client
}

func newOVPNTunnel(id int64, gatewaySecret string, port int) *ovpnTunnel {
	host := privnet.SidecarName(id)
	return &ovpnTunnel{
		id:       id,
		socks:    net.JoinHostPort(host, strconv.Itoa(port)),
		status:   "http://" + net.JoinHostPort(host, strconv.Itoa(port+1)) + "/status",
		user:     "agnts",
		password: privnet.SidecarPassword(gatewaySecret, id),
		hc:       &http.Client{},
	}
}

func (t *ovpnTunnel) Dial(ctx context.Context, addr string) (net.Conn, string, error) {
	c, bound, err := privnet.SocksDial(ctx, t.socks, t.user, t.password, addr)
	if err != nil {
		// SOCKS has no room for a reason: when the VPN is down, say why.
		if st := t.Status(ctx); st.State != privnet.StateUp {
			msg := "the VPN is not connected"
			if st.Error != "" {
				msg += ": " + st.Error
			}
			return nil, "", errors.New(msg)
		}
		return nil, "", fmt.Errorf("%s through OpenVPN: %w", addr, err)
	}
	resolved := ""
	if h, _, err := net.SplitHostPort(bound); err == nil && h != "0.0.0.0" {
		resolved = h
	}
	return c, resolved, nil
}

func (t *ovpnTunnel) Status(ctx context.Context) privnet.Status {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, t.status, nil)
	if err != nil {
		return privnet.Status{State: privnet.StateError, Error: err.Error()}
	}
	req.Header.Set("Authorization", "Bearer "+t.password)
	resp, err := t.hc.Do(req)
	if err != nil {
		return privnet.Status{State: privnet.StateConnecting, Error: "the OpenVPN sidecar is not running yet"}
	}
	defer func() { _ = resp.Body.Close() }()
	var st privnet.Status
	if resp.StatusCode != http.StatusOK || json.NewDecoder(io.LimitReader(resp.Body, 64<<10)).Decode(&st) != nil {
		return privnet.Status{State: privnet.StateError, Error: "the OpenVPN sidecar gave no status"}
	}
	return st
}

func (t *ovpnTunnel) Close() {}
