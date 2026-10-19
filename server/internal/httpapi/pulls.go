package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Pulls is what the pull request pages read and change: the pull requests
// of a repository and their conversations on the git host.
type Pulls interface {
	Pulls(ctx context.Context, repoID int64, state string, page int) ([]orchestrator.PullItem, error)
	Pull(ctx context.Context, repoID int64, number int) (orchestrator.PullView, error)
	PullThreads(ctx context.Context, repoID int64, number int) ([]orchestrator.ThreadView, error)
	AddPullComment(ctx context.Context, repoID int64, number int, c domain.NewPRComment, origin domain.Origin) (domain.PRThread, error)
	ReplyPullThread(ctx context.Context, repoID int64, number int, threadID, body string, origin domain.Origin) (domain.PRComment, error)
	EditPullComment(ctx context.Context, repoID int64, number int, commentID, body string, origin domain.Origin) (domain.PRComment, error)
	DeletePullComment(ctx context.Context, repoID int64, number int, commentID string, origin domain.Origin) error
	ResolvePullThread(ctx context.Context, repoID int64, number int, threadID string, resolved bool, origin domain.Origin) error
	AddressThreads(ctx context.Context, key string, ids []string, origin domain.Origin) (domain.Ticket, error)
}

func (s *Server) pullsReady(w http.ResponseWriter) bool {
	if s.opt.Pulls == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

// pullsError answers a failed pull request call: the git host's refusal
// is a 502 with its message.
func (s *Server) pullsError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, orchestrator.ErrHost):
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", err.Error())
	default:
		s.writeUseCaseError(w, r, err)
	}
}

func optStr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func optInt(n int) *int {
	if n == 0 {
		return nil
	}
	return &n
}

func toPullItem(p domain.PullRequest, key string, own bool) gen.PullItem {
	return gen.PullItem{Number: p.Number, Url: p.URL, Title: p.Title, Author: p.Author, HeadRef: p.HeadRef, HeadSha: p.HeadSHA,
		BaseRef: p.BaseRef, Draft: p.Draft, State: gen.PullItemState(p.State), Why: p.Why, UpdatedAt: p.UpdatedAt,
		TicketKey: optStr(key), Own: own}
}

func toPullComment(c domain.PRComment) gen.PullComment {
	return gen.PullComment{Id: c.ID, Author: c.Author, AvatarUrl: optStr(c.AvatarURL), Body: c.Body, CreatedAt: c.CreatedAt,
		UpdatedAt: c.UpdatedAt, Url: optStr(c.URL), Mine: c.Mine, System: c.System, Agnts: c.Agnts}
}

func toPullThread(t domain.PRThread) gen.PullThread {
	out := gen.PullThread{Id: t.ID, Kind: gen.PullThreadKind(t.Kind), Path: optStr(t.Path), Line: optInt(t.Line), OldLine: optInt(t.OldLine),
		StartLine: optInt(t.StartLine), DiffHunk: optStr(t.DiffHunk), CommitSha: optStr(t.CommitSHA), Outdated: t.Outdated,
		Resolvable: t.Resolvable, Resolved: t.Resolved, ReviewState: optStr(t.ReviewState), Comments: make([]gen.PullComment, len(t.Comments))}
	for i, c := range t.Comments {
		out.Comments[i] = toPullComment(c)
	}
	return out
}

// ListRepoPulls implements gen.ServerInterface.
func (s *Server) ListRepoPulls(w http.ResponseWriter, r *http.Request, id gen.RepoID, p gen.ListRepoPullsParams) {
	if !s.pullsReady(w) {
		return
	}
	state, page := "", 1
	if p.State != nil {
		state = string(*p.State)
	}
	if p.Page != nil {
		page = *p.Page
	}
	items, err := s.opt.Pulls.Pulls(r.Context(), id, state, page)
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	out := make([]gen.PullItem, len(items))
	for i, it := range items {
		out[i] = toPullItem(it.PullRequest, it.TicketKey, it.Own)
	}
	writeJSON(w, http.StatusOK, out)
}

