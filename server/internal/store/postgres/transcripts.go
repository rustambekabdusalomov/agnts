package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Transcripts is the run history store: transcripts of Claude Code and
// Codex invocations, its settings, and the Admin audit log.
type Transcripts struct{ db *pgxpool.Pool }

// NewTranscripts returns the run history store.
func NewTranscripts(db *pgxpool.Pool) *Transcripts { return &Transcripts{db: db} }

const runHistoryKey = "run_history"

// backgroundPurposes are the calls outside a ticket's stages.
var backgroundPurposes = []string{
	string(domain.PurposeAssistant), string(domain.PurposeBrief), string(domain.PurposeDetect),
	string(domain.PurposeReflect), string(domain.PurposeRules), string(domain.PurposeTranslate),
}

// StartTranscript implements orchestrator.Recorder. The workspace is
// always given: background loops act with a system scope, where the
// database cannot infer it.
func (s *Transcripts) StartTranscript(ctx context.Context, t domain.TranscriptStart) (int64, error) {
	if t.WorkspaceID <= 0 {
		return 0, errors.New("transcript: no workspace")
	}
	if t.Prompt == nil {
		t.Prompt = []byte{}
	}
	var id int64
	err := s.db.QueryRow(ctx, `INSERT INTO transcripts (workspace_id, run_id, ticket_key, subject, claude_connection_id, claude_label,
			purpose, model_stage, engine, model, prompt)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id`,
		t.WorkspaceID, t.RunID, t.TicketKey, t.Subject, t.ConnectionID, t.ClaudeLabel,
		string(t.Purpose), t.ModelStage, t.Engine, t.Model, t.Prompt).Scan(&id)
	return id, err
}

// AppendTranscript implements orchestrator.Recorder.
func (s *Transcripts) AppendTranscript(ctx context.Context, id int64, chunk []byte, c domain.TranscriptCounts) error {
	_, err := s.db.Exec(ctx, `UPDATE transcripts SET body = body || $2, raw_bytes = $3, tool_calls = $4, tool_errors = $5,
			truncated = $6
		WHERE id = $1 AND status = 'running'`, id, chunk, c.RawBytes, c.ToolCalls, c.ToolErrors, c.Truncated)
	return err
}

// FinishTranscript implements orchestrator.Recorder.
func (s *Transcripts) FinishTranscript(ctx context.Context, id int64, chunk []byte, e domain.TranscriptEnd) error {
	if chunk == nil {
		chunk = []byte{}
	}
	u := e.Usage
	_, err := s.db.Exec(ctx, `UPDATE transcripts SET body = body || $2, raw_bytes = $3, tool_calls = $4, tool_errors = $5,
			truncated = $6, status = $7, exit_reason = $8, session_id = $9, model = CASE WHEN $10 = '' THEN model ELSE $10 END,
			turns = $11, stalls = $12, input_tokens = $13, output_tokens = $14, cache_read_tokens = $15,
			cache_write_tokens = $16, cost_usd = $17, finished_at = now()
		WHERE id = $1`, id, chunk, e.Counts.RawBytes, e.Counts.ToolCalls, e.Counts.ToolErrors, e.Counts.Truncated,
		string(e.Status), e.ExitReason, e.SessionID, e.Model, e.Turns, e.Stalls,
		u.Input, u.Output, u.CacheRead, u.CacheWrite, u.CostUSD)
	return err
}

