package domain

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"slices"
	"strings"
	"time"
	"unicode/utf8"
)

// Draft comments of a pull request review. Every comment agnts's review
// writes (the summary and each finding) is first a draft kept in agnts. A
// person accepts, edits or dismisses each one, and only the accepted ones
// are published on the git host, together as one review. People can add
// their own drafts to the same review. Drafts survive re-reviews: they are
// matched by FindingKey.

// Kinds of draft.
const (
	DraftSummary = "summary" // the review's summary and verdict
	DraftFinding = "finding" // one finding, on its line when it has one
	DraftComment = "comment" // written by a person in agnts
)

// Draft states.
const (
	DraftOpen       = "draft"
	DraftAccepted   = "accepted"
	DraftPublishing = "publishing" // claimed by a publish in progress
	DraftDismissed  = "dismissed"
	DraftPublished  = "published"
	DraftOutdated   = "outdated" // its finding is gone from the newest review
)

// DraftDismissMax caps the reason a draft was dismissed.
const DraftDismissMax = 1000

// DraftPublishingStale is how long a draft may stay claimed by a publish
// before it is taken as left behind by a crash and accepted again.
const DraftPublishingStale = 10 * time.Minute

// ReviewDraft is one comment of a review, kept in agnts until published.
type ReviewDraft struct {
	ID       int64
	TicketID int64
	RepoID   int64
	Number   int
	Kind     string
	// Key is FindingKey for a finding, "summary" for the summary and a
	// random key for a person's comment: one draft per key per ticket.
	Key        string
	Severity   string
	Category   string
	Title      string
	Confidence float64
	Pass       string
	// Path and Line anchor it on the new version of the file; Line may be
	// outside the diff, and both are empty for a general comment.
	Path string
	Line int
	// HeadSHA is the commit it was written about, BaseSHA and StartSHA the
	// rest of the diff it belongs to (GitLab needs them for a line).
	HeadSHA  string
	BaseSHA  string
	StartSHA string
	// Body is the Markdown that will be published. Edited: a person
	// changed it, and re-reviews keep their text.
	Body   string
	Edited bool
	State  string
	// DismissReason is why it was dismissed; Error why the last publish
	// of it failed.
	DismissReason string
	Error         string
	// PostID is its pr_posts row once published (a published summary
	// keeps it when a re-review makes it a draft again, to edit it).
	PostID *int64
	// Noted: what a person did with it is in their reviewer notes.
	Noted     bool
	AuthorID  *int64 // who wrote it (DraftComment)
	Author    string // filled on reads
	DecidedBy *int64
	Decider   string // filled on reads
	DecidedAt *time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
}

// OnLine reports whether the draft is anchored on a line.
func (d ReviewDraft) OnLine() bool { return d.Path != "" && d.Line > 0 }

// Pending reports whether a person still has to decide on it.
func (d ReviewDraft) Pending() bool { return d.State == DraftOpen }

// SeverityRank orders severities, most severe first; unknown last.
func SeverityRank(s string) int {
	if i := slices.Index(FindingSeverities, s); i >= 0 {
		return i
	}
	return len(FindingSeverities)
}

// NewDraftKey returns a key for a person's comment.
func NewDraftKey() string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return "c" + hex.EncodeToString(b)
}

// CleanDraftBody trims a draft's text and checks it can be posted.
func CleanDraftBody(s string) (string, error) {
	s = strings.TrimSpace(strings.ReplaceAll(s, "\r\n", "\n"))
	switch {
	case s == "":
		return s, errors.New("the comment is empty")
	case len(s) > PRCommentMax:
		return s, errors.New("the comment is too long")
	case !utf8.ValidString(s):
		return s, errors.New("the comment is not valid text")
	}
	return s, nil
}

// MergeReviewDrafts folds a new review's drafts (incoming, all DraftOpen,
// keyed by Kind and Key) into the ticket's existing ones and returns every
// draft that changed or is new (ID 0). The rules:
//
//   - a new key is a new draft;
//   - an open or accepted draft takes the new text (unless a person edited
//     it), anchor and rating, and keeps its state;
//   - a dismissed finding stays dismissed: it is not asked about again;
//   - a published finding stays published (publishing answers in its
//     thread if it is still there);
//   - a dismissed or published summary is a draft again: new commits have
//     a new verdict; a published one keeps PostID so it is edited in place;
//   - an outdated draft whose finding is back is a draft again;
//   - open and accepted findings missing from the new review are outdated;
//   - drafts being published, and people's comments, are left alone.
func MergeReviewDrafts(existing, incoming []ReviewDraft, now time.Time) []ReviewDraft {
	key := func(d ReviewDraft) string { return d.Kind + "\x00" + d.Key }
	have := map[string]int{}
	for i, d := range existing {
		have[key(d)] = i
	}
	seen := map[string]bool{}
	var out []ReviewDraft
	for _, in := range incoming {
		k := key(in)
		seen[k] = true
		i, ok := have[k]
		if !ok {
			in.ID, in.State, in.CreatedAt, in.UpdatedAt = 0, DraftOpen, now, now
			out = append(out, in)
			continue
		}
		d := existing[i]
		if d.State == DraftPublishing {
			continue
		}
		before := d
		d.Severity, d.Category, d.Title, d.Confidence, d.Pass = in.Severity, in.Category, in.Title, in.Confidence, in.Pass
		d.Path, d.Line, d.HeadSHA, d.BaseSHA, d.StartSHA = in.Path, in.Line, in.HeadSHA, in.BaseSHA, in.StartSHA
		switch {
		case d.Kind == DraftSummary && (d.State == DraftDismissed || d.State == DraftPublished):
			// A new verdict: a published text was already used, so the new
			// one replaces it even if a person had edited it.
			d.State, d.Body, d.Edited, d.DismissReason, d.Noted = DraftOpen, in.Body, false, "", false
			d.DecidedBy, d.DecidedAt = nil, nil
		case d.State == DraftOutdated:
			d.State = DraftOpen
			if !d.Edited {
				d.Body = in.Body
			}
		case d.State == DraftOpen || d.State == DraftAccepted:
			if !d.Edited {
				d.Body = in.Body
			}
		}
		d.Error = ""
		if d != before {
			d.UpdatedAt = now
			out = append(out, d)
		}
	}
	for _, d := range existing {
		if seen[key(d)] || d.Kind == DraftComment {
			continue
		}
		if d.State == DraftOpen || d.State == DraftAccepted {
			d.State, d.Error, d.UpdatedAt = DraftOutdated, "", now
			d.DecidedBy, d.DecidedAt = nil, nil
			out = append(out, d)
		}
	}
	return out
}
