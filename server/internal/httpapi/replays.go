package httpapi

import (
	"context"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// ReplayTicket implements gen.ServerInterface.
func (s *Server) ReplayTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Replay(ctx, key, origin(r)) })
}

// GetReplayReport implements gen.ServerInterface.
func (s *Server) GetReplayReport(w http.ResponseWriter, r *http.Request) {
	rep, err := s.opt.Tickets.ReplayReport(r.Context())
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toReplayReport(rep))
}

func toReplayReport(rep orchestrator.ReplayReport) gen.ReplayReport {
	out := gen.ReplayReport{Versions: make([]gen.ReplayVersion, len(rep.Versions)), Replays: make([]gen.ReplayResult, len(rep.Replays))}
	for i, v := range rep.Versions {
		out.Versions[i] = gen.ReplayVersion{PromptVersion: v.PromptVersion, Replays: v.Replays, ChecksPassed: v.ChecksPassed,
			Reviewed: v.Reviewed, LooksGood: v.LooksGood, AvgOverlap: float32(v.AvgOverlap), AvgRecall: float32(v.AvgRecall),
			AvgTurns: float32(v.AvgTurns), AvgCostUsd: float32(v.AvgCostUSD), OriginalTurns: float32(v.OriginalTurns),
			OriginalCostUsd: float32(v.OriginalCostUSD)}
	}
	for i, x := range rep.Replays {
		out.Replays[i] = gen.ReplayResult{Key: x.Key, Original: x.Original, Title: x.Title, State: gen.TicketState(x.State),
			PromptVersion: x.PromptVersion, HasChange: x.HasChange, ChecksPassed: x.ChecksPassed, Files: nonNilStrings(x.Files),
			OriginalFiles: nonNilStrings(x.OriginalFiles), Overlap: float32(x.Overlap), Recall: float32(x.Recall), Turns: x.Turns,
			OriginalTurns: x.OriginalTurns, CostUsd: float32(x.CostUSD), OriginalCostUsd: float32(x.OriginalCostUSD), CreatedAt: x.CreatedAt}
		if x.Verdict != "" {
			v := gen.ReplayResultVerdict(x.Verdict)
			out.Replays[i].Verdict = &v
		}
	}
	return out
}
