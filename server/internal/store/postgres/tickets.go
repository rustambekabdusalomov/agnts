package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Agent implements orchestrator.Store.
type Agent struct{ db *pgxpool.Pool }

var _ orchestrator.Store = (*Agent)(nil)

// NewAgent returns the orchestrator's store.
func NewAgent(db *pgxpool.Pool) *Agent { return &Agent{db: db} }

const ticketCols = `id, key, source, repo_id, title, description, priority, state, resume_state,
	revision, turns, models, after_approve, branch, head_sha, pr_number, pr_url, feedback, held, ask_first, merged_at, assignees, learn_state, review_state, kind, kind_auto, post_report, COALESCE(parent_key, ''),
	COALESCE(follow_up_of, ''), suggest_follow_ups, created_at, updated_at`

func scanTicket(row pgx.Row) (domain.Ticket, error) {
	var t domain.Ticket
	var source, state, resume, kind string
	var models []byte
	err := row.Scan(&t.ID, &t.Key, &source, &t.RepoID, &t.Title, &t.Description, &t.Priority, &state, &resume,
		&t.Revision, &t.Turns, &models, &t.AfterApprove, &t.Branch, &t.HeadSHA, &t.PRNumber, &t.PRURL, &t.Feedback,
		&t.Held, &t.AskFirst, &t.MergedAt, &t.Assignees, &t.LearnState, &t.ReviewState, &kind, &t.KindAuto, &t.PostReport, &t.ParentKey,
		&t.FollowUpOf, &t.SuggestFollowUps, &t.CreatedAt, &t.UpdatedAt)
	if err != nil {
		return t, notFound(err)
	}
	t.Source, t.State, t.ResumeState = domain.TicketSource(source), domain.TicketState(state), domain.TicketState(resume)
	t.Kind = domain.TicketKind(kind)
	if len(models) > 0 {
		_ = json.Unmarshal(models, &t.Models)
	}
	return t, nil
}

