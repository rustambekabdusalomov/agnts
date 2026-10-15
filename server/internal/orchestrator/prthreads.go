package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// Pull request conversations: agnts reads a pull request's comments from
// the git host, and people comment, reply, edit, delete and resolve
// through agnts. Everything goes out as the token's user; with
// Settings.PRComments.Attribution a line says who wrote it in agnts.

// agntsMark is in every comment agnts writes itself (reviews, answers), so
// the webhooks can tell them from what people write.
const agntsMark = "<!-- agnts -->"

// attributionRe matches the attribution line agnts adds, to replace it on
// an edit instead of adding a second one.
var attributionRe = regexp.MustCompile(`\n*<sub>via agnts[^<]*</sub>\s*$`)

// pullStates are the states a pull request list can show.
var pullStates = []string{domain.PullOpen, domain.PullClosed, domain.PullMerged, "all"}

// pullsPerPage is the size of a pull request list page.
const pullsPerPage = 30

// threadsForgetter drops a cached conversation (vcs.Multi).
type threadsForgetter interface {
	ForgetThreads(repoID int64, number int)
}

// repoLister lists every repository of the workspace (the store).
type repoLister interface {
	ListRepositories(ctx context.Context) ([]domain.Repository, error)
}

func (o *Orchestrator) conversation() (Conversation, error) {
	c, ok := o.host.(Conversation)
	if !ok {
		return nil, invalid("pull request comments are not available on this server")
	}
	return c, nil
}

// pullRepo loads a repository whose pull requests can be read.
func (o *Orchestrator) pullRepo(ctx context.Context, repoID int64) (domain.Repository, Conversation, error) {
	c, err := o.conversation()
	if err != nil {
		return domain.Repository{}, nil, err
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return repo, nil, err
	}
	if repo.Provider != "github" && repo.Provider != "gitlab" {
		return repo, nil, invalid("%s is not on GitHub or GitLab", repo.Name)
	}
	return repo, c, nil
}

func checkNumber(number int) error {
	if number <= 0 {
		return invalid("%d is not a pull request number", number)
	}
	return nil
}

// PullItem is a pull request in a repository's list, with the agnts
// ticket that goes with it: agnts's own change (Own), or its review.
type PullItem struct {
	domain.PullRequest
	TicketKey string
	Own       bool
}

// Pulls returns one page (from 1) of a repository's pull requests in state
// (open, closed, merged or all).
func (o *Orchestrator) Pulls(ctx context.Context, repoID int64, state string, page int) ([]PullItem, error) {
	if state == "" {
		state = domain.PullOpen
	}
	if !slices.Contains(pullStates, state) {
		return nil, invalid("unknown pull request state %q", state)
	}
	repo, c, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return nil, err
	}
	prs, err := c.PullRequests(ctx, repo, state, max(page, 1), pullsPerPage)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrHost, err)
	}
	out := make([]PullItem, len(prs))
	for i, pr := range prs {
		out[i].PullRequest = pr
		if t, own, ok := o.ticketOfPull(ctx, repo, pr.Number, pr.URL); ok {
			out[i].TicketKey, out[i].Own = t.Key, own
		}
	}
	return out, nil
}

// ticketOfPull finds the agnts ticket of a pull request: the ticket whose
// change it is (own), else the review of it.
func (o *Orchestrator) ticketOfPull(ctx context.Context, repo domain.Repository, number int, url string) (domain.Ticket, bool, bool) {
	if url != "" {
		t, rid, err := o.store.TicketByPR(ctx, domain.PRRef{URL: url, RepoID: repo.ID})
		if err == nil && rid == repo.ID && t.Kind != domain.KindReview && t.Source != domain.SourceGit {
			return t, true, true
		}
	}
	if o.pulls != nil {
		if t, err := o.pulls.TicketByPull(ctx, repo.ID, number); err == nil {
			return t, false, true
		}
	}
	return domain.Ticket{}, false, false
}

