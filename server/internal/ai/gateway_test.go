package ai_test

import (
	"context"
	"errors"
	"slices"
	"testing"
	"time"

	"agnts/internal/ai"
	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
)

// box is a run container that scripts the agent's answer.
type box struct {
	ai.Box
	got    []ai.Request
	res    ai.Result
	events []ai.Event
}

func (b *box) Claude(_ context.Context, req ai.Request, on func(ai.Event)) (ai.Result, error) {
	b.got = append(b.got, req)
	for _, e := range b.events {
		on(e)
	}
	return b.res, nil
}

// accounts gives every module an account: a connection per module, or
// credits for the modules in credits; none for the modules in refuse.
type accounts struct {
	conn    map[string]int64
	credits map[string]bool
	refuse  map[string]string
	picks   []bool // the credits flag of each Pick
	opened  []domain.ClaudeAccount
}

func (a *accounts) Pick(_ context.Context, w domain.Workspace, member *int64, provider string, opts ai.PickOpts) (domain.ClaudeAccount, bool, string, time.Time) {
	credits := opts.Credits
	a.picks = append(a.picks, credits)
	if why, ok := a.refuse[provider]; ok {
		return domain.ClaudeAccount{}, false, why, time.Time{}
	}
	if a.credits[provider] || slices.Contains(opts.Skip, a.conn[provider]) {
		if !credits {
			return domain.ClaudeAccount{}, false, "no " + provider + " account is connected", time.Time{}
		}
		return domain.ClaudeAccount{Credits: true, Provider: provider}, true, "", time.Time{}
	}
	return domain.ClaudeAccount{ConnectionID: a.conn[provider], Provider: provider}, true, "", time.Time{}
}

func (a *accounts) Credential(_ context.Context, acct domain.ClaudeAccount) (ai.Credential, error) {
	a.opened = append(a.opened, acct)
	return ai.Credential{Token: "t-" + acct.Provider}, nil
}

type workspaces struct{}

func (workspaces) ByID(_ context.Context, id int64) (domain.Workspace, error) {
	return domain.Workspace{ID: id, ClaudeMode: domain.ClaudeShared}, nil
}

type access struct{ a domain.Access }

func (a access) For(context.Context, int64) (domain.Access, error) { return a.a, nil }

type limits struct {
	paused  bool
	records []domain.ClaudeAccount
	limited []domain.ClaudeAccount
}

func (l *limits) Paused(context.Context, domain.ClaudeAccount, domain.Settings) (bool, time.Time) {
	return l.paused, time.Date(2026, 11, 1, 15, 0, 0, 0, time.UTC)
}
func (l *limits) Record(_ context.Context, a domain.ClaudeAccount, _ map[string]any) {
	l.records = append(l.records, a)
}
func (l *limits) RecordLimited(_ context.Context, a domain.ClaudeAccount) {
	l.limited = append(l.limited, a)
}

var all = domain.Access{Modules: []string{"claude", "muse", "codex"}}

func gateway(a *accounts, l *limits, spent *[]domain.ClaudeCall) *ai.Gateway {
	return ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{all}, Accounts: a, Workspaces: workspaces{}, Limits: l, Settings: settings{},
		Spend: func(_ context.Context, c domain.ClaudeCall) error {
			*spent = append(*spent, c)
			return nil
		}})
}

