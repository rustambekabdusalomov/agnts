package ciwatch

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// outcome is what recording one failed job did to its group.
type outcome struct {
	f        domain.CIFailure
	isNew    bool
	changed  bool // false: this run was already recorded
	rerun    bool // the group is new and waits for a re-run
	became   domain.CIStatus
	previous domain.CIStatus
}

// triage records the failed jobs of a run on a watched branch (pr == 0) or
// on someone's pull request, then re-runs, opens tickets or comments.
func (s *Service) triage(ctx context.Context, st domain.Settings, watch domain.CIWatch, repo domain.Repository, run domain.CIRun, pr int) error {
	fs, err := s.failures(ctx, st, &watch, repo, run)
	if err != nil {
		return err
	}
	if len(fs) == 0 {
		return nil
	}
	retry := st.CI.RetryFlaky && pr == 0
	var outs []outcome
	for _, f := range fs {
		o, err := s.record(ctx, repo, run, f, pr, retry)
		if err != nil {
			return err
		}
		outs = append(outs, o)
	}
	if pr != 0 {
		return s.comment(ctx, repo, run, pr, fs, outs)
	}
	rerun := false
	for _, o := range outs {
		rerun = rerun || o.rerun
	}
	if rerun {
		if err := s.host.RerunFailed(ctx, repo, run.RunID); err != nil {
			// No permission to re-run (or the host refused): believe the failure.
			s.log.Warn("ci re-run", "repo", repo.Name, "run", run.RunID, "err", err)
			for i, o := range outs {
				if o.rerun {
					if outs[i].f, err = s.setStatus(ctx, o.f.ID, domain.CIOpen, ""); err != nil {
						return err
					}
					outs[i].became = domain.CIOpen
				}
			}
		} else {
			return nil // the re-run's result decides
		}
	}
	for _, o := range outs {
		if !o.changed {
			continue
		}
		switch o.became {
		case domain.CIOpen:
			if o.previous != domain.CIOpen {
				s.announce(ctx, o.f, repo, "")
			}
			if err := s.autoFix(ctx, st, watch, repo, o.f); err != nil {
				s.log.Warn("ci auto-fix", "failure", o.f.ID, "err", err)
			}
		case domain.CIRegression:
			if o.previous != domain.CIRegression {
				s.announce(ctx, o.f, repo, "regression")
			}
		case domain.CIInfra:
			if o.isNew {
				s.announce(ctx, o.f, repo, "infra")
			}
		}
	}
	return nil
}

// record adds one failed job to its group and decides the group's status.
func (s *Service) record(ctx context.Context, repo domain.Repository, run domain.CIRun, fl failure, pr int, retry bool) (outcome, error) {
	var o outcome
	occ := domain.CIOccurrence{RunID: run.RunID, URL: firstNonEmpty(fl.job.URL, run.URL), SHA: run.SHA, Job: fl.job.QualifiedName(), At: run.Finished}
	if occ.At.IsZero() {
		occ.At = time.Now()
	}
	key := domain.CIFailure{RepoID: repo.ID, Branch: run.Branch, Workflow: run.Workflow, Fingerprint: fl.fingerprint,
		Job: fl.job.QualifiedName(), Title: fl.title, PRNumber: pr}
	if pr != 0 {
		key.Branch = fmt.Sprintf("pr/%d", pr) // other people's branches never mix with watched ones
	}
	regression := false
	if fl.infra == "" {
		if prev, err := s.store.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID, Branch: key.Branch, Workflow: key.Workflow,
			Statuses: []domain.CIStatus{domain.CIFixed}}); err == nil {
			for _, p := range prev {
				if p.Fingerprint == fl.fingerprint {
					regression = s.isRegression(ctx, repo, p, run)
				}
			}
		}
	}
	f, err := s.store.UpsertCIFailure(ctx, key, fl.excerpt, func(f *domain.CIFailure, isNew bool) error {
		o.isNew, o.previous = isNew, f.Status
		if isNew {
			o.previous = "" // a new group is announced once it is confirmed
		}
		// The same run seen again: a duplicate, or (same run, finished
		// later) the re-run of a group waiting in triage.
		for _, x := range f.Occurrences {
			if x.RunID != run.RunID {
				continue
			}
			if f.Status == domain.CITriage && occ.At.After(x.At) {
				f.Status, f.Class = domain.CIOpen, classOf(f.Class)
				f.LastSeenAt = time.Now()
				o.changed, o.became = true, domain.CIOpen
			}
			return nil
		}
		o.changed = true
		if !isNew {
			f.Count++
		} else {
			f.FirstSHA = run.SHA
		}
		f.Occurrences = append(f.Occurrences, occ)
		f.LastSeenAt, f.LastSHA, f.Title = occ.At, run.SHA, fl.title
		switch {
		case fl.infra != "":
			if isNew || !f.Status.Active() {
				f.Status, f.Class = domain.CIInfra, domain.CIClassInfra
			}
		case isNew, f.Status == domain.CIFlaky, f.Status == domain.CIResolved:
			// New, or back: believe it only after a re-run fails too.
			if retry && run.Attempt <= 1 {
				f.Status = domain.CITriage
				o.rerun = true
			} else {
				f.Status = domain.CIOpen
			}
		case f.Status == domain.CIFixed && regression:
			f.Status = domain.CIRegression
		case f.Status == domain.CIInfra:
			// The code changed under an infra group? Not likely: it stays.
		}
		if f.Status == domain.CIOpen && f.Class == domain.CIClassFlaky {
			f.Class = ""
		}
		o.became = f.Status
		return nil
	})
	o.f = f
	return o, err
}

