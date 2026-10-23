package domain

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

// GuestVia is how a guest said who they are.
type GuestVia string

// How guests say who they are.
const (
	GuestByName    GuestVia = "name"    // typed a name; nobody vouched for it
	GuestByGoogle  GuestVia = "google"  // Google vouched for the name and email
	GuestByAccount GuestVia = "account" // was signed in to agnts
)

// DocumentGuest is someone who opened a public document through its link:
// by a name they typed, as Google vouched for them, or as the agnts account
// they were signed in with (UserID). A guest belongs to one document.
type DocumentGuest struct {
	ID         int64
	DocumentID int64
	Name       string
	Email      string
	Via        GuestVia
	UserID     *int64
	CreatedAt  time.Time
}

// DocumentComment is one comment on a document. A thread's first comment
// is on a selection (Quote, with Prefix and Suffix to tell repeats apart,
// and Slide for a deck); replies have a ParentID and no selection.
type DocumentComment struct {
	ID            int64
	DocumentID    int64
	ParentID      *int64
	AuthorUserID  *int64
	AuthorGuestID *int64
	AuthorName    string
	AuthorEmail   string   // a guest's, when Google or an account gave one; filled on reads
	AuthorVia     GuestVia // how a guest said who they are; filled on reads
	Body          string
	Quote         string
	Prefix        string
	Suffix        string
	Slide         *int
	Version       int
	ResolvedAt    *time.Time
	ResolvedBy    string
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

// Thread reports whether c starts a thread.
func (c DocumentComment) Thread() bool { return c.ParentID == nil }

// Limits of comments.
const (
	CommentMaxBody     = 5000 // runes
	CommentMaxQuote    = 1000 // runes
	CommentMaxAround   = 64   // runes of prefix and suffix
	CommentMaxThreads  = 200  // open threads per document
	GuestNameMin       = 2
	GuestNameMax       = 60
	GuestCommentsPerMn = 10
)

// CleanCommentBody trims a comment and checks it.
func CleanCommentBody(s string) (string, error) {
	s = strings.TrimSpace(strings.ReplaceAll(s, "\r\n", "\n"))
	switch {
	case s == "":
		return "", docInvalid("write something")
	case !utf8.ValidString(s):
		return "", docInvalid("the comment is not valid UTF-8")
	case utf8.RuneCountInString(s) > CommentMaxBody:
		return "", docInvalid("a comment is at most %d characters", CommentMaxBody)
	}
	return s, nil
}

// CleanGuestName trims a guest's name to one line and checks it.
func CleanGuestName(s string) (string, error) {
	s = strings.Join(strings.Fields(s), " ")
	switch n := utf8.RuneCountInString(s); {
	case !utf8.ValidString(s):
		return "", docInvalid("the name is not valid UTF-8")
	case n < GuestNameMin:
		return "", docInvalid("type your name")
	case n > GuestNameMax:
		return "", docInvalid("a name is at most %d characters", GuestNameMax)
	}
	return s, nil
}

// clipRunes keeps at most n runes of s; fromEnd keeps the last ones.
func clipRunes(s string, n int, fromEnd bool) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	if fromEnd {
		return string(r[len(r)-n:])
	}
	return string(r[:n])
}

// CleanAnchor checks a thread's selection and trims the text around it.
func CleanAnchor(quote, prefix, suffix string) (string, string, string, error) {
	quote = strings.TrimSpace(quote)
	switch {
	case quote == "":
		return "", "", "", docInvalid("select the text the comment is about")
	case !utf8.ValidString(quote + prefix + suffix):
		return "", "", "", docInvalid("the selection is not valid UTF-8")
	case utf8.RuneCountInString(quote) > CommentMaxQuote:
		return "", "", "", docInvalid("select at most %d characters", CommentMaxQuote)
	}
	return quote, clipRunes(prefix, CommentMaxAround, true), clipRunes(suffix, CommentMaxAround, false), nil
}

// NewGuestToken returns a guest's secret token and the hash that is kept.
func NewGuestToken() (string, []byte, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", nil, err
	}
	tok := base64.RawURLEncoding.EncodeToString(b)
	return tok, GuestTokenHash(tok), nil
}

// GuestTokenHash is the stored form of a guest token.
func GuestTokenHash(tok string) []byte {
	h := sha256.Sum256([]byte(tok))
	return h[:]
}

// ViewerKind says whether a viewer is a member or a guest.
type ViewerKind string

// Viewer kinds.
const (
	ViewerMember ViewerKind = "member"
	ViewerGuest  ViewerKind = "guest"
)

// Viewer is someone who has a document open now.
type Viewer struct {
	Kind   ViewerKind
	ID     int64 // the user or the guest
	Name   string
	Via    GuestVia // a guest's
	UserID int64    // a member's, or a guest's who came signed in
}

// Key tells viewers apart across kinds: one person signed in on the
// document page and on its public link is one viewer.
func (v Viewer) Key() string {
	if v.UserID > 0 {
		return "u" + strconv.FormatInt(v.UserID, 10)
	}
	if v.Kind == ViewerGuest {
		return "g" + strconv.FormatInt(v.ID, 10)
	}
	return "u" + strconv.FormatInt(v.ID, 10)
}
