package orchestrator_test

import (
	"context"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/perfreview"
	"agnts/internal/store/postgres/pgtest"
)

// The Developers tab end to end: a scored delivery last month, closing
// it, mapping an identity (the closed month shows the change), closing
// again, an override, a confirmed regression, and the export.
func TestDevelopersReport(t *testing.T) {
	h := newHarness(t)
	h.settings.s.PerfReview.Enabled = true
	h.o.SetScoreHost(&fakeScoreHost{pulls: map[int][]domain.FileChange{
		3: {{Path: "billing/charge.go", Add: 120, Del: 20, Diff: "@@ -1 +1 @@\n+x\n"}},
	}})
	owner := pgtest.User(t, h.pool, "orch-owner")
	repo, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	last := perfreview.MonthOf(perfreview.MonthOf(time.Now(), time.UTC).Start.Add(-time.Hour), time.UTC)
	at := last.Start.Add(10 * 24 * time.Hour)

	tk, err := h.store.CreateTicket(h.ctx, domain.Ticket{Key: "PAY-30", Source: domain.SourceJira, Kind: domain.KindCode, RepoID: &repo.ID,
		Title: "Charge in two steps", Priority: "medium", State: domain.StateWaitingForAnswers, ResumeState: domain.StateNew, AfterApprove: "pr"},
		domain.Event{TicketKey: "PAY-30", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	pr := 3
	if _, err := h.store.UpsertCommitLinks(h.ctx, []domain.CommitLink{{TicketID: tk.ID, RepoID: repo.ID, SHA: "w1", Branch: "f/PAY-30", Subject: "charge",
		Author: "Alice", AuthorLogin: "alice-gh", AuthorEmail: "alice@x.io", CommittedAt: at.Add(-time.Hour), MatchedOn: []string{domain.MatchBranch}, Token: "pay-30"}}); err != nil {
		t.Fatal(err)
	}
	if err := h.store.MarkOnDefault(h.ctx, repo.ID, []domain.DefaultCommit{{SHA: "w1", At: at, PRNumber: &pr}}); err != nil {
		t.Fatal(err)
	}
	if err := h.store.SetTrackerResolution(h.ctx, domain.SourceJira, "PAY-30", &at, "Done"); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.ScorePath: `{"points": 5, "rationale": "Money path."}`}}}
	if est, err := h.o.BackfillScores(h.ctx, nil, true); err != nil || est.Queued != 1 {
		t.Fatalf("backfill: %+v %v", est, err)
	}
	h.step()

	rep, err := h.o.Developers(h.ctx, orchestrator.Period{Month: last.Name()})
	if err != nil {
		t.Fatal(err)
	}
	if !rep.Live || len(rep.Rows) != 1 || rep.Rows[0].Key != "unmapped:alice-gh" || rep.Rows[0].Kind != orchestrator.AuthorUnmapped ||
		rep.Rows[0].Points != 5 || rep.ClosesOn == nil {
		t.Fatalf("live report: %+v", rep)
	}

	// Close it: the snapshot shows.
	rep, err = h.o.CloseMonth(h.ctx, last.Name(), owner)
	if err != nil || rep.Live || rep.Closing == nil || rep.Closing.Closing != 1 || rep.Changed {
		t.Fatalf("closed: %+v %v", rep, err)
	}
	// Mapping alice moves the points to the owner: the closed month
	// shows a change, not new numbers.
	if err := h.o.MapGitIdentity(h.ctx, owner, "alice-gh", "", false); err != nil {
		t.Fatal(err)
	}
	rep, _ = h.o.Developers(h.ctx, orchestrator.Period{Month: last.Name()})
	if !rep.Changed || len(rep.Rows) != 2 {
		t.Fatalf("after mapping: %+v", rep)
	}
	for _, r := range rep.Rows {
		switch r.Kind {
		case orchestrator.AuthorUnmapped:
			if r.Points != 5 || r.Live == nil || r.Live.Points != 0 {
				t.Fatalf("unmapped row: %+v", r)
			}
		case orchestrator.AuthorUser:
			if r.UserID != owner || r.Live == nil || r.Live.Points != 5 {
				t.Fatalf("member row: %+v", r)
			}
		}
	}
	// Re-close: a second closing, the first kept.
	rep, err = h.o.CloseMonth(h.ctx, last.Name(), owner)
	if err != nil || rep.Closing.Closing != 2 || len(rep.Closings) != 2 || rep.Changed || len(rep.Rows) != 1 || rep.Rows[0].UserID != owner {
		t.Fatalf("re-closed: %+v %v", rep, err)
	}
	first, _ := h.o.Developers(h.ctx, orchestrator.Period{Month: last.Name(), Closing: 1})
	if first.Rows[0].Kind != orchestrator.AuthorUnmapped {
		t.Fatalf("an earlier closing: %+v", first)
	}

	// The owner overrides the score, with a reason.
	if _, err := h.o.OverrideScore(h.ctx, "PAY-30", 1, intp(13), "", owner); err == nil {
		t.Fatal("an override without a reason")
	}
	dt, err := h.o.OverrideScore(h.ctx, "PAY-30", 1, intp(8), "The rollback logic was the hard part", owner)
	if err != nil || dt.Effective() != 8 || dt.Points != 5 {
		t.Fatalf("override: %+v %v", dt, err)
	}

	// A bug filed after the delivery, confirmed as its regression, takes
	// 30% of what is left; analysing the bug again keeps it.
	bug, err := h.store.CreateTicket(h.ctx, domain.Ticket{Key: "PAY-31", Source: domain.SourceJira, Kind: domain.KindBug, RepoID: &repo.ID,
		Title: "Double charge", Priority: "high", State: domain.StateWaitingForAnswers, ResumeState: domain.StateNew, AfterApprove: "pr"},
		domain.Event{TicketKey: "PAY-31", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := h.pool.Exec(domain.System(context.Background()), `UPDATE tickets SET created_at = $2 WHERE id = $1`, bug.ID, at.Add(48*time.Hour)); err != nil {
		t.Fatal(err)
	}
	if err := h.store.ProposeRegression(h.ctx, "PAY-31", "PAY-30", "charge.go retries without an idempotency key", 0.7); err != nil {
		t.Fatal(err)
	}
	regs, err := h.o.Regressions(h.ctx)
	if err != nil || len(regs) != 1 || regs[0].Status != "proposed" || regs[0].Counts {
		t.Fatalf("proposed: %+v %v", regs, err)
	}
	if g, err := h.o.DecideRegression(h.ctx, "PAY-31", orchestrator.RegressionConfirm, regs[0].ID, "", "", owner); err != nil || g.Status != "active" || !g.Counts {
		t.Fatalf("confirm: %+v %v", g, err)
	}
	if _, err := h.store.ReplaceFound(h.ctx, "PAY-31", nil, nil); err != nil {
		t.Fatal(err)
	}
	rep, _ = h.o.Developers(h.ctx, orchestrator.Period{Month: last.Name()})
	if !rep.Changed || rep.Rows[0].Live == nil || rep.Rows[0].Live.Points != 5.6 || rep.Rows[0].Live.Regressions != 1 {
		t.Fatalf("after the regression: %+v", rep.Rows)
	}

	// The member's export has the delivery and both closings' rows.
	ex, err := h.o.ExportMember(h.ctx, perfreview.UserKey(owner))
	if err != nil || len(ex.Tickets) != 1 || ex.Tickets[0].Earned != 5.6 || len(ex.Snapshots) != 1 || ex.Name == "" {
		t.Fatalf("export: %+v %v", ex, err)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-30"})
	logged := false
	for _, e := range evs {
		logged = logged || strings.Contains(e.Message, "overridden to 8")
	}
	if !logged {
		t.Fatal("the override was not logged on the ticket")
	}

	// Off: nothing is shown.
	h.settings.s.PerfReview.Enabled = false
	if _, err := h.o.Developers(h.ctx, orchestrator.Period{Month: last.Name()}); err == nil {
		t.Fatal("the report showed with performance reviews off")
	}
}

func intp(v int) *int { return &v }
