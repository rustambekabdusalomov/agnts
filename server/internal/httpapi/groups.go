package httpapi

import (
	"context"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// RepoGroups are the workspace's repository groups (the orchestrator).
type RepoGroups interface {
	Groups(ctx context.Context) ([]domain.RepoGroup, error)
	Group(ctx context.Context, id int64) (orchestrator.GroupView, error)
	SaveGroup(ctx context.Context, id int64, in orchestrator.GroupInput, origin domain.Origin) (orchestrator.GroupView, error)
	DeleteGroup(ctx context.Context, id int64, origin domain.Origin) error
	SetRepos(ctx context.Context, key string, c domain.RepoChoice, origin domain.Origin) (domain.Ticket, error)
}

func (s *Server) groups(w http.ResponseWriter) (RepoGroups, bool) {
	g, ok := s.opt.Tickets.(RepoGroups)
	if !ok {
		writeError(w, http.StatusNotImplemented, "not_implemented", "repository groups are not available")
	}
	return g, ok
}

// ListRepoGroups implements gen.ServerInterface.
func (s *Server) ListRepoGroups(w http.ResponseWriter, r *http.Request) {
	g, ok := s.groups(w)
	if !ok {
		return
	}
	list, err := g.Groups(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.RepoGroup, len(list))
	for i, x := range list {
		out[i] = toRepoGroup(orchestrator.GroupView{RepoGroup: x})
	}
	writeJSON(w, http.StatusOK, out)
}

// GetRepoGroup implements gen.ServerInterface.
func (s *Server) GetRepoGroup(w http.ResponseWriter, r *http.Request, id int64) {
	g, ok := s.groups(w)
	if !ok {
		return
	}
	v, err := g.Group(r.Context(), id)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toRepoGroup(v))
}

// CreateRepoGroup implements gen.ServerInterface.
func (s *Server) CreateRepoGroup(w http.ResponseWriter, r *http.Request) {
	s.saveRepoGroup(w, r, 0, http.StatusCreated)
}

// UpdateRepoGroup implements gen.ServerInterface.
func (s *Server) UpdateRepoGroup(w http.ResponseWriter, r *http.Request, id int64) {
	s.saveRepoGroup(w, r, id, http.StatusOK)
}

func (s *Server) saveRepoGroup(w http.ResponseWriter, r *http.Request, id int64, status int) {
	g, ok := s.groups(w)
	if !ok {
		return
	}
	var req gen.RepoGroupInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := orchestrator.GroupInput{Name: req.Name}
	if req.Description != nil {
		in.Description = *req.Description
	}
	if req.Instructions != nil {
		in.Instructions = *req.Instructions
	}
	if req.TaskPrefix != nil {
		in.TaskPrefix = *req.TaskPrefix
	}
	if req.BranchTemplate != nil {
		in.BranchTemplate = *req.BranchTemplate
	}
	if req.CommitTemplate != nil {
		in.CommitTemplate = *req.CommitTemplate
	}
	for _, m := range req.Members {
		x := orchestrator.GroupMemberInput{RepoID: m.RepoId}
		if m.Role != nil {
			x.Role = *m.Role
		}
		in.Members = append(in.Members, x)
	}
	v, err := g.SaveGroup(r.Context(), id, in, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, status, toRepoGroup(v))
}

// DeleteRepoGroup implements gen.ServerInterface.
func (s *Server) DeleteRepoGroup(w http.ResponseWriter, r *http.Request, id int64) {
	g, ok := s.groups(w)
	if !ok {
		return
	}
	if err := g.DeleteGroup(r.Context(), id, origin(r)); err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// SetTicketRepos implements gen.ServerInterface.
func (s *Server) SetTicketRepos(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	g, ok := s.groups(w)
	if !ok {
		return
	}
	var req gen.TicketReposInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var c domain.RepoChoice
	if req.RepoIds != nil {
		c.RepoIDs = *req.RepoIds
	}
	if req.GroupId != nil {
		c.GroupID = *req.GroupId
	}
	if c.Empty() {
		writeError(w, http.StatusBadRequest, "bad_request", "give repoIds or groupId")
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return g.SetRepos(ctx, key, c, origin(r))
	})
}

func toRepoGroup(v orchestrator.GroupView) gen.RepoGroup {
	out := gen.RepoGroup{Id: v.ID, Name: v.Name, Description: v.Description, Instructions: v.Instructions, TaskPrefix: v.TaskPrefix,
		BranchTemplate: v.BranchTemplate, CommitTemplate: v.CommitTemplate,
		Members: make([]gen.RepoGroupMember, len(v.Members)), Warnings: nonNil(v.Warnings), CreatedAt: v.CreatedAt, UpdatedAt: v.UpdatedAt}
	for i, m := range v.Members {
		out.Members[i] = gen.RepoGroupMember{RepoId: m.RepoID, RepoName: m.RepoName, Role: m.Role, Archived: m.Archived}
	}
	return out
}

func toGroupRefs(gs []domain.RepoGroup) []gen.RepoGroupRef {
	out := make([]gen.RepoGroupRef, len(gs))
	for i, g := range gs {
		out[i] = gen.RepoGroupRef{Id: g.ID, Name: g.Name}
	}
	return out
}

// toTicketRepos is a ticket's repositories for the API: every one, the
// primary first, with the primary's values taken from the ticket.
func toTicketRepos(t domain.Ticket) []gen.TicketRepoState {
	ids := t.RepoIDs()
	out := make([]gen.TicketRepoState, 0, len(ids))
	for _, id := range ids {
		r, ok := t.RepoState(id)
		if !ok {
			continue
		}
		st := r.State
		if st == "" {
			st = domain.RepoPending
		}
		x := gen.TicketRepoState{RepoId: r.RepoID, RepoName: r.RepoName, Role: r.Role, Folder: r.Folder, Branch: r.Branch,
			HeadSha: r.HeadSHA, PrNumber: r.PRNumber, PrUrl: r.PRURL, CiFixes: r.CIFixes, State: gen.TicketRepoStateState(st),
			MergedAt: r.MergedAt, ClosedAt: r.ClosedAt, Files: r.Files}
		if r.PushError != "" {
			x.PushError = ptr(r.PushError)
		}
		if r.Archived {
			x.Archived = ptr(true)
		}
		out = append(out, x)
	}
	return out
}
