package httpapi

import (
	"context"
	"net/http"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// RelationTickets is the ordering part of the ticket use cases.
type RelationTickets interface {
	ListRelations(ctx context.Context, key string) (orchestrator.Relations, error)
	AddRelation(ctx context.Context, key, other string, typ domain.RelationType, origin domain.Origin) (domain.Relation, error)
	DecideRelation(ctx context.Context, key string, id int64, accept bool, origin domain.Origin) (domain.Relation, error)
	MarkMergedByHand(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
}

func toBlockers(bs []domain.Blocker) []gen.Blocker {
	out := make([]gen.Blocker, len(bs))
	for i, b := range bs {
		out[i] = gen.Blocker{Key: b.Key, Title: b.Title, State: gen.TicketState(b.State), Type: gen.RelationType(b.Type)}
	}
	return out
}

// toRelation describes r as seen from ticket key.
func toRelation(key string, r orchestrator.RelationRow) gen.Relation {
	dir := gen.RelationDirectionConflicts
	if r.Type == domain.RelDependsOn {
		dir = gen.RelationDirectionWaitedBy
		if r.TicketKey == key {
			dir = gen.RelationDirectionWaitsFor
		}
	}
	files := r.Files
	if files == nil {
		files = []string{}
	}
	return gen.Relation{
		Id: r.ID, Type: gen.RelationType(r.Type), Direction: dir, Source: gen.RelationSource(r.Source), Status: gen.RelationStatus(r.Status),
		Confidence: r.Confidence, Reason: r.Reason, Basis: r.Basis, Files: files,
		Other:       gen.RelatedTicket{Key: r.Other(key), Title: r.OtherTitle, State: gen.TicketState(r.OtherState), Landed: r.OtherReleases},
		ConfirmedAt: r.ConfirmedAt, DecidedAt: r.DecidedAt, CreatedAt: r.CreatedAt,
	}
}

func toRelations(key string, rs orchestrator.Relations) gen.Relations {
	out := gen.Relations{Items: make([]gen.Relation, len(rs.All)), BlockedBy: toBlockers(rs.Blockers)}
	for i, r := range rs.All {
		out.Items[i] = toRelation(key, r)
	}
	return out
}

// ListRelations implements gen.ServerInterface.
func (s *Server) ListRelations(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	rs, err := s.opt.Tickets.ListRelations(r.Context(), key)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toRelations(key, rs))
}

// AddRelation implements gen.ServerInterface.
func (s *Server) AddRelation(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.RelationInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Type.Valid() || strings.TrimSpace(req.OtherKey) == "" {
		writeError(w, http.StatusBadRequest, "bad_request", "otherKey and a type of depends_on or conflicts are required")
		return
	}
	rel, err := s.opt.Tickets.AddRelation(r.Context(), key, strings.ToUpper(strings.TrimSpace(req.OtherKey)), domain.RelationType(req.Type), origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeRelation(w, r, key, http.StatusCreated, rel)
}

// AcceptRelation implements gen.ServerInterface.
func (s *Server) AcceptRelation(w http.ResponseWriter, r *http.Request, key gen.TicketKey, id gen.RelationID) {
	s.decideRelation(w, r, key, id, true)
}

// DismissRelation implements gen.ServerInterface.
func (s *Server) DismissRelation(w http.ResponseWriter, r *http.Request, key gen.TicketKey, id gen.RelationID) {
	s.decideRelation(w, r, key, id, false)
}

func (s *Server) decideRelation(w http.ResponseWriter, r *http.Request, key string, id int64, accept bool) {
	rel, err := s.opt.Tickets.DecideRelation(r.Context(), key, id, accept, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeRelation(w, r, key, http.StatusOK, rel)
}

// writeRelation answers with the relation as the ticket's page shows it.
func (s *Server) writeRelation(w http.ResponseWriter, r *http.Request, key string, status int, rel domain.Relation) {
	rs, err := s.opt.Tickets.ListRelations(r.Context(), key)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	for _, x := range rs.All {
		if x.ID == rel.ID {
			writeJSON(w, status, toRelation(key, x))
			return
		}
	}
	writeJSON(w, status, toRelation(key, orchestrator.RelationRow{Relation: rel}))
}

// MarkTicketMerged implements gen.ServerInterface.
func (s *Server) MarkTicketMerged(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.MarkMergedByHand(ctx, key, origin(r))
	})
}

// toFootprint maps an analysis footprint, or nil.
func toFootprint(f *domain.Footprint) *gen.Footprint {
	if f == nil {
		return nil
	}
	c := f.Clean()
	out := gen.Footprint{Files: c.Files}
	if out.Files == nil {
		out.Files = []string{}
	}
	if len(c.Modules) > 0 {
		out.Modules = &c.Modules
	}
	if len(c.Provides) > 0 {
		out.Provides = &c.Provides
	}
	if len(c.Consumes) > 0 {
		out.Consumes = &c.Consumes
	}
	if c.Migrations {
		m := true
		out.Migrations = &m
	}
	return &out
}
