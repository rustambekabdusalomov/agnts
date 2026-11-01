package ai_test

import (
	"context"
	"errors"
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

func (a *accounts) Pick(_ context.Context, w domain.Workspace, member *int64, provider string, credits bool) (domain.ClaudeAccount, bool, string, time.Time) {
	a.picks = append(a.picks, credits)
	if why, ok := a.refuse[provider]; ok {
		return domain.ClaudeAccount{}, false, why, time.Time{}
	}
	if a.credits[provider] {
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
	return ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{all}, Accounts: a, Workspaces: workspaces{}, Limits: l,
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
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{domain.Access{Modules: []string{"muse"}}}})
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
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{all}, Limits: l})
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