// PullView is one pull request with what it changes.
type PullView struct {
	Repo      domain.Repository
	Pull      domain.PullRequest
	Files     []domain.FileChange
	FilesErr  string // why the files could not be read; the page still shows
	TicketKey string
	Own       bool
}

// Pull returns a pull request as it stands on the git host, with its files.
func (o *Orchestrator) Pull(ctx context.Context, repoID int64, number int) (PullView, error) {
	if err := checkNumber(number); err != nil {
		return PullView{}, err
	}
	repo, c, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return PullView{}, err
	}
	rh, ok := o.host.(ReviewHost)
	if !ok {
		return PullView{}, invalid("pull requests are not available on this server")
	}
	pr, err := rh.PullRequest(ctx, repo, number)
	if err != nil {
		return PullView{}, fmt.Errorf("%w: %w", ErrHost, err)
	}
	v := PullView{Repo: repo, Pull: pr}
	if files, err := c.PullFiles(ctx, repo, number); err != nil {
		v.FilesErr = err.Error()
	} else {
		v.Files = files
	}
	if t, own, ok := o.ticketOfPull(ctx, repo, number, pr.URL); ok {
		v.TicketKey, v.Own = t.Key, own
	}
	return v, nil
}

// ThreadView is a thread with what agnts did about it on its own pull
// request: sent back to the ticket as feedback, and answered.
type ThreadView struct {
	domain.PRThread
	Sent    bool // sent as feedback, with no newer comment since
	Replied bool
}

// PullThreads returns a pull request's conversation, marking agnts's own
// comments.
func (o *Orchestrator) PullThreads(ctx context.Context, repoID int64, number int) ([]ThreadView, error) {
	if err := checkNumber(number); err != nil {
		return nil, err
	}
	repo, c, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return nil, err
	}
	ts, err := c.Threads(ctx, repo, number)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrHost, err)
	}
	mine := map[string]bool{}
	if o.prposts != nil {
		posts, err := o.prposts.PRPosts(ctx, repoID, number)
		if err != nil {
			return nil, err
		}
		for _, p := range posts {
			mine[p.CommentID] = true
		}
	}
	sent := map[string]domain.PRThreadFeedback{}
	if o.prposts != nil {
		if t, ok := o.ownTicketByNumber(ctx, repo, number); ok {
			fs, err := o.prposts.ThreadFeedback(ctx, t.ID)
			if err != nil {
				return nil, err
			}
			for _, f := range fs {
				sent[f.ThreadID] = f
			}
		}
	}
	out := make([]ThreadView, len(ts))
	for i, t := range ts {
		t.Comments = slices.Clone(t.Comments) // the host's copy is cached and shared
		for j := range t.Comments {
			t.Comments[j].Agnts = mine[t.Comments[j].ID] || strings.Contains(t.Comments[j].Body, agntsMark)
		}
		out[i].PRThread = t
		if f, ok := sent[t.ID]; ok {
			last, _ := t.Last()
			out[i].Sent = last.ID == f.LastCommentID || f.Replied
			out[i].Replied = f.Replied
		}
	}
	return out, nil
}

// ownTicketByNumber finds agnts's ticket whose pull request in repo is
// number, without the pull request's address.
func (o *Orchestrator) ownTicketByNumber(ctx context.Context, repo domain.Repository, number int) (domain.Ticket, bool) {
	rh, ok := o.host.(ReviewHost)
	if !ok {
		return domain.Ticket{}, false
	}
	pr, err := rh.PullRequest(ctx, repo, number)
	if err != nil {
		return domain.Ticket{}, false
	}
	t, own, ok := o.ticketOfPull(ctx, repo, number, pr.URL)
	return t, ok && own
}

// attribute adds who wrote a comment in agnts, when the settings ask for
// it; an attribution already there (an edit) is replaced.
func (o *Orchestrator) attribute(ctx context.Context, body string) string {
	body = strings.TrimRight(attributionRe.ReplaceAllString(body, ""), " \n")
	s, err := o.settings.Get(ctx)
	if err != nil || !s.PRComments.Attribution {
		return body
	}
	a, ok := domain.ActorOf(ctx)
	if !ok || a.Username == "" {
		return body
	}
	return body + "\n\n<sub>via agnts · " + a.Username + "</sub>"
}

