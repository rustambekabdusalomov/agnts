package postgres

import (
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestAnalyticsTabs(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "jira", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	base := time.Now().UTC().Add(-3 * time.Hour)
	at := func(m int) time.Time { return base.Add(time.Duration(m) * time.Minute) }
	exec := func(q string, args ...any) {
		t.Helper()
		if _, err := s.db.Exec(ctx, q, args...); err != nil {
			t.Fatal(err)
		}
	}
	ticket := func(key, state string, created time.Time, merged, closed *time.Time) {
		t.Helper()
		exec(`INSERT INTO tickets (key, source, repo_id, title, state, created_at, updated_at, merged_at, closed_at, pr_number, pr_url)
			VALUES ($1, 'jira', $2, $1 || ' title', $3, $4, now(), $5, $6, 7, 'https://github.com/a/api/pull/' || $1)`, key, repo.ID, state, created, merged, closed)
	}
	pushed := func(key string, when time.Time) {
		t.Helper()
		exec(`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ($1, 'state_changed', 'system', '{"to":"done"}', $2)`, key, when)
		exec(`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ($1, 'pr_opened', 'system', '{"number":7}', $2)`, key, when)
	}
	ptr := func(v time.Time) *time.Time { return &v }

	// PAY-1 pushed after 60 min and merged an hour later; PAY-2 pushed after
	// 30 and closed; PAY-3 pushed after 10, still open; OLD-1 open for 8 days.
	ticket("PAY-1", "done", at(0), ptr(at(120)), nil)
	ticket("PAY-2", "done", at(0), nil, ptr(at(90)))
	ticket("PAY-3", "done", at(0), nil, nil)
	ticket("PAY-4", "waiting_for_answers", at(0), nil, nil)
	ticket("OLD-1", "done", time.Now().AddDate(0, 0, -9), nil, nil)
	// A person's review of PAY-1 took 40 of its 60 minutes.
	exec(`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES
		('PAY-1', 'state_changed', 'system', '{"to":"coding"}', $1),
		('PAY-1', 'state_changed', 'system', '{"to":"waiting_for_review"}', $2)`, at(10), at(20))
	pushed("PAY-1", at(60))
	pushed("PAY-2", at(30))
	pushed("PAY-3", at(10))
	pushed("OLD-1", time.Now().AddDate(0, 0, -8))

	// Questions: PAY-1's answered after 20 minutes, PAY-4's waiting.
	exec(`INSERT INTO questions (ticket_id, position, text, created_at, answered_at, answer) VALUES
		((SELECT id FROM tickets WHERE key = 'PAY-1'), 0, 'q', $1, $2, 'a'),
		((SELECT id FROM tickets WHERE key = 'PAY-4'), 0, 'q', $1, NULL, NULL)`, at(0), at(20))
	exec(`INSERT INTO runs (ticket_id, stage, model, started_at) SELECT id, 'analyze', 'sonnet', $1 FROM tickets WHERE key IN ('PAY-1', 'PAY-2', 'PAY-4')`, at(1))

	d, err := s.Delivery(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	c := d.Current
	if c.Opened != 3 || c.Merged != 1 || c.Closed != 1 || c.MergeMin.P50 == nil || *c.MergeMin.P50 < 59 || *c.MergeMin.P50 > 61 {
		t.Fatalf("pull requests: %+v (merge %v)", c, c.MergeMin.P50)
	}
	if c.Pushed != 3 || c.PushedMin.P50 == nil || *c.PushedMin.P50 < 29 || *c.PushedMin.P50 > 31 {
		t.Fatalf("pushed: %d %v", c.Pushed, c.PushedMin.P50)
	}
	if c.MergedTickets != 1 || c.MergedMin.P50 == nil || *c.MergedMin.P50 < 119 || *c.MergedMin.P50 > 121 {
		t.Fatalf("merged: %d %v", c.MergedTickets, c.MergedMin.P50)
	}
	if c.Questions != 2 || c.AskedTickets != 2 || c.AnalyzedTickets != 3 || c.AnswerMin.P50 == nil || *c.AnswerMin.P50 < 19 || *c.AnswerMin.P50 > 21 {
		t.Fatalf("questions: %+v", c)
	}
	if d.Prev.Opened != 1 || d.Unanswered != 1 {
		t.Fatalf("previous opened %d, unanswered %d", d.Prev.Opened, d.Unanswered)
	}
	if len(d.Slowest) != 3 || d.Slowest[0].Key != "PAY-1" || !d.Slowest[0].Merged || d.Slowest[0].ReviewMin < 39 || d.Slowest[0].ReviewMin > 41 {
		t.Fatalf("slowest: %+v", d.Slowest)
	}
	if len(d.Stale) != 1 || d.Stale[0].Key != "OLD-1" || d.Stale[0].Repo != "api" {
		t.Fatalf("stale: %+v", d.Stale)
	}
	var merged, closed int
	for _, x := range d.Days {
		merged += x.Merged
		closed += x.Closed
	}
	if len(d.Days) != 7 || merged != 1 || closed != 1 {
		t.Fatalf("days: %d, merged %d, closed %d", len(d.Days), merged, closed)
	}

	a, err := s.Analytics(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	if a.Current.Merged != 1 || a.Current.Closed != 1 || len(a.Repos) != 1 || a.Repos[0].Merged != 1 || a.Repos[0].Asked != 2 || a.Repos[0].Analyzed != 3 {
		t.Fatalf("overview: %+v repos %+v", a.Current, a.Repos)
	}

	// CI: one code failure fixed by PAY-1 after an hour, one flaky job, one open test failure.
	exec(`INSERT INTO ci_failures (repo_id, branch, workflow, job, fingerprint, class, title, status, flaky_count, first_seen_at, last_seen_at, fixed_at, ticket_key) VALUES
		($1, 'main', 'ci', 'unit', 'a', 'code', 'boom', 'resolved', 0, $2, $2, $3, 'PAY-1'),
		($1, 'main', 'ci', 'e2e', 'b', 'flaky', 'timeout', 'flaky', 4, $2, $3, NULL, ''),
		($1, 'main', 'ci', 'lint', 'c', 'test', 'lint', 'open', 0, $2, $3, NULL, '')`, repo.ID, at(0), at(60))
	h, err := s.CIHealth(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	if !h.Watching || h.Current.Seen != 3 || h.Current.New != 3 || h.Current.Fixed != 1 || h.Current.AutoFixed != 1 || h.Current.Flaky != 1 || h.Open != 1 {
		t.Fatalf("ci: %+v open %d", h.Current, h.Open)
	}
	if h.Current.FixMin.P50 == nil || *h.Current.FixMin.P50 < 59 || *h.Current.FixMin.P50 > 61 {
		t.Fatalf("fix time: %v", h.Current.FixMin.P50)
	}
	if h.ByClass["code"] != 1 || h.ByClass["flaky"] != 1 || len(h.Flakiest) != 1 || h.Flakiest[0].Job != "e2e" || h.Flakiest[0].Flaky != 4 {
		t.Fatalf("by class %v, flakiest %+v", h.ByClass, h.Flakiest)
	}
	if a, err = s.Analytics(ctx, 7, time.UTC); err != nil || a.Flakiest.Job != "e2e" || a.Repos[0].CIFails != 3 {
		t.Fatalf("overview flakiest %+v, repo %+v, %v", a.Flakiest, a.Repos, err)
	}

	// Learning.
	exec(`INSERT INTO lessons (repo_id, ticket_key, slug, title, category, level, summary, created_at, learned_at) VALUES
		($1, 'PAY-1', 'a', 'A', 'testing', 'beginner', 's', $2, $2),
		($1, 'PAY-1', 'b', 'B', 'testing', 'beginner', 's', $2, NULL)`, repo.ID, at(0))
	exec(`INSERT INTO rules (title, body, status, source_ticket) VALUES ('r1', 'b', 'ready', 'PAY-1'), ('r2', 'b', 'suggested', 'PAY-2'), ('r3', 'b', 'ready', '')`)
	exec(`INSERT INTO reflections (ticket_key, source, feedback, status, suggested) VALUES ('PAY-1', 'changes', 'f', 'done', 2)`)
	exec(`INSERT INTO ticket_suggestions (ticket_id, source, type, title, serves, kind, priority, status, decided_at)
		SELECT id, src, typ, 't', 's', 'feature', 'medium', st, CASE WHEN st = 'open' THEN NULL ELSE now() END FROM tickets,
		(VALUES ('analyze', 'prerequisite', 'accepted'), ('review', 'gap', 'dismissed'), ('review', 'gap', 'open')) v(src, typ, st)
		WHERE key = 'PAY-1'`)
	exec(`INSERT INTO reviewer_notes (login, repo_id, kind, note) VALUES ('alice', $1, 'rereview', 'n'), ('alice', $1, 'rereview', 'n'), ('bob', NULL, 'dismissed', 'n')`, repo.ID)
	l, err := s.Learning(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	p := l.Current
	if p.Lessons != 2 || p.LessonsLearned != 1 || p.RulesSuggested != 2 || p.RulesAdopted != 1 || p.RulesManual != 1 ||
		p.Reflections != 1 || p.ReflectionRules != 2 || p.FollowUps != 3 || p.Accepted != 1 || p.Dismissed != 1 || p.ReviewerNotes != 3 {
		t.Fatalf("learning: %+v", p)
	}
	if len(l.Lessons) != 1 || l.Lessons[0].Created != 2 || len(l.FollowUpTypes) != 2 || l.FollowUpTypes[0].Name != "gap" || l.FollowUpTypes[0].Dismissed != 1 {
		t.Fatalf("lessons %+v, types %+v", l.Lessons, l.FollowUpTypes)
	}
	if len(l.Reviewers) != 2 || l.Reviewers[0].Login != "alice" || l.Reviewers[0].Rereview != 2 || len(l.Reviewers[0].Repos) != 1 || len(l.Reviewers[1].Repos) != 0 {
		t.Fatalf("reviewers: %+v", l.Reviewers)
	}
	if a, err = s.Analytics(ctx, 7, time.UTC); err != nil || a.FollowUpsAccepted != 1 || a.FollowUpsDismissed != 1 {
		t.Fatalf("overview follow-ups %d/%d, %v", a.FollowUpsAccepted, a.FollowUpsDismissed, err)
	}
}
