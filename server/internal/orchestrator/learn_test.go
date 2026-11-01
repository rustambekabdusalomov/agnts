package orchestrator_test

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"

	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// newLearnHarness is a harness whose orchestrator has the lessons store.
func newLearnHarness(t *testing.T) (*harness, *postgres.Lessons) {
	t.Helper()
	h := newHarness(t)
	pool, err := postgres.Open(h.ctx, os.Getenv("AGNTS_TEST_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	lessons := postgres.NewLessons(pool)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Providers: aitest.Providers(),
		Store:     h.store, Runner: h.runner, Git: h.git, Host: h.host, Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker}, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage, Lessons: lessons,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return h, lessons
}

func lessonsJSON(ls ...map[string]any) string {
	b, _ := json.Marshal(map[string]any{"lessons": ls})
	return string(b)
}

func outboxLesson() map[string]any {
	return map[string]any{
		"slug": "Transactional Outbox", "title": "Transactional outbox", "category": "pattern", "level": "intermediate",
		"summary":     "Write the event in the same transaction as the state change.",
		"explanation": "A relay reads the outbox table and publishes.", "whyHere": "Refund events were lost on crashes.",
		"refs": []any{map[string]any{"path": "/workspace/refund.go", "line": 12, "note": "outbox insert"}, map[string]any{"path": "../etc/passwd"}},
		"quiz": []any{
			map[string]any{"question": "Why one transaction?", "options": []string{"Atomicity", "Speed"}, "answer": 0, "explanation": "Both or neither."},
			map[string]any{"question": "Broken", "options": []string{"only one"}, "answer": 0},
		},
		"reading": []any{map[string]any{"title": "Pattern", "url": "https://microservices.io/patterns/data/transactional-outbox.html"}, map[string]any{"title": "x", "url": "javascript:alert(1)"}},
	}
}

// shipped runs a ticket from intake to done with one coding script.
func (h *harness) shipped(key string) {
	h.t.Helper()
	h.ingest(key)
	h.runner.scripts = append(h.runner.scripts,
		script{result: ok("s-" + key), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		script{result: ok("s-" + key), edit: "fix " + key},
	)
	h.step() // analyze
	h.step() // code
	if _, err := h.o.Approve(h.ctx, key, nil, false, domain.OriginWeb); err != nil {
		h.t.Fatal(err)
	}
	h.step() // push
	h.expect(key, domain.StateDone)
}

func TestLearnAfterPush(t *testing.T) {
	h, lessons := newLearnHarness(t)
	h.shipped("PAY-1")
	if tk := h.state("PAY-1"); tk.LearnState != domain.LearnPending {
		t.Fatalf("learn state after push: %q", tk.LearnState)
	}

	h.runner.scripts = []script{{result: ok("l1"), files: map[string]string{orchestrator.LessonsPath: lessonsJSON(outboxLesson())}}}
	h.step() // learn
	tk := h.expect("PAY-1", domain.StateDone)
	if tk.LearnState != domain.LearnDone {
		t.Fatalf("learn state: %q", tk.LearnState)
	}
	h.idle()

	prompt := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(prompt, orchestrator.ChangePath) || !strings.Contains(prompt, "main.go (+3 −1)") || !strings.Contains(prompt, "Nothing yet") {
		t.Fatalf("learn prompt:\n%s", prompt)
	}

	ls, err := lessons.ListLessons(h.ctx, postgres.LessonFilter{TicketKey: "PAY-1"})
	if err != nil || len(ls) != 1 {
		t.Fatalf("lessons: %+v %v", ls, err)
	}
	l := ls[0]
	if l.Slug != "transactional-outbox" || l.RepoName != "api" || len(l.Refs) != 1 || l.Refs[0].Path != "refund.go" ||
		len(l.Quiz) != 1 || len(l.Reading) != 1 {
		t.Fatalf("lesson not normalised: %+v", l)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-1"})
	found := false
	for _, e := range evs {
		if e.Type == domain.EventLessons && strings.Contains(e.Message, "1 new lesson: Transactional outbox") {
			found = true
		}
	}
	if !found {
		t.Fatal("no lessons_found event")
	}

	// The next ticket sees the known topic and cannot add it twice.
	h.shipped("PAY-2")
	h.runner.scripts = []script{{result: ok("l2"), files: map[string]string{orchestrator.LessonsPath: lessonsJSON(outboxLesson())}}}
	h.step()
	if !strings.Contains(h.runner.prompts[len(h.runner.prompts)-1], "transactional-outbox: Transactional outbox") {
		t.Fatal("known topics missing from the second learn prompt")
	}
	if all, _ := lessons.ListLessons(h.ctx, postgres.LessonFilter{}); len(all) != 1 {
		t.Fatalf("duplicate lesson stored: %d", len(all))
	}
	if total, unlearned, _ := lessons.LessonCounts(h.ctx); total != 1 || unlearned != 1 {
		t.Fatalf("counts %d %d", total, unlearned)
	}
	if l, err := lessons.SetLessonLearned(h.ctx, l.ID, true); err != nil || l.LearnedAt == nil {
		t.Fatalf("mark learned: %+v %v", l, err)
	}
}

func TestLearnFailureKeepsTicketDone(t *testing.T) {
	h, _ := newLearnHarness(t)
	h.shipped("PAY-3")
	h.runner.scripts = []script{{result: ok("l3")}} // writes no lessons.json
	h.step()
	if tk := h.expect("PAY-3", domain.StateDone); tk.LearnState != domain.LearnFailed {
		t.Fatalf("learn state: %q", tk.LearnState)
	}
	h.idle()

	// Learning again on request.
	if _, err := h.o.Learn(h.ctx, "PAY-3", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("l4"), files: map[string]string{orchestrator.LessonsPath: lessonsJSON()}}}
	h.step()
	if tk := h.expect("PAY-3", domain.StateDone); tk.LearnState != domain.LearnDone {
		t.Fatalf("learn state after retry: %q", tk.LearnState)
	}
}

func TestLearnRateLimitedStaysPending(t *testing.T) {
	h, _ := newLearnHarness(t)
	h.shipped("PAY-4")
	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{RateLimited: true, IsError: true}}}
	h.step()
	if tk := h.expect("PAY-4", domain.StateDone); tk.LearnState != domain.LearnPending {
		t.Fatalf("learn state: %q", tk.LearnState)
	}
	if !h.usage.paused {
		t.Fatal("plan limit not recorded")
	}
}

