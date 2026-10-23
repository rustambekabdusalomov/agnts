package documents

import (
	"context"
	"errors"
	"fmt"
	"time"

	"agnts/internal/domain"
)

// CommentStore is where comments and guests live (postgres.Documents).
type CommentStore interface {
	CreateGuest(ctx context.Context, g domain.DocumentGuest, tokenHash []byte) (domain.DocumentGuest, error)
	GuestByToken(ctx context.Context, docID int64, tokenHash []byte) (domain.DocumentGuest, error)
	Comments(ctx context.Context, docID int64) ([]domain.DocumentComment, error)
	Comment(ctx context.Context, id int64) (domain.DocumentComment, error)
	CreateComment(ctx context.Context, c domain.DocumentComment) (domain.DocumentComment, error)
	EditComment(ctx context.Context, id int64, body string) (domain.DocumentComment, error)
	ResolveComment(ctx context.Context, id int64, resolved bool, by string) (domain.DocumentComment, error)
	DeleteComment(ctx context.Context, id int64) error
	OpenThreads(ctx context.Context, docID int64) (int, error)
	GuestCommentsSince(ctx context.Context, guestID int64, since time.Time) (int, error)
	CommentsStamp(ctx context.Context, docID int64) (string, error)
	UserName(ctx context.Context, userID int64) (string, error)
}

// EventDocumentComments tells the people who can open a document that its
// comments changed. Like EventDocumentUpdated it is not stored.
const EventDocumentComments = "document_comments"

// ErrTooMany means a guest posted too many comments in the last minute.
var ErrTooMany = errors.New("too many comments; wait a minute")

// ErrNoGuest means a public document needs its reader to say who they are.
var ErrNoGuest = errors.New("say who you are to open this document")

// NewComment is a comment someone writes: a thread on a selection, or a
// reply (ParentID).
type NewComment struct {
	ParentID *int64
	Body     string
	Quote    string
	Prefix   string
	Suffix   string
	Slide    *int
}

// actor is who acts on comments: a member with their access, or a guest
// (view access, never more).
type actor struct {
	userID  int64
	guestID int64
	name    string
	access  domain.AccessLevel
}

// CommentView is a comment as one person sees it: whether they wrote it,
// and what they may do with it.
type CommentView struct {
	domain.DocumentComment
	Mine       bool
	CanResolve bool
	CanDelete  bool
	// ShowEmail: members see a Google guest's email; guests do not.
	ShowEmail bool
}

func (a actor) view(c domain.DocumentComment) CommentView {
	mine := a.wrote(c)
	return CommentView{DocumentComment: c, Mine: mine, CanResolve: c.Thread() && (mine || a.access >= domain.AccessEdit),
		CanDelete: mine || a.access >= domain.AccessOwner, ShowEmail: a.userID != 0}
}

func (a actor) views(cs []domain.DocumentComment, err error) ([]CommentView, error) {
	if err != nil {
		return nil, err
	}
	out := make([]CommentView, len(cs))
	for i, c := range cs {
		out[i] = a.view(c)
	}
	return out, nil
}

func (a actor) one(c domain.DocumentComment, err error) (CommentView, error) {
	if err != nil {
		return CommentView{}, err
	}
	return a.view(c), nil
}

func (a actor) wrote(c domain.DocumentComment) bool {
	return a.userID != 0 && c.AuthorUserID != nil && *c.AuthorUserID == a.userID ||
		a.guestID != 0 && c.AuthorGuestID != nil && *c.AuthorGuestID == a.guestID
}

func (s *Service) comments() CommentStore {
	cs, _ := s.d.Store.(CommentStore)
	return cs
}

// member is the caller as an actor on the document id, which they must be
// able to open.
func (s *Service) member(ctx context.Context, c Caller, id int64) (View, actor, error) {
	v, err := s.open(ctx, c, id)
	if err != nil {
		return v, actor{}, err
	}
	if s.comments() == nil {
		return v, actor{}, invalid("comments are not available on this server")
	}
	name, err := s.comments().UserName(ctx, c.UserID)
	if err != nil {
		return v, actor{}, err
	}
	return v, actor{userID: c.UserID, name: name, access: v.Access}, nil
}