// hostErr turns a git host failure into an error for people.
func hostErr(what string, err error) error {
	switch {
	case errors.Is(err, domain.ErrNotInDiff):
		return invalid("%s: %v", what, err)
	case errors.Is(err, domain.ErrNotFound):
		return err
	}
	return fmt.Errorf("%w: %s: %w", ErrHost, what, err)
}

// pullEvent records a change to a pull request's conversation, on its
// ticket when it has one; clients showing the conversation read it again.
func (o *Orchestrator) pullEvent(ctx context.Context, repo domain.Repository, number int, msg string, level domain.Level, origin domain.Origin, data map[string]any) {
	ev := domain.Event{Type: domain.EventPRComment, Origin: origin, Level: level, Message: msg,
		Data: map[string]any{"repo": repo.Name, "repoId": repo.ID, "number": number}}
	for k, v := range data {
		ev.Data[k] = v
	}
	if t, ok := o.pullTicket(ctx, repo, number); ok {
		ev.TicketKey = t.Key
	}
	o.event(ctx, ev)
}

// recordPost keeps a comment agnts posted. Failures only log: the comment
// is on the git host already.
func (o *Orchestrator) recordPost(ctx context.Context, p domain.PRPost) {
	if o.prposts == nil || p.CommentID == "" {
		return
	}
	if _, err := o.prposts.AddPRPost(context.WithoutCancel(ctx), p); err != nil {
		o.log.Warn("record pull request comment", "repo", p.RepoID, "number", p.Number, "err", err)
	}
}

// pullTicket finds the review ticket of a pull request, else agnts's own
// ticket whose pull request it is.
func (o *Orchestrator) pullTicket(ctx context.Context, repo domain.Repository, number int) (domain.Ticket, bool) {
	if t, _, ok := o.ticketOfPull(ctx, repo, number, ""); ok {
		return t, true
	}
	return o.ownTicketByNumber(ctx, repo, number)
}

func pullTicketID(ctx context.Context, o *Orchestrator, repo domain.Repository, number int) *int64 {
	if t, ok := o.pullTicket(ctx, repo, number); ok {
		id := t.ID
		return &id
	}
	return nil
}

// AddPullComment comments on a pull request: on the pull request itself,
// or on a line of its diff.
func (o *Orchestrator) AddPullComment(ctx context.Context, repoID int64, number int, c domain.NewPRComment, origin domain.Origin) (domain.PRThread, error) {
	if err := checkNumber(number); err != nil {
		return domain.PRThread{}, err
	}
	if err := c.Check(); err != nil {
		return domain.PRThread{}, invalid("%v", err)
	}
	repo, conv, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return domain.PRThread{}, err
	}
	if c.Path != "" && c.HeadSHA == "" {
		if rh, ok := o.host.(ReviewHost); ok {
			if pr, err := rh.PullRequest(ctx, repo, number); err == nil {
				c.HeadSHA = pr.HeadSHA
			}
		}
	}
	c.Body = o.attribute(ctx, c.Body)
	th, err := conv.AddComment(ctx, repo, number, c)
	if err != nil {
		return th, hostErr(fmt.Sprintf("comment on #%d", number), err)
	}
	if len(th.Comments) > 0 {
		o.recordPost(ctx, domain.PRPost{RepoID: repo.ID, Number: number, TicketID: pullTicketID(ctx, o, repo, number),
			CommentID: th.Comments[0].ID, ThreadID: th.ID, Kind: domain.PostComment, HeadSHA: c.HeadSHA})
	}
	where := ""
	if c.Path != "" {
		where = fmt.Sprintf(" on %s:%d", c.Path, max(c.Line, c.OldLine))
	}
	o.pullEvent(ctx, repo, number, fmt.Sprintf("commented on #%d%s", number, where), domain.LevelInfo, origin, nil)
	return th, nil
}

