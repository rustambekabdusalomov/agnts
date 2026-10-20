package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

// CommitLinks reads the commits linked to tickets by number.
type CommitLinks interface {
	TicketByKey(ctx context.Context, key string) (domain.Ticket, error)
	CommitLinksOfTicket(ctx context.Context, ticketID int64, limit, offset int) ([]domain.CommitLink, int, error)
	TicketsOfCommits(ctx context.Context, repoID int64, shas []string) (map[string][]domain.LinkedTicket, error)
}

// ListTicketLinkedCommits implements gen.ServerInterface.
func (s *Server) ListTicketLinkedCommits(w http.ResponseWriter, r *http.Request, key gen.TicketKey, params gen.ListTicketLinkedCommitsParams) {
	if s.opt.CommitLinks == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "commit links are not available")
		return
	}
	limit, offset := 20, 0
	if params.Limit != nil {
		limit = *params.Limit
	}
	if params.Offset != nil {
		offset = *params.Offset
	}
	if limit < 1 || limit > 100 || offset < 0 {
		writeError(w, http.StatusBadRequest, "bad_request", "limit is 1 to 100, offset 0 or more")
		return
	}
	t, err := s.opt.CommitLinks.TicketByKey(r.Context(), key)
	if errors.Is(err, domain.ErrNotFound) {
		writeError(w, http.StatusNotFound, "not_found", "no such ticket")
		return
	}
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	links, total, err := s.opt.CommitLinks.CommitLinksOfTicket(r.Context(), t.ID, limit, offset)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := gen.LinkedCommits{Total: total, Commits: make([]gen.LinkedCommit, len(links))}
	for i, l := range links {
		c := gen.LinkedCommit{Sha: l.SHA, ShortSha: l.SHA[:min(len(l.SHA), 8)], Subject: l.Subject, Author: l.Author, Branch: l.Branch,
			RepoId: l.RepoID, Repo: l.RepoName, Url: l.URL, CommittedAt: l.CommittedAt, MatchedOn: make([]gen.LinkedCommitMatchedOn, len(l.MatchedOn))}
		if l.AuthorLogin != "" {
			c.AuthorLogin = ptr(l.AuthorLogin)
		}
		for j, on := range l.MatchedOn {
			c.MatchedOn[j] = gen.LinkedCommitMatchedOn(on)
		}
		out.Commits[i] = c
	}
	writeJSON(w, http.StatusOK, out)
}

// commitTickets reads the tickets a repository's commits are linked to;
// nil when commit links are off or the read fails (the commits still
// show).
func (s *Server) commitTickets(ctx context.Context, repoID int64, shas []string) map[string][]domain.LinkedTicket {
	if s.opt.CommitLinks == nil || len(shas) == 0 {
		return nil
	}
	m, err := s.opt.CommitLinks.TicketsOfCommits(ctx, repoID, shas)
	if err != nil {
		s.opt.Log.Warn("read commit links", "repo", repoID, "err", err)
		return nil
	}
	return m
}

// toCommitTickets returns a commit's linked tickets for the API, and the
// key the commit's ticketKey shows: the first linked ticket's, else the
// one read from the message.
func toCommitTickets(linked []domain.LinkedTicket, fromMessage *string) (*[]gen.CommitTicket, *string) {
	if len(linked) == 0 {
		return nil, fromMessage
	}
	out := make([]gen.CommitTicket, len(linked))
	for i, t := range linked {
		out[i] = gen.CommitTicket{Key: t.Key, Title: t.Title, State: gen.TicketState(t.State)}
		if t.Number != "" {
			out[i].Number = ptr(t.Number)
		}
	}
	return &out, ptr(linked[0].Key)
}
