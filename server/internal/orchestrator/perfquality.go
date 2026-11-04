package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/perfreview"
)

// ScoreQuality keeps what takes points back: reverts, regressions, and
// the owner's overrides. A Store may implement it.
type ScoreQuality interface {
	RecentDeliveries(ctx context.Context, repoID int64, since time.Time, limit int) ([]domain.Delivery, []string, error)
	ProposeRegression(ctx context.Context, bug, origin, reason string, confidence float64) error
	Regressions(ctx context.Context) ([]domain.Regression, error)
	DecideRegression(ctx context.Context, bug string, id int64, status domain.RelationStatus, by int64) (domain.Regression, error)
	SetRegression(ctx context.Context, bug, origin, reason string, by int64) (domain.Regression, error)
	SetScoreOverride(ctx context.Context, ticketID int64, delivery int, points *int, reason string, by int64) error
	RevertsOf(ctx context.Context, repoID int64, shas []string) (map[string]string, error)
	SetRevertedShare(ctx context.Context, ticketID int64, delivery int, share float64) error
	ScoredDeliveriesOf(ctx context.Context, ticketID int64) ([]int, error)
}

func (o *Orchestrator) quality() (ScoreQuality, error) {
	q, ok := o.store.(ScoreQuality)
	if !ok {
		return nil, errors.New("performance reviews are not available on this server")
	}
	return q, nil
}

// revertedShare works out the part of a delivery's scored lines that
// reverts on the default branch undid; a re-land (a revert of the
// revert) gives them back.
func (o *Orchestrator) revertedShare(ctx context.Context, q ScoreQuality, cleaned perfreview.Cleaned) (float64, error) {
	if o.scoreHost == nil {
		return 0, nil
	}
	byRepo := map[int64][]string{}
	for _, l := range cleaned.Commits {
		if l.MergeKind != domain.MergeKindMerge && len(l.Parents) <= 1 {
			byRepo[l.RepoID] = append(byRepo[l.RepoID], l.SHA)
		}
	}
	undone := map[int64]map[string]bool{}
	any := false
	for repoID, shas := range byRepo {
		reverts, err := q.RevertsOf(ctx, repoID, shas)
		if err != nil {
			return 0, err
		}
		undone[repoID] = perfreview.Undone(shas, reverts)
		any = any || len(undone[repoID]) > 0
	}
	if !any {
		return 0, nil // nothing undone: no line counts needed
	}
	total, lost := 0, 0
	for repoID, shas := range byRepo {
		repo, err := o.store.RepositoryByID(ctx, repoID)
		if err != nil {
			return 0, err
		}
		for _, sha := range shas {
			files, err := o.scoreHost.CommitFiles(ctx, repo, sha)
			if err != nil {
				return 0, fmt.Errorf("read commit %s: %w", shortSHA(sha), err)
			}
			kept, _ := perfreview.Filter(files)
			n := 0
			for _, f := range kept {
				n += f.Add + f.Del
			}
			total += n
			if undone[repoID][sha] {
				lost += n
			}
		}
	}
	if total == 0 {
		return 0, nil
	}
	return float64(lost) / float64(total), nil
}

// updateReverts works the reverted share of a ticket's scored deliveries
// out again, after a revert (or a re-land) of its work.
func (o *Orchestrator) updateReverts(ctx context.Context, key string) {
	q, err := o.quality()
	sr := o.scoreRuns()
	if err != nil || sr == nil {
		return
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return
	}
	ds, err := q.ScoredDeliveriesOf(ctx, t.ID)
	if err != nil || len(ds) == 0 {
		return
	}
	links, err := sr.AllCommitLinksOfTicket(ctx, t.ID)
	if err != nil {
		return
	}
	for _, n := range ds {
		d, err := sr.DeliveryOf(ctx, t.ID, n)
		if err != nil {
			continue
		}
		cleaned, err := o.cleanDelivery(ctx, sr, perfreview.InDelivery(links, d.PreviousAt))
		if err != nil {
			continue
		}
		share, err := o.revertedShare(ctx, q, cleaned)
		if err != nil {
			o.log.Warn("reverted share", "ticket", key, "delivery", n, "err", err)
			continue
		}
		if err := q.SetRevertedShare(ctx, t.ID, n, share); err != nil {
			o.log.Warn("save reverted share", "ticket", key, "err", err)
		}
	}
}

// regressionWindow is how long after a delivery a bug counts against it.
const regressionWindow = 90 * 24 * time.Hour

// regressionCandidates are the recent deliveries a bug's analysis may
// name as the work it is a regression of: performance reviews on, a bug
// ticket in a repository.
func (o *Orchestrator) regressionCandidates(ctx context.Context, s domain.Settings, t domain.Ticket) []RelatedTicket {
	q, err := o.quality()
	if err != nil || !s.PerfReview.Enabled || t.Kind != domain.KindBug || t.RepoID == nil {
		return nil
	}
	ds, titles, err := q.RecentDeliveries(ctx, *t.RepoID, time.Now().Add(-regressionWindow), 30)
	if err != nil {
		return nil
	}
	var out []RelatedTicket
	seen := map[string]bool{t.Key: true}
	for i, d := range ds {
		if seen[d.TicketKey] {
			continue
		}
		seen[d.TicketKey] = true
		out = append(out, RelatedTicket{Key: d.TicketKey, Title: oneLine(titles[i]), State: "delivered " + d.DeliveredAt.Format(time.DateOnly)})
	}
	return out
}

// withRegressions appends the regression block to a bug's analysis
// prompt when there are recent deliveries to name.
func withRegressions(d promptData, cs []RelatedTicket, prompt string) (string, error) {
	if len(cs) == 0 {
		return prompt, nil
	}
	d.Related = cs
	block, err := render("regressions", d)
	if err != nil {
		return "", err
	}
	return prompt + "\n" + block, nil
}

