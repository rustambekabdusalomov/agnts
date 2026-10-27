package documents

import (
	"context"
	"errors"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

type fakePDF struct {
	mu    sync.Mutex
	calls int
	fail  bool
	done  chan struct{}
}

func (f *fakePDF) RenderPDF(_ context.Context, html []byte) ([]byte, error) {
	f.mu.Lock()
	f.calls++
	fail := f.fail
	f.mu.Unlock()
	defer func() { f.done <- struct{}{} }()
	if fail {
		return nil, errors.New("chromium crashed")
	}
	if !strings.Contains(string(html), "<h1 class=\"doc-title\">") && !strings.Contains(string(html), `<meta name="agnts-layout" content="slides">`) {
		return nil, errors.New("not the print page")
	}
	return []byte("%PDF-1.7 fake"), nil
}

func (f *fakePDF) wait(t *testing.T) {
	t.Helper()
	select {
	case <-f.done:
	case <-time.After(5 * time.Second):
		t.Fatal("no render")
	}
}

type fakeGen struct{ wakes int }

func (g *fakeGen) Wake() { g.wakes++ }

type fakeNotifier struct {
	mu   sync.Mutex
	sent map[int64]int // user -> events
}

func (n *fakeNotifier) PublishTo(_, user int64, e domain.Event) {
	n.mu.Lock()
	defer n.mu.Unlock()
	if e.Type == EventDocumentUpdated {
		n.sent[user]++
	}
}

type fixture struct {
	s                     *Service
	ctx                   context.Context
	pool                  *pgxpool.Pool
	ws                    int64
	owner, alice, bob, vi Caller
	pdf                   *fakePDF
	gen                   *fakeGen
	notes                 *fakeNotifier
	settings              *postgres.Settings
	agent                 *postgres.Agent
	ticket                domain.Ticket
}

func setup(t *testing.T) fixture {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	slug := "docs-" + strings.ToLower(strings.ReplaceAll(t.Name(), "/", "-"))
	ctx, ws := pgtest.Workspace(t, pool, slug)
	sys := domain.System(context.Background())
	workspaces := postgres.NewWorkspaces(pool)
	w, err := workspaces.ByID(sys, ws)
	if err != nil {
		t.Fatal(err)
	}
	member := func(name string, role domain.WorkspaceRole) Caller {
		id := pgtest.User(t, pool, slug+"-"+name)
		pgtest.Exec(t, pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`, ws, id, string(role))
		return Caller{WorkspaceID: ws, UserID: id, Role: role}
	}
	f := fixture{ctx: ctx, pool: pool, ws: ws, owner: Caller{WorkspaceID: ws, UserID: w.OwnerID, Role: domain.RoleOwner},
		alice: member("alice", domain.RoleUser), bob: member("bob", domain.RoleUser), vi: member("vi", domain.RoleViewer),
		pdf: &fakePDF{done: make(chan struct{}, 10)}, gen: &fakeGen{}, notes: &fakeNotifier{sent: map[int64]int{}},
		settings: postgres.NewSettings(pool, domain.DefaultSettings()), agent: postgres.NewAgent(pool)}
	f.s = New(Deps{Store: postgres.NewDocuments(pool), Workspaces: workspaces, Tickets: f.agent, Settings: f.settings,
		Generator: f.gen, PDF: f.pdf, Notifier: f.notes})
	f.ticket, err = f.agent.CreateTicket(ctx, domain.Ticket{Key: "T-1", TicketNumber: "AMANAT-12", Source: domain.SourceLocal, Kind: domain.KindPlan,
		Title: "Plan the billing", Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"},
		domain.Event{TicketKey: "T-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	return f
}

// settled waits until the PDF of a version is no longer pending: the
// render reports back before the store has it.
func (f fixture) settled(t *testing.T, docID int64, version int) {
	t.Helper()
	f.pdf.wait(t)
	store := postgres.NewDocuments(f.pool)
	for range 100 {
		if e, err := store.DocumentExport(f.ctx, docID, version, ""); err == nil && e.Status != domain.ExportPending {
			return
		}
		time.Sleep(20 * time.Millisecond)
	}
	t.Fatal("the PDF stayed pending")
}

// join makes a guest of the public document with token and returns it
// with its secret token.
func (f fixture) join(t *testing.T, token, name string) (Guest, string) {
	t.Helper()
	sys := domain.System(context.Background())
	if _, _, err := f.s.Join(sys, token, domain.DocumentGuest{Name: "x"}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("a one-letter name: %v", err)
	}
	_, tok, err := f.s.Join(sys, token, domain.DocumentGuest{Name: name})
	if err != nil {
		t.Fatal(err)
	}
	g, err := f.s.Guest(sys, token, tok)
	if err != nil {
		t.Fatal(err)
	}
	return g, tok
}

func (f fixture) create(t *testing.T, c Caller, title, body string) View {
	t.Helper()
	v, err := f.s.Create(f.ctx, c, NewDocument{Title: title, Body: body})
	if err != nil {
		t.Fatal(err)
	}
	return v
}

func TestAccessThroughTheService(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Alice's plan", "first")
	if v.Access != domain.AccessOwner || v.Doc.Version != 1 {
		t.Fatalf("created: %+v", v)
	}
	// Bob cannot see it at all: 404, not 403.
	if _, err := f.s.Get(f.ctx, f.bob, v.Doc.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob reads a private document: %v", err)
	}
	if _, err := f.s.Save(f.ctx, f.bob, v.Doc.ID, "x", "y", 1); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob saves: %v", err)
	}
	// The workspace owner always can.
	if g, err := f.s.Get(f.ctx, f.owner, v.Doc.ID); err != nil || g.Access != domain.AccessOwner {
		t.Fatalf("workspace owner: %+v %v", g, err)
	}
	// A viewer cannot be given edit.
	if _, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate,
		Grants: []domain.DocumentGrant{{UserID: f.vi.UserID, Level: domain.AccessEdit}}}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("edit for a viewer: %v", err)
	}
	// With the workspace default at edit, a viewer still only reads.
	if _, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate, WorkspaceAccess: domain.AccessEdit,
		Grants: []domain.DocumentGrant{{UserID: f.bob.UserID, Level: domain.AccessView}}}); err != nil {
		t.Fatal(err)
	}
	if g, _ := f.s.Get(f.ctx, f.vi, v.Doc.ID); g.Access != domain.AccessView {
		t.Fatalf("viewer: %s", g.Access)
	}
	if _, err := f.s.Save(f.ctx, f.vi, v.Doc.ID, "Alice's plan", "viewer edit", 1); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("viewer saves: %v", err)
	}
	// Bob edits through the workspace default; only the owner shares.
	if _, err := f.s.Save(f.ctx, f.bob, v.Doc.ID, "Alice's plan", "bob's edit", 1); err != nil {
		t.Fatalf("bob edits: %v", err)
	}
	if _, err := f.s.Share(f.ctx, f.bob, v.Doc.ID, Sharing{Type: domain.DocPublic}); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("an editor publishes: %v", err)
	}
	// A stale save: 409 with what is current.
	got, err := f.s.Save(f.ctx, f.alice, v.Doc.ID, "Alice's plan", "alice from version 1", 1)
	if !errors.Is(err, domain.ErrConflict) || got.Doc.Body != "bob's edit" {
		t.Fatalf("stale save: %+v %v", got.Doc, err)
	}
	// Viewers may create their own documents and own them.
	mine := f.create(t, f.vi, "Viewer notes", "mine")
	if mine.Access != domain.AccessOwner {
		t.Fatalf("viewer's own document: %s", mine.Access)
	}
	// but cannot link tickets.
	if err := f.s.Link(f.ctx, f.vi, mine.Doc.ID, "T-1"); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("viewer links: %v", err)
	}
	// Members link by the ticket's number or its key.
	if err := f.s.Link(f.ctx, f.alice, v.Doc.ID, "AMANAT-12"); err != nil {
		t.Fatalf("link by number: %v", err)
	}
	if ts, _ := f.s.Tickets(f.ctx, f.alice, v.Doc.ID); len(ts) != 1 || ts[0].Key != "T-1" || ts[0].Number != "AMANAT-12" {
		t.Fatalf("linked: %+v", ts)
	}
	if err := f.s.Unlink(f.ctx, f.alice, v.Doc.ID, "T-1"); err != nil {
		t.Fatalf("unlink by key: %v", err)
	}
	if err := f.s.Link(f.ctx, f.alice, v.Doc.ID, "NOPE-9"); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("unknown ticket: %v", err)
	}
	// Only the people who can open a document hear about its changes.
	if f.notes.sent[f.alice.UserID] == 0 || f.notes.sent[f.owner.UserID] == 0 {
		t.Fatalf("events: %v", f.notes.sent)
	}
	f.notes.sent = map[int64]int{}
	private := f.create(t, f.alice, "Secret plan", "x")
	if _, err := f.s.Save(f.ctx, f.alice, private.Doc.ID, "Secret plan", "y", 1); err != nil {
		t.Fatal(err)
	}
	if f.notes.sent[f.bob.UserID] != 0 || f.notes.sent[f.vi.UserID] != 0 || f.notes.sent[f.alice.UserID] == 0 {
		t.Fatalf("a private change reached others: %v", f.notes.sent)
	}
}

func TestPublishing(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Status", "Token: ghp_abcdefghijklmnopqrstuvwxyz0123456789")
	var se *SecretsError
	if _, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPublic}); !errors.As(err, &se) || len(se.Findings) != 1 || se.Findings[0].Line != 1 {
		t.Fatalf("secret not caught: %v %+v", err, se)
	}
	v, _ = f.s.Save(f.ctx, f.alice, v.Doc.ID, "Status", "# All good\n\nNothing secret.", 1)
	pub, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPublic})
	if err != nil || pub.Doc.PublicToken == "" {
		t.Fatalf("publish: %+v %v", pub.Doc, err)
	}
	f.settled(t, v.Doc.ID, 2) // rendered ahead
	tok := pub.Doc.PublicToken
	sys := domain.System(context.Background())
	g, gtok := f.join(t, tok, "Client")
	p, err := f.s.PublicDocument(g)
	if err != nil || p.Title != "Status" || p.Version != 2 {
		t.Fatalf("public: %+v %v", p, err)
	}
	file, err := f.s.PublicDownload(g, FormatPDF)
	if err != nil || file.ContentType != "application/pdf" || file.Name != "status-v2.pdf" {
		t.Fatalf("public pdf: %+v %v", file, err)
	}
	md, err := f.s.PublicDownload(g, FormatMarkdown)
	if err != nil || !strings.HasPrefix(string(md.Data), "# Status\n\n# All good") {
		t.Fatalf("public md: %q %v", md.Data, err)
	}
	// A save renders the new version ahead; the public PDF waits for it
	// and a visitor never starts one.
	f.pdf.mu.Lock()
	f.pdf.fail = true
	f.pdf.mu.Unlock()
	if _, err := f.s.Save(f.ctx, f.alice, v.Doc.ID, "Status", "# Still good", 2); err != nil {
		t.Fatal(err)
	}
	f.settled(t, v.Doc.ID, 3)
	g, _ = f.s.Guest(sys, tok, gtok) // each request reads the document as it is now
	calls := f.pdf.calls
	for range 3 {
		if _, err := f.s.PublicDownload(g, FormatPDF); err == nil {
			t.Fatal("a failed render served")
		}
	}
	if f.pdf.calls != calls {
		t.Fatalf("a visitor started renders: %d → %d", calls, f.pdf.calls)
	}
	// Reset: the old link dies.
	reset, err := f.s.ResetLink(f.ctx, f.alice, v.Doc.ID)
	if err != nil || reset.Doc.PublicToken == tok {
		t.Fatalf("reset: %v", err)
	}
	if _, err := f.s.Guest(sys, tok, gtok); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("old link: %v", err)
	}
	// Private, then public again: a new token.
	if _, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate}); err != nil {
		t.Fatal(err)
	}
	again, _ := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPublic})
	if again.Doc.PublicToken == reset.Doc.PublicToken || again.Doc.PublicToken == "" {
		t.Fatal("public again kept the old token")
	}
	// The setting turns publishing off.
	st, _ := f.settings.Get(f.ctx)
	st.PublicDocuments = false
	_, _ = f.settings.Put(f.ctx, st, domain.OriginWeb)
	other := f.create(t, f.alice, "Other", "text")
	if _, err := f.s.Share(f.ctx, f.alice, other.Doc.ID, Sharing{Type: domain.DocPublic}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("publish with the setting off: %v", err)
	}
	if _, err := f.s.Info(sys, again.Doc.PublicToken); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("link with the setting off: %v", err)
	}
	if _, err := f.s.Info(sys, "../../etc"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bad token: %v", err)
	}
}

func TestDownloads(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Отчёт по спринту", "Первая версия")
	v, _ = f.s.Save(f.ctx, f.alice, v.Doc.ID, "Отчёт по спринту", "Вторая версия", 1)
	if _, err := f.s.Download(f.ctx, f.bob, v.Doc.ID, FormatMarkdown, 0, ""); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("no access: %v", err)
	}
	_, _ = f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate, Grants: []domain.DocumentGrant{{UserID: f.vi.UserID, Level: domain.AccessView}}})
	old, err := f.s.Download(f.ctx, f.vi, v.Doc.ID, FormatMarkdown, 1, "")
	if err != nil || old.Name != "otchyot-po-sprintu-v1.md" || !strings.Contains(string(old.Data), "Первая версия") {
		t.Fatalf("old version: %+v %v", old, err)
	}
	if _, err := f.s.Download(f.ctx, f.vi, v.Doc.ID, "docx", 0, ""); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("unknown format: %v", err)
	}
	// The first PDF download starts a render and asks to come back.
	if _, err := f.s.Download(f.ctx, f.vi, v.Doc.ID, FormatPDF, 0, ""); !errors.Is(err, ErrPreparing) {
		t.Fatalf("first pdf: %v", err)
	}
	f.settled(t, v.Doc.ID, 2)
	pdf, err := f.s.Download(f.ctx, f.vi, v.Doc.ID, FormatPDF, 0, "")
	if err != nil || pdf.Name != "otchyot-po-sprintu-v2.pdf" || !strings.HasPrefix(string(pdf.Data), "%PDF") {
		t.Fatalf("pdf: %+v %v", pdf, err)
	}
	if f.pdf.calls != 1 {
		t.Fatalf("renders: %d", f.pdf.calls)
	}
}

func TestPrintHTML(t *testing.T) {
	page := string(PrintHTML("Report <x>", "# Report <x>\n\n| a | b |\n|---|---|\n| 1 | oʻzbek |\n\n<script>alert(1)</script>\n\n![logo](https://evil.example/x.png)\n\n[click](javascript:alert(1))\n", 3,
		time.Date(2026, 10, 22, 0, 0, 0, 0, time.UTC), "uz"))
	for _, bad := range []string{"<script>", "evil.example", "javascript:"} {
		if strings.Contains(page, bad) {
			t.Errorf("page has %q", bad)
		}
	}
	for _, good := range []string{"<table>", "oʻzbek", "Version 3 · Oct 22, 2026", "Report &lt;x&gt;", `[logo]`, `lang="uz"`, "Noto Sans"} {
		if !strings.Contains(page, good) {
			t.Errorf("page lacks %q", good)
		}
	}
	if strings.Count(page, "Report &lt;x&gt;</h1>") != 1 {
		t.Errorf("the title heading is printed twice")
	}
}

func TestGenerationRequests(t *testing.T) {
	f := setup(t)
	// A ticket without a report cannot be the source.
	if _, err := f.s.CreateFromReport(f.ctx, f.alice, "T-1", "", "en"); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("no report: %v", err)
	}
	pgtest.Exec(t, f.pool, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, 'code', 'x')`, f.ticket.ID)
	pgtest.Exec(t, f.pool, `INSERT INTO results (run_id, summary, report) SELECT id, '{}', '# The plan' FROM runs WHERE ticket_id = $1`, f.ticket.ID)
	// People name the ticket by its number; the source keeps the key.
	v, err := f.s.CreateFromReport(f.ctx, f.alice, "amanat-12", "for the client", "ru")
	if err != nil || v.Doc.Version != 0 || !v.Doc.Generating() || v.Doc.Title != "AMANAT-12: Plan the billing" || v.Doc.Language != "ru" || f.gen.wakes != 1 {
		t.Fatalf("from report: %+v %v (wakes %d)", v.Doc, err, f.gen.wakes)
	}
	if v.Doc.Source == nil || v.Doc.Source.TicketKeys[0] != "T-1" {
		t.Fatalf("source keeps the key: %+v", v.Doc.Source)
	}
	// Linked right away, so the ticket page shows it while it is written.
	if ds, _ := f.s.TicketDocuments(f.ctx, f.alice, "T-1"); len(ds) != 1 {
		t.Fatalf("ticket documents: %d", len(ds))
	}
	if ds, _ := f.s.TicketDocuments(f.ctx, f.bob, "T-1"); len(ds) != 0 {
		t.Fatalf("bob sees a private document on the ticket: %d", len(ds))
	}
	// While it is written: no second run, no body edits, but the title may change.
	if _, err := f.s.Regenerate(f.ctx, f.alice, v.Doc.ID, nil); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("second run: %v", err)
	}
	if _, err := f.s.Save(f.ctx, f.alice, v.Doc.ID, v.Doc.Title, "my text", 0); !errors.Is(err, ErrBusy) {
		t.Fatalf("body edit while writing: %v", err)
	}
	if r, err := f.s.Save(f.ctx, f.alice, v.Doc.ID, "Plan for the client", "", 0); err != nil || r.Doc.Title != "Plan for the client" {
		t.Fatalf("rename while writing: %+v %v", r.Doc, err)
	}
	// A hand-written document needs a source to regenerate.
	hand := f.create(t, f.alice, "By hand", "x")
	if _, err := f.s.Regenerate(f.ctx, f.alice, hand.Doc.ID, nil); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("regenerate by hand: %v", err)
	}
	if _, err := f.s.Regenerate(f.ctx, f.alice, hand.Doc.ID, &domain.DocumentSource{Kind: domain.SourceRepo, RepoIDs: []int64{424242}}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("unknown repository: %v", err)
	}
}

func TestTrash(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Old", "x")
	if err := f.s.Delete(f.ctx, f.bob, v.Doc.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob deletes: %v", err)
	}
	if err := f.s.Delete(f.ctx, f.alice, v.Doc.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.Get(f.ctx, f.alice, v.Doc.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("deleted still opens: %v", err)
	}
	if _, err := f.s.Undelete(f.ctx, f.bob, v.Doc.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob restores: %v", err)
	}
	if r, err := f.s.Undelete(f.ctx, f.alice, v.Doc.ID); err != nil || r.Doc.DeletedAt != nil {
		t.Fatalf("owner restores: %v", err)
	}
	_ = f.s.Delete(f.ctx, f.alice, v.Doc.ID)
	if r, err := f.s.Undelete(f.ctx, f.owner, v.Doc.ID); err != nil || r.Doc.DeletedAt != nil {
		t.Fatalf("workspace owner restores: %v", err)
	}
}