func classOf(c string) string {
	if c == domain.CIClassFlaky {
		return ""
	}
	return c
}

func firstNonEmpty(ss ...string) string {
	for _, s := range ss {
		if s != "" {
			return s
		}
	}
	return ""
}

// isRegression decides whether a fixed group failing again on run is a
// regression: the failing commit contains the fix, or (squash merges, an
// unknown commit) the run finished well after the fix was merged.
func (s *Service) isRegression(ctx context.Context, repo domain.Repository, f domain.CIFailure, run domain.CIRun) bool {
	if f.FixedSHA != "" && run.SHA != "" && s.ancestry != nil {
		if ok, err := s.ancestry.IsAncestor(ctx, repo, f.FixedSHA, run.SHA); err == nil {
			return ok
		}
	}
	return f.FixedAt != nil && run.Finished.After(f.FixedAt.Add(30*time.Minute))
}

func (s *Service) setStatus(ctx context.Context, id int64, st domain.CIStatus, class string) (domain.CIFailure, error) {
	return s.store.UpdateCIFailure(ctx, id, func(f *domain.CIFailure) error {
		f.Status = st
		if class != "" {
			f.Class = class
		}
		return nil
	})
}

// passed handles a green run: a re-run that passed makes its groups flaky;
// any green run on a branch resolves the groups of that workflow there.
func (s *Service) passed(ctx context.Context, repo domain.Repository, run domain.CIRun) error {
	branches := []string{run.Branch}
	for _, pr := range run.PRNumbers {
		branches = append(branches, fmt.Sprintf("pr/%d", pr))
	}
	var groups []domain.CIFailure
	for _, br := range branches {
		gs, err := s.store.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID, Branch: br, Workflow: run.Workflow,
			Statuses: []domain.CIStatus{domain.CITriage, domain.CIOpen, domain.CIFixed, domain.CIRegression, domain.CIInfra}})
		if err != nil {
			return err
		}
		groups = append(groups, gs...)
	}
	var err error
	for _, g := range groups {
		last, _ := g.LastRun()
		switch {
		case g.Status == domain.CITriage && last.RunID == run.RunID:
			_, err = s.store.UpdateCIFailure(ctx, g.ID, func(f *domain.CIFailure) error {
				f.Status, f.Class = domain.CIFlaky, domain.CIClassFlaky
				f.FlakyCount++
				if n := len(f.Occurrences); n > 0 {
					f.Occurrences[n-1].Flaky = true
				}
				return nil
			})
			if err == nil {
				s.log.Info("ci: flaky, passed on re-run", "repo", repo.Name, "failure", g.ID, "title", g.Title)
			}
		case g.Status == domain.CITriage:
			// Waiting for another run's re-run: leave it.
		case g.Status == domain.CIOpen && g.TicketKey != "":
			// A report or a rejected ticket: the branch is green now anyway.
			_, err = s.setStatus(ctx, g.ID, domain.CIResolved, "")
		default:
			_, err = s.setStatus(ctx, g.ID, domain.CIResolved, "")
		}
		if err != nil {
			return err
		}
	}
	return nil
}

