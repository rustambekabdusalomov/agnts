package github

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.Conversation = (*Host)(nil)

// GitHub keeps a pull request's conversation in three places: issue
// comments (the general ones), review comments (on diff lines, grouped in
// threads that only GraphQL can resolve) and reviews (a summary with a
// verdict). Ids say which:
//
//	ic:<id>                  issue comment (thread and comment)
//	rv:<id>                  review summary (thread and comment)
//	rc:<id>                  review comment
//	th:<node id>:<first id>  review thread: its GraphQL id and the id of
//	                         its first comment, which replies go to

const (
	prefIssue   = "ic:"
	prefReview  = "rv:"
	prefComment = "rc:"
	prefThread  = "th:"
)

// maxThreadPages caps the GraphQL pages of review threads read (50 each).
const maxThreadPages = 20

func repoPath(repo domain.Repository) (string, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return "", err
	}
	return "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name), nil
}

func numID(id, prefix string) (int64, error) {
	rest, ok := strings.CutPrefix(id, prefix)
	if !ok {
		return 0, fmt.Errorf("%q is not a GitHub comment id", id)
	}
	n, err := strconv.ParseInt(rest, 10, 64)
	if err != nil || n <= 0 {
		return 0, fmt.Errorf("%q is not a GitHub comment id", id)
	}
	return n, nil
}

// threadParts splits a review thread id into its GraphQL id ("" when not
// known yet) and its first comment's id.
func threadParts(id string) (string, int64, error) {
	rest, ok := strings.CutPrefix(id, prefThread)
	if !ok {
		return "", 0, fmt.Errorf("%q is not a GitHub review thread id", id)
	}
	node, first, ok := strings.Cut(rest, ":")
	n, err := strconv.ParseInt(first, 10, 64)
	if !ok || err != nil || n <= 0 {
		return "", 0, fmt.Errorf("%q is not a GitHub review thread id", id)
	}
	return node, n, nil
}

func threadID(node string, first int64) string {
	return prefThread + node + ":" + strconv.FormatInt(first, 10)
}

type ghAuthor struct {
	Login     string `json:"login"`
	AvatarURL string `json:"avatar_url"`
	Type      string `json:"type"`
}

type ghIssueComment struct {
	ID        int64     `json:"id"`
	User      ghAuthor  `json:"user"`
	Body      string    `json:"body"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	HTMLURL   string    `json:"html_url"`
}

func (c ghIssueComment) domain(login string) domain.PRComment {
	return domain.PRComment{ID: prefIssue + strconv.FormatInt(c.ID, 10), Author: c.User.Login, AvatarURL: c.User.AvatarURL,
		Body: c.Body, CreatedAt: c.CreatedAt, UpdatedAt: c.UpdatedAt, URL: c.HTMLURL, Mine: sameLogin(c.User.Login, login)}
}

type ghReviewComment struct {
	ID          int64     `json:"id"`
	User        ghAuthor  `json:"user"`
	Body        string    `json:"body"`
	Path        string    `json:"path"`
	Line        int       `json:"line"`
	StartLine   int       `json:"start_line"`
	Side        string    `json:"side"`
	CommitID    string    `json:"commit_id"`
	DiffHunk    string    `json:"diff_hunk"`
	InReplyToID int64     `json:"in_reply_to_id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	HTMLURL     string    `json:"html_url"`
}

func (c ghReviewComment) domain(login string) domain.PRComment {
	return domain.PRComment{ID: prefComment + strconv.FormatInt(c.ID, 10), Author: c.User.Login, AvatarURL: c.User.AvatarURL,
		Body: c.Body, CreatedAt: c.CreatedAt, UpdatedAt: c.UpdatedAt, URL: c.HTMLURL, Mine: sameLogin(c.User.Login, login)}
}

type ghReview struct {
	ID          int64     `json:"id"`
	User        ghAuthor  `json:"user"`
	Body        string    `json:"body"`
	State       string    `json:"state"`
	CommitID    string    `json:"commit_id"`
	SubmittedAt time.Time `json:"submitted_at"`
	HTMLURL     string    `json:"html_url"`
}