// TicketByKey returns one ticket.
func (s *Agent) TicketByKey(ctx context.Context, key string) (domain.Ticket, error) {
	return scanTicket(s.db.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE key = $1`, key))
}

// ListTickets returns tickets, most recently updated first.
func (s *Agent) ListTickets(ctx context.Context, f orchestrator.TicketFilter) ([]domain.Ticket, error) {
	limit := f.Limit
	if limit <= 0 || limit > 500 {
		limit = 200
	}
	states := make([]string, len(f.States))
	for i, st := range f.States {
		states[i] = string(st)
	}
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE cardinality($1::text[]) = 0 OR state = ANY($1)
		ORDER BY updated_at DESC LIMIT $2`, states, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Ticket
	for rows.Next() {
		t, err := scanTicket(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// CreateTicket inserts a new ticket and its creation event.
func (s *Agent) CreateTicket(ctx context.Context, t domain.Ticket, ev domain.Event) (domain.Ticket, error) {
	var out domain.Ticket
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		models, _ := json.Marshal(nonNilMap(t.Models))
		var err error
		if out, err = insertTicket(ctx, tx, t, models); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

func insertTicket(ctx context.Context, tx pgx.Tx, t domain.Ticket, models []byte) (domain.Ticket, error) {
	out, err := scanTicket(tx.QueryRow(ctx, `INSERT INTO tickets
		(key, source, repo_id, title, description, priority, state, resume_state, models, after_approve, held, ask_first, kind, kind_auto,
		 parent_key, follow_up_of, suggest_follow_ups)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NULLIF($15, ''), NULLIF($16, ''), $17) RETURNING `+ticketCols,
		t.Key, string(t.Source), t.RepoID, t.Title, t.Description, t.Priority, string(t.State),
		string(t.ResumeState), models, t.AfterApprove, t.Held, t.AskFirst, string(kindOr(t.Kind)), t.KindAuto, t.ParentKey,
		t.FollowUpOf, t.SuggestFollowUps))
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return out, domain.ErrConflict
	}
	return out, err
}

// UpdateTicket changes fields other than state on a locked row.
func (s *Agent) UpdateTicket(ctx context.Context, key string, ev *domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error) {
	var out domain.Ticket
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		t, err := scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE key = $1 FOR UPDATE`, key))
		if err != nil {
			return err
		}
		state := t.State
		mut(&t)
		t.State = state // state only changes through Transition
		if out, err = saveTicket(ctx, tx, t); err != nil {
			return err
		}
		if ev != nil {
			return insertEvent(ctx, tx, *ev)
		}
		return nil
	})
	return out, err
}

// Transition changes state and writes its event in one transaction.
func (s *Agent) Transition(ctx context.Context, key string, to domain.TicketState, ev domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error) {
	var out domain.Ticket
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		t, err := scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE key = $1 FOR UPDATE`, key))
		if err != nil {
			return err
		}
		if !domain.CanTransition(t.State, to) {
			return &domain.TransitionError{Key: key, From: t.State, To: to}
		}
		if mut != nil {
			mut(&t)
		}
		from := t.State
		t.State = to
		if out, err = saveTicket(ctx, tx, t); err != nil {
			return err
		}
		if ev.Data == nil {
			ev.Data = map[string]any{}
		}
		ev.Data["from"], ev.Data["to"] = string(from), string(to)
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

func saveTicket(ctx context.Context, tx pgx.Tx, t domain.Ticket) (domain.Ticket, error) {
	models, _ := json.Marshal(nonNilMap(t.Models))
	return scanTicket(tx.QueryRow(ctx, `UPDATE tickets SET
		repo_id = $2, title = $3, description = $4, priority = $5, state = $6, resume_state = $7,
		revision = $8, turns = $9, models = $10, after_approve = $11, branch = $12, head_sha = $13,
		pr_number = $14, pr_url = $15, feedback = $16, held = $17, ask_first = $18, merged_at = $19, assignees = $20, learn_state = $21,
		kind = $22, kind_auto = $23, post_report = $24, review_state = $25, suggest_follow_ups = $26, updated_at = now()
		WHERE id = $1 RETURNING `+ticketCols,
		t.ID, t.RepoID, t.Title, t.Description, t.Priority, string(t.State), string(t.ResumeState),
		t.Revision, t.Turns, models, t.AfterApprove, t.Branch, t.HeadSHA, t.PRNumber, t.PRURL, t.Feedback, t.Held, t.AskFirst, t.MergedAt, nonNilSlice(t.Assignees), t.LearnState,
		string(kindOr(t.Kind)), t.KindAuto, t.PostReport, t.ReviewState, t.SuggestFollowUps))
}

func kindOr(k domain.TicketKind) domain.TicketKind {
	if k == "" {
		return domain.KindCode
	}
	return k
}

func nonNilMap(m map[string]string) map[string]string {
	if m == nil {
		return map[string]string{}
	}
	return m
}

const runCols = `id, ticket_id, stage, model, session_id, container_id, started_at, finished_at, turns, exit_reason`

func scanRun(row pgx.Row) (domain.Run, error) {
	var r domain.Run
	var stage string
	err := row.Scan(&r.ID, &r.TicketID, &stage, &r.Model, &r.SessionID, &r.ContainerID, &r.StartedAt, &r.FinishedAt, &r.Turns, &r.ExitReason)
	r.Stage = domain.Stage(stage)
	return r, notFound(err)
}

// ClaimNext starts a run for the oldest ticket waiting for a worker. Code
// reviews come next (the reviewer may be reading the change already), and
// learn runs only take the worker when nothing else is waiting.
func (s *Agent) ClaimNext(ctx context.Context) (domain.Ticket, domain.Run, bool, error) {
	var t domain.Ticket
	var r domain.Run
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
			WHERE state IN ('new', 'coding', 'pushing') AND NOT held
			  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
			ORDER BY updated_at
			LIMIT 1 FOR UPDATE SKIP LOCKED`))
		if errors.Is(err, domain.ErrNotFound) {
			t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
				WHERE state = 'waiting_for_review' AND review_state = 'pending'
				  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
				ORDER BY updated_at
				LIMIT 1 FOR UPDATE SKIP LOCKED`))
		}
		if errors.Is(err, domain.ErrNotFound) {
			t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
				WHERE state = 'done' AND learn_state = 'pending'
				  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
				ORDER BY updated_at
				LIMIT 1 FOR UPDATE SKIP LOCKED`))
		}
		if err != nil {
			return err
		}
		stage := map[domain.TicketState]domain.Stage{
			domain.StateNew: domain.StageAnalyze, domain.StateCoding: domain.StageCode, domain.StatePushing: domain.StagePush,
			domain.StateDone: domain.StageLearn, domain.StateWaitingForReview: domain.StageReview,
		}[t.State]
		if r, err = scanRun(tx.QueryRow(ctx, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, $2, '') RETURNING `+runCols,
			t.ID, string(stage))); err != nil {
			return err
		}
		if stage == domain.StageReview {
			t.ReviewState = domain.ReviewRunning
			t, err = saveTicket(ctx, tx, t)
			return err
		}
		if t.State == domain.StateNew {
			from := t.State
			t.State = domain.StateAnalyzing
			if t, err = saveTicket(ctx, tx, t); err != nil {
				return err
			}
			return insertEvent(ctx, tx, domain.Event{
				TicketKey: t.Key, RunID: &r.ID, Type: domain.EventStateChanged, Step: string(stage),
				Message: "picked up for analysis", Data: map[string]any{"from": string(from), "to": string(t.State)},
			})
		}
		return nil
	})
	if errors.Is(err, domain.ErrNotFound) {
		return t, r, false, nil
	}
	return t, r, err == nil, err
}

