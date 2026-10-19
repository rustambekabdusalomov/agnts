package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Reviews asked for from a pull request page, and the draft comments of
// pull request reviews. agnts's review writes every comment (the summary
// and each finding) as a draft kept in agnts; a person accepts, edits or
// dismisses each one, and publishing sends only the accepted ones to the
// git host, together as one review. Drafts not accepted stay in agnts.

// ReviewDrafts keeps the draft comments of pull request reviews.
type ReviewDrafts interface {
	// ReviewDrafts returns a ticket's drafts, the summary first.
	ReviewDrafts(ctx context.Context, ticketID int64) ([]domain.ReviewDraft, error)
	// ReviewDraft returns one, or domain.ErrNotFound.
	ReviewDraft(ctx context.Context, ticketID, id int64) (domain.ReviewDraft, error)
	// SyncReviewDrafts locks the ticket's drafts, passes them to merge and
	// saves the drafts it returns (ID 0: new), in one transaction.
	SyncReviewDrafts(ctx context.Context, ticketID int64, merge func([]domain.ReviewDraft) []domain.ReviewDraft) error
	AddReviewDraft(ctx context.Context, d domain.ReviewDraft) (domain.ReviewDraft, error)
	// UpdateReviewDraft changes one draft under a row lock.
	UpdateReviewDraft(ctx context.Context, ticketID, id int64, change func(*domain.ReviewDraft) error) (domain.ReviewDraft, error)
	// UpdateReviewDrafts changes several in one transaction (change
	// reports whether it changed one) and returns them all.
	UpdateReviewDrafts(ctx context.Context, ticketID int64, change func(*domain.ReviewDraft) bool) ([]domain.ReviewDraft, error)
	DeleteReviewDraft(ctx context.Context, ticketID, id int64) error
	// ClaimReviewDrafts moves the accepted drafts to publishing and
	// returns them; publishing ones older than stale are accepted again
	// first.
	ClaimReviewDrafts(ctx context.Context, ticketID int64, stale time.Time) ([]domain.ReviewDraft, error)
	// FinishReviewDraft ends a claim: published, or accepted again with
	// errMsg.
	FinishReviewDraft(ctx context.Context, id int64, published bool, postID *int64, errMsg string) error
}

// ReviewPullOptions is how a person asks for a review from the pull
// request page.
type ReviewPullOptions struct {
	Focus string // what to look at especially
	Deep  string // "", domain.DeepOff or domain.DeepAlways
}

// ReviewExistsError is returned when agnts is reviewing the pull request
// right now.
type ReviewExistsError struct{ Key string }

func (e *ReviewExistsError) Error() string {
	return fmt.Sprintf("agnts is already reviewing this pull request in %s", e.Key)
}

func (e *ReviewExistsError) Unwrap() error { return domain.ErrConflict }

// reviewRunning reports whether a review ticket is being worked on (or
// queued to be): a new review would race it.
func reviewRunning(t domain.Ticket) bool {
	switch t.State {
	case domain.StateNew, domain.StateAnalyzing, domain.StateCoding, domain.StateTesting, domain.StatePushing:
		return true
	}
	return false
}

