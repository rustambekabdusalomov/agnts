package httpapi

import (
	"bufio"
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// RunHistory is the run history the Admin console reads: transcripts of
// every Claude Code and Codex invocation, and the audit log of who read
// them.
type RunHistory interface {
	ListTranscripts(ctx context.Context, f domain.TranscriptFilter) ([]domain.Transcript, error)
	TranscriptSummary(ctx context.Context, f domain.TranscriptFilter) (domain.TranscriptSummary, error)
	Transcript(ctx context.Context, id int64) (domain.Transcript, error)
	RunTranscripts(ctx context.Context, runID int64) ([]domain.Transcript, error)
	TranscriptBody(ctx context.Context, id int64) ([]byte, error)
	TranscriptPrompt(ctx context.Context, id int64) ([]byte, error)
	Audit(ctx context.Context, a domain.AdminAudit) error
	ListAudit(ctx context.Context, f postgres.AuditFilter) ([]domain.AdminAudit, error)
	RunHistorySettings(ctx context.Context) (domain.RunHistorySettings, error)
	SetRunHistorySettings(ctx context.Context, v domain.RunHistorySettings) (domain.RunHistorySettings, error)
}

func (s *Server) runHistoryOff(w http.ResponseWriter) bool {
	if s.opt.RunHistory == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "run history is not available")
		return true
	}
	return false
}

func toRunTranscript(t domain.Transcript) gen.RunTranscript {
	out := gen.RunTranscript{
		Id: t.ID, WorkspaceId: t.WorkspaceID, Workspace: t.WorkspaceName, WorkspaceSlug: t.WorkspaceSlug, RunId: t.RunID,
		Purpose: string(t.Purpose), Background: t.Purpose.Background(), Engine: gen.RunTranscriptEngine(t.Engine), Model: t.Model,
		StartedAt: t.StartedAt, FinishedAt: t.FinishedAt, Status: gen.RunTranscriptStatus(t.Status), ExitReason: t.ExitReason,
		Turns: t.Turns, ToolCalls: t.ToolCalls, ToolErrors: t.ToolErrors, Stalls: t.Stalls,
		InputTokens: t.Usage.Input, OutputTokens: t.Usage.Output, CacheReadTokens: t.Usage.CacheRead,
		CacheWriteTokens: t.Usage.CacheWrite, CostUsd: float32(t.Usage.CostUSD),
		RawBytes: t.RawBytes, StoredBytes: t.StoredBytes, Truncated: t.Truncated,
	}
	opt := func(v string) *string {
		if v == "" {
			return nil
		}
		return &v
	}
	out.TicketKey, out.Subject, out.ModelStage, out.SessionId = opt(t.TicketKey), opt(t.Subject), opt(t.ModelStage), opt(t.SessionID)
	out.ClaudeAccount, out.ClaudeUser = opt(t.ClaudeLabel), opt(t.ClaudeUser)
	return out
}

// runFilter is the filter the list and the summary share.
type runFilter struct {
	Workspace *int64
	Purpose   *string
	Status    *string
	Engine    *string
	Model     *string
	Ticket    *string
	Stalled   *bool
	From, To  *time.Time
	MinCost   *float32
}

func (p runFilter) filter() domain.TranscriptFilter {
	var f domain.TranscriptFilter
	if p.Workspace != nil {
		f.WorkspaceID = *p.Workspace
	}
	f.Purpose, f.Engine, f.Model = strings.TrimSpace(deref(p.Purpose)), deref(p.Engine), strings.TrimSpace(deref(p.Model))
	f.TicketKey = strings.TrimSpace(deref(p.Ticket))
	f.Status = domain.TranscriptStatus(deref(p.Status))
	f.Stalled = p.Stalled != nil && *p.Stalled
	if p.From != nil {
		f.From = *p.From
	}
	if p.To != nil {
		f.To = *p.To
	}
	if p.MinCost != nil {
		f.MinCost = float64(*p.MinCost)
	}
	return f
}

func strPtr[T ~string](v *T) *string {
	if v == nil {
		return nil
	}
	s := string(*v)
	return &s
}