func TestLearnOffAndNotForUnfinishedTickets(t *testing.T) {
	h, _ := newLearnHarness(t)
	h.settings.s.AutoLearn = false
	h.shipped("PAY-5")
	if tk := h.state("PAY-5"); tk.LearnState != domain.LearnNone {
		t.Fatalf("learn queued with autoLearn off: %q", tk.LearnState)
	}
	h.idle()

	h.ingest("PAY-6")
	if _, err := h.o.Learn(h.ctx, "PAY-6", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("learn on a new ticket: %v", err)
	}
}

func TestLearnQueue(t *testing.T) {
	h, lessons := newLearnHarness(t)
	h.settings.s.AutoLearn = false
	h.shipped("PAY-7")
	h.shipped("PAY-8")
	h.ingest("PAY-9") // not done: never in the queue

	status := func() map[string]string {
		q, err := lessons.LearnQueue(h.ctx)
		if err != nil {
			t.Fatal(err)
		}
		m := map[string]string{}
		for _, x := range q {
			m[x.Key] = x.Status
		}
		return m
	}
	if s := status(); len(s) != 2 || s["PAY-7"] != "none" || s["PAY-8"] != "none" {
		t.Fatalf("before queueing: %v", s)
	}
	if _, err := h.o.Learn(h.ctx, "PAY-8", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	q, _ := lessons.LearnQueue(h.ctx)
	if len(q) != 2 || q[0].Key != "PAY-8" || q[0].Status != "pending" {
		t.Fatalf("queued ticket not first: %+v", q)
	}

	// Ticket work goes first, so get PAY-9 out of the way.
	if _, err := h.o.Reject(h.ctx, "PAY-9", "", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("l8"), files: map[string]string{orchestrator.LessonsPath: lessonsJSON()}}}
	h.step()
	if s := status(); len(s) != 1 || s["PAY-7"] != "none" {
		t.Fatalf("learned ticket still listed: %v", s)
	}
}
