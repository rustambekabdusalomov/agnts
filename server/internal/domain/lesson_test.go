package domain

import (
	"strings"
	"testing"
)

func TestLessonNormalize(t *testing.T) {
	l := Lesson{Title: "  Ring buffer ", Summary: "Fixed-size FIFO.", Category: "Algorithm", Level: "expert"}
	if !l.Normalize() || l.Slug != "ring-buffer" || l.Category != "algorithm" || l.Level != "intermediate" {
		t.Fatalf("%+v", l)
	}
	if (&Lesson{Title: "No summary"}).Normalize() {
		t.Fatal("lesson without summary accepted")
	}
	long := Lesson{Title: strings.Repeat("ж", 100), Summary: "x"}
	if !long.Normalize() || len(long.Title) > 120 || !strings.HasPrefix(long.Title, "ж") || strings.ContainsRune(long.Title, '�') {
		t.Fatalf("title clipped badly: %q", long.Title)
	}
}

func TestReadMinutes(t *testing.T) {
	if m := (Lesson{Summary: "Short."}).ReadMinutes(); m != 1 {
		t.Fatalf("short lesson: %d", m)
	}
	prose := strings.Repeat("word ", 450)
	if m := (Lesson{Explanation: prose}).ReadMinutes(); m != 3 {
		t.Fatalf("450 words: %d", m)
	}
	code := "```\n" + strings.Repeat("x := y\n", 100) + "```" // 300 words, read at half speed
	if m := (Lesson{Explanation: code}).ReadMinutes(); m != 3 {
		t.Fatalf("code: %d", m)
	}
}
