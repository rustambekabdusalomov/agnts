package orchestrator

import (
	"context"

	"agnts/internal/domain"
)

// Conversation is a git host's side of pull request comments: it reads a
// pull request's threads and posts, edits, deletes and resolves comments,
// as the token's user.
type Conversation interface {
	// PullRequests returns one page (from 1) of repo's pull requests in
	// state (open, closed, merged or all), most recently updated first.
	PullRequests(ctx context.Context, repo domain.Repository, state string, page, perPage int) ([]domain.PullRequest, error)
	// PullFiles returns the files a pull request changes, with their
	// patches (at most PullFilesMax).
	PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error)
	// Threads returns a pull request's conversation, oldest first.
	Threads(ctx context.Context, repo domain.Repository, number int) ([]domain.PRThread, error)
	// AddComment starts a thread: a general comment, or an inline one.
	// It returns domain.ErrNotInDiff for a line outside the diff.
	AddComment(ctx context.Context, repo domain.Repository, number int, c domain.NewPRComment) (domain.PRThread, error)
	// Reply answers in a thread.
	Reply(ctx context.Context, repo domain.Repository, number int, threadID, body string) (domain.PRComment, error)
	// EditComment replaces a comment's text.
	EditComment(ctx context.Context, repo domain.Repository, number int, commentID, body string) (domain.PRComment, error)
	// DeleteComment removes a comment.
	DeleteComment(ctx context.Context, repo domain.Repository, number int, commentID string) error
	// ResolveThread resolves or reopens an inline thread.
	ResolveThread(ctx context.Context, repo domain.Repository, number int, threadID string, resolved bool) error
	// PostReview posts body and the inline comments together, as one
	// review (GitHub) or one batch of draft notes (GitLab), so people get
	// one notification. requestChanges asks for changes where the host
	// can (GitHub). It returns the summary's comment id ("" when the host
	// made none) and each inline comment's thread, in order.
	PostReview(ctx context.Context, repo domain.Repository, number int, headSHA, body string, cs []domain.NewPRComment, requestChanges bool) (string, []domain.PRThread, error)
}

// PullFilesMax caps the files of a pull request read from the git host.
const PullFilesMax = 1000

// PRPosts keeps what agnts posted on pull requests and which reviewer
// threads it took as feedback.
type PRPosts interface {
	AddPRPost(ctx context.Context, p domain.PRPost) (domain.PRPost, error)
	PRPosts(ctx context.Context, repoID int64, number int) ([]domain.PRPost, error)
	UpdatePRPost(ctx context.Context, id int64, headSHA string, resolved bool) error
	DeletePRPost(ctx context.Context, repoID int64, number int, commentID string) error
	SaveThreadFeedback(ctx context.Context, fs []domain.PRThreadFeedback) error
	ThreadFeedback(ctx context.Context, ticketID int64) ([]domain.PRThreadFeedback, error)
	MarkThreadReplied(ctx context.Context, ticketID int64, threadID string) error
}
