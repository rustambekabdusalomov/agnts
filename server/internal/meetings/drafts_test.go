package meetings_test

import (
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/meetings"
)

// notesWritten ends a notes generation of session x with these action
// items, as the documents module does, and tells the service.
func (h harness) notesWritten(x domain.MeetingSession, items []domain.ActionItem) {
	h.t.Helper()
	docs := h.notes.docs
	var docID int64
	if x.DocumentID != nil {
		docID = *x.DocumentID
	} else {
		d, err := docs.CreateDocument(h.ctx, domain.Document{Title: "Notes", OwnerID: h.host.ID, Language: "en", Kind: domain.DocKindPage}, nil)
		if err != nil {
			h.t.Fatal(err)
		}
		docID = d.ID
	}
	run, err := docs.CreateDocumentRun(h.ctx, docID, domain.DocumentSource{Kind: domain.SourceMeeting, SessionID: x.ID, Template: domain.TemplateMeetingNotes}, &h.host.ID, "test")
	if err != nil {
		h.t.Fatal(err)
	}
	d, err := docs.FinishDocumentRun(h.ctx, run.ID, domain.DocRunResult{Status: domain.DocRunDone, ActionItems: items})
	if err != nil {
		h.t.Fatal(err)
	}
	h.svc.NotesChanged(h.ctx, d)
}

