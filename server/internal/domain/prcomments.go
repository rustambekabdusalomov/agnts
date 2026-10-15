package domain

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"strings"
	"time"
	"unicode/utf8"
)

// The conversation of a pull request (GitHub) or merge request (GitLab):
// general comments, review summaries and threads on diff lines. The git
// host keeps it; agnts reads it live and records only what it posted
// itself (PRPost) and which reviewer threads it took as feedback.

// Kinds of thread.
const (
	ThreadGeneral = "general" // a comment on the pull request itself
	ThreadInline  = "inline"  // a thread on a diff line
	ThreadReview  = "review"  // a GitHub review's summary
)

// PRComment is one comment on a pull request.
type PRComment struct {
	// ID is opaque outside the git host adapter: it says which API the
	// comment lives in (GitHub issue or review comment, GitLab note).
	ID        string
	Author    string
	AvatarURL string
	Body      string // Markdown, as the host stores it
	CreatedAt time.Time
	UpdatedAt time.Time
	URL       string
	// Mine: written by the token's user, who may edit and delete it.
	Mine bool
	// System: a note the host wrote (GitLab "added 2 commits"); read-only.
	System bool
	// Agnts: agnts posted it (it is in pr_posts).
	Agnts bool
}

// Edited reports whether the comment changed after it was written.
func (c PRComment) Edited() bool { return c.UpdatedAt.Sub(c.CreatedAt) > time.Second }

// PRThread is a conversation on a pull request: a general comment (one
// comment, no Path), a review summary, or a thread on a diff line.
type PRThread struct {
	ID   string // opaque, like PRComment.ID
	Kind string // ThreadGeneral, ThreadInline or ThreadReview
	// Path, Line (in the new file) or OldLine (a removed line), and
	// StartLine for a range: where an inline thread is.
	Path      string
	Line      int
	OldLine   int
	StartLine int
	DiffHunk  string // the diff around the line, as the host has it
	CommitSHA string // the commit it was written on
	// Outdated: the line changed or vanished since the thread started.
	Outdated   bool
	Resolvable bool
	Resolved   bool
	// ReviewState is a review's verdict: APPROVED, CHANGES_REQUESTED or
	// COMMENTED (ThreadReview only).
	ReviewState string
	Comments    []PRComment // oldest first
}

// Last returns the thread's newest comment.
func (t PRThread) Last() (PRComment, bool) {
	if len(t.Comments) == 0 {
		return PRComment{}, false
	}
	return t.Comments[len(t.Comments)-1], true
}

// Starter returns who started the thread.
func (t PRThread) Starter() string {
	if len(t.Comments) == 0 {
		return ""
	}
	return t.Comments[0].Author
}

// NewPRComment is a comment to post. With Path it goes on Line of the new
// file (OldLine for a removed line), from StartLine for a range, on the
// commit HeadSHA; without it, on the pull request itself.
type NewPRComment struct {
	Body      string
	Path      string
	Line      int
	OldLine   int
	StartLine int
	HeadSHA   string
}

// PRCommentMax caps a comment agnts posts (both hosts take 65,536
// characters; GitHub counts bytes).
const PRCommentMax = 60000

// ErrNotInDiff is returned for an inline comment on a line the pull
// request does not change: the git host refuses those.
var ErrNotInDiff = errors.New("that line is not part of the pull request's diff")

// Check validates a comment before it is posted.
func (c *NewPRComment) Check() error {
	c.Body = strings.TrimSpace(c.Body)
	c.Path = strings.TrimSpace(c.Path)
	switch {
	case c.Body == "":
		return errors.New("the comment is empty")
	case len(c.Body) > PRCommentMax:
		return errors.New("the comment is too long")
	case !utf8.ValidString(c.Body):
		return errors.New("the comment is not valid text")
	case c.Path == "" && (c.Line != 0 || c.OldLine != 0):
		return errors.New("a line needs a file")
	case c.Path != "" && c.Line <= 0 && c.OldLine <= 0:
		return errors.New("an inline comment needs a line")
	case c.Line < 0 || c.OldLine < 0 || c.StartLine < 0:
		return errors.New("lines start at 1")
	case c.StartLine > 0 && (c.Line == 0 || c.StartLine >= c.Line):
		return errors.New("a range must start before its last line")
	}
	return nil
}

// Kinds of PRPost.
const (
	PostSummary = "summary" // the review summary comment
	PostFinding = "finding" // one review finding, inline
	PostReply   = "reply"   // an answer in a reviewer's thread
	PostComment = "comment" // a comment someone wrote through agnts
)