// A run admitted with a member's Claude account and Muse on credits: each
// call runs on its own module's route, opens that account's credential,
// and is recorded with it.
func TestRunUsesTheAdmittedRouteOfItsModule(t *testing.T) {
	a := &accounts{conn: map[string]int64{"claude": 7}, credits: map[string]bool{"muse": true}}
	var spent []domain.ClaudeCall
	g := gateway(a, &limits{}, &spent)
	ctx := domain.WithWorkspace(context.Background(), 3)
	adm, hold := g.Admit(ctx, ai.Who{Person: 4}, "code", all, []string{"claude", "muse"}, ai.AdmitCache{})
	if hold != nil || !adm.OnCredits() {
		t.Fatalf("admit: %v %+v", hold, adm)
	}
	ctx = ai.WithAdmission(ctx, adm)
	b := &box{res: ai.Result{Turns: 2}}
	for _, m := range []string{"opus", "muse:spark"} {
		if _, err := g.Run(ctx, ai.Call{Purpose: "code", Box: b, Req: ai.Request{Model: m}, RunID: 3, ModelStage: "coding"}, nil); err != nil {
			t.Fatal(err)
		}
	}
	if len(a.picks) != 2 {
		t.Fatalf("calls of an admitted run are not picked again: %d picks", len(a.picks))
	}
	if len(spent) != 2 || spent[0].ConnectionID != 7 || spent[0].OnCredits || spent[0].Provider != "claude" ||
		spent[1].ConnectionID != 0 || !spent[1].OnCredits || spent[1].Provider != "muse" {
		t.Fatalf("spent: %+v", spent)
	}
	if len(a.opened) != 2 || a.opened[0].ConnectionID != 7 || !a.opened[1].Credits {
		t.Fatalf("opened: %+v", a.opened)
	}
	// A model on a module the run did not admit is routed on its own.
	if _, err := g.Run(ctx, ai.Call{Purpose: "code", Box: b, Req: ai.Request{Model: "codex:gpt-5"}}, nil); err != nil || len(a.picks) != 3 {
		t.Fatalf("codex: %v, %d picks", err, len(a.picks))
	}
}

// Answers, spoken questions, translation and detection never run on
// credits; a call held for want of an account says why.
func TestPolicyKeepsSomePurposesOffCredits(t *testing.T) {
	a := &accounts{credits: map[string]bool{"claude": true}}
	var spent []domain.ClaudeCall
	g := gateway(a, &limits{}, &spent)
	ctx := domain.WithWorkspace(context.Background(), 3)
	b := &box{}
	_, err := g.Run(ctx, ai.Call{Who: ai.Who{Person: 4}, Purpose: domain.PurposeAssistant, Box: b, Req: ai.Request{Model: "sonnet"}}, nil)
	var h *ai.Hold
	if !errors.As(err, &h) || h.Why != "no claude account is connected" || len(b.got) != 0 {
		t.Fatalf("assistant on credits: %v", err)
	}
	if _, err := g.Run(ctx, ai.Call{Who: ai.Who{Person: 4}, Purpose: domain.PurposeDocument, Box: b, Req: ai.Request{Model: "sonnet"}}, nil); err != nil {
		t.Fatalf("a document may run on credits: %v", err)
	}
	if len(a.picks) != 2 || a.picks[0] || !a.picks[1] {
		t.Fatalf("credits flags: %v", a.picks)
	}
}

// A call on a module its person may not use never reaches the provider.
func TestRunRefusesModulesThePersonMayNotUse(t *testing.T) {
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{domain.Access{Modules: []string{"muse"}}}, Settings: settings{}})
	b := &box{}
	_, err := g.Run(context.Background(), ai.Call{Who: ai.Who{Person: 4}, Box: b, Req: ai.Request{Model: "opus"}}, nil)
	var na *domain.NotAllowedError
	if !errors.As(err, &na) || na.Module != ai.Claude || len(b.got) != 0 {
		t.Fatalf("err %v, calls %d", err, len(b.got))
	}
	own := domain.Access{Modules: []string{"claude"}}
	if _, err := g.Run(context.Background(), ai.Call{Who: ai.Who{Access: &own}, Box: b, Req: ai.Request{Model: "muse:spark"}}, nil); !errors.As(err, &na) {
		t.Fatalf("access the caller read: %v", err)
	}
}

// With one account for everything, its limit holds calls (ErrLimit), and
// the gateway records the stream's readings and a refusal on the call's
// account.
func TestLimits(t *testing.T) {
	l := &limits{paused: true}
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{all}, Limits: l, Settings: settings{}})
	b := &box{res: ai.Result{RateLimited: true}, events: []ai.Event{{Kind: ai.EventRateLimit, Data: map[string]any{"status": "rejected"}}}}
	_, err := g.Run(context.Background(), ai.Call{Who: ai.Who{Person: 4}, Box: b, Req: ai.Request{Model: "opus"}}, nil)
	if !errors.Is(err, ai.ErrLimit) || err.Error() != "Claude limit reached; resumes at 15:00" {
		t.Fatalf("paused: %v", err)
	}
	l.paused = false
	res, err := g.Run(context.Background(), ai.Call{Who: ai.Who{Person: 4}, Box: b, Req: ai.Request{Model: "opus"}}, nil)
	if err != nil || !res.RateLimited || len(l.records) != 1 || len(l.limited) != 1 || res.Provider != ai.Claude {
		t.Fatalf("readings: %v %+v %d %d", err, res, len(l.records), len(l.limited))
	}
}

