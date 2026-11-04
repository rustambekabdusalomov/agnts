package httpapi

import (
	"cmp"
	"context"
	"errors"
	"net/http"
	"time"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Security is what the Security pages change (the orchestrator).
type Security interface {
	ScanRepository(ctx context.Context, repoID int64, origin domain.Origin, by *int64) (domain.SecurityScan, bool, error)
	CancelScan(ctx context.Context, id int64) (domain.SecurityScan, error)
	CreateSecurityTicket(ctx context.Context, in orchestrator.SecurityFixInput, origin domain.Origin) (domain.Ticket, error)
	DismissFindings(ctx context.Context, ids []int64, reason, note string, by *int64, origin domain.Origin) ([]domain.SecurityFinding, error)
	ReopenFinding(ctx context.Context, id int64, origin domain.Origin) (domain.SecurityFinding, error)
	SetSecuritySettings(ctx context.Context, repoID int64, set domain.SecuritySettings, origin domain.Origin) (domain.SecuritySettings, error)
}

// SecurityReads is what the Security pages read (postgres.Security).
type SecurityReads interface {
	SecurityScan(ctx context.Context, id int64) (domain.SecurityScan, error)
	SecurityScans(ctx context.Context, repoID int64, limit int) ([]domain.SecurityScan, error)
	SecurityFindings(ctx context.Context, flt domain.SecFindingFilter) ([]domain.SecurityFinding, error)
	SecurityFinding(ctx context.Context, id int64) (domain.SecurityFinding, error)
	FindingsByTicket(ctx context.Context, key string) ([]domain.SecurityFinding, error)
	SecuritySummaries(ctx context.Context) ([]postgres.SecuritySummary, error)
	SecuritySettings(ctx context.Context, repoID int64) (domain.SecuritySettings, error)
}

var (
	_ Security      = (*orchestrator.Orchestrator)(nil)
	_ SecurityReads = (*postgres.Security)(nil)
)

func (s *Server) securityReady(w http.ResponseWriter) bool {
	if s.opt.Security == nil || s.opt.SecurityReads == nil {
		writeError(w, http.StatusNotImplemented, "not_implemented", "security testing is not available")
		return false
	}
	return true
}

func (s *Server) writeSecurityError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such repository, scan or finding")
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func callerID(r *http.Request) *int64 {
	if u, ok := userFrom(r.Context()); ok && u.ID > 0 {
		id := u.ID
		return &id
	}
	return nil
}

func severityCounts(m map[domain.SecSeverity]int) gen.SecSeverityCounts {
	return gen.SecSeverityCounts{Critical: m[domain.SecCritical], High: m[domain.SecHigh], Medium: m[domain.SecMedium],
		Low: m[domain.SecLow], Info: m[domain.SecInfo]}
}

func toSecurityScan(x domain.SecurityScan, withRejected bool) gen.SecurityScan {
	out := gen.SecurityScan{Id: x.ID, RepoId: x.RepoID, Repo: x.RepoName, Trigger: gen.SecurityScanTrigger(x.Trigger),
		Status: gen.SecurityScanStatus(x.Status), Commit: x.Commit, Tools: []gen.SecToolRun{}, Agent: x.Ran.Agent,
		History: x.Ran.History, Commits: x.Ran.Commits, New: x.Counts.New, Seen: x.Counts.Seen, Fixed: x.Counts.Fixed,
		Reopened: x.Counts.Reopened, Unchecked: x.Counts.Unchecked, RejectedCount: max(x.Counts.Rejected, len(x.Rejected)),
		Open: severityCounts(x.Counts.Open), Summary: x.Summary, Error: x.Error, Provider: x.Provider,
		CreatedAt: x.CreatedAt, StartedAt: x.StartedAt, FinishedAt: x.FinishedAt}
	if len(x.Scope.FindingIDs) > 0 {
		ids := x.Scope.FindingIDs
		out.FindingIds = &ids
	}
	if x.Scope.FullHistory {
		t := true
		out.FullHistory = &t
	}
	if len(x.DBVersions) > 0 {
		v := x.DBVersions
		out.DbVersions = &v
	}
	out.Tools = toSecToolRuns(x.Ran.Tools)
	if withRejected {
		rej := toSecRejected(x.Rejected)
		out.Rejected = &rej
	}
	return out
}

// toSecToolRuns lists how each scanner's run ended, in a fixed order.
func toSecToolRuns(tools map[string]domain.SecToolRun) []gen.SecToolRun {
	out := []gen.SecToolRun{}
	for _, tool := range domain.SecTools {
		t, ok := tools[tool]
		if !ok {
			continue
		}
		g := gen.SecToolRun{Tool: tool, Status: gen.SecToolRunStatus(t.Status), Seconds: t.Seconds, Hits: t.Hits}
		if t.Error != "" {
			e := t.Error
			g.Error = &e
		}
		out = append(out, g)
	}
	return out
}

func toSecRejected(xs []domain.SecRejected) []gen.SecRejectedHit {
	rej := make([]gen.SecRejectedHit, 0, len(xs))
	for _, r := range xs {
		h := gen.SecRejectedHit{Hit: r.Hit, Reason: r.Reason, Tool: optStr(r.Tool), Rule: optStr(r.Rule), File: optStr(r.File)}
		if r.Line > 0 {
			l := r.Line
			h.Line = &l
		}
		rej = append(rej, h)
	}
	return rej
}

// toSecurityCheck is a ticket's security check for the API.
func toSecurityCheck(c domain.SecurityCheck) gen.SecurityCheck {
	out := gen.SecurityCheck{RunId: c.RunID, Revision: c.Revision, Summary: c.Summary, Files: c.Files, Tools: toSecToolRuns(c.Tools),
		Issues: make([]gen.SecCheckIssue, 0, len(c.Issues)), Agent: gen.SecurityCheckAgent(cmp.Or(c.Agent, domain.SecAgentSkipped)), CreatedAt: c.CreatedAt}
	for _, i := range c.Issues {
		g := gen.SecCheckIssue{Severity: gen.SecSeverity(i.Severity), Title: i.Title, Feedback: i.FeedbackText(), File: optStr(i.File),
			Cwe: optStr(i.CWE), Tool: optStr(i.Tool), Rule: optStr(i.Rule), Advice: optStr(i.Advice), SecretMask: optStr(i.SecretMask)}
		if i.Line > 0 {
			l := i.Line
			g.Line = &l
		}
		out.Issues = append(out.Issues, g)
	}
	if len(c.Rejected) > 0 {
		rej := toSecRejected(c.Rejected)
		out.Rejected = &rej
	}
	return out
}

func strSlice(xs []string) []string {
	if xs == nil {
		return []string{}
	}
	return xs
}

func (s *Server) toSecurityFinding(ctx context.Context, f domain.SecurityFinding) gen.SecurityFinding {
	d := f.Data
	out := gen.SecurityFinding{Id: f.ID, RepoId: f.RepoID, Repo: f.RepoName, Severity: gen.SecSeverity(f.Severity),
		Category: f.Category, Source: gen.SecurityFindingSource(f.Source), Status: gen.SecFindingStatus(f.Status), Title: d.Title,
		Confidence: gen.SecurityFindingConfidence(cmpOr(string(d.Confidence), string(domain.SecPossible))), Rules: strSlice(d.Rules),
		References: strSlice(d.References), FirstSeen: f.FirstSeen, LastSeen: f.LastSeen, LastChecked: f.LastChecked,
		TicketKey: f.TicketKey, DismissReason: f.DismissReason, DismissNote: f.DismissNote,
		Symbol: optStr(f.Symbol), Cwe: optStr(d.CWE), Owasp: optStr(d.OWASP), Tool: optStr(d.Tool), Evidence: optStr(d.Evidence),
		Impact: optStr(d.Impact), FixExplanation: optStr(d.Fix.Explanation), FixPatch: optStr(d.Fix.Patch), Package: optStr(d.Package),
		Version: optStr(d.Version), Ecosystem: optStr(d.Ecosystem), FixedIn: optStr(d.FixedIn), Cvss: optStr(d.CVSS),
		SecretMask: optStr(d.SecretMask), Commit: optStr(d.Commit), Note: optStr(d.Note)}
	out.Location.File, out.Location.Url = optStr(d.Location.File), optStr(d.Location.URL)
	if d.Location.Line > 0 {
		l := d.Location.Line
		out.Location.Line = &l
	}
	if len(d.Advisories) > 0 {
		a := d.Advisories
		out.Advisories = &a
	}
	if f.TicketKey != "" && s.opt.Tickets != nil {
		if v, err := s.opt.Tickets.View(ctx, f.TicketKey); err == nil {
			st := gen.TicketState(v.Ticket.State)
			out.TicketState = &st
		}
	}
	return out
}

func cmpOr(a, b string) string {
	if a != "" {
		return a
	}
	return b
}

func (s *Server) writeFindings(w http.ResponseWriter, r *http.Request, fs []domain.SecurityFinding, err error) {
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	out := make([]gen.SecurityFinding, len(fs))
	for i, f := range fs {
		out[i] = s.toSecurityFinding(r.Context(), f)
	}
	writeJSON(w, http.StatusOK, out)
}

// GetSecuritySummary implements gen.ServerInterface.
func (s *Server) GetSecuritySummary(w http.ResponseWriter, r *http.Request) {
	if !s.securityReady(w) {
		return
	}
	sums, err := s.opt.SecurityReads.SecuritySummaries(r.Context())
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	out := make([]gen.SecurityRepoSummary, 0, len(sums))
	for _, x := range sums {
		g := gen.SecurityRepoSummary{RepoId: x.RepoID, Repo: x.RepoName, Open: severityCounts(x.Open)}
		if x.LastScanID != nil {
			if sc, err := s.opt.SecurityReads.SecurityScan(r.Context(), *x.LastScanID); err == nil {
				v := toSecurityScan(sc, false)
				g.LastScan = &v
			}
		}
		out = append(out, g)
	}
	writeJSON(w, http.StatusOK, out)
}

// ListSecurityScans implements gen.ServerInterface.
func (s *Server) ListSecurityScans(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.securityReady(w) {
		return
	}
	xs, err := s.opt.SecurityReads.SecurityScans(r.Context(), id, 50)
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	out := make([]gen.SecurityScan, len(xs))
	for i, x := range xs {
		out[i] = toSecurityScan(x, false)
	}
	writeJSON(w, http.StatusOK, out)
}

// StartSecurityScan implements gen.ServerInterface.
func (s *Server) StartSecurityScan(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.securityReady(w) {
		return
	}
	x, queued, err := s.opt.Security.ScanRepository(r.Context(), id, origin(r), callerID(r))
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"scan": toSecurityScan(x, false), "queued": queued})
}

