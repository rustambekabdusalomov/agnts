package connections

import (
	"os"
	"testing"

	"agnts/internal/domain"
)

// These tests cover Claude accounts; muse_test.go covers Muse ones.
func TestMain(m *testing.M) {
	domain.SetProviders([]string{domain.ProviderClaude, domain.ProviderCodex})
	os.Exit(m.Run())
}
