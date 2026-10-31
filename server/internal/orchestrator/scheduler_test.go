package orchestrator_test

import (
	"context"
	"io"
	"log/slog"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// fakeAccounts refuses the Claude account of the workspaces in paused,
// and every account of the modules in refuse.
type fakeAccounts struct {
	mu     sync.Mutex
	paused map[int64]bool
	refuse map[string]string
	picked []domain.ClaudeAccount
}

func (f *fakeAccounts) Pick(_ context.Context, w domain.Workspace, member *int64, provider string) (domain.ClaudeAccount, bool, string, time.Time) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.paused[w.ID] {
		return domain.ClaudeAccount{}, false, "Claude limit reached on the workspace's account", time.Time{}
	}
	if why, ok := f.refuse[provider]; ok {
		return domain.ClaudeAccount{}, false, why, time.Time{}
	}
	a := domain.ClaudeAccount{ConnectionID: w.ID * 100, Provider: provider}
	f.picked = append(f.picked, a)
	return a, true, "", time.Time{}
}

// sched is two workspaces sharing one orchestrator.
type sched struct {
	t        *testing.T
	o        *orchestrator.Orchestrator
	store    *postgres.Agent
	a, b     context.Context
	wa, wb   int64
	accounts *fakeAccounts
	budget   *orchestrator.MemoryBudget
	runner   *fakeRunner
	settings *postgres.Settings
	pool     *pgxpool.Pool
}

func newSched(t *testing.T, budgetMB int64) *sched {
	t.Helper()
	return newSchedAccess(t, budgetMB, nil)
}

