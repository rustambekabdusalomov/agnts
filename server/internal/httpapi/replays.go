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

func toReplayVersions(vs []orchestrator.EvalVersion) []gen.ReplayVersion {
	out := make([]gen.ReplayVersion, len(vs))
	for i, v := range vs {
		out[i] = gen.ReplayVersion{PromptVersion: v.PromptVersion, Replays: v.Replays, ChecksPassed: v.ChecksPassed,
			Reviewed: v.Reviewed, LooksGood: v.LooksGood, AvgOverlap: float32(v.AvgOverlap), AvgRecall: float32(v.AvgRecall),
			AvgTurns: float32(v.AvgTurns), AvgCostUsd: float32(v.AvgCostUSD), OriginalTurns: float32(v.OriginalTurns),
			OriginalCostUsd: float32(v.OriginalCostUSD), Merged: ptr(v.Merged)}
		if v.Model != "" {
			out[i].Model = ptr(v.Model)
		}
		if v.AvgLineRecall >= 0 {
			out[i].AvgLineRecall, out[i].OriginalLineRecall = ptr(float32(v.AvgLineRecall)), ptr(float32(v.OriginalLineRecall))
		}
	}
	return out
}

func toReplayReport(rep orchestrator.ReplayReport) gen.ReplayReport {
	bench := toReplayVersions(rep.Benchmark)
	out := gen.ReplayReport{Versions: toReplayVersions(rep.Versions), Benchmark: &bench, Replays: make([]gen.ReplayResult, len(rep.Replays))}
	for i, x := range rep.Replays {
		out.Replays[i] = gen.ReplayResult{Key: x.Key, Original: x.Original, Title: x.Title, State: gen.TicketState(x.State),
			PromptVersion: x.PromptVersion, HasChange: x.HasChange, ChecksPassed: x.ChecksPassed, Files: nonNilStrings(x.Files),
			OriginalFiles: nonNilStrings(x.OriginalFiles), Overlap: float32(x.Overlap), Recall: float32(x.Recall), Turns: x.Turns,
			OriginalTurns: x.OriginalTurns, CostUsd: float32(x.CostUSD), OriginalCostUsd: float32(x.OriginalCostUSD), CreatedAt: x.CreatedAt,
			Benchmark: ptr(x.Benchmark)}
		if x.Model != "" {
			out.Replays[i].Model = ptr(x.Model)
		}
		if x.Against != "" {
			out.Replays[i].Against = ptr(gen.ReplayResultAgainst(x.Against))
		}
		if x.LineRecall >= 0 {
			out.Replays[i].LineRecall = ptr(float32(x.LineRecall))
		}
		if x.OriginalLineRecall >= 0 {
			out.Replays[i].OriginalLineRecall = ptr(float32(x.OriginalLineRecall))
		}
		if x.Verdict != "" {
			v := gen.ReplayResultVerdict(x.Verdict)
			out.Replays[i].Verdict = &v
		}
	}
	return out
}

// SetTicketBenchmark implements gen.ServerInterface.
func (s *Server) SetTicketBenchmark(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.SetTicketBenchmarkJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetBenchmark(ctx, key, req.Benchmark, origin(r))
	})
}

// GetBenchmark implements gen.ServerInterface.
func (s *Server) GetBenchmark(w http.ResponseWriter, r *http.Request) {
	ts, err := s.opt.Tickets.Benchmark(r.Context())
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := make([]gen.Ticket, len(ts))
	for i, t := range ts {
		out[i] = toTicket(t)
	}
	writeJSON(w, http.StatusOK, out)
}

// RunBenchmark implements gen.ServerInterface.
func (s *Server) RunBenchmark(w http.ResponseWriter, r *http.Request) {
	var req gen.RunBenchmarkJSONRequestBody
	if r.ContentLength != 0 {
		if err := decodeJSON(r, &req); err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", err.Error())
			return
		}
	}
	var models map[string]string
	if req.Models != nil {
		models = *req.Models
	}
	runs, err := s.opt.Tickets.RunBenchmark(r.Context(), models, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := make([]gen.BenchmarkRun, len(runs))
	for i, x := range runs {
		out[i] = gen.BenchmarkRun{Original: x.Original}
		if x.Replay != nil {
			out[i].Replay = ptr(x.Replay.Key)
		}
		if x.Error != "" {
			out[i].Error = ptr(x.Error)
		}
	}
	writeJSON(w, http.StatusOK, out)
}
