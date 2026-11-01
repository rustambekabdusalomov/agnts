package ai_test

import (
	"context"
	"errors"
	"testing"

	"agnts/internal/ai"
	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
)

// box is a run container that scripts the agent's answer.
type box struct {
	ai.Box
	got []ai.Request
	res ai.Result
}

func (b *box) Claude(_ context.Context, req ai.Request, _ func(ai.Event)) (ai.Result, error) {
	b.got = append(b.got, req)
	return b.res, nil
}

type creds struct{ asked []string }

func (c *creds) Credential(_ context.Context, provider string) (ai.Credential, error) {
	c.asked = append(c.asked, provider)
	return ai.Credential{Token: "t-" + provider}, nil
}

// A call is recorded with its own module's account: in a run with a
// member's Claude account and Muse on credits, the Muse call is on
// credits and the Claude call is not.
func TestSpendRecordsTheCallsAccount(t *testing.T) {
	var spent []domain.ClaudeCall
	c := &creds{}
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Credentials: c, Spend: func(_ context.Context, call domain.ClaudeCall) error {
		spent = append(spent, call)
		return nil
	}})
	ctx := domain.WithAccounts(context.Background(), domain.ProviderClaude, map[string]domain.ClaudeAccount{
		domain.ProviderClaude: {ConnectionID: 7, Provider: domain.ProviderClaude},
		domain.ProviderMuse:   {Credits: true, Provider: domain.ProviderMuse},
	})
	b := &box{res: ai.Result{Turns: 2}}
	for _, m := range []string{"opus", "muse:spark"} {
		if _, err := g.Run(ctx, ai.Call{Box: b, Req: ai.Request{Model: m}, RunID: 3, ModelStage: "coding"}, nil); err != nil {
			t.Fatal(err)
		}
	}
	// Not charged anywhere: no run and no document.
	if _, err := g.Run(ctx, ai.Call{Box: b, Req: ai.Request{Model: "codex:gpt-5"}}, nil); err != nil {
		t.Fatal(err)
	}
	if len(spent) != 2 {
		t.Fatalf("spent: %+v", spent)
	}
	if s := spent[0]; s.Provider != domain.ProviderClaude || s.ConnectionID != 7 || s.OnCredits || s.RunID != 3 {
		t.Fatalf("claude call: %+v", s)
	}
	if s := spent[1]; s.Provider != domain.ProviderMuse || s.ConnectionID != 0 || !s.OnCredits {
		t.Fatalf("muse call: %+v", s)
	}
	if len(c.asked) != 3 || c.asked[0] != ai.Claude || c.asked[1] != ai.Muse || c.asked[2] != ai.Codex {
		t.Fatalf("credentials asked for %v", c.asked)
	}
}

type access struct{ a domain.Access }

func (a access) For(context.Context, int64) (domain.Access, error) { return a.a, nil }

// A call on a module its person may not use never reaches the provider,
// whether the access is on ctx or read for the person.
func TestRunRefusesModulesThePersonMayNotUse(t *testing.T) {
	g := ai.New(ai.Deps{Providers: aitest.Providers(), Access: access{domain.Access{Modules: []string{"muse"}}}})
	b := &box{}
	_, err := g.Run(context.Background(), ai.Call{Person: 4, Box: b, Req: ai.Request{Model: "opus"}}, nil)
	var na *domain.NotAllowedError
	if !errors.As(err, &na) || na.Module != ai.Claude || len(b.got) != 0 {
		t.Fatalf("err %v, calls %d", err, len(b.got))
	}
	ctx := domain.WithAccess(context.Background(), domain.Access{Modules: []string{"claude"}})
	if _, err := g.Run(ctx, ai.Call{Box: b, Req: ai.Request{Model: "muse:spark"}}, nil); !errors.As(err, &na) {
		t.Fatalf("access on ctx: %v", err)
	}
}
