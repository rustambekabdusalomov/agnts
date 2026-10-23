package domain

import (
	"reflect"
	"strings"
	"testing"
)

func TestSplitSlides(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want []Slide
	}{
		{"one slide", "# Hello\n\nWorld", []Slide{{Body: "# Hello\n\nWorld", Layout: SlideLead}}},
		{"separators", "# A\n\n---\n\n# B\n  ---  \n# C", []Slide{
			{Body: "# A", Layout: SlideLead}, {Body: "# B", Layout: SlideLead}, {Body: "# C", Layout: SlideLead}}},
		{"empty slides dropped", "---\n\n# A\n---\n\n---\n# B\n---\n", []Slide{
			{Body: "# A", Layout: SlideLead}, {Body: "# B", Layout: SlideLead}}},
		{"--- inside a fence", "## Code\n\n```yaml\na: 1\n---\nb: 2\n```\n---\n# Next", []Slide{
			{Body: "## Code\n\n```yaml\na: 1\n---\nb: 2\n```", Layout: SlideNormal}, {Body: "# Next", Layout: SlideLead}}},
		{"longer fence", "````\n```\n---\n```\n````\n---\n# B", []Slide{
			{Body: "````\n```\n---\n```\n````", Layout: SlideNormal}, {Body: "# B", Layout: SlideLead}}},
		{"notes", "## Plan\n\n- one\n- two\n\nNotes: say it slowly\nand smile\n---\n# End\nNOTES:\nthanks", []Slide{
			{Body: "## Plan\n\n- one\n- two", Notes: "say it slowly\nand smile", Layout: SlideNormal},
			{Body: "# End", Notes: "thanks", Layout: SlideLead}}},
		{"notes: in a fence is text", "```\nnotes: x\n```", []Slide{{Body: "```\nnotes: x\n```", Layout: SlideNormal}}},
		{"front matter", "---\nmarp: true\ntheme: default\n---\n\n# Title\n---\n# Two", []Slide{
			{Body: "# Title", Layout: SlideLead}, {Body: "# Two", Layout: SlideLead}}},
		{"not front matter", "---\n# A\n---\n# B", []Slide{{Body: "# A", Layout: SlideLead}, {Body: "# B", Layout: SlideLead}}},
		{"lead with a subtitle", "# Sprint 42\n\nWhat shipped, Oct 22", []Slide{{Body: "# Sprint 42\n\nWhat shipped, Oct 22", Layout: SlideLead}}},
		{"a list is not lead", "# Sprint 42\n\n- one", []Slide{{Body: "# Sprint 42\n\n- one", Layout: SlideNormal}}},
		{"CRLF", "# A\r\n---\r\n# B", []Slide{{Body: "# A", Layout: SlideLead}, {Body: "# B", Layout: SlideLead}}},
		{"nothing", "\n\n---\n", nil},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := SplitSlides(tt.in); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("SplitSlides(%q)\n got %#v\nwant %#v", tt.in, got, tt.want)
			}
		})
	}
}

func TestSlideDensity(t *testing.T) {
	bullets := func(n int) string {
		var b strings.Builder
		b.WriteString("## Points\n")
		for range n {
			b.WriteString("- a point of ordinary length\n")
		}
		return b.String()
	}
	for _, tt := range []struct {
		n    int
		want SlideLayout
	}{{5, SlideNormal}, {13, SlideDense}, {20, SlideDenser}} {
		if got := SplitSlides(bullets(tt.n))[0].Layout; got != tt.want {
			t.Errorf("%d bullets: %s, want %s", tt.n, got, tt.want)
		}
	}
}

func TestSlidesWithoutNotes(t *testing.T) {
	got := SlidesWithoutNotes("# A\nNotes: secret plan\n---\n## B\n- x\nnotes: more")
	if want := "# A\n\n---\n\n## B\n- x"; got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestDocumentFile(t *testing.T) {
	if got := DocumentFile(DocKindSlides, "Deck", "\n# Deck\n---\n# Two\n\n"); got != "# Deck\n---\n# Two\n" {
		t.Errorf("slides: %q", got)
	}
	if got := DocumentFile(DocKindPage, "Page", "text"); got != "# Page\n\ntext\n" {
		t.Errorf("page: %q", got)
	}
}

func TestDocumentSourceOfAPage(t *testing.T) {
	s := DocumentSource{Kind: SourceDoc, DocumentID: 4}
	if err := s.Validate(); err != nil || s.Template != TemplatePresentation {
		t.Fatalf("document source: %v %s", err, s.Template)
	}
	if err := (&DocumentSource{Kind: SourceDoc}).Validate(); err == nil {
		t.Error("a document source without a document passed")
	}
}