// Hearing runs on the provider that hears audio, whatever modules the
// person codes with.
func TestHearing(t *testing.T) {
	muse := aitest.Muse()
	muse.Ears = func(_ context.Context, c ai.Credential, _ []byte) (string, error) { return "hello " + c.Token, nil }
	a := &accounts{conn: map[string]int64{"muse": 9}}
	g := ai.New(ai.Deps{Providers: ai.NewRegistry(aitest.Claude(), muse), Access: access{domain.Access{Modules: []string{"claude"}}},
		Accounts: a, Workspaces: workspaces{}})
	if !g.CanHear() {
		t.Fatal("muse has ears")
	}
	got, err := g.HearClip(domain.WithWorkspace(context.Background(), 3), ai.Who{Person: 4}, []byte("RIFF"))
	if err != nil || got != "hello t-muse" || a.picks[0] {
		t.Fatalf("heard %q, %v, credits %v", got, err, a.picks)
	}
}

type settings struct{ s domain.Settings }

func (s settings) Get(context.Context) (domain.Settings, error) { return s.s, nil }

// A Claude limit moves a strong call to Muse Wonder for a person with
// both modules, when the workspace switches modules; a second opinion,
// a person with Claude alone, or a workspace that does not switch waits.
func TestRerouting(t *testing.T) {
	ctx := domain.WithWorkspace(context.Background(), 3)
	on := domain.Settings{SwitchModules: true}
	both := domain.Access{Modules: []string{"claude", "muse"}}
	route := func(acc domain.Access, s domain.Settings, purpose ai.Purpose, model string) (ai.Route, *ai.Hold) {
		a := &accounts{conn: map[string]int64{"muse": 9}, refuse: map[string]string{"claude": "Claude limit reached on Acme's account"}}
		g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{acc}, Accounts: a, Workspaces: workspaces{}, Settings: settings{s}})
		return g.Route(ctx, ai.Who{Person: 4}, purpose, ai.Want{Model: model})
	}
	r, h := route(both, on, "analyze", "opus")
	if h != nil || r.Provider != ai.Muse || r.Model != "muse:wonder" || r.Account.ConnectionID != 9 || r.Rerouted != "Claude limit reached on Acme's account" {
		t.Fatalf("strong: %+v %v", r, h)
	}
	if r, _ := route(both, on, "code", "sonnet"); r.Model != "muse:spark" {
		t.Fatalf("light: %+v", r)
	}
	if _, h := route(both, on, domain.PurposeSecondOpinion, "opus"); h == nil {
		t.Fatal("a second opinion never switches")
	}
	if _, h := route(domain.Access{Modules: []string{"claude"}}, on, "analyze", "opus"); h == nil || h.Why != "Claude limit reached on Acme's account" {
		t.Fatalf("claude only: %v", h)
	}
	if _, h := route(both, domain.Settings{}, "analyze", "opus"); h == nil {
		t.Fatal("switching is off")
	}
	// A module the person may not use moves too, when switching is on.
	if r, h := route(domain.Access{Modules: []string{"muse"}}, on, "analyze", "opus"); h != nil || r.Provider != ai.Muse {
		t.Fatalf("not enabled: %+v %v", r, h)
	}
}