// ReplyPullThread answers in a thread of a pull request.
func (o *Orchestrator) ReplyPullThread(ctx context.Context, repoID int64, number int, threadID, body string, origin domain.Origin) (domain.PRComment, error) {
	if err := checkNumber(number); err != nil {
		return domain.PRComment{}, err
	}
	c := domain.NewPRComment{Body: body}
	if err := c.Check(); err != nil {
		return domain.PRComment{}, invalid("%v", err)
	}
	if strings.TrimSpace(threadID) == "" {
		return domain.PRComment{}, invalid("which thread?")
	}
	repo, conv, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return domain.PRComment{}, err
	}
	out, err := conv.Reply(ctx, repo, number, threadID, o.attribute(ctx, c.Body))
	if err != nil {
		return out, hostErr(fmt.Sprintf("reply on #%d", number), err)
	}
	o.recordPost(ctx, domain.PRPost{RepoID: repo.ID, Number: number, TicketID: pullTicketID(ctx, o, repo, number),
		CommentID: out.ID, ThreadID: threadID, Kind: domain.PostComment})
	o.pullEvent(ctx, repo, number, fmt.Sprintf("replied on #%d", number), domain.LevelInfo, origin, nil)
	return out, nil
}

// EditPullComment replaces the text of a comment.
func (o *Orchestrator) EditPullComment(ctx context.Context, repoID int64, number int, commentID, body string, origin domain.Origin) (domain.PRComment, error) {
	if err := checkNumber(number); err != nil {
		return domain.PRComment{}, err
	}
	c := domain.NewPRComment{Body: body}
	if err := c.Check(); err != nil {
		return domain.PRComment{}, invalid("%v", err)
	}
	repo, conv, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return domain.PRComment{}, err
	}
	out, err := conv.EditComment(ctx, repo, number, commentID, o.attribute(ctx, c.Body))
	if err != nil {
		return out, hostErr(fmt.Sprintf("edit the comment on #%d", number), err)
	}
	o.pullEvent(ctx, repo, number, fmt.Sprintf("edited a comment on #%d", number), domain.LevelInfo, origin, nil)
	return out, nil
}

// DeletePullComment deletes a comment.
func (o *Orchestrator) DeletePullComment(ctx context.Context, repoID int64, number int, commentID string, origin domain.Origin) error {
	if err := checkNumber(number); err != nil {
		return err
	}
	repo, conv, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return err
	}
	if err := conv.DeleteComment(ctx, repo, number, commentID); err != nil {
		return hostErr(fmt.Sprintf("delete the comment on #%d", number), err)
	}
	if o.prposts != nil {
		if err := o.prposts.DeletePRPost(ctx, repo.ID, number, commentID); err != nil {
			o.log.Warn("forget deleted comment", "repo", repo.ID, "number", number, "err", err)
		}
	}
	o.pullEvent(ctx, repo, number, fmt.Sprintf("deleted a comment on #%d", number), domain.LevelInfo, origin, nil)
	return nil
}

// ResolvePullThread resolves or reopens a thread.
func (o *Orchestrator) ResolvePullThread(ctx context.Context, repoID int64, number int, threadID string, resolved bool, origin domain.Origin) error {
	if err := checkNumber(number); err != nil {
		return err
	}
	repo, conv, err := o.pullRepo(ctx, repoID)
	if err != nil {
		return err
	}
	if err := conv.ResolveThread(ctx, repo, number, threadID, resolved); err != nil {
		return hostErr(fmt.Sprintf("resolve the thread on #%d", number), err)
	}
	msg := "resolved a thread on #%d"
	if !resolved {
		msg = "reopened a thread on #%d"
	}
	o.pullEvent(ctx, repo, number, fmt.Sprintf(msg, number), domain.LevelInfo, origin, nil)
	return nil
}

