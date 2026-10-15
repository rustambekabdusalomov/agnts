package httpapi

import (
	"net/http"
	"time"

	"agnts/internal/httpapi/gen"
	"agnts/internal/network"
	"agnts/internal/privnet"
)

func (s *Server) networkReady(w http.ResponseWriter) bool {
	if s.opt.Network == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

func toNetwork(v network.View) gen.PrivateNetwork {
	out := gen.PrivateNetwork{
		Id: v.ID, Name: v.Name, Kind: gen.PrivateNetworkKind(v.Kind), Enabled: v.Enabled, Routes: toRoutes(v.Routes),
		Status: gen.PrivateNetworkStatus(orStatus(v.Status)), TokenSet: v.TokenSet,
		Webhooks: gen.PrivateNetworkWebhooks(v.Webhooks), PollMinutes: v.PollMinutes,
		UpAt: v.UpAt, HandshakeAt: v.HandshakeAt, UpdatedAt: v.UpdatedAt,
	}
	if out.Webhooks == "" {
		out.Webhooks = "polling"
	}
	out.Summary = optString(v.Summary)
	out.LastError = optString(v.LastError)
	out.Detail = optString(v.Detail)
	if v.CA != nil {
		out.Ca = &struct {
			NotAfter time.Time `json:"notAfter"`
			Subjects []string  `json:"subjects"`
		}{NotAfter: v.CA.NotAfter, Subjects: v.CA.Subjects}
	}
	return out
}

func orStatus(s string) string {
	if s == "" {
		return "disabled"
	}
	return s
}

func optString(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func toRoutes(rs []privnet.Route) []gen.NetworkRoute {
	out := make([]gen.NetworkRoute, 0, len(rs))
	for _, r := range rs {
		g := gen.NetworkRoute{Host: optString(r.Host), Cidr: optString(r.CIDR)}
		if len(r.Ports) > 0 {
			ports := append([]int{}, r.Ports...)
			g.Ports = &ports
		}
		out = append(out, g)
	}
	return out
}

func fromRoutes(rs []gen.NetworkRoute) []privnet.Route {
	out := make([]privnet.Route, 0, len(rs))
	for _, r := range rs {
		x := privnet.Route{}
		if r.Host != nil {
			x.Host = *r.Host
		}
		if r.Cidr != nil {
			x.CIDR = *r.Cidr
		}
		if r.Ports != nil {
			x.Ports = *r.Ports
		}
		out = append(out, x)
	}
	return out
}

// ListPrivateNetworks implements gen.ServerInterface.
func (s *Server) ListPrivateNetworks(w http.ResponseWriter, r *http.Request) {
	if !s.networkReady(w) {
		return
	}
	o, err := s.opt.Network.List(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.PrivateNetworkList{Available: o.Available, LinkUrl: o.LinkURL, Max: o.Max, Networks: make([]gen.PrivateNetwork, 0, len(o.Networks))}
	for _, v := range o.Networks {
		out.Networks = append(out.Networks, toNetwork(v))
	}
	writeJSON(w, http.StatusOK, out)
}

// GetPrivateNetwork implements gen.ServerInterface.
func (s *Server) GetPrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	if !s.networkReady(w) {
		return
	}
	v, err := s.opt.Network.Get(r.Context(), id)
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toNetwork(v))
}

func networkInput(req gen.PrivateNetworkInput) network.Input {
	return network.Input{
		Name: req.Name, Kind: privnet.Kind(req.Kind), Enabled: req.Enabled, Config: req.Config, Username: req.Username,
		Password: req.Password, Routes: fromRoutes(req.Routes), CAPEM: req.CaPem,
	}
}

func toSaved(saved network.Saved) gen.PrivateNetworkSaved {
	return gen.PrivateNetworkSaved{Network: toNetwork(saved.View), Token: optString(saved.Token)}
}

// CreatePrivateNetwork implements gen.ServerInterface.
func (s *Server) CreatePrivateNetwork(w http.ResponseWriter, r *http.Request) {
	if !s.networkReady(w) {
		return
	}
	var req gen.PrivateNetworkInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	saved, err := s.opt.Network.Create(r.Context(), networkInput(req), origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusCreated, toSaved(saved))
}

// UpdatePrivateNetwork implements gen.ServerInterface.
func (s *Server) UpdatePrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	if !s.networkReady(w) {
		return
	}
	var req gen.PrivateNetworkInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	saved, err := s.opt.Network.Update(r.Context(), id, networkInput(req), origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toSaved(saved))
}

