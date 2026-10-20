// Package commitlink links commits on the git host to tickets: a commit
// whose branch or message has a ticket's number (or key) belongs to that
// ticket, whoever made it. Pushes come from the webhooks; earlier history
// is scanned when a ticket gets a number and when a repository is added.
package commitlink

import (
	"context"
	"fmt"
	"log/slog"
	"slices"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
)

// Store keeps the links and reads tickets and repositories.
type Store interface {
	ListRepositories(ctx context.Context) ([]domain.Repository, error)
	TicketsByTokens(ctx context.Context, tokens []string) ([]domain.Ticket, error)
	UpsertCommitLinks(ctx context.Context, links []domain.CommitLink) (map[int64]int, error)
	DeleteCommitLinksByToken(ctx context.Context, ticketID int64, token string) error
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Host reads commits on the git host (vcs.HistoryReader).
type Host interface {
	BranchNames(ctx context.Context, repo domain.Repository, max int) ([]string, error)
	History(ctx context.Context, repo domain.Repository, ref string, page, perPage int) ([]domain.PushedCommit, error)
	Ahead(ctx context.Context, repo domain.Repository, base, head string) ([]domain.PushedCommit, error)
}

const (
	// historyDepth is how many of the default branch's newest commits a
	// scan reads.
	historyDepth = 500
	// historyAge stops a scan at commits older than this.
	historyAge = 90 * 24 * time.Hour
	// maxBranches is how many branch names a scan reads.
	maxBranches = 300
	// maxBranchScans is how many branches with a number one scan reads
	// the commits of.
	maxBranchScans = 50
	// snapshotTTL is how long a repository's branch names and history are
	// reused between scans, so many tickets arriving at once (a tracker
	// import) read them once.
	snapshotTTL = 10 * time.Minute
	// scanTimeout bounds one scan or push.
	scanTimeout = 5 * time.Minute
	// workers is how many scans and pushes run at once.
	workers = 2
)

// Service links commits to tickets.
type Service struct {
	store Store
	host  Host
	log   *slog.Logger

	// async runs work off the caller (a webhook request, a ticket
	// change); tests replace it.
	async func(func())
	slots chan struct{}

	mu    sync.Mutex
	snaps map[int64]snapshot // by repository
}

// snapshot is a repository's branch names and default-branch history.
type snapshot struct {
	at       time.Time
	branches []string
	history  []domain.PushedCommit
}

// New returns the service.
func New(store Store, host Host, log *slog.Logger) *Service {
	return &Service{store: store, host: host, log: log, slots: make(chan struct{}, workers), snaps: map[int64]snapshot{},
		async: func(f func()) { go f() }}
}

// run does f in the background, at most workers at a time, keeping the
// context's workspace but not its deadline.
func (s *Service) run(ctx context.Context, what string, f func(ctx context.Context) error) {
	ctx = context.WithoutCancel(ctx)
	s.async(func() {
		s.slots <- struct{}{}
		defer func() { <-s.slots }()
		ctx, cancel := context.WithTimeout(ctx, scanTimeout)
		defer cancel()
		if err := f(ctx); err != nil {
			s.log.Warn("commit links: "+what, "err", err)
		}
	})
}

// CommitsPushed implements vcs.PushSink: it returns at once and links the
// push's commits in the background, so the webhook does not time out.
func (s *Service) CommitsPushed(ctx context.Context, p domain.Push) error {
	s.run(ctx, "push to "+p.Repo+" "+p.Branch, func(ctx context.Context) error { return s.Push(ctx, p) })
	return nil
}

// Push links a push's commits now.
func (s *Service) Push(ctx context.Context, p domain.Push) error {
	if p.Deleted() || p.Branch == "" {
		return nil
	}
	repo, ok, err := s.repoNamed(ctx, p.Provider, p.Repo)
	if err != nil || !ok {
		return err
	}
	commits := p.Commits
	if p.Total > len(commits) {
		// The host left commits out of the payload: read them.
		base := p.Before
		if p.NewBranch() {
			base = repo.DefaultBranch
		}
		if more, err := s.host.Ahead(ctx, repo, base, p.After); err != nil {
			s.log.Warn("commit links: read the rest of a push", "repo", repo.Name, "branch", p.Branch, "err", err)
		} else if len(more) > len(commits) {
			commits = more
		}
	}
	links, err := s.match(ctx, repo, p.Branch, commits, nil)
	if err != nil {
		return err
	}
	added, err := s.store.UpsertCommitLinks(ctx, links)
	if err != nil {
		return err
	}
	who := p.Pusher
	if who == "" {
		who = "someone"
	}
	for _, key := range touched(links, added) {
		n := added[key.id]
		s.event(ctx, key.key, domain.OriginWebhook, fmt.Sprintf("%s pushed %s to %s (%s)", who, plural(n, "commit"), p.Branch, repo.Name),
			map[string]any{"repo": repo.Name, "repoId": repo.ID, "branch": p.Branch, "commits": n, "by": p.Pusher})
	}
	return nil
}

// TicketNumberChanged implements orchestrator.CommitLinker: a ticket
// arrived, or its number changed from old. Links made through the old
// number go, and the repositories' history is scanned for the ticket in
// the background.
func (s *Service) TicketNumberChanged(ctx context.Context, t domain.Ticket, old string) {
	s.run(ctx, "scan for "+t.Key, func(ctx context.Context) error {
		if old != "" && !strings.EqualFold(old, t.TicketNumber) && !strings.EqualFold(old, t.Key) {
			if err := s.store.DeleteCommitLinksByToken(ctx, t.ID, strings.ToLower(old)); err != nil {
				return err
			}
		}
		return s.ScanTicket(ctx, t)
	})
}

// RepositoryAdded scans a new repository's history for all tickets in the
// background.
func (s *Service) RepositoryAdded(ctx context.Context, repo domain.Repository) {
	s.run(ctx, "scan "+repo.Name, func(ctx context.Context) error { return s.ScanRepo(ctx, repo, nil) })
}

// ScanTicket links the commits in the workspace's repositories that have
// t's number or key.
func (s *Service) ScanTicket(ctx context.Context, t domain.Ticket) error {
	repos, err := s.store.ListRepositories(ctx)
	if err != nil {
		return err
	}
	tokens := domain.TicketTokensOf(t)
	keep := func(tok string) bool { return slices.Contains(tokens, tok) }
	for _, r := range repos {
		if r.ArchivedAt != nil || r.CloneURL == "" {
			continue
		}
		if err := s.ScanRepo(ctx, r, keep); err != nil {
			s.log.Warn("commit links: scan", "repo", r.Name, "ticket", t.Key, "err", err)
		}
	}
	return nil
}

// ScanRepo links the commits of a repository's recent default-branch
// history and of its branches that have a ticket's number. keep, when not
// nil, limits the scan to the tokens it accepts.
func (s *Service) ScanRepo(ctx context.Context, repo domain.Repository, keep func(token string) bool) error {
	snap, err := s.snapshot(ctx, repo)
	if err != nil {
		return err
	}
	links, err := s.match(ctx, repo, repo.DefaultBranch, snap.history, keep)
	if err != nil {
		return err
	}
	scanned := 0
	for _, b := range snap.branches {
		if b == repo.DefaultBranch || !slices.ContainsFunc(domain.TicketTokens(b), func(tok string) bool { return keep == nil || keep(tok) }) {
			continue
		}
		if scanned++; scanned > maxBranchScans {
			break
		}
		commits, err := s.host.Ahead(ctx, repo, repo.DefaultBranch, b)
		if err != nil {
			s.log.Warn("commit links: read a branch", "repo", repo.Name, "branch", b, "err", err)
			continue
		}
		more, err := s.match(ctx, repo, b, commits, keep)
		if err != nil {
			return err
		}
		links = append(links, more...)
	}
	added, err := s.store.UpsertCommitLinks(ctx, links)
	if err != nil {
		return err
	}
	for _, key := range touched(links, added) {
		n := added[key.id]
		s.event(ctx, key.key, domain.OriginSystem, fmt.Sprintf("Linked %s found in %s", plural(n, "earlier commit"), repo.Name),
			map[string]any{"repo": repo.Name, "repoId": repo.ID, "commits": n})
	}
	return nil
}

// snapshot returns a repository's branch names and recent default-branch
// history, read again when older than snapshotTTL.
func (s *Service) snapshot(ctx context.Context, repo domain.Repository) (snapshot, error) {
	s.mu.Lock()
	snap, ok := s.snaps[repo.ID]
	s.mu.Unlock()
	if ok && time.Since(snap.at) < snapshotTTL {
		return snap, nil
	}
	branches, err := s.host.BranchNames(ctx, repo, maxBranches)
	if err != nil {
		return snapshot{}, err
	}
	snap = snapshot{at: time.Now(), branches: branches}
	since := time.Now().Add(-historyAge)
read:
	for page := 1; len(snap.history) < historyDepth; page++ {
		list, err := s.host.History(ctx, repo, repo.DefaultBranch, page, 100)
		if err != nil {
			return snapshot{}, err
		}
		for _, c := range list {
			if !c.Date.IsZero() && c.Date.Before(since) {
				break read
			}
			snap.history = append(snap.history, c)
		}
		if len(list) < 100 {
			break
		}
	}
	s.mu.Lock()
	for id, old := range s.snaps {
		if time.Since(old.at) >= snapshotTTL {
			delete(s.snaps, id) // a server keeps many workspaces' repositories
		}
	}
	s.snaps[repo.ID] = snap
	s.mu.Unlock()
	return snap, nil
}

// match links commits pushed to branch to the tickets their branch (when
// not the default) and messages name. keep, when not nil, limits it to
// the tokens it accepts.
func (s *Service) match(ctx context.Context, repo domain.Repository, branch string, commits []domain.PushedCommit, keep func(string) bool) ([]domain.CommitLink, error) {
	filter := func(toks []string) []string {
		if keep == nil {
			return toks
		}
		return slices.DeleteFunc(toks, func(t string) bool { return !keep(t) })
	}
	var branchToks []string
	if branch != repo.DefaultBranch {
		branchToks = filter(domain.TicketTokens(branch))
	}
	msgToks := make([][]string, len(commits))
	all := slices.Clone(branchToks)
	for i, c := range commits {
		msgToks[i] = filter(domain.TicketTokens(c.Message))
		for _, t := range msgToks[i] {
			if !slices.Contains(all, t) {
				all = append(all, t)
			}
		}
	}
	if len(all) == 0 || len(commits) == 0 {
		return nil, nil
	}
	found, err := s.store.TicketsByTokens(ctx, all)
	if err != nil {
		return nil, err
	}
	tickets := map[string]domain.Ticket{}
	for _, tok := range all {
		if t, ok := domain.PickTicket(tok, found); ok {
			tickets[tok] = t
		}
	}
	var out []domain.CommitLink
	for i, c := range commits {
		if c.SHA == "" {
			continue
		}
		byTicket := map[int64]int{} // index in out
		add := func(tok, on string) {
			t, ok := tickets[tok]
			if !ok {
				return
			}
			if j, ok := byTicket[t.ID]; ok {
				if !slices.Contains(out[j].MatchedOn, on) {
					out[j].MatchedOn = append(out[j].MatchedOn, on)
				}
				return
			}
			at := c.Date
			if at.IsZero() {
				at = time.Now()
			}
			byTicket[t.ID] = len(out)
			out = append(out, domain.CommitLink{TicketID: t.ID, TicketKey: t.Key, RepoID: repo.ID, SHA: strings.ToLower(c.SHA), Branch: branch,
				Subject: domain.Subject(c.Message), Author: c.Author, AuthorLogin: c.AuthorLogin, URL: c.URL, CommittedAt: at,
				MatchedOn: []string{on}, Token: tok})
		}
		for _, tok := range branchToks {
			add(tok, domain.MatchBranch)
		}
		for _, tok := range msgToks[i] {
			add(tok, domain.MatchMessage)
		}
	}
	for i := range out {
		slices.Sort(out[i].MatchedOn)
	}
	return out, nil
}

// repoNamed finds the workspace's repository a webhook names.
func (s *Service) repoNamed(ctx context.Context, provider, name string) (domain.Repository, bool, error) {
	repos, err := s.store.ListRepositories(ctx)
	if err != nil {
		return domain.Repository{}, false, err
	}
	for _, r := range repos {
		if r.Provider == provider && r.ArchivedAt == nil && domain.SameRepo(r.CloneURL, name) {
			return r, true, nil
		}
	}
	return domain.Repository{}, false, nil
}

type ticketRef struct {
	id  int64
	key string
}

// touched lists the tickets that gained links, in the order links name
// them.
func touched(links []domain.CommitLink, added map[int64]int) []ticketRef {
	var out []ticketRef
	for _, l := range links {
		if added[l.TicketID] > 0 && !slices.ContainsFunc(out, func(r ticketRef) bool { return r.id == l.TicketID }) {
			out = append(out, ticketRef{l.TicketID, l.TicketKey})
		}
	}
	return out
}

func (s *Service) event(ctx context.Context, key string, origin domain.Origin, msg string, data map[string]any) {
	if err := s.store.AppendEvent(ctx, domain.Event{TicketKey: key, Type: domain.EventCommitsLinked, Origin: origin,
		Level: domain.LevelInfo, Message: msg, Data: data}); err != nil {
		s.log.Warn("commit links: event", "ticket", key, "err", err)
	}
}

func plural(n int, what string) string {
	if n == 1 {
		return "1 " + what
	}
	return fmt.Sprintf("%d %ss", n, what)
}
