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

// MergeStore keeps what the git host said about default-branch commits'
// pull requests, so each is asked once. A Store may implement it; without
// it, pull requests are not looked up.
type MergeStore interface {
	// CommitPulls returns the stored lookups of shas (lower case) in a
	// repository; a sha missing from the map was not looked up yet.
	CommitPulls(ctx context.Context, repoID int64, shas []string) (map[string]domain.CommitPull, error)
	SaveCommitPull(ctx context.Context, repoID int64, sha string, cp domain.CommitPull) error
	SavePullCommits(ctx context.Context, repoID int64, number int, commits []domain.PushedCommit) error
	// MarkOnDefault records facts of commits seen on the default branch
	// on every link they have, whichever ticket and however linked.
	MarkOnDefault(ctx context.Context, repoID int64, facts []domain.DefaultCommit) error
}

// MergeHost reads how commits reached a default branch (vcs.MergeReader).
type MergeHost interface {
	CommitMerges(ctx context.Context, repo domain.Repository, sha string) ([]domain.MergedPull, error)
	PullCommits(ctx context.Context, repo domain.Repository, number int) ([]domain.PushedCommit, error)
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
	// maxPullLookups is how many default-branch commits one push or scan
	// asks the host about; the rest are asked by the next one.
	maxPullLookups = 100
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
	// reverted hears of commits pushed to a default branch that revert a
	// ticket's work (nil: nobody listens).
	reverted func(ctx context.Context, l domain.CommitLink)
}

// OnRevert sets what hears of a revert of a ticket's work pushed to a
// repository's default branch.
func (s *Service) OnRevert(f func(ctx context.Context, l domain.CommitLink)) { s.reverted = f }

