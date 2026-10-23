package orchestrator_test

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestSlidesFromAPage(t *testing.T) {
	h := newDocHarness(t)
	tk := h.ticketWithReport("DOC-9", "# Plan")
	page, err := h.docs.CreateDocument(h.ctx, domain.Document{Title: "Refunds plan", OwnerID: h.owner, Language: "en"},
		&domain.DocumentVersion{Title: "Refunds plan", Body: "## Detail\n\nThe refunds endpoint calls the payments API.", Source: domain.VersionHuman, AuthorID: &h.owner})
	if err != nil {
		t.Fatal(err)
	}
	if err := h.docs.LinkDocumentTicket(h.ctx, page.ID, tk.ID, nil); err != nil {
		t.Fatal(err)
	}
	src := domain.DocumentSource{Kind: domain.SourceDoc, DocumentID: page.ID, DocumentVersion: 1}
	if err := src.Validate(); err != nil {
		t.Fatal(err)
	}
	deck, err := h.docs.CreateDocument(h.ctx, domain.Document{Kind: domain.DocKindSlides, Title: "Refunds", OwnerID: h.owner, Language: "en",
		Source: &src, DerivedFromID: &page.ID}, nil)
	if err != nil {
		t.Fatal(err)
	}
	queue := func() {
		t.Helper()
		if _, err := h.docs.CreateDocumentRun(h.ctx, deck.ID, src, &h.owner, orchestrator.DocumentPromptVersion); err != nil {
			t.Fatal(err)
		}
	}

	// Text without separators is not a deck: the generation fails.
	queue()
	h.runner.scripts = []script{{result: withUsage(ok("s0")), files: map[string]string{orchestrator.DocOutPath: generated}}}
	h.step()
	if got, _ := h.docs.Document(h.ctx, deck.ID); got.Run.Status != domain.DocRunFailed || !strings.Contains(got.Run.Error, "no slides") || got.Version != 0 {
		t.Fatalf("no slides: %+v", got.Run)
	}

	queue()
	h.runner.scripts = []script{{result: withUsage(ok("s1")), files: map[string]string{orchestrator.DocOutPath: "# Refunds\n\nOct 22\n\n---\n\n## What changes\n\n- Refunds in one click (AMANAT-7)\n"}}}
	h.step()

	p := h.runner.prompts[len(h.runner.prompts)-1]
	for _, want := range []string{"slide deck titled \"Refunds\"", "exactly ---", "Notes:", orchestrator.DocSourcesDir + "/document.md", "title slide"} {
		if !strings.Contains(p, want) {
			t.Errorf("prompt lacks %q:\n%s", want, p)
		}
	}
	if strings.Contains(p, "Do not repeat the title") {
		t.Error("a deck was told not to start with its title")
	}
	if s := h.runner.written[orchestrator.DocSourcesDir+"/document.md"]; !strings.Contains(s, "calls the payments API") || !strings.Contains(s, "Version 1") {
		t.Fatalf("gathered page:\n%s", s)
	}
	got, err := h.docs.Document(h.ctx, deck.ID)
	if err != nil || got.Version != 1 || got.DerivedFromVersion == nil || *got.DerivedFromVersion != 1 || got.TicketCount != 1 {
		t.Fatalf("deck after the run: %+v %v", got, err)
	}

	// A page that went away fails the next generation.
	if err := h.docs.DeleteDocument(h.ctx, page.ID); err != nil {
		t.Fatal(err)
	}
	queue()
	h.step()
	if got, _ := h.docs.Document(h.ctx, deck.ID); got.Run.Status != domain.DocRunFailed || !strings.Contains(got.Run.Error, "gone") {
		t.Fatalf("deleted page: %+v", got.Run)
	}
}