// ReviewPull starts a new agnts review of an open pull request, the
// person's own included: a review ticket of the pull request as it stands
// now. It may be reviewed again whenever no review runs; the earlier
// review, if it still waits for you, is replaced. Approving merges only a
// pull request that waits for you (assigned, or asking for your review);
// otherwise it finishes the review.
func (o *Orchestrator) ReviewPull(ctx context.Context, repoID int64, number int, opt ReviewPullOptions, origin domain.Origin) (domain.Ticket, error) {
	if err := checkNumber(number); err != nil {
		return domain.Ticket{}, err
	}
	rh, err := o.pullReviewsReady()
	if err != nil {
		return domain.Ticket{}, err
	}
	opt.Focus = strings.TrimSpace(strings.ReplaceAll(opt.Focus, "\r\n", "\n"))
	if len([]rune(opt.Focus)) > domain.PullFocusMax {
		return domain.Ticket{}, invalid("the focus note is longer than %d characters", domain.PullFocusMax)
	}
	if !slices.Contains(domain.PullDeepChoices, opt.Deep) {
		return domain.Ticket{}, invalid("unknown deep review choice %q", opt.Deep)
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return domain.Ticket{}, err
	}
	if repo.ArchivedAt != nil {
		return domain.Ticket{}, invalid("%s is archived", repo.Name)
	}
	pr, err := rh.PullRequest(ctx, repo, number)
	if err != nil {
		return domain.Ticket{}, hostErr(fmt.Sprintf("read #%d", number), err)
	}
	pr.Clean()
	if pr.State != domain.PullOpen {
		return domain.Ticket{}, invalid("#%d is %s: only an open pull request can be reviewed", number, pr.State)
	}
	prev, err := o.pulls.TicketByPull(ctx, repo.ID, number)
	switch {
	case errors.Is(err, domain.ErrNotFound):
		prev = domain.Ticket{}
	case err != nil:
		return domain.Ticket{}, err
	case reviewRunning(prev):
		return prev, &ReviewExistsError{Key: prev.Key}
	}
	after := domain.AfterApproveNone
	if pr.Why == domain.PullAssigned || pr.Why == domain.PullReviewRequested {
		after = "pr"
	}
	pr.Focus, pr.Deep = opt.Focus, opt.Deep
	who := "someone"
	if a, ok := domain.ActorOf(ctx); ok && a.Username != "" {
		who = a.Username
	}
	t, err := o.createPullTicket(ctx, repo, pr, after,
		fmt.Sprintf("review of #%d at %s by @%s asked by %s", pr.Number, shortSHA(pr.HeadSHA), pr.Author, who), origin)
	if err != nil {
		return t, err
	}
	if prev.Key != "" && !prev.State.Terminal() {
		// Waiting for you, or stopped: the new review replaces it.
		if _, err := o.store.Transition(ctx, prev.Key, domain.StateRejected, domain.Event{
			TicketKey: prev.Key, Type: domain.EventStateChanged, Origin: origin,
			Message: fmt.Sprintf("replaced by a new review of #%d in %s", number, t.Key),
		}, nil); err != nil {
			o.log.Warn("replace earlier review", "ticket", prev.Key, "err", err)
		}
	}
	o.Wake()
	return t, nil
}

// latestPullReview returns the newest review of a review ticket.
func (o *Orchestrator) latestPullReview(ctx context.Context, t domain.Ticket) (domain.Review, []domain.FileChange, bool, error) {
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Review{}, nil, false, nil
	}
	if err != nil {
		return domain.Review{}, nil, false, err
	}
	var rv domain.Review
	if json.Unmarshal(res.Summary, &rv) != nil || rv.Summary == "" {
		return domain.Review{}, nil, false, nil
	}
	return rv, res.Files, true, nil
}

// draftsOf builds the drafts a review writes.
func draftsOf(t domain.Ticket, rv domain.Review, base, start string) []domain.ReviewDraft {
	mk := func(kind, key string) domain.ReviewDraft {
		return domain.ReviewDraft{TicketID: t.ID, RepoID: *t.RepoID, Number: *t.PRNumber, Kind: kind, Key: key,
			HeadSHA: rv.HeadSHA, BaseSHA: base, StartSHA: start, State: domain.DraftOpen}
	}
	sum := mk(domain.DraftSummary, domain.DraftSummary)
	sum.Body, sum.Title, sum.Severity = summaryComment(*t.Pull, rv), strings.ReplaceAll(rv.Verdict, "_", " "), rv.Verdict
	out := []domain.ReviewDraft{sum}
	for _, f := range rv.Findings {
		d := mk(domain.DraftFinding, domain.FindingKey(f))
		d.Severity, d.Category, d.Title, d.Confidence, d.Pass = f.Severity, f.Category, f.Title, f.Confidence, f.Pass
		d.Path, d.Line = f.File, f.Line
		d.Body = findingBody(f, rv.HeadSHA)
		out = append(out, d)
	}
	return out
}

