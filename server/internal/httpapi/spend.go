package httpapi

import (
	"net/http"

	"agnts/internal/httpapi/gen"
)

// GetTicketSpend implements gen.ServerInterface.
func (s *Server) GetTicketSpend(w http.ResponseWriter, r *http.Request, p gen.GetTicketSpendParams) {
	if !s.adminReady(w) {
		return
	}
	days, limit := 30, 10
	if p.Days != nil {
		days = int(*p.Days)
	}
	if p.Limit != nil {
		limit = *p.Limit
	}
	v, err := s.opt.Admin.Dashboard.TicketSpend(r.Context(), days, limit)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.TicketSpendList{Days: v.Days, Total: toTokenSpend(v.Total), Tickets: make([]gen.TicketSpendRow, len(v.Tickets))}
	for i, t := range v.Tickets {
		row := gen.TicketSpendRow{Key: t.Key, Title: t.Title, Kind: gen.TicketKind(t.Kind), State: gen.TicketState(t.State),
			Calls: t.Calls, TopStage: gen.TicketSpendRowTopStage(t.TopStage), Spend: toTokenSpend(t.Usage)}
		if t.RepoName != "" {
			name := t.RepoName
			row.RepoName = &name
		}
		out.Tickets[i] = row
	}
	writeJSON(w, http.StatusOK, out)
}
