// Package privnet is what the parts of a workspace's private network share:
// routes and their checks, the WireGuard and OpenVPN config parsers, the
// gateway's CONNECT protocol, the connector's stream protocol and a small
// SOCKS5 client and server. It has no dependencies inside agnts, so the
// egress proxy, the gateway and agnts-link can all use it.
package privnet

import (
	"errors"
	"fmt"
	"net"
	"net/netip"
	"regexp"
	"slices"
	"strconv"
	"strings"
)

// Kind is how a workspace's tunnel is made.
type Kind string

// The kinds of tunnel.
const (
	KindWireGuard Kind = "wireguard"
	KindOpenVPN   Kind = "openvpn"
	KindConnector Kind = "connector"
)

// Valid reports whether k is a known kind.
func (k Kind) Valid() bool { return k == KindWireGuard || k == KindOpenVPN || k == KindConnector }

// Route is a host, a domain (".corp.local") or a private range that goes
// through the tunnel, on the listed ports (80 and 443 when none are).
type Route struct {
	Host  string `json:"host,omitempty"`
	CIDR  string `json:"cidr,omitempty"`
	Ports []int  `json:"ports,omitempty"`
}

// DefaultPorts are a route's ports when it lists none.
var DefaultPorts = []int{80, 443}

// MaxRoutes is the most routes a workspace may list.
const MaxRoutes = 50

// privateRanges are the only ranges a CIDR route may cover: a route can
// never send a public address, loopback, link-local (cloud metadata) or
// the default route through a tunnel.
var privateRanges = []netip.Prefix{
	netip.MustParsePrefix("10.0.0.0/8"),
	netip.MustParsePrefix("172.16.0.0/12"),
	netip.MustParsePrefix("192.168.0.0/16"),
	netip.MustParsePrefix("100.64.0.0/10"),
	netip.MustParsePrefix("fc00::/7"),
}

// internalTLDs may be used as a one-label domain route (".corp"); any
// other domain route needs two labels, so ".com" can never be routed.
var internalTLDs = map[string]bool{
	"local": true, "lan": true, "internal": true, "corp": true, "home": true, "intranet": true,
	"private": true, "localdomain": true, "intra": true,
}

var labelRe = regexp.MustCompile(`^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$`)

// NormalizeHost lowercases a host name and drops a trailing dot.
func NormalizeHost(h string) string {
	return strings.TrimSuffix(strings.ToLower(strings.TrimSpace(h)), ".")
}

// CleanRoutes checks routes and returns them normalized: lowercase names,
// "*.x" written ".x", canonical prefixes, sorted unique ports. reserved
// are hosts (or ".domains") a route may not cover: the built-in egress
// allowlist and agnts's own domains.
func CleanRoutes(routes []Route, reserved []string) ([]Route, error) {
	if len(routes) > MaxRoutes {
		return nil, fmt.Errorf("at most %d routes", MaxRoutes)
	}
	out := make([]Route, 0, len(routes))
	seen := map[string]bool{}
	for _, r := range routes {
		c, err := cleanRoute(r, reserved)
		if err != nil {
			return nil, err
		}
		key := c.Host + "|" + c.CIDR
		if seen[key] {
			continue
		}
		seen[key] = true
		out = append(out, c)
	}
	return out, nil
}

func cleanRoute(r Route, reserved []string) (Route, error) {
	host, cidr := NormalizeHost(r.Host), strings.TrimSpace(r.CIDR)
	if (host == "") == (cidr == "") {
		return Route{}, errors.New("a route has either a host or a range (CIDR)")
	}
	out := Route{}
	if host != "" {
		// An address typed as a host is a one-address range.
		if a, err := netip.ParseAddr(host); err == nil {
			cidr, host = netip.PrefixFrom(a, a.BitLen()).String(), ""
		}
	}
	if host != "" {
		host = strings.TrimPrefix(host, "*")
		if err := validHost(host); err != nil {
			return Route{}, err
		}
		for _, res := range reserved {
			if covers(host, NormalizeHost(res)) || covers(NormalizeHost(res), host) {
				return Route{}, fmt.Errorf("%s overlaps %s, which agnts reaches directly", r.Host, strings.TrimPrefix(res, "."))
			}
		}
		out.Host = host
	} else {
		p, err := netip.ParsePrefix(cidr)
		if err != nil {
			return Route{}, fmt.Errorf("%q is not a range like 10.20.0.0/16", r.CIDR)
		}
		p = p.Masked()
		if p.Addr().Is4() && p.Bits() < 8 || p.Addr().Is6() && p.Bits() < 7 {
			return Route{}, fmt.Errorf("%s is too wide", p)
		}
		if !isPrivatePrefix(p) {
			return Route{}, fmt.Errorf("%s is not a private range (10/8, 172.16/12, 192.168/16, 100.64/10, fc00::/7)", p)
		}
		out.CIDR = p.String()
	}
	if len(r.Ports) > 10 {
		return Route{}, errors.New("a route lists at most 10 ports")
	}
	for _, p := range r.Ports {
		if p < 1 || p > 65535 {
			return Route{}, fmt.Errorf("port %d is out of range", p)
		}
		if !slices.Contains(out.Ports, p) {
			out.Ports = append(out.Ports, p)
		}
	}
	slices.Sort(out.Ports)
	return out, nil
}

