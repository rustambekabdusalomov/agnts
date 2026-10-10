package domain

import (
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"
	"unicode/utf8"
)

// Pull request states, as the git host last reported them.
const (
	PullOpen   = "open"
	PullClosed = "closed"
	PullMerged = "merged"
)

// Why a pull request is waiting for you.
const (
	PullAssigned        = "assigned"
	PullReviewRequested = "review_requested"
)

// PullRequest is a pull request (GitHub) or merge request (GitLab) someone
// else opened, which agnts reviews for the person it waits for.
type PullRequest struct {
	Number int    `json:"number"` // GitLab: the IID
	URL    string `json:"url"`
	Title  string `json:"title"`
	Body   string `json:"body,omitempty"`
	Author string `json:"author"`
	// HeadRef is the branch on the git host (it may live in a fork);
	// FetchRef is where the head can be fetched from the repository
	// itself: refs/pull/42/head, refs/merge-requests/42/head.
	HeadRef  string `json:"headRef"`
	HeadSHA  string `json:"headSha"`
	BaseRef  string `json:"baseRef"`
	FetchRef string `json:"fetchRef"`
	Draft    bool   `json:"draft"`
	State    string `json:"state"`
	// Login is the git host user it waits for (the token's owner): whose
	// reviewer profile its reviews read. Why says how: assigned, or
	// review_requested.
	Login     string    `json:"login"`
	Why       string    `json:"why"`
	Additions int       `json:"additions,omitempty"`
	Deletions int       `json:"deletions,omitempty"`
	UpdatedAt time.Time `json:"updatedAt"`
	// PostedSHA is the commit whose review agnts last posted on the pull
	// request as a comment, and PostedAt when. agnts's own, not the host's.
	PostedSHA string     `json:"postedSha,omitempty"`
	PostedAt  *time.Time `json:"postedAt,omitempty"`
}

// Keep carries what agnts recorded on old (what it posted) over to p, a
// fresher copy from the git host.
func (p *PullRequest) Keep(old *PullRequest) {
	if old != nil {
		p.PostedSHA, p.PostedAt = old.PostedSHA, old.PostedAt
	}
}

// PullBodyMax caps the pull request description kept on a ticket.
const PullBodyMax = 20000

// Clean trims what the git host sent and caps the description.
func (p *PullRequest) Clean() {
	p.Title = clip(strings.TrimSpace(p.Title), 300)
	p.Body = clip(strings.TrimSpace(strings.ReplaceAll(p.Body, "\r\n", "\n")), PullBodyMax)
	if p.State == "" {
		p.State = PullOpen
	}
}

// Reviewer note kinds: what the person did when they told agnts.
const (
	NoteRereview  = "rereview"  // asked agnts to review again, with a note
	NoteDismissed = "dismissed" // dismissed agnts's review, with a reason
	NoteManual    = "manual"    // wrote it on the Reviews page
)

// ReviewerNoteMax caps one note.
const ReviewerNoteMax = 4000

// ReviewerNote is something a person told agnts about one of its pull
// request reviews: what it got wrong, missed or flagged for nothing. Every
// later review of a pull request waiting for the same person reads the
// notes not yet folded into their profile.
type ReviewerNote struct {
	ID          int64
	WorkspaceID int64
	Login       string // the git host user the review was for
	UserID      *int64 // who wrote it in agnts; nil for agnts itself
	Username    string // filled on reads
	RepoID      *int64
	RepoName    string // filled on reads
	TicketKey   string // "" for a note written on the Reviews page
	PullTitle   string
	Kind        string
	Note        string
	CreatedAt   time.Time
}

// Validate trims the note and checks it.
func (n *ReviewerNote) Validate() error {
	n.Note = strings.TrimSpace(n.Note)
	n.Login = strings.TrimSpace(n.Login)
	switch {
	case n.Login == "":
		return errors.New("a note needs the reviewer it is about")
	case n.Note == "":
		return errors.New("the note is empty")
	case utf8.RuneCountInString(n.Note) > ReviewerNoteMax:
		return fmt.Errorf("the note is longer than %d characters", ReviewerNoteMax)
	case !slices.Contains([]string{NoteRereview, NoteDismissed, NoteManual}, n.Kind):
		return fmt.Errorf("unknown note kind %q", n.Kind)
	}
	n.PullTitle = clip(strings.TrimSpace(n.PullTitle), 300)
	return nil
}

// ReviewerProfileMax caps a reviewer profile.
const ReviewerProfileMax = 8000

// ReviewerProfile is what agnts learned about how one person reviews pull
// requests: what they care about, what they call noise, how severe they
// rate things, the conventions they hold each repository to. Review runs
// fold new notes into it; the person can edit it on the Reviews page.
type ReviewerProfile struct {
	WorkspaceID int64
	Login       string
	Body        string // Markdown
	// LearnedThrough is the newest note folded into Body; later notes are
	// given to reviews as they are until a review folds them in.
	LearnedThrough int64
	// Notes counts the notes folded in so far.
	Notes     int
	UpdatedAt time.Time
}

// CleanReviewerProfile trims a profile body and checks its size.
func CleanReviewerProfile(s string) (string, error) {
	s = strings.TrimSpace(strings.ReplaceAll(s, "\r\n", "\n"))
	if utf8.RuneCountInString(s) > ReviewerProfileMax {
		return s, fmt.Errorf("the profile is longer than %d characters", ReviewerProfileMax)
	}
	if !utf8.ValidString(s) {
		return s, errors.New("the profile is not valid UTF-8")
	}
	return s, nil
}

// MergeMethods are how agnts can merge a pull request after your review.
var MergeMethods = []string{"merge", "squash", "rebase"}

// PullReviewSettings control the reviews of pull requests waiting for you.
type PullReviewSettings struct {
	// Enabled syncs the open pull requests waiting for you every few
	// minutes and reviews the new ones. Off, Sync on the Reviews page
	// still does it once.
	Enabled bool `json:"enabled"`
	// ReviewRequested also takes pull requests whose review is requested
	// from you, not only those assigned to you.
	ReviewRequested bool `json:"reviewRequested"`
	// SkipDrafts leaves draft pull requests alone until they are ready.
	SkipDrafts bool `json:"skipDrafts"`
	// Rereview reviews a pull request again when its author pushes new
	// commits while the review waits for you.
	Rereview bool `json:"rereview"`
	// MergeMethod is how an accepted pull request is merged.
	MergeMethod string `json:"mergeMethod"`
}

// DefaultPullReviewSettings returns the settings used before any are saved.
func DefaultPullReviewSettings() PullReviewSettings {
	return PullReviewSettings{ReviewRequested: true, SkipDrafts: true, Rereview: true, MergeMethod: "merge"}
}
