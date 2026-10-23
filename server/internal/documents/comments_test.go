package documents

import (
	"context"
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestComments(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Plan", "# Plan\n\nRefunds go through the payments API.")
	id := v.Doc.ID
	on := func(quote string) NewComment {
		return NewComment{Body: "why?", Quote: quote, Prefix: "Refunds go ", Suffix: " API."}
	}

	// Someone who cannot open it cannot comment; a grant of view is enough,
	// for a workspace viewer too.
	if _, err := f.s.AddComment(f.ctx, f.bob, id, on("through the payments")); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob without access: %v", err)
	}
	if _, err := f.s.Share(f.ctx, f.alice, id, Sharing{Type: domain.DocPrivate, Grants: []domain.DocumentGrant{
		{UserID: f.bob.UserID, Level: domain.AccessView}, {UserID: f.vi.UserID, Level: domain.AccessView}}}); err != nil {
		t.Fatal(err)
	}
	th, err := f.s.AddComment(f.ctx, f.bob, id, on("  through the payments "))
	if err != nil || th.Quote != "through the payments" || th.AuthorName == "" || !th.Mine || !th.CanResolve || !th.CanDelete || th.Version != 1 {
		t.Fatalf("bob's thread: %+v %v", th, err)
	}
	if _, err := f.s.AddComment(f.ctx, f.vi, id, NewComment{Body: "me too", ParentID: &th.ID}); err != nil {
		t.Fatalf("a viewer replies: %v", err)
	}
	if _, err := f.s.AddComment(f.ctx, f.bob, id, NewComment{Body: "no selection"}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("a thread without a selection: %v", err)
	}
	if _, err := f.s.AddComment(f.ctx, f.bob, id, NewComment{Body: "  ", Quote: "x"}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("an empty comment: %v", err)
	}
	if _, err := f.s.AddComment(f.ctx, f.bob, id, NewComment{Body: "x", Quote: "x", Slide: new(int)}); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("a slide on a page: %v", err)
	}
	reply := NewComment{Body: "reply to a reply"}
	cs, _ := f.s.Comments(f.ctx, f.alice, id)
	reply.ParentID = &cs[1].ID
	if _, err := f.s.AddComment(f.ctx, f.bob, id, reply); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("a reply to a reply: %v", err)
	}

	// What each person may do.
	cs, err = f.s.Comments(f.ctx, f.vi, id)
	if err != nil || len(cs) != 2 || cs[0].Mine || cs[0].CanResolve || cs[0].CanDelete || !cs[1].Mine || cs[1].CanResolve {
		t.Fatalf("vi's view: %+v %v", cs, err)
	}
	if _, err := f.s.EditComment(f.ctx, f.vi, id, th.ID, "changed"); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("vi edits bob's: %v", err)
	}
	if _, err := f.s.ResolveComment(f.ctx, f.vi, id, th.ID, true); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("vi resolves bob's: %v", err)
	}
	if c, err := f.s.EditComment(f.ctx, f.bob, id, th.ID, "why the payments API?"); err != nil || c.Body != "why the payments API?" {
		t.Fatalf("bob edits his: %+v %v", c, err)
	}
	// The owner may resolve and delete anything; resolving a reply is not a thing.
	if _, err := f.s.ResolveComment(f.ctx, f.alice, id, cs[1].ID, true); !errors.Is(err, domain.ErrDocInvalid) {
		t.Fatalf("resolve a reply: %v", err)
	}
	if c, err := f.s.ResolveComment(f.ctx, f.alice, id, th.ID, true); err != nil || c.ResolvedAt == nil || c.ResolvedBy == "" {
		t.Fatalf("alice resolves: %+v %v", c, err)
	}
	if c, err := f.s.ResolveComment(f.ctx, f.bob, id, th.ID, false); err != nil || c.ResolvedAt != nil {
		t.Fatalf("bob reopens his: %+v %v", c, err)
	}
	// A comment of another document is not found through this one.
	other := f.create(t, f.alice, "Other", "text")
	if _, err := f.s.EditComment(f.ctx, f.alice, other.Doc.ID, th.ID, "x"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("through another document: %v", err)
	}
	// Members hear about it; deleting a thread takes its replies.
	if f.notes.sent[f.bob.UserID] == 0 {
		t.Error("bob heard nothing about comments")
	}
	if err := f.s.DeleteComment(f.ctx, f.vi, id, th.ID); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("vi deletes bob's: %v", err)
	}
	if err := f.s.DeleteComment(f.ctx, f.alice, id, th.ID); err != nil {
		t.Fatal(err)
	}
	if cs, _ := f.s.Comments(f.ctx, f.alice, id); len(cs) != 0 {
		t.Fatalf("replies left after their thread: %d", len(cs))
	}
}

