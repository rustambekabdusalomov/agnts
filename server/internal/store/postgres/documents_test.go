package postgres

import (
	"context"
	"errors"
	"fmt"
	"math/rand/v2"
	"slices"
	"testing"
	"time"

	"agnts/internal/domain"
)

type docFixture struct {
	ctx            context.Context
	ws             int64
	s              *Documents
	users          *Users
	owner          int64 // the workspace's owner
	alice, bob, vi int64 // members: alice and bob users, vi a viewer
}

func newDocFixture(t *testing.T) docFixture {
	t.Helper()
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	sys := domain.System(context.Background())
	w, err := NewWorkspaces(users.db).ByID(sys, ws)
	if err != nil {
		t.Fatal(err)
	}
	f := docFixture{ctx: ctx, ws: ws, s: NewDocuments(users.db), users: users, owner: w.OwnerID}
	add := func(name string, role domain.WorkspaceRole) int64 {
		u, err := users.Create(sys, domain.User{Username: fmt.Sprintf("%s-%d-%s", name, ws, t.Name()), PasswordHash: "h"})
		if err != nil {
			t.Fatal(err)
		}
		if err := NewWorkspaces(users.db).AddMember(sys, ws, u.ID, role); err != nil {
			t.Fatal(err)
		}
		return u.ID
	}
	f.alice, f.bob, f.vi = add("alice", domain.RoleUser), add("bob", domain.RoleUser), add("vi", domain.RoleViewer)
	return f
}

func (f docFixture) create(t *testing.T, owner int64, title string) domain.Document {
	t.Helper()
	d, err := f.s.CreateDocument(f.ctx, domain.Document{Title: title, OwnerID: owner, Language: "en"},
		&domain.DocumentVersion{Title: title, Body: "body of " + title, Source: domain.VersionHuman, AuthorID: &owner})
	if err != nil {
		t.Fatal(err)
	}
	return d
}

func TestDocumentsCreateAndVersions(t *testing.T) {
	f := newDocFixture(t)
	d := f.create(t, f.alice, "Sprint report")
	if d.Version != 1 || d.Body != "body of Sprint report" || d.Type != domain.DocPrivate || d.OwnerID != f.alice || d.OwnerName == "" {
		t.Fatalf("created: %+v", d)
	}
	// A save from the current version makes version 2.
	d, err := f.s.SaveDocumentVersion(f.ctx, d.ID, 1, domain.DocumentVersion{Title: "Sprint report", Body: "v2", Source: domain.VersionHuman, AuthorID: &f.bob})
	if err != nil || d.Version != 2 || d.Body != "v2" {
		t.Fatalf("save: %+v %v", d, err)
	}
	// A save that started from version 1 is refused, and answers what is current.
	d, err = f.s.SaveDocumentVersion(f.ctx, d.ID, 1, domain.DocumentVersion{Title: "x", Body: "stale", Source: domain.VersionHuman})
	if !errors.Is(err, domain.ErrConflict) || d.Body != "v2" {
		t.Fatalf("stale save: %+v %v", d, err)
	}
	// A restore skips the check.
	if d, err = f.s.SaveDocumentVersion(f.ctx, d.ID, -1, domain.DocumentVersion{Title: "Sprint report", Body: "body of Sprint report", Source: domain.VersionRestore}); err != nil || d.Version != 3 {
		t.Fatalf("restore: %+v %v", d, err)
	}
	vs, err := f.s.DocumentVersions(f.ctx, d.ID)
	if err != nil || len(vs) != 3 || vs[0].Version != 3 || vs[0].Source != domain.VersionRestore || vs[1].Body != "" || vs[1].AuthorName == "" {
		t.Fatalf("versions: %+v %v", vs, err)
	}
	v1, err := f.s.DocumentVersion(f.ctx, d.ID, 1)
	if err != nil || v1.Body != "body of Sprint report" {
		t.Fatalf("version 1: %+v %v", v1, err)
	}
	if _, err := f.s.DocumentVersion(f.ctx, d.ID, 9); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing version: %v", err)
	}
	// Another workspace sees nothing.
	other, _ := testWS(t, f.users)
	if _, err := f.s.Document(other, d.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace reads it: %v", err)
	}
}