// IsRevert reports whether a commit subject reverts another commit, as git
// and the git hosts write it.
func IsRevert(subject string) bool {
	return strings.HasPrefix(subject, `Revert "`) || strings.HasPrefix(subject, "Revert '") || strings.HasPrefix(subject, "revert: ")
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
	onDefault := p.Branch == repo.DefaultBranch
	if onDefault && !p.NewBranch() {
		// GitHub leaves out commits already on the host (a merged pull
		// request's branch commits) and neither host gives parents: read
		// what the push brought.
		if all, err := s.host.Ahead(ctx, repo, p.Before, p.After); err != nil {
			s.log.Warn("commit links: read a push to the default branch", "repo", repo.Name, "err", err)
		} else if len(all) > 0 {
			commits = all
		}
	} else if p.Total > len(commits) {
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
	if onDefault {
		now := time.Now()
		if links, err = s.onDefault(ctx, repo, commits, links, func(domain.PushedCommit) time.Time { return now }, nil); err != nil {
			return err
		}
	}
	added, err := s.store.UpsertCommitLinks(ctx, links)
	if err != nil {
		return err
	}
	if s.reverted != nil && onDefault {
		for _, l := range links {
			if added[l.TicketID] > 0 && IsRevert(l.Subject) {
				l.RepoName = repo.Name
				s.reverted(ctx, l)
			}
		}
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
	// A scan cannot tell when a commit reached the default branch; its
	// date is the best guess, and never later than a push saw it.
	if links, err = s.onDefault(ctx, repo, snap.history, links, func(c domain.PushedCommit) time.Time {
		if c.Date.IsZero() {
			return time.Now()
		}
		return c.Date
	}, keep); err != nil {
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

// onDefault fills in what links of commits on the default branch need
// for performance reviews: when each was seen there, merge or squash,
// the pull request it came through and what it reverts. A commit whose
// pull request names a ticket in its branch or title is linked to that
// ticket too (a squash that does not carry the number). keep, when not
// nil, limits the new links to the tokens it accepts.
func (s *Service) onDefault(ctx context.Context, repo domain.Repository, commits []domain.PushedCommit, links []domain.CommitLink,
	seen func(domain.PushedCommit) time.Time, keep func(string) bool) ([]domain.CommitLink, error) {
	pulls := s.pullsOf(ctx, repo, commits)
	var prToks []string
	for _, cp := range pulls {
		if cp.Number > 0 {
			prToks = append(prToks, domain.TicketTokens(cp.HeadBranch+" "+cp.Title)...)
		}
	}
	if keep != nil {
		prToks = slices.DeleteFunc(prToks, func(t string) bool { return !keep(t) })
	}
	var found []domain.Ticket
	if len(prToks) > 0 {
		var err error
		if found, err = s.store.TicketsByTokens(ctx, prToks); err != nil {
			return nil, err
		}
	}
	var facts []domain.DefaultCommit
	defer func() {
		if ms, ok := s.store.(MergeStore); ok && len(facts) > 0 {
			if err := ms.MarkOnDefault(ctx, repo.ID, facts); err != nil {
				s.log.Warn("commit links: mark commits on the default branch", "repo", repo.Name, "err", err)
			}
		}
	}()
	for _, c := range commits {
		sha := strings.ToLower(c.SHA)
		if sha == "" {
			continue
		}
		at := seen(c)
		kind := ""
		if len(c.Parents) > 1 {
			kind = domain.MergeKindMerge
		}
		cp, hasPull := pulls[sha]
		var pr *int
		if hasPull && cp.Number > 0 {
			n := cp.Number
			pr = &n
			if cp.Squash {
				kind = domain.MergeKindSquash
			}
		}
		facts = append(facts, domain.DefaultCommit{SHA: sha, At: at, MergeKind: kind, PRNumber: pr, Reverts: domain.RevertedSHA(c.Message),
			AuthorEmail: c.AuthorEmail, Parents: c.Parents})
		fill := func(l *domain.CommitLink) {
			l.OnDefaultAt = &at
			l.MergeKind, l.PRNumber, l.Reverts = kind, pr, domain.RevertedSHA(c.Message)
			l.AuthorEmail, l.Parents = c.AuthorEmail, c.Parents
		}
		linked := map[int64]bool{}
		for i := range links {
			if links[i].SHA == sha {
				fill(&links[i])
				linked[links[i].TicketID] = true
			}
		}
		if pr == nil {
			continue
		}
		for _, tok := range domain.TicketTokens(cp.HeadBranch + " " + cp.Title) {
			if keep != nil && !keep(tok) {
				continue
			}
			t, ok := domain.PickTicket(tok, found)
			if !ok || linked[t.ID] {
				continue
			}
			linked[t.ID] = true
			l := domain.CommitLink{TicketID: t.ID, TicketKey: t.Key, RepoID: repo.ID, SHA: sha, Branch: repo.DefaultBranch,
				Subject: domain.Subject(c.Message), Author: c.Author, AuthorLogin: c.AuthorLogin, URL: c.URL, CommittedAt: c.Date,
				MatchedOn: []string{domain.MatchPullRequest}, Token: tok}
			if l.CommittedAt.IsZero() {
				l.CommittedAt = at
			}
			fill(&l)
			links = append(links, l)
		}
	}
	return links, nil
}

// pullsOf returns the pull requests the default-branch commits came
// through, by sha: stored lookups, and up to maxPullLookups new ones.
// Merge commits are not looked up: they link through their message.
func (s *Service) pullsOf(ctx context.Context, repo domain.Repository, commits []domain.PushedCommit) map[string]domain.CommitPull {
	ms, okStore := s.store.(MergeStore)
	mh, okHost := s.host.(MergeHost)
	if !okStore || !okHost {
		return nil
	}
	var shas []string
	for _, c := range commits {
		if c.SHA != "" && len(c.Parents) <= 1 {
			shas = append(shas, strings.ToLower(c.SHA))
		}
	}
	if len(shas) == 0 {
		return nil
	}
	out, err := ms.CommitPulls(ctx, repo.ID, shas)
	if err != nil {
		s.log.Warn("commit links: read pull request lookups", "repo", repo.Name, "err", err)
		return nil
	}
	asked := 0
	for _, c := range commits {
		sha := strings.ToLower(c.SHA)
		if _, known := out[sha]; known || sha == "" || len(c.Parents) > 1 {
			continue
		}
		if asked++; asked > maxPullLookups {
			break
		}
		cp, err := s.lookupPull(ctx, mh, ms, repo, c)
		if err != nil {
			s.log.Warn("commit links: look up a commit's pull request", "repo", repo.Name, "sha", sha, "err", err)
			continue
		}
		if err := ms.SaveCommitPull(ctx, repo.ID, sha, cp); err != nil {
			s.log.Warn("commit links: save a pull request lookup", "repo", repo.Name, "sha", sha, "err", err)
		}
		out[sha] = cp
	}
	return out
}

// lookupPull asks the host which merged pull request into the default
// branch commit c came through, and whether c is its squash. The squashed
// pull request's commits are stored: they earn the shares.
func (s *Service) lookupPull(ctx context.Context, mh MergeHost, ms MergeStore, repo domain.Repository, c domain.PushedCommit) (domain.CommitPull, error) {
	prs, err := mh.CommitMerges(ctx, repo, strings.ToLower(c.SHA))
	if err != nil {
		return domain.CommitPull{}, err
	}
	for _, pr := range prs {
		if pr.BaseBranch != "" && pr.BaseBranch != repo.DefaultBranch {
			continue
		}
		cp := domain.CommitPull{Number: pr.Number, Title: pr.Title, HeadBranch: pr.HeadBranch}
		var own []domain.PushedCommit
		if !pr.SquashKnown || pr.Squash {
			if own, err = mh.PullCommits(ctx, repo, pr.Number); err != nil {
				return domain.CommitPull{}, err
			}
		}
		cp.Squash = domain.IsSquashOf(c, pr, own)
		if cp.Squash {
			if err := ms.SavePullCommits(ctx, repo.ID, pr.Number, own); err != nil {
				return domain.CommitPull{}, err
			}
		}
		return cp, nil
	}
	return domain.CommitPull{}, nil
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
