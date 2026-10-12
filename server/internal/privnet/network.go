package privnet

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"strconv"
	"strings"
	"time"
)

// Network is one of a workspace's private networks as agnts hands it to
// the gateway. Secret is sealed with the server key (Seal with SecretAAD);
// only the gateway opens it.
type Network struct {
	ID        int64   `json:"id"`
	Workspace int64   `json:"workspace"`
	Name      string  `json:"name"`
	Kind      Kind    `json:"kind"`
	Enabled   bool    `json:"enabled"`
	Routes    []Route `json:"routes"`
	Secret    []byte  `json:"secret,omitempty"`
	TokenHash string  `json:"tokenHash,omitempty"` // connector: hex sha256 of its token
	// Version changes whenever the config changes: the gateway restarts
	// the tunnel.
	Version string `json:"version"`
}

// Secret is what a network keeps encrypted: the VPN config and, for
// OpenVPN, the username and password.
type Secret struct {
	Config   string `json:"config"`
	Username string `json:"username,omitempty"`
	Password string `json:"password,omitempty"`
}

// SecretAAD binds a sealed network secret to its network and workspace, so
// it cannot be copied to another network row.
func SecretAAD(ws, id int64) []byte {
	return []byte("privnet:" + strconv.FormatInt(ws, 10) + ":" + strconv.FormatInt(id, 10))
}

// LegacySecretAAD is what secrets were bound to when a workspace had one
// network; agnts seals them again with SecretAAD.
func LegacySecretAAD(ws int64) []byte { return []byte("privnet:" + strconv.FormatInt(ws, 10)) }

// Tunnel states.
const (
	StateConnecting = "connecting"
	StateUp         = "up"
	StateError      = "error"
)

// Status is how a tunnel is doing, as the gateway reports it.
type Status struct {
	Network   int64      `json:"network"`
	Workspace int64      `json:"workspace"`
	Version   string     `json:"version,omitempty"` // the network version the tunnel runs
	State     string     `json:"state"`
	Error     string     `json:"error,omitempty"`
	Since     *time.Time `json:"since,omitempty"`     // up since
	Handshake *time.Time `json:"handshake,omitempty"` // WireGuard's last handshake, or the connector's last heartbeat
	Detail    string     `json:"detail,omitempty"`
}

// Dial is one connection the gateway made (or refused) for a workspace,
// through one of its networks (0: none was picked).
type Dial struct {
	Workspace int64     `json:"workspace"`
	Network   int64     `json:"network,omitempty"`
	Ticket    string    `json:"ticket,omitempty"`
	Source    string    `json:"source"` // run, server or test
	Target    string    `json:"target"`
	OK        bool      `json:"ok"`
	Error     string    `json:"error,omitempty"`
	BytesIn   int64     `json:"bytesIn"`
	BytesOut  int64     `json:"bytesOut"`
	At        time.Time `json:"at"`
}

// Report is what the gateway posts to agnts every few seconds.
type Report struct {
	Statuses []Status `json:"statuses"`
	Dials    []Dial   `json:"dials"`
}

// LinkTokenPrefix starts every connector token.
const LinkTokenPrefix = "lnk_"

// NewLinkToken returns a connector token and its hash.
func NewLinkToken() (token, hash string) {
	b := make([]byte, 32)
	_, _ = rand.Read(b)
	token = LinkTokenPrefix + base64.RawURLEncoding.EncodeToString(b)
	return token, HashToken(token)
}

// HashToken is the hex sha256 kept in place of a connector token.
func HashToken(token string) string {
	sum := sha256.Sum256([]byte(strings.TrimSpace(token)))
	return hex.EncodeToString(sum[:])
}

// SidecarPassword is the SOCKS password of an OpenVPN network's sidecar,
// derived from the gateway secret so agnts (which starts the sidecar) and
// the gateway (which dials through it) agree without storing it.
func SidecarPassword(gatewaySecret string, network int64) string {
	m := hmac.New(sha256.New, []byte(gatewaySecret))
	m.Write([]byte("ovpn-net:" + strconv.FormatInt(network, 10)))
	return hex.EncodeToString(m.Sum(nil))
}

// SidecarName is the container name of an OpenVPN network's sidecar,
// which is also its host name on the sidecar network.
func SidecarName(network int64) string { return "agnts-ovpn-net-" + strconv.FormatInt(network, 10) }