// GetSecurityScan implements gen.ServerInterface.
func (s *Server) GetSecurityScan(w http.ResponseWriter, r *http.Request, id gen.SecurityScanID) {
	if !s.securityReady(w) {
		return
	}
	x, err := s.opt.SecurityReads.SecurityScan(r.Context(), id)
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSecurityScan(x, true))
}

// CancelSecurityScan implements gen.ServerInterface.
func (s *Server) CancelSecurityScan(w http.ResponseWriter, r *http.Request, id gen.SecurityScanID) {
	if !s.securityReady(w) {
		return
	}
	x, err := s.opt.Security.CancelScan(r.Context(), id)
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSecurityScan(x, true))
}

// ListSecurityFindings implements gen.ServerInterface.
func (s *Server) ListSecurityFindings(w http.ResponseWriter, r *http.Request, p gen.ListSecurityFindingsParams) {
	if !s.securityReady(w) {
		return
	}
	var q domain.SecFindingFilter
	if p.RepoId != nil {
		q.RepoID = *p.RepoId
	}
	if p.Status != nil {
		q.Status = domain.SecStatus(*p.Status)
	}
	if p.Severity != nil {
		q.Severity = domain.SecSeverity(*p.Severity)
	}
	if p.Active != nil {
		q.Active = *p.Active
	}
	fs, err := s.opt.SecurityReads.SecurityFindings(r.Context(), q)
	s.writeFindings(w, r, fs, err)
}

