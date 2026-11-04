package httpapi

import (
	"context"
	"encoding/csv"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/perfreview"
)

// PerfReview is the owner's performance reviews (the orchestrator).
type PerfReview interface {
	Developers(ctx context.Context, p orchestrator.Period) (orchestrator.DevelopersReport, error)
	DeveloperTickets(ctx context.Context, author string, p orchestrator.Period) ([]orchestrator.DeveloperTicket, error)
	ExportMember(ctx context.Context, author string) (orchestrator.MemberExport, error)
	CloseMonth(ctx context.Context, month string, by int64) (orchestrator.DevelopersReport, error)
	BackfillScores(ctx context.Context, since *time.Time, confirm bool) (orchestrator.BackfillEstimate, error)
	Identities(ctx context.Context) ([]domain.GitIdentity, []domain.UnmappedAuthor, error)
	MapGitIdentity(ctx context.Context, userID int64, login, email string, remove bool) error
	Regressions(ctx context.Context) ([]domain.Regression, error)
	DecideRegression(ctx context.Context, bug, decision string, id int64, origin, reason string, by int64) (domain.Regression, error)
	OverrideScore(ctx context.Context, key string, delivery int, points *int, reason string, by int64) (orchestrator.DeveloperTicket, error)
}

// perf runs f and writes its answer, or the error it ended with.
func perf[T any](s *Server, w http.ResponseWriter, r *http.Request, f func(PerfReview) (T, error), out func(T) any) {
	if s.opt.PerfReview == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "performance reviews are not available")
		return
	}
	v, err := f(s.opt.PerfReview)
	switch {
	case errors.Is(err, orchestrator.ErrInvalid), errors.Is(err, domain.ErrPerfInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "not found")
	case err != nil:
		s.writeInternal(w, r, err)
	default:
		writeJSON(w, http.StatusOK, out(v))
	}
}

func actorID(r *http.Request) int64 {
	if u, ok := userFrom(r.Context()); ok {
		return u.ID
	}
	return 0
}

func period(month *string, closing *int, from, to *time.Time) orchestrator.Period {
	p := orchestrator.Period{From: from, To: to}
	if month != nil {
		p.Month = *month
	}
	if closing != nil {
		p.Closing = *closing
	}
	return p
}

func f32(x float64) float32 { return float32(x) }

func toTotals(t perfreview.Total) gen.DeveloperTotals {
	return gen.DeveloperTotals{Points: f32(t.Points), Tickets: t.Tickets, AvgPoints: f32(t.Average()), Reverts: t.Reverts, Regressions: t.Regressions}
}

func toClosing(c domain.PeriodClosing) gen.DevelopersClosing {
	return gen.DevelopersClosing{Closing: c.Closing, PromptVersion: c.PromptVersion, Unscored: c.Unscored, ClosedAt: c.ClosedAt, ClosedBy: c.ClosedBy}
}

func toDevelopersReport(rep orchestrator.DevelopersReport) any {
	out := gen.DevelopersReport{From: rep.From, To: rep.To, Live: rep.Live, PromptVersion: rep.PromptVersion, Changed: rep.Changed,
		ClosesOn: rep.ClosesOn, Unscored: rep.Unscored, Closings: []gen.DevelopersClosing{}, Rows: []gen.DeveloperRow{}}
	if rep.Month != "" {
		out.Month = &rep.Month
	}
	if rep.Closing != nil {
		c := toClosing(*rep.Closing)
		out.Closing = &c
	}
	for _, c := range rep.Closings {
		out.Closings = append(out.Closings, toClosing(c))
	}
	for _, r := range rep.Rows {
		row := gen.DeveloperRow{Key: r.Key, Kind: gen.DeveloperRowKind(r.Kind), Name: r.Name, Totals: toTotals(r.Total)}
		if r.UserID > 0 {
			id := r.UserID
			row.UserId = &id
		}
		if r.Live != nil {
			l := toTotals(*r.Live)
			row.Live = &l
		}
		out.Rows = append(out.Rows, row)
	}
	return out
}

func toDeveloperTicket(t orchestrator.DeveloperTicket) gen.DeveloperTicket {
	out := gen.DeveloperTicket{Key: t.TicketKey, Title: t.Title, Delivery: t.Delivery, DeliveredAt: t.DeliveredAt, PromptVersion: t.PromptVersion,
		Status: gen.DeveloperTicketStatus(t.Status), Points: t.Points, Effective: t.Effective(), OverridePoints: t.OverridePoints,
		OverriddenBy: t.OverriddenBy, OverriddenAt: t.OverriddenAt, Rationale: t.Rationale, DiffSource: t.DiffSource, Clamped: t.Clamped,
		FromFactsOnly: t.FromFactsOnly, RevertedShare: f32(t.RevertedShare), Regressions: t.Regressions, Share: f32(t.Share),
		Earned: f32(t.Earned), Authors: []gen.DeveloperShare{}, Factors: t.Factors}
	if out.Factors == nil {
		out.Factors = map[string]any{}
	}
	delete(out.Factors, "earners") // who wrote which commit stays on the server
	if t.Error != "" {
		out.Error = &t.Error
	}
	if t.Model != "" {
		out.Model = &t.Model
	}
	if t.OverrideReason != "" {
		out.OverrideReason = &t.OverrideReason
	}
	for _, a := range t.Authors {
		out.Authors = append(out.Authors, gen.DeveloperShare{Key: a.Key, Name: t.AuthorNames[a.Key], Share: f32(a.Share), Days: a.Days})
	}
	return out
}