// runCursor is a page position: the last transcript's start and id.
func runCursor(t domain.Transcript) string {
	return strconv.FormatInt(t.StartedAt.UnixNano(), 10) + "." + strconv.FormatInt(t.ID, 10)
}

func parseRunCursor(c string) (time.Time, int64, bool) {
	ns, id, ok := strings.Cut(c, ".")
	if !ok {
		return time.Time{}, 0, false
	}
	n, err1 := strconv.ParseInt(ns, 10, 64)
	i, err2 := strconv.ParseInt(id, 10, 64)
	if err1 != nil || err2 != nil || i <= 0 {
		return time.Time{}, 0, false
	}
	return time.Unix(0, n), i, true
}

// ListPlatformRuns implements gen.ServerInterface.
func (s *Server) ListPlatformRuns(w http.ResponseWriter, r *http.Request, p gen.ListPlatformRunsParams) {
	if s.runHistoryOff(w) {
		return
	}
	f := runFilter{p.Workspace, p.Purpose, strPtr(p.Status), strPtr(p.Engine), p.Model, p.Ticket, p.Stalled, p.From, p.To, p.MinCost}.filter()
	if c := deref(p.Cursor); c != "" {
		at, id, ok := parseRunCursor(c)
		if !ok {
			writeError(w, http.StatusBadRequest, "bad_request", "cursor is not one this server gave")
			return
		}
		f.BeforeAt, f.BeforeID = at, id
	}
	f.Limit = 50
	if p.Limit != nil {
		f.Limit = min(max(*p.Limit, 1), 200)
	}
	list, err := s.opt.RunHistory.ListTranscripts(domain.System(r.Context()), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.RunHistoryPage{Items: make([]gen.RunTranscript, 0, len(list))}
	for _, t := range list {
		out.Items = append(out.Items, toRunTranscript(t))
	}
	if len(list) == f.Limit {
		c := runCursor(list[len(list)-1])
		out.NextCursor = &c
	}
	writeJSON(w, http.StatusOK, out)
}

// GetPlatformRunSummary implements gen.ServerInterface.
func (s *Server) GetPlatformRunSummary(w http.ResponseWriter, r *http.Request, p gen.GetPlatformRunSummaryParams) {
	if s.runHistoryOff(w) {
		return
	}
	f := runFilter{p.Workspace, p.Purpose, strPtr(p.Status), strPtr(p.Engine), p.Model, p.Ticket, p.Stalled, p.From, p.To, p.MinCost}.filter()
	sum, err := s.opt.RunHistory.TranscriptSummary(domain.System(r.Context()), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.RunHistorySummary{
		Count: sum.Count, Errors: sum.Errors, Stalled: sum.Stalled, CostUsd: float32(sum.CostUSD),
		BackgroundCostUsd: float32(sum.BackgroundCost), InputTokens: sum.InputTokens, OutputTokens: sum.OutputTokens,
		P50Ms: sum.P50.Milliseconds(), P95Ms: sum.P95.Milliseconds(),
	})
}

// auditRead finds a transcript and writes the Admin's read of it to the
// audit log. It answers the request itself and returns false when the
// transcript is unknown or the audit row cannot be written: customer
// content is never served without its audit row.
func (s *Server) auditRead(w http.ResponseWriter, r *http.Request, id int64, action string) (domain.Transcript, bool) {
	ctx := domain.System(r.Context())
	t, err := s.opt.RunHistory.Transcript(ctx, id)
	if err != nil {
		s.authError(w, r, err)
		return t, false
	}
	if err := s.audit(r, action, "transcript:"+strconv.FormatInt(id, 10), &t.WorkspaceID); err != nil {
		s.writeInternal(w, r, err)
		return t, false
	}
	return t, true
}

// audit writes one row of the Admin audit log for the signed-in Admin.
func (s *Server) audit(r *http.Request, action, target string, workspaceID *int64) error {
	u, ok := userFrom(r.Context())
	if !ok {
		return errors.New("audit: no signed-in user")
	}
	return s.opt.RunHistory.Audit(domain.System(r.Context()), domain.AdminAudit{
		AdminID: &u.ID, AdminName: u.Username, Action: action, Target: target, WorkspaceID: workspaceID, IP: r.RemoteAddr,
	})
}

// GetPlatformRun implements gen.ServerInterface.
func (s *Server) GetPlatformRun(w http.ResponseWriter, r *http.Request, id int64) {
	if s.runHistoryOff(w) {
		return
	}
	t, ok := s.auditRead(w, r, id, domain.AuditTranscriptView)
	if !ok {
		return
	}
	ctx := domain.System(r.Context())
	body, err := s.opt.RunHistory.TranscriptBody(ctx, id)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	events, bad := transcriptLines(body)
	siblings := []gen.RunTranscript{}
	if t.RunID != nil {
		list, err := s.opt.RunHistory.RunTranscripts(ctx, *t.RunID)
		if err != nil {
			s.writeInternal(w, r, err)
			return
		}
		for _, x := range list {
			if x.ID != t.ID {
				siblings = append(siblings, toRunTranscript(x))
			}
		}
	}
	out := struct {
		Transcript gen.RunTranscript   `json:"transcript"`
		Events     []json.RawMessage   `json:"events"`
		Siblings   []gen.RunTranscript `json:"siblings"`
		Unreadable bool                `json:"unreadable,omitempty"`
	}{toRunTranscript(t), events, siblings, bad}
	writeJSON(w, http.StatusOK, out)
}

// transcriptLines decodes a stored body (gzip members, one stream) into
// its JSON lines. bad is true when part of it could not be read; the
// lines before that are still returned.
func transcriptLines(body []byte) (lines []json.RawMessage, bad bool) {
	lines = []json.RawMessage{}
	if len(body) == 0 {
		return lines, false
	}
	zr, err := gzip.NewReader(bytes.NewReader(body))
	if err != nil {
		return lines, true
	}
	sc := bufio.NewScanner(zr)
	sc.Buffer(make([]byte, 64*1024), 64<<20)
	for sc.Scan() {
		b := bytes.TrimSpace(sc.Bytes())
		if len(b) == 0 {
			continue
		}
		if !json.Valid(b) {
			bad = true
			continue
		}
		lines = append(lines, json.RawMessage(bytes.Clone(b)))
	}
	if sc.Err() != nil {
		bad = true // a cut-off member (a crash mid-write): keep the lines before it
	}
	return lines, bad
}

// GetPlatformRunPrompt implements gen.ServerInterface.
func (s *Server) GetPlatformRunPrompt(w http.ResponseWriter, r *http.Request, id int64) {
	if s.runHistoryOff(w) {
		return
	}
	if _, ok := s.auditRead(w, r, id, domain.AuditTranscriptPrompt); !ok {
		return
	}
	raw, err := s.opt.RunHistory.TranscriptPrompt(domain.System(r.Context()), id)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	prompt := ""
	if len(raw) > 0 {
		zr, err := gzip.NewReader(bytes.NewReader(raw))
		if err != nil {
			s.writeInternal(w, r, err)
			return
		}
		b, err := io.ReadAll(io.LimitReader(zr, 64<<20))
		if err != nil {
			s.writeInternal(w, r, err)
			return
		}
		prompt = string(b)
	}
	writeJSON(w, http.StatusOK, map[string]string{"prompt": prompt})
}

// DownloadPlatformRun implements gen.ServerInterface.
func (s *Server) DownloadPlatformRun(w http.ResponseWriter, r *http.Request, id int64) {
	if s.runHistoryOff(w) {
		return
	}
	if _, ok := s.auditRead(w, r, id, domain.AuditTranscriptDownload); !ok {
		return
	}
	body, err := s.opt.RunHistory.TranscriptBody(domain.System(r.Context()), id)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	w.Header().Set("Content-Type", "application/x-ndjson")
	w.Header().Set("Content-Disposition", `attachment; filename="agnts-transcript-`+strconv.FormatInt(id, 10)+`.jsonl"`)
	w.WriteHeader(http.StatusOK)
	if len(body) == 0 {
		return
	}
	zr, err := gzip.NewReader(bytes.NewReader(body))
	if err != nil {
		return
	}
	// The body was written by agnts within the transcript cap (64 MB at
	// most); the limit only guards against a corrupt row.
	if _, err := io.Copy(w, io.LimitReader(zr, 128<<20)); err != nil {
		s.opt.Log.Warn("download transcript", "transcript", id, "err", err)
	}
}

func toAuditEntry(a domain.AdminAudit) gen.AdminAuditEntry {
	out := gen.AdminAuditEntry{Id: a.ID, AdminId: a.AdminID, AdminName: a.AdminName, Action: a.Action, Target: a.Target,
		WorkspaceId: a.WorkspaceID, CreatedAt: a.CreatedAt}
	if a.Workspace != "" {
		out.Workspace = &a.Workspace
	}
	if a.IP != "" {
		out.Ip = &a.IP
	}
	return out
}

// ListPlatformAudit implements gen.ServerInterface.
func (s *Server) ListPlatformAudit(w http.ResponseWriter, r *http.Request, p gen.ListPlatformAuditParams) {
	if s.runHistoryOff(w) {
		return
	}
	f := postgres.AuditFilter{Action: strings.TrimSpace(deref(p.Action)), Limit: 100}
	if p.Admin != nil {
		f.AdminID = *p.Admin
	}
	if p.Workspace != nil {
		f.WorkspaceID = *p.Workspace
	}
	if p.Before != nil {
		f.BeforeID = *p.Before
	}
	if p.Limit != nil {
		f.Limit = min(max(*p.Limit, 1), 500)
	}
	list, err := s.opt.RunHistory.ListAudit(domain.System(r.Context()), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.AdminAuditEntry, 0, len(list))
	for _, a := range list {
		out = append(out, toAuditEntry(a))
	}
	writeJSON(w, http.StatusOK, out)
}

func toRunHistorySettings(v domain.RunHistorySettings) gen.RunHistorySettings {
	return gen.RunHistorySettings{RetentionDays: v.RetentionDays, ToolOutputKB: v.ToolOutputKB, TextKB: v.TextKB, TranscriptMB: v.TranscriptMB}
}

// GetRunHistorySettings implements gen.ServerInterface.
func (s *Server) GetRunHistorySettings(w http.ResponseWriter, r *http.Request) {
	if s.runHistoryOff(w) {
		return
	}
	v, err := s.opt.RunHistory.RunHistorySettings(domain.System(r.Context()))
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toRunHistorySettings(v))
}