func (r ghReview) thread(login string) domain.PRThread {
	id := prefReview + strconv.FormatInt(r.ID, 10)
	return domain.PRThread{ID: id, Kind: domain.ThreadReview, CommitSHA: r.CommitID, ReviewState: r.State,
		Comments: []domain.PRComment{{ID: id, Author: r.User.Login, AvatarURL: r.User.AvatarURL, Body: r.Body,
			CreatedAt: r.SubmittedAt, UpdatedAt: r.SubmittedAt, URL: r.HTMLURL, Mine: sameLogin(r.User.Login, login)}}}
}

func sameLogin(a, b string) bool { return a != "" && strings.EqualFold(a, b) }

// PullRequests returns one page of repo's pull requests in state, most
// recently updated first. "merged" is the closed ones that were merged.
func (h *Host) PullRequests(ctx context.Context, repo domain.Repository, state string, page, perPage int) ([]domain.PullRequest, error) {
	base, err := pullsPath(repo)
	if err != nil {
		return nil, err
	}
	q := url.Values{"sort": {"updated"}, "direction": {"desc"}, "page": {strconv.Itoa(max(page, 1))}, "per_page": {strconv.Itoa(min(max(perPage, 1), 100))}}
	switch state {
	case "", domain.PullOpen:
		q.Set("state", "open")
	case domain.PullClosed, domain.PullMerged:
		q.Set("state", "closed")
	default:
		q.Set("state", "all")
	}
	var batch []ghPull
	if _, err := h.call(ctx, http.MethodGet, base+"?"+q.Encode(), nil, &batch); err != nil {
		return nil, err
	}
	login, _ := h.User(ctx)
	out := make([]domain.PullRequest, 0, len(batch))
	for _, p := range batch {
		why := ""
		switch {
		case has(p.Assignees, login):
			why = domain.PullAssigned
		case has(p.RequestedReviewers, login):
			why = domain.PullReviewRequested
		}
		d := p.domain(login, why)
		if (state == domain.PullMerged || state == domain.PullClosed) && d.State != state {
			continue // GitHub's closed are both: keep the asked ones
		}
		out = append(out, d)
	}
	return out, nil
}