// findRepoNamed finds the repository a webhook names.
func (o *Orchestrator) findRepoNamed(ctx context.Context, provider, name string) (domain.Repository, bool, error) {
	rl, ok := o.store.(repoLister)
	if !ok {
		return domain.Repository{}, false, nil
	}
	repos, err := rl.ListRepositories(ctx)
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

// PRCommentChanged hears from a webhook that a pull request's conversation
// changed: the cached copy is dropped and the clients told; a comment you
// wrote on someone's pull request becomes a reviewer note; and a request
// for changes on agnts's pull request may send its threads back to the
// ticket.
func (o *Orchestrator) PRCommentChanged(ctx context.Context, ev domain.PRCommentEvent) error {
	repo, ok, err := o.findRepoNamed(ctx, ev.Provider, ev.Repo)
	if err != nil || !ok {
		return err
	}
	if f, ok := o.host.(threadsForgetter); ok {
		f.ForgetThreads(repo.ID, ev.Number)
	}
	who := ev.Author
	if who == "" {
		who = "someone"
	}
	o.pullEvent(ctx, repo, ev.Number, fmt.Sprintf("%s %s on #%d", who, commentVerb(ev), ev.Number), domain.LevelDebug, domain.OriginWebhook,
		map[string]any{"author": ev.Author, "action": ev.Action})
	s, err := o.settings.Get(ctx)
	if err != nil {
		return err
	}
	if s.PRComments.LearnFromComments && (ev.Action == "created" || ev.Action == "submitted") {
		o.learnFromComment(ctx, repo, ev)
	}
	if s.PRComments.AutoAddress && ev.ReviewState == "changes_requested" {
		if t, ok := o.ownTicketByNumber(ctx, repo, ev.Number); ok {
			if _, err := o.AddressThreads(ctx, t.Key, nil, domain.OriginWebhook); err != nil && !errors.Is(err, ErrInvalid) {
				return err
			}
		}
	}
	return nil
}

func commentVerb(ev domain.PRCommentEvent) string {
	switch {
	case ev.ReviewState == "changes_requested":
		return "requested changes"
	case ev.ReviewState == "approved":
		return "approved"
	case ev.Action == "edited":
		return "edited a comment"
	case ev.Action == "deleted":
		return "deleted a comment"
	case ev.Action == "resolved":
		return "resolved a thread"
	case ev.Action == "unresolved":
		return "reopened a thread"
	case ev.ReviewState != "":
		return "reviewed"
	}
	return "commented"
}

// learnFromComment keeps a comment the token's user wrote on someone
// else's pull request as a note on how they review. agnts's own comments
// are not notes.
func (o *Orchestrator) learnFromComment(ctx context.Context, repo domain.Repository, ev domain.PRCommentEvent) {
	body := strings.TrimSpace(attributionRe.ReplaceAllString(ev.Body, ""))
	if o.pulls == nil || body == "" || strings.Contains(ev.Body, agntsMark) {
		return
	}
	rh, ok := o.host.(ReviewHost)
	if !ok {
		return
	}
	pr, err := rh.PullRequest(ctx, repo, ev.Number)
	if err != nil || pr.Login == "" || !strings.EqualFold(pr.Login, ev.Author) || strings.EqualFold(pr.Author, pr.Login) {
		return // not yours, or on your own pull request
	}
	n := domain.ReviewerNote{Login: pr.Login, RepoID: &repo.ID, PullTitle: pr.Title, Kind: domain.NoteHostComment,
		Note: clipRunes(body, domain.ReviewerNoteMax)}
	if t, err := o.pulls.TicketByPull(ctx, repo.ID, ev.Number); err == nil {
		n.TicketKey = t.Key
	}
	if n.Validate() != nil {
		return
	}
	if _, err := o.pulls.AddReviewerNote(context.WithoutCancel(ctx), n); err != nil {
		o.log.Warn("keep reviewer note from a comment", "repo", repo.Name, "number", ev.Number, "err", err)
	}
}

func clipRunes(s string, n int) string {
	if r := []rune(s); len(r) > n {
		return string(r[:n-1]) + "…"
	}
	return s
}
