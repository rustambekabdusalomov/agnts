// Package vcs holds the provider-neutral repository views (branches,
// commits, pipelines, environments) and routes calls to GitHub or GitLab.
package vcs

import (
	"context"
	"errors"
	"strconv"
	"sync"
	"time"

	"golang.org/x/sync/singleflight"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// CI statuses, as the demo shows them.
const (
	CIOK       = "ok"
	CIFail     = "fail"
	CIRun      = "run"
	CIPending  = "pending"
	CIManual   = "manual"
	CISkip     = "skip"
	CICanceled = "canceled"
	CINone     = "none"
)

// Branch is one branch with its tip and how it compares to the default.
type Branch struct {
	Name    string
	Default bool
	SHA     string
	Message string
	Author  string
	Date    time.Time
	Ahead   int
	Behind  int
	CI      string
}

// Commit is one commit.
type Commit struct {
	SHA     string
	Message string
	Author  string
	Date    time.Time
	Add     int
	Del     int
	CI      string
	URL     string
}

// Stage is one stage (GitLab) or job (GitHub Actions) of a pipeline.
type Stage struct {
	ID       int64
	Name     string
	Status   string
	Duration time.Duration
	Manual   bool // can be started by hand (GitLab manual job)
}

// Pipeline is one CI run.
type Pipeline struct {
	ID       int64
	Name     string
	Branch   string
	SHA      string
	Message  string
	Trigger  string
	Status   string
	Created  time.Time
	Duration time.Duration
	URL      string
	Stages   []Stage
}

// Environment is a deployment target and what runs there.
type Environment struct {
	Name       string
	SHA        string
	DeployedAt *time.Time
	URL        string
}

// RemoteRepo is a repository the connected token can reach, offered for
// import on the Repositories page.
type RemoteRepo struct {
	FullName      string // owner/name, or group/sub/project on GitLab
	CloneURL      string // https
	DefaultBranch string
	Private       bool
	Description   string
	UpdatedAt     time.Time
}

// MaxRemoteRepos caps how many repositories an import listing fetches.
const MaxRemoteRepos = 500

// LocalBranch is a branch in agnts's own clone on the server: one per ticket
// checkout. agnts commits there first and pushes only after approval.
type LocalBranch struct {
	Name    string
	SHA     string
	Message string
	Author  string
	Date    time.Time
	Ahead   int // commits not on the default branch
	Behind  int // default branch commits the branch lacks
	// Unpushed counts commits origin's copy of the branch lacks, as of the
	// clone's last fetch; -1 when origin did not have the branch then.
	Unpushed int
}

// Member is someone with access to a repository.
type Member struct {
	Username  string
	Name      string // display name, when the host gives one
	AvatarURL string
	URL       string // profile page
	Role      string // the host's own role name: admin, write, Maintainer, Developer...
}

// Deploy starts a deployment: a GitLab manual job (JobID), or a GitHub
// workflow_dispatch of the repository's deploy workflow on Ref.
type Deploy struct {
	JobID int64
	Ref   string
}

// Browser reads a repository's activity and triggers deploys.
type Browser interface {
	Branches(ctx context.Context, repo domain.Repository) ([]Branch, error)
	// Commits returns one page (from 1) of the default branch's history, newest first.
	Commits(ctx context.Context, repo domain.Repository, page, perPage int) ([]Commit, error)
	// Pipelines returns one page (from 1) of CI runs, newest first, with stages.
	Pipelines(ctx context.Context, repo domain.Repository, page, perPage int) ([]Pipeline, error)
	Environments(ctx context.Context, repo domain.Repository) ([]Environment, error)
	Deploy(ctx context.Context, repo domain.Repository, d Deploy) error
	Members(ctx context.Context, repo domain.Repository) ([]Member, error)
}

// Provider is a git host: it opens and assigns pull requests and serves
// the browser.
type Provider interface {
	orchestrator.Host
	orchestrator.Assigner
	orchestrator.MergeChecker
	orchestrator.ReviewHost
	Browser
}

// Multi routes to the provider named on each repository.
type Multi struct {
	providers map[string]Provider

	mu    sync.Mutex
	cache map[string]cached
	gen   int64 // bumped by Forget: reads started before it are not kept
	group singleflight.Group
}

type cached struct {
	at  time.Time
	val any
}

// NewMulti returns a router over the given providers ("github", "gitlab").
func NewMulti(p map[string]Provider) *Multi {
	return &Multi{providers: p, cache: map[string]cached{}}
}

var _ Provider = (*Multi)(nil)

// ErrNotConnected is returned when the git host has no token.
var ErrNotConnected = errors.New("not connected")

// ErrUnsupported is returned for a repository on an unknown provider.
var ErrUnsupported = errors.New("this repository's git host is not connected")

func (m *Multi) pick(repo domain.Repository) (Provider, error) {
	p, ok := m.providers[repo.Provider]
	if !ok {
		return nil, ErrUnsupported
	}
	return p, nil
}

// remember caches read results briefly: the repository page polls, and
// provider APIs are rate-limited. Concurrent misses share one read, which
// goes on when the caller that started it leaves, so the next one finds it.
func remember[T any](ctx context.Context, m *Multi, key string, ttl time.Duration, f func(ctx context.Context) (T, error)) (T, error) {
	m.mu.Lock()
	if c, ok := m.cache[key]; ok && time.Since(c.at) < ttl {
		m.mu.Unlock()
		return c.val.(T), nil
	}
	gen := m.gen
	m.mu.Unlock()
	v, err, _ := m.group.Do(key+"@"+itoa(gen), func() (any, error) {
		v, err := f(context.WithoutCancel(ctx))
		if err == nil {
			m.mu.Lock()
			if m.gen == gen {
				m.cache[key] = cached{at: time.Now(), val: v}
			}
			m.mu.Unlock()
		}
		return v, err
	})
	if err != nil {
		var zero T
		return zero, err
	}
	return v.(T), nil
}

// ForgetAll drops every cached read (after a pipeline webhook).
func (m *Multi) ForgetAll() {
	m.mu.Lock()
	m.cache = map[string]cached{}
	m.gen++
	m.mu.Unlock()
}

// Forget drops cached reads for a repository (after a webhook or deploy).
func (m *Multi) Forget(repoID int64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.gen++
	prefix := cacheKey(repoID, "")
	for k := range m.cache {
		if len(k) >= len(prefix) && k[:len(prefix)] == prefix {
			delete(m.cache, k)
		}
	}
}

func cacheKey(id int64, what string) string {
	return "repo:" + itoa(id) + ":" + what
}

func itoa(i int64) string { return strconv.FormatInt(i, 10) }

// OpenPR implements orchestrator.Host.
func (m *Multi) OpenPR(ctx context.Context, repo domain.Repository, pr orchestrator.PR) (int, string, error) {
	p, err := m.pick(repo)
	if err != nil {
		return 0, "", err
	}
	return p.OpenPR(ctx, repo, pr)
}

// Branches implements Browser.
func (m *Multi) Branches(ctx context.Context, repo domain.Repository) ([]Branch, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return remember(ctx, m, cacheKey(repo.ID, "branches"), time.Minute, func(ctx context.Context) ([]Branch, error) { return p.Branches(ctx, repo) })
}

// Commits implements Browser.
func (m *Multi) Commits(ctx context.Context, repo domain.Repository, page, perPage int) ([]Commit, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	key := cacheKey(repo.ID, "commits:"+itoa(int64(page))+":"+itoa(int64(perPage)))
	return remember(ctx, m, key, time.Minute, func(ctx context.Context) ([]Commit, error) { return p.Commits(ctx, repo, page, perPage) })
}

// Pipelines implements Browser.
func (m *Multi) Pipelines(ctx context.Context, repo domain.Repository, page, perPage int) ([]Pipeline, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	key := cacheKey(repo.ID, "pipelines:"+itoa(int64(page))+":"+itoa(int64(perPage)))
	return remember(ctx, m, key, 20*time.Second, func(ctx context.Context) ([]Pipeline, error) { return p.Pipelines(ctx, repo, page, perPage) })
}

// PRMerged implements orchestrator.MergeChecker.
func (m *Multi) PRMerged(ctx context.Context, repo domain.Repository, number int) (bool, error) {
	p, err := m.pick(repo)
	if err != nil {
		return false, err
	}
	return p.PRMerged(ctx, repo, number)
}

// ReviewQueue implements orchestrator.ReviewHost. It is not cached: a
// sync wants the pull requests as they are.
func (m *Multi) ReviewQueue(ctx context.Context, repo domain.Repository, requested bool) ([]domain.PullRequest, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return p.ReviewQueue(ctx, repo, requested)
}

// PullRequest implements orchestrator.ReviewHost.
func (m *Multi) PullRequest(ctx context.Context, repo domain.Repository, number int) (domain.PullRequest, error) {
	p, err := m.pick(repo)
	if err != nil {
		return domain.PullRequest{}, err
	}
	return p.PullRequest(ctx, repo, number)
}

// MergePR implements orchestrator.ReviewHost.
func (m *Multi) MergePR(ctx context.Context, repo domain.Repository, number int, sha, method string) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	defer m.Forget(repo.ID)
	return p.MergePR(ctx, repo, number, sha, method)
}