// newSchedAccess is newSched with people's modules from access (nil: the
// default access for everyone).
func newSchedAccess(t *testing.T, budgetMB int64, access orchestrator.AccessSource) *sched {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	a, wa := pgtest.Workspace(t, pool, "sched-a")
	b, wb := pgtest.Workspace(t, pool, "sched-b")
	pgtest.Exec(t, pool, `UPDATE workspaces SET slots = 1 WHERE id IN ($1, $2)`, wa, wb)
	s := &sched{t: t, store: postgres.NewAgent(pool), a: a, b: b, wa: wa, wb: wb,
		accounts: &fakeAccounts{paused: map[int64]bool{}},
		budget:   &orchestrator.MemoryBudget{BudgetMB: budgetMB, DefaultMB: 4096, MaxMB: 8192},
		runner:   &fakeRunner{execs: map[string][]orchestrator.ExecResult{}}}
	settings := postgres.NewSettings(pool, domain.DefaultSettings())
	s.settings, s.pool = settings, pool
	s.o = orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{
		Store: s.store, Runner: s.runner, Git: &fakeGit{}, Host: &fakeHost{}, Homes: &memHomes{},
		Settings: settings, Usage: &fakeUsage{}, Workspaces: postgres.NewWorkspaces(pool),
		Accounts: s.accounts, Capacity: s.budget, Access: access,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return s
}

// task creates a held-free plan task (a report needs no repository).
func (s *sched) task(ctx context.Context, key string) {
	s.t.Helper()
	if _, err := s.store.CreateTicket(ctx, domain.Ticket{Key: key, Source: domain.SourceLocal, Title: key, State: domain.StateNew,
		Priority: "medium", Kind: domain.KindPlan, AfterApprove: "pr"}, domain.Event{TicketKey: key, Type: domain.EventTicketCreated}); err != nil {
		s.t.Fatal(err)
	}
}

func (s *sched) wait(ctx context.Context, key string) domain.WaitReason {
	s.t.Helper()
	tk, err := s.store.TicketByKey(ctx, key)
	if err != nil {
		s.t.Fatal(err)
	}
	return tk.WaitReason
}

func (s *sched) started(ctx context.Context, key string) bool {
	s.t.Helper()
	tk, err := s.store.TicketByKey(ctx, key)
	if err != nil {
		s.t.Fatal(err)
	}
	return tk.State != domain.StateNew
}

func TestSchedulerSlotsPerWorkspace(t *testing.T) {
	s := newSched(t, 0) // memory unlimited
	s.task(s.a, "A-1")
	s.task(s.a, "A-2")
	s.task(s.b, "B-1")

	// One slot each: A-1 and B-1 start, A-2 waits for A's slot.
	if n := s.o.Tick(s.a); n != 2 {
		t.Fatalf("started %d runs, want 2", n)
	}
	if !s.started(s.a, "A-1") || !s.started(s.b, "B-1") || s.started(s.a, "A-2") {
		t.Fatal("the wrong tickets started")
	}
	if got := s.wait(s.a, "A-2"); got != domain.WaitSlots {
		t.Fatalf("A-2 waits for %q, want slots", got)
	}
	// The runs used each workspace's own account.
	if len(s.accounts.picked) != 2 {
		t.Fatalf("accounts picked: %+v", s.accounts.picked)
	}
	// With the slot free again, A-2 starts and its reason clears.
	if n := s.o.Tick(s.a); n != 1 || !s.started(s.a, "A-2") || s.wait(s.a, "A-2") != domain.WaitNone {
		t.Fatalf("second tick: %d", n)
	}
}

func TestSchedulerServerQueueAndFairness(t *testing.T) {
	s := newSched(t, 4096) // room for one run of 4 GB
	pgtest.Exec(t, pgtest.Open(t), `UPDATE workspaces SET slots = 2 WHERE id = $1`, s.wa)
	s.task(s.a, "A-1")
	s.task(s.a, "A-2")
	s.task(s.b, "B-1")

	if n := s.o.Tick(s.a); n != 1 {
		t.Fatalf("started %d, want 1 (the server has room for one)", n)
	}
	// One of the workspaces started; the others wait for the server.
	waiting := 0
	for _, x := range []struct {
		ctx context.Context
		key string
	}{{s.a, "A-1"}, {s.a, "A-2"}, {s.b, "B-1"}} {
		if !s.started(x.ctx, x.key) {
			waiting++
			if got := s.wait(x.ctx, x.key); got != domain.WaitServer {
				t.Fatalf("%s waits for %q, want server", x.key, got)
			}
		}
	}
	if waiting != 2 {
		t.Fatalf("%d tickets waiting, want 2", waiting)
	}
	st := s.o.ServerStatus()
	if len(st.ServerQueue) != 2 {
		t.Fatalf("server queue %+v", st.ServerQueue)
	}
	// B sees its own position and only a count of A's tickets.
	q, err := s.o.QueueStatus(s.b)
	if err != nil {
		t.Fatal(err)
	}
	if !s.started(s.b, "B-1") && (len(q.ServerQueue) != 1 || q.ServerQueue[0].Key != "B-1" || q.ServerQueueLen != 2) {
		t.Fatalf("B's queue view %+v", q)
	}
	// The run ended (released its memory): the next tick serves the
	// workspace that has had fewer runs, so B gets its turn before A's second.
	s.o.Tick(s.a)
	if !s.started(s.b, "B-1") {
		t.Fatal("B-1 did not get its turn")
	}
}

func TestSchedulerClaudeLimitPerAccount(t *testing.T) {
	s := newSched(t, 0)
	s.accounts.paused[s.wb] = true
	s.task(s.a, "A-1")
	s.task(s.b, "B-1")
	if n := s.o.Tick(s.a); n != 1 || !s.started(s.a, "A-1") {
		t.Fatalf("A's run should start: %d", n)
	}
	if got := s.wait(s.b, "B-1"); got != domain.WaitClaude {
		t.Fatalf("B-1 waits for %q, want claude", got)
	}
	tk, _ := s.store.TicketByKey(s.b, "B-1")
	if tk.WaitMessage == "" {
		t.Fatal("no wait message")
	}
	s.accounts.paused[s.wb] = false
	if n := s.o.Tick(s.b); n != 1 || !s.started(s.b, "B-1") {
		t.Fatalf("B-1 should start once its account is back: %d", n)
	}
}

func TestSchedulerSkipsSuspendedAndHeld(t *testing.T) {
	s := newSched(t, 0)
	pool := pgtest.Open(t)
	pgtest.Exec(t, pool, `UPDATE workspaces SET suspended_at = now() WHERE id = $1`, s.wb)
	t.Cleanup(func() { pgtest.Exec(t, pool, `UPDATE workspaces SET suspended_at = NULL WHERE id = $1`, s.wb) })
	s.task(s.b, "B-1")
	if _, err := s.store.CreateTicket(s.a, domain.Ticket{Key: "A-9", Source: domain.SourceLocal, Title: "held", State: domain.StateNew,
		Priority: "medium", Kind: domain.KindPlan, Held: true, AfterApprove: "pr"}, domain.Event{TicketKey: "A-9", Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	if n := s.o.Tick(s.a); n != 0 {
		t.Fatalf("started %d runs, want none", n)
	}
	if got := s.wait(s.a, "A-9"); got != domain.WaitBlocked {
		t.Fatalf("held ticket waits for %q, want blocked", got)
	}
}

func TestMemoryBudget(t *testing.T) {
	free := int64(100000)
	b := &orchestrator.MemoryBudget{BudgetMB: 10240, DefaultMB: 4096, MaxMB: 8192, MinFreeDiskMB: 1000,
		Available: func() (int64, bool) { return 6000, true }, DiskFree: func() (int64, bool) { return free, true }}
	if b.RunMemory(0) != 4096 || b.RunMemory(16384) != 8192 || b.RunMemory(2048) != 2048 {
		t.Fatal("run memory")
	}
	r1, ok, _ := b.Reserve(4096)
	if !ok {
		t.Fatal("first run")
	}
	if _, ok, why := b.Reserve(8192); ok || why == "" {
		t.Fatal("over the budget")
	}
	if b.Spare(4096) {
		t.Fatal("no spare room with 6 GB left of 10")
	}
	r2, ok, _ := b.Reserve(4096)
	if !ok {
		t.Fatal("second run fits")
	}
	if st := b.Status(); st.ReservedMB != 8192 || st.Runs != 2 {
		t.Fatalf("status %+v", st)
	}
	r1()
	r1() // twice is harmless
	r2()
	if st := b.Status(); st.ReservedMB != 0 || st.Runs != 0 {
		t.Fatalf("after release %+v", st)
	}
	// The host's available memory and the disk floor hold runs back too.
	if _, ok, _ := b.Reserve(8000); ok {
		t.Fatal("more than the host has available")
	}
	free = 10
	if _, ok, why := b.Reserve(1024); ok || why == "" {
		t.Fatal("disk floor ignored")
	}
}