// FinishRun records how a run ended.
func (s *Agent) FinishRun(ctx context.Context, r domain.Run) error {
	_, err := s.db.Exec(ctx, `UPDATE runs SET session_id = $2, container_id = $3, finished_at = $4, turns = $5, exit_reason = $6, model = $7 WHERE id = $1`,
		r.ID, r.SessionID, r.ContainerID, r.FinishedAt, r.Turns, r.ExitReason, r.Model)
	return err
}

// LastSessionID returns the newest Claude session of a ticket's own work
// (analysis and coding), or "". Learn and review sessions are not resumed.
func (s *Agent) LastSessionID(ctx context.Context, ticketID int64) (string, error) {
	var id string
	err := s.db.QueryRow(ctx, `SELECT session_id FROM runs WHERE ticket_id = $1 AND session_id <> '' AND stage NOT IN ('learn', 'review')
		ORDER BY started_at DESC LIMIT 1`, ticketID).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", nil
	}
	return id, err
}

// RecoverInterrupted closes runs a crash left open and requeues their tickets.
func (s *Agent) RecoverInterrupted(ctx context.Context) (int, error) {
	var n int
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `UPDATE runs SET finished_at = now(), exit_reason = 'interrupted'
			WHERE finished_at IS NULL RETURNING ticket_id, id`)
		if err != nil {
			return err
		}
		type pair struct{ ticket, run int64 }
		var ps []pair
		for rows.Next() {
			var p pair
			if err := rows.Scan(&p.ticket, &p.run); err != nil {
				return err
			}
			ps = append(ps, p)
		}
		if err := rows.Err(); err != nil {
			return err
		}
		n = len(ps)
		for _, p := range ps {
			var key, from string
			err := tx.QueryRow(ctx, `UPDATE tickets t SET state = CASE state WHEN 'analyzing' THEN 'new' WHEN 'testing' THEN 'coding' ELSE state END,
				review_state = CASE review_state WHEN 'running' THEN 'pending' ELSE review_state END,
				updated_at = now() FROM (SELECT state AS old FROM tickets WHERE id = $1) o
				WHERE t.id = $1 RETURNING t.key, o.old`, p.ticket).Scan(&key, &from)
			if err != nil {
				return err
			}
			if err := insertEvent(ctx, tx, domain.Event{TicketKey: key, RunID: &p.run, Type: domain.EventError, Level: domain.LevelWarn,
				Message: "agnts restarted during this run; it will start again"}); err != nil {
				return err
			}
		}
		return nil
	})
	return n, err
}

