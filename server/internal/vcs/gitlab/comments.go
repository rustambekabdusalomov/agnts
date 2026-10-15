package gitlab

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

// On GitLab a merge request's conversation is its discussions: a general
// comment is a discussion with one note (individual_note), a thread on a
// diff line has a position. Ids:
//
//	gd:<discussion id>  a discussion (thread)
//	gn:<note id>        a general comment agnts just posted, whose
//	                    discussion is looked up when it is answered
//	n:<note id>         a note (comment)

const (
	prefDiscussion = "gd:"
	prefNewNote    = "gn:"
	prefNote       = "n:"
)

type glAuthor struct {
	Username  string `json:"username"`
	AvatarURL string `json:"avatar_url"`
}

type glPosition struct {
	BaseSHA  string `json:"base_sha"`
	StartSHA string `json:"start_sha"`
	HeadSHA  string `json:"head_sha"`
	OldPath  string `json:"old_path"`
	NewPath  string `json:"new_path"`
	OldLine  int    `json:"old_line"`
	NewLine  int    `json:"new_line"`
	Range    *struct {
		Start struct {
			OldLine int `json:"old_line"`
			NewLine int `json:"new_line"`
		} `json:"start"`
	} `json:"line_range"`
}

type glNote struct {
	ID         int64       `json:"id"`
	Body       string      `json:"body"`
	Author     glAuthor    `json:"author"`
	CreatedAt  time.Time   `json:"created_at"`
	UpdatedAt  time.Time   `json:"updated_at"`
	System     bool        `json:"system"`
	Resolvable bool        `json:"resolvable"`
	Resolved   bool        `json:"resolved"`
	Position   *glPosition `json:"position"`
}

func (n glNote) domain(login, mrURL string) domain.PRComment {
	c := domain.PRComment{ID: prefNote + strconv.FormatInt(n.ID, 10), Author: n.Author.Username, AvatarURL: n.Author.AvatarURL,
		Body: n.Body, CreatedAt: n.CreatedAt, UpdatedAt: n.UpdatedAt, System: n.System,
		Mine: !n.System && n.Author.Username != "" && strings.EqualFold(n.Author.Username, login)}
	if mrURL != "" {
		c.URL = mrURL + "#note_" + strconv.FormatInt(n.ID, 10)
	}
	return c
}

type glDiscussion struct {
	ID             string   `json:"id"`
	IndividualNote bool     `json:"individual_note"`
	Notes          []glNote `json:"notes"`
}

func (d glDiscussion) domain(login, mrURL, head string) (domain.PRThread, bool) {
	if len(d.Notes) == 0 {
		return domain.PRThread{}, false
	}
	first := d.Notes[0]
	t := domain.PRThread{ID: prefDiscussion + d.ID, Kind: domain.ThreadGeneral}
	if p := first.Position; p != nil && (p.NewPath != "" || p.OldPath != "") {
		t.Kind, t.Path, t.Line, t.CommitSHA = domain.ThreadInline, p.NewPath, p.NewLine, p.HeadSHA
		if t.Path == "" {
			t.Path = p.OldPath
		}
		if p.NewLine == 0 {
			t.OldLine = p.OldLine
		}
		if p.Range != nil && p.Range.Start.NewLine > 0 && p.Range.Start.NewLine < p.NewLine {
			t.StartLine = p.Range.Start.NewLine
		}
		// GitLab does not say whether the line changed since; a thread
		// written on an older version is shown as such.
		t.Outdated = head != "" && p.HeadSHA != "" && p.HeadSHA != head
	}
	resolved := true
	for _, n := range d.Notes {
		if n.Resolvable {
			t.Resolvable = true
			resolved = resolved && n.Resolved
		}
		t.Comments = append(t.Comments, n.domain(login, mrURL))
	}
	t.Resolved = t.Resolvable && resolved
	return t, true
}

func notesID(id, prefix string) (string, error) {
	rest, ok := strings.CutPrefix(id, prefix)
	if !ok || rest == "" || strings.ContainsAny(rest, "/?#") {
		return "", fmt.Errorf("%q is not a GitLab comment id", id)
	}
	return rest, nil
}

func mrPath(p string, number int) string { return p + "/merge_requests/" + strconv.Itoa(number) }

