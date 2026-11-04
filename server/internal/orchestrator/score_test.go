package orchestrator_test

import (
	"context"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type fakeScoreHost struct {
	pulls   map[int][]domain.FileChange
	commits map[string][]domain.FileChange
}

func (f *fakeScoreHost) PullFiles(_ context.Context, _ domain.Repository, n int) ([]domain.FileChange, error) {
	return f.pulls[n], nil
}

func (f *fakeScoreHost) CommitFiles(_ context.Context, _ domain.Repository, sha string) ([]domain.FileChange, error) {
	return f.commits[sha], nil
}

// A delivery after the workspace started scoring is scored on its own:
// the model's answer within the facts' ceiling, its points split by
// commit days. One from before waits for a backfill.
func TestScoreDelivery(t *testing.T) {
	h := newHarness(t)
	h.settings.s.PerfReview.Enabled = true
	host := &fakeScoreHost{pulls: map[int][]domain.FileChange{
		7: {{Path: "internal/queue/claim.go", Add: 30, Del: 6, Diff: "@@ -1,6 +1,30 @@\n+\tvar mu sync.Mutex\n"}, {Path: "go.sum", Add: 300}},
	}}
	h.o.SetScoreHost(host)
	sys := domain.System(context.Background())
	repo, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	deliver := func(key string, shas ...string) domain.Ticket {
		t.Helper()
		tk, err := h.store.CreateTicket(h.ctx, domain.Ticket{Key: key, Source: domain.SourceJira, Kind: domain.KindCode, RepoID: &repo.ID,
			Title: "Fix " + key, Priority: "medium", State: domain.StateWaitingForAnswers, ResumeState: domain.StateNew, AfterApprove: "pr"},
			domain.Event{TicketKey: key, Type: domain.EventTicketCreated})
		if err != nil {
			t.Fatal(err)
		}
		pr := 7
		day := time.Now().Add(-48 * time.Hour)
		var links []domain.CommitLink
		for i, sha := range shas {
			login := "alice"
			if i == len(shas)-1 {
				login = "bob"
			}
			links = append(links, domain.CommitLink{TicketID: tk.ID, RepoID: repo.ID, SHA: sha, Branch: "feature/" + key, Subject: "work " + sha,
				Author: login, AuthorLogin: login, AuthorEmail: login + "@x.io", CommittedAt: day.Add(time.Duration(i) * 24 * time.Hour),
				MatchedOn: []string{domain.MatchBranch}, Token: strings.ToLower(key)})
		}
		if _, err := h.store.UpsertCommitLinks(h.ctx, links); err != nil {
			t.Fatal(err)
		}
		var facts []domain.DefaultCommit
		for _, sha := range shas {
			facts = append(facts, domain.DefaultCommit{SHA: sha, At: time.Now(), PRNumber: &pr})
		}
		if err := h.store.MarkOnDefault(h.ctx, repo.ID, facts); err != nil {
			t.Fatal(err)
		}
		now := time.Now()
		if err := h.store.SetTrackerResolution(h.ctx, domain.SourceJira, key, &now, "Done"); err != nil {
			t.Fatal(err)
		}
		return tk
	}

	old := deliver("PAY-20", "o1")
	h.o.PerfTick(sys) // the first tick starts scoring: what was delivered before waits
	h.idle()

	tk := deliver("PAY-21", "a1", "a2", "b1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.ScorePath: `{"points": 13, "rationale": "A race fix.", "factors": ["locking"]}`}}}
	h.o.PerfTick(sys)
	h.step()
	h.idle()

	var points int
	var clamped bool
	var source, rationale string
	if err := h.pool.QueryRow(sys, `SELECT points, clamped, diff_source, rationale FROM ticket_scores WHERE ticket_id = $1`, tk.ID).
		Scan(&points, &clamped, &source, &rationale); err != nil {
		t.Fatal(err)
	}
	// 36 lines touching concurrency: facts 2, ceiling three steps up (8).
	if points != 8 || !clamped || source != "api:pull_request" || rationale != "A race fix." {
		t.Fatalf("score: %d clamped=%v %s %q", points, clamped, source, rationale)
	}
	rows, err := h.pool.Query(sys, `SELECT author_key, share FROM ticket_score_authors WHERE ticket_id = $1 ORDER BY author_key`, tk.ID)
	if err != nil {
		t.Fatal(err)
	}
	var keys []string
	for rows.Next() {
		var k string
		var share float64
		if err := rows.Scan(&k, &share); err != nil {
			t.Fatal(err)
		}
		keys = append(keys, k)
	}
	rows.Close()
	if strings.Join(keys, ",") != "unmapped:alice,unmapped:bob" {
		t.Fatalf("authors: %v", keys)
	}
	if !strings.Contains(h.runner.prompts[len(h.runner.prompts)-1], "Score the diff, not the words") {
		t.Fatal("the scoring prompt was not used")
	}
	var n int
	_ = h.pool.QueryRow(sys, `SELECT count(*) FROM ticket_scores WHERE ticket_id = $1`, old.ID).Scan(&n)
	if n != 0 {
		t.Fatal("a delivery from before scoring started was scored on its own")
	}

	// The backfill estimates first, then scores it when confirmed.
	est, err := h.o.BackfillScores(h.ctx, nil, false)
	if err != nil || est.Deliveries != 1 || est.Queued != 0 || est.CostUSD <= 0 {
		t.Fatalf("estimate: %+v %v", est, err)
	}
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.ScorePath: `{"points": 1, "rationale": "Small."}`}}}
	if est, err = h.o.BackfillScores(h.ctx, nil, true); err != nil || est.Queued != 1 {
		t.Fatalf("backfill: %+v %v", est, err)
	}
	h.step()
	if err := h.pool.QueryRow(sys, `SELECT points FROM ticket_scores WHERE ticket_id = $1`, old.ID).Scan(&points); err != nil || points != 1 {
		t.Fatalf("backfilled: %d %v", points, err)
	}

	// A model that writes nothing is tried twice more, then the delivery
	// shows as unscored.
	bad := deliver("PAY-22", "c1")
	h.runner.scripts = []script{{result: ok("s3")}, {result: ok("s4")}, {result: ok("s5")}}
	h.o.PerfTick(sys)
	h.step()
	h.step()
	h.step()
	h.idle()
	var status, msg string
	if err := h.pool.QueryRow(sys, `SELECT status, error FROM ticket_scores WHERE ticket_id = $1`, bad.ID).Scan(&status, &msg); err != nil ||
		status != domain.ScoreUnscored || !strings.Contains(msg, "did not write") {
		t.Fatalf("unscored: %s %q %v", status, msg, err)
	}
}