// ReplaceQuestions swaps a ticket's questions for a new set.
func (s *Agent) ReplaceQuestions(ctx context.Context, ticketID int64, qs []domain.Question) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM questions WHERE ticket_id = $1`, ticketID); err != nil {
			return err
		}
		for _, q := range qs {
			opts, _ := json.Marshal(nonNilSlice(q.Options))
			if _, err := tx.Exec(ctx, `INSERT INTO questions (ticket_id, position, text, options) VALUES ($1, $2, $3, $4)`,
				ticketID, q.Position, q.Text, opts); err != nil {
				return err
			}
		}
		return nil
	})
}

func nonNilSlice(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}

// Questions returns a ticket's questions in order.
func (s *Agent) Questions(ctx context.Context, ticketID int64) ([]domain.Question, error) {
	rows, err := s.db.Query(ctx, `SELECT id, ticket_id, position, text, options, answer, note
		FROM questions WHERE ticket_id = $1 ORDER BY position`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Question
	for rows.Next() {
		var q domain.Question
		var opts []byte
		if err := rows.Scan(&q.ID, &q.TicketID, &q.Position, &q.Text, &opts, &q.Answer, &q.Note); err != nil {
			return nil, err
		}
		_ = json.Unmarshal(opts, &q.Options)
		out = append(out, q)
	}
	return out, rows.Err()
}

// SaveAnswers stores answers to a ticket's questions.
func (s *Agent) SaveAnswers(ctx context.Context, ticketID int64, as []domain.Answer) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		for _, a := range as {
			tag, err := tx.Exec(ctx, `UPDATE questions SET answer = $3, note = $4, answered_at = now()
				WHERE id = $1 AND ticket_id = $2`, a.QuestionID, ticketID, a.Answer, a.Note)
			if err != nil {
				return err
			}
			if tag.RowsAffected() != 1 {
				return fmt.Errorf("question %d: %w", a.QuestionID, domain.ErrNotFound)
			}
		}
		return nil
	})
}

// SaveResult stores what a run produced.
func (s *Agent) SaveResult(ctx context.Context, r domain.Result) error {
	files, _ := json.Marshal(r.Files)
	if r.Files == nil {
		files = []byte("[]")
	}
	_, err := s.db.Exec(ctx, `INSERT INTO results (run_id, summary, tests, lint, files, report) VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (run_id) DO UPDATE SET summary = $2, tests = $3, lint = $4, files = $5, report = $6`,
		r.RunID, jsonOr(r.Summary, "{}"), jsonOr(r.Tests, "{}"), r.Lint, files, r.Report)
	return err
}

func jsonOr(b json.RawMessage, def string) []byte {
	if len(b) == 0 || !json.Valid(b) {
		return []byte(def)
	}
	return b
}

// LatestResult returns the newest result of a stage for a ticket.
func (s *Agent) LatestResult(ctx context.Context, ticketID int64, stage domain.Stage) (domain.Result, error) {
	var r domain.Result
	var files []byte
	err := s.db.QueryRow(ctx, `SELECT res.id, res.run_id, res.summary, res.tests, res.lint, res.files, res.report, res.created_at
		FROM results res JOIN runs ON runs.id = res.run_id
		WHERE runs.ticket_id = $1 AND runs.stage = $2 ORDER BY res.created_at DESC LIMIT 1`, ticketID, string(stage)).
		Scan(&r.ID, &r.RunID, &r.Summary, &r.Tests, &r.Lint, &files, &r.Report, &r.CreatedAt)
	if err != nil {
		return r, notFound(err)
	}
	_ = json.Unmarshal(files, &r.Files)
	return r, nil
}

// AppendEvent writes one event.
func (s *Agent) AppendEvent(ctx context.Context, ev domain.Event) error {
	return insertEvent(ctx, s.db, ev)
}

type execer interface {
	Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error)
}

func insertEvent(ctx context.Context, db execer, ev domain.Event) error {
	if ev.Level == "" {
		ev.Level = domain.LevelInfo
	}
	if ev.Origin == "" {
		ev.Origin = domain.OriginSystem
	}
	data, err := json.Marshal(ev.Data)
	if err != nil || ev.Data == nil {
		data = []byte("{}")
	}
	var key *string
	if ev.TicketKey != "" {
		key = &ev.TicketKey
	}
	_, err = db.Exec(ctx, `INSERT INTO events (ticket_key, run_id, step, type, level, origin, message, data, duration_ms)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		key, ev.RunID, ev.Step, ev.Type, string(ev.Level), string(ev.Origin), ev.Message, data, ev.DurationMS)
	return err
}