// announce writes the event the notifier and the live UI hear.
func (s *Service) announce(ctx context.Context, f domain.CIFailure, repo domain.Repository, what string) {
	msg := fmt.Sprintf("%s is red on %s: %s", repo.Name, f.Branch, f.Title)
	switch what {
	case "regression":
		msg = fmt.Sprintf("%s: a fixed CI failure is back on %s: %s", repo.Name, f.Branch, f.Title)
	case "infra":
		msg = fmt.Sprintf("%s: CI failed on %s for a reason outside the code: %s", repo.Name, f.Branch, f.Title)
	}
	ev := domain.Event{Type: domain.EventCIFailure, Origin: domain.OriginWebhook, Level: domain.LevelWarn, Message: msg,
		TicketKey: f.TicketKey,
		Data: map[string]any{"failureId": f.ID, "repo": repo.Name, "branch": f.Branch, "title": f.Title, "status": string(f.Status),
			"notify": what != "infra", "kind": what}}
	if err := s.tickets.AppendEvent(ctx, ev); err != nil {
		s.log.Warn("ci event", "err", err)
	}
}

// autoFix opens a ticket for an open group when the policy allows.
func (s *Service) autoFix(ctx context.Context, st domain.Settings, watch domain.CIWatch, repo domain.Repository, f domain.CIFailure) error {
	auto := st.CI.AutoFix
	if watch.AutoFix != nil {
		auto = *watch.AutoFix
	}
	if !auto || f.Status != domain.CIOpen || f.TicketKey != "" || f.PRNumber != 0 {
		return nil
	}
	day := time.Now().Truncate(24 * time.Hour)
	n, err := s.store.AutoCITickets(ctx, day)
	if err != nil {
		return err
	}
	if n >= st.CI.MaxAutoPerDay {
		s.log.Info("ci: daily budget reached, the failure waits for Fix it", "failure", f.ID, "budget", st.CI.MaxAutoPerDay)
		return nil
	}
	_, err = s.openTicket(ctx, repo, f, domain.OriginWebhook)
	return err
}

// FixIt opens a ticket for a group now, whatever the settings and budget.
func (s *Service) FixIt(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error) {
	f, err := s.store.CIFailure(ctx, id)
	if err != nil {
		return domain.Ticket{}, err
	}
	if f.PRNumber != 0 {
		return domain.Ticket{}, invalid("this failure is on someone else's pull request: agnts only comments there")
	}
	if f.TicketKey != "" {
		if t, err := s.tickets.TicketByKey(ctx, f.TicketKey); err == nil && !t.State.Terminal() {
			return t, invalid("%s is already working on it", t.Key)
		}
	}
	repo, err := s.tickets.RepositoryByID(ctx, f.RepoID)
	if err != nil {
		return domain.Ticket{}, err
	}
	return s.openTicket(ctx, repo, f, origin)
}

func (s *Service) openTicket(ctx context.Context, repo domain.Repository, f domain.CIFailure, origin domain.Origin) (domain.Ticket, error) {
	if f.Sample == "" {
		if full, err := s.store.CIFailure(ctx, f.ID); err == nil {
			f = full
		}
	}
	prio := "high"
	if f.Branch == repo.DefaultBranch {
		prio = "highest"
	}
	t, err := s.work.CreateCITicket(ctx, orchestrator.CITicketInput{RepoID: repo.ID, Title: ticketTitle(f), Description: Description(repo, f),
		Priority: prio, Log: f.Sample}, origin)
	if err != nil {
		return t, err
	}
	_, err = s.store.UpdateCIFailure(ctx, f.ID, func(x *domain.CIFailure) error {
		x.TicketKey, x.Status = t.Key, domain.CIFixing
		return nil
	})
	return t, err
}