// GetRepoPull implements gen.ServerInterface.
func (s *Server) GetRepoPull(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	v, err := s.opt.Pulls.Pull(r.Context(), id, number)
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	out := gen.PullDetail{RepoId: v.Repo.ID, RepoName: v.Repo.Name, Provider: gen.PullDetailProvider(v.Repo.Provider),
		Pull: toPullItem(v.Pull, v.TicketKey, v.Own), Body: optStr(v.Pull.Body), Login: optStr(v.Pull.Login),
		Files: make([]gen.FileChange, len(v.Files)), FilesError: optStr(v.FilesErr), TicketKey: optStr(v.TicketKey), Own: v.Own}
	if t := v.Ticket; t != nil {
		st := gen.TicketState(t.State)
		out.TicketState = &st
		if t.Kind == domain.KindReview {
			out.ReviewedSha = optStr(t.HeadSHA)
		}
		if t.AfterApprove != "" {
			aa := gen.PullDetailAfterApprove(t.AfterApprove)
			out.AfterApprove = &aa
		}
	}
	reviews := make([]gen.PullReviewRef, len(v.Reviews))
	for i, t := range v.Reviews {
		reviews[i] = toPullReviewRef(t)
	}
	out.Reviews = &reviews
	if v.Drafts != nil {
		ds := toReviewDrafts(v.Drafts)
		out.Drafts = &ds
	}
	for i, f := range v.Files {
		out.Files[i] = gen.FileChange{Path: f.Path, Add: f.Add, Del: f.Del, Diff: f.Diff}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListPullThreads implements gen.ServerInterface.
func (s *Server) ListPullThreads(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	ts, err := s.opt.Pulls.PullThreads(r.Context(), id, number)
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	out := make([]gen.PullThread, len(ts))
	for i, t := range ts {
		out[i] = toPullThread(t.PRThread)
		if t.Sent || t.Replied {
			sent, replied := t.Sent, t.Replied
			out[i].Sent, out[i].Replied = &sent, &replied
		}
	}
	writeJSON(w, http.StatusOK, out)
}

func derefInt(p *int) int {
	if p == nil {
		return 0
	}
	return *p
}

func derefStr(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

// AddPullComment implements gen.ServerInterface.
func (s *Server) AddPullComment(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	var req gen.NewPullComment
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c := domain.NewPRComment{Body: req.Body, Path: derefStr(req.Path), Line: derefInt(req.Line), OldLine: derefInt(req.OldLine),
		StartLine: derefInt(req.StartLine), HeadSHA: derefStr(req.HeadSha)}
	th, err := s.opt.Pulls.AddPullComment(r.Context(), id, number, c, origin(r))
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toPullThread(th))
}

// ReplyPullThread implements gen.ServerInterface.
func (s *Server) ReplyPullThread(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	var req gen.ReplyPullThreadJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Pulls.ReplyPullThread(r.Context(), id, number, req.ThreadId, req.Body, origin(r))
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toPullComment(c))
}

// EditPullComment implements gen.ServerInterface.
func (s *Server) EditPullComment(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	var req gen.EditPullCommentJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Pulls.EditPullComment(r.Context(), id, number, req.CommentId, req.Body, origin(r))
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toPullComment(c))
}

// DeletePullComment implements gen.ServerInterface.
func (s *Server) DeletePullComment(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber, p gen.DeletePullCommentParams) {
	if !s.pullsReady(w) {
		return
	}
	if err := s.opt.Pulls.DeletePullComment(r.Context(), id, number, p.CommentId, origin(r)); err != nil {
		s.pullsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ResolvePullThread implements gen.ServerInterface.
func (s *Server) ResolvePullThread(w http.ResponseWriter, r *http.Request, id gen.RepoID, number gen.PullNumber) {
	if !s.pullsReady(w) {
		return
	}
	var req gen.ResolvePullThreadJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Pulls.ResolvePullThread(r.Context(), id, number, req.ThreadId, req.Resolved, origin(r)); err != nil {
		s.pullsError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AddressPullComments implements gen.ServerInterface.
func (s *Server) AddressPullComments(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.pullsReady(w) {
		return
	}
	var req gen.AddressPullCommentsJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var ids []string
	if req.ThreadIds != nil {
		ids = *req.ThreadIds
	}
	t, err := s.opt.Pulls.AddressThreads(r.Context(), key, ids, origin(r))
	if err != nil {
		s.pullsError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusOK, t)
}
