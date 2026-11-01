package runner

import (
	"context"
	"strings"
	"testing"
)

func TestReadLoginPrompt(t *testing.T) {
	// What `muse login` 1.4.13 printed in the run image.
	out := "Open this page to sign in:\n  https://auth.meta.com/oauth/device/?code=ABCD-EFGH\nconfirm this code matches:\n  ABCD-EFGH\n\nWaiting for approval…\n"
	p, err := readLoginPrompt(context.Background(), strings.NewReader(out))
	if err != nil || p.URL != "https://auth.meta.com/oauth/device/?code=ABCD-EFGH" || p.Code != "ABCD-EFGH" {
		t.Fatalf("prompt = %+v, %v", p, err)
	}
	if _, err := readLoginPrompt(context.Background(), strings.NewReader("muse: not signed in\n")); err == nil {
		t.Fatal("no page printed must fail")
	}
}