// TestDocumentsListMatchesAccessRule checks that the list shows exactly
// the documents EffectiveAccess lets each person open, over random grants
// and workspace defaults.
func TestDocumentsListMatchesAccessRule(t *testing.T) {
	f := newDocFixture(t)
	people := map[int64]domain.WorkspaceRole{f.owner: domain.RoleOwner, f.alice: domain.RoleUser, f.bob: domain.RoleUser, f.vi: domain.RoleViewer}
	ids := []int64{f.owner, f.alice, f.bob, f.vi}
	rng := rand.New(rand.NewPCG(1, 2))
	levels := []domain.AccessLevel{domain.AccessNone, domain.AccessView, domain.AccessEdit}
	grants := map[int64]map[int64]domain.AccessLevel{}
	var docs []domain.Document
	for i := range 30 {
		owner := ids[1+rng.IntN(3)]
		d := f.create(t, owner, fmt.Sprintf("doc %d", i))
		sh := Sharing{Type: domain.DocPrivate, WorkspaceAccess: levels[rng.IntN(3)]}
		grants[d.ID] = map[int64]domain.AccessLevel{}
		for _, u := range ids {
			if l := levels[rng.IntN(3)]; l != domain.AccessNone && u != owner {
				sh.Grants = append(sh.Grants, domain.DocumentGrant{UserID: u, Level: l})
				grants[d.ID][u] = l
			}
		}
		d, err := f.s.SetDocumentSharing(f.ctx, d.ID, sh, owner)
		if err != nil {
			t.Fatal(err)
		}
		docs = append(docs, d)
	}
	for _, u := range ids {
		got, gs, err := f.s.ListDocuments(f.ctx, u, people[u], DocumentFilter{})
		if err != nil {
			t.Fatal(err)
		}
		var gotIDs, want []int64
		for i, d := range got {
			gotIDs = append(gotIDs, d.ID)
			if gs[i] != grants[d.ID][u] {
				t.Errorf("user %d doc %d: grant %s, want %s", u, d.ID, gs[i], grants[d.ID][u])
			}
		}
		for _, d := range docs {
			if domain.EffectiveAccess(d, u, people[u], grants[d.ID][u]) > domain.AccessNone {
				want = append(want, d.ID)
			}
		}
		slices.Sort(gotIDs)
		slices.Sort(want)
		if !slices.Equal(gotIDs, want) {
			t.Errorf("user %d (%s): list %v, rule %v", u, people[u], gotIDs, want)
		}
	}
	// Mine and shared split what alice can open by owner.
	mine, _, _ := f.s.ListDocuments(f.ctx, f.alice, domain.RoleUser, DocumentFilter{Scope: "mine"})
	for _, d := range mine {
		if d.OwnerID != f.alice {
			t.Errorf("mine has %d of %d", d.ID, d.OwnerID)
		}
	}
	shared, _, _ := f.s.ListDocuments(f.ctx, f.alice, domain.RoleUser, DocumentFilter{Scope: "shared"})
	for _, d := range shared {
		if d.OwnerID == f.alice {
			t.Errorf("shared has alice's own %d", d.ID)
		}
	}
	if q, _, _ := f.s.ListDocuments(f.ctx, f.owner, domain.RoleOwner, DocumentFilter{Query: "DOC 1"}); len(q) != 11 { // doc 1, doc 10..19
		t.Errorf("query: %d", len(q))
	}
}

