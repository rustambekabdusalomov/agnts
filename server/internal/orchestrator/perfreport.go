package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/perfreview"
)

// PeriodCloser is the store of performance review totals and month
// closings. A Store may implement it.
type PeriodCloser interface {
	DeliveryScores(ctx context.Context, from, to time.Time, version, author string) ([]domain.TicketScore, error)
	PendingScores(ctx context.Context, from, to time.Time, version string) (int, error)
	CloseMonth(ctx context.Context, month time.Time, version string, totals []perfreview.Total, unscored int, by *int64) (domain.PeriodClosing, error)
	Closings(ctx context.Context, month time.Time) ([]domain.PeriodClosing, error)
	ClosedMonths(ctx context.Context) ([]time.Time, error)
	SnapshotTotals(ctx context.Context, month time.Time, closing int) ([]perfreview.Total, error)
	UserNames(ctx context.Context, ids []int64) (map[int64]string, error)
	PromptVersionAt(ctx context.Context, at time.Time) (domain.PromptVersionRow, error)
	CurrentPromptVersion(ctx context.Context) (domain.PromptVersionRow, error)
	PerfReviewSince(ctx context.Context) (*time.Time, error)
}

// Period is what a report covers: a month ("2026-10", optionally one of
// its earlier closings) or a range [From, To).
type Period struct {
	Month   string
	Closing int // 0: the latest
	From    *time.Time
	To      *time.Time
}

// Author kinds of a report's rows.
const (
	AuthorUser     = "user"
	AuthorAgent    = "agent"
	AuthorUnmapped = "unmapped"
)

// DeveloperRow is one author's row of a report.
type DeveloperRow struct {
	perfreview.Total
	Kind    string
	UserID  int64
	Name    string
	Average float64
	// Live is what the row is now, when a closed month changed since.
	Live *perfreview.Total
}

// DevelopersReport is the Developers tab: one row per author.
type DevelopersReport struct {
	From, To      time.Time
	Month         string
	Live          bool // a custom range, or a month not closed yet
	PromptVersion string
	Closing       *domain.PeriodClosing  // the closing shown
	Closings      []domain.PeriodClosing // every closing of the month, newest first
	Changed       bool                   // the month changed since that closing
	ClosesOn      *time.Time             // an ended month in its grace period
	Rows          []DeveloperRow
	Unscored      int
}

func (o *Orchestrator) periodStore() (PeriodCloser, error) {
	pc, ok := o.store.(PeriodCloser)
	if !ok {
		return nil, errors.New("performance reviews are not available on this server")
	}
	return pc, nil
}

// perfEnabled returns the settings when performance reviews are on.
func (o *Orchestrator) perfEnabled(ctx context.Context) (domain.Settings, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return s, err
	}
	if !s.PerfReview.Enabled {
		return s, invalid("performance reviews are off in this workspace's settings")
	}
	return s, nil
}

// monthDate is a month as the period tables store it.
func monthDate(m perfreview.Month) time.Time {
	return time.Date(m.Start.Year(), m.Start.Month(), 1, 0, 0, 0, 0, time.UTC)
}

// versionAt is the scoring version current at a time, else the current.
func versionAt(ctx context.Context, pc PeriodCloser, at time.Time) string {
	if v, err := pc.PromptVersionAt(ctx, at); err == nil {
		return v.Version
	}
	return perfreview.PromptVersion
}

// liveTotals adds up a period's scored deliveries now.
func liveTotals(ctx context.Context, pc PeriodCloser, from, to time.Time, version string) ([]perfreview.Total, int, error) {
	scores, err := pc.DeliveryScores(ctx, from, to, version, "")
	if err != nil {
		return nil, 0, err
	}
	unscored := 0
	for _, s := range scores {
		if s.Status != domain.ScoreScored {
			unscored++
		}
	}
	return perfreview.Totals(scores), unscored, nil
}

