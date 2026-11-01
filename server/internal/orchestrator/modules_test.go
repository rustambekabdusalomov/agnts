package orchestrator_test

import (
	"context"
	"slices"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres/pgtest"
)

// fakeAccess gives each person their modules; anyone else the default.
type fakeAccess struct {
	mu  sync.Mutex
	own map[int64][]string
}

func (f *fakeAccess) For(_ context.Context, user int64) (domain.Access, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if m, ok := f.own[user]; ok {
		return domain.Access{Modules: slices.Clone(m)}, nil
	}
	return domain.Access{Modules: []string{domain.ProviderClaude, domain.ProviderCodex}}, nil
}

func (f *fakeAccess) set(user int64, m ...string) {
	f.mu.Lock()
	f.own[user] = m
	f.mu.Unlock()
}

// taskOf creates a plan task of member.
func (s *sched) taskOf(ctx context.Context, key string, member int64) {
	s.t.Helper()
	if _, err := s.store.CreateTicket(ctx, domain.Ticket{Key: key, Source: domain.SourceLocal, Title: key, State: domain.StateNew,
		Priority: "medium", Kind: domain.KindPlan, AfterApprove: "pr", MemberID: &member}, domain.Event{TicketKey: key, Type: domain.EventTicketCreated}); err != nil {
		s.t.Fatal(err)
	}
}

func (s *sched) providers() []string {
	s.accounts.mu.Lock()
	defer s.accounts.mu.Unlock()
	var out []string
	for _, a := range s.accounts.picked {
		out = append(out, a.Provider)
	}
	return out
}

// A ticket analysed on Claude and coded on Codex picks an account for
// each module before it starts.
func TestSchedulerPicksAnAccountPerModule(t *testing.T) {
	access := &fakeAccess{own: map[int64][]string{}}
	s := newSchedAccess(t, 0, access)
	v := domain.DefaultSettings()
	v.Models.Analyze, v.Models.Coding = "sonnet", "codex:gpt-5"
	if _, err := s.settings.Put(s.a, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	s.task(s.a, "A-1")
	if n := s.o.Tick(s.a); n != 1 {
		t.Fatalf("started %d runs", n)
	}
	if got := s.providers(); !slices.Equal(got, []string{domain.ProviderClaude, domain.ProviderCodex}) {
		t.Fatalf("picked %v, want claude and codex", got)
	}
}

// A Codex stage without an OpenAI key holds the ticket back with Codex's
// reason, before analysis on Claude starts.
func TestSchedulerHoldsAModuleWithoutAnAccount(t *testing.T) {
	access := &fakeAccess{own: map[int64][]string{}}
	s := newSchedAccess(t, 0, access)
	s.accounts.refuse = map[string]string{domain.ProviderCodex: "Codex runs need an OpenAI API key: connect OpenAI under Integrations"}
	v := domain.DefaultSettings()
	v.Models.Coding = "codex:gpt-5"
	v.SwitchModules = false
	if _, err := s.settings.Put(s.a, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	s.task(s.a, "A-1")
	if n := s.o.Tick(s.a); n != 0 {
		t.Fatalf("started %d runs", n)
	}
	tk, _ := s.store.TicketByKey(s.a, "A-1")
	if tk.WaitReason != domain.WaitClaude || !strings.Contains(tk.WaitMessage, "OpenAI") {
		t.Fatalf("waits for %q: %q", tk.WaitReason, tk.WaitMessage)
	}
}

// A judge's ticket runs on Muse even in a workspace that shares one
// account and whose settings name Claude models: access goes with the
// person, payment with the account.
func TestSchedulerUsesTheTicketPersonsModules(t *testing.T) {
	access := &fakeAccess{own: map[int64][]string{}}
	s := newSchedAccess(t, 0, access)
	judge := pgtest.User(t, s.pool, "judge")
	pgtest.Exec(t, s.pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'user') ON CONFLICT DO NOTHING`, s.wa, judge)
	access.set(judge, domain.ProviderMuse)
	v := domain.DefaultSettings()
	v.Models.Analyze, v.Models.Coding = "sonnet", "opus"
	if _, err := s.settings.Put(s.a, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	s.taskOf(s.a, "A-1", judge)
	if n := s.o.Tick(s.a); n != 1 {
		t.Fatalf("started %d runs", n)
	}
	if got := s.providers(); !slices.Equal(got, []string{domain.ProviderMuse}) {
		t.Fatalf("judge's ticket picked %v, want muse only", got)
	}
}

// A person with no modules waits with a reason that says so.
func TestSchedulerWithoutModules(t *testing.T) {
	access := &fakeAccess{own: map[int64][]string{}}
	s := newSchedAccess(t, 0, access)
	someone := pgtest.User(t, s.pool, "no-modules")
	pgtest.Exec(t, s.pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'user') ON CONFLICT DO NOTHING`, s.wa, someone)
	access.set(someone)
	s.taskOf(s.a, "A-1", someone)
	if n := s.o.Tick(s.a); n != 0 {
		t.Fatalf("started %d runs", n)
	}
	tk, _ := s.store.TicketByKey(s.a, "A-1")
	if !strings.Contains(tk.WaitMessage, "no coding module") {
		t.Fatalf("wait message %q", tk.WaitMessage)
	}
	// An Admin enables one: the next tick starts it.
	access.set(someone, domain.ProviderClaude)
	if n := s.o.Tick(s.a); n != 1 {
		t.Fatalf("started %d runs after enabling", n)
	}
}

// When a Claude account is at its limit, a workspace that switches modules
// runs the ticket on the person's next module, at the same tier, and says
// so on the ticket; one that does not waits for Claude.
func TestSchedulerSwitchesModules(t *testing.T) {
	access := &fakeAccess{own: map[int64][]string{}}
	s := newSchedAccess(t, 0, access)
	owner := pgtest.User(t, s.pool, "both")
	access.set(owner, domain.ProviderClaude, domain.ProviderMuse)
	s.accounts.refuse = map[string]string{domain.ProviderClaude: "Claude limit reached on the workspace's account"}
	v := domain.DefaultSettings()
	v.Models.Analyze, v.Models.Coding = "opus", "sonnet"
	v.SwitchModules = false
	if _, err := s.settings.Put(s.a, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	s.taskOf(s.a, "A-1", owner)
	if n := s.o.Tick(s.a); n != 0 {
		t.Fatalf("switching off: started %d runs", n)
	}
	if tk, _ := s.store.TicketByKey(s.a, "A-1"); tk.WaitReason != domain.WaitClaude || !strings.Contains(tk.WaitMessage, "limit") {
		t.Fatalf("waits for %q: %q", tk.WaitReason, tk.WaitMessage)
	}

	v.SwitchModules = true
	if _, err := s.settings.Put(s.a, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	var models []string
	s.runner.onClaude = func(r orchestrator.ClaudeRequest) { models = append(models, r.Model) }
	s.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	if n := s.o.Tick(s.a); n != 1 {
		t.Fatalf("switching on: started %d runs", n)
	}
	if len(models) == 0 || models[0] != "muse:wonder" {
		t.Fatalf("analysis ran on %v, want muse:wonder", models)
	}
	evs, err := s.store.Events(s.a, orchestrator.EventFilter{TicketKey: "A-1"})
	if err != nil {
		t.Fatal(err)
	}
	found := false
	for _, e := range evs {
		found = found || (e.Type == domain.EventRerouted && strings.Contains(e.Message, "Muse Wonder") && strings.Contains(e.Message, "Claude limit reached"))
	}
	if !found {
		t.Fatalf("no rerouted event: %+v", evs)
	}
}