// syncDrafts folds a review into the ticket's drafts. Findings agnts
// already posted on the pull request (by this ticket or an earlier
// review of it) start as published, so they are never posted twice.
func (o *Orchestrator) syncDrafts(ctx context.Context, t domain.Ticket, rv domain.Review) error {
	if o.drafts == nil || t.Pull == nil || t.PRNumber == nil || t.RepoID == nil {
		return nil
	}
	base, start := "", ""
	if rh, ok := o.host.(ReviewHost); ok {
		if repo, err := o.repoFor(ctx, t); err == nil {
			if pr, err := rh.PullRequest(ctx, repo, *t.PRNumber); err == nil && pr.HeadSHA == rv.HeadSHA {
				base, start = pr.BaseSHA, pr.StartSHA
			}
		}
	}
	posted := map[string]domain.PRPost{}
	var summary *domain.PRPost
	if o.prposts != nil {
		posts, err := o.prposts.PRPosts(ctx, *t.RepoID, *t.PRNumber)
		if err != nil {
			return err
		}
		for _, p := range posts {
			switch {
			case p.Kind == domain.PostFinding && !p.Resolved:
				posted[p.FindingKey] = p
			case p.Kind == domain.PostSummary && p.HeadSHA == rv.HeadSHA:
				summary = &p
			}
		}
	}
	incoming := draftsOf(t, rv, base, start)
	now := time.Now()
	return o.drafts.SyncReviewDrafts(ctx, t.ID, func(cur []domain.ReviewDraft) []domain.ReviewDraft {
		out := domain.MergeReviewDrafts(cur, incoming, now)
		for i, d := range out {
			if d.ID != 0 {
				continue
			}
			if p, ok := posted[d.Key]; ok && d.Kind == domain.DraftFinding {
				out[i].State, out[i].PostID = domain.DraftPublished, &p.ID
			}
			if summary != nil && d.Kind == domain.DraftSummary {
				out[i].State, out[i].PostID = domain.DraftPublished, &summary.ID
			}
		}
		return out
	})
}