// Comments returns a document's comments, oldest first. Viewing is enough.
func (s *Service) Comments(ctx context.Context, c Caller, id int64) ([]CommentView, error) {
	_, a, err := s.member(ctx, c, id)
	if err != nil {
		return nil, err
	}
	return a.views(s.comments().Comments(ctx, id))
}

// AddComment starts a thread or replies. Viewing is enough: a member who
// can open a document can comment on it.
func (s *Service) AddComment(ctx context.Context, c Caller, id int64, in NewComment) (CommentView, error) {
	v, a, err := s.member(ctx, c, id)
	if err != nil {
		return CommentView{}, err
	}
	return a.one(s.addComment(ctx, v.Doc, a, in))
}

// EditComment changes the text of the caller's own comment.
func (s *Service) EditComment(ctx context.Context, c Caller, id, cid int64, body string) (CommentView, error) {
	v, a, err := s.member(ctx, c, id)
	if err != nil {
		return CommentView{}, err
	}
	return a.one(s.editComment(ctx, v.Doc, a, cid, body))
}

// ResolveComment resolves or reopens a thread: its author, or someone who
// can edit the document.
func (s *Service) ResolveComment(ctx context.Context, c Caller, id, cid int64, resolved bool) (CommentView, error) {
	v, a, err := s.member(ctx, c, id)
	if err != nil {
		return CommentView{}, err
	}
	return a.one(s.resolveComment(ctx, v.Doc, a, cid, resolved))
}

// DeleteComment removes a comment (a thread with its replies): its author,
// or the document's owner.
func (s *Service) DeleteComment(ctx context.Context, c Caller, id, cid int64) error {
	v, a, err := s.member(ctx, c, id)
	if err != nil {
		return err
	}
	return s.deleteComment(ctx, v.Doc, a, cid)
}

func (s *Service) addComment(ctx context.Context, d domain.Document, a actor, in NewComment) (domain.DocumentComment, error) {
	body, err := domain.CleanCommentBody(in.Body)
	if err != nil {
		return domain.DocumentComment{}, err
	}
	cm := domain.DocumentComment{DocumentID: d.ID, ParentID: in.ParentID, AuthorName: a.name, Body: body}
	if a.userID != 0 {
		cm.AuthorUserID = &a.userID
	} else {
		cm.AuthorGuestID = &a.guestID
	}
	if in.ParentID == nil {
		if cm.Quote, cm.Prefix, cm.Suffix, err = domain.CleanAnchor(in.Quote, in.Prefix, in.Suffix); err != nil {
			return domain.DocumentComment{}, err
		}
		if in.Slide != nil && (d.Kind != domain.DocKindSlides || *in.Slide < 0) {
			return domain.DocumentComment{}, invalid("a slide is only given for slides, from 0")
		}
		cm.Slide = in.Slide
		n, err := s.comments().OpenThreads(ctx, d.ID)
		if err != nil {
			return domain.DocumentComment{}, err
		}
		if n >= domain.CommentMaxThreads {
			return domain.DocumentComment{}, invalid("this document has %d open comments; resolve some first", n)
		}
	}
	if a.guestID != 0 {
		n, err := s.comments().GuestCommentsSince(ctx, a.guestID, s.now().Add(-time.Minute))
		if err != nil {
			return domain.DocumentComment{}, err
		}
		if n >= domain.GuestCommentsPerMn {
			return domain.DocumentComment{}, ErrTooMany
		}
	}
	out, err := s.comments().CreateComment(ctx, cm)
	if errors.Is(err, domain.ErrNotFound) && in.ParentID != nil {
		return out, invalid("the comment you reply to is gone")
	}
	if err == nil {
		s.commentsChanged(ctx, d)
	}
	return out, err
}

// ofDocument returns comment cid when it is on document d.
func (s *Service) ofDocument(ctx context.Context, d domain.Document, cid int64) (domain.DocumentComment, error) {
	cm, err := s.comments().Comment(ctx, cid)
	if err == nil && cm.DocumentID != d.ID {
		err = domain.ErrNotFound
	}
	return cm, err
}

