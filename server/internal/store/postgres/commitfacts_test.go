package postgres

import (
	"context"
	"testing"
	"time"

	"agnts/internal/domain"
)

type deliveryRow struct {
	n     int
	at    time.Time
	ended bool
}

func deliveriesOf(t *testing.T, s *Agent, ticketID int64) []deliveryRow {
	t.Helper()
	rows, err := s.db.Query(domain.System(context.Background()), `SELECT delivery, delivered_at, undelivered_at IS NOT NULL FROM ticket_deliveries
		WHERE ticket_id = $1 ORDER BY delivery`, ticketID)
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	var out []deliveryRow
	for rows.Next() {
		var d deliveryRow
		if err := rows.Scan(&d.n, &d.at, &d.ended); err != nil {
			t.Fatal(err)
		}
		out = append(out, d)
	}
	return out
}

// Deliveries are recorded by the database as they happen: done (in
// agnts or the tracker) with a linked commit on a default branch.
func TestDeliveries(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	sys := domain.System(context.Background())

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	newTicket := func(key string, src domain.TicketSource, kind domain.TicketKind) domain.Ticket {
		tk, err := s.CreateTicket(ctx, domain.Ticket{Key: key, Source: src, Kind: kind, RepoID: &repo.ID, Title: "t " + key, Priority: "medium",
			State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{TicketKey: key, Type: domain.EventTicketCreated})
		if err != nil {
			t.Fatal(err)
		}
		return tk
	}
	at := time.Date(2026, 10, 1, 12, 0, 0, 0, time.UTC)
	link := func(tk domain.Ticket, sha string) {
		t.Helper()
		if _, err := s.UpsertCommitLinks(ctx, []domain.CommitLink{{TicketID: tk.ID, RepoID: repo.ID, SHA: sha, Branch: "feature/" + tk.Key,
			Subject: "work", Author: "Alice", CommittedAt: at, MatchedOn: []string{domain.MatchBranch}, Token: tk.Key}}); err != nil {
			t.Fatal(err)
		}
	}

	// agnts's own ticket: done, then its commit reaches the default branch.
	a := newTicket("DL-1", domain.SourceLocal, domain.KindCode)
	link(a, "a1")
	if _, err := s.db.Exec(sys, `UPDATE tickets SET state = 'done' WHERE id = $1`, a.ID); err != nil {
		t.Fatal(err)
	}
	if got := deliveriesOf(t, s, a.ID); len(got) != 0 {
		t.Fatalf("delivered before the default branch: %+v", got)
	}
	merged := time.Now().Add(time.Minute).Truncate(time.Microsecond)
	pr := 5
	if err := s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "A1", At: merged, PRNumber: &pr, AuthorEmail: "alice@x.io"}}); err != nil {
		t.Fatal(err)
	}
	got := deliveriesOf(t, s, a.ID)
	if len(got) != 1 || got[0].n != 1 || !got[0].at.Equal(merged) || got[0].ended {
		t.Fatalf("deliveries: %+v", got)
	}
	// Seen again later: the first sighting stays, nothing new.
	if err := s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "a1", At: merged.Add(time.Hour)}}); err != nil {
		t.Fatal(err)
	}
	links, _, _ := s.CommitLinksOfTicket(ctx, a.ID, 10, 0)
	if len(links) != 1 || links[0].OnDefaultAt == nil || !links[0].OnDefaultAt.Equal(merged) || links[0].PRNumber == nil || links[0].AuthorEmail != "alice@x.io" {
		t.Fatalf("links: %+v", links)
	}
	if got := deliveriesOf(t, s, a.ID); len(got) != 1 {
		t.Fatalf("delivered twice: %+v", got)
	}

	// A Jira ticket people did by hand: the tracker closes it, a reopen
	// ends the delivery, the next close is delivery 2.
	j := newTicket("DL-2", domain.SourceJira, domain.KindCode)
	link(j, "j1")
	if err := s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "j1", At: at}}); err != nil {
		t.Fatal(err)
	}
	closed := time.Date(2026, 10, 3, 9, 0, 0, 0, time.UTC)
	if err := s.SetTrackerResolution(ctx, domain.SourceJira, "DL-2", &closed, "Done"); err != nil {
		t.Fatal(err)
	}
	got = deliveriesOf(t, s, j.ID)
	if len(got) != 1 || !got[0].at.Equal(closed) {
		t.Fatalf("tracker delivery: %+v", got)
	}
	if err := s.SetTrackerResolution(ctx, domain.SourceJira, "DL-2", nil, ""); err != nil {
		t.Fatal(err)
	}
	if got := deliveriesOf(t, s, j.ID); len(got) != 1 || !got[0].ended {
		t.Fatalf("reopen: %+v", got)
	}
	again := time.Now().Add(time.Hour).Truncate(time.Microsecond)
	if err := s.SetTrackerResolution(ctx, domain.SourceJira, "DL-2", &again, "Done"); err != nil {
		t.Fatal(err)
	}
	got = deliveriesOf(t, s, j.ID)
	if len(got) != 2 || got[1].n != 2 || !got[1].at.Equal(again) || got[1].ended {
		t.Fatalf("redelivery: %+v", got)
	}

	// Rejected and review tickets never deliver.
	r := newTicket("DL-3", domain.SourceJira, domain.KindCode)
	link(r, "r1")
	_ = s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "r1", At: at}})
	if _, err := s.db.Exec(sys, `UPDATE tickets SET state = 'rejected' WHERE id = $1`, r.ID); err != nil {
		t.Fatal(err)
	}
	_ = s.SetTrackerResolution(ctx, domain.SourceJira, "DL-3", &closed, "Done")
	rv := newTicket("DL-4", domain.SourceLocal, domain.KindReview)
	link(rv, "v1")
	_, _ = s.db.Exec(sys, `UPDATE tickets SET state = 'done' WHERE id = $1`, rv.ID)
	_ = s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "v1", At: at}})
	if len(deliveriesOf(t, s, r.ID)) != 0 || len(deliveriesOf(t, s, rv.ID)) != 0 {
		t.Fatal("a rejected or review ticket was delivered")
	}

	// Agent commits and pull request lookups.
	if err := s.RecordAgentCommits(ctx, repo.ID, a.ID, []string{"AG1", "ag2"}); err != nil {
		t.Fatal(err)
	}
	mine, err := s.AgentCommitsAmong(ctx, repo.ID, []string{"ag1", "zz"})
	if err != nil || !mine["ag1"] || mine["zz"] {
		t.Fatalf("agent commits: %v %v", mine, err)
	}
	if err := s.SaveCommitPull(ctx, repo.ID, "SQ", domain.CommitPull{Number: 7, Title: "DL-1", Squash: true}); err != nil {
		t.Fatal(err)
	}
	if err := s.SaveCommitPull(ctx, repo.ID, "none", domain.CommitPull{}); err != nil {
		t.Fatal(err)
	}
	cps, err := s.CommitPulls(ctx, repo.ID, []string{"sq", "none", "nope"})
	if err != nil || len(cps) != 2 || cps["sq"].Number != 7 || !cps["sq"].Squash || cps["none"].Number != 0 {
		t.Fatalf("commit pulls: %+v %v", cps, err)
	}
	if err := s.SavePullCommits(ctx, repo.ID, 7, []domain.PushedCommit{{SHA: "B1", Message: "wip\n\nmore", AuthorEmail: "bob@x.io", Date: at}}); err != nil {
		t.Fatal(err)
	}
	pcs, err := s.PullCommitsOf(ctx, repo.ID, 7)
	if err != nil || len(pcs) != 1 || pcs[0].SHA != "b1" || pcs[0].Message != "wip" || pcs[0].AuthorEmail != "bob@x.io" {
		t.Fatalf("pull commits: %+v %v", pcs, err)
	}
}