// draftTicket loads a review ticket whose drafts a person works on.
func (o *Orchestrator) draftTicket(ctx context.Context, key string, changing bool) (domain.Ticket, error) {
	if o.drafts == nil {
		return domain.Ticket{}, invalid("review drafts are not available on this server")
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.Kind != domain.KindReview || t.Pull == nil || t.PRNumber == nil || t.RepoID == nil {
		return t, invalid("%s is not a pull request review", key)
	}
	if changing {
		switch {
		case t.State == domain.StateRejected:
			return t, invalid("the review %s was dismissed: its drafts can only be read", key)
		case t.Pull.State != "" && t.Pull.State != domain.PullOpen:
			return t, invalid("#%d is %s: its drafts can only be read", *t.PRNumber, t.Pull.State)
		}
	}
	return t, nil
}

// ensureDrafts makes the drafts of a review that has none yet (a review
// written before drafts existed).
func (o *Orchestrator) ensureDrafts(ctx context.Context, t domain.Ticket) ([]domain.ReviewDraft, error) {
	ds, err := o.drafts.ReviewDrafts(ctx, t.ID)
	if err != nil || slices.ContainsFunc(ds, func(d domain.ReviewDraft) bool { return d.Kind != domain.DraftComment }) {
		return ds, err
	}
	rv, _, ok, err := o.latestPullReview(ctx, t)
	if err != nil || !ok {
		return ds, err
	}
	if err := o.syncDrafts(ctx, t, rv); err != nil {
		return ds, err
	}
	return o.drafts.ReviewDrafts(ctx, t.ID)
}

// TicketDrafts returns a review ticket's drafts.
func (o *Orchestrator) TicketDrafts(ctx context.Context, key string) ([]domain.ReviewDraft, error) {
	t, err := o.draftTicket(ctx, key, false)
	if err != nil {
		return nil, err
	}
	return o.ensureDrafts(ctx, t)
}

// pullDrafts returns the drafts of a pull request's review ticket, for
// its page; nil when it has none or they cannot be read.
func (o *Orchestrator) pullDrafts(ctx context.Context, t domain.Ticket) []domain.ReviewDraft {
	if o.drafts == nil || t.Kind != domain.KindReview {
		return nil
	}
	ds, err := o.ensureDrafts(ctx, t)
	if err != nil {
		o.log.Warn("review drafts", "ticket", t.Key, "err", err)
		return nil
	}
	return ds
}

// DraftChange is what a person changes on a draft; nil fields stay.
type DraftChange struct {
	State  *string // draft, accepted or dismissed
	Body   *string
	Reason *string // why it was dismissed
}

// UpdateDraft accepts, dismisses, reopens or rewrites a draft.
func (o *Orchestrator) UpdateDraft(ctx context.Context, key string, id int64, ch DraftChange, origin domain.Origin) (domain.ReviewDraft, error) {
	t, err := o.draftTicket(ctx, key, true)
	if err != nil {
		return domain.ReviewDraft{}, err
	}
	var body, reason string
	if ch.Body != nil {
		if body, err = domain.CleanDraftBody(*ch.Body); err != nil {
			return domain.ReviewDraft{}, invalid("%v", err)
		}
	}
	if ch.Reason != nil {
		reason = clipRunes(strings.TrimSpace(*ch.Reason), domain.DraftDismissMax)
	}
	learn := false
	d, err := o.drafts.UpdateReviewDraft(ctx, t.ID, id, func(d *domain.ReviewDraft) error {
		switch d.State {
		case domain.DraftPublishing:
			return invalid("this comment is being published")
		case domain.DraftPublished:
			return invalid("this comment is on the pull request already: edit it there")
		}
		if ch.Body != nil && body != d.Body {
			d.Body, d.Edited = body, true
		}
		if ch.State != nil && *ch.State != d.State {
			switch *ch.State {
			case domain.DraftAccepted:
				if d.State == domain.DraftOutdated {
					return invalid("agnts's newest review no longer finds this: it cannot be published")
				}
			case domain.DraftOpen, domain.DraftDismissed:
			default:
				return invalid("a draft can be accepted, dismissed or reopened, not %q", *ch.State)
			}
			d.State = *ch.State
			now := time.Now()
			d.DecidedAt, d.DecidedBy = &now, nil
			if a, ok := domain.ActorOf(ctx); ok && a.UserID > 0 {
				d.DecidedBy = &a.UserID
			}
			d.DismissReason = ""
			if d.State == domain.DraftDismissed {
				d.DismissReason = reason
				learn = reason != "" && d.Kind == domain.DraftFinding && !d.Noted
				d.Noted = d.Noted || learn
			}
			d.Error = ""
		}
		return nil
	})
	if err != nil {
		return d, err
	}
	if learn {
		o.noteReviewer(ctx, t, domain.NoteDraft, fmt.Sprintf("Dismissed agnts's finding %q%s: %s", d.Title, draftWhere(d), d.DismissReason), origin)
	}
	return d, nil
}

// AddDraftComment adds a person's own comment to the review, to publish
// with agnts's accepted ones.
func (o *Orchestrator) AddDraftComment(ctx context.Context, key string, c domain.NewPRComment) (domain.ReviewDraft, error) {
	t, err := o.draftTicket(ctx, key, true)
	if err != nil {
		return domain.ReviewDraft{}, err
	}
	if err := c.Check(); err != nil {
		return domain.ReviewDraft{}, invalid("%v", err)
	}
	if c.OldLine > 0 || c.StartLine > 0 {
		return domain.ReviewDraft{}, invalid("a draft comment goes on a line of the new version")
	}
	if c.Path != "" && c.HeadSHA == "" {
		if rh, ok := o.host.(ReviewHost); ok {
			if repo, err := o.repoFor(ctx, t); err == nil {
				if pr, err := rh.PullRequest(ctx, repo, *t.PRNumber); err == nil {
					c.HeadSHA = pr.HeadSHA
				}
			}
		}
	}
	d := domain.ReviewDraft{TicketID: t.ID, RepoID: *t.RepoID, Number: *t.PRNumber, Kind: domain.DraftComment, Key: domain.NewDraftKey(),
		Path: c.Path, Line: c.Line, HeadSHA: c.HeadSHA, Body: c.Body, State: domain.DraftAccepted}
	if a, ok := domain.ActorOf(ctx); ok && a.UserID > 0 {
		d.AuthorID = &a.UserID
	}
	return o.drafts.AddReviewDraft(ctx, d)
}

// DeleteDraft removes a person's own draft comment; agnts's drafts are
// dismissed instead.
func (o *Orchestrator) DeleteDraft(ctx context.Context, key string, id int64) error {
	t, err := o.draftTicket(ctx, key, true)
	if err != nil {
		return err
	}
	d, err := o.drafts.ReviewDraft(ctx, t.ID, id)
	if err != nil {
		return err
	}
	switch {
	case d.Kind != domain.DraftComment:
		return invalid("agnts's drafts are dismissed, not deleted")
	case d.State == domain.DraftPublishing || d.State == domain.DraftPublished:
		return invalid("this comment is on the pull request: delete it there")
	}
	return o.drafts.DeleteReviewDraft(ctx, t.ID, id)
}

// AcceptAllDrafts accepts every open finding at least as severe as
// minSeverity ("" for all), and the summary.
func (o *Orchestrator) AcceptAllDrafts(ctx context.Context, key, minSeverity string) ([]domain.ReviewDraft, error) {
	if minSeverity != "" && !slices.Contains(domain.FindingSeverities, minSeverity) {
		return nil, invalid("unknown severity %q", minSeverity)
	}
	t, err := o.draftTicket(ctx, key, true)
	if err != nil {
		return nil, err
	}
	if _, err := o.ensureDrafts(ctx, t); err != nil {
		return nil, err
	}
	limit := len(domain.FindingSeverities)
	if minSeverity != "" {
		limit = domain.SeverityRank(minSeverity)
	}
	now := time.Now()
	var by *int64
	if a, ok := domain.ActorOf(ctx); ok && a.UserID > 0 {
		by = &a.UserID
	}
	return o.drafts.UpdateReviewDrafts(ctx, t.ID, func(d *domain.ReviewDraft) bool {
		if d.State != domain.DraftOpen || (d.Kind == domain.DraftFinding && domain.SeverityRank(d.Severity) > limit) {
			return false
		}
		d.State, d.DecidedAt, d.DecidedBy, d.Error = domain.DraftAccepted, &now, by, ""
		return true
	})
}

// PublishOptions says how accepted drafts go on the pull request.
type PublishOptions struct {
	RequestChanges bool // GitHub only
}

// PublishDrafts posts a review's accepted drafts on the pull request as
// one review, as the git host token's user: findings and people's
// comments on their lines, the summary (edited in place when agnts posted
// one before) with the accepted findings not on a changed line. It also
// answers in the threads of findings agnts posted earlier that are still
// there, and resolves the ones that are gone. It can be called again to
// publish drafts accepted later.
func (o *Orchestrator) PublishDrafts(ctx context.Context, key string, opt PublishOptions, origin domain.Origin) (domain.Ticket, PostedReview, error) {
	var did PostedReview
	rh, err := o.pullReviewsReady()
	if err != nil {
		return domain.Ticket{}, did, err
	}
	conv, ok := o.host.(Conversation)
	if !ok || o.prposts == nil {
		return domain.Ticket{}, did, invalid("this server cannot publish review comments")
	}
	t, err := o.draftTicket(ctx, key, true)
	if err != nil {
		return t, did, err
	}
	repo, err := o.repoFor(ctx, t)
	if err != nil {
		return t, did, err
	}
	n := *t.PRNumber
	pr, err := rh.PullRequest(ctx, repo, n)
	if err != nil {
		return t, did, hostErr(fmt.Sprintf("read #%d", n), err)
	}
	if pr.State != domain.PullOpen {
		return t, did, invalid("#%d is %s on the git host: nothing can be published on it", n, pr.State)
	}
	rv, files, reviewed, err := o.latestPullReview(ctx, t)
	if err != nil {
		return t, did, err
	}
	all, err := o.ensureDrafts(ctx, t)
	if err != nil {
		return t, did, err
	}
	claimed, err := o.drafts.ClaimReviewDrafts(ctx, t.ID, time.Now().Add(-domain.DraftPublishingStale))
	if err != nil {
		return t, did, err
	}
	if len(claimed) == 0 {
		return t, did, invalid("nothing to publish: accept a comment first")
	}
	var published []domain.ReviewDraft
	for _, d := range all {
		if d.State == domain.DraftPublished && d.Kind == domain.DraftFinding {
			published = append(published, d)
		}
	}
	if ownPull(pr) {
		opt.RequestChanges = false // GitHub refuses changes requested on your own pull request
	}
	posts, err := o.publishDrafts(ctx, conv, repo, t, pr, rv, reviewed, files, claimed, published, opt, &did)
	for _, d := range claimed {
		perr := ""
		if err != nil {
			perr = err.Error()
		}
		if ferr := o.drafts.FinishReviewDraft(context.WithoutCancel(ctx), d.ID, err == nil, posts[d.ID], perr); ferr != nil {
			o.log.Warn("finish a review draft", "ticket", t.Key, "draft", d.ID, "err", ferr)
		}
	}
	if err != nil {
		return t, did, err
	}
	o.learnFromDrafts(ctx, t, origin)
	now := time.Now()
	msg := fmt.Sprintf("published %d %s on #%d", len(claimed), plural(len(claimed), "comment", "comments"), n)
	if did.Inline > 0 {
		msg += fmt.Sprintf(", %d on the lines", did.Inline)
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventReviewPosted, Origin: origin, Message: msg,
		Data: map[string]any{"url": t.PRURL, "sha": rv.HeadSHA, "published": len(claimed), "inline": did.Inline,
			"still": did.Still, "resolved": did.Resolved, "summary": did.Summary, "repoId": repo.ID, "number": n},
	}, func(x *domain.Ticket) {
		if x.Pull != nil {
			p := *x.Pull
			p.PostedSHA, p.PostedAt = pr.HeadSHA, &now
			if reviewed {
				p.PostedSHA = rv.HeadSHA
			}
			x.Pull = &p
		}
	})
	return t, did, err
}