func TestDocumentsSharingAndPublic(t *testing.T) {
	f := newDocFixture(t)
	d := f.create(t, f.alice, "Release notes")
	stranger, err := f.users.Create(domain.System(context.Background()), domain.User{Username: "stranger-" + t.Name(), PasswordHash: "h"})
	if err != nil {
		t.Fatal(err)
	}
	tok, _ := domain.NewPublicToken()
	d, err = f.s.SetDocumentSharing(f.ctx, d.ID, Sharing{Type: domain.DocPublic, PublicToken: tok, WorkspaceAccess: domain.AccessView,
		Grants: []domain.DocumentGrant{{UserID: f.bob, Level: domain.AccessEdit}, {UserID: stranger.ID, Level: domain.AccessEdit}}}, f.alice)
	if err != nil || d.Type != domain.DocPublic || d.PublicToken != tok || d.WorkspaceAccess != domain.AccessView {
		t.Fatalf("share: %+v %v", d, err)
	}
	gs, _ := f.s.DocumentGrants(f.ctx, d.ID)
	if len(gs) != 1 || gs[0].UserID != f.bob || gs[0].Level != domain.AccessEdit {
		t.Fatalf("grants (a non-member is never granted): %+v", gs)
	}
	sys := domain.System(context.Background())
	pub, err := f.s.PublicDocument(sys, tok)
	if err != nil || pub.Title != "Release notes" || pub.Body != "body of Release notes" || pub.Version != 1 {
		t.Fatalf("public: %+v %v", pub, err)
	}
	// Keeping it public keeps the token.
	if d, err = f.s.SetDocumentSharing(f.ctx, d.ID, Sharing{Type: domain.DocPublic, WorkspaceAccess: domain.AccessNone}, f.alice); err != nil || d.PublicToken != tok {
		t.Fatalf("keep token: %+v %v", d, err)
	}
	// The workspace setting turns every link off.
	settings := NewSettings(f.users.db, domain.DefaultSettings())
	v, _ := settings.Get(f.ctx)
	v.PublicDocuments = false
	if _, err := settings.Put(f.ctx, v, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.PublicDocument(sys, tok); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("setting off: %v", err)
	}
	v.PublicDocuments = true
	_, _ = settings.Put(f.ctx, v, domain.OriginWeb)
	if _, err := f.s.PublicDocument(sys, tok); err != nil {
		t.Fatalf("setting on again: %v", err)
	}
	// Private: dead. Deleted: dead.
	if _, err := f.s.SetDocumentSharing(f.ctx, d.ID, Sharing{Type: domain.DocPrivate}, f.alice); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.PublicDocument(sys, tok); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("private: %v", err)
	}
	tok2, _ := domain.NewPublicToken()
	_, _ = f.s.SetDocumentSharing(f.ctx, d.ID, Sharing{Type: domain.DocPublic, PublicToken: tok2}, f.alice)
	if err := f.s.DeleteDocument(f.ctx, d.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.PublicDocument(sys, tok2); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("deleted: %v", err)
	}
	if _, err := f.s.SaveDocumentVersion(f.ctx, d.ID, -1, domain.DocumentVersion{Title: "x", Source: domain.VersionHuman}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("save to deleted: %v", err)
	}
	trash, _, _ := f.s.ListDocuments(f.ctx, f.alice, domain.RoleUser, DocumentFilter{Scope: "deleted"})
	if len(trash) != 1 {
		t.Fatalf("trash: %+v", trash)
	}
	if bobTrash, _, _ := f.s.ListDocuments(f.ctx, f.bob, domain.RoleUser, DocumentFilter{Scope: "deleted"}); len(bobTrash) != 0 {
		t.Fatalf("bob sees alice's trash: %+v", bobTrash)
	}
	if _, err := f.s.RestoreDocument(f.ctx, d.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.PublicDocument(sys, tok2); err != nil {
		t.Fatalf("restored: %v", err)
	}
	// Purge removes only what was deleted before the cut-off.
	_ = f.s.DeleteDocument(f.ctx, d.ID)
	if n, err := f.s.PurgeDocuments(sys, time.Now().Add(-time.Hour)); err != nil || n != 0 {
		t.Fatalf("purge young: %d %v", n, err)
	}
	if n, err := f.s.PurgeDocuments(sys, time.Now().Add(time.Minute)); err != nil || n < 1 {
		t.Fatalf("purge: %d %v", n, err)
	}
}