// SetRunHistorySettings implements gen.ServerInterface.
func (s *Server) SetRunHistorySettings(w http.ResponseWriter, r *http.Request) {
	if s.runHistoryOff(w) {
		return
	}
	var req gen.RunHistorySettings
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if req.RetentionDays < 0 || req.RetentionDays > 3650 || req.ToolOutputKB < 1 || req.ToolOutputKB > 1024 ||
		req.TextKB < 1 || req.TextKB > 1024 || req.TranscriptMB < 1 || req.TranscriptMB > 64 {
		writeError(w, http.StatusBadRequest, "bad_request", "retention is 0 to 3650 days; tool output and text 1 to 1024 KB; a transcript 1 to 64 MB")
		return
	}
	ctx := domain.System(r.Context())
	v, err := s.opt.RunHistory.SetRunHistorySettings(ctx, domain.RunHistorySettings{
		RetentionDays: req.RetentionDays, ToolOutputKB: req.ToolOutputKB, TextKB: req.TextKB, TranscriptMB: req.TranscriptMB,
	})
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	target := "retention " + strconv.Itoa(v.RetentionDays) + "d, tool " + strconv.Itoa(v.ToolOutputKB) + "KB, text " +
		strconv.Itoa(v.TextKB) + "KB, transcript " + strconv.Itoa(v.TranscriptMB) + "MB"
	if err := s.audit(r, domain.AuditRunHistorySettings, target, nil); err != nil {
		s.opt.Log.Warn("audit run history settings", "err", err)
	}
	writeJSON(w, http.StatusOK, toRunHistorySettings(v))
}