// PullFiles returns the files the pull request changes, with patches.
func (h *Host) PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error) {
	base, err := pullsPath(repo)
	if err != nil {
		return nil, err
	}
	var out []domain.FileChange
	for page := 1; page <= orchestrator.PullFilesMax/100; page++ {
		var batch []struct {
			Filename  string `json:"filename"`
			Additions int    `json:"additions"`
			Deletions int    `json:"deletions"`
			Patch     string `json:"patch"`
		}
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, base+"/"+strconv.Itoa(number)+"/files?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, f := range batch {
			out = append(out, domain.FileChange{Path: f.Filename, Add: f.Additions, Del: f.Deletions, Diff: f.Patch})
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// threadsQuery reads a pull request's review threads, 50 at a time.
const threadsQuery = `query($owner: String!, $name: String!, $number: Int!, $after: String) {
  viewer { login }
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 50, after: $after) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line originalLine startLine originalStartLine diffSide
          comments(first: 100) {
            nodes {
              databaseId body createdAt lastEditedAt url diffHunk
              author { login avatarUrl }
              commit { oid }
              originalCommit { oid }
            }
          }
        }
      }
    }
  }
}`

type gqlThreads struct {
	Viewer struct {
		Login string `json:"login"`
	} `json:"viewer"`
	Repository struct {
		PullRequest *struct {
			ReviewThreads struct {
				PageInfo struct {
					HasNextPage bool   `json:"hasNextPage"`
					EndCursor   string `json:"endCursor"`
				} `json:"pageInfo"`
				Nodes []gqlThread `json:"nodes"`
			} `json:"reviewThreads"`
		} `json:"pullRequest"`
	} `json:"repository"`
}

type gqlThread struct {
	ID                string `json:"id"`
	IsResolved        bool   `json:"isResolved"`
	IsOutdated        bool   `json:"isOutdated"`
	Path              string `json:"path"`
	Line              *int   `json:"line"`
	OriginalLine      *int   `json:"originalLine"`
	StartLine         *int   `json:"startLine"`
	OriginalStartLine *int   `json:"originalStartLine"`
	DiffSide          string `json:"diffSide"`
	Comments          struct {
		Nodes []struct {
			DatabaseID   int64      `json:"databaseId"`
			Body         string     `json:"body"`
			CreatedAt    time.Time  `json:"createdAt"`
			LastEditedAt *time.Time `json:"lastEditedAt"`
			URL          string     `json:"url"`
			DiffHunk     string     `json:"diffHunk"`
			Author       *struct {
				Login     string `json:"login"`
				AvatarURL string `json:"avatarUrl"`
			} `json:"author"`
			Commit *struct {
				OID string `json:"oid"`
			} `json:"commit"`
			OriginalCommit *struct {
				OID string `json:"oid"`
			} `json:"originalCommit"`
		} `json:"nodes"`
	} `json:"comments"`
}

func intOr(ps ...*int) int {
	for _, p := range ps {
		if p != nil && *p > 0 {
			return *p
		}
	}
	return 0
}

func (t gqlThread) domain(login string) (domain.PRThread, bool) {
	cs := t.Comments.Nodes
	if len(cs) == 0 {
		return domain.PRThread{}, false
	}
	line := intOr(t.Line, t.OriginalLine)
	out := domain.PRThread{ID: threadID(t.ID, cs[0].DatabaseID), Kind: domain.ThreadInline, Path: t.Path,
		StartLine: intOr(t.StartLine, t.OriginalStartLine), DiffHunk: cs[0].DiffHunk,
		Outdated: t.IsOutdated, Resolvable: true, Resolved: t.IsResolved}
	if strings.EqualFold(t.DiffSide, "LEFT") {
		out.OldLine = line
		out.StartLine = 0 // ranges on removed lines are shown from their last line
	} else {
		out.Line = line
	}
	if c := cs[0].OriginalCommit; c != nil {
		out.CommitSHA = c.OID
	} else if c := cs[0].Commit; c != nil {
		out.CommitSHA = c.OID
	}
	for _, c := range cs {
		pc := domain.PRComment{ID: prefComment + strconv.FormatInt(c.DatabaseID, 10), Body: c.Body, CreatedAt: c.CreatedAt,
			UpdatedAt: c.CreatedAt, URL: c.URL}
		if c.LastEditedAt != nil {
			pc.UpdatedAt = *c.LastEditedAt
		}
		if c.Author != nil {
			pc.Author, pc.AvatarURL = c.Author.Login, c.Author.AvatarURL
		} else {
			pc.Author = "ghost" // a deleted account
		}
		pc.Mine = sameLogin(pc.Author, login)
		out.Comments = append(out.Comments, pc)
	}
	return out, true
}

// Threads returns the pull request's conversation: the general comments,
// the reviews that say something, and the review threads, ordered by when
// each started.
func (h *Host) Threads(ctx context.Context, repo domain.Repository, number int) ([]domain.PRThread, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return nil, err
	}
	var out []domain.PRThread
	login := ""
	after := any(nil)
	for range maxThreadPages {
		var res gqlThreads
		if err := h.graphql(ctx, threadsQuery, map[string]any{"owner": owner, "name": name, "number": number, "after": after}, &res); err != nil {
			return nil, err
		}
		login = res.Viewer.Login
		pr := res.Repository.PullRequest
		if pr == nil {
			return nil, fmt.Errorf("github: pull request #%d: %w", number, domain.ErrNotFound)
		}
		for _, t := range pr.ReviewThreads.Nodes {
			if th, ok := t.domain(login); ok {
				out = append(out, th)
			}
		}
		if !pr.ReviewThreads.PageInfo.HasNextPage {
			break
		}
		after = pr.ReviewThreads.PageInfo.EndCursor
	}
	base, _ := repoPath(repo)
	for page := 1; page <= 10; page++ {
		var batch []ghIssueComment
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, base+"/issues/"+strconv.Itoa(number)+"/comments?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, c := range batch {
			d := c.domain(login)
			out = append(out, domain.PRThread{ID: d.ID, Kind: domain.ThreadGeneral, Comments: []domain.PRComment{d}})
		}
		if len(batch) < 100 {
			break
		}
	}
	for page := 1; page <= 5; page++ {
		var batch []ghReview
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, base+"/pulls/"+strconv.Itoa(number)+"/reviews?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, r := range batch {
			// A pending review is only its author's draft; a bare COMMENTED
			// review is just the wrapper of its inline comments.
			if r.State == "PENDING" || (r.State == "COMMENTED" && strings.TrimSpace(r.Body) == "") {
				continue
			}
			out = append(out, r.thread(login))
		}
		if len(batch) < 100 {
			break
		}
	}
	sortThreads(out)
	return out, nil
}

