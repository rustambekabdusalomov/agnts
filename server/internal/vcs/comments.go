package vcs

import (
	"context"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.Conversation = (*Multi)(nil)

// threadsTTL is how long a pull request's conversation is cached: webhooks
// and agnts's own writes drop it sooner.
const threadsTTL = 15 * time.Second

func threadsKey(repoID int64, number int) string {
	return cacheKey(repoID, "threads:"+itoa(int64(number)))
}

// ForgetThreads drops the cached conversation of a pull request.
func (m *Multi) ForgetThreads(repoID int64, number int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.gen++
	delete(m.cache, threadsKey(repoID, number))
}

// PullRequests implements orchestrator.Conversation.
func (m *Multi) PullRequests(ctx context.Context, repo domain.Repository, state string, page, perPage int) ([]domain.PullRequest, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	key := cacheKey(repo.ID, "pulls:"+state+":"+itoa(int64(page))+":"+itoa(int64(perPage)))
	return remember(ctx, m, key, 30*time.Second, func(ctx context.Context) ([]domain.PullRequest, error) {
		return p.PullRequests(ctx, repo, state, page, perPage)
	})
}

// PullFiles implements orchestrator.Conversation.
func (m *Multi) PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return remember(ctx, m, cacheKey(repo.ID, "pullfiles:"+itoa(int64(number))), 30*time.Second, func(ctx context.Context) ([]domain.FileChange, error) {
		return p.PullFiles(ctx, repo, number)
	})
}

// Threads implements orchestrator.Conversation.
func (m *Multi) Threads(ctx context.Context, repo domain.Repository, number int) ([]domain.PRThread, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return remember(ctx, m, threadsKey(repo.ID, number), threadsTTL, func(ctx context.Context) ([]domain.PRThread, error) {
		return p.Threads(ctx, repo, number)
	})
}

// AddComment implements orchestrator.Conversation.
func (m *Multi) AddComment(ctx context.Context, repo domain.Repository, number int, c domain.NewPRComment) (domain.PRThread, error) {
	p, err := m.pick(repo)
	if err != nil {
		return domain.PRThread{}, err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.AddComment(ctx, repo, number, c)
}

// Reply implements orchestrator.Conversation.
func (m *Multi) Reply(ctx context.Context, repo domain.Repository, number int, threadID, body string) (domain.PRComment, error) {
	p, err := m.pick(repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.Reply(ctx, repo, number, threadID, body)
}

// EditComment implements orchestrator.Conversation.
func (m *Multi) EditComment(ctx context.Context, repo domain.Repository, number int, commentID, body string) (domain.PRComment, error) {
	p, err := m.pick(repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.EditComment(ctx, repo, number, commentID, body)
}

// DeleteComment implements orchestrator.Conversation.
func (m *Multi) DeleteComment(ctx context.Context, repo domain.Repository, number int, commentID string) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.DeleteComment(ctx, repo, number, commentID)
}

// ResolveThread implements orchestrator.Conversation.
func (m *Multi) ResolveThread(ctx context.Context, repo domain.Repository, number int, threadID string, resolved bool) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.ResolveThread(ctx, repo, number, threadID, resolved)
}

// PostReview implements orchestrator.Conversation.
func (m *Multi) PostReview(ctx context.Context, repo domain.Repository, number int, headSHA, body string, cs []domain.NewPRComment, requestChanges bool) (string, []domain.PRThread, error) {
	p, err := m.pick(repo)
	if err != nil {
		return "", nil, err
	}
	defer m.ForgetThreads(repo.ID, number)
	return p.PostReview(ctx, repo, number, headSHA, body, cs, requestChanges)
}