func ticketTitle(f domain.CIFailure) string {
	return fmt.Sprintf("Fix CI on %s: %s", f.Branch, f.Title)
}

// Description is a CI ticket's description: where it fails and the error.
func Description(repo domain.Repository, f domain.CIFailure) string {
	var b strings.Builder
	fmt.Fprintf(&b, "CI fails on **%s** of %s.\n\n", f.Branch, repo.Name)
	fmt.Fprintf(&b, "- Workflow: %s, job: %s\n", f.Workflow, f.Job)
	fmt.Fprintf(&b, "- Failing since commit %s (%s), %d failing runs, last on %s\n", short(f.FirstSHA), f.FirstSeenAt.UTC().Format("2006-01-02 15:04 MST"), f.Count, short(f.LastSHA))
	if last, ok := f.LastRun(); ok {
		fmt.Fprintf(&b, "- Last failing run: %s\n", last.URL)
	}
	if f.Branch != repo.DefaultBranch {
		fmt.Fprintf(&b, "\nThis branch is not %s: agnts's fixes branch off %s, so diagnose the failure and write a report with the fix instead of changing code here.\n", repo.DefaultBranch, repo.DefaultBranch)
	}
	if f.Sample != "" {
		block := f.Sample
		if i := strings.Index(block, "\n\n=== end of the log ==="); i > 0 {
			block = block[:i]
		}
		b.WriteString("\nThe first error in the log (redacted; the whole excerpt is attached as ci-log.txt):\n\n```\n")
		b.WriteString(limit(strings.TrimPrefix(block, "=== first error ===\n"), 4000))
		b.WriteString("\n```\n")
	}
	return b.String()
}

// TicketMerged implements orchestrator.CIHook: the fix of a CI ticket was
// merged, so its group waits for a green run.
func (s *Service) TicketMerged(ctx context.Context, t domain.Ticket) {
	if t.Source != domain.SourceCI {
		return
	}
	f, err := s.store.CIFailureByTicket(ctx, t.Key)
	if err != nil {
		return
	}
	now := time.Now()
	_, err = s.store.UpdateCIFailure(ctx, f.ID, func(x *domain.CIFailure) error {
		if x.Status == domain.CIResolved {
			return nil // already green
		}
		x.Status, x.FixedSHA, x.FixedAt = domain.CIFixed, t.HeadSHA, &now
		return nil
	})
	if err != nil {
		s.log.Warn("ci: mark fixed", "ticket", t.Key, "err", err)
	}
}

// Sync follows the tickets of groups being fixed: a rejected ticket gives
// the group back (open, so Fix it works again), a finished report keeps
// it open with the report as its ticket, so it is not reopened by itself.
func (s *Service) Sync(ctx context.Context) error {
	groups, err := s.store.ListCIFailures(ctx, domain.CIFilter{Statuses: []domain.CIStatus{domain.CIFixing}})
	if err != nil {
		return err
	}
	for _, g := range groups {
		t, err := s.tickets.TicketByKey(ctx, g.TicketKey)
		gone := errors.Is(err, domain.ErrNotFound)
		if err != nil && !gone {
			continue
		}
		switch {
		case gone, t.State == domain.StateRejected:
			_, err = s.store.UpdateCIFailure(ctx, g.ID, func(f *domain.CIFailure) error {
				f.Status = domain.CIOpen
				if gone {
					f.TicketKey = ""
				}
				return nil
			})
		case t.State == domain.StateDone && t.PRNumber == nil && t.Kind.Report():
			_, err = s.store.UpdateCIFailure(ctx, g.ID, func(f *domain.CIFailure) error {
				f.Status = domain.CIOpen
				if f.Class == "" {
					f.Class = "report"
				}
				return nil
			})
		}
		if err != nil {
			s.log.Warn("ci sync", "failure", g.ID, "err", err)
		}
	}
	return nil
}

