package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"agnts/internal/egress"
	"agnts/internal/httpapi/gen"
)

// GetPlatformEgress implements gen.ServerInterface: the egress proxy's
// upstream, as egress itself checks it.
func (s *Server) GetPlatformEgress(w http.ResponseWriter, r *http.Request) {
	out := gen.EgressStatus{}
	st, err := s.egressStatus(r.Context())
	if err != nil {
		msg := err.Error()
		out.Error = &msg
		writeJSON(w, http.StatusOK, out)
		return
	}
	out.Reachable = true
	var up gen.EgressUpstream
	b, _ := json.Marshal(st)
	_ = json.Unmarshal(b, &up)
	if up.History == nil {
		up.History = []struct {
			At time.Time `json:"at"`
			Ms int64     `json:"ms"`
			Ok bool      `json:"ok"`
		}{}
	}
	out.Upstream = &up
	writeJSON(w, http.StatusOK, out)
}

// egressStatus reads egress's status page on the internal network.
func (s *Server) egressStatus(ctx context.Context) (egress.UpstreamStatus, error) {
	return egress.FetchStatus(ctx, s.opt.EgressURL)
}
