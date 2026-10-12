// Package network runs workspaces' private networks on the agnts side. A
// workspace may keep several, each with its own tunnel and routes; a
// connection goes through the one whose route matches it most closely. The
// service checks and saves them (refusing routes two networks would
// share), feeds them to the gateway and the server's router, answers the
// egress proxy's "which network does this run reach this host through?",
// starts the OpenVPN sidecars, and tests a connection for the settings
// page.
package network

import (
	"bytes"
	"context"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"agnts/internal/domain"
	"agnts/internal/netroute"
	"agnts/internal/orchestrator"
	"agnts/internal/privnet"
	"agnts/internal/runner"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
)

// ErrInvalid wraps input errors to show to the user.
var ErrInvalid = orchestrator.ErrInvalid

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// ErrOff is returned when the server has no gateway.
var ErrOff = errors.New("private networks are not set up on this server (AGNTS_GATEWAY)")

// Config configures the service.
type Config struct {
	// Gateway is the gateway's CONNECT address (gateway:3129); empty turns
	// private networks off.
	Gateway, GatewaySecret string
	// LinkURL is where agnts-link connects (https://api.example.com/link).
	LinkURL string
	// Reserved are hosts no route may cover (the egress allowlist, agnts's
	// own domains).
	Reserved []string
	// OpenVPN sidecars: their image and the network they share with the
	// gateway.
	OVPNImage, OVPNNetwork string
	// Polled is how often trackers reached through a VPN (no webhooks) are
	// read.
	Polled time.Duration
	// MaxNetworks is how many networks a workspace may keep (0: 5).
	MaxNetworks int
	// MaxOVPN is how many OpenVPN networks the server runs a sidecar for,
	// across workspaces (0: 50).
	MaxOVPN int
}

