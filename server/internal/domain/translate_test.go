package domain

import (
	"strings"
	"testing"
)

func translateAll(segs []Segment) map[string]string {
	tr := map[string]string{}
	for _, s := range segs {
		if s.Translate {
			tr[s.Text] = "T(" + strings.ReplaceAll(s.Text, "\n", "|") + ")"
		}
	}
	return tr
}

func TestSegmentPage(t *testing.T) {
	body := "# Title\n\nFirst paragraph\nsecond line.\n\n```go\nfunc main() {}\n```\n\n![shot](a.png)\n\n- one\n- two\n\n---\n\n| a | b |\n|---|---|\n| 1 | 2 |\n"
	segs := SegmentDocument(DocKindPage, body)
	joined, complete := JoinSegments(segs, nil)
	if joined != body || complete && len(SegmentTexts(segs)) > 0 {
		t.Fatalf("untranslated join = %q, complete %v", joined, complete)
	}
	texts := SegmentTexts(segs)
	want := []string{"# Title", "First paragraph\nsecond line.", "- one\n- two", "| a | b |\n|---|---|\n| 1 | 2 |"}
	if strings.Join(texts, "§") != strings.Join(want, "§") {
		t.Fatalf("texts = %q", texts)
	}
	got, complete := JoinSegments(segs, translateAll(segs))
	exp := "T(# Title)\n\nT(First paragraph|second line.)\n\n```go\nfunc main() {}\n```\n\n![shot](a.png)\n\nT(- one|- two)\n\n---\n\nT(| a | b |||---|---||| 1 | 2 |)\n"
	if got != exp || !complete {
		t.Fatalf("join = %q, complete %v", got, complete)
	}
}

func TestSegmentKeepsMissingAndMisshapen(t *testing.T) {
	segs := SegmentDocument(DocKindPage, "One.\n\nTwo.\n\nOne.")
	if texts := SegmentTexts(segs); len(texts) != 2 {
		t.Fatalf("repeated block sent twice: %q", texts)
	}
	got, complete := JoinSegments(segs, map[string]string{"One.": "Bir.", "Two.": "Ikki.\n\n---\nUch."})
	if got != "Bir.\n\nTwo.\n\nBir." || complete {
		t.Fatalf("join = %q, complete %v", got, complete)
	}
}

func TestSegmentDeck(t *testing.T) {
	body := "---\nmarp: true\n---\n\n# Deck\n\nIntro\n\nNotes: say hello\nand wave\n\n---\n\n## Second\n\n- point\n\nnotes:\n\nLong note.\n"
	segs := SegmentDocument(DocKindSlides, body)
	if joined, _ := JoinSegments(segs, nil); joined != body {
		t.Fatalf("untranslated join = %q", joined)
	}
	for _, s := range SegmentTexts(segs) {
		if strings.Contains(strings.ToLower(s), "notes:") || strings.Contains(s, "marp") {
			t.Fatalf("kept text sent: %q", s)
		}
	}
	got, _ := JoinSegments(segs, translateAll(segs))
	before, after := SplitSlides(body), SplitSlides(got)
	if len(after) != len(before) || len(after) != 2 {
		t.Fatalf("slides %d -> %d: %q", len(before), len(after), got)
	}
	if after[0].Notes != "T(say hello|and wave)" || after[0].Body != "T(# Deck)\n\nT(Intro)" || after[1].Notes != "T(Long note.)" {
		t.Fatalf("slides = %+v", after)
	}
}