// An admitted run whose Claude route moved to Muse runs its Claude calls
// on Muse at their own tier; its second opinion does not follow.
func TestAdmissionMoves(t *testing.T) {
	ctx := domain.WithWorkspace(context.Background(), 3)
	both := domain.Access{Modules: []string{"claude", "muse"}}
	a := &accounts{conn: map[string]int64{"muse": 9}, refuse: map[string]string{"claude": "Claude limit reached"}}
	var spent []domain.ClaudeCall
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{both}, Accounts: a, Workspaces: workspaces{},
		Settings: settings{domain.Settings{SwitchModules: true}}, Spend: func(_ context.Context, c domain.ClaudeCall) error {
			spent = append(spent, c)
			return nil
		}})
	adm, h := g.Admit(ctx, ai.Who{Person: 4}, "code", both, []string{"claude"}, ai.AdmitCache{})
	if h != nil || !adm.Routes["claude"].Moved() {
		t.Fatalf("admit: %+v %v", adm, h)
	}
	ctx = ai.WithAdmission(ctx, adm)
	b := &box{res: ai.Result{Turns: 1}}
	res, err := g.Run(ctx, ai.Call{Purpose: "code", Box: b, Req: ai.Request{Model: "opus", Resume: "s1"}, RunID: 1}, nil)
	if err != nil || res.Provider != ai.Muse || b.got[0].Model != "muse:wonder" || b.got[0].Resume != "s1" {
		t.Fatalf("moved call: %v %+v %+v", err, res, b.got)
	}
	if _, err := g.Run(ctx, ai.Call{Purpose: domain.PurposeSecondOpinion, Box: b, Req: ai.Request{Model: "opus"}}, nil); err == nil {
		t.Fatal("the second opinion followed the moved route")
	}
	if len(spent) != 1 || spent[0].Provider != ai.Muse || spent[0].ConnectionID != 9 {
		t.Fatalf("spent: %+v", spent)
	}
}

func TestMapModel(t *testing.T) {
	reg := aitest.Providers()
	for _, c := range []struct{ model, to, want string }{
		{"opus", "muse", "muse:wonder"}, {"sonnet", "muse", "muse:spark"}, {"haiku", "muse", "muse:spark"},
		{"muse:wonder", "claude", "opus"}, {"muse:spark", "claude", "sonnet"}, {"muse:muse-wonder-1.2", "claude", "opus"},
		{"opus", "codex", "codex:gpt-5"}, {"codex:gpt-5-mini", "claude", "sonnet"}, {"opus", "claude", "opus"}, {"", "muse", ""},
	} {
		if got := ai.MapModel(reg, c.model, c.to); got != c.want {
			t.Errorf("%s → %s: %q, want %q", c.model, c.to, got, c.want)
		}
	}
	// Codex without models for its tiers takes no calls.
	if got := ai.MapModel(ai.NewRegistry(aitest.Claude()), "opus", "codex"); got != "" {
		t.Fatalf("no codex: %q", got)
	}
}

// seqBox answers each call with the next of its scripted answers.
type seqBox struct {
	ai.Box
	answers []answer
	got     []ai.Request
}

type answer struct {
	res   ai.Result
	err   error
	tools int
}

func (b *seqBox) Claude(_ context.Context, req ai.Request, on func(ai.Event)) (ai.Result, error) {
	a := b.answers[len(b.got)]
	b.got = append(b.got, req)
	for range a.tools {
		on(ai.Event{Kind: ai.EventTool, Tool: "Edit: main.go"})
	}
	return a.res, a.err
}

func failover(t *testing.T, a *accounts, l *limits, s domain.Settings) (*ai.Gateway, *[]domain.ClaudeCall) {
	t.Helper()
	var spent []domain.ClaudeCall
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{domain.Access{Modules: []string{"claude", "muse"}}}, Accounts: a,
		Workspaces: workspaces{}, Limits: l, Settings: settings{s}, Spend: func(_ context.Context, c domain.ClaudeCall) error {
			spent = append(spent, c)
			return nil
		}})
	return g, &spent
}