// Developers returns the Developers tab for a period: a closed month's
// snapshot with what changed since, else the live numbers.
func (o *Orchestrator) Developers(ctx context.Context, p Period) (DevelopersReport, error) {
	var rep DevelopersReport
	pc, err := o.periodStore()
	if err != nil {
		return rep, err
	}
	s, err := o.perfEnabled(ctx)
	if err != nil {
		return rep, err
	}
	tz := s.PerfReview.Location()
	var live []perfreview.Total
	switch {
	case p.Month != "":
		m, ok := perfreview.ParseMonth(p.Month, tz)
		if !ok {
			return rep, invalid("month must look like 2026-10")
		}
		rep.From, rep.To, rep.Month = m.Start, m.End, m.Name()
		rep.PromptVersion = versionAt(ctx, pc, m.End)
		if live, rep.Unscored, err = liveTotals(ctx, pc, m.Start, m.End, rep.PromptVersion); err != nil {
			return rep, err
		}
		if rep.Closings, err = pc.Closings(ctx, monthDate(m)); err != nil {
			return rep, err
		}
		if len(rep.Closings) == 0 {
			rep.Live = true
			if now := time.Now(); !now.Before(m.End) {
				on := m.ClosesOn()
				rep.ClosesOn = &on
			}
			rep.Rows = o.rows(ctx, pc, live, nil)
			return rep, nil
		}
		c := rep.Closings[0]
		if p.Closing > 0 {
			i := slices.IndexFunc(rep.Closings, func(x domain.PeriodClosing) bool { return x.Closing == p.Closing })
			if i < 0 {
				return rep, invalid("the month has no closing %d", p.Closing)
			}
			c = rep.Closings[i]
		}
		rep.Closing = &c
		snap, err := pc.SnapshotTotals(ctx, c.Month, c.Closing)
		if err != nil {
			return rep, err
		}
		rep.Rows = o.rows(ctx, pc, snap, live)
		rep.Changed = changed(snap, live) || c.Unscored != rep.Unscored
		rep.Unscored = c.Unscored
		return rep, nil
	case p.From != nil && p.To != nil:
		if !p.From.Before(*p.To) {
			return rep, invalid("from must be before to")
		}
		rep.From, rep.To, rep.Live = *p.From, *p.To, true
		rep.PromptVersion = versionAt(ctx, pc, time.Now())
		if live, rep.Unscored, err = liveTotals(ctx, pc, rep.From, rep.To, rep.PromptVersion); err != nil {
			return rep, err
		}
		rep.Rows = o.rows(ctx, pc, live, nil)
		return rep, nil
	}
	return rep, invalid("give a month, or from and to")
}

// changed reports whether live totals differ from a snapshot.
func changed(snap, live []perfreview.Total) bool {
	if len(snap) != len(live) {
		return true
	}
	for i := range snap {
		if snap[i] != live[i] {
			return true
		}
	}
	return false
}

// rows names the totals' authors; with live, each row shows what it is
// now when that differs (and authors new since get a row of their own).
func (o *Orchestrator) rows(ctx context.Context, pc PeriodCloser, totals, live []perfreview.Total) []DeveloperRow {
	byKey := map[string]perfreview.Total{}
	for _, t := range live {
		byKey[t.Key] = t
	}
	keys := map[string]bool{}
	var out []DeveloperRow
	for _, t := range totals {
		keys[t.Key] = true
		r := DeveloperRow{Total: t, Average: t.Average()}
		if live != nil {
			if l, ok := byKey[t.Key]; !ok || l != t {
				l.Key = t.Key
				r.Live = &l
			}
		}
		out = append(out, r)
	}
	for _, l := range live {
		if !keys[l.Key] {
			l := l
			out = append(out, DeveloperRow{Total: perfreview.Total{Key: l.Key}, Live: &l})
		}
	}
	o.nameRows(ctx, pc, out)
	slices.SortStableFunc(out, func(a, b DeveloperRow) int { return strings.Compare(a.Kind+a.Name, b.Kind+b.Name) })
	return out
}

func (o *Orchestrator) nameRows(ctx context.Context, pc PeriodCloser, rows []DeveloperRow) {
	var ids []int64
	for i := range rows {
		if id, ok := perfreview.ParseUserKey(rows[i].Key); ok {
			rows[i].Kind, rows[i].UserID = AuthorUser, id
			ids = append(ids, id)
		}
	}
	names, _ := pc.UserNames(ctx, ids)
	for i := range rows {
		r := &rows[i]
		switch {
		case r.Kind == AuthorUser:
			r.Name = names[r.UserID]
		case r.Key == perfreview.AgentKey:
			r.Kind, r.Name = AuthorAgent, "agnts"
		default:
			r.Kind, r.Name = AuthorUnmapped, strings.TrimPrefix(r.Key, "unmapped:")
		}
	}
}

// DeveloperTicket is one delivery in an author's drill-down.
type DeveloperTicket struct {
	domain.TicketScore
	Share  float64
	Earned float64
	// AuthorNames names the delivery's authors, by key.
	AuthorNames map[string]string
}

// DeveloperTickets returns an author's deliveries in a period, with what
// each earned them; author "" lists every delivery (unscored included).
func (o *Orchestrator) DeveloperTickets(ctx context.Context, author string, p Period) ([]DeveloperTicket, error) {
	pc, err := o.periodStore()
	if err != nil {
		return nil, err
	}
	s, err := o.perfEnabled(ctx)
	if err != nil {
		return nil, err
	}
	from, to, version, err := o.periodBounds(ctx, pc, s, p)
	if err != nil {
		return nil, err
	}
	scores, err := pc.DeliveryScores(ctx, from, to, version, author)
	if err != nil {
		return nil, err
	}
	return o.developerTickets(ctx, pc, author, scores), nil
}