func TestDraftTickets(t *testing.T) {
	h := newHarness(t)
	// The plan's member limit: the harness's members are renamed instead.
	aziza, bekzod := h.member, h.viewer
	for u, name := range map[int64]string{aziza.ID: "Aziza Rahimova", bekzod.ID: "Bekzod Tursunov"} {
		if _, err := h.pool.Exec(domain.System(h.ctx), `UPDATE users SET display_name = $2 WHERE id = $1`, u, name); err != nil {
			t.Fatal(err)
		}
	}
	aziza.DisplayName = "Aziza Rahimova"
	m := h.create(domain.MeetingInput{Title: "Refunds"}, meetings.Invites{})
	x, _, err := h.store.OpenSession(h.ctx, m.ID)
	if err != nil {
		t.Fatal(err)
	}
	now := time.Now()
	for _, u := range []domain.User{h.host, aziza} {
		if err := h.store.ParticipantJoined(h.ctx, x.ID, "u"+u.Username, domain.Person{UserID: u.ID}, u.DisplayName, now); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := h.store.EndSession(h.ctx, x.ID, now.Add(time.Minute)); err != nil {
		t.Fatal(err)
	}
	if err := h.store.ReplaceSegments(h.ctx, x.ID, []domain.MeetingSegment{{StartMS: 0, EndMS: 1000, Text: "Азиза, migration please."}}); err != nil {
		t.Fatal(err)
	}
	at := 75_000
	h.notesWritten(x, []domain.ActionItem{
		{Text: "Write the refunds migration", Who: "Азиза", Due: "by Friday", AtMS: &at, Quote: "Азиза, migration please."},
		{Text: "Email the client", Who: "me", Speaker: "Bekzod"}, // not in the call, but the only Bekzod
		{Text: "Call Kamola", Who: "Kamola"},                     // nobody: an unassigned draft
	})

	items, err := h.store.ActionItems(h.ctx, x.ID)
	if err != nil || len(items) != 3 {
		t.Fatalf("items %+v %v", items, err)
	}
	wantMember := []*int64{&aziza.ID, &bekzod.ID, nil}
	for i, it := range items {
		if it.TicketKey == "" || !it.Drafted {
			t.Fatalf("item %d has no draft: %+v", i, it)
		}
		tk, err := h.tix.TicketByKey(h.ctx, it.TicketKey)
		if err != nil {
			t.Fatal(err)
		}
		if !tk.Held || tk.State != domain.StateNew || tk.Title != it.Text {
			t.Errorf("draft %d is not held and new: %+v", i, tk)
		}
		if (wantMember[i] == nil) != (tk.MemberID == nil) || (tk.MemberID != nil && *tk.MemberID != *wantMember[i]) {
			t.Errorf("draft %d member %v, want %v", i, tk.MemberID, wantMember[i])
		}
		if tk.CreatedBy == nil || *tk.CreatedBy != h.host.ID {
			t.Errorf("draft %d created by %v", i, tk.CreatedBy)
		}
	}
	if items[0].WhoName != "Aziza Rahimova" {
		t.Errorf("item 0 who %q", items[0].WhoName)
	}
	tk0, _ := h.tix.TicketByKey(h.ctx, items[0].TicketKey)
	for _, want := range []string{"Who: Aziza Rahimova (said: Азиза)", "When: by Friday", "> Азиза, migration please. [1:15]"} {
		if !strings.Contains(tk0.Description, want) {
			t.Errorf("description has no %q:\n%s", want, tk0.Description)
		}
	}
	tk2, _ := h.tix.TicketByKey(h.ctx, items[2].TicketKey)
	if !strings.Contains(tk2.Description, "Kamola (no member matched this name)") {
		t.Errorf("unassigned description:\n%s", tk2.Description)
	}

	// The notes ending again makes no second drafts, even of a draft deleted by hand.
	if err := h.tix.DeleteTask(h.ctx, items[1].TicketKey, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	x, _ = h.store.Session(h.ctx, x.ID)
	d, _ := h.notes.docs.Document(h.ctx, *x.DocumentID)
	made := len(h.tix.made)
	h.svc.NotesChanged(h.ctx, d)
	if len(h.tix.made) != made {
		t.Errorf("drafts made again: %d", len(h.tix.made)-made)
	}

	// The member is picked by hand: the item and its ticket are theirs.
	if _, err := h.svc.SetActionItemMember(h.ctx, h.caller(h.viewer), m.ID, x.ID, items[2].ID, h.host.ID, domain.OriginWeb); err == nil {
		t.Error("a viewer picked the member")
	}
	if _, err := h.svc.SetActionItemMember(h.ctx, h.caller(h.host), m.ID, x.ID, items[2].ID, h.other.ID, domain.OriginWeb); err == nil {
		t.Error("an outsider took an action item")
	}
	it, err := h.svc.SetActionItemMember(h.ctx, h.caller(h.host), m.ID, x.ID, items[2].ID, h.host.ID, domain.OriginWeb)
	if err != nil || it.WhoUserID == nil || *it.WhoUserID != h.host.ID || it.WhoSetBy == nil {
		t.Fatalf("set member %+v %v", it, err)
	}
	if tk, _ := h.tix.TicketByKey(h.ctx, it.TicketKey); tk.MemberID == nil || *tk.MemberID != h.host.ID {
		t.Errorf("ticket member %v", tk.MemberID)
	}

	// Writing the notes again drops the untouched draft, keeps the one a
	// person changed, and drafts only what is new.
	if err := h.svc.RegenerateNotes(h.ctx, h.caller(h.host), m.ID, x.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := h.tix.TicketByKey(h.ctx, items[0].TicketKey); err == nil {
		t.Error("the untouched draft is still there")
	}
	x, _ = h.store.Session(h.ctx, x.ID)
	h.notesWritten(x, []domain.ActionItem{
		{Text: "Write the migration for refunds", Who: "Aziza", AtMS: &at},
		{Text: "call kamola", Who: "Kamola"}, // the kept one, by its text
	})
	items, _ = h.store.ActionItems(h.ctx, x.ID)
	byText := map[string]domain.ActionItem{}
	for _, it := range items {
		byText[it.Text] = it
	}
	kept, fresh := byText["Call Kamola"], byText["Write the migration for refunds"]
	if len(items) != 2 || kept.TicketKey != it.TicketKey || fresh.TicketKey == "" {
		t.Errorf("after the rewrite %+v", items)
	}
	if tk, _ := h.tix.TicketByKey(h.ctx, fresh.TicketKey); tk.MemberID == nil || *tk.MemberID != aziza.ID {
		t.Errorf("the new migration draft is on %v", tk.MemberID)
	}
}