// CommentPR implements orchestrator.ReviewHost.
func (m *Multi) CommentPR(ctx context.Context, repo domain.Repository, number int, body string) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	return p.CommentPR(ctx, repo, number, body)
}

// Assign implements orchestrator.Assigner.
func (m *Multi) Assign(ctx context.Context, repo domain.Repository, number int, usernames []string) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	return p.Assign(ctx, repo, number, usernames)
}

// Members lists who has access to the repository.
func (m *Multi) Members(ctx context.Context, repo domain.Repository) ([]Member, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return remember(ctx, m, cacheKey(repo.ID, "members"), 5*time.Minute, func(ctx context.Context) ([]Member, error) { return p.Members(ctx, repo) })
}

// Environments implements Browser.
func (m *Multi) Environments(ctx context.Context, repo domain.Repository) ([]Environment, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return remember(ctx, m, cacheKey(repo.ID, "envs"), time.Minute, func(ctx context.Context) ([]Environment, error) { return p.Environments(ctx, repo) })
}

// Deploy implements Browser.
func (m *Multi) Deploy(ctx context.Context, repo domain.Repository, d Deploy) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	defer m.Forget(repo.ID)
	return p.Deploy(ctx, repo, d)
}

// Limit runs f for every item with at most n at once.
func Limit[T any](items []T, n int, f func(i int, it T)) {
	var wg sync.WaitGroup
	sem := make(chan struct{}, n)
	for i, it := range items {
		wg.Add(1)
		sem <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-sem }()
			f(i, it)
		}()
	}
	wg.Wait()
}
