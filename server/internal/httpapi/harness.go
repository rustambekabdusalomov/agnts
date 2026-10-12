package httpapi

import (
	"context"
	"encoding/json"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/toolchain"
)

// via converts between a domain type and the API type with the same JSON
// shape (the harness types share their field names with the spec).
func via[T any](v any) T {
	var out T
	b, err := json.Marshal(v)
	if err == nil {
		_ = json.Unmarshal(b, &out)
	}
	return out
}

func mustJSON(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}

func toRepoHarness(x domain.Repository) *gen.RepoHarness {
	h := x.Harness
	out := gen.RepoHarness{
		Acceptance: ptr(h.Acceptance), EditChecksOff: ptr(h.EditChecksOff), SecretAllow: ptr(nonNil(h.SecretAllow)),
		Coverage: ptr(via[gen.CoverageConfig](h.Coverage)),
	}
	if h.GuardProfile != "" {
		p := gen.RepoHarnessGuardProfile(h.GuardProfile)
		out.GuardProfile = &p
	}
	if h.EditChecks != nil {
		out.EditChecks = ptr(via[[]gen.EditCheck](h.EditChecks))
	}
	derived := via[[]gen.EditCheck](toolchain.EditChecks(x.Toolchains))
	if derived == nil {
		derived = []gen.EditCheck{}
	}
	out.DerivedEditChecks = &derived
	cmd, report := toolchain.Coverage(x.Toolchains, x.TestCmd)
	out.DerivedCoverage = &struct {
		Command *string `json:"command,omitempty"`
		Report  *string `json:"report,omitempty"`
	}{Command: &cmd, Report: &report}
	if h.AgentConfig != nil {
		out.AgentConfig = ptr(via[gen.AgentConfigScan](h.AgentConfig))
	}
	return &out
}

// SaveRepoHarness implements gen.ServerInterface.
func (s *Server) SaveRepoHarness(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.adminReady(w) {
		return
	}
	var in gen.RepoHarnessInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	h := domain.RepoHarness{}
	if in.GuardProfile != nil {
		h.GuardProfile = string(*in.GuardProfile)
	}
	if in.SecretAllow != nil {
		h.SecretAllow = *in.SecretAllow
	}
	if in.EditChecks != nil {
		h.EditChecks = via[[]domain.EditCheck](*in.EditChecks)
		if h.EditChecks == nil {
			h.EditChecks = []domain.EditCheck{}
		}
	}
	if in.EditChecksOff != nil {
		h.EditChecksOff = *in.EditChecksOff
	}
	if in.Coverage != nil {
		h.Coverage = via[domain.CoverageConfig](*in.Coverage)
	}
	if in.Acceptance != nil {
		h.Acceptance = *in.Acceptance
	}
	x, err := s.opt.Admin.Repos.SetHarness(r.Context(), id, h, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "no such repository")
		return
	}
	writeJSON(w, http.StatusOK, toRepo(x))
}

// AcknowledgeSecrets implements gen.ServerInterface.
func (s *Server) AcknowledgeSecrets(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.AcknowledgeSecrets(ctx, key, origin(r))
	})
}

// ListStarterPacks implements gen.ServerInterface.
func (s *Server) ListStarterPacks(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.rulesReady(w) {
		return
	}
	offers, err := s.opt.Rules.StarterPacks(r.Context(), id)
	if err != nil {
		s.writeRuleError(w, r, err)
		return
	}
	out := make([]gen.StarterPack, len(offers))
	for i, o := range offers {
		out[i] = gen.StarterPack{Pack: o.Pack, Name: o.Name, Rules: o.Rules, Offered: o.Offered}
	}
	writeJSON(w, http.StatusOK, out)
}

// OfferStarterRules implements gen.ServerInterface.
func (s *Server) OfferStarterRules(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.rulesReady(w) {
		return
	}
	var in struct {
		Pack string `json:"pack"`
	}
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	rs, err := s.opt.Rules.OfferStarterRules(r.Context(), id, in.Pack, origin(r))
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

// TryEnforce implements gen.ServerInterface.
func (s *Server) TryEnforce(w http.ResponseWriter, r *http.Request) {
	if !s.rulesReady(w) {
		return
	}
	var in gen.TryEnforceInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	res, err := s.opt.Rules.TryEnforce(r.Context(), via[domain.RuleEnforce](in.Enforce), in.RepoId)
	if err != nil {
		s.writeRuleError(w, r, err)
		return
	}
	out := gen.TryEnforceResult{Checked: res.Checked, Tickets: nonNil(res.Tickets), Hits: make([]struct {
		Line   *int   `json:"line,omitempty"`
		Path   string `json:"path"`
		Text   string `json:"text"`
		Ticket string `json:"ticket"`
	}, len(res.Hits))}
	for i, h := range res.Hits {
		out.Hits[i].Ticket, out.Hits[i].Path, out.Hits[i].Text = h.Title, h.Path, h.Text
		if h.Line > 0 {
			out.Hits[i].Line = ptr(h.Line)
		}
	}
	if res.Note != "" {
		out.Note = &res.Note
	}
	writeJSON(w, http.StatusOK, out)
}

// harnessRules is what the rules API needs from the harness.
type harnessRules interface {
	StarterPacks(ctx context.Context, repoID int64) ([]orchestrator.StarterOffer, error)
	OfferStarterRules(ctx context.Context, repoID int64, pack string, origin domain.Origin) ([]domain.Rule, error)
	TryEnforce(ctx context.Context, e domain.RuleEnforce, repoID *int64) (orchestrator.TryResult, error)
}
