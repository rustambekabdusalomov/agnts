package postgres

import (
	"context"
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestWorkspaceIsolation(t *testing.T) {
	users, _ := testDB(t)
	a, wsA := testWS(t, users)
	b, wsB := testWS(t, users)
	s := NewAgent(users.db)

	ok, err := DetectTenantRole(a, users.db)
	if err != nil || !ok {
		t.Fatalf("the tenant role is missing (%v): the policies would not hold for a superuser", err)
	}

	// The same repository name and ticket key in two workspaces.
	repoA, err := s.SaveRepository(a, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git"})
	if err != nil {
		t.Fatal(err)
	}
	repoB, err := s.SaveRepository(b, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/b/api.git"})
	if err != nil {
		t.Fatal(err)
	}
	if repoA.ID == repoB.ID || repoA.WorkspaceID != wsA || repoB.WorkspaceID != wsB {
		t.Fatalf("repositories: %+v %+v", repoA, repoB)
	}
	ev := domain.Event{TicketKey: "API-1", Type: domain.EventTicketCreated}
	ta, err := s.CreateTicket(a, domain.Ticket{Key: "API-1", Source: domain.SourceLocal, RepoID: &repoA.ID, Title: "in A", State: domain.StateNew, Priority: "medium", AfterApprove: "pr"}, ev)
	if err != nil {
		t.Fatal(err)
	}
	tb, err := s.CreateTicket(b, domain.Ticket{Key: "API-1", Source: domain.SourceLocal, RepoID: &repoB.ID, Title: "in B", State: domain.StateNew, Priority: "medium", AfterApprove: "pr"}, ev)
	if err != nil {
		t.Fatal(err)
	}
	if ta.WorkspaceID != wsA || tb.WorkspaceID != wsB {
		t.Fatalf("tickets' workspaces: %d %d", ta.WorkspaceID, tb.WorkspaceID)
	}
	if got, err := s.TicketByKey(a, "API-1"); err != nil || got.Title != "in A" {
		t.Fatalf("A reads %+v %v", got, err)
	}
	if got, err := s.TicketByKey(b, "API-1"); err != nil || got.Title != "in B" {
		t.Fatalf("B reads %+v %v", got, err)
	}
	if list, _ := s.ListTickets(a, orchestrator.TicketFilter{}); len(list) != 1 {
		t.Fatalf("A lists %d tickets", len(list))
	}
	evs, _ := s.Events(a, orchestrator.EventFilter{TicketKey: "API-1"})
	if len(evs) != 1 || evs[0].WorkspaceID != wsA {
		t.Fatalf("A's events: %+v", evs)
	}

	// No workspace in the context: nothing.
	if _, err := s.TicketByKey(context.Background(), "API-1"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unscoped read: %v", err)
	}
	if list, _ := s.ListRepositories(context.Background()); len(list) != 0 {
		t.Fatalf("unscoped repositories: %+v", list)
	}
	// The system sees both.
	var n int
	if err := users.db.QueryRow(domain.System(a), `SELECT count(*) FROM tickets WHERE key = 'API-1'`).Scan(&n); err != nil || n != 2 {
		t.Fatalf("system count %d %v", n, err)
	}

	// B cannot change A's rows, even by id.
	tag, err := users.db.Exec(b, `UPDATE tickets SET title = 'hijacked' WHERE id = $1`, ta.ID)
	if err != nil || tag.RowsAffected() != 0 {
		t.Fatalf("cross-workspace update: %v rows %d", err, tag.RowsAffected())
	}
	if _, err := s.RepositoryByID(b, repoA.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("B read A's repository: %v", err)
	}
	// Nor write a row into A, nor hang one under A's ticket.
	if _, err := users.db.Exec(b, `INSERT INTO tickets (workspace_id, key, source, title, state) VALUES ($1, 'X-1', 'local', 't', 'new')`, wsA); err == nil {
		t.Fatal("B inserted a ticket into A")
	}
	if _, err := users.db.Exec(b, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, 'code', '')`, ta.ID); err == nil {
		t.Fatal("B started a run on A's ticket")
	}
	// A child row takes its parent's workspace.
	if _, err := users.db.Exec(a, `INSERT INTO questions (ticket_id, position, text) VALUES ($1, 1, 'q')`, ta.ID); err != nil {
		t.Fatal(err)
	}
	var qws int64
	if err := users.db.QueryRow(domain.System(a), `SELECT workspace_id FROM questions WHERE ticket_id = $1`, ta.ID).Scan(&qws); err != nil || qws != wsA {
		t.Fatalf("question's workspace %d %v", qws, err)
	}

	// Settings and integrations are per workspace.
	settings := NewSettings(users.db, domain.DefaultSettings())
	sa := domain.DefaultSettings()
	sa.MaxTurns = 77
	if _, err := settings.Put(a, sa, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if got, _ := settings.Get(b); got.MaxTurns == 77 {
		t.Fatal("B got A's settings")
	}
	if got, _ := settings.Get(a); got.MaxTurns != 77 {
		t.Fatalf("A's settings: %d", got.MaxTurns)
	}
	if _, err := settings.Get(context.Background()); !errors.Is(err, domain.ErrNoWorkspace) {
		t.Fatalf("settings without a workspace: %v", err)
	}

	// Task numbers without a repository count per workspace.
	na, _ := s.NextTaskNumber(a, nil)
	nb, _ := s.NextTaskNumber(b, nil)
	na2, _ := s.NextTaskNumber(a, nil)
	if na != 1 || nb != 1 || na2 != 2 {
		t.Fatalf("task numbers %d %d %d", na, nb, na2)
	}
}

func TestQueueAcrossWorkspaces(t *testing.T) {
	users, _ := testDB(t)
	a, wsA := testWS(t, users)
	b, wsB := testWS(t, users)
	s := NewAgent(users.db)
	sys := domain.System(context.Background())
	mk := func(ctx context.Context, key string, held bool) domain.Ticket {
		t.Helper()
		tk, err := s.CreateTicket(ctx, domain.Ticket{Key: key, Source: domain.SourceLocal, Title: key, State: domain.StateNew, Priority: "medium",
			Kind: domain.KindPlan, Held: held, AfterApprove: "pr"}, domain.Event{TicketKey: key, Type: domain.EventTicketCreated})
		if err != nil {
			t.Fatal(err)
		}
		return tk
	}
	t1 := mk(a, "T-1", false)
	mk(a, "T-2", true)
	t3 := mk(b, "T-1", false)

	items, err := s.QueueItems(sys)
	if err != nil {
		t.Fatal(err)
	}
	if len(items) != 3 {
		t.Fatalf("queue items %+v", items)
	}
	seen := map[int64]int{}
	for _, it := range items {
		seen[it.WorkspaceID]++
		if it.Class != orchestrator.ClassMain {
			t.Fatalf("class %q", it.Class)
		}
	}
	if seen[wsA] != 2 || seen[wsB] != 1 {
		t.Fatalf("by workspace %v", seen)
	}
	// A workspace sees only its own items.
	if mine, _ := s.QueueItems(b); len(mine) != 1 || mine[0].TicketID != t3.ID {
		t.Fatalf("B's queue %+v", mine)
	}

	if err := s.SetWaitReasons(sys, []orchestrator.WaitChange{
		{TicketID: t1.ID, WorkspaceID: wsA, Key: "T-1", Reason: domain.WaitServer, Message: "waiting for the server", Announce: true},
	}); err != nil {
		t.Fatal(err)
	}
	got, _ := s.TicketByKey(a, "T-1")
	if got.WaitReason != domain.WaitServer || got.QueuedAt == nil || got.WaitMessage != "waiting for the server" {
		t.Fatalf("wait reason: %+v", got)
	}
	evs, _ := s.Events(a, orchestrator.EventFilter{TicketKey: "T-1"})
	if evs[len(evs)-1].Type != domain.EventQueued || evs[len(evs)-1].WorkspaceID != wsA {
		t.Fatalf("queued event %+v", evs[len(evs)-1])
	}

	// Claiming a specific ticket starts its run and clears the reason.
	tk, run, ok, err := s.ClaimTicket(a, t1.ID, orchestrator.ClassMain)
	if err != nil || !ok || run.Stage != domain.StageAnalyze || tk.State != domain.StateAnalyzing || tk.WaitReason != domain.WaitNone {
		t.Fatalf("claim: %+v %+v %v %v", tk, run, ok, err)
	}
	if _, _, ok, _ := s.ClaimTicket(a, t1.ID, orchestrator.ClassMain); ok {
		t.Fatal("claimed twice")
	}
	// Held tickets are not claimed; nor another workspace's ticket.
	held, _ := s.TicketByKey(a, "T-2")
	if _, _, ok, _ := s.ClaimTicket(a, held.ID, orchestrator.ClassMain); ok {
		t.Fatal("claimed a held ticket")
	}
	if _, _, ok, _ := s.ClaimTicket(a, t3.ID, orchestrator.ClassMain); ok {
		t.Fatal("A claimed B's ticket")
	}
	// The interrupted run comes back on recovery.
	if n, err := s.RecoverInterrupted(sys); err != nil || n != 1 {
		t.Fatalf("recover %d %v", n, err)
	}
}

func TestMembersInvitesAndCredits(t *testing.T) {
	users, _ := testDB(t)
	sys := domain.System(context.Background())
	ws := NewWorkspaces(users.db)
	owner, _ := users.Create(sys, domain.User{Username: "boss", PasswordHash: "h"})
	mate, _ := users.Create(sys, domain.User{Username: "mate", PasswordHash: "h"})
	third, _ := users.Create(sys, domain.User{Username: "third", PasswordHash: "h"})

	w, err := ws.Create(sys, NewWorkspace{Name: "Acme Web!", OwnerID: owner.ID, MemberLimit: 2})
	if err != nil {
		t.Fatal(err)
	}
	if w.Slug != "acme-web" || w.HookID == "" || w.ClaudeMode != domain.ClaudeShared {
		t.Fatalf("workspace %+v", w)
	}
	w2, err := ws.Create(sys, NewWorkspace{Name: "Acme Web", OwnerID: owner.ID})
	if err != nil || w2.Slug != "acme-web-2" {
		t.Fatalf("second slug %q %v", w2.Slug, err)
	}
	if _, err := ws.Create(sys, NewWorkspace{Name: "x", Slug: "acme-web", OwnerID: owner.ID}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("chosen taken slug: %v", err)
	}

	tok := []byte("token-hash-1")
	if _, err := ws.CreateInvite(sys, domain.Invite{WorkspaceID: w.ID, Email: "mate@x.io", InvitedBy: owner.ID, ExpiresAt: time.Now().Add(time.Hour)}, tok); err != nil {
		t.Fatal(err)
	}
	if _, err := ws.AcceptInvite(sys, tok, mate.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := ws.AcceptInvite(sys, tok, third.ID); !errors.Is(err, domain.ErrInviteInvalid) {
		t.Fatalf("invite used twice: %v", err)
	}
	if role, _ := ws.Role(sys, w.ID, mate.ID); role != domain.RoleUser {
		t.Fatalf("mate's role %q", role)
	}
	// The plan includes two members.
	if err := ws.AddMember(sys, w.ID, third.ID, domain.RoleUser); !errors.Is(err, domain.ErrMemberLimit) {
		t.Fatalf("over the member limit: %v", err)
	}
	if err := ws.RemoveMember(sys, w.ID, owner.ID); !errors.Is(err, domain.ErrLastOwner) {
		t.Fatalf("removed the owner: %v", err)
	}
	if err := ws.TransferOwnership(sys, w.ID, mate.ID); err != nil {
		t.Fatal(err)
	}
	if role, _ := ws.Role(sys, w.ID, owner.ID); role != domain.RoleUser {
		t.Fatalf("old owner's role %q", role)
	}
	got, _ := ws.ByID(sys, w.ID)
	if got.OwnerID != mate.ID {
		t.Fatalf("owner %d", got.OwnerID)
	}
	// The old owner becomes a viewer: they stop being the default member,
	// and cannot be made it again. The owner's role does not change this way.
	def := owner.ID
	if _, err := ws.Update(sys, w.ID, WorkspaceUpdate{DefaultMemberID: &def}); err != nil {
		t.Fatal(err)
	}
	if err := ws.SetRole(sys, w.ID, owner.ID, domain.RoleViewer); err != nil {
		t.Fatal(err)
	}
	if role, _ := ws.Role(sys, w.ID, owner.ID); role != domain.RoleViewer {
		t.Fatalf("viewer's role %q", role)
	}
	if got, _ := ws.ByID(sys, w.ID); got.DefaultMemberID != nil {
		t.Fatalf("a viewer stayed the default member")
	}
	if _, err := ws.Update(sys, w.ID, WorkspaceUpdate{DefaultMemberID: &def}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("viewer as default member: %v", err)
	}
	if err := ws.SetRole(sys, w.ID, mate.ID, domain.RoleViewer); !errors.Is(err, domain.ErrLastOwner) {
		t.Fatalf("owner made a viewer: %v", err)
	}
	if err := ws.SetRole(sys, w.ID, owner.ID, domain.RoleOwner); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("made an owner by role: %v", err)
	}
	if err := ws.SetRole(sys, w.ID, owner.ID, domain.RoleUser); err != nil {
		t.Fatal(err)
	}
	of, _ := ws.Of(sys, owner.ID)
	if len(of) != 2 {
		t.Fatalf("owner's workspaces %+v", of)
	}

	credits := NewCredits(users.db)
	bal, err := credits.Add(sys, LedgerEntry{WorkspaceID: w.ID, Amount: 500, Reason: CreditGrant})
	if err != nil || bal != 500 {
		t.Fatalf("grant %d %v", bal, err)
	}
	p, err := credits.CreatePayment(sys, Payment{WorkspaceID: w.ID, Provider: "payme", AmountUZS: 17500, Credits: 100})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := credits.BeginPayment(sys, p.ID, "txn-1", 1); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.BeginPayment(sys, p.ID, "txn-2", 1); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("second transaction: %v", err)
	}
	if _, err := credits.CompletePayment(sys, p.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.CompletePayment(sys, p.ID); err != nil {
		t.Fatal(err)
	}
	if bal, _ := credits.Balance(sys, w.ID); bal != 600 {
		t.Fatalf("balance after payment %d (paid twice?)", bal)
	}
	if _, err := credits.CancelPayment(sys, p.ID, 5); err != nil {
		t.Fatal(err)
	}
	if bal, _ := credits.Balance(sys, w.ID); bal != 500 {
		t.Fatalf("balance after refund %d", bal)
	}
	ledger, _ := credits.Ledger(sys, w.ID, 10)
	if len(ledger) != 3 || ledger[0].Reason != CreditRefund {
		t.Fatalf("ledger %+v", ledger)
	}
}

func TestMembershipsAndLastSignIns(t *testing.T) {
	users, sessions := testDB(t)
	sys := domain.System(context.Background())
	ws := NewWorkspaces(users.db)
	solo, _ := users.Create(sys, domain.User{Username: "solo", PasswordHash: "h"})
	idle, _ := users.Create(sys, domain.User{Username: "idle", PasswordHash: "h"})
	kept, err := ws.Create(sys, NewWorkspace{Name: "Kept", OwnerID: solo.ID})
	if err != nil {
		t.Fatal(err)
	}
	gone, err := ws.Create(sys, NewWorkspace{Name: "Gone", OwnerID: solo.ID})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := ws.SetDeleted(sys, gone.ID, true); err != nil {
		t.Fatal(err)
	}
	ms, err := ws.Memberships(sys)
	if err != nil {
		t.Fatal(err)
	}
	var mine []domain.Member
	for _, m := range ms {
		if m.UserID == solo.ID {
			mine = append(mine, m)
		}
	}
	// A deleted workspace is left out.
	if len(mine) != 1 || mine[0].WorkspaceID != kept.ID || mine[0].Role != domain.RoleOwner {
		t.Fatalf("memberships %+v", mine)
	}

	now := time.Now().Truncate(time.Second)
	for i, at := range []time.Time{now.Add(-time.Hour), now} {
		if err := sessions.Create(sys, domain.Session{TokenHash: []byte{byte(i), 7}, UserID: solo.ID, Client: domain.ClientWeb, CreatedAt: at, ExpiresAt: now.Add(time.Hour)}); err != nil {
			t.Fatal(err)
		}
	}
	last, err := users.LastSignIns(sys)
	if err != nil {
		t.Fatal(err)
	}
	if !last[solo.ID].Equal(now) {
		t.Fatalf("last sign-in %v, want %v", last[solo.ID], now)
	}
	if _, ok := last[idle.ID]; ok {
		t.Fatal("a user who never signed in has a last sign-in")
	}
}

func TestFeedback(t *testing.T) {
	users, _ := testDB(t)
	sys := domain.System(context.Background())
	fb := NewFeedbacks(users.db)
	u, _ := users.Create(sys, domain.User{Username: "fan", PasswordHash: "h"})
	w, err := NewWorkspaces(users.db).Create(sys, NewWorkspace{Name: "Fan club", OwnerID: u.ID})
	if err != nil {
		t.Fatal(err)
	}
	a, err := fb.Create(sys, Feedback{UserID: &u.ID, Sender: "Fan", Email: "fan@x.io", WorkspaceID: &w.ID, Title: "Love it", Description: "More languages please"})
	if err != nil || a.Status != "new" || a.Workspace != "Fan club" || a.Title != "Love it" {
		t.Fatalf("created %+v %v", a, err)
	}
	b, err := fb.Create(sys, Feedback{UserID: &u.ID, Sender: "Fan", Title: "Bug", Description: "The button is grey"})
	if err != nil || b.WorkspaceID != nil || b.Workspace != "" {
		t.Fatalf("without a workspace %+v %v", b, err)
	}
	if _, err := fb.Create(sys, Feedback{Title: "", Description: "x"}); err == nil {
		t.Fatal("an empty title was stored")
	}
	if a.Kind != FeedbackKind {
		t.Fatalf("kind %q", a.Kind)
	}
	// A connector request from the website has no account behind it.
	cr, err := fb.Create(sys, Feedback{Kind: ConnectorKind, Sender: "Visitor", Email: "v@x.io", Title: "Connector: Linear", Description: "Hosting: cloud"})
	if err != nil || cr.Kind != ConnectorKind || cr.UserID != nil {
		t.Fatalf("connector request %+v %v", cr, err)
	}
	if _, err := fb.Create(sys, Feedback{Kind: "spam", Title: "x", Description: "y"}); err == nil {
		t.Fatal("an unknown kind was stored")
	}
	if done, err := fb.SetStatus(sys, a.ID, "done"); err != nil || done.Status != "done" {
		t.Fatalf("done: %+v %v", done, err)
	}
	if _, err := fb.SetStatus(sys, 1<<40, "done"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unknown id: %v", err)
	}
	list, err := fb.List(sys)
	if err != nil || len(list) < 3 || list[0].ID != cr.ID {
		t.Fatalf("newest first: %+v %v", list, err)
	}
	// The sender's name stays when their account goes.
	gone, _ := users.Create(sys, domain.User{Username: "gone", PasswordHash: "h"})
	c, err := fb.Create(sys, Feedback{UserID: &gone.ID, Sender: "Gone Person", Title: "Bye", Description: "Thanks"})
	if err != nil {
		t.Fatal(err)
	}
	if err := users.Delete(sys, gone.ID); err != nil {
		t.Fatal(err)
	}
	if c, err = fb.byID(sys, c.ID); err != nil || c.UserID != nil || c.Sender != "Gone Person" {
		t.Fatalf("after the account went: %+v %v", c, err)
	}
}