// GetSecurityFinding implements gen.ServerInterface.
func (s *Server) GetSecurityFinding(w http.ResponseWriter, r *http.Request, id gen.SecurityFindingID) {
	if !s.securityReady(w) {
		return
	}
	f, err := s.opt.SecurityReads.SecurityFinding(r.Context(), id)
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.toSecurityFinding(r.Context(), f))
}

// ReopenSecurityFinding implements gen.ServerInterface.
func (s *Server) ReopenSecurityFinding(w http.ResponseWriter, r *http.Request, id gen.SecurityFindingID) {
	if !s.securityReady(w) {
		return
	}
	f, err := s.opt.Security.ReopenFinding(r.Context(), id, origin(r))
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.toSecurityFinding(r.Context(), f))
}

// DismissSecurityFindings implements gen.ServerInterface.
func (s *Server) DismissSecurityFindings(w http.ResponseWriter, r *http.Request) {
	if !s.securityReady(w) {
		return
	}
	var req gen.DismissSecurityFindingsJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !domain.ValidDismissReason(string(req.Reason)) {
		writeError(w, http.StatusBadRequest, "bad_request", "reason must be false_positive, accepted_risk or wont_fix")
		return
	}
	note := ""
	if req.Note != nil {
		note = *req.Note
	}
	fs, err := s.opt.Security.DismissFindings(r.Context(), req.FindingIds, string(req.Reason), note, callerID(r), origin(r))
	s.writeFindings(w, r, fs, err)
}

