package documents

import (
	"errors"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

func TestSlidesFromAPage(t *testing.T) {
	f := setup(t)
	store := postgres.NewDocuments(f.pool)
	page := f.create(t, f.alice, "Sprint report", "# Sprint\n\nAll the detail.")
	if page.Doc.Kind != domain.DocKindPage {
		t.Fatalf("default kind: %q", page.Doc.Kind)
	}
	if err := f.s.Link(f.ctx, f.alice, page.Doc.ID, "T-1"); err != nil {
		t.Fatal(err)
	}
	fromPage := func() *domain.DocumentSource {
		return &domain.DocumentSource{Kind: domain.SourceDoc, DocumentID: page.Doc.ID}
	}
	slides := func(c Caller) (View, error) {
		return f.s.Create(f.ctx, c, NewDocument{Kind: domain.DocKindSlides, Title: "Sprint for the client", Source: fromPage()})
	}

	// Only someone who can open the page makes slides from it, and only slides.
	if _, err := slides(f.bob); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("bob without access: %v", err)
	}
	if _, err := f.s.Create(f.ctx, f.alice, NewDocument{Title: "A page from a page", Source: fromPage()}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("a page from a page: %v", err)
	}
	if _, err := f.s.Create(f.ctx, f.alice, NewDocument{Kind: "poster", Title: "x"}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("unknown kind: %v", err)
	}

	deck, err := slides(f.alice)
	if err != nil {
		t.Fatal(err)
	}
	d := deck.Doc
	if d.Kind != domain.DocKindSlides || !d.Generating() || d.Source.DocumentVersion != 1 || d.Source.Template != domain.TemplatePresentation ||
		d.DerivedFromID == nil || *d.DerivedFromID != page.Doc.ID {
		t.Fatalf("deck: %+v source %+v", d, d.Source)
	}
	if v, err := f.s.Get(f.ctx, f.alice, d.ID); err != nil || v.From == nil || v.From.Title != "Sprint report" || v.From.Version != 0 || v.From.Current != 1 {
		t.Fatalf("from while writing: %+v %v", v.From, err)
	}
	// Slides are not made from slides.
	if _, err := f.s.Create(f.ctx, f.alice, NewDocument{Kind: domain.DocKindSlides, Title: "x",
		Source: &domain.DocumentSource{Kind: domain.SourceDoc, DocumentID: d.ID}}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("slides from slides: %v", err)
	}

	// The generation finishes: the deck records the version it read and gets the page's tickets.
	finish := func(fromVersion int) {
		t.Helper()
		run, ok, err := store.ClaimDocumentRun(f.ctx)
		if err != nil || !ok {
			t.Fatalf("claim: %v %v", ok, err)
		}
		if _, err := store.FinishDocumentRun(f.ctx, run.ID, domain.DocRunResult{Status: domain.DocRunDone, DataAsOf: time.Now(), FromVersion: fromVersion,
			Tickets: []int64{f.ticket.ID}, Version: &domain.DocumentVersion{Title: d.Title, Body: "# Sprint\n\nShort\nNotes: say the long part\n\n---\n\n## Next\n\n- ship", Source: domain.VersionAI}}); err != nil {
			t.Fatal(err)
		}
	}
	finish(1)
	v, err := f.s.Get(f.ctx, f.alice, d.ID)
	if err != nil || v.From == nil || v.From.Version != 1 || v.Doc.TicketCount != 1 {
		t.Fatalf("after the run: %+v %+v %v", v.From, v.Doc, err)
	}

	// Bob may see the deck but not the page: nothing about the page is shown.
	if _, err := f.s.Share(f.ctx, f.alice, d.ID, Sharing{Type: domain.DocPrivate, Grants: []domain.DocumentGrant{{UserID: f.bob.UserID, Level: domain.AccessView}}}); err != nil {
		t.Fatal(err)
	}
	if v, err := f.s.Get(f.ctx, f.bob, d.ID); err != nil || v.From != nil {
		t.Fatalf("bob's view: %+v %v", v.From, err)
	}

	// Lists by kind and by the page.
	if vs, _ := f.s.List(f.ctx, f.alice, postgres.DocumentFilter{Kind: domain.DocKindSlides}); len(vs) != 1 || vs[0].Doc.ID != d.ID {
		t.Fatalf("slides only: %d", len(vs))
	}
	if vs, _ := f.s.List(f.ctx, f.alice, postgres.DocumentFilter{Kind: domain.DocKindPage}); len(vs) != 1 || vs[0].Doc.ID != page.Doc.ID {
		t.Fatalf("pages only: %d", len(vs))
	}
	if vs, _ := f.s.List(f.ctx, f.alice, postgres.DocumentFilter{DerivedFrom: page.Doc.ID}); len(vs) != 1 {
		t.Fatalf("made from the page: %d", len(vs))
	}
	if vs, _ := f.s.List(f.ctx, f.owner, postgres.DocumentFilter{DerivedFrom: page.Doc.ID}); len(vs) != 1 {
		t.Fatalf("the workspace owner sees it: %d", len(vs))
	}

	// The page moves on; regenerating reads it as it is now.
	if _, err := f.s.Save(f.ctx, f.alice, page.Doc.ID, "Sprint report", "# Sprint\n\nMore detail.", 1); err != nil {
		t.Fatal(err)
	}
	if v, _ := f.s.Get(f.ctx, f.alice, d.ID); v.From == nil || v.From.Version != 1 || v.From.Current != 2 {
		t.Fatalf("page moved on: %+v", v.From)
	}
	v, err = f.s.Regenerate(f.ctx, f.alice, d.ID, nil)
	if err != nil || v.Doc.Run == nil || v.Doc.Run.Source.DocumentVersion != 2 {
		t.Fatalf("regenerate: %+v %v", v.Doc.Run, err)
	}
	finish(2)

	// Downloads: the deck's text as is for people inside, without notes outside.
	file, err := f.s.Download(f.ctx, f.alice, d.ID, FormatMarkdown, 0, "")
	if err != nil || !strings.HasPrefix(string(file.Data), "# Sprint\n") || !strings.Contains(string(file.Data), "say the long part") {
		t.Fatalf("md: %q %v", file.Data, err)
	}
	if _, err := f.s.Share(f.ctx, f.alice, d.ID, Sharing{Type: domain.DocPublic}); err != nil {
		t.Fatal(err)
	}
	f.settled(t, d.ID, 2)
	got, _ := store.Document(f.ctx, d.ID)
	g, _ := f.join(t, got.PublicToken, "Client")
	pub, err := f.s.PublicDocument(g)
	if err != nil || pub.Kind != domain.DocKindSlides || strings.Contains(pub.Body, "long part") || !strings.Contains(pub.Body, "## Next") {
		t.Fatalf("public: %+v %v", pub, err)
	}
	pf, err := f.s.PublicDownload(g, FormatMarkdown)
	if err != nil || strings.Contains(string(pf.Data), "long part") {
		t.Fatalf("public md: %q %v", pf.Data, err)
	}
	if e, err := store.DocumentExport(f.ctx, d.ID, 2, ""); err != nil || e.Status != domain.ExportDone {
		t.Fatalf("deck PDF: %+v %v", e.Status, err)
	}

	// Once the page is gone, regenerating fails and the deck says nothing about it.
	if err := f.s.Delete(f.ctx, f.alice, page.Doc.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.Regenerate(f.ctx, f.alice, d.ID, nil); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("regenerate from a deleted page: %v", err)
	}
	if v, _ := f.s.Get(f.ctx, f.alice, d.ID); v.From != nil {
		t.Fatalf("from a deleted page: %+v", v.From)
	}
}

func TestPrintSlidesHTML(t *testing.T) {
	page := string(PrintSlidesHTML("Deck", "# Deck\n\nOct 22\n\n---\n\n## Point\n\n- a\n\nNotes: secret words\n", "uz"))
	for _, want := range []string{`<meta name="agnts-layout" content="slides">`, `<section class="slide lead">`, `<section class="slide normal">`,
		"1 / 2", "2 / 2", "@page { size: 254mm 142.875mm", `lang="uz"`} {
		if !strings.Contains(page, want) {
			t.Errorf("missing %q", want)
		}
	}
	if strings.Contains(page, "secret words") {
		t.Error("speaker notes were printed")
	}
}