func validHost(h string) error {
	name := strings.TrimPrefix(h, ".")
	if name == "" || len(name) > 253 {
		return fmt.Errorf("%q is not a host name", h)
	}
	labels := strings.Split(name, ".")
	for _, l := range labels {
		if !labelRe.MatchString(l) {
			return fmt.Errorf("%q is not a host name", h)
		}
	}
	if strings.HasPrefix(h, ".") && len(labels) < 2 && !internalTLDs[labels[0]] {
		return fmt.Errorf("%s is too broad: list a domain like .corp.example.com", h)
	}
	if name == "localhost" || strings.HasSuffix(name, ".localhost") {
		return errors.New("localhost cannot be routed")
	}
	return nil
}

// covers reports whether pattern (a host, or ".domain" for its subdomains)
// matches host, or a host under it.
func covers(pattern, host string) bool {
	if pattern == "" || host == "" {
		return false
	}
	p := strings.TrimPrefix(pattern, ".")
	h := strings.TrimPrefix(host, ".")
	if strings.HasPrefix(pattern, ".") {
		return h == p || strings.HasSuffix(h, "."+p)
	}
	return h == p
}

func isPrivatePrefix(p netip.Prefix) bool {
	for _, r := range privateRanges {
		if r.Bits() <= p.Bits() && r.Contains(p.Addr()) {
			return true
		}
	}
	return false
}

// IsPrivateAddr reports whether a is in one of the private ranges.
func IsPrivateAddr(a netip.Addr) bool {
	a = a.Unmap()
	for _, r := range privateRanges {
		if r.Contains(a) {
			return true
		}
	}
	return false
}

// Match reports whether host:port goes through the tunnel. An address
// matches a range; a name matches a host or domain route (names are
// resolved on the tunnel's side, so they never match a range here).
func Match(routes []Route, host string, port int) bool {
	_, ok := best(routes, host, port)
	return ok
}

// Specificity of a matching route: an exact host beats any domain, a
// domain with more labels beats a shorter one, and a longer prefix beats a
// shorter range. Names and addresses never compete.
const (
	scoreHost   = 1000
	scoreDomain = 100
)

// best returns the specificity of the most specific route matching
// host:port.
func best(routes []Route, host string, port int) (int, bool) {
	host = NormalizeHost(strings.Trim(host, "[]"))
	addr, err := netip.ParseAddr(host)
	isAddr := err == nil
	top, found := -1, false
	for _, r := range routes {
		ports := r.Ports
		if len(ports) == 0 {
			ports = DefaultPorts
		}
		if !slices.Contains(ports, port) {
			continue
		}
		score := -1
		switch {
		case isAddr && r.CIDR != "":
			if p, err := netip.ParsePrefix(r.CIDR); err == nil && p.Contains(addr.Unmap()) {
				score = p.Bits()
			}
		case !isAddr && r.Host != "" && covers(r.Host, host):
			if strings.HasPrefix(r.Host, ".") {
				score = scoreDomain + strings.Count(r.Host, ".")
			} else {
				score = scoreHost
			}
		}
		if score > top {
			top, found = score, true
		}
	}
	return top, found
}

// RouteSet is one network's routes, for picking between networks.
type RouteSet struct {
	ID     int64
	Name   string
	Routes []Route
}

// Pick returns the network whose most specific route matches host:port.
// Saved networks never tie (CheckConflicts); if they ever do, the lowest
// id wins so the choice stays the same everywhere.
func Pick(sets []RouteSet, host string, port int) (int64, bool) {
	var id int64
	top := -1
	for _, s := range sets {
		score, ok := best(s.Routes, host, port)
		if !ok {
			continue
		}
		if score > top || score == top && s.ID < id {
			id, top = s.ID, score
		}
	}
	return id, top >= 0
}

// CheckConflicts refuses routes that another of the workspace's networks
// already has: the same host, domain or range on a common port. A route
// nested inside another network's (10.30.0.0/16 under 10.0.0.0/8,
// gitlab.corp.local under .corp.local) is fine: the more specific one wins.
func CheckConflicts(routes []Route, others []RouteSet) error {
	for _, r := range routes {
		for _, o := range others {
			for _, x := range o.Routes {
				if r.Host != x.Host || r.CIDR != x.CIDR || !portsOverlap(r.Ports, x.Ports) {
					continue
				}
				what := strings.TrimSpace(r.Host + r.CIDR)
				return fmt.Errorf("%s is already routed through %q: a target can go through only one network", what, o.Name)
			}
		}
	}
	return nil
}

func portsOverlap(a, b []int) bool {
	if len(a) == 0 {
		a = DefaultPorts
	}
	if len(b) == 0 {
		b = DefaultPorts
	}
	for _, p := range a {
		if slices.Contains(b, p) {
			return true
		}
	}
	return false
}

// SplitHostPort splits "host:port" and parses the port.
func SplitHostPort(addr string) (string, int, error) {
	h, p, err := net.SplitHostPort(addr)
	if err != nil {
		return "", 0, err
	}
	port, err := strconv.Atoi(p)
	if err != nil || port < 1 || port > 65535 {
		return "", 0, fmt.Errorf("bad port in %q", addr)
	}
	return NormalizeHost(h), port, nil
}

// String is a route as people write it: "gitlab.corp.local :443".
func (r Route) String() string {
	s := r.Host
	if s == "" {
		s = r.CIDR
	}
	for _, p := range r.Ports {
		s += " :" + strconv.Itoa(p)
	}
	return s
}