// publishDrafts posts claimed drafts and reconciles what agnts posted before. It
// returns each published draft's pr_posts row.
func (o *Orchestrator) publishDrafts(ctx context.Context, conv Conversation, repo domain.Repository, t domain.Ticket, pr domain.PullRequest,
	rv domain.Review, reviewed bool, reviewedFiles []domain.FileChange, claimed, published []domain.ReviewDraft, opt PublishOptions, did *PostedReview) (map[int64]*int64, error) {
	n := *t.PRNumber
	out := map[int64]*int64{}
	posts, err := o.prposts.PRPosts(ctx, repo.ID, n)
	if err != nil {
		return out, err
	}
	var summaryPost *domain.PRPost
	earlier := map[string]domain.PRPost{}
	for _, p := range posts {
		switch p.Kind {
		case domain.PostSummary:
			summaryPost = &p
		case domain.PostFinding:
			earlier[p.FindingKey] = p
		}
	}
	// The lines a comment can go on, per commit: the host's diff for the
	// current head, the reviewed diff for the commit agnts reviewed.
	lineSets := map[string]map[string]map[int]bool{}
	linesAt := func(sha string) map[string]map[int]bool {
		if ls, ok := lineSets[sha]; ok {
			return ls
		}
		var ls map[string]map[int]bool
		switch {
		case sha == pr.HeadSHA:
			if files, err := conv.PullFiles(ctx, repo, n); err == nil {
				ls = commentableLines(files)
			} else {
				o.log.Warn("pull request files for inline comments", "ticket", t.Key, "err", err)
			}
		case reviewed && sha == rv.HeadSHA:
			ls = commentableLines(reviewedFiles)
		}
		lineSets[sha] = ls
		return ls
	}

	var sum *domain.ReviewDraft
	var offLine []domain.ReviewDraft
	type inline struct {
		d domain.ReviewDraft
		c domain.NewPRComment
	}
	byHead := map[string][]inline{}
	var heads []string
	for _, d := range claimed {
		if d.Kind == domain.DraftSummary {
			sum = &d
			continue
		}
		head := d.HeadSHA
		if head == "" {
			head = pr.HeadSHA
		}
		ls := linesAt(head)
		if !d.OnLine() || (ls != nil && !ls[d.Path][d.Line]) {
			offLine = append(offLine, d)
			continue
		}
		body := d.Body + "\n" + agntsMark
		if d.Kind == domain.DraftComment {
			body = o.attributeTo(ctx, d.Body, d.Author)
		}
		c := domain.NewPRComment{Body: truncate(body, domain.PRCommentMax), Path: d.Path, Line: d.Line, HeadSHA: head}
		if head == d.HeadSHA && head != pr.HeadSHA {
			c.BaseSHA, c.StartSHA = d.BaseSHA, d.StartSHA
		}
		if _, ok := byHead[head]; !ok {
			heads = append(heads, head)
		}
		byHead[head] = append(byHead[head], inline{d, c})
	}

	// Findings agnts posted before: still there, or gone.
	if reviewed {
		sha := rv.HeadSHA
		current := map[string]bool{}
		for _, f := range rv.Findings {
			current[domain.FindingKey(f)] = true
		}
		for _, d := range published {
			p, ok := earlier[d.Key]
			if !ok || p.Resolved || !current[d.Key] || p.HeadSHA == sha || p.ThreadID == "" {
				continue
			}
			if _, err := conv.Reply(ctx, repo, n, p.ThreadID, fmt.Sprintf("Still present at %s.\n\n<sub>agnts review</sub>%s", shortSHA(sha), agntsMark)); err == nil {
				did.Still++
				_ = o.prposts.UpdatePRPost(ctx, p.ID, sha, false)
			}
		}
		for k, p := range earlier {
			if p.Resolved || current[k] || p.HeadSHA == sha || p.ThreadID == "" {
				continue
			}
			if _, err := conv.Reply(ctx, repo, n, p.ThreadID, fmt.Sprintf("No longer found at %s.\n\n<sub>agnts review</sub>%s", shortSHA(sha), agntsMark)); err != nil {
				continue
			}
			if err := conv.ResolveThread(ctx, repo, n, p.ThreadID, true); err != nil {
				o.log.Warn("resolve a finding that is gone", "ticket", t.Key, "err", err)
			}
			did.Resolved++
			_ = o.prposts.UpdatePRPost(ctx, p.ID, sha, true)
		}
	}

	// The review's text: the summary and what is not on a changed line.
	body := ""
	if sum != nil {
		body = sum.Body
	}
	if len(offLine) > 0 {
		if body == "" {
			body = "## agnts review\n"
		}
		body += "\n" + offLineSection(o, ctx, offLine)
	}
	if body != "" {
		body = truncate(body, maxPostedReview) + "\n" + agntsMark
	}
	var bodyPost *int64
	if sum != nil && summaryPost != nil {
		if _, err := conv.EditComment(ctx, repo, n, summaryPost.CommentID, body); err == nil {
			did.Summary, body = "edited", ""
			_ = o.prposts.UpdatePRPost(ctx, summaryPost.ID, rv.HeadSHA, false)
			bodyPost = &summaryPost.ID
		}
	}
	if len(heads) == 0 && body != "" {
		heads = []string{pr.HeadSHA}
		if reviewed && sum != nil {
			heads = []string{rv.HeadSHA}
		}
	}
	// One review per commit the comments are about (nearly always one);
	// the text goes with the first.
	slices.SortStableFunc(heads, func(a, b string) int {
		return boolRank(a != rv.HeadSHA) - boolRank(b != rv.HeadSHA)
	})
	for i, head := range heads {
		items := byHead[head]
		cs := make([]domain.NewPRComment, len(items))
		for j, it := range items {
			cs[j] = it.c
		}
		text, filler := "", false
		if i == 0 {
			text = body
		}
		if text == "" && len(cs) > 0 && opt.RequestChanges && i == 0 {
			text, filler = "agnts asks for changes: see the comments on the lines.\n"+agntsMark, true // GitHub wants a text with a verdict
		}
		if text == "" && len(cs) == 0 {
			continue
		}
		sumID, threads, err := conv.PostReview(ctx, repo, n, head, text, cs, opt.RequestChanges && i == 0)
		if err != nil {
			if errors.Is(err, domain.ErrNotInDiff) && head != pr.HeadSHA {
				return out, invalid("#%d has new commits since agnts reviewed it (%s, now %s) and the git host refused the old lines: review it again to publish these on the current lines",
					n, shortSHA(head), shortSHA(pr.HeadSHA))
			}
			return out, hostErr(fmt.Sprintf("publish the review on #%d", n), err)
		}
		if sumID != "" && !filler {
			if text == body && sum != nil {
				did.Summary = "posted"
			}
			// Only a text with the summary is the one a later summary edits.
			kind := domain.PostComment
			if text == body && sum != nil {
				kind = domain.PostSummary
			}
			if p, ok := o.addPost(ctx, domain.PRPost{RepoID: repo.ID, Number: n, TicketID: &t.ID, CommentID: sumID, ThreadID: sumID,
				Kind: kind, HeadSHA: head}); ok && text == body {
				bodyPost = &p.ID
			}
		}
		did.Inline += len(cs)
		for j, th := range threads {
			if j >= len(items) || len(th.Comments) == 0 {
				continue
			}
			it := items[j]
			kind, fk := domain.PostFinding, it.d.Key
			if it.d.Kind == domain.DraftComment {
				kind, fk = domain.PostComment, ""
			}
			if p, ok := o.addPost(ctx, domain.PRPost{RepoID: repo.ID, Number: n, TicketID: &t.ID, CommentID: th.Comments[0].ID, ThreadID: th.ID,
				Kind: kind, FindingKey: fk, HeadSHA: head}); ok {
				out[it.d.ID] = &p.ID
			}
		}
	}
	if sum != nil {
		out[sum.ID] = bodyPost
	}
	for _, d := range offLine {
		out[d.ID] = bodyPost
	}
	return out, nil
}