// PRPost is a comment agnts posted on a pull request, so a later review
// can edit or answer it instead of posting again.
type PRPost struct {
	ID         int64
	RepoID     int64
	Number     int
	TicketID   *int64
	CommentID  string
	ThreadID   string
	Kind       string
	FindingKey string // FindingKey of the finding it carries
	HeadSHA    string // the commit it was written about
	Resolved   bool   // agnts resolved its thread (the finding is gone)
	PostedBy   *int64
	CreatedAt  time.Time
}

// FindingKey identifies a finding across reviews of new commits: its file
// and title, not its line, which moves.
func FindingKey(f Finding) string {
	h := sha256.Sum256([]byte(strings.ToLower(strings.TrimSpace(f.File)) + "\x00" + strings.ToLower(strings.TrimSpace(f.Title))))
	return hex.EncodeToString(h[:8])
}

// PRThreadFeedback is a reviewer's thread on agnts's own pull request that
// was sent back to the ticket as feedback.
type PRThreadFeedback struct {
	TicketID int64
	RepoID   int64
	Number   int
	ThreadID string
	// LastCommentID is the newest comment when it was sent: a newer one
	// makes the thread new again.
	LastCommentID string
	Revision      int // the ticket's revision that addresses it
	Replied       bool
	CreatedAt     time.Time
}

// Actions a coding run reports for a reviewer's thread.
const (
	ThreadFixed    = "fixed"
	ThreadAnswered = "answered"
	ThreadDeclined = "declined"
)

// ThreadAnswer is what a coding run did about one reviewer thread.
type ThreadAnswer struct {
	ID     string `json:"id"`
	Action string `json:"action"`
	Note   string `json:"note"`
}

// PRCommentSettings is how agnts takes part in pull request conversations.
type PRCommentSettings struct {
	// Attribution adds "via agnts by <person>" to comments written through
	// agnts: they all go out as the token's user.
	Attribution bool `json:"attribution"`
	// LearnFromComments adds the comments you write on others' pull
	// requests on the git host to your reviewer notes.
	LearnFromComments bool `json:"learnFromComments"`
	// ResolveFixed resolves a reviewer's thread once agnts pushed the fix
	// and answered it.
	ResolveFixed bool `json:"resolveFixed"`
	// AutoAddress sends unresolved threads back to the ticket when a
	// reviewer requests changes on agnts's pull request. The fix still
	// waits for your approval.
	AutoAddress bool `json:"autoAddress"`
}

// DefaultPRCommentSettings returns the settings used before any are saved.
func DefaultPRCommentSettings() PRCommentSettings {
	return PRCommentSettings{Attribution: true, LearnFromComments: true, ResolveFixed: true}
}

// PRCommentEvent is what a webhook says about a pull request's
// conversation.
type PRCommentEvent struct {
	Provider string
	Repo     string // owner/name, or the GitLab project path
	Number   int
	Author   string
	Body     string
	// Action: created, edited, deleted, submitted (a review), resolved,
	// unresolved.
	Action string
	// ReviewState is a submitted review's verdict (GitHub, lower case:
	// approved, changes_requested, commented).
	ReviewState string
	// Inline: the comment is on a diff line.
	Inline bool
}

// Event type of the conversation.
const (
	// EventPRComment: a pull request's conversation changed (data "repo",
	// "repoId", "number"); clients showing it read it again.
	EventPRComment = "pr_comment"
	// EventThreadsFeedback: reviewer threads went back to the ticket.
	EventThreadsFeedback = "threads_feedback"
)

// SameRepo reports whether a clone URL is the repository the host names
// owner/name (GitHub) or group/sub/project (GitLab).
func SameRepo(cloneURL, name string) bool {
	if name == "" {
		return false
	}
	u := strings.ToLower(strings.TrimSuffix(strings.TrimSpace(cloneURL), ".git"))
	if i := strings.Index(u, "://"); i >= 0 {
		u = u[i+3:]
		if j := strings.IndexByte(u, '/'); j >= 0 {
			u = u[j+1:]
		}
	} else if i := strings.IndexByte(u, ':'); i >= 0 { // git@host:owner/name
		u = u[i+1:]
	}
	u = strings.Trim(u, "/")
	n := strings.Trim(strings.ToLower(name), "/")
	// GitLab under a path prefix (https://host/gitlab/group/project).
	return u == n || strings.HasSuffix(u, "/"+n)
}