// PullRequests returns one page of repo's merge requests in state, most
// recently updated first.
func (h *Host) PullRequests(ctx context.Context, repo domain.Repository, state string, page, perPage int) ([]domain.PullRequest, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	q := url.Values{"order_by": {"updated_at"}, "sort": {"desc"}, "page": {strconv.Itoa(max(page, 1))}, "per_page": {strconv.Itoa(min(max(perPage, 1), 100))}}
	switch state {
	case "", domain.PullOpen:
		q.Set("state", "opened")
	case domain.PullClosed, domain.PullMerged:
		q.Set("state", state)
	default:
		q.Set("state", "all")
	}
	var batch []glMR
	if _, err := h.call(ctx, http.MethodGet, p+"/merge_requests?"+q.Encode(), nil, &batch); err != nil {
		return nil, err
	}
	login, _ := h.User(ctx)
	out := make([]domain.PullRequest, 0, len(batch))
	for _, m := range batch {
		why := ""
		switch {
		case hasUser(m.Assignees, login):
			why = domain.PullAssigned
		case hasUser(m.Reviewers, login):
			why = domain.PullReviewRequested
		}
		out = append(out, m.domain(login, why))
	}
	return out, nil
}

// PullFiles returns the files the merge request changes, with patches.
func (h *Host) PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	type glDiff struct {
		OldPath     string `json:"old_path"`
		NewPath     string `json:"new_path"`
		Diff        string `json:"diff"`
		DeletedFile bool   `json:"deleted_file"`
	}
	var diffs []glDiff
	for page := 1; page <= orchestrator.PullFilesMax/100; page++ {
		var batch []glDiff
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		status, err := h.call(ctx, http.MethodGet, mrPath(p, number)+"/diffs?"+q.Encode(), nil, &batch)
		if status == http.StatusNotFound && page == 1 { // before GitLab 15.7
			var ch struct {
				Changes []glDiff `json:"changes"`
			}
			if _, err := h.call(ctx, http.MethodGet, mrPath(p, number)+"/changes", nil, &ch); err != nil {
				return nil, err
			}
			diffs = ch.Changes
			break
		}
		if err != nil {
			return nil, err
		}
		diffs = append(diffs, batch...)
		if len(batch) < 100 {
			break
		}
	}
	out := make([]domain.FileChange, 0, len(diffs))
	for _, d := range diffs {
		f := domain.FileChange{Path: d.NewPath, Diff: d.Diff}
		if d.DeletedFile || f.Path == "" {
			f.Path = d.OldPath
		}
		for _, l := range strings.Split(d.Diff, "\n") {
			switch {
			case strings.HasPrefix(l, "+"):
				f.Add++
			case strings.HasPrefix(l, "-"):
				f.Del++
			}
		}
		out = append(out, f)
	}
	return out, nil
}

// mrRefs returns the merge request's page and its diff refs.
func (h *Host) mrRefs(ctx context.Context, p string, number int) (glMR, error) {
	var m glMR
	_, err := h.call(ctx, http.MethodGet, mrPath(p, number), nil, &m)
	return m, err
}

// Threads returns the merge request's discussions, oldest first.
func (h *Host) Threads(ctx context.Context, repo domain.Repository, number int) ([]domain.PRThread, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	m, err := h.mrRefs(ctx, p, number)
	if err != nil {
		return nil, err
	}
	login, _ := h.User(ctx)
	var out []domain.PRThread
	for page := 1; page <= 10; page++ {
		var batch []glDiscussion
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, mrPath(p, number)+"/discussions?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, d := range batch {
			if t, ok := d.domain(login, m.WebURL, m.DiffRefs.HeadSHA); ok {
				out = append(out, t)
			}
		}
		if len(batch) < 100 {
			break
		}
	}
	slices.SortStableFunc(out, func(a, b domain.PRThread) int { return a.Comments[0].CreatedAt.Compare(b.Comments[0].CreatedAt) })
	return out, nil
}

// position is where an inline note goes. A line in both versions (an
// unchanged line of the diff) needs both numbers.
func position(m glMR, c domain.NewPRComment, head string) map[string]any {
	if head == "" {
		head = m.DiffRefs.HeadSHA
	}
	pos := map[string]any{"position_type": "text", "base_sha": m.DiffRefs.BaseSHA, "start_sha": m.DiffRefs.StartSHA, "head_sha": head,
		"new_path": c.Path, "old_path": c.Path}
	if c.Line > 0 {
		pos["new_line"] = c.Line
	}
	if c.OldLine > 0 {
		pos["old_line"] = c.OldLine
	}
	return pos
}

// notInDiff turns GitLab's refusal of a position into domain.ErrNotInDiff.
func notInDiff(status int, err error) error {
	if status == http.StatusBadRequest && err != nil &&
		(strings.Contains(err.Error(), "line_code") || strings.Contains(err.Error(), "position") || strings.Contains(err.Error(), "line")) {
		return fmt.Errorf("%w (%w)", domain.ErrNotInDiff, err)
	}
	return err
}