func (o *Orchestrator) developerTickets(ctx context.Context, pc PeriodCloser, author string, scores []domain.TicketScore) []DeveloperTicket {
	var rows []DeveloperRow
	seen := map[string]bool{}
	for _, sc := range scores {
		for _, a := range sc.Authors {
			if !seen[a.Key] {
				seen[a.Key] = true
				rows = append(rows, DeveloperRow{Total: perfreview.Total{Key: a.Key}})
			}
		}
	}
	o.nameRows(ctx, pc, rows)
	names := map[string]string{}
	for _, r := range rows {
		names[r.Key] = r.Name
	}
	out := make([]DeveloperTicket, 0, len(scores))
	for _, sc := range scores {
		dt := DeveloperTicket{TicketScore: sc, AuthorNames: names}
		for _, a := range sc.Authors {
			if a.Key == author {
				dt.Share = a.Share
			}
		}
		if sc.Status == domain.ScoreScored && author != "" {
			dt.Earned = perfreview.Earned(sc, dt.Share)
		}
		out = append(out, dt)
	}
	return out
}

// periodBounds turns a period into its range and scoring version.
func (o *Orchestrator) periodBounds(ctx context.Context, pc PeriodCloser, s domain.Settings, p Period) (time.Time, time.Time, string, error) {
	if p.Month != "" {
		m, ok := perfreview.ParseMonth(p.Month, s.PerfReview.Location())
		if !ok {
			return time.Time{}, time.Time{}, "", invalid("month must look like 2026-10")
		}
		return m.Start, m.End, versionAt(ctx, pc, m.End), nil
	}
	if p.From == nil || p.To == nil || !p.From.Before(*p.To) {
		return time.Time{}, time.Time{}, "", invalid("give a month, or from before to")
	}
	return *p.From, *p.To, versionAt(ctx, pc, time.Now()), nil
}

// CloseMonth closes (or closes again) an ended month now, for the owner.
func (o *Orchestrator) CloseMonth(ctx context.Context, month string, by int64) (DevelopersReport, error) {
	pc, err := o.periodStore()
	if err != nil {
		return DevelopersReport{}, err
	}
	s, err := o.perfEnabled(ctx)
	if err != nil {
		return DevelopersReport{}, err
	}
	m, ok := perfreview.ParseMonth(month, s.PerfReview.Location())
	if !ok {
		return DevelopersReport{}, invalid("month must look like 2026-10")
	}
	if time.Now().Before(m.End) {
		return DevelopersReport{}, invalid("%s has not ended yet", m.Name())
	}
	if err := closeOne(ctx, pc, m, &by); err != nil {
		return DevelopersReport{}, err
	}
	return o.Developers(ctx, Period{Month: m.Name()})
}

func closeOne(ctx context.Context, pc PeriodCloser, m perfreview.Month, by *int64) error {
	version := versionAt(ctx, pc, m.End)
	totals, unscored, err := liveTotals(ctx, pc, m.Start, m.End, version)
	if err != nil {
		return err
	}
	_, err = pc.CloseMonth(ctx, monthDate(m), version, totals, unscored, by)
	return err
}

// closeMonths closes, on their own, the ended months since the workspace
// started scoring that are past their grace period.
func (o *Orchestrator) closeMonths(ctx context.Context, pc PeriodCloser) {
	s, err := o.settings.Get(ctx)
	if err != nil || !s.PerfReview.Enabled {
		return
	}
	since, err := pc.PerfReviewSince(ctx)
	if err != nil || since == nil {
		return
	}
	closed, err := pc.ClosedMonths(ctx)
	if err != nil {
		return
	}
	tz := s.PerfReview.Location()
	now := time.Now()
	for m := perfreview.MonthOf(*since, tz); !now.Before(m.End); m = perfreview.MonthOf(m.End, tz) {
		if slices.ContainsFunc(closed, func(c time.Time) bool { return c.Equal(monthDate(m)) }) {
			continue
		}
		pending, err := pc.PendingScores(ctx, m.Start, m.End, versionAt(ctx, pc, m.End))
		if err != nil || !m.CloseDue(now, pending) {
			continue
		}
		if err := closeOne(ctx, pc, m, nil); err != nil {
			o.log.Warn("close month", "month", m.Name(), "err", err)
			continue
		}
		o.log.Info("month closed", "month", m.Name(), "workspace", domain.WorkspaceOf(ctx))
	}
}

// MemberExport is everything held about one author, for a right of
// access request: every delivery they have a share of and every closing
// row about them.
type MemberExport struct {
	Author    string
	Name      string
	Tickets   []DeveloperTicket
	Snapshots []MemberSnapshot
}

