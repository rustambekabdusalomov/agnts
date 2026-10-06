package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Rules is what the Rules page reads and changes.
type Rules interface {
	ListRules(ctx context.Context) ([]domain.Rule, error)
	Rule(ctx context.Context, id int64) (domain.Rule, error)
	CreateRule(ctx context.Context, in orchestrator.RuleInput, origin domain.Origin) (domain.Rule, error)
	UpdateRule(ctx context.Context, id int64, in orchestrator.RuleInput, origin domain.Origin) (domain.Rule, error)
	AnswerRule(ctx context.Context, id int64, answers []orchestrator.RuleAnswer, origin domain.Origin) (domain.Rule, error)
	AcceptRule(ctx context.Context, id int64, origin domain.Origin) (domain.Rule, error)
	ReviewRule(ctx context.Context, id int64, origin domain.Origin) (domain.Rule, error)
	DeleteRule(ctx context.Context, id int64, origin domain.Origin) error
}

func (s *Server) rulesReady(w http.ResponseWriter) bool {
	if s.opt.Rules == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

func (s *Server) writeRuleError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such rule")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func (s *Server) ruleAction(w http.ResponseWriter, r *http.Request, status int, f func(context.Context) (domain.Rule, error)) {
	if !s.rulesReady(w) {
		return
	}
	x, err := f(r.Context())
	if err != nil {
		s.writeRuleError(w, r, err)
		return
	}
	writeJSON(w, status, toRule(x))
}

func ruleInput(r *http.Request) (orchestrator.RuleInput, error) {
	var req gen.RuleInput
	if err := decodeJSON(r, &req); err != nil {
		return orchestrator.RuleInput{}, err
	}
	in := orchestrator.RuleInput{Title: req.Title, Body: req.Body, RepoID: req.RepoId, Enabled: true}
	if req.Enabled != nil {
		in.Enabled = *req.Enabled
	}
	return in, nil
}

// ListRules implements gen.ServerInterface.
func (s *Server) ListRules(w http.ResponseWriter, r *http.Request) {
	if !s.rulesReady(w) {
		return
	}
	rs, err := s.opt.Rules.ListRules(r.Context())
	if err != nil {
		s.writeRuleError(w, r, err)
		return
	}
	out := make([]gen.Rule, len(rs))
	for i, x := range rs {
		out[i] = toRule(x)
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateRule implements gen.ServerInterface.
func (s *Server) CreateRule(w http.ResponseWriter, r *http.Request) {
	in, err := ruleInput(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ruleAction(w, r, http.StatusCreated, func(ctx context.Context) (domain.Rule, error) {
		return s.opt.Rules.CreateRule(ctx, in, origin(r))
	})
}

// GetRule implements gen.ServerInterface.
func (s *Server) GetRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	s.ruleAction(w, r, http.StatusOK, func(ctx context.Context) (domain.Rule, error) { return s.opt.Rules.Rule(ctx, id) })
}

// UpdateRule implements gen.ServerInterface.
func (s *Server) UpdateRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	in, err := ruleInput(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ruleAction(w, r, http.StatusOK, func(ctx context.Context) (domain.Rule, error) {
		return s.opt.Rules.UpdateRule(ctx, id, in, origin(r))
	})
}

// DeleteRule implements gen.ServerInterface.
func (s *Server) DeleteRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	if !s.rulesReady(w) {
		return
	}
	if err := s.opt.Rules.DeleteRule(r.Context(), id, origin(r)); err != nil {
		s.writeRuleError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AnswerRule implements gen.ServerInterface.
func (s *Server) AnswerRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	var req gen.RuleAnswers
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	as := make([]orchestrator.RuleAnswer, len(req.Answers))
	for i, a := range req.Answers {
		as[i] = orchestrator.RuleAnswer{Index: a.Index, Answer: a.Answer}
		if a.Note != nil {
			as[i].Note = *a.Note
		}
	}
	s.ruleAction(w, r, http.StatusOK, func(ctx context.Context) (domain.Rule, error) {
		return s.opt.Rules.AnswerRule(ctx, id, as, origin(r))
	})
}

// AcceptRule implements gen.ServerInterface.
func (s *Server) AcceptRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	s.ruleAction(w, r, http.StatusOK, func(ctx context.Context) (domain.Rule, error) {
		return s.opt.Rules.AcceptRule(ctx, id, origin(r))
	})
}

// ReviewRule implements gen.ServerInterface.
func (s *Server) ReviewRule(w http.ResponseWriter, r *http.Request, id gen.RuleID) {
	s.ruleAction(w, r, http.StatusOK, func(ctx context.Context) (domain.Rule, error) {
		return s.opt.Rules.ReviewRule(ctx, id, origin(r))
	})
}

func toRule(x domain.Rule) gen.Rule {
	out := gen.Rule{
		Id: x.ID, RepoId: x.RepoID, Title: x.Title, Body: x.Body, Enabled: x.Enabled, Status: gen.RuleStatus(x.Status),
		Interpretation: x.Interpretation, Clarified: x.Clarified, Text: x.Text(), Rounds: x.Rounds, Error: x.Error,
		AnalyzedAt: x.AnalyzedAt, CreatedAt: x.CreatedAt, UpdatedAt: x.UpdatedAt,
		Questions: make([]gen.RuleQuestion, len(x.Questions)),
	}
	if x.RepoName != "" {
		out.RepoName = &x.RepoName
	}
	for i, q := range x.Questions {
		out.Questions[i] = gen.RuleQuestion{Index: i, Text: q.Text, Options: q.Options, Round: q.Round}
		if out.Questions[i].Options == nil {
			out.Questions[i].Options = []string{}
		}
		if q.Answer != "" {
			out.Questions[i].Answer = &q.Answer
		}
		if q.Note != "" {
			out.Questions[i].Note = &q.Note
		}
	}
	return out
}