func TestGuests(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "For the client", "# Hello\n\nThe plan is ready.")
	sys := domain.System(context.Background())
	if _, _, err := f.s.Join(sys, "nope-not-a-token-0123456789", domain.DocumentGuest{Name: "Client"}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("join a private document: %v", err)
	}
	pub, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPublic})
	if err != nil {
		t.Fatal(err)
	}
	f.settled(t, v.Doc.ID, 1)
	tok := pub.Doc.PublicToken
	if _, err := f.s.Guest(sys, tok, ""); !errors.Is(err, ErrNoGuest) {
		t.Fatalf("no guest: %v", err)
	}
	g, gtok := f.join(t, tok, "Dilnoza")
	g2, _ := f.join(t, tok, "Sardor")

	// A guest comments and sees members' comments with their names.
	th, err := f.s.GuestAddComment(g, NewComment{Body: "Is this final?", Quote: "The plan is ready"})
	if err != nil || th.AuthorName != "Dilnoza" || !th.Mine || !th.CanResolve || !th.CanDelete || th.ShowEmail {
		t.Fatalf("guest thread: %+v %v", th, err)
	}
	if _, err := f.s.AddComment(f.ctx, f.alice, v.Doc.ID, NewComment{Body: "Yes", ParentID: &th.ID}); err != nil {
		t.Fatal(err)
	}
	cs, err := f.s.GuestComments(g2)
	if err != nil || len(cs) != 2 || cs[0].Mine || cs[0].CanResolve || cs[0].CanDelete || cs[1].AuthorUserID == nil {
		t.Fatalf("another guest's view: %+v %v", cs, err)
	}
	// Guests touch only their own.
	if _, err := f.s.GuestEditComment(g2, th.ID, "x"); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("a guest edits another's: %v", err)
	}
	if _, err := f.s.GuestResolveComment(g2, th.ID, true); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("a guest resolves another's: %v", err)
	}
	if err := f.s.GuestDeleteComment(g2, cs[1].ID); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("a guest deletes a member's: %v", err)
	}
	if _, err := f.s.GuestResolveComment(g, th.ID, true); err != nil {
		t.Fatalf("a guest resolves their own: %v", err)
	}
	// Members see who the guest is; a guest from Google is marked.
	_, gtok3, err := f.s.Join(sys, tok, domain.DocumentGuest{Name: "Aziz", Email: "aziz@example.com", Via: domain.GuestByGoogle})
	if err != nil {
		t.Fatal(err)
	}
	g3, _ := f.s.Guest(sys, tok, gtok3)
	if c, err := f.s.GuestAddComment(g3, NewComment{Body: "ok", Quote: "Hello"}); err != nil || c.AuthorEmail != "aziz@example.com" || c.AuthorVia != domain.GuestByGoogle || c.ShowEmail {
		t.Fatalf("Google guest: %+v %v", c, err)
	}
	if cs, _ := f.s.Comments(f.ctx, f.alice, v.Doc.ID); !cs[2].ShowEmail || cs[2].AuthorEmail == "" {
		t.Fatalf("members see the email: %+v", cs[2])
	}

	// Ten comments a minute.
	for i := range 20 {
		_, err = f.s.GuestAddComment(g2, NewComment{Body: "spam", Quote: "Hello"})
		if err != nil {
			if !errors.Is(err, ErrTooMany) || i != domain.GuestCommentsPerMn {
				t.Fatalf("limit at %d: %v", i, err)
			}
			break
		}
	}
	if err == nil {
		t.Fatal("no limit on guest comments")
	}

	// Going private ends every guest at once.
	if _, err := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPrivate}); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.Guest(sys, tok, gtok); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("guest after going private: %v", err)
	}
	// A guest of one document is no one on another.
	again, _ := f.s.Share(f.ctx, f.alice, v.Doc.ID, Sharing{Type: domain.DocPublic})
	other := f.create(t, f.alice, "Other", "text")
	op, _ := f.s.Share(f.ctx, f.alice, other.Doc.ID, Sharing{Type: domain.DocPublic})
	if _, err := f.s.Guest(sys, op.Doc.PublicToken, gtok); !errors.Is(err, ErrNoGuest) {
		t.Fatalf("a guest on another document: %v", err)
	}
	// The same guest comes back once the document is public again (new link, same document).
	if _, err := f.s.Guest(sys, again.Doc.PublicToken, gtok); err != nil {
		t.Fatalf("guest on the new link: %v", err)
	}
}