func (s *Service) editComment(ctx context.Context, d domain.Document, a actor, cid int64, body string) (domain.DocumentComment, error) {
	cm, err := s.ofDocument(ctx, d, cid)
	if err != nil {
		return cm, err
	}
	if !a.wrote(cm) {
		return cm, fmt.Errorf("%w: only its author edits a comment", domain.ErrForbidden)
	}
	if body, err = domain.CleanCommentBody(body); err != nil {
		return cm, err
	}
	out, err := s.comments().EditComment(ctx, cid, body)
	if err == nil {
		s.commentsChanged(ctx, d)
	}
	return out, err
}

func (s *Service) resolveComment(ctx context.Context, d domain.Document, a actor, cid int64, resolved bool) (domain.DocumentComment, error) {
	cm, err := s.ofDocument(ctx, d, cid)
	if err != nil {
		return cm, err
	}
	switch {
	case !cm.Thread():
		return cm, invalid("only a thread is resolved, not a reply")
	case !a.wrote(cm) && a.access < domain.AccessEdit:
		return cm, fmt.Errorf("%w: a thread is resolved by its author or someone who can edit the document", domain.ErrForbidden)
	}
	out, err := s.comments().ResolveComment(ctx, cid, resolved, a.name)
	if err == nil {
		s.commentsChanged(ctx, d)
	}
	return out, err
}

func (s *Service) deleteComment(ctx context.Context, d domain.Document, a actor, cid int64) error {
	cm, err := s.ofDocument(ctx, d, cid)
	if err != nil {
		return err
	}
	if !a.wrote(cm) && a.access < domain.AccessOwner {
		return fmt.Errorf("%w: a comment is deleted by its author or the document's owner", domain.ErrForbidden)
	}
	if err := s.comments().DeleteComment(ctx, cid); err != nil {
		return err
	}
	s.commentsChanged(ctx, d)
	return nil
}

// commentsChanged tells the members who can open d that its comments
// changed. Guests see it through their presence heartbeat.
func (s *Service) commentsChanged(ctx context.Context, d domain.Document) {
	s.notify(ctx, d, EventDocumentComments)
}

// Guest is a guest of a public document with the context to act in its
// workspace.
type Guest struct {
	ctx   context.Context
	Doc   domain.Document
	Guest domain.DocumentGuest
}

// PublicInfo is what anyone with the link learns before saying who they
// are: the kind and title, nothing else.
type PublicInfo struct {
	Kind  domain.DocumentKind
	Title string
}

// publicDoc returns the public document with token and a context in its
// workspace. ctx must be system work.
func (s *Service) publicDoc(ctx context.Context, token string) (domain.Document, context.Context, error) {
	if !domain.ValidPublicToken(token) {
		return domain.Document{}, ctx, domain.ErrNotFound
	}
	d, err := s.d.Store.PublicDocument(ctx, token)
	if err != nil {
		return d, ctx, err
	}
	return d, domain.WithWorkspace(ctx, d.WorkspaceID), nil
}

// Info returns the kind and title of a public document.
func (s *Service) Info(ctx context.Context, token string) (PublicInfo, error) {
	d, _, err := s.publicDoc(ctx, token)
	if err != nil {
		return PublicInfo{}, err
	}
	return PublicInfo{Kind: d.Kind, Title: d.Title}, nil
}

// Join makes a guest of a public document: by the name they typed, as
// Google vouched for them, or as the agnts account they are signed in with
// (g's Name, Email, Via and UserID). It returns the guest and its secret
// token, which only the guest keeps.
func (s *Service) Join(ctx context.Context, token string, g domain.DocumentGuest) (domain.DocumentGuest, string, error) {
	d, wctx, err := s.publicDoc(ctx, token)
	if err != nil {
		return domain.DocumentGuest{}, "", err
	}
	if s.comments() == nil {
		return domain.DocumentGuest{}, "", invalid("guests are not available on this server")
	}
	if g.Name, err = domain.CleanGuestName(g.Name); err != nil {
		return domain.DocumentGuest{}, "", err
	}
	if g.Via == "" {
		g.Via = domain.GuestByName
	}
	g.DocumentID = d.ID
	tok, hash, err := domain.NewGuestToken()
	if err != nil {
		return domain.DocumentGuest{}, "", err
	}
	g, err = s.comments().CreateGuest(wctx, g, hash)
	return g, tok, err
}

