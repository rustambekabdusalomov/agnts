package privnet

import (
	"bufio"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"net"
	"net/netip"
	"strconv"
	"strings"
)

// WireGuard is a wg-quick config ([Interface] and [Peer] sections) as the
// gateway needs it. PostUp, Table and other wg-quick extras are ignored:
// the gateway runs the tunnel in user space, not as a host interface.
type WireGuard struct {
	PrivateKey []byte
	Addresses  []netip.Addr
	DNS        []netip.Addr
	MTU        int
	ListenPort int
	Peers      []WireGuardPeer
}

// WireGuardPeer is one [Peer] section.
type WireGuardPeer struct {
	PublicKey    []byte
	PresharedKey []byte
	Endpoint     string // host:port as written; resolved when the tunnel starts
	AllowedIPs   []netip.Prefix
	Keepalive    int
}

// DefaultKeepalive keeps the handshake fresh (and the status accurate)
// when the config does not set PersistentKeepalive.
const DefaultKeepalive = 25

// ParseWireGuard reads a wg-quick config.
func ParseWireGuard(text string) (WireGuard, error) {
	var wg WireGuard
	section := ""
	var peer *WireGuardPeer
	sc := bufio.NewScanner(strings.NewReader(text))
	line := 0
	for sc.Scan() {
		line++
		l := strings.TrimSpace(sc.Text())
		if i := strings.IndexAny(l, "#;"); i >= 0 {
			l = strings.TrimSpace(l[:i])
		}
		if l == "" {
			continue
		}
		if strings.HasPrefix(l, "[") && strings.HasSuffix(l, "]") {
			section = strings.ToLower(strings.Trim(l, "[] "))
			switch section {
			case "interface":
			case "peer":
				wg.Peers = append(wg.Peers, WireGuardPeer{})
				peer = &wg.Peers[len(wg.Peers)-1]
			default:
				return wg, fmt.Errorf("line %d: unknown section [%s]", line, section)
			}
			continue
		}
		k, v, ok := strings.Cut(l, "=")
		if !ok {
			return wg, fmt.Errorf("line %d: expected key = value", line)
		}
		k, v = strings.ToLower(strings.TrimSpace(k)), strings.TrimSpace(v)
		var err error
		switch section {
		case "interface":
			err = wg.setInterface(k, v)
		case "peer":
			err = peer.set(k, v)
		default:
			err = errors.New("a setting outside [Interface] or [Peer]")
		}
		if err != nil {
			return wg, fmt.Errorf("line %d: %w", line, err)
		}
	}
	if len(wg.PrivateKey) == 0 {
		return wg, errors.New("[Interface] has no PrivateKey")
	}
	if len(wg.Addresses) == 0 {
		return wg, errors.New("[Interface] has no Address")
	}
	if len(wg.Peers) == 0 {
		return wg, errors.New("the config has no [Peer]")
	}
	for i, p := range wg.Peers {
		if len(p.PublicKey) == 0 {
			return wg, fmt.Errorf("peer %d has no PublicKey", i+1)
		}
		if p.Endpoint == "" {
			return wg, fmt.Errorf("peer %d has no Endpoint: agnts connects out, so the peer must be reachable", i+1)
		}
		if len(p.AllowedIPs) == 0 {
			return wg, fmt.Errorf("peer %d has no AllowedIPs", i+1)
		}
	}
	if wg.MTU == 0 {
		wg.MTU = 1420
	}
	return wg, nil
}

