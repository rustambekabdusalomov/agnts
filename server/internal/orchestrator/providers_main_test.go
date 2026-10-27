package orchestrator_test

import (
	"os"
	"testing"

	"agnts/internal/domain"
)

// The orchestrator's tests were written for Claude Code's models and
// accounts; they run with Claude as the primary tool. Muse's own paths
// are tested in muse_test.go, which switches the provider per test.
func TestMain(m *testing.M) {
	domain.SetProviders([]string{domain.ProviderClaude, domain.ProviderCodex, domain.ProviderMuse})
	os.Exit(m.Run())
}