// A call refused at its account's limit runs again at once on the
// module's next account (credits); the run's later calls go there.
func TestFailoverToCredits(t *testing.T) {
	a := &accounts{conn: map[string]int64{"claude": 7}, credits: map[string]bool{}}
	g, spent := failover(t, a, &limits{}, domain.Settings{})
	ctx := domain.WithWorkspace(context.Background(), 3)
	both := domain.Access{Modules: []string{"claude", "muse"}}
	adm, h := g.Admit(ctx, ai.Who{Person: 4}, "code", both, []string{"claude"}, ai.AdmitCache{})
	if h != nil {
		t.Fatal(h)
	}
	ctx = ai.WithAdmission(ctx, adm)
	// After the first failure the connection is skipped: the fake then
	// gives credits.
	b := &seqBox{answers: []answer{{res: ai.Result{RateLimited: true, IsError: true, Turns: 1}}, {res: ai.Result{Turns: 3}}, {res: ai.Result{Turns: 2}}}}
	var events []ai.Event
	res, err := g.Run(ctx, ai.Call{Purpose: "code", Box: b, Req: ai.Request{Model: "opus", Resume: "s1"}, RunID: 1}, func(e ai.Event) { events = append(events, e) })
	if err != nil || res.RateLimited || !res.Account.Credits || len(b.got) != 2 || b.got[1].Model != "opus" || b.got[1].Resume != "s1" {
		t.Fatalf("res %+v err %v calls %+v", res, err, b.got)
	}
	if len(events) != 1 || events[0].Kind != ai.EventRetry {
		t.Fatalf("events: %+v", events)
	}
	if len(*spent) != 2 || (*spent)[0].ConnectionID != 7 || !(*spent)[1].OnCredits {
		t.Fatalf("spent: %+v", *spent)
	}
	// The run's next call goes straight to credits.
	if _, err := g.Run(ctx, ai.Call{Purpose: "code", Box: b, Req: ai.Request{Model: "opus"}, RunID: 1}, nil); err != nil || !(*spent)[2].OnCredits {
		t.Fatalf("next call: %v %+v", err, *spent)
	}
}

// Without another account of its module, a call refused by its
// credential moves to the next module when the workspace switches, on a
// fresh session; without switching, the failure stands.
func TestFailoverToTheNextModule(t *testing.T) {
	ctx := domain.WithWorkspace(context.Background(), 3)
	refused := answer{err: errors.New("claude exited: Invalid API key · Please run /login")}
	for _, switching := range []bool{true, false} {
		a := &accounts{conn: map[string]int64{"claude": 7, "muse": 9}, credits: map[string]bool{}}
		g, _ := failover(t, a, &limits{}, domain.Settings{SwitchModules: switching})
		// Skipping Claude's connection leaves no Claude account: answers
		// never run on credits.
		b := &seqBox{answers: []answer{refused, {res: ai.Result{Turns: 1}}}}
		res, err := g.Run(ctx, ai.Call{Who: ai.Who{Person: 4}, Purpose: domain.PurposeAssistant, Box: b,
			Req: ai.Request{Model: "sonnet", Resume: "s1", ReadOnly: true}}, nil)
		if switching && (err != nil || res.Provider != ai.Muse || b.got[1].Model != "muse:spark" || b.got[1].Resume != "") {
			t.Fatalf("switching: %v %+v %+v", err, res, b.got)
		}
		if !switching && (err == nil || len(b.got) != 1) {
			t.Fatalf("not switching: %v %d calls", err, len(b.got))
		}
	}
}

// A call that already changed files is never run again, and a call runs
// at most three times.
func TestNoFailoverAfterWork(t *testing.T) {
	ctx := domain.WithWorkspace(context.Background(), 3)
	a := &accounts{conn: map[string]int64{"claude": 7}, credits: map[string]bool{}}
	g, _ := failover(t, a, &limits{}, domain.Settings{SwitchModules: true})
	limited := answer{res: ai.Result{RateLimited: true, IsError: true}, tools: 2}
	b := &seqBox{answers: []answer{limited}}
	if res, _ := g.Run(ctx, ai.Call{Who: ai.Who{Person: 4}, Purpose: "code", Box: b, Req: ai.Request{Model: "opus"}}, nil); !res.RateLimited || len(b.got) != 1 {
		t.Fatalf("after work: %+v, %d calls", res, len(b.got))
	}
	early := answer{res: ai.Result{RateLimited: true, IsError: true}}
	b = &seqBox{answers: []answer{early, early, early, early}}
	_, _ = g.Run(ctx, ai.Call{Who: ai.Who{Person: 4}, Purpose: "code", Box: b, Req: ai.Request{Model: "opus"}}, nil)
	if len(b.got) > 3 {
		t.Fatalf("%d attempts", len(b.got))
	}
}