// DeletePrivateNetwork implements gen.ServerInterface.
func (s *Server) DeletePrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	if !s.networkReady(w) {
		return
	}
	if err := s.opt.Network.Delete(r.Context(), id, origin(r)); err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ReconnectPrivateNetwork implements gen.ServerInterface.
func (s *Server) ReconnectPrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	if !s.networkReady(w) {
		return
	}
	v, err := s.opt.Network.Reconnect(r.Context(), id, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toNetwork(v))
}

// DisconnectPrivateNetwork implements gen.ServerInterface.
func (s *Server) DisconnectPrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	s.setNetworkConnected(w, r, id, false)
}

// ConnectPrivateNetwork implements gen.ServerInterface.
func (s *Server) ConnectPrivateNetwork(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	s.setNetworkConnected(w, r, id, true)
}

func (s *Server) setNetworkConnected(w http.ResponseWriter, r *http.Request, id gen.NetworkID, on bool) {
	if !s.networkReady(w) {
		return
	}
	v, err := s.opt.Network.SetConnected(r.Context(), id, on, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toNetwork(v))
}

// RotateLinkToken implements gen.ServerInterface.
func (s *Server) RotateLinkToken(w http.ResponseWriter, r *http.Request, id gen.NetworkID) {
	if !s.networkReady(w) {
		return
	}
	tok, err := s.opt.Network.RotateToken(r.Context(), id, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"token": tok})
}

// TestPrivateNetwork implements gen.ServerInterface.
func (s *Server) TestPrivateNetwork(w http.ResponseWriter, r *http.Request) {
	if !s.networkReady(w) {
		return
	}
	var req gen.TestPrivateNetworkJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var want int64
	if req.Network != nil {
		want = *req.Network
	}
	res, err := s.opt.Network.Test(r.Context(), req.Target, want)
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	out := gen.NetworkTest{Ok: res.OK, Via: optString(res.Via), Resolved: optString(res.Resolved), Error: optString(res.Error)}
	if res.NetworkID != 0 {
		out.Network = &struct {
			Id   int64  `json:"id"`
			Name string `json:"name"`
		}{Id: res.NetworkID, Name: res.NetworkName}
	}
	if res.ConnectMS > 0 {
		out.ConnectMs = &res.ConnectMS
	}
	if t := res.TLS; t != nil {
		out.Tls = &struct {
			Error    *string    `json:"error,omitempty"`
			Issuer   *string    `json:"issuer,omitempty"`
			NotAfter *time.Time `json:"notAfter,omitempty"`
			Subject  *string    `json:"subject,omitempty"`
			Verified bool       `json:"verified"`
		}{Error: optString(t.Error), Issuer: optString(t.Issuer), Subject: optString(t.Subject), Verified: t.Verified}
		if !t.NotAfter.IsZero() {
			na := t.NotAfter
			out.Tls.NotAfter = &na
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// GetNetworkActivity implements gen.ServerInterface.
func (s *Server) GetNetworkActivity(w http.ResponseWriter, r *http.Request, params gen.GetNetworkActivityParams) {
	if !s.networkReady(w) {
		return
	}
	var only int64
	if params.Network != nil {
		only = *params.Network
	}
	a, err := s.opt.Network.Activity(r.Context(), only)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.NetworkActivity{Today: a.Today, Refused: a.Refused}
	out.Dials = make([]struct {
		At       time.Time `json:"at"`
		BytesIn  int64     `json:"bytesIn"`
		BytesOut int64     `json:"bytesOut"`
		Error    *string   `json:"error,omitempty"`
		Network  *int64    `json:"network,omitempty"`
		Ok       bool      `json:"ok"`
		Source   string    `json:"source"`
		Target   string    `json:"target"`
		Ticket   *string   `json:"ticket,omitempty"`
	}, len(a.Dials))
	for i, d := range a.Dials {
		x := &out.Dials[i]
		x.At, x.BytesIn, x.BytesOut, x.Ok, x.Source, x.Target = d.At, d.BytesIn, d.BytesOut, d.OK, d.Source, d.Target
		x.Error, x.Ticket = optString(d.Error), optString(d.Ticket)
		if d.Network != 0 {
			n := d.Network
			x.Network = &n
		}
	}
	writeJSON(w, http.StatusOK, out)
}
