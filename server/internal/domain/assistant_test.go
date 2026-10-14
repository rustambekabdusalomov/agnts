package domain

import (
	"strings"
	"testing"
	"unicode/utf8"
)

func TestTicketKeysIn(t *testing.T) {
	got := TicketKeysIn("What changed in pay-214 and PAY-214?", "see WEB-7, not foo-bar or 12-3", "PAY-9")
	if strings.Join(got, ",") != "PAY-214,WEB-7,PAY-9" {
		t.Errorf("keys = %v", got)
	}
}

func TestAssistantTitle(t *testing.T) {
	if got := AssistantTitle("  why   is\nmain red? "); got != "why is main red?" {
		t.Errorf("title = %q", got)
	}
	long := AssistantTitle(strings.Repeat("слово ", 40))
	if n := utf8.RuneCountInString(long); n > AssistantTitleLen || !strings.HasSuffix(long, "…") {
		t.Errorf("long title (%d runes) = %q", n, long)
	}
}