// Events returns events after a cursor, oldest first.
func (s *Agent) Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error) {
	limit := f.Limit
	if limit <= 0 || limit > 1000 {
		limit = 500
	}
	rows, err := s.db.Query(ctx, `SELECT id, COALESCE(ticket_key, ''), run_id, step, type, level, origin, message, data, duration_ms, created_at
		FROM events WHERE ($1 = '' OR ticket_key = $1) AND id > $2 ORDER BY id LIMIT $3`, f.TicketKey, f.AfterID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Event
	for rows.Next() {
		var e domain.Event
		var level, origin string
		var data []byte
		if err := rows.Scan(&e.ID, &e.TicketKey, &e.RunID, &e.Step, &e.Type, &level, &origin, &e.Message, &data, &e.DurationMS, &e.CreatedAt); err != nil {
			return nil, err
		}
		e.Level, e.Origin = domain.Level(level), domain.Origin(origin)
		_ = json.Unmarshal(data, &e.Data)
		out = append(out, e)
	}
	return out, rows.Err()
}

const repoCols = `id, name, kind, provider, clone_url, default_branch, stack, build_cmd, lint_cmd, test_cmd, branch_prefix, claude_md, jira_project, task_prefix, claude_md_status, deploy_workflow, archived_at`

func scanRepo(row pgx.Row) (domain.Repository, error) {
	var r domain.Repository
	err := row.Scan(&r.ID, &r.Name, &r.Kind, &r.Provider, &r.CloneURL, &r.DefaultBranch, &r.Stack,
		&r.BuildCmd, &r.LintCmd, &r.TestCmd, &r.BranchPrefix, &r.ClaudeMD, &r.JiraProject, &r.TaskPrefix, &r.ClaudeMDState, &r.DeployWorkflow, &r.ArchivedAt)
	return r, notFound(err)
}

// RepositoryByID returns one repository.
func (s *Agent) RepositoryByID(ctx context.Context, id int64) (domain.Repository, error) {
	return scanRepo(s.db.QueryRow(ctx, `SELECT `+repoCols+` FROM repositories WHERE id = $1`, id))
}

// SetRepositoryArchived archives (true) or restores a repository.
func (s *Agent) SetRepositoryArchived(ctx context.Context, id int64, archived bool) (domain.Repository, error) {
	return scanRepo(s.db.QueryRow(ctx, `UPDATE repositories SET
		archived_at = CASE WHEN $2 THEN coalesce(archived_at, now()) END, updated_at = now()
		WHERE id = $1 RETURNING `+repoCols, id, archived))
}

// RepositoryByJiraProject returns the repository linked to a Jira project key.
func (s *Agent) RepositoryByJiraProject(ctx context.Context, project string) (domain.Repository, error) {
	if project == "" {
		return domain.Repository{}, domain.ErrNotFound
	}
	return scanRepo(s.db.QueryRow(ctx, `SELECT `+repoCols+` FROM repositories WHERE jira_project = $1`, project))
}

// ListRepositories returns all repositories.
func (s *Agent) ListRepositories(ctx context.Context) ([]domain.Repository, error) {
	rows, err := s.db.Query(ctx, `SELECT `+repoCols+` FROM repositories ORDER BY name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Repository
	for rows.Next() {
		r, err := scanRepo(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

// SaveRepository inserts or updates a repository by name.
func (s *Agent) SaveRepository(ctx context.Context, r domain.Repository) (domain.Repository, error) {
	if r.BranchPrefix == "" {
		r.BranchPrefix = "agnts/"
	}
	if r.DefaultBranch == "" {
		r.DefaultBranch = "main"
	}
	out, err := scanRepo(s.db.QueryRow(ctx, `INSERT INTO repositories
		(name, kind, provider, clone_url, default_branch, stack, build_cmd, lint_cmd, test_cmd, branch_prefix, claude_md, jira_project, task_prefix, deploy_workflow)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		ON CONFLICT (name) DO UPDATE SET kind = $2, provider = $3, clone_url = $4, default_branch = $5, stack = $6,
			build_cmd = $7, lint_cmd = $8, test_cmd = $9, branch_prefix = $10, claude_md = $11, jira_project = $12,
			task_prefix = $13, deploy_workflow = $14, updated_at = now()
		RETURNING `+repoCols,
		r.Name, r.Kind, r.Provider, r.CloneURL, r.DefaultBranch, r.Stack, r.BuildCmd, r.LintCmd, r.TestCmd,
		r.BranchPrefix, r.ClaudeMD, r.JiraProject, r.TaskPrefix, r.DeployWorkflow))
	return out, uniqueConflict(err)
}

// UpdateRepository changes a repository by id.
func (s *Agent) UpdateRepository(ctx context.Context, r domain.Repository) (domain.Repository, error) {
	out, err := scanRepo(s.db.QueryRow(ctx, `UPDATE repositories SET name = $2, kind = $3, provider = $4, clone_url = $5,
		default_branch = $6, build_cmd = $7, lint_cmd = $8, test_cmd = $9, branch_prefix = $10, claude_md = $11,
		jira_project = $12, task_prefix = $13, deploy_workflow = $14, updated_at = now() WHERE id = $1 RETURNING `+repoCols,
		r.ID, r.Name, r.Kind, r.Provider, r.CloneURL, r.DefaultBranch, r.BuildCmd, r.LintCmd, r.TestCmd,
		r.BranchPrefix, r.ClaudeMD, r.JiraProject, r.TaskPrefix, r.DeployWorkflow))
	return out, uniqueConflict(err)
}

// SetClaudeMDState records whether the repository has a CLAUDE.md.
func (s *Agent) SetClaudeMDState(ctx context.Context, id int64, state string) error {
	_, err := s.db.Exec(ctx, `UPDATE repositories SET claude_md_status = $2 WHERE id = $1`, id, state)
	return err
}

// NextTaskNumber reserves the next task number of a repository, or of
// tasks without one when repoID is nil.
func (s *Agent) NextTaskNumber(ctx context.Context, repoID *int64) (int, error) {
	var n int
	if repoID == nil {
		err := s.db.QueryRow(ctx, `SELECT nextval('task_seq')`).Scan(&n)
		return n, err
	}
	err := s.db.QueryRow(ctx, `UPDATE repositories SET task_seq = task_seq + 1 WHERE id = $1 RETURNING task_seq`, *repoID).Scan(&n)
	return n, notFound(err)
}

// DeleteTicket removes a ticket and its runs; its events stay in the log.
func (s *Agent) DeleteTicket(ctx context.Context, key string, ev domain.Event) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `DELETE FROM tickets WHERE key = $1`, key)
		if err != nil {
			return err
		}
		if tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return insertEvent(ctx, tx, ev)
	})
}

// OpenTicketCounts returns open tickets per repository id.
func (s *Agent) OpenTicketCounts(ctx context.Context) (map[int64]int, error) {
	rows, err := s.db.Query(ctx, `SELECT repo_id, count(*) FROM tickets WHERE repo_id IS NOT NULL AND state NOT IN ('done', 'rejected') GROUP BY repo_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64]int{}
	for rows.Next() {
		var id int64
		var n int
		if err := rows.Scan(&id, &n); err != nil {
			return nil, err
		}
		out[id] = n
	}
	return out, rows.Err()
}

func uniqueConflict(err error) error {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return fmt.Errorf("%w: %s", domain.ErrConflict, pgErr.ConstraintName)
	}
	return err
}

