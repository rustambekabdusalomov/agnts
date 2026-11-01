package orchestrator

import (
	"context"
	"testing"

	"agnts/internal/domain"
)

// A call is recorded with its own module's account: in a run with a
// member's Claude account and Muse on credits, the Muse call is on
// credits and the Claude call is not.
func TestCallAccountIsTheCallsModule(t *testing.T) {
	ctx := domain.WithAccounts(context.Background(), domain.ProviderClaude, map[string]domain.ClaudeAccount{
		domain.ProviderClaude: {ConnectionID: 7, Provider: domain.ProviderClaude},
		domain.ProviderMuse:   {Credits: true, Provider: domain.ProviderMuse},
	})
	claude := domain.ClaudeCall{Model: "opus"}
	callAccount(ctx, &claude)
	if claude.Provider != domain.ProviderClaude || claude.ConnectionID != 7 || claude.OnCredits {
		t.Fatalf("claude call: %+v", claude)
	}
	muse := domain.ClaudeCall{Model: "muse:muse-spark-1.3"}
	callAccount(ctx, &muse)
	if muse.Provider != domain.ProviderMuse || muse.ConnectionID != 0 || !muse.OnCredits {
		t.Fatalf("muse call: %+v", muse)
	}
	none := domain.ClaudeCall{Model: "codex:gpt-5"}
	callAccount(context.Background(), &none)
	if none.Provider != domain.ProviderCodex || none.OnCredits {
		t.Fatalf("codex call without accounts: %+v", none)
	}
}
