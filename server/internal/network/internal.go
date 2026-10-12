package network

import (
	"crypto/subtle"
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/privnet"
)

// Internal serves what the gateway and the egress proxy ask agnts, on the
// internal listener (never routed by Caddy, not reachable from runs). Each
// call carries the gateway secret.
func (s *Service) Internal(mux *http.ServeMux) {
	mux.HandleFunc("GET /gateway/networks", s.guard(s.serveNetworks))
	mux.HandleFunc("POST /gateway/report", s.guard(s.serveReport))
	mux.HandleFunc("GET /egress/route", s.guard(s.serveRoute))
}

func (s *Service) guard(h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tok, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
		if !ok || s.cfg.GatewaySecret == "" || subtle.ConstantTimeCompare([]byte(tok), []byte(s.cfg.GatewaySecret)) != 1 {
			http.Error(w, "not authorized", http.StatusUnauthorized)
			return
		}
		h(w, r)
	}
}

// serveNetworks hands the gateway every network, secrets still sealed.
func (s *Service) serveNetworks(w http.ResponseWriter, r *http.Request) {
	all, err := s.store.All(r.Context())
	if err != nil {
		http.Error(w, "unavailable", http.StatusServiceUnavailable)
		return
	}
	out := make([]privnet.Network, 0, len(all))
	for _, n := range all {
		pn := privnet.Network{ID: n.ID, Workspace: n.Workspace, Name: n.Name, Kind: n.Kind, Enabled: n.Enabled, Routes: n.Routes,
			TokenHash: n.TokenHash, Version: version(n)}
		// A secret still bound to the workspace alone is sealed again
		// within seconds of start (Run); until then the gateway waits.
		if n.SecretV >= 2 {
			pn.Secret = n.SecretEnc
		}
		out = append(out, pn)
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(out) //nolint:gosec // G117: Secret is sealed; only the gateway opens it
}

// serveReport stores the gateway's statuses and connections.
func (s *Service) serveReport(w http.ResponseWriter, r *http.Request) {
	var rep privnet.Report
	if err := json.NewDecoder(io.LimitReader(r.Body, 16<<20)).Decode(&rep); err != nil {
		http.Error(w, "bad report", http.StatusBadRequest)
		return
	}
	s.lastReport.Store(time.Now().Unix())
	ctx := r.Context()
	for _, st := range rep.Statuses {
		// A status of a tunnel that was replaced since is stale.
		if n, ok := s.router.Network(st.Workspace, st.Network); !ok || n.Version != st.Version {
			continue
		}
		if len(st.Error) > 500 {
			st.Error = st.Error[:500]
		}
		if err := s.store.SetStatus(ctx, st); err != nil {
			s.log.Warn("private network status", "workspace", st.Workspace, "network", st.Network, "err", err)
		}
	}
	for i := range rep.Dials {
		if len(rep.Dials[i].Error) > 500 {
			rep.Dials[i].Error = rep.Dials[i].Error[:500]
		}
	}
	if err := s.store.AddDials(ctx, rep.Dials); err != nil {
		s.log.Warn("private network connections", "err", err)
	}
	w.WriteHeader(http.StatusNoContent)
}

// serveRoute answers the egress proxy: does the run container at ip reach
// host:port through one of its workspace's private networks, and which?
func (s *Service) serveRoute(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	port, err := strconv.Atoi(q.Get("port"))
	if err != nil || s.whois == nil {
		http.Error(w, "no", http.StatusNotFound)
		return
	}
	id, ok := s.whois(q.Get("ip"))
	if !ok {
		http.Error(w, "no", http.StatusNotFound)
		return
	}
	n, ok := s.router.Pick(id.Workspace, q.Get("host"), port)
	if !ok {
		http.Error(w, "no", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{"workspace": id.Workspace, "network": n.ID, "ticket": id.Ticket})
}