// AddComment posts a note, or starts a discussion on a diff line.
func (h *Host) AddComment(ctx context.Context, repo domain.Repository, number int, c domain.NewPRComment) (domain.PRThread, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return domain.PRThread{}, err
	}
	m, err := h.mrRefs(ctx, p, number)
	if err != nil {
		return domain.PRThread{}, err
	}
	login, _ := h.User(ctx)
	if c.Path == "" {
		var n glNote
		if _, err := h.call(ctx, http.MethodPost, mrPath(p, number)+"/notes", map[string]any{"body": c.Body}, &n); err != nil {
			return domain.PRThread{}, err
		}
		return domain.PRThread{ID: prefNewNote + strconv.FormatInt(n.ID, 10), Kind: domain.ThreadGeneral,
			Comments: []domain.PRComment{n.domain(login, m.WebURL)}}, nil
	}
	var d glDiscussion
	status, err := h.call(ctx, http.MethodPost, mrPath(p, number)+"/discussions",
		map[string]any{"body": c.Body, "position": position(m, c, c.HeadSHA)}, &d)
	if err != nil {
		return domain.PRThread{}, notInDiff(status, err)
	}
	t, ok := d.domain(login, m.WebURL, m.DiffRefs.HeadSHA)
	if !ok {
		return domain.PRThread{}, errors.New("gitlab returned an empty discussion")
	}
	return t, nil
}

// discussionOf finds the discussion a note is in.
func (h *Host) discussionOf(ctx context.Context, p string, number int, noteID string) (string, error) {
	for page := 1; page <= 10; page++ {
		var batch []glDiscussion
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, mrPath(p, number)+"/discussions?"+q.Encode(), nil, &batch); err != nil {
			return "", err
		}
		for _, d := range batch {
			for _, n := range d.Notes {
				if strconv.FormatInt(n.ID, 10) == noteID {
					return d.ID, nil
				}
			}
		}
		if len(batch) < 100 {
			break
		}
	}
	return "", fmt.Errorf("%w: the comment is gone from GitLab", domain.ErrNotFound)
}

func (h *Host) discussionID(ctx context.Context, p string, number int, id string) (string, error) {
	if strings.HasPrefix(id, prefNewNote) {
		n, err := notesID(id, prefNewNote)
		if err != nil {
			return "", err
		}
		return h.discussionOf(ctx, p, number, n)
	}
	return notesID(id, prefDiscussion)
}

// Reply answers in a discussion.
func (h *Host) Reply(ctx context.Context, repo domain.Repository, number int, id, body string) (domain.PRComment, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	did, err := h.discussionID(ctx, p, number, id)
	if err != nil {
		return domain.PRComment{}, err
	}
	var n glNote
	status, err := h.call(ctx, http.MethodPost, mrPath(p, number)+"/discussions/"+url.PathEscape(did)+"/notes", map[string]any{"body": body}, &n)
	if err != nil {
		return domain.PRComment{}, notFoundOr(status, err)
	}
	login, _ := h.User(ctx)
	return n.domain(login, ""), nil
}

func notFoundOr(status int, err error) error {
	if status == http.StatusNotFound {
		return fmt.Errorf("%w: the comment is gone from GitLab", domain.ErrNotFound)
	}
	return err
}

// EditComment replaces a note's text.
func (h *Host) EditComment(ctx context.Context, repo domain.Repository, number int, id, body string) (domain.PRComment, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return domain.PRComment{}, err
	}
	nid, err := notesID(id, prefNote)
	if err != nil {
		return domain.PRComment{}, err
	}
	var n glNote
	status, err := h.call(ctx, http.MethodPut, mrPath(p, number)+"/notes/"+nid, map[string]any{"body": body}, &n)
	if err != nil {
		return domain.PRComment{}, notFoundOr(status, err)
	}
	login, _ := h.User(ctx)
	return n.domain(login, ""), nil
}

// DeleteComment removes a note.
func (h *Host) DeleteComment(ctx context.Context, repo domain.Repository, number int, id string) error {
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	nid, err := notesID(id, prefNote)
	if err != nil {
		return err
	}
	status, err := h.call(ctx, http.MethodDelete, mrPath(p, number)+"/notes/"+nid, nil, nil)
	if status == http.StatusNotFound {
		return nil // gone already
	}
	return err
}