// Guest returns the guest with guestToken on the public document with
// token. ErrNoGuest when they have not said who they are (or their token
// is for another document); ErrNotFound when the link no longer works.
func (s *Service) Guest(ctx context.Context, token, guestToken string) (Guest, error) {
	d, wctx, err := s.publicDoc(ctx, token)
	if err != nil {
		return Guest{}, err
	}
	if guestToken == "" || s.comments() == nil {
		return Guest{}, ErrNoGuest
	}
	g, err := s.comments().GuestByToken(wctx, d.ID, domain.GuestTokenHash(guestToken))
	if errors.Is(err, domain.ErrNotFound) {
		return Guest{}, ErrNoGuest
	}
	if err != nil {
		return Guest{}, err
	}
	return Guest{ctx: wctx, Doc: d, Guest: g}, nil
}

func (g Guest) actor() actor {
	return actor{guestID: g.Guest.ID, name: g.Guest.Name, access: domain.AccessView}
}

// GuestComments returns the comments of a guest's document.
func (s *Service) GuestComments(g Guest) ([]CommentView, error) {
	return g.actor().views(s.comments().Comments(g.ctx, g.Doc.ID))
}

// GuestAddComment has a guest start a thread or reply.
func (s *Service) GuestAddComment(g Guest, in NewComment) (CommentView, error) {
	return g.actor().one(s.addComment(g.ctx, g.Doc, g.actor(), in))
}

// GuestEditComment changes a guest's own comment.
func (s *Service) GuestEditComment(g Guest, cid int64, body string) (CommentView, error) {
	return g.actor().one(s.editComment(g.ctx, g.Doc, g.actor(), cid, body))
}

// GuestResolveComment resolves or reopens a guest's own thread.
func (s *Service) GuestResolveComment(g Guest, cid int64, resolved bool) (CommentView, error) {
	return g.actor().one(s.resolveComment(g.ctx, g.Doc, g.actor(), cid, resolved))
}

// GuestDeleteComment removes a guest's own comment.
func (s *Service) GuestDeleteComment(g Guest, cid int64) error {
	return s.deleteComment(g.ctx, g.Doc, g.actor(), cid)
}

// Presence is who has a document open now, and the stamp of its comments.
type Presence struct {
	Viewers       []domain.Viewer
	You           string // the asker's domain.Viewer.Key
	CommentsStamp string
}

// Here records that the caller has the document open (or, leaving, no
// longer) and returns who else does.
func (s *Service) Here(ctx context.Context, c Caller, id int64, leaving bool) (Presence, error) {
	_, a, err := s.member(ctx, c, id)
	if err != nil {
		return Presence{}, err
	}
	return s.here(ctx, id, domain.Viewer{Kind: domain.ViewerMember, ID: c.UserID, Name: a.name, UserID: c.UserID}, leaving)
}

// GuestHere is Here for a guest.
func (s *Service) GuestHere(g Guest, leaving bool) (Presence, error) {
	v := domain.Viewer{Kind: domain.ViewerGuest, ID: g.Guest.ID, Name: g.Guest.Name, Via: g.Guest.Via}
	if g.Guest.UserID != nil {
		v.UserID = *g.Guest.UserID
	}
	return s.here(g.ctx, g.Doc.ID, v, leaving)
}

func (s *Service) here(ctx context.Context, id int64, v domain.Viewer, leaving bool) (Presence, error) {
	stamp, err := s.comments().CommentsStamp(ctx, id)
	if err != nil {
		return Presence{}, err
	}
	return Presence{Viewers: s.viewers.touch(id, v, leaving, s.now()), You: v.Key(), CommentsStamp: stamp}, nil
}