// addPost records a comment agnts posted and returns its row.
func (o *Orchestrator) addPost(ctx context.Context, p domain.PRPost) (domain.PRPost, bool) {
	if p.CommentID == "" {
		return p, false
	}
	out, err := o.prposts.AddPRPost(context.WithoutCancel(ctx), p)
	if err != nil {
		o.log.Warn("record pull request comment", "repo", p.RepoID, "number", p.Number, "err", err)
		return p, false
	}
	return out, true
}

// ownPull reports whether the git host token's user opened pr: the hosts
// do not let anyone request changes on their own pull request.
func ownPull(pr domain.PullRequest) bool {
	return pr.Login != "" && strings.EqualFold(pr.Author, pr.Login)
}

func boolRank(b bool) int {
	if b {
		return 1
	}
	return 0
}

// offLineSection lists accepted comments that are not on a changed line,
// for the review's text.
func offLineSection(o *Orchestrator, ctx context.Context, ds []domain.ReviewDraft) string {
	var b strings.Builder
	b.WriteString("### Not on a changed line\n")
	for _, d := range ds {
		where := ""
		if d.Path != "" {
			where = "`" + d.Path
			if d.Line > 0 {
				where += fmt.Sprintf(":%d", d.Line)
			}
			where += "`\n\n"
		}
		body := d.Body
		if d.Kind == domain.DraftComment {
			body = o.attributeTo(ctx, d.Body, d.Author)
		}
		fmt.Fprintf(&b, "\n%s%s\n", where, strings.TrimSpace(body))
	}
	return b.String()
}

