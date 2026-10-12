package network

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"strconv"
	"strings"

	"agnts/internal/privnet"
	"agnts/internal/runner"
)

// sidecarSpec changes when the sidecar's container settings change, so
// running sidecars are replaced on the next deploy.
const sidecarSpec = "/3"

// Labels of the OpenVPN sidecar containers.
const (
	labelKind      = "agnts"
	labelWorkspace = "agnts.workspace"
	labelNetwork   = "agnts.network"
	labelVersion   = "agnts.version"
)

// sidecarHint explains a failed sidecar create to the workspace owner.
func sidecarHint(err error, image string) string {
	if strings.Contains(err.Error(), "No such image") {
		return "the image " + image + " is not on this server (the operator builds it: docker compose --profile build build ovpn)"
	}
	return err.Error()
}

// syncSidecars runs one OpenVPN sidecar per enabled OpenVPN network, and
// replaces a sidecar whose config changed or that stopped. Sidecars of the
// single-network days (no network label) are replaced too.
func (s *Service) syncSidecars(ctx context.Context) {
	s.sidecarMu.Lock()
	defer s.sidecarMu.Unlock()
	all, err := s.store.All(ctx)
	if err != nil {
		return
	}
	type want struct {
		ws      int64
		env     []string
		version string
	}
	wants := map[int64]want{}
	for _, n := range all {
		if !n.Enabled || n.Kind != privnet.KindOpenVPN || len(n.SecretEnc) == 0 {
			continue
		}
		pt, err := s.box.Open(n.SecretEnc, aad(n))
		if err != nil {
			s.log.Warn("open an OpenVPN config", "network", n.ID, "err", err)
			continue
		}
		sum := sha256.Sum256(append(pt, []byte(s.cfg.OVPNImage+sidecarSpec)...))
		wants[n.ID] = want{
			ws:      n.Workspace,
			env:     []string{"AGNTS_OVPN_SECRET=" + string(pt), "AGNTS_OVPN_SOCKS_PASSWORD=" + privnet.SidecarPassword(s.cfg.GatewaySecret, n.ID)},
			version: hex.EncodeToString(sum[:8]),
		}
	}
	have, err := s.docker.Containers(ctx, labelKind+"=ovpn")
	if err != nil {
		s.log.Warn("list OpenVPN sidecars", "err", err)
		return
	}
	running := map[int64]bool{}
	for _, c := range have {
		id, _ := strconv.ParseInt(c.Labels[labelNetwork], 10, 64)
		w, ok := wants[id]
		if ok && c.Labels[labelVersion] == w.version && c.State == "running" {
			running[id] = true
			continue
		}
		if err := s.docker.Remove(ctx, c.ID); err != nil {
			s.log.Warn("remove an OpenVPN sidecar", "container", c.Name, "err", err)
		} else if ok {
			s.log.Info("OpenVPN sidecar replaced", "network", id, "state", c.State)
		}
	}
	if len(wants) == 0 {
		return
	}
	if err := s.docker.EnsureNetwork(ctx, s.cfg.OVPNNetwork, false); err != nil {
		s.log.Warn("the OpenVPN sidecar network", "err", err)
		return
	}
	for netID, w := range wants {
		if running[netID] {
			continue
		}
		id, err := s.docker.Create(ctx, runner.ContainerConfig{
			Name:    privnet.SidecarName(netID),
			Image:   s.cfg.OVPNImage,
			Network: s.cfg.OVPNNetwork,
			Labels: map[string]string{labelKind: "ovpn", labelWorkspace: strconv.FormatInt(w.ws, 10),
				labelNetwork: strconv.FormatInt(netID, 10), labelVersion: w.version},
			MemoryMB: 128,
			CPUs:     0.5,
			PIDs:     64,
			Tmpfs:    map[string]string{"/tmp": "rw,noexec,nosuid,size=4m"},
			Env:      w.env,
			// OpenVPN makes its tun device and routes in the sidecar's own
			// network namespace; nothing else gets these.
			CapAdd:  []string{"NET_ADMIN"},
			Devices: []string{"/dev/net/tun"},
			// Loose reverse-path filtering: when the VPN pushes a route for
			// its own address (a company serving GitLab on it), the server's
			// replies still arrive on eth0 and must not be dropped as spoofed.
			Sysctls: map[string]string{"net.ipv4.conf.all.rp_filter": "2", "net.ipv4.conf.default.rp_filter": "2"},
		})
		if err != nil {
			s.log.Warn("create an OpenVPN sidecar", "network", netID, "err", err)
			s.sidecarErr.Store(netID, sidecarHint(err, s.cfg.OVPNImage))
			continue
		}
		if err := s.docker.Start(ctx, id); err != nil {
			s.log.Warn("start an OpenVPN sidecar", "network", netID, "err", err)
			s.sidecarErr.Store(netID, err.Error())
			_ = s.docker.Remove(context.WithoutCancel(ctx), id)
			continue
		}
		s.sidecarErr.Delete(netID)
		s.log.Info("OpenVPN sidecar started", "workspace", w.ws, "network", netID)
	}
}