// Mute stops a group from making tickets or notifications; Unmute opens it.
func (s *Service) Mute(ctx context.Context, id int64, mute bool) (domain.CIFailure, error) {
	return s.store.UpdateCIFailure(ctx, id, func(f *domain.CIFailure) error {
		switch {
		case mute:
			f.Status = domain.CIMuted
		case f.Status == domain.CIMuted:
			f.Status = domain.CIOpen
		}
		return nil
	})
}

// Rerun re-runs the failed jobs of a group's newest run.
func (s *Service) Rerun(ctx context.Context, id int64) error {
	f, err := s.store.CIFailure(ctx, id)
	if err != nil {
		return err
	}
	last, ok := f.LastRun()
	if !ok {
		return invalid("no run to re-run")
	}
	repo, err := s.tickets.RepositoryByID(ctx, f.RepoID)
	if err != nil {
		return err
	}
	return s.host.RerunFailed(ctx, repo, last.RunID)
}

// List returns groups; Get one with its log sample.
func (s *Service) List(ctx context.Context, f domain.CIFilter) ([]domain.CIFailure, error) {
	return s.store.ListCIFailures(ctx, f)
}

// Get returns one group with its log sample.
func (s *Service) Get(ctx context.Context, id int64) (domain.CIFailure, error) {
	return s.store.CIFailure(ctx, id)
}

// ForTicket returns the group a CI ticket fixes.
func (s *Service) ForTicket(ctx context.Context, key string) (domain.CIFailure, error) {
	return s.store.CIFailureByTicket(ctx, key)
}

// Watch returns a repository's watch.
func (s *Service) Watch(ctx context.Context, repoID int64) (domain.CIWatch, error) {
	if _, err := s.tickets.RepositoryByID(ctx, repoID); err != nil {
		return domain.CIWatch{}, err
	}
	return s.store.CIWatch(ctx, repoID)
}

// SetWatch saves a repository's watch.
func (s *Service) SetWatch(ctx context.Context, w domain.CIWatch) (domain.CIWatch, error) {
	if err := w.Normalize(); err != nil {
		return w, invalid("%v", err)
	}
	cur, err := s.Watch(ctx, w.RepoID)
	if err != nil {
		return w, err
	}
	w.LastPolledRun = cur.LastPolledRun
	if !w.Enabled {
		w.LastPolledRun = 0 // a new watch starts from the newest run, not history
	}
	return s.store.SaveCIWatch(ctx, w)
}

// statusesOpen are the groups that still need attention.
var statusesOpen = []domain.CIStatus{domain.CIOpen, domain.CIFixing, domain.CIRegression, domain.CITriage}

// Red returns the repositories' branches that are red now, for the MCP
// "why is main red?" question: the groups that still need attention.
func (s *Service) Red(ctx context.Context, repoID int64) ([]domain.CIFailure, error) {
	out, err := s.store.ListCIFailures(ctx, domain.CIFilter{RepoID: repoID, Statuses: statusesOpen})
	if err != nil {
		return nil, err
	}
	slices.SortStableFunc(out, func(a, b domain.CIFailure) int { return b.LastSeenAt.Compare(a.LastSeenAt) })
	return out, nil
}

// Problem says why agnts cannot read a repository's CI with the current
// git token ("" when it can).
func (s *Service) Problem(ctx context.Context, repoID int64) string {
	repo, err := s.tickets.RepositoryByID(ctx, repoID)
	if err != nil {
		return ""
	}
	if _, err := s.host.CIRuns(ctx, repo, 1); err != nil {
		return err.Error()
	}
	return ""
}

// TicketStates returns the states of the tickets fixing these groups.
func (s *Service) TicketStates(ctx context.Context, fs []domain.CIFailure) map[string]domain.TicketState {
	out := map[string]domain.TicketState{}
	for _, f := range fs {
		if f.TicketKey == "" {
			continue
		}
		if _, ok := out[f.TicketKey]; ok {
			continue
		}
		if t, err := s.tickets.TicketByKey(ctx, f.TicketKey); err == nil {
			out[f.TicketKey] = t.State
		}
	}
	return out
}