// ResolveThread resolves or reopens a discussion.
func (h *Host) ResolveThread(ctx context.Context, repo domain.Repository, number int, id string, resolved bool) error {
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	did, err := h.discussionID(ctx, p, number, id)
	if err != nil {
		return err
	}
	q := url.Values{"resolved": {strconv.FormatBool(resolved)}}
	status, err := h.call(ctx, http.MethodPut, mrPath(p, number)+"/discussions/"+url.PathEscape(did)+"?"+q.Encode(), nil, nil)
	return notFoundOr(status, err)
}

// PostReview posts the summary and the inline comments as draft notes and
// publishes them together, so people get one notification. GitLab has no
// "request changes" verdict here; requestChanges is ignored. Instances
// without draft notes get the comments one by one.
func (h *Host) PostReview(ctx context.Context, repo domain.Repository, number int, headSHA, body string, cs []domain.NewPRComment, _ bool) (string, []domain.PRThread, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return "", nil, err
	}
	m, err := h.mrRefs(ctx, p, number)
	if err != nil {
		return "", nil, err
	}
	drafts := mrPath(p, number) + "/draft_notes"
	var ids []int64
	discard := func() {
		for _, id := range ids {
			_, _ = h.call(context.WithoutCancel(ctx), http.MethodDelete, drafts+"/"+strconv.FormatInt(id, 10), nil, nil)
		}
	}
	for _, c := range cs {
		var d struct {
			ID int64 `json:"id"`
		}
		status, err := h.call(ctx, http.MethodPost, drafts, map[string]any{"note": c.Body, "position": position(m, c, headSHA)}, &d)
		if status == http.StatusNotFound && len(ids) == 0 {
			return h.postOneByOne(ctx, repo, number, headSHA, body, cs)
		}
		if err != nil {
			discard()
			return "", nil, notInDiff(status, err)
		}
		ids = append(ids, d.ID)
	}
	if strings.TrimSpace(body) != "" {
		var d struct {
			ID int64 `json:"id"`
		}
		status, err := h.call(ctx, http.MethodPost, drafts, map[string]any{"note": body}, &d)
		if status == http.StatusNotFound && len(ids) == 0 {
			return h.postOneByOne(ctx, repo, number, headSHA, body, cs)
		}
		if err != nil {
			discard()
			return "", nil, err
		}
		ids = append(ids, d.ID)
	}
	if len(ids) == 0 {
		return "", nil, nil
	}
	if _, err := h.call(ctx, http.MethodPost, drafts+"/bulk_publish", nil, nil); err != nil {
		discard()
		return "", nil, err
	}
	// Published drafts become notes with new ids: find them by text.
	ts, err := h.Threads(ctx, repo, number)
	if err != nil {
		return "", nil, nil // posted; agnts just cannot tell the ids
	}
	return matchPosted(ts, body, cs)
}

// matchPosted finds the summary note and each inline comment's thread
// among the newest threads, by place and text.
func matchPosted(ts []domain.PRThread, body string, cs []domain.NewPRComment) (string, []domain.PRThread, error) {
	used := map[string]bool{}
	summary := ""
	threads := make([]domain.PRThread, len(cs))
	for i := len(ts) - 1; i >= 0; i-- { // newest first
		t := ts[i]
		if len(t.Comments) == 0 || used[t.ID] {
			continue
		}
		first := t.Comments[0]
		if !first.Mine {
			continue
		}
		if t.Kind == domain.ThreadGeneral && summary == "" && strings.TrimSpace(body) != "" && strings.TrimSpace(first.Body) == strings.TrimSpace(body) {
			summary, used[t.ID] = first.ID, true
			continue
		}
		for j, c := range cs {
			if threads[j].ID == "" && t.Path == c.Path && strings.TrimSpace(first.Body) == strings.TrimSpace(c.Body) {
				threads[j], used[t.ID] = t, true
				break
			}
		}
	}
	return summary, threads, nil
}

// postOneByOne posts the review without draft notes (older GitLab).
func (h *Host) postOneByOne(ctx context.Context, repo domain.Repository, number int, headSHA, body string, cs []domain.NewPRComment) (string, []domain.PRThread, error) {
	threads := make([]domain.PRThread, len(cs))
	for i, c := range cs {
		c.HeadSHA = headSHA
		t, err := h.AddComment(ctx, repo, number, c)
		if err != nil {
			return "", threads[:i], err
		}
		threads[i] = t
	}
	summary := ""
	if strings.TrimSpace(body) != "" {
		t, err := h.AddComment(ctx, repo, number, domain.NewPRComment{Body: body})
		if err != nil {
			return "", threads, err
		}
		summary = t.Comments[0].ID
	}
	return summary, threads, nil
}