// proposeRegression stores what the analysis said the bug is a
// regression of, as a proposal the owner confirms or dismisses.
func (o *Orchestrator) proposeRegression(ctx context.Context, t domain.Ticket, a Analysis, cs []RelatedTicket) {
	if a.RegressionOf == nil || len(cs) == 0 {
		return
	}
	key := strings.TrimSpace(a.RegressionOf.Key)
	known := false
	for _, c := range cs {
		known = known || c.Key == key
	}
	if !known {
		return
	}
	q, err := o.quality()
	if err != nil {
		return
	}
	if err := q.ProposeRegression(ctx, t.Key, key, truncate(strings.TrimSpace(a.RegressionOf.Reason), 1000), a.RegressionOf.Confidence); err != nil {
		o.log.Warn("propose regression", "ticket", t.Key, "err", err)
	}
}

// Regressions lists the workspace's regressions for the owner.
func (o *Orchestrator) Regressions(ctx context.Context) ([]domain.Regression, error) {
	q, err := o.quality()
	if err != nil {
		return nil, err
	}
	if _, err := o.perfEnabled(ctx); err != nil {
		return nil, err
	}
	return q.Regressions(ctx)
}

// Regression decisions.
const (
	RegressionConfirm = "confirm"
	RegressionDismiss = "dismiss"
	RegressionSet     = "set"
)

// DecideRegression confirms or dismisses a proposed regression of bug, or
// sets one the owner knows of (origin). Only confirmed ones count.
func (o *Orchestrator) DecideRegression(ctx context.Context, bug, decision string, id int64, origin, reason string, by int64) (domain.Regression, error) {
	q, err := o.quality()
	if err != nil {
		return domain.Regression{}, err
	}
	if _, err := o.perfEnabled(ctx); err != nil {
		return domain.Regression{}, err
	}
	var g domain.Regression
	switch decision {
	case RegressionConfirm, RegressionDismiss:
		if id <= 0 {
			return g, invalid("name the proposed regression")
		}
		status := domain.RelActive
		if decision == RegressionDismiss {
			status = domain.RelDismissed
		}
		g, err = q.DecideRegression(ctx, bug, id, status, by)
	case RegressionSet:
		if strings.TrimSpace(origin) == "" {
			return g, invalid("name the ticket it is a regression of")
		}
		g, err = q.SetRegression(ctx, bug, strings.TrimSpace(origin), strings.TrimSpace(reason), by)
	default:
		return g, invalid("decision must be confirm, dismiss or set")
	}
	if errors.Is(err, domain.ErrPerfInvalid) {
		return g, invalid("%s", strings.TrimPrefix(err.Error(), domain.ErrPerfInvalid.Error()+": "))
	}
	if err == nil {
		o.event(ctx, domain.Event{TicketKey: bug, Type: domain.EventTicketUpdated, Origin: domain.OriginWeb,
			Message: fmt.Sprintf("regression of %s %s", g.Origin, map[string]string{RegressionConfirm: "confirmed", RegressionDismiss: "dismissed", RegressionSet: "set"}[decision]),
			Data:    map[string]any{"regressionOf": g.Origin, "decision": decision, "by": by}})
	}
	return g, err
}

// OverrideScore sets or clears the owner's override of a delivery's
// score. Every change is logged on the ticket with who and why.
func (o *Orchestrator) OverrideScore(ctx context.Context, key string, delivery int, points *int, reason string, by int64) (DeveloperTicket, error) {
	q, err := o.quality()
	if err != nil {
		return DeveloperTicket{}, err
	}
	pc, err := o.periodStore()
	if err != nil {
		return DeveloperTicket{}, err
	}
	if _, err := o.perfEnabled(ctx); err != nil {
		return DeveloperTicket{}, err
	}
	reason = strings.TrimSpace(reason)
	if points != nil {
		if *points != 0 && !perfreview.OnScale(*points) {
			return DeveloperTicket{}, invalid("points must be 0, 1, 2, 3, 5, 8 or 13")
		}
		if reason == "" {
			return DeveloperTicket{}, invalid("say why the score changes")
		}
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return DeveloperTicket{}, err
	}
	if err := q.SetScoreOverride(ctx, t.ID, delivery, points, reason, by); err != nil {
		return DeveloperTicket{}, err
	}
	msg := fmt.Sprintf("score of delivery %d overridden", delivery)
	data := map[string]any{"delivery": delivery, "by": by, "reason": reason}
	if points != nil {
		msg += fmt.Sprintf(" to %d: %s", *points, reason)
		data["points"] = *points
	} else {
		msg = fmt.Sprintf("override of delivery %d's score cleared", delivery)
	}
	o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: domain.OriginWeb, Message: msg, Data: data})
	sr := o.scoreRuns()
	if sr == nil {
		return DeveloperTicket{}, errors.New("performance reviews are not available on this server")
	}
	d, err := sr.DeliveryOf(ctx, t.ID, delivery)
	if err != nil {
		return DeveloperTicket{}, err
	}
	scores, err := pc.DeliveryScores(ctx, d.DeliveredAt, d.DeliveredAt.Add(time.Microsecond), versionAt(ctx, pc, time.Now()), "")
	if err != nil {
		return DeveloperTicket{}, err
	}
	for _, dt := range o.developerTickets(ctx, pc, "", scores) {
		if dt.TicketID == t.ID && dt.Delivery == delivery {
			return dt, nil
		}
	}
	return DeveloperTicket{}, domain.ErrNotFound
}