// draftWhere is " (file:line)" for a draft with a file.
func draftWhere(d domain.ReviewDraft) string {
	if d.Path == "" {
		return ""
	}
	if d.Line > 0 {
		return fmt.Sprintf(" (%s:%d)", d.Path, d.Line)
	}
	return " (" + d.Path + ")"
}

// learnFromDrafts keeps what people did with agnts's findings, once, as a
// note on how they review: the ones dismissed without a reason (noise),
// and the ones rewritten before they were published.
func (o *Orchestrator) learnFromDrafts(ctx context.Context, t domain.Ticket, origin domain.Origin) {
	if o.pulls == nil || origin == domain.OriginSystem {
		return
	}
	var noise, rewritten []string
	_, err := o.drafts.UpdateReviewDrafts(context.WithoutCancel(ctx), t.ID, func(d *domain.ReviewDraft) bool {
		if d.Kind != domain.DraftFinding || d.Noted {
			return false
		}
		switch {
		case d.State == domain.DraftDismissed:
			noise = append(noise, fmt.Sprintf("- [%s] %s%s", d.Severity, d.Title, draftWhere(*d)))
		case d.State == domain.DraftPublished && d.Edited:
			rewritten = append(rewritten, fmt.Sprintf("- %s%s, posted as:\n\n%s", d.Title, draftWhere(*d), indentLines(clipRunes(d.Body, 600))))
		default:
			return false
		}
		d.Noted = true
		return true
	})
	if err != nil {
		o.log.Warn("note review drafts", "ticket", t.Key, "err", err)
		return
	}
	var b strings.Builder
	if len(noise) > 0 {
		b.WriteString("Left these findings out of the published review:\n" + strings.Join(noise, "\n") + "\n")
	}
	if len(rewritten) > 0 {
		if b.Len() > 0 {
			b.WriteString("\n")
		}
		b.WriteString("Rewrote these findings before publishing them:\n" + strings.Join(rewritten, "\n") + "\n")
	}
	if b.Len() > 0 {
		o.noteReviewer(ctx, t, domain.NoteDraft, clipRunes(b.String(), domain.ReviewerNoteMax), origin)
	}
}
