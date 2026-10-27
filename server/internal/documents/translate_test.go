package documents

import (
	"context"
	"errors"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
)

// fakeTranslator translates by prefixing the language, and keeps what it
// was asked so a test sees which texts were sent.
type fakeTranslator struct {
	mu    sync.Mutex
	asked [][]string
	store map[string]string
	err   error
}

func (f *fakeTranslator) TranslateTexts(_ context.Context, subject, lang string, texts []string) (map[string]string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.err != nil {
		return nil, f.err
	}
	if f.store == nil {
		f.store = map[string]string{}
	}
	var sent []string
	out := map[string]string{}
	for _, s := range texts {
		k := lang + "\x00" + s
		if _, ok := f.store[k]; !ok {
			f.store[k] = "[" + lang + "] " + s
			sent = append(sent, s)
		}
		out[s] = f.store[k]
	}
	f.asked = append(f.asked, sent)
	return out, nil
}

func TestTranslate(t *testing.T) {
	f := setup(t)
	tr := &fakeTranslator{}
	f.s.d.Translator = tr
	v := f.create(t, f.alice, "Sprint report", "# Done\n\nPayments shipped.\n\n```sh\nmake deploy\n```\n")

	if _, err := f.s.Translate(f.ctx, f.bob, v.Doc.ID, "ru"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("no access: %v", err)
	}
	if _, err := f.s.Translate(f.ctx, f.alice, v.Doc.ID, "xx"); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("unknown language: %v", err)
	}
	// A workspace viewer reads the document, so they can translate it.
	_, _ = f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate, WorkspaceAccess: domain.AccessView})
	got, err := f.s.Translate(f.ctx, f.vi, v.Doc.ID, "ru")
	if err != nil {
		t.Fatal(err)
	}
	if got.Title != "[ru] Sprint report" || !got.Complete || got.Version != 1 ||
		got.Body != "[ru] # Done\n\n[ru] Payments shipped.\n\n```sh\nmake deploy\n```\n" {
		t.Fatalf("translation = %+v", got)
	}

	// A new version sends only the block that changed.
	v, _ = f.s.Save(f.ctx, f.alice, v.Doc.ID, "Sprint report", "# Done\n\nPayments and refunds shipped.\n", 1)
	if got, err = f.s.Translate(f.ctx, f.alice, v.Doc.ID, "ru"); err != nil || got.Version != 2 {
		t.Fatalf("second translation = %+v, %v", got, err)
	}
	if last := tr.asked[len(tr.asked)-1]; len(last) != 1 || last[0] != "Payments and refunds shipped." {
		t.Fatalf("sent again: %q", last)
	}

	// Downloads in the language, named by the translated title.
	file, err := f.s.Download(f.ctx, f.alice, v.Doc.ID, FormatMarkdown, 0, "ru")
	if err != nil || file.Name != "ru-sprint-report-v2.ru.md" || !strings.Contains(string(file.Data), "[ru] Payments and refunds shipped.") {
		t.Fatalf("markdown: %+v %v", file, err)
	}
	if _, err := f.s.Download(f.ctx, f.alice, v.Doc.ID, FormatPDF, 0, "ru"); !errors.Is(err, ErrPreparing) {
		t.Fatalf("first translated pdf: %v", err)
	}
	f.pdf.wait(t)
	if _, err := f.s.Download(f.ctx, f.alice, v.Doc.ID, FormatPDF, 0, ""); !errors.Is(err, ErrPreparing) {
		t.Fatalf("the original's PDF is its own: %v", err)
	}
	f.pdf.wait(t)

	tr.err = errors.New("the Claude plan limit is reached")
	if _, err := f.s.Translate(f.ctx, f.alice, v.Doc.ID, "de"); err == nil {
		t.Fatal("a translator error was swallowed")
	}
	f.s.d.Translator = nil
	if _, err := f.s.Translate(f.ctx, f.alice, v.Doc.ID, "de"); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("without a translator: %v", err)
	}
}