// SeenDelivery records a webhook delivery id and reports whether it was
// already processed.
func (s *Agent) SeenDelivery(ctx context.Context, provider, id string) (bool, error) {
	tag, err := s.db.Exec(ctx, `INSERT INTO webhook_deliveries (provider, delivery_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`, provider, id)
	if err != nil {
		return false, err
	}
	return tag.RowsAffected() == 0, nil
}

// PruneDeliveries forgets deliveries older than d.
func (s *Agent) PruneDeliveries(ctx context.Context, d time.Duration) error {
	_, err := s.db.Exec(ctx, `DELETE FROM webhook_deliveries WHERE received_at < now() - make_interval(secs => $1)`, d.Seconds())
	return err
}

// ChildOf returns the ticket that implements parentKey, or ErrNotFound.
func (s *Agent) ChildOf(ctx context.Context, parentKey string) (domain.Ticket, error) {
	return scanTicket(s.db.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE parent_key = $1`, parentKey))
}

// TicketByPR finds the ticket whose pull request is url (or whose branch is
// branch on that repository), for merge webhooks.
func (s *Agent) TicketByPR(ctx context.Context, url, branch string) (domain.Ticket, error) {
	return scanTicket(s.db.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE ($1 <> '' AND pr_url = $1) OR ($2 <> '' AND branch = $2) ORDER BY updated_at DESC LIMIT 1`, url, branch))
}