func sortThreads(ts []domain.PRThread) {
	slices.SortStableFunc(ts, func(a, b domain.PRThread) int {
		var at, bt time.Time
		if len(a.Comments) > 0 {
			at = a.Comments[0].CreatedAt
		}
		if len(b.Comments) > 0 {
			bt = b.Comments[0].CreatedAt
		}
		return at.Compare(bt)
	})
}

// inlineBody is a review comment's position, as the REST API takes it.
func inlineBody(c domain.NewPRComment) map[string]any {
	m := map[string]any{"path": c.Path, "body": c.Body}
	if c.Line > 0 {
		m["line"], m["side"] = c.Line, "RIGHT"
		if c.StartLine > 0 && c.StartLine < c.Line {
			m["start_line"], m["start_side"] = c.StartLine, "RIGHT"
		}
	} else {
		m["line"], m["side"] = c.OldLine, "LEFT"
	}
	return m
}

// notInDiff turns GitHub's refusal of a position into domain.ErrNotInDiff.
func notInDiff(status int, err error) error {
	if status == http.StatusUnprocessableEntity && err != nil &&
		(strings.Contains(err.Error(), "line") || strings.Contains(err.Error(), "diff") || strings.Contains(err.Error(), "position")) {
		return fmt.Errorf("%w (%w)", domain.ErrNotInDiff, err)
	}
	return needs(status, err, "Pull requests: Read and write")
}

// AddComment starts a thread: an issue comment, or a review comment on a
// diff line of the commit c.HeadSHA.
func (h *Host) AddComment(ctx context.Context, repo domain.Repository, number int, c domain.NewPRComment) (domain.PRThread, error) {
	base, err := repoPath(repo)
	if err != nil {
		return domain.PRThread{}, err
	}
	login, _ := h.User(ctx)
	if c.Path == "" {
		var ic ghIssueComment
		status, err := h.call(ctx, http.MethodPost, base+"/issues/"+strconv.Itoa(number)+"/comments", map[string]any{"body": c.Body}, &ic)
		if err != nil {
			return domain.PRThread{}, needs(status, err, "Pull requests: Read and write")
		}
		d := ic.domain(login)
		return domain.PRThread{ID: d.ID, Kind: domain.ThreadGeneral, Comments: []domain.PRComment{d}}, nil
	}
	if c.HeadSHA == "" {
		return domain.PRThread{}, errors.New("an inline comment needs the pull request's head commit")
	}
	body := inlineBody(c)
	body["commit_id"] = c.HeadSHA
	var rc ghReviewComment
	status, err := h.call(ctx, http.MethodPost, base+"/pulls/"+strconv.Itoa(number)+"/comments", body, &rc)
	if err != nil {
		return domain.PRThread{}, notInDiff(status, err)
	}
	return h.reviewCommentThread(rc, login), nil
}

// reviewCommentThread is the thread a new review comment started. Its
// GraphQL id is not known yet: resolving it looks the thread up.
func (h *Host) reviewCommentThread(rc ghReviewComment, login string) domain.PRThread {
	th := domain.PRThread{ID: threadID("", rc.ID), Kind: domain.ThreadInline, Path: rc.Path, StartLine: rc.StartLine,
		DiffHunk: rc.DiffHunk, CommitSHA: rc.CommitID, Resolvable: true, Comments: []domain.PRComment{rc.domain(login)}}
	if strings.EqualFold(rc.Side, "LEFT") {
		th.OldLine, th.StartLine = rc.Line, 0
	} else {
		th.Line = rc.Line
	}
	return th
}