func toDeveloperTickets(ts []orchestrator.DeveloperTicket) any {
	out := make([]gen.DeveloperTicket, len(ts))
	for i, t := range ts {
		out[i] = toDeveloperTicket(t)
	}
	return out
}

// GetDevelopers implements gen.ServerInterface.
func (s *Server) GetDevelopers(w http.ResponseWriter, r *http.Request, p gen.GetDevelopersParams) {
	perf(s, w, r, func(pr PerfReview) (orchestrator.DevelopersReport, error) {
		return pr.Developers(r.Context(), period(p.Month, p.Closing, p.From, p.To))
	}, toDevelopersReport)
}

// GetDeveloperTickets implements gen.ServerInterface.
func (s *Server) GetDeveloperTickets(w http.ResponseWriter, r *http.Request, p gen.GetDeveloperTicketsParams) {
	author := ""
	if p.Author != nil {
		author = *p.Author
	}
	perf(s, w, r, func(pr PerfReview) ([]orchestrator.DeveloperTicket, error) {
		return pr.DeveloperTickets(r.Context(), author, period(p.Month, nil, p.From, p.To))
	}, toDeveloperTickets)
}

// ExportDeveloper implements gen.ServerInterface: a download of one
// author's data, JSON or CSV.
func (s *Server) ExportDeveloper(w http.ResponseWriter, r *http.Request, p gen.ExportDeveloperParams) {
	if s.opt.PerfReview == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "performance reviews are not available")
		return
	}
	ex, err := s.opt.PerfReview.ExportMember(r.Context(), p.Author)
	switch {
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	case err != nil:
		s.writeInternal(w, r, err)
		return
	}
	name := "agnts-performance-" + strings.NewReplacer(":", "-", "@", "-at-", "/", "-", `"`, "").Replace(p.Author)
	if p.Format != nil && *p.Format == gen.ExportDeveloperParamsFormatCsv {
		w.Header().Set("Content-Type", "text/csv; charset=utf-8")
		w.Header().Set("Content-Disposition", `attachment; filename="`+name+`.csv"`)
		cw := csv.NewWriter(w)
		_ = cw.Write([]string{"ticket", "title", "delivery", "delivered_at", "status", "points", "override", "override_reason", "share", "earned",
			"reverted_share", "regressions", "clamped", "facts_only", "diff_source", "rationale"})
		for _, t := range ex.Tickets {
			override := ""
			if t.OverridePoints != nil {
				override = strconv.Itoa(*t.OverridePoints)
			}
			_ = cw.Write([]string{t.TicketKey, t.Title, strconv.Itoa(t.Delivery), t.DeliveredAt.Format(time.RFC3339), t.Status, strconv.Itoa(t.Points),
				override, t.OverrideReason, fmt.Sprintf("%.4f", t.Share), fmt.Sprintf("%.2f", t.Earned), fmt.Sprintf("%.4f", t.RevertedShare),
				strconv.Itoa(t.Regressions), strconv.FormatBool(t.Clamped), strconv.FormatBool(t.FromFactsOnly), t.DiffSource, t.Rationale})
		}
		for _, sn := range ex.Snapshots {
			_ = cw.Write([]string{"closing", sn.Month.Format("2006-01"), strconv.Itoa(sn.Closing), sn.ClosedAt.Format(time.RFC3339), "",
				fmt.Sprintf("%.2f", sn.Points), "", "", "", "", "", strconv.Itoa(sn.Regressions), "", "", "",
				fmt.Sprintf("%d tickets, %d reverts", sn.Tickets, sn.Reverts)})
		}
		cw.Flush()
		return
	}
	out := gen.DeveloperExport{Author: ex.Author, Name: ex.Name, ExportedAt: time.Now(), Tickets: []gen.DeveloperTicket{}}
	for _, t := range ex.Tickets {
		out.Tickets = append(out.Tickets, toDeveloperTicket(t))
	}
	for _, sn := range ex.Snapshots {
		out.Snapshots = append(out.Snapshots, struct {
			ClosedAt time.Time           `json:"closedAt"`
			Closing  int                 `json:"closing"`
			Month    string              `json:"month"`
			Totals   gen.DeveloperTotals `json:"totals"`
		}{ClosedAt: sn.ClosedAt, Closing: sn.Closing, Month: sn.Month.Format("2006-01"), Totals: toTotals(sn.Total)})
	}
	w.Header().Set("Content-Disposition", `attachment; filename="`+name+`.json"`)
	writeJSON(w, http.StatusOK, out)
}