// Events records workspace changes.
type Events interface {
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Service is the agnts side of private networks.
type Service struct {
	cfg    Config
	store  *postgres.PrivateNetworks
	box    *secret.Box
	router *netroute.Router
	events Events
	log    *slog.Logger
	docker *runner.Docker // nil: no sidecars (API-only server)
	whois  func(ip string) (runner.Identity, bool)

	lastReport atomic.Int64 // unix seconds of the gateway's last report
	sidecarMu  sync.Mutex
	// sidecarErr is why an OpenVPN network's sidecar could not start.
	sidecarErr sync.Map // network id -> string
	resealOnce sync.Once
}

// New returns the service; router gets every enabled network.
func New(cfg Config, store *postgres.PrivateNetworks, box *secret.Box, router *netroute.Router, events Events, log *slog.Logger) *Service {
	if cfg.MaxNetworks <= 0 {
		cfg.MaxNetworks = 5
	}
	if cfg.MaxOVPN <= 0 {
		cfg.MaxOVPN = 50
	}
	return &Service{cfg: cfg, store: store, box: box, router: router, events: events, log: log}
}

// SetRuns lets the service start sidecars and identify run containers.
func (s *Service) SetRuns(d *runner.Docker, whois func(ip string) (runner.Identity, bool)) {
	s.docker, s.whois = d, whois
}

// Enabled reports whether the server has a gateway.
func (s *Service) Enabled() bool { return s.cfg.Gateway != "" }

// View is one private network as the settings page shows it.
type View struct {
	ID          int64
	Name        string
	Kind        privnet.Kind
	Enabled     bool
	Summary     string
	Routes      []privnet.Route
	CA          *CAInfo
	Status      string // connecting, up, error, disabled, gateway_down
	LastError   string
	UpAt        *time.Time
	HandshakeAt *time.Time
	Detail      string
	TokenSet    bool
	Webhooks    string // relay (connector) or polling
	PollMinutes int
	UpdatedAt   time.Time
}

// Overview is the workspace's private networks and what the server offers.
type Overview struct {
	Available bool // the server has a gateway
	LinkURL   string
	Max       int
	Networks  []View
}

// CAInfo describes the CA bundle.
type CAInfo struct {
	Subjects []string
	NotAfter time.Time
}

// Input is a save from the settings page. Nil fields keep what is stored.
type Input struct {
	Name     string
	Kind     privnet.Kind
	Enabled  bool
	Config   *string
	Username *string
	Password *string
	Routes   []privnet.Route
	CAPEM    *string
}

// Saved is the result of a save: the view, and a connector token when
// one was made (shown once).
type Saved struct {
	View  View
	Token string
}

func version(n postgres.PrivateNetwork) string { return strconv.FormatInt(n.UpdatedAt.UnixMicro(), 10) }

// List returns the workspace's private networks.
func (s *Service) List(ctx context.Context) (Overview, error) {
	all, err := s.store.List(ctx)
	if err != nil {
		return Overview{}, err
	}
	o := Overview{Available: s.Enabled(), LinkURL: s.cfg.LinkURL, Max: s.cfg.MaxNetworks, Networks: make([]View, 0, len(all))}
	for _, n := range all {
		o.Networks = append(o.Networks, s.view(n))
	}
	return o, nil
}

// Get returns one of the workspace's networks.
func (s *Service) Get(ctx context.Context, id int64) (View, error) {
	n, err := s.store.Get(ctx, id)
	if err != nil {
		return View{}, err
	}
	return s.view(n), nil
}

func (s *Service) view(n postgres.PrivateNetwork) View {
	v := View{ID: n.ID, Name: n.Name, Kind: n.Kind, Enabled: n.Enabled, Summary: n.Summary, Routes: n.Routes,
		Status: n.Status, LastError: n.LastError, UpAt: n.UpAt, HandshakeAt: n.HandshakeAt, Detail: n.Detail,
		TokenSet: n.TokenHash != "", Webhooks: "polling", PollMinutes: int(s.cfg.Polled.Minutes()), UpdatedAt: n.UpdatedAt}
	if v.Routes == nil {
		v.Routes = []privnet.Route{}
	}
	if n.Kind == privnet.KindConnector {
		v.Webhooks = "relay"
	}
	if n.CAPEM != "" {
		v.CA = caInfo(n.CAPEM)
	}
	if n.Kind == privnet.KindOpenVPN && n.Status != privnet.StateUp {
		if e, ok := s.sidecarErr.Load(n.ID); ok {
			v.Status, v.LastError = privnet.StateError, "the OpenVPN sidecar could not start: "+e.(string)
		}
	}
	last := s.lastReport.Load()
	switch {
	case !n.Enabled:
		v.Status = "disabled"
	case !s.Enabled():
		v.Status, v.LastError = "gateway_down", ErrOff.Error()
	case last == 0 || time.Since(time.Unix(last, 0)) > time.Minute:
		v.Status, v.LastError = "gateway_down", "the gateway service has not reported for a while: is the gateway container running?"
	}
	return v
}

func caInfo(p string) *CAInfo {
	certs, err := parseCerts(p)
	if err != nil || len(certs) == 0 {
		return nil
	}
	info := &CAInfo{NotAfter: certs[0].NotAfter}
	for _, c := range certs {
		info.Subjects = append(info.Subjects, c.Subject.CommonName)
		if c.NotAfter.Before(info.NotAfter) {
			info.NotAfter = c.NotAfter
		}
	}
	return info
}

func parseCerts(p string) ([]*x509.Certificate, error) {
	var out []*x509.Certificate
	rest := []byte(strings.TrimSpace(p))
	for len(rest) > 0 {
		var b *pem.Block
		b, rest = pem.Decode(rest)
		if b == nil {
			break
		}
		if b.Type != "CERTIFICATE" {
			return nil, errors.New("the CA bundle may only hold certificates")
		}
		c, err := x509.ParseCertificate(b.Bytes)
		if err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	if len(out) == 0 {
		return nil, errors.New("the CA bundle has no PEM certificate (-----BEGIN CERTIFICATE-----)")
	}
	return out, nil
}

// aad is what n's sealed secret is bound to.
func aad(n postgres.PrivateNetwork) []byte {
	if n.SecretV < 2 {
		return privnet.LegacySecretAAD(n.Workspace)
	}
	return privnet.SecretAAD(n.Workspace, n.ID)
}

// openSecret opens n's sealed secret (empty when it has none).
func (s *Service) openSecret(n postgres.PrivateNetwork) (privnet.Secret, error) {
	var sec privnet.Secret
	if len(n.SecretEnc) == 0 {
		return sec, nil
	}
	pt, err := s.box.Open(n.SecretEnc, aad(n))
	if err != nil {
		return sec, err
	}
	return sec, json.Unmarshal(pt, &sec)
}

func sets(nets []postgres.PrivateNetwork) []privnet.RouteSet {
	out := make([]privnet.RouteSet, 0, len(nets))
	for _, n := range nets {
		out = append(out, privnet.RouteSet{ID: n.ID, Name: n.Name, Routes: n.Routes})
	}
	return out
}

// Create adds a private network to the workspace.
func (s *Service) Create(ctx context.Context, in Input, origin domain.Origin) (Saved, error) {
	return s.save(ctx, 0, in, origin)
}

// Update changes one of the workspace's networks.
func (s *Service) Update(ctx context.Context, id int64, in Input, origin domain.Origin) (Saved, error) {
	if id <= 0 {
		return Saved{}, domain.ErrNotFound
	}
	return s.save(ctx, id, in, origin)
}

// save checks and stores a network (id 0 creates one). Its routes may not
// claim a target another of the workspace's networks has.
func (s *Service) save(ctx context.Context, id int64, in Input, origin domain.Origin) (Saved, error) {
	if !s.Enabled() {
		return Saved{}, invalid("%s", ErrOff.Error())
	}
	if !in.Kind.Valid() {
		return Saved{}, invalid("kind must be wireguard, openvpn or connector")
	}
	name := strings.Join(strings.Fields(in.Name), " ")
	if name == "" {
		return Saved{}, invalid("give the network a name, like the company or office it reaches")
	}
	if len([]rune(name)) > 60 {
		return Saved{}, invalid("the name is longer than 60 characters")
	}
	routes, err := privnet.CleanRoutes(in.Routes, s.cfg.Reserved)
	if err != nil {
		return Saved{}, invalid("%s", err.Error())
	}
	if len(routes) == 0 {
		return Saved{}, invalid("list at least one route: the hosts or ranges that go through this network")
	}
	caPEM := ""
	if in.CAPEM != nil {
		caPEM = strings.TrimSpace(*in.CAPEM)
		if caPEM != "" {
			if _, err := parseCerts(caPEM); err != nil {
				return Saved{}, invalid("CA bundle: %s", err.Error())
			}
		}
	}
	// The server-wide cap on OpenVPN sidecars (each is a container).
	if in.Kind == privnet.KindOpenVPN && in.Enabled {
		if all, err := s.store.All(ctx); err == nil {
			running := 0
			for _, n := range all {
				if n.ID != id && n.Enabled && n.Kind == privnet.KindOpenVPN {
					running++
				}
			}
			if running >= s.cfg.MaxOVPN {
				return Saved{}, invalid("this server already runs %d OpenVPN networks, its limit: use WireGuard or agnts-link", s.cfg.MaxOVPN)
			}
		}
	}
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return Saved{}, err
	}
	token := ""
	saved, err := s.store.Save(ctx, id, func(id int64, cur *postgres.PrivateNetwork, others []postgres.PrivateNetwork) (postgres.PrivateNetwork, error) {
		if cur == nil && len(others) >= s.cfg.MaxNetworks {
			return postgres.PrivateNetwork{}, invalid("a workspace keeps at most %d private networks", s.cfg.MaxNetworks)
		}
		for _, o := range others {
			if strings.EqualFold(o.Name, name) {
				return postgres.PrivateNetwork{}, invalid("another network is already named %q", o.Name)
			}
		}
		// Disabled networks count too: turning one back on must not make
		// a target ambiguous.
		if err := privnet.CheckConflicts(routes, sets(others)); err != nil {
			return postgres.PrivateNetwork{}, invalid("%s", err.Error())
		}
		n := postgres.PrivateNetwork{ID: id, Workspace: ws, Name: name, Kind: in.Kind, Enabled: in.Enabled, Routes: routes}
		if cur != nil {
			n.CAPEM, n.TokenHash = cur.CAPEM, cur.TokenHash
		}
		if in.CAPEM != nil {
			n.CAPEM = caPEM
		}
		// The secret: a new config, or the stored one (only for the same kind).
		sameKind := cur != nil && cur.Kind == in.Kind
		var old privnet.Secret
		if sameKind {
			old, _ = s.openSecret(*cur)
		}
		sec, changed := old, false
		if in.Config != nil && strings.TrimSpace(*in.Config) != "" {
			sec.Config, changed = strings.TrimSpace(*in.Config)+"\n", true
		}
		if in.Username != nil {
			sec.Username, changed = strings.TrimSpace(*in.Username), true
		}
		if in.Password != nil && *in.Password != "" {
			sec.Password, changed = *in.Password, true
		}
		switch in.Kind {
		case privnet.KindWireGuard:
			if sec.Config == "" {
				return n, invalid("paste the WireGuard config ([Interface] and [Peer])")
			}
			wg, err := privnet.ParseWireGuard(sec.Config)
			if err != nil {
				return n, invalid("WireGuard config: %s", err.Error())
			}
			n.Summary = wg.Summary()
			sec.Username, sec.Password = "", ""
			n.TokenHash = ""
		case privnet.KindOpenVPN:
			if sec.Config == "" {
				return n, invalid("paste the OpenVPN config (.ovpn)")
			}
			o, err := privnet.ParseOpenVPN(sec.Config)
			if err != nil {
				return n, invalid("OpenVPN config: %s", err.Error())
			}
			if o.NeedsAuth && (sec.Username == "" || sec.Password == "") {
				return n, invalid("this config asks for a username and password (auth-user-pass): enter both")
			}
			n.Summary = o.Summary()
			n.TokenHash = ""
		case privnet.KindConnector:
			sec, changed = privnet.Secret{}, false
			n.Summary = "agnts-link"
			if !sameKind || n.TokenHash == "" {
				token, n.TokenHash = privnet.NewLinkToken()
			}
		}
		switch {
		case in.Kind == privnet.KindConnector:
			n.SecretEnc = []byte{} // drop a VPN config left from another kind
		case changed || !sameKind || cur.SecretV < 2:
			b, _ := json.Marshal(sec) //nolint:gosec // G117: sealed on the next line
			sealed, err := s.box.Seal(b, privnet.SecretAAD(ws, id))
			if err != nil {
				return n, err
			}
			n.SecretEnc = sealed
		}
		return n, nil
	})
	if err != nil {
		return Saved{}, err
	}
	verb := "saved"
	if id == 0 {
		verb = "added"
	}
	s.event(ctx, origin, fmt.Sprintf("private network %q %s (%s, %d routes, %s)", saved.Name, verb, in.Kind, len(routes),
		map[bool]string{true: "on", false: "off"}[in.Enabled]))
	s.changed(ctx)
	return Saved{View: s.view(saved), Token: token}, nil
}

// Reconnect restarts a network's tunnel: the gateway opens it again
// (WireGuard makes a new handshake, agnts-link reconnects) and an OpenVPN
// sidecar is replaced.
func (s *Service) Reconnect(ctx context.Context, id int64, origin domain.Origin) (View, error) {
	cur, err := s.store.Get(ctx, id)
	if err != nil {
		return View{}, err
	}
	if !cur.Enabled {
		return View{}, invalid("%s is turned off", cur.Name)
	}
	n, err := s.store.Restart(ctx, id)
	if err != nil {
		return View{}, err
	}
	s.sidecarErr.Delete(n.ID)
	if n.Kind == privnet.KindOpenVPN && s.docker != nil {
		if err := s.docker.Remove(ctx, privnet.SidecarName(n.ID)); err != nil {
			s.log.Warn("remove an OpenVPN sidecar to reconnect", "network", n.ID, "err", err)
		}
	}
	s.event(ctx, origin, fmt.Sprintf("private network %q reconnected", n.Name))
	s.changed(ctx)
	return s.view(n), nil
}

// Delete removes one of the workspace's networks.
func (s *Service) Delete(ctx context.Context, id int64, origin domain.Origin) error {
	cur, err := s.store.Get(ctx, id)
	if err != nil {
		return err
	}
	if err := s.store.Delete(ctx, id); err != nil {
		return err
	}
	s.sidecarErr.Delete(id)
	s.event(ctx, origin, fmt.Sprintf("private network %q removed", cur.Name))
	s.changed(ctx)
	return nil
}

// RotateToken makes a new token for a connector network; the old one
// stops working.
func (s *Service) RotateToken(ctx context.Context, id int64, origin domain.Origin) (string, error) {
	n, err := s.store.Get(ctx, id)
	if err != nil {
		return "", err
	}
	if n.Kind != privnet.KindConnector {
		return "", invalid("%s is not an agnts-link network", n.Name)
	}
	tok, hash := privnet.NewLinkToken()
	if err := s.store.SetToken(ctx, id, hash); err != nil {
		return "", err
	}
	s.event(ctx, origin, fmt.Sprintf("agnts-link token of %q replaced", n.Name))
	s.Refresh(ctx)
	return tok, nil
}

func (s *Service) event(ctx context.Context, origin domain.Origin, msg string) {
	if s.events == nil {
		return
	}
	if err := s.events.AppendEvent(ctx, domain.Event{Type: domain.EventIntegration, Origin: origin, Message: msg}); err != nil {
		s.log.Warn("private network event", "err", err)
	}
}

// changed applies a saved network now: the router, and the sidecars in
// the background (Run would within 30 seconds).
func (s *Service) changed(ctx context.Context) {
	s.Refresh(ctx)
	if s.docker != nil {
		go s.syncSidecars(domain.System(context.WithoutCancel(ctx)))
	}
}

// Refresh loads every enabled network into the router.
func (s *Service) Refresh(ctx context.Context) {
	all, err := s.store.All(ctx)
	if err != nil {
		if ctx.Err() == nil {
			s.log.Warn("load private networks", "err", err)
		}
		return
	}
	nets := map[int64][]netroute.Network{}
	for _, n := range all {
		if !n.Enabled {
			continue
		}
		rn := netroute.Network{ID: n.ID, Name: n.Name, Kind: n.Kind, Routes: n.Routes, Version: version(n)}
		if n.CAPEM != "" {
			if pool, err := x509.SystemCertPool(); err == nil && pool.AppendCertsFromPEM([]byte(n.CAPEM)) {
				rn.CA = pool
			}
		}
		nets[n.Workspace] = append(nets[n.Workspace], rn)
	}
	s.router.Set(nets)
}

// reseal binds secrets sealed when a workspace had a single network to
// their network (secret_v 1 to 2). The tunnel keeps running: its version
// does not change.
func (s *Service) reseal(ctx context.Context) {
	all, err := s.store.All(ctx)
	if err != nil {
		return
	}
	for _, n := range all {
		if n.SecretV >= 2 || len(n.SecretEnc) == 0 {
			continue
		}
		pt, err := s.box.Open(n.SecretEnc, privnet.LegacySecretAAD(n.Workspace))
		if err != nil {
			s.log.Warn("open a private network secret to seal it again", "network", n.ID, "err", err)
			continue
		}
		sealed, err := s.box.Seal(pt, privnet.SecretAAD(n.Workspace, n.ID))
		if err == nil {
			err = s.store.Reseal(ctx, n.ID, sealed)
		}
		if err != nil {
			s.log.Warn("seal a private network secret again", "network", n.ID, "err", err)
		}
	}
}

// CA is the CA bundles of the workspace ctx acts in, every enabled
// network's once each, for its runs.
func (s *Service) CA(ctx context.Context) []byte {
	ws := domain.WorkspaceOf(ctx)
	if ws <= 0 || len(s.router.Networks(ws)) == 0 {
		return nil
	}
	list, err := s.store.List(domain.WithWorkspace(ctx, ws))
	if err != nil {
		return nil
	}
	var out bytes.Buffer
	seen := map[[32]byte]bool{}
	for _, n := range list {
		if !n.Enabled || n.CAPEM == "" {
			continue
		}
		certs, err := parseCerts(n.CAPEM)
		if err != nil {
			continue
		}
		for _, c := range certs {
			sum := sha256.Sum256(c.Raw)
			if seen[sum] {
				continue
			}
			seen[sum] = true
			_ = pem.Encode(&out, &pem.Block{Type: "CERTIFICATE", Bytes: c.Raw})
		}
	}
	return out.Bytes()
}

// PolledBy returns, for a tracker's reconcile loop, a function that calls
// fn in each workspace whose tracker (at the URL trackerURL returns) is
// reached through a VPN network: no webhooks reach agnts from it, so it is
// read more often. agnts-link relays webhooks, so its networks are skipped.
func (s *Service) PolledBy(trackerURL func(ctx context.Context) string) func(context.Context, func(context.Context)) {
	return func(ctx context.Context, fn func(context.Context)) {
		all, err := s.store.All(ctx)
		if err != nil {
			return
		}
		seen := map[int64]bool{}
		for _, n := range all {
			if seen[n.Workspace] || !n.Enabled || n.Kind == privnet.KindConnector || ctx.Err() != nil {
				continue
			}
			seen[n.Workspace] = true
			wctx := domain.WithWorkspace(ctx, n.Workspace)
			u, err := url.Parse(trackerURL(wctx))
			if err != nil || u.Hostname() == "" {
				continue
			}
			port := 443
			if u.Scheme == "http" {
				port = 80
			}
			if p, err := strconv.Atoi(u.Port()); err == nil {
				port = p
			}
			if via, ok := s.router.Pick(n.Workspace, u.Hostname(), port); ok && via.Kind != privnet.KindConnector {
				fn(wctx)
			}
		}
	}
}

// Run refreshes the router, keeps the OpenVPN sidecars in step and drops
// old connection records until ctx ends.
func (s *Service) Run(ctx context.Context) {
	t := time.NewTicker(30 * time.Second)
	defer t.Stop()
	lastPrune := time.Time{}
	for {
		s.resealOnce.Do(func() { s.reseal(ctx) })
		s.Refresh(ctx)
		if s.docker != nil {
			s.syncSidecars(ctx)
		}
		if time.Since(lastPrune) > time.Hour {
			lastPrune = time.Now()
			if err := s.store.PruneDials(ctx, time.Now().Add(-30*24*time.Hour)); err != nil && ctx.Err() == nil {
				s.log.Warn("prune private network connections", "err", err)
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

// Activity is the workspace's recent connections.
type Activity struct {
	Today, Refused int
	Dials          []privnet.Dial
}

// Activity returns the last day's counts and the latest connections, of
// one network or (0) all of them.
func (s *Service) Activity(ctx context.Context, network int64) (Activity, error) {
	total, refused, err := s.store.DialStats(ctx, network, time.Now().Add(-24*time.Hour))
	if err != nil {
		return Activity{}, err
	}
	dials, err := s.store.Dials(ctx, network, 100)
	return Activity{Today: total, Refused: refused, Dials: dials}, err
}

// TestResult is what a test connection found.
type TestResult struct {
	OK          bool
	Via         string
	NetworkID   int64
	NetworkName string
	Resolved    string
	ConnectMS   int64
	TLS         *TLSResult
	Error       string
}

// TLSResult is the TLS handshake of a test.
type TLSResult struct {
	Verified bool
	Subject  string
	Issuer   string
	NotAfter time.Time
	Error    string
}

// Test connects to target (host:port) through the network the workspace's
// routes pick for it and, unless the port is 80, checks its TLS
// certificate against the system roots and that network's CA bundle. With
// a network id, it also says when the target would go through another
// network instead.
func (s *Service) Test(ctx context.Context, target string, network int64) (TestResult, error) {
	if !s.Enabled() {
		return TestResult{}, invalid("%s", ErrOff.Error())
	}
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return TestResult{}, err
	}
	target = strings.TrimSpace(target)
	if !strings.Contains(target, ":") || strings.HasSuffix(target, "]") {
		target = net.JoinHostPort(strings.Trim(target, "[]"), "443")
	}
	host, port, err := privnet.SplitHostPort(target)
	if err != nil {
		return TestResult{}, invalid("enter host:port, like gitlab.corp.local:443")
	}
	if len(s.router.Networks(ws)) == 0 {
		return TestResult{}, invalid("add a private network and turn it on first")
	}
	var want netroute.Network
	if network != 0 {
		var ok bool
		if want, ok = s.router.Network(ws, network); !ok {
			return TestResult{}, invalid("that network is turned off or gone")
		}
	}
	via, ok := s.router.Pick(ws, host, port)
	switch {
	case !ok && network != 0:
		return TestResult{NetworkID: want.ID, NetworkName: want.Name,
			Error: target + " is not on the routes of " + want.Name + ": add it there"}, nil
	case !ok:
		return TestResult{Error: target + " is not on the routes of any network, so agnts would not send it through one"}, nil
	case network != 0 && via.ID != network:
		return TestResult{NetworkID: via.ID, NetworkName: via.Name,
			Error: target + " goes through " + via.Name + ", whose route is more specific than " + want.Name + "'s"}, nil
	}
	c, cancel := context.WithTimeout(ctx, 25*time.Second)
	defer cancel()
	start := time.Now()
	conn, info, err := s.router.Dial(c, ws, via.ID, target, "test")
	res := TestResult{Via: string(info.Via), NetworkID: via.ID, NetworkName: via.Name, Resolved: info.Resolved,
		ConnectMS: time.Since(start).Milliseconds()}
	if err != nil {
		res.Error = err.Error()
		return res, nil
	}
	defer func() { _ = conn.Close() }()
	res.OK = true
	if port == 80 {
		return res, nil
	}
	res.TLS = s.checkTLS(c, conn, ws, via.ID, host)
	return res, nil
}

func (s *Service) checkTLS(ctx context.Context, conn net.Conn, ws, network int64, host string) *TLSResult {
	cfg := s.router.TLSConfig(ws, network, host)
	roots := cfg.RootCAs
	if net.ParseIP(host) != nil {
		cfg.ServerName = ""
	}
	out := &TLSResult{}
	// Verify by hand so a failed check still shows the certificate.
	cfg.InsecureSkipVerify = true //nolint:gosec // G402: verified below, against the same roots
	cfg.VerifyConnection = func(cs tls.ConnectionState) error {
		if len(cs.PeerCertificates) == 0 {
			return errors.New("no certificate")
		}
		leaf := cs.PeerCertificates[0]
		out.Subject, out.Issuer, out.NotAfter = leaf.Subject.CommonName, leaf.Issuer.CommonName, leaf.NotAfter
		inter := x509.NewCertPool()
		for _, c := range cs.PeerCertificates[1:] {
			inter.AddCert(c)
		}
		_, err := leaf.Verify(x509.VerifyOptions{Roots: roots, Intermediates: inter, DNSName: host})
		if err != nil {
			out.Error = err.Error()
			if errors.As(err, new(x509.UnknownAuthorityError)) {
				out.Error += " (add the company CA bundle below)"
			}
		} else {
			out.Verified = true
		}
		return nil
	}
	tc := tls.Client(conn, cfg)
	if err := tc.HandshakeContext(ctx); err != nil && out.Subject == "" {
		if errors.As(err, new(tls.RecordHeaderError)) {
			return nil // a plain HTTP (or other non-TLS) port: nothing to check
		}
		out.Error = "TLS handshake: " + err.Error()
	}
	return out
}