func TestPresence(t *testing.T) {
	f := setup(t)
	v := f.create(t, f.alice, "Plan", "text")
	id := v.Doc.ID
	now := time.Date(2026, 10, 23, 10, 0, 0, 0, time.UTC)
	f.s.now = func() time.Time { return now }

	p, err := f.s.Here(f.ctx, f.alice, id, false)
	if err != nil || len(p.Viewers) != 1 || p.Viewers[0].Key() != p.You || p.CommentsStamp != "0" {
		t.Fatalf("alice alone: %+v %v", p, err)
	}
	if _, err := f.s.Here(f.ctx, f.bob, id, false); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("bob cannot open it: %v", err)
	}
	pub, _ := f.s.Share(f.ctx, f.alice, id, Sharing{Type: domain.DocPublic})
	f.settled(t, id, 1)
	g, _ := f.join(t, pub.Doc.PublicToken, "Client")
	now = now.Add(5 * time.Second)
	p, err = f.s.GuestHere(g, false)
	if err != nil || len(p.Viewers) != 2 || p.Viewers[0].Kind != domain.ViewerMember || p.Viewers[1].Name != "Client" || p.Viewers[1].Key() != p.You {
		t.Fatalf("with a guest: %+v %v", p, err)
	}
	// The stamp moves with the comments.
	if _, err := f.s.GuestAddComment(g, NewComment{Body: "hi", Quote: "text"}); err != nil {
		t.Fatal(err)
	}
	if p2, _ := f.s.GuestHere(g, false); p2.CommentsStamp == p.CommentsStamp {
		t.Fatal("the stamp did not move")
	}
	// Alice went quiet for longer than the TTL: she is gone; leaving removes at once.
	now = now.Add(presenceTTL)
	if p, _ := f.s.GuestHere(g, false); len(p.Viewers) != 1 {
		t.Fatalf("alice should have expired: %+v", p.Viewers)
	}
	if p, _ := f.s.GuestHere(g, true); len(p.Viewers) != 0 {
		t.Fatalf("after leaving: %+v", p.Viewers)
	}
	// Alice signed in on the public link and on the document page is one viewer.
	sys := domain.System(context.Background())
	_, atok, err := f.s.Join(sys, pub.Doc.PublicToken, domain.DocumentGuest{Name: "Alice", Via: domain.GuestByAccount, UserID: &f.alice.UserID})
	if err != nil {
		t.Fatal(err)
	}
	ag, _ := f.s.Guest(sys, pub.Doc.PublicToken, atok)
	if p, _ := f.s.GuestHere(ag, false); len(p.Viewers) != 1 || p.Viewers[0].Via != domain.GuestByAccount {
		t.Fatalf("alice by the link: %+v", p.Viewers)
	}
	if p, _ := f.s.Here(f.ctx, f.alice, id, false); len(p.Viewers) != 1 {
		t.Fatalf("alice twice: %+v", p.Viewers)
	}
}