// RecoverTranscripts implements orchestrator.Recorder: transcripts left
// running by a crash are closed as errors, keeping what was appended.
func (s *Transcripts) RecoverTranscripts(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE transcripts SET status = 'error', exit_reason = 'server restarted', finished_at = now()
		WHERE status = 'running'`)
	return int(tag.RowsAffected()), err
}

// RunHistorySettings implements orchestrator.Recorder.
func (s *Transcripts) RunHistorySettings(ctx context.Context) (domain.RunHistorySettings, error) {
	var raw []byte
	err := s.db.QueryRow(ctx, `SELECT value FROM system_settings WHERE key = $1`, runHistoryKey).Scan(&raw)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.DefaultRunHistory, nil
	}
	if err != nil {
		return domain.DefaultRunHistory, err
	}
	out := domain.DefaultRunHistory
	if err := json.Unmarshal(raw, &out); err != nil {
		return domain.DefaultRunHistory, err
	}
	return out.Normalize(), nil
}

// SetRunHistorySettings stores the run history limits.
func (s *Transcripts) SetRunHistorySettings(ctx context.Context, v domain.RunHistorySettings) (domain.RunHistorySettings, error) {
	v = v.Normalize()
	b, err := json.Marshal(v)
	if err != nil {
		return v, err
	}
	_, err = s.db.Exec(ctx, `INSERT INTO system_settings (key, value) VALUES ($1, $2)
		ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = now()`, runHistoryKey, b)
	return v, err
}

// PruneTranscripts deletes transcripts started before before, in batches
// so a big backlog does not hold one long lock.
func (s *Transcripts) PruneTranscripts(ctx context.Context, before time.Time) (int64, error) {
	var total int64
	for {
		tag, err := s.db.Exec(ctx, `DELETE FROM transcripts WHERE id IN (
			SELECT id FROM transcripts WHERE started_at < $1 AND status <> 'running' ORDER BY id LIMIT 1000)`, before)
		if err != nil {
			return total, err
		}
		total += tag.RowsAffected()
		if tag.RowsAffected() < 1000 || ctx.Err() != nil {
			return total, ctx.Err()
		}
	}
}

// PruneAudit deletes audit rows older than before.
func (s *Transcripts) PruneAudit(ctx context.Context, before time.Time) (int64, error) {
	tag, err := s.db.Exec(ctx, `DELETE FROM admin_audit WHERE created_at < $1`, before)
	return tag.RowsAffected(), err
}

const transcriptCols = `t.id, t.workspace_id, COALESCE(w.slug, ''), COALESCE(w.name, ''), t.run_id, t.ticket_key, t.subject,
	t.claude_connection_id, t.claude_label, COALESCE(NULLIF(u.display_name, ''), u.username, ''),
	t.purpose, t.model_stage, t.engine, t.model, t.session_id, t.started_at, t.finished_at, t.status, t.exit_reason,
	t.turns, t.tool_calls, t.tool_errors, t.stalls, t.input_tokens, t.output_tokens, t.cache_read_tokens,
	t.cache_write_tokens, t.cost_usd::float8, t.raw_bytes, octet_length(t.body), t.truncated`

const transcriptFrom = ` FROM transcripts t
	LEFT JOIN workspaces w ON w.id = t.workspace_id
	LEFT JOIN claude_connections c ON c.id = t.claude_connection_id
	LEFT JOIN users u ON u.id = c.user_id`

func scanTranscript(row interface{ Scan(...any) error }) (domain.Transcript, error) {
	var t domain.Transcript
	var purpose, status string
	err := row.Scan(&t.ID, &t.WorkspaceID, &t.WorkspaceSlug, &t.WorkspaceName, &t.RunID, &t.TicketKey, &t.Subject,
		&t.ConnectionID, &t.ClaudeLabel, &t.ClaudeUser,
		&purpose, &t.ModelStage, &t.Engine, &t.Model, &t.SessionID, &t.StartedAt, &t.FinishedAt, &status, &t.ExitReason,
		&t.Turns, &t.ToolCalls, &t.ToolErrors, &t.Stalls, &t.Usage.Input, &t.Usage.Output, &t.Usage.CacheRead,
		&t.Usage.CacheWrite, &t.Usage.CostUSD, &t.RawBytes, &t.StoredBytes, &t.Truncated)
	t.Purpose, t.Status = domain.TranscriptPurpose(purpose), domain.TranscriptStatus(status)
	return t, notFound(err)
}

// transcriptWhere builds the WHERE clause of a filter (paging aside).
func transcriptWhere(f domain.TranscriptFilter) (string, []any) {
	var conds []string
	var args []any
	arg := func(v any) string {
		args = append(args, v)
		return fmt.Sprintf("$%d", len(args))
	}
	if f.WorkspaceID > 0 {
		conds = append(conds, "t.workspace_id = "+arg(f.WorkspaceID))
	}
	switch f.Purpose {
	case "":
	case "background":
		conds = append(conds, "t.purpose = ANY("+arg(backgroundPurposes)+")")
	case "stages":
		conds = append(conds, "NOT (t.purpose = ANY("+arg(backgroundPurposes)+"))")
	default:
		conds = append(conds, "t.purpose = "+arg(f.Purpose))
	}
	if f.Status != "" {
		conds = append(conds, "t.status = "+arg(string(f.Status)))
	}
	if f.Engine != "" {
		conds = append(conds, "t.engine = "+arg(f.Engine))
	}
	if f.Model != "" {
		conds = append(conds, "t.model ILIKE "+arg("%"+escapeLike(f.Model)+"%"))
	}
	if f.TicketKey != "" {
		conds = append(conds, "t.ticket_key ILIKE "+arg(escapeLike(f.TicketKey)+"%"))
	}
	if f.Stalled {
		conds = append(conds, "t.stalls > 0")
	}
	if !f.From.IsZero() {
		conds = append(conds, "t.started_at >= "+arg(f.From))
	}
	if !f.To.IsZero() {
		conds = append(conds, "t.started_at < "+arg(f.To))
	}
	if f.MinCost > 0 {
		conds = append(conds, "t.cost_usd >= "+arg(f.MinCost))
	}
	if len(conds) == 0 {
		return "", args
	}
	return " WHERE " + strings.Join(conds, " AND "), args
}

func escapeLike(s string) string {
	return strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`).Replace(s)
}

