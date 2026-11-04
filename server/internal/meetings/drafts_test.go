package meetings_test

import (
	"context"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/meetings"
	"agnts/internal/orchestrator"
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

	// The notes make no tickets: the items stay drafts in the meeting, on
	// the members matched.
	if len(h.tix.made) != 0 {
		t.Fatalf("tickets made before anyone approved: %d", len(h.tix.made))
	}
	items, err := h.store.ActionItems(h.ctx, x.ID)
	if err != nil || len(items) != 3 {
		t.Fatalf("items %+v %v", items, err)
	}
	wantMember := []*int64{&aziza.ID, &bekzod.ID, nil}
	for i, it := range items {
		if it.TicketKey != "" || it.Drafted {
			t.Fatalf("item %d is a ticket already: %+v", i, it)
		}
		if (wantMember[i] == nil) != (it.WhoUserID == nil) || (it.WhoUserID != nil && *it.WhoUserID != *wantMember[i]) {
			t.Errorf("item %d member %v, want %v", i, it.WhoUserID, wantMember[i])
		}
	}
	if items[0].WhoName != "Aziza Rahimova" {
		t.Errorf("item 0 who %q", items[0].WhoName)
	}

	// Approving a draft makes it a ticket of the member matched.
	if _, err := h.svc.ActionItemTicket(h.ctx, h.caller(h.viewer), m.ID, x.ID, items[0].ID, meetings.TicketOptions{}); err == nil {
		t.Error("a viewer approved a draft")
	}
	tk0, err := h.svc.ActionItemTicket(h.ctx, h.caller(h.host), m.ID, x.ID, items[0].ID, meetings.TicketOptions{})
	if err != nil {
		t.Fatal(err)
	}
	if tk0.MemberID == nil || *tk0.MemberID != aziza.ID || tk0.Title != items[0].Text {
		t.Errorf("approved ticket %+v", tk0)
	}
	if tk0.CreatedBy == nil || *tk0.CreatedBy != h.host.ID {
		t.Errorf("approved ticket created by %v", tk0.CreatedBy)
	}
	for _, want := range []string{"Who: Aziza Rahimova (said: Азиза)", "When: by Friday", "> Азиза, migration please. [1:15]"} {
		if !strings.Contains(tk0.Description, want) {
			t.Errorf("description has no %q:\n%s", want, tk0.Description)
		}
	}
	if _, err := h.svc.ActionItemTicket(h.ctx, h.caller(h.host), m.ID, x.ID, items[0].ID, meetings.TicketOptions{}); err == nil {
		t.Error("a draft was approved twice")
	}

	// The notes ending again make no tickets.
	x, _ = h.store.Session(h.ctx, x.ID)
	d, _ := h.notes.docs.Document(h.ctx, *x.DocumentID)
	made := len(h.tix.made)
	h.svc.NotesChanged(h.ctx, d)
	if len(h.tix.made) != made {
		t.Errorf("tickets made again: %d", len(h.tix.made)-made)
	}

	// The member is picked by hand on a draft.
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

	// Writing the notes again keeps the approved item and the draft a
	// person changed, drops the other draft, and adds only what is new.
	if err := h.svc.RegenerateNotes(h.ctx, h.caller(h.host), m.ID, x.ID); err != nil {
		t.Fatal(err)
	}
	x, _ = h.store.Session(h.ctx, x.ID)
	h.notesWritten(x, []domain.ActionItem{
		{Text: "Write the migration for refunds", Who: "Aziza", AtMS: &at}, // the approved one, by its time
		{Text: "call kamola", Who: "Kamola"},                               // the hand-picked draft, by its text
		{Text: "Book the demo room", Who: "Aziza"},
	})
	items, _ = h.store.ActionItems(h.ctx, x.ID)
	byText := map[string]domain.ActionItem{}
	for _, it := range items {
		byText[it.Text] = it
	}
	approved, picked, fresh := byText["Write the refunds migration"], byText["Call Kamola"], byText["Book the demo room"]
	if len(items) != 3 || approved.TicketKey != tk0.Key || picked.WhoUserID == nil || *picked.WhoUserID != h.host.ID || fresh.ID == 0 {
		t.Errorf("after the rewrite %+v", items)
	}
	if _, ok := byText["Email the client"]; ok {
		t.Error("the untouched draft is still there")
	}
	if fresh.TicketKey != "" || fresh.WhoUserID == nil || *fresh.WhoUserID != aziza.ID {
		t.Errorf("the new draft %+v", fresh)
	}
	if len(h.tix.made) != made {
		t.Errorf("the rewrite made tickets: %d", len(h.tix.made)-made)
	}
}

// Draft tickets made before drafts stayed in the meeting go back to it,
// unless someone has worked on them.
func TestReturnHeldDrafts(t *testing.T) {
	h := newHarness(t)
	m := h.create(domain.MeetingInput{Title: "Old drafts"}, meetings.Invites{})
	x, _, err := h.store.OpenSession(h.ctx, m.ID)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := h.store.EndSession(h.ctx, x.ID, time.Now()); err != nil {
		t.Fatal(err)
	}
	h.notesWritten(x, []domain.ActionItem{{Text: "Untouched"}, {Text: "Renamed"}, {Text: "Picked"}, {Text: "Approved"}})
	items, err := h.store.ActionItems(h.ctx, x.ID)
	if err != nil || len(items) != 4 {
		t.Fatalf("items %+v %v", items, err)
	}
	// As the old notes did: a held ticket per item, marked drafted; the
	// approved one was made by hand and is not a draft.
	keys := make([]string, len(items))
	for i, it := range items {
		start := "queue"
		if i == 3 {
			start = "ask"
		}
		tk, err := h.tix.CreateTask(h.ctx, orchestrator.TaskInput{Title: it.Text, Start: start, Priority: "medium", AfterApprove: "pr"}, domain.OriginSystem)
		if err != nil {
			t.Fatal(err)
		}
		keys[i] = tk.Key
		if _, err := h.store.SetActionItemTicket(h.ctx, it.ID, tk.ID, h.host.ID); err != nil {
			t.Fatal(err)
		}
		if i < 3 {
			if err := h.store.SetActionItemsDrafted(h.ctx, []int64{it.ID}, true); err != nil {
				t.Fatal(err)
			}
		}
	}
	if _, err := h.pool.Exec(domain.System(h.ctx), `UPDATE tickets SET title = 'Renamed by a person' WHERE key = $1`, keys[1]); err != nil {
		t.Fatal(err)
	}
	if _, err := h.svc.SetActionItemMember(h.ctx, h.caller(h.host), m.ID, x.ID, items[2].ID, h.member.ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	for range 2 { // a second start changes nothing
		h.svc.ReturnHeldDrafts(domain.System(context.Background()))
	}
	items, _ = h.store.ActionItems(h.ctx, x.ID)
	gone := map[string]bool{}
	for i, it := range items {
		_, err := h.tix.TicketByKey(h.ctx, keys[i])
		gone[it.Text] = err != nil
		if gone[it.Text] && (it.TicketKey != "" || it.Drafted) {
			t.Errorf("%s still points at its ticket: %+v", it.Text, it)
		}
	}
	if !gone["Untouched"] || gone["Renamed"] || !gone["Picked"] || gone["Approved"] {
		t.Errorf("tickets gone %v", gone)
	}
	if it := items[2]; it.WhoUserID == nil || *it.WhoUserID != h.member.ID {
		t.Errorf("the picked draft lost its member: %+v", it)
	}
}