// MemberSnapshot is an author's row in one closing.
type MemberSnapshot struct {
	domain.PeriodClosing
	perfreview.Total
}

// ExportMember gathers an author's data.
func (o *Orchestrator) ExportMember(ctx context.Context, author string) (MemberExport, error) {
	ex := MemberExport{Author: author}
	pc, err := o.periodStore()
	if err != nil {
		return ex, err
	}
	if _, err := o.perfEnabled(ctx); err != nil {
		return ex, err
	}
	// Every delivery, under the version each month closes with: the
	// current one is what the tab shows.
	version := versionAt(ctx, pc, time.Now())
	scores, err := pc.DeliveryScores(ctx, time.Unix(0, 0), time.Now().AddDate(1, 0, 0), version, author)
	if err != nil {
		return ex, err
	}
	ex.Tickets = o.developerTickets(ctx, pc, author, scores)
	rows := []DeveloperRow{{Total: perfreview.Total{Key: author}}}
	o.nameRows(ctx, pc, rows)
	ex.Name = rows[0].Name
	months, err := pc.ClosedMonths(ctx)
	if err != nil {
		return ex, err
	}
	for _, m := range months {
		cs, err := pc.Closings(ctx, m)
		if err != nil {
			return ex, err
		}
		for _, c := range cs {
			totals, err := pc.SnapshotTotals(ctx, c.Month, c.Closing)
			if err != nil {
				return ex, err
			}
			for _, t := range totals {
				if t.Key == author {
					ex.Snapshots = append(ex.Snapshots, MemberSnapshot{PeriodClosing: c, Total: t})
				}
			}
		}
	}
	return ex, nil
}

// GitIdentities keeps which git logins and emails are whose. A Store may
// implement it.
type GitIdentities interface {
	MapGitIdentity(ctx context.Context, userID int64, login, email string) error
	UnmapGitIdentity(ctx context.Context, userID int64, login, email string) error
	ScoredEarners(ctx context.Context) ([]domain.DeliveryEarners, error)
	ReplaceScoreAuthors(ctx context.Context, ticketID int64, delivery int, authors []domain.ScoreAuthor) error
	IdentityResolver(ctx context.Context) (perfreview.Resolve, error)
	GitIdentities(ctx context.Context) ([]domain.GitIdentity, error)
	UnmappedAuthors(ctx context.Context) ([]domain.UnmappedAuthor, error)
}

// Identities lists the workspace's git identities and those that earned
// points but are no member's.
func (o *Orchestrator) Identities(ctx context.Context) ([]domain.GitIdentity, []domain.UnmappedAuthor, error) {
	gi, ok := o.store.(GitIdentities)
	if !ok {
		return nil, nil, errors.New("performance reviews are not available on this server")
	}
	if _, err := o.perfEnabled(ctx); err != nil {
		return nil, nil, err
	}
	ids, err := gi.GitIdentities(ctx)
	if err != nil {
		return nil, nil, err
	}
	un, err := gi.UnmappedAuthors(ctx)
	return ids, un, err
}

// MapGitIdentity gives a git login or email to a member (or takes it
// away, with remove) and works every scored delivery's shares out again,
// so the Unmapped row's points move to the member. A closed month shows
// the move as a change since it closed.
func (o *Orchestrator) MapGitIdentity(ctx context.Context, userID int64, login, email string, remove bool) error {
	gi, ok := o.store.(GitIdentities)
	if !ok {
		return errors.New("performance reviews are not available on this server")
	}
	s, err := o.perfEnabled(ctx)
	if err != nil {
		return err
	}
	if remove {
		err = gi.UnmapGitIdentity(ctx, userID, login, email)
	} else {
		err = gi.MapGitIdentity(ctx, userID, login, email)
	}
	if err != nil {
		return err
	}
	return o.recomputeShares(ctx, gi, s.PerfReview.Location())
}

func (o *Orchestrator) recomputeShares(ctx context.Context, gi GitIdentities, tz *time.Location) error {
	resolve, err := gi.IdentityResolver(ctx)
	if err != nil {
		return err
	}
	all, err := gi.ScoredEarners(ctx)
	if err != nil {
		return err
	}
	for _, d := range all {
		var earners []perfreview.Earner
		if json.Unmarshal(d.Earners, &earners) != nil || len(earners) == 0 {
			continue
		}
		var authors []domain.ScoreAuthor
		for _, sh := range perfreview.Shares(earners, resolve, tz) {
			authors = append(authors, domain.ScoreAuthor{Key: sh.Key, Share: sh.Share, Days: sh.Days})
		}
		if err := gi.ReplaceScoreAuthors(ctx, d.TicketID, d.Delivery, authors); err != nil {
			return err
		}
	}
	return nil
}
