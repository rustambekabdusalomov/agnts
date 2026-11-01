package admin

import (
	"context"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

// Dashboard builds the dashboard and the logs summary.
type Dashboard struct {
	store    *postgres.Agent
	orch     *orchestrator.Orchestrator
	repos    *Repos
	usage    *usage.Tracker
	settings interface {
		Get(ctx context.Context) (domain.Settings, error)
	}
	tz *time.Location
	// viewer is the account whose usage the person viewing sees; nil: the
	// install's one account.
	viewer func(ctx context.Context) (domain.ClaudeAccount, bool)
}

// SetViewerAccount sets how the account whose usage the dashboard shows is
// found for the person viewing it.
func (d *Dashboard) SetViewerAccount(f func(ctx context.Context) (domain.ClaudeAccount, bool)) {
	d.viewer = f
}

// NewDashboard returns the dashboard service; tz decides "today".
func NewDashboard(store *postgres.Agent, orch *orchestrator.Orchestrator, repos *Repos, u *usage.Tracker, settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}, tz *time.Location) *Dashboard {
	return &Dashboard{store: store, orch: orch, repos: repos, usage: u, settings: settings, tz: tz}
}

// LiveRun is a ticket in a container right now.
type LiveRun struct {
	Row         orchestrator.TicketRow
	Model       string
	Turns       int
	MaxTurns    int
	LastMessage string
}

// RepoActivity is one repository's open work.
type RepoActivity struct {
	Repo   RepoView
	Latest *orchestrator.TicketRow
}

// Data is everything the dashboard shows.
type Data struct {
	Counts      map[string]int
	Waiting     []orchestrator.TicketRow
	Live        []LiveRun
	Pipeline    map[string]int
	TodayByHour []postgres.HourBucket
	Week        postgres.WeekStats
	LastWeek    postgres.WeekStats
	Repos       []RepoActivity
	Recent      []domain.Event
	Usage       usage.View
	Parallel    int
}

var (
	needsStates   = []domain.TicketState{domain.StateWaitingForAnswers, domain.StateWaitingForReview, domain.StateFailed, domain.StateRateLimited}
	runningStates = []domain.TicketState{domain.StateAnalyzing, domain.StateCoding, domain.StateTesting, domain.StatePushing}
)

// Build assembles the dashboard.
func (d *Dashboard) Build(ctx context.Context) (Data, error) {
	s, err := d.settings.Get(ctx)
	if err != nil {
		return Data{}, err
	}
	var out Data
	out.Parallel = s.Parallel
	var acct domain.ClaudeAccount
	if d.viewer != nil {
		acct, _ = d.viewer(ctx)
	}
	if out.Usage, err = d.usage.Current(ctx, acct, s); err != nil {
		return out, err
	}

	open, err := d.store.ListTickets(ctx, orchestrator.TicketFilter{States: []domain.TicketState{
		domain.StateNew, domain.StateAnalyzing, domain.StateWaitingForAnswers, domain.StateCoding, domain.StateTesting,
		domain.StateWaitingForReview, domain.StatePushing, domain.StateFailed, domain.StateRateLimited,
	}, Limit: 500})
	if err != nil {
		return out, err
	}
	rows, err := d.orch.Rows(ctx, open)
	if err != nil {
		return out, err
	}

	out.Counts = map[string]int{}
	out.Pipeline = map[string]int{}
	var liveKeys []string
	for _, r := range rows {
		st := r.Ticket.State
		out.Pipeline[string(st)]++
		switch {
		case inStates(st, needsStates):
			out.Counts["needs"]++
			out.Waiting = append(out.Waiting, r)
			switch st {
			case domain.StateWaitingForAnswers:
				out.Counts["answers"]++
			case domain.StateWaitingForReview:
				out.Counts["reviews"]++
			default:
				out.Counts["stopped"]++
			}
		case inStates(st, runningStates):
			out.Counts["running"]++
			liveKeys = append(liveKeys, r.Ticket.Key)
		case st == domain.StateNew:
			out.Counts["queued"]++
		}
	}
	// Oldest wait first: every minute there is a minute agnts can't work.
	sortBySince(out.Waiting)
	if len(out.Waiting) > 6 {
		out.Waiting = out.Waiting[:6]
	}

	active, err := d.store.ActiveRuns(ctx)
	if err != nil {
		return out, err
	}
	var runIDs []int64
	for _, r := range active {
		runIDs = append(runIDs, r.ID)
	}
	calls, err := d.store.ToolCallsByRun(ctx, runIDs)
	if err != nil {
		return out, err
	}
	last, err := d.store.LastMessages(ctx, liveKeys)
	if err != nil {
		return out, err
	}
	for _, r := range rows {
		if !inStates(r.Ticket.State, runningStates) {
			continue
		}
		lr := LiveRun{Row: r, MaxTurns: s.MaxTurns, LastMessage: last[r.Ticket.Key]}
		if run, ok := active[r.Ticket.ID]; ok {
			lr.Turns = calls[run.ID]
			stage := domain.ModelCoding
			if run.Stage == domain.StageAnalyze {
				stage = domain.ModelAnalyze
			}
			lr.Model = s.ModelFor(r.Ticket, stage)
		}
		out.Live = append(out.Live, lr)
	}

	if out.TodayByHour, err = d.store.TodayByHour(ctx, d.tz); err != nil {
		return out, err
	}
	now := time.Now()
	if out.Week, err = d.store.Week(ctx, now.Add(-7*24*time.Hour)); err != nil {
		return out, err
	}
	if out.LastWeek, err = d.store.Week(ctx, now.Add(-14*24*time.Hour)); err != nil {
		return out, err
	}

	repos, err := d.repos.List(ctx)
	if err != nil {
		return out, err
	}
	recentTickets, err := d.store.ListTickets(ctx, orchestrator.TicketFilter{Limit: 200})
	if err != nil {
		return out, err
	}
	recentRows, err := d.orch.Rows(ctx, recentTickets)
	if err != nil {
		return out, err
	}
	for _, rp := range repos {
		a := RepoActivity{Repo: rp}
		for i := range recentRows {
			if id := recentRows[i].Ticket.RepoID; id != nil && *id == rp.ID {
				a.Latest = &recentRows[i]
				break
			}
		}
		if rp.Open > 0 || a.Latest != nil {
			out.Repos = append(out.Repos, a)
		}
	}
	if len(out.Repos) > 7 {
		out.Repos = out.Repos[:7]
	}
	out.Recent, err = d.store.RecentEvents(ctx, 8)
	return out, err
}

func inStates(s domain.TicketState, list []domain.TicketState) bool {
	for _, x := range list {
		if x == s {
			return true
		}
	}
	return false
}

func sortBySince(rows []orchestrator.TicketRow) {
	for i := 1; i < len(rows); i++ {
		for j := i; j > 0 && rows[j].Info.Since.Before(rows[j-1].Info.Since); j-- {
			rows[j], rows[j-1] = rows[j-1], rows[j]
		}
	}
}