func TestDocumentsOwnerAndHandOver(t *testing.T) {
	f := newDocFixture(t)
	ws := NewWorkspaces(f.users.db)
	sys := domain.System(context.Background())
	a := f.create(t, f.alice, "Alice's plan")
	b := f.create(t, f.bob, "Bob's notes")
	if _, err := f.s.SetDocumentSharing(f.ctx, b.ID, Sharing{Type: domain.DocPrivate, Grants: []domain.DocumentGrant{{UserID: f.alice, Level: domain.AccessEdit}}}, f.bob); err != nil {
		t.Fatal(err)
	}
	// Transfer: the new owner's grant goes, the old owner keeps edit.
	if _, err := f.s.SetDocumentOwner(f.ctx, b.ID, f.alice); err != nil {
		t.Fatal(err)
	}
	b, _ = f.s.Document(f.ctx, b.ID)
	if l, _ := f.s.DocumentGrant(f.ctx, b.ID, f.bob); b.OwnerID != f.alice || l != domain.AccessEdit {
		t.Fatalf("transfer: owner %d, bob %s", b.OwnerID, l)
	}
	if l, _ := f.s.DocumentGrant(f.ctx, b.ID, f.alice); l != domain.AccessNone {
		t.Fatalf("new owner kept a grant: %s", l)
	}
	if _, err := f.s.SetDocumentOwner(f.ctx, b.ID, 999999); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("transfer to a stranger: %v", err)
	}
	// Alice leaves: her documents go to the workspace owner, bob's grant stays.
	if err := ws.RemoveMember(sys, f.ws, f.alice); err != nil {
		t.Fatal(err)
	}
	for _, id := range []int64{a.ID, b.ID} {
		d, _ := f.s.Document(f.ctx, id)
		if d.OwnerID != f.owner {
			t.Errorf("doc %d owner %d, want the workspace owner %d", id, d.OwnerID, f.owner)
		}
	}
	if l, _ := f.s.DocumentGrant(f.ctx, b.ID, f.bob); l != domain.AccessEdit {
		t.Errorf("bob's grant: %s", l)
	}
	// Bob leaves: his grant goes.
	if err := ws.RemoveMember(sys, f.ws, f.bob); err != nil {
		t.Fatal(err)
	}
	if l, _ := f.s.DocumentGrant(f.ctx, b.ID, f.bob); l != domain.AccessNone {
		t.Errorf("grant of a member who left: %s", l)
	}
	// Deleting an account hands over first; a plain delete would fail on
	// the owner foreign key.
	c := f.create(t, f.vi, "Viewer's doc")
	if _, err := f.users.db.Exec(sys, `DELETE FROM users WHERE id = $1`, f.vi); err == nil {
		t.Fatal("a delete without the hand-over passed the foreign key")
	}
	if err := f.users.Delete(sys, f.vi); err != nil {
		t.Fatal(err)
	}
	if d, _ := f.s.Document(f.ctx, c.ID); d.OwnerID != f.owner {
		t.Fatalf("after account delete: owner %d", d.OwnerID)
	}
}