// Reply answers in a review thread. General comments and reviews have no
// threads on GitHub: the answer is a new comment quoting the first line.
func (h *Host) Reply(ctx context.Context, repo domain.Repository, number int, id, body string) (domain.PRComment, error) {
	base, err := repoPath(repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	login, _ := h.User(ctx)
	if strings.HasPrefix(id, prefThread) {
		_, first, err := threadParts(id)
		if err != nil {
			return domain.PRComment{}, err
		}
		var rc ghReviewComment
		status, err := h.call(ctx, http.MethodPost, base+"/pulls/"+strconv.Itoa(number)+"/comments/"+strconv.FormatInt(first, 10)+"/replies",
			map[string]any{"body": body}, &rc)
		if err != nil {
			return domain.PRComment{}, needs(status, err, "Pull requests: Read and write")
		}
		return rc.domain(login), nil
	}
	quote := ""
	if q, err := h.quoted(ctx, base, number, id); err == nil && q != "" {
		quote = q + "\n\n"
	}
	var ic ghIssueComment
	status, err := h.call(ctx, http.MethodPost, base+"/issues/"+strconv.Itoa(number)+"/comments", map[string]any{"body": quote + body}, &ic)
	if err != nil {
		return domain.PRComment{}, needs(status, err, "Pull requests: Read and write")
	}
	return ic.domain(login), nil
}

// quoted is "> @author: first line" of the comment a reply answers.
func (h *Host) quoted(ctx context.Context, base string, number int, id string) (string, error) {
	var author, body string
	switch {
	case strings.HasPrefix(id, prefIssue):
		n, err := numID(id, prefIssue)
		if err != nil {
			return "", err
		}
		var c ghIssueComment
		if _, err := h.call(ctx, http.MethodGet, base+"/issues/comments/"+strconv.FormatInt(n, 10), nil, &c); err != nil {
			return "", err
		}
		author, body = c.User.Login, c.Body
	case strings.HasPrefix(id, prefReview):
		n, err := numID(id, prefReview)
		if err != nil {
			return "", err
		}
		var r ghReview
		if _, err := h.call(ctx, http.MethodGet, base+"/pulls/"+strconv.Itoa(number)+"/reviews/"+strconv.FormatInt(n, 10), nil, &r); err != nil {
			return "", err
		}
		author, body = r.User.Login, r.Body
	default:
		return "", fmt.Errorf("%q is not a GitHub thread id", id)
	}
	line, _, _ := strings.Cut(strings.TrimSpace(body), "\n")
	if r := []rune(line); len(r) > 140 {
		line = string(r[:139]) + "…"
	}
	if line == "" {
		return "", nil
	}
	return "> @" + author + ": " + line, nil
}

// EditComment replaces a comment's text.
func (h *Host) EditComment(ctx context.Context, repo domain.Repository, number int, id, body string) (domain.PRComment, error) {
	base, err := repoPath(repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	login, _ := h.User(ctx)
	switch {
	case strings.HasPrefix(id, prefIssue):
		n, err := numID(id, prefIssue)
		if err != nil {
			return domain.PRComment{}, err
		}
		var c ghIssueComment
		status, err := h.call(ctx, http.MethodPatch, base+"/issues/comments/"+strconv.FormatInt(n, 10), map[string]any{"body": body}, &c)
		if err != nil {
			return domain.PRComment{}, notFoundOr(status, err)
		}
		return c.domain(login), nil
	case strings.HasPrefix(id, prefComment):
		n, err := numID(id, prefComment)
		if err != nil {
			return domain.PRComment{}, err
		}
		var c ghReviewComment
		status, err := h.call(ctx, http.MethodPatch, base+"/pulls/comments/"+strconv.FormatInt(n, 10), map[string]any{"body": body}, &c)
		if err != nil {
			return domain.PRComment{}, notFoundOr(status, err)
		}
		return c.domain(login), nil
	case strings.HasPrefix(id, prefReview):
		n, err := numID(id, prefReview)
		if err != nil {
			return domain.PRComment{}, err
		}
		var r ghReview
		status, err := h.call(ctx, http.MethodPut, base+"/pulls/"+strconv.Itoa(number)+"/reviews/"+strconv.FormatInt(n, 10), map[string]any{"body": body}, &r)
		if err != nil {
			return domain.PRComment{}, notFoundOr(status, err)
		}
		return r.thread(login).Comments[0], nil
	}
	return domain.PRComment{}, fmt.Errorf("%q is not a GitHub comment id", id)
}

// DeleteComment removes a comment. A submitted review cannot be deleted
// on GitHub, only edited.
func (h *Host) DeleteComment(ctx context.Context, repo domain.Repository, number int, id string) error {
	base, err := repoPath(repo)
	if err != nil {
		return err
	}
	var path string
	switch {
	case strings.HasPrefix(id, prefIssue):
		n, err := numID(id, prefIssue)
		if err != nil {
			return err
		}
		path = base + "/issues/comments/" + strconv.FormatInt(n, 10)
	case strings.HasPrefix(id, prefComment):
		n, err := numID(id, prefComment)
		if err != nil {
			return err
		}
		path = base + "/pulls/comments/" + strconv.FormatInt(n, 10)
	case strings.HasPrefix(id, prefReview):
		return errors.New("GitHub cannot delete a submitted review; edit its text instead")
	default:
		return fmt.Errorf("%q is not a GitHub comment id", id)
	}
	status, err := h.call(ctx, http.MethodDelete, path, nil, nil)
	if status == http.StatusNotFound {
		return nil // gone already
	}
	return needs(status, err, "Pull requests: Read and write")
}

func notFoundOr(status int, err error) error {
	if status == http.StatusNotFound {
		return fmt.Errorf("%w: the comment is gone from GitHub", domain.ErrNotFound)
	}
	return needs(status, err, "Pull requests: Read and write")
}

const resolveMutation = `mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }`
const unresolveMutation = `mutation($id: ID!) { unresolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }`

// ResolveThread resolves or reopens a review thread (GraphQL only).
func (h *Host) ResolveThread(ctx context.Context, repo domain.Repository, number int, id string, resolved bool) error {
	node, first, err := threadParts(id)
	if err != nil {
		return errors.New("only threads on diff lines can be resolved on GitHub")
	}
	if node == "" { // a thread agnts just started: find its GraphQL id
		ts, err := h.Threads(ctx, repo, number)
		if err != nil {
			return err
		}
		for _, t := range ts {
			if n, f, err := threadParts(t.ID); err == nil && f == first {
				node = n
				break
			}
		}
		if node == "" {
			return fmt.Errorf("%w: the thread is gone from GitHub", domain.ErrNotFound)
		}
	}
	q := resolveMutation
	if !resolved {
		q = unresolveMutation
	}
	var out map[string]any
	return h.graphql(ctx, q, map[string]any{"id": node}, &out)
}

// PostReview posts one review: body as its summary and cs on their lines.
func (h *Host) PostReview(ctx context.Context, repo domain.Repository, number int, headSHA, body string, cs []domain.NewPRComment, requestChanges bool) (string, []domain.PRThread, error) {
	base, err := repoPath(repo)
	if err != nil {
		return "", nil, err
	}
	event := "COMMENT"
	if requestChanges {
		event = "REQUEST_CHANGES"
	}
	comments := make([]map[string]any, len(cs))
	for i, c := range cs {
		comments[i] = inlineBody(c)
	}
	in := map[string]any{"event": event, "body": body, "comments": comments}
	if headSHA != "" {
		in["commit_id"] = headSHA
	}
	var r ghReview
	status, err := h.call(ctx, http.MethodPost, base+"/pulls/"+strconv.Itoa(number)+"/reviews", in, &r)
	if err != nil {
		return "", nil, notInDiff(status, err)
	}
	summary := ""
	if strings.TrimSpace(body) != "" {
		summary = prefReview + strconv.FormatInt(r.ID, 10)
	}
	if len(cs) == 0 {
		return summary, nil, nil
	}
	// The review's comments come back in the order they were given; match
	// them by place and text all the same.
	var posted []ghReviewComment
	if _, err := h.call(ctx, http.MethodGet, base+"/pulls/"+strconv.Itoa(number)+"/reviews/"+strconv.FormatInt(r.ID, 10)+"/comments?per_page=100", nil, &posted); err != nil {
		return summary, nil, nil // posted; agnts just cannot tell the ids
	}
	login, _ := h.User(ctx)
	used := make([]bool, len(posted))
	threads := make([]domain.PRThread, len(cs))
	for i, c := range cs {
		for j, p := range posted {
			if !used[j] && p.Path == c.Path && strings.TrimSpace(p.Body) == strings.TrimSpace(c.Body) {
				used[j] = true
				threads[i] = h.reviewCommentThread(p, login)
				break
			}
		}
	}
	return summary, threads, nil
}