func (wg *WireGuard) setInterface(k, v string) error {
	switch k {
	case "privatekey":
		b, err := wgKey(v)
		wg.PrivateKey = b
		return err
	case "address":
		for _, a := range splitList(v) {
			if p, err := netip.ParsePrefix(a); err == nil {
				wg.Addresses = append(wg.Addresses, p.Addr())
			} else if ad, err := netip.ParseAddr(a); err == nil {
				wg.Addresses = append(wg.Addresses, ad)
			} else {
				return fmt.Errorf("the address %q is not an address", a)
			}
		}
	case "dns":
		for _, a := range splitList(v) {
			// wg-quick also takes search domains here; only addresses matter.
			if ad, err := netip.ParseAddr(a); err == nil {
				wg.DNS = append(wg.DNS, ad)
			}
		}
	case "mtu":
		n, err := strconv.Atoi(v)
		if err != nil || n < 576 || n > 9000 {
			return fmt.Errorf("MTU %q is out of range", v)
		}
		wg.MTU = n
	case "listenport":
		n, err := strconv.Atoi(v)
		if err != nil || n < 0 || n > 65535 {
			return fmt.Errorf("ListenPort %q is out of range", v)
		}
		wg.ListenPort = n
	}
	return nil // PostUp, Table, SaveConfig...: host interface settings
}

func (p *WireGuardPeer) set(k, v string) error {
	var err error
	switch k {
	case "publickey":
		p.PublicKey, err = wgKey(v)
	case "presharedkey":
		p.PresharedKey, err = wgKey(v)
	case "endpoint":
		if _, _, e := net.SplitHostPort(v); e != nil {
			return fmt.Errorf("the endpoint %q is not host:port", v)
		}
		p.Endpoint = v
	case "allowedips":
		for _, a := range splitList(v) {
			pr, e := netip.ParsePrefix(a)
			if e != nil {
				return fmt.Errorf("AllowedIPs %q is not a range", a)
			}
			p.AllowedIPs = append(p.AllowedIPs, pr.Masked())
		}
	case "persistentkeepalive":
		if v == "off" {
			return nil
		}
		n, e := strconv.Atoi(v)
		if e != nil || n < 0 || n > 65535 {
			return fmt.Errorf("PersistentKeepalive %q is out of range", v)
		}
		p.Keepalive = n
	}
	return err
}

func wgKey(v string) ([]byte, error) {
	b, err := base64.StdEncoding.DecodeString(v)
	if err != nil || len(b) != 32 {
		return nil, errors.New("a key must be 32 bytes of base64")
	}
	return b, nil
}

func splitList(v string) []string {
	var out []string
	for s := range strings.SplitSeq(v, ",") {
		if s = strings.TrimSpace(s); s != "" {
			out = append(out, s)
		}
	}
	return out
}

// Summary describes the config without its keys: "peer vpn.corp.com:51820".
func (wg WireGuard) Summary() string {
	eps := make([]string, 0, len(wg.Peers))
	for _, p := range wg.Peers {
		eps = append(eps, p.Endpoint)
	}
	s := "peer " + strings.Join(eps, ", ")
	if len(wg.DNS) == 0 {
		s += " · no DNS"
	}
	return s
}

// UAPI is the device configuration in wireguard-go's IPC format, with
// each endpoint resolved by resolve (host:port in, ip:port out).
func (wg WireGuard) UAPI(resolve func(hostport string) (string, error)) (string, error) {
	var b strings.Builder
	fmt.Fprintf(&b, "private_key=%s\n", hex.EncodeToString(wg.PrivateKey))
	if wg.ListenPort > 0 {
		fmt.Fprintf(&b, "listen_port=%d\n", wg.ListenPort)
	}
	b.WriteString("replace_peers=true\n")
	for _, p := range wg.Peers {
		fmt.Fprintf(&b, "public_key=%s\n", hex.EncodeToString(p.PublicKey))
		if len(p.PresharedKey) > 0 {
			fmt.Fprintf(&b, "preshared_key=%s\n", hex.EncodeToString(p.PresharedKey))
		}
		ep, err := resolve(p.Endpoint)
		if err != nil {
			return "", fmt.Errorf("resolve the peer %s: %w", p.Endpoint, err)
		}
		fmt.Fprintf(&b, "endpoint=%s\n", ep)
		ka := p.Keepalive
		if ka == 0 {
			ka = DefaultKeepalive
		}
		fmt.Fprintf(&b, "persistent_keepalive_interval=%d\n", ka)
		b.WriteString("replace_allowed_ips=true\n")
		for _, a := range p.AllowedIPs {
			fmt.Fprintf(&b, "allowed_ip=%s\n", a)
		}
	}
	return b.String(), nil
}