// FixSecurityFindings implements gen.ServerInterface.
func (s *Server) FixSecurityFindings(w http.ResponseWriter, r *http.Request) {
	if !s.securityReady(w) {
		return
	}
	var req gen.FixSecurityFindingsJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	hold := req.Hold != nil && *req.Hold
	t, err := s.opt.Security.CreateSecurityTicket(r.Context(), orchestrator.SecurityFixInput{FindingIDs: req.FindingIds, Hold: hold}, origin(r))
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusOK, t)
}

// GetTicketSecurityFindings implements gen.ServerInterface.
func (s *Server) GetTicketSecurityFindings(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.securityReady(w) {
		return
	}
	fs, err := s.opt.SecurityReads.FindingsByTicket(r.Context(), key)
	s.writeFindings(w, r, fs, err)
}

func toSecuritySettings(repoID int64, x domain.SecuritySettings) gen.SecuritySettings {
	out := gen.SecuritySettings{Schedule: gen.SecuritySettingsSchedule(cmpOr(x.Schedule, "off")), Exclude: strSlice(x.Exclude),
		MinNotify: gen.SecSeverity(x.NotifyAt())}
	if next := x.NextScan(repoID, time.Now()); next != nil {
		out.NextAt = next
	}
	return out
}

// GetSecuritySettings implements gen.ServerInterface.
func (s *Server) GetSecuritySettings(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.securityReady(w) {
		return
	}
	set, err := s.opt.SecurityReads.SecuritySettings(r.Context(), id)
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSecuritySettings(id, set))
}

// SetSecuritySettings implements gen.ServerInterface.
func (s *Server) SetSecuritySettings(w http.ResponseWriter, r *http.Request, id gen.RepoID) {
	if !s.securityReady(w) {
		return
	}
	var req gen.SecuritySettings
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	set := domain.SecuritySettings{Schedule: string(req.Schedule), Exclude: req.Exclude, MinNotify: domain.SecSeverity(req.MinNotify)}
	saved, err := s.opt.Security.SetSecuritySettings(r.Context(), id, set, origin(r))
	if err != nil {
		s.writeSecurityError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toSecuritySettings(id, saved))
}