// CloseDevelopersMonth implements gen.ServerInterface.
func (s *Server) CloseDevelopersMonth(w http.ResponseWriter, r *http.Request, month string) {
	perf(s, w, r, func(pr PerfReview) (orchestrator.DevelopersReport, error) {
		return pr.CloseMonth(r.Context(), month, actorID(r))
	}, toDevelopersReport)
}

// BackfillScores implements gen.ServerInterface.
func (s *Server) BackfillScores(w http.ResponseWriter, r *http.Request) {
	var req gen.ScoreBackfillRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	perf(s, w, r, func(pr PerfReview) (orchestrator.BackfillEstimate, error) {
		return pr.BackfillScores(r.Context(), req.Since, req.Confirm)
	}, func(e orchestrator.BackfillEstimate) any {
		out := gen.ScoreBackfill{Deliveries: e.Deliveries, CostUsd: f32(e.CostUSD), Credits: e.Credits, Balance: e.Balance, OnCredits: e.OnCredits,
			Queued: e.Queued, ReachDays: e.ReachDays}
		if e.Refused != "" {
			out.Refused = &e.Refused
		}
		return out
	})
}

func (s *Server) identities(w http.ResponseWriter, r *http.Request, before func(PerfReview) error) {
	perf(s, w, r, func(pr PerfReview) (gen.GitIdentities, error) {
		if before != nil {
			if err := before(pr); err != nil {
				return gen.GitIdentities{}, err
			}
		}
		ids, un, err := pr.Identities(r.Context())
		out := gen.GitIdentities{Identities: []gen.GitIdentity{}, Unmapped: []struct {
			Deliveries int    `json:"deliveries"`
			Identity   string `json:"identity"`
			Key        string `json:"key"`
		}{}}
		for _, g := range ids {
			out.Identities = append(out.Identities, gen.GitIdentity{UserId: g.UserID, Login: g.Login, Email: g.Email})
		}
		for _, u := range un {
			out.Unmapped = append(out.Unmapped, struct {
				Deliveries int    `json:"deliveries"`
				Identity   string `json:"identity"`
				Key        string `json:"key"`
			}{Deliveries: u.Deliveries, Identity: u.Identity, Key: u.Key})
		}
		return out, err
	}, func(g gen.GitIdentities) any { return g })
}

// GetGitIdentities implements gen.ServerInterface.
func (s *Server) GetGitIdentities(w http.ResponseWriter, r *http.Request) { s.identities(w, r, nil) }

// MapGitIdentity implements gen.ServerInterface.
func (s *Server) MapGitIdentity(w http.ResponseWriter, r *http.Request) {
	var req gen.GitIdentityInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.identities(w, r, func(pr PerfReview) error {
		return pr.MapGitIdentity(r.Context(), req.UserId, deref(req.Login), deref(req.Email), req.Remove != nil && *req.Remove)
	})
}

func toRegression(g domain.Regression) gen.Regression {
	return gen.Regression{Id: g.ID, Bug: g.Bug, BugTitle: g.BugTitle, Origin: g.Origin, OriginTitle: g.OriginTitle,
		Status: gen.RegressionStatus(g.Status), Source: g.Source, Reason: g.Reason, Counts: &g.Counts, DecidedBy: g.DecidedBy, DecidedAt: g.DecidedAt}
}

// GetRegressions implements gen.ServerInterface.
func (s *Server) GetRegressions(w http.ResponseWriter, r *http.Request) {
	perf(s, w, r, func(pr PerfReview) ([]domain.Regression, error) { return pr.Regressions(r.Context()) }, func(gs []domain.Regression) any {
		out := make([]gen.Regression, len(gs))
		for i, g := range gs {
			out[i] = toRegression(g)
		}
		return out
	})
}

// SetRegressionOf implements gen.ServerInterface.
func (s *Server) SetRegressionOf(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.RegressionInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var id int64
	if req.Id != nil {
		id = *req.Id
	}
	perf(s, w, r, func(pr PerfReview) (domain.Regression, error) {
		return pr.DecideRegression(r.Context(), key, string(req.Decision), id, deref(req.Origin), deref(req.Reason), actorID(r))
	}, func(g domain.Regression) any { return toRegression(g) })
}

// OverrideScore implements gen.ServerInterface.
func (s *Server) OverrideScore(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.ScoreOverride
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var points *int
	if req.Points != nil {
		p := int(*req.Points)
		points = &p
	}
	perf(s, w, r, func(pr PerfReview) (orchestrator.DeveloperTicket, error) {
		return pr.OverrideScore(r.Context(), key, req.Delivery, points, deref(req.Reason), actorID(r))
	}, func(t orchestrator.DeveloperTicket) any { return toDeveloperTicket(t) })
}
