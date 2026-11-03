package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
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
	var st egress.UpstreamStatus
	if s.opt.EgressURL == "" {
		return st, fmt.Errorf("this server runs without the egress proxy (AGNTS_RUN_PROXY is not set)")
	}
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, s.opt.EgressURL+egress.StatusPath, nil)
	if err != nil {
		return st, err
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return st, fmt.Errorf("egress did not answer: %w", err)
	}
	defer func() { _ = res.Body.Close() }()
	if res.StatusCode != http.StatusOK {
		return st, fmt.Errorf("egress answered %s (an egress from before the status page?)", res.Status)
	}
	if err := json.NewDecoder(io.LimitReader(res.Body, 1<<20)).Decode(&st); err != nil {
		return st, fmt.Errorf("egress status: %w", err)
	}
	return st, nil
}