func TestDocumentsTicketsRunsAndExports(t *testing.T) {
	f := newDocFixture(t)
	agent := NewAgent(f.users.db)
	repo, err := agent.SaveRepository(f.ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	tk, err := agent.CreateTicket(f.ctx, domain.Ticket{Key: "DOC-1", Source: domain.SourceLocal, Kind: domain.KindPlan, RepoID: &repo.ID,
		Title: "Plan it", Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"},
		domain.Event{TicketKey: "DOC-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	// A generated document starts at version 0.
	src := domain.DocumentSource{Kind: domain.SourceReport, Template: domain.TemplateTicketSummary, TicketKeys: []string{"DOC-1"}}
	d, err := f.s.CreateDocument(f.ctx, domain.Document{Title: "From the plan", OwnerID: f.alice, Language: "en", Source: &src}, nil)
	if err != nil || d.Version != 0 || d.Source == nil || d.Source.Kind != domain.SourceReport {
		t.Fatalf("create: %+v %v", d, err)
	}
	run, err := f.s.CreateDocumentRun(f.ctx, d.ID, src, &f.alice, "v1")
	if err != nil || run.Status != domain.DocRunQueued {
		t.Fatalf("run: %+v %v", run, err)
	}
	if _, err := f.s.CreateDocumentRun(f.ctx, d.ID, src, &f.alice, "v1"); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("second run while one waits: %v", err)
	}
	pend, err := f.s.PendingDocumentWorkspaces(domain.System(context.Background()))
	if err != nil || !slices.ContainsFunc(pend, func(p domain.PendingDocument) bool { return p.WorkspaceID == f.ws && *p.RequestedBy == f.alice }) {
		t.Fatalf("pending: %+v %v", pend, err)
	}
	claimed, ok, err := f.s.ClaimDocumentRun(f.ctx)
	if err != nil || !ok || claimed.ID != run.ID || claimed.Status != domain.DocRunWriting || claimed.Source.TicketKeys[0] != "DOC-1" {
		t.Fatalf("claim: %+v %v %v", claimed, ok, err)
	}
	if _, ok, _ := f.s.ClaimDocumentRun(f.ctx); ok {
		t.Fatal("claimed twice")
	}
	if n, err := f.s.RecoverDocumentRuns(domain.System(context.Background())); err != nil || n < 1 {
		t.Fatalf("recover: %d %v", n, err)
	}
	claimed, _, _ = f.s.ClaimDocumentRun(f.ctx)
	// Spend has no ticket.
	if err := f.s.RecordDocumentCall(f.ctx, claimed.ID, domain.ClaudeCall{ModelStage: "document", Model: "sonnet",
		Usage: domain.TokenUsage{Input: 10, Output: 5, CostUSD: 0.42}, Turns: 3}); err != nil {
		t.Fatal(err)
	}
	if usd, err := f.s.DocumentRunCostUSD(f.ctx, claimed.ID); err != nil || usd < 0.41 || usd > 0.43 {
		t.Fatalf("cost: %v %v", usd, err)
	}
	asOf := time.Now().Truncate(time.Second)
	d, err = f.s.FinishDocumentRun(f.ctx, claimed.ID, domain.DocRunResult{Status: domain.DocRunDone, DataAsOf: asOf, Tickets: []int64{tk.ID},
		Version: &domain.DocumentVersion{Title: "From the plan", Body: "# Summary", Source: domain.VersionAI, Note: src.Note()}})
	if err != nil || d.Version != 1 || d.Body != "# Summary" || d.TicketCount != 1 || d.Run == nil || d.Run.Status != domain.DocRunDone || d.DataAsOf == nil {
		t.Fatalf("finish: %+v %v", d, err)
	}
	if v, _ := f.s.DocumentVersion(f.ctx, d.ID, 1); v.RunID == nil || *v.RunID != claimed.ID || v.Source != domain.VersionAI {
		t.Fatalf("ai version: %+v", v)
	}
	// Links: auto-linked once, linking again is fine, listing by ticket.
	if err := f.s.LinkDocumentTicket(f.ctx, d.ID, tk.ID, &f.alice); err != nil {
		t.Fatal(err)
	}
	links, _ := f.s.DocumentTickets(f.ctx, d.ID)
	if len(links) != 1 || links[0].Key != "DOC-1" || links[0].LinkedBy != nil {
		t.Fatalf("links: %+v", links)
	}
	byTicket, _, _ := f.s.ListDocuments(f.ctx, f.alice, domain.RoleUser, DocumentFilter{TicketKey: "DOC-1"})
	if len(byTicket) != 1 {
		t.Fatalf("by ticket: %+v", byTicket)
	}
	if byTicket, _, _ := f.s.ListDocuments(f.ctx, f.bob, domain.RoleUser, DocumentFilter{TicketKey: "DOC-1"}); len(byTicket) != 0 {
		t.Fatalf("bob sees a private linked document: %+v", byTicket)
	}
	if err := f.s.UnlinkDocumentTicket(f.ctx, d.ID, tk.ID); err != nil {
		t.Fatal(err)
	}
	if err := f.s.UnlinkDocumentTicket(f.ctx, d.ID, tk.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unlink twice: %v", err)
	}

	// Exports: one renderer at a time, a failure waits before a retry.
	if _, err := f.s.DocumentExport(f.ctx, d.ID, 1, ""); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("no export yet: %v", err)
	}
	if ok, err := f.s.StartDocumentExport(f.ctx, d.ID, 1, "", time.Minute); !ok || err != nil {
		t.Fatalf("start: %v %v", ok, err)
	}
	if ok, _ := f.s.StartDocumentExport(f.ctx, d.ID, 1, "", time.Minute); ok {
		t.Fatal("started twice")
	}
	if err := f.s.FinishDocumentExport(f.ctx, d.ID, 1, "", nil, "chromium crashed"); err != nil {
		t.Fatal(err)
	}
	if ok, _ := f.s.StartDocumentExport(f.ctx, d.ID, 1, "", time.Minute); ok {
		t.Fatal("retried right after a failure")
	}
	if ok, _ := f.s.StartDocumentExport(f.ctx, d.ID, 1, "", 0); !ok {
		t.Fatal("no retry after the wait")
	}
	if err := f.s.FinishDocumentExport(f.ctx, d.ID, 1, "", []byte("%PDF-1.7"), ""); err != nil {
		t.Fatal(err)
	}
	e, err := f.s.DocumentExport(f.ctx, d.ID, 1, "")
	if err != nil || e.Status != domain.ExportDone || string(e.Data) != "%PDF-1.7" {
		t.Fatalf("export: %+v %v", e, err)
	}
	if ok, _ := f.s.StartDocumentExport(f.ctx, d.ID, 1, "", 0); ok {
		t.Fatal("a done export started again")
	}

	// A translation's PDF is kept apart from the original's.
	if ok, err := f.s.StartDocumentExport(f.ctx, d.ID, 1, "ru", 0); !ok || err != nil {
		t.Fatalf("start the Russian PDF: %v %v", ok, err)
	}
	if e, err := f.s.DocumentExport(f.ctx, d.ID, 1, "ru"); err != nil || e.Status != domain.ExportPending {
		t.Fatalf("Russian export: %+v %v", e, err)
	}
	if e, _ := f.s.DocumentExport(f.ctx, d.ID, 1, ""); e.Status != domain.ExportDone {
		t.Fatalf("the original's PDF changed: %+v", e)
	}
}