// ListTranscripts returns transcripts matching f, newest first, without
// prompt or body. Pages continue below (BeforeAt, BeforeID).
func (s *Transcripts) ListTranscripts(ctx context.Context, f domain.TranscriptFilter) ([]domain.Transcript, error) {
	where, args := transcriptWhere(f)
	if f.BeforeID > 0 {
		args = append(args, f.BeforeAt, f.BeforeID)
		cond := fmt.Sprintf("(t.started_at, t.id) < ($%d, $%d)", len(args)-1, len(args))
		if where == "" {
			where = " WHERE " + cond
		} else {
			where += " AND " + cond
		}
	}
	limit := f.Limit
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	rows, err := s.db.Query(ctx, `SELECT `+transcriptCols+transcriptFrom+where+
		fmt.Sprintf(` ORDER BY t.started_at DESC, t.id DESC LIMIT %d`, limit), args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Transcript{}
	for rows.Next() {
		t, err := scanTranscript(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// TranscriptSummary returns the totals of the transcripts matching f.
func (s *Transcripts) TranscriptSummary(ctx context.Context, f domain.TranscriptFilter) (domain.TranscriptSummary, error) {
	where, args := transcriptWhere(f)
	args = append(args, backgroundPurposes)
	bg := fmt.Sprintf("$%d", len(args))
	var out domain.TranscriptSummary
	var p50, p95 *float64
	err := s.db.QueryRow(ctx, `SELECT count(*),
			count(*) FILTER (WHERE t.status IN ('error', 'timeout', 'oom')),
			count(*) FILTER (WHERE t.stalls > 0),
			COALESCE(sum(t.cost_usd), 0)::float8,
			COALESCE(sum(t.cost_usd) FILTER (WHERE t.purpose = ANY(`+bg+`)), 0)::float8,
			COALESCE(sum(t.input_tokens), 0), COALESCE(sum(t.output_tokens), 0),
			percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM t.finished_at - t.started_at)),
			percentile_cont(0.95) WITHIN GROUP (ORDER BY extract(epoch FROM t.finished_at - t.started_at))
		FROM transcripts t`+where, args...).Scan(&out.Count, &out.Errors, &out.Stalled, &out.CostUSD, &out.BackgroundCost,
		&out.InputTokens, &out.OutputTokens, &p50, &p95)
	if p50 != nil {
		out.P50 = time.Duration(*p50 * float64(time.Second))
	}
	if p95 != nil {
		out.P95 = time.Duration(*p95 * float64(time.Second))
	}
	return out, err
}

// Transcript returns one transcript without prompt or body.
func (s *Transcripts) Transcript(ctx context.Context, id int64) (domain.Transcript, error) {
	return scanTranscript(s.db.QueryRow(ctx, `SELECT `+transcriptCols+transcriptFrom+` WHERE t.id = $1`, id))
}

// RunTranscripts returns the transcripts of a run (first pass, fix
// attempts, second opinion), oldest first.
func (s *Transcripts) RunTranscripts(ctx context.Context, runID int64) ([]domain.Transcript, error) {
	rows, err := s.db.Query(ctx, `SELECT `+transcriptCols+transcriptFrom+` WHERE t.run_id = $1 ORDER BY t.started_at, t.id`, runID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Transcript{}
	for rows.Next() {
		t, err := scanTranscript(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// TranscriptBody returns a transcript's gzipped body.
func (s *Transcripts) TranscriptBody(ctx context.Context, id int64) ([]byte, error) {
	var b []byte
	err := s.db.QueryRow(ctx, `SELECT body FROM transcripts WHERE id = $1`, id).Scan(&b)
	return b, notFound(err)
}

// TranscriptPrompt returns a transcript's gzipped prompt.
func (s *Transcripts) TranscriptPrompt(ctx context.Context, id int64) ([]byte, error) {
	var b []byte
	err := s.db.QueryRow(ctx, `SELECT prompt FROM transcripts WHERE id = $1`, id).Scan(&b)
	return b, notFound(err)
}

// Audit writes one row of the Admin audit log.
func (s *Transcripts) Audit(ctx context.Context, a domain.AdminAudit) error {
	_, err := s.db.Exec(ctx, `INSERT INTO admin_audit (admin_id, admin_name, action, target, workspace_id, ip)
		VALUES ($1, $2, $3, $4, $5, $6)`, a.AdminID, a.AdminName, a.Action, a.Target, a.WorkspaceID, a.IP)
	return err
}

// AuditFilter narrows the audit log.
type AuditFilter struct {
	AdminID     int64
	Action      string
	WorkspaceID int64
	BeforeID    int64
	Limit       int
}

// ListAudit returns audit rows matching f, newest first.
func (s *Transcripts) ListAudit(ctx context.Context, f AuditFilter) ([]domain.AdminAudit, error) {
	var conds []string
	var args []any
	arg := func(v any) string {
		args = append(args, v)
		return fmt.Sprintf("$%d", len(args))
	}
	if f.AdminID > 0 {
		conds = append(conds, "a.admin_id = "+arg(f.AdminID))
	}
	if f.Action != "" {
		conds = append(conds, "a.action = "+arg(f.Action))
	}
	if f.WorkspaceID > 0 {
		conds = append(conds, "a.workspace_id = "+arg(f.WorkspaceID))
	}
	if f.BeforeID > 0 {
		conds = append(conds, "a.id < "+arg(f.BeforeID))
	}
	where := ""
	if len(conds) > 0 {
		where = " WHERE " + strings.Join(conds, " AND ")
	}
	limit := f.Limit
	if limit <= 0 || limit > 500 {
		limit = 100
	}
	rows, err := s.db.Query(ctx, `SELECT a.id, a.admin_id, a.admin_name, a.action, a.target, a.workspace_id, COALESCE(w.name, ''),
			a.ip, a.created_at
		FROM admin_audit a LEFT JOIN workspaces w ON w.id = a.workspace_id`+where+
		fmt.Sprintf(` ORDER BY a.id DESC LIMIT %d`, limit), args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.AdminAudit{}
	for rows.Next() {
		var a domain.AdminAudit
		if err := rows.Scan(&a.ID, &a.AdminID, &a.AdminName, &a.Action, &a.Target, &a.WorkspaceID, &a.Workspace, &a.IP, &a.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}
