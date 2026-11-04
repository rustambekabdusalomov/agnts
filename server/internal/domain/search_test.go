package domain

import (
	"strings"
	"testing"
)

func TestSearchWords(t *testing.T) {
	got := strings.Join(SearchWords(`  Invoice-March, "отчёт" a CSV csv 2026 x`), "|")
	if got != "invoice|march|отчёт|csv|2026" {
		t.Fatalf("words = %q", got)
	}
	if len(SearchWords("a b c")) != 0 {
		t.Fatal("one-letter words are left out")
	}
}

func TestSearchSnippet(t *testing.T) {
	m := func(s string) string { return SearchMarkStart + s + SearchMarkEnd }
	if got := SearchSnippet("The CSV export times out", []string{"csv", "exp"}, 80); got != "The "+m("CSV")+" "+m("exp")+"ort times out" {
		t.Fatalf("snippet = %q", got)
	}
	// Only a word's start matches; a long text is cut around the match.
	long := strings.Repeat("filler ", 40) + "the refund failed " + strings.Repeat("tail ", 40)
	got := SearchSnippet(long, []string{"refund", "ail"}, 60)
	if !strings.HasPrefix(got, "…") || !strings.HasSuffix(got, "…") || !strings.Contains(got, m("refund")) || strings.Contains(got, m("ail")) {
		t.Fatalf("snippet = %q", got)
	}
	if got := SearchSnippet("Отчёт за март готов", []string{"март"}, 80); got != "Отчёт за "+m("март")+" готов" {
		t.Fatalf("cyrillic snippet = %q", got)
	}
}
