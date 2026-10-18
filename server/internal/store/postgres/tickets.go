package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
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
	COALESCE(follow_up_of, ''), suggest_follow_ups, preview_state, preview_compare, feedback_shots, feedback_files, created_at, updated_at,
	workspace_id, member_id, created_by, wait_reason, queued_at, wait_message, self_fixes, quiet_review, replay_of, base_sha, pull_request,
	tracker_update, tracker_kept, ci_fixes, group_id, agnts_group_name(group_id), agnts_ticket_repos(id), ticket_number, skip_checks`

func scanTicket(row pgx.Row) (domain.Ticket, error) {
	var t domain.Ticket
	var source, state, resume, kind, wait string
	var models, shots, files, pull, update, repos []byte
	err := row.Scan(&t.ID, &t.Key, &source, &t.RepoID, &t.Title, &t.Description, &t.Priority, &state, &resume,
		&t.Revision, &t.Turns, &models, &t.AfterApprove, &t.Branch, &t.HeadSHA, &t.PRNumber, &t.PRURL, &t.Feedback,
		&t.Held, &t.AskFirst, &t.MergedAt, &t.Assignees, &t.LearnState, &t.ReviewState, &kind, &t.KindAuto, &t.PostReport, &t.ParentKey,
		&t.FollowUpOf, &t.SuggestFollowUps, &t.PreviewState, &t.PreviewCompare, &shots, &files, &t.CreatedAt, &t.UpdatedAt,
		&t.WorkspaceID, &t.MemberID, &t.CreatedBy, &wait, &t.QueuedAt, &t.WaitMessage, &t.SelfFixes, &t.QuietReview, &t.ReplayOf, &t.BaseSHA, &pull, &update, &t.Kept, &t.CIFixes,
		&t.GroupID, &t.GroupName, &repos, &t.TicketNumber, &t.SkipChecks)
	if err != nil {
		return t, notFound(err)
	}
	if len(repos) > 0 {
		// A failed read would make the next save drop the other rows.
		if err := json.Unmarshal(repos, &t.Repos); err != nil {
			return t, fmt.Errorf("ticket %s repositories: %w", t.Key, err)
		}
	}
	if len(shots) > 0 {
		_ = json.Unmarshal(shots, &t.FeedbackShots)
	}
	if len(files) > 0 {
		_ = json.Unmarshal(files, &t.FeedbackFiles)
	}
	if len(update) > 0 {
		var u domain.TrackerUpdate
		if json.Unmarshal(update, &u) == nil {
			t.Update = &u
		}
	}
	if len(pull) > 0 {
		var p domain.PullRequest
		if json.Unmarshal(pull, &p) == nil {
			t.Pull = &p
		}
	}
	t.Source, t.State, t.ResumeState = domain.TicketSource(source), domain.TicketState(state), domain.TicketState(resume)
	t.Kind = domain.TicketKind(kind)
	t.WaitReason = domain.WaitReason(wait)
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
	if a, ok := domain.ActorOf(ctx); ok {
		if t.CreatedBy == nil {
			t.CreatedBy = &a.UserID
		}
		if t.MemberID == nil {
			t.MemberID = &a.UserID
		}
	}
	t.SyncRepos()
	out, err := scanTicket(tx.QueryRow(ctx, `INSERT INTO tickets
		(key, source, repo_id, title, description, priority, state, resume_state, models, after_approve, held, ask_first, kind, kind_auto,
		 parent_key, follow_up_of, suggest_follow_ups, member_id, created_by, replay_of, base_sha, branch, pr_number, pr_url, pull_request, group_id, ticket_number)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NULLIF($15, ''), NULLIF($16, ''), $17, $18, $19, $20, $21,
		 $22, $23, $24, $25, $26, $27) RETURNING `+ticketCols,
		t.Key, string(t.Source), t.RepoID, t.Title, t.Description, t.Priority, string(t.State),
		string(t.ResumeState), models, t.AfterApprove, t.Held, t.AskFirst, string(kindOr(t.Kind)), t.KindAuto, t.ParentKey,
		t.FollowUpOf, t.SuggestFollowUps, t.MemberID, t.CreatedBy, t.ReplayOf, t.BaseSHA, t.Branch, t.PRNumber, t.PRURL, pullJSON(t.Pull), t.GroupID, t.TicketNumber))
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return out, domain.ErrConflict
	}
	if err != nil || len(t.Repos) == 0 {
		return out, err
	}
	t.ID = out.ID
	if err := saveTicketRepos(ctx, tx, t); err != nil {
		return out, err
	}
	return scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE id = $1`, out.ID))
}

// saveTicketRepos makes the ticket's ticket_repos rows exactly t.Repos
// (t.SyncRepos was called): rows of repositories it no longer works in go.
func saveTicketRepos(ctx context.Context, tx pgx.Tx, t domain.Ticket) error {
	ids := t.RepoIDs()
	if t.RepoID == nil {
		ids = nil
	}
	if _, err := tx.Exec(ctx, `DELETE FROM ticket_repos WHERE ticket_id = $1 AND NOT (repo_id = ANY($2::bigint[]))`, t.ID, ids); err != nil {
		return err
	}
	if t.RepoID == nil {
		return nil
	}
	for _, r := range t.Repos {
		if _, err := tx.Exec(ctx, `INSERT INTO ticket_repos (ticket_id, repo_id, position, folder, role, branch, head_sha, base_sha,
				pr_number, pr_url, assignees, ci_fixes, merged_at, closed_at, state, push_error, files)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
			ON CONFLICT (ticket_id, repo_id) DO UPDATE SET position = $3, folder = $4, role = $5, branch = $6, head_sha = $7,
				base_sha = $8, pr_number = $9, pr_url = $10, assignees = $11, ci_fixes = $12, merged_at = $13, closed_at = $14,
				state = $15, push_error = $16, files = $17`,
			t.ID, r.RepoID, r.Position, r.Folder, r.Role, r.Branch, r.HeadSHA, r.BaseSHA, r.PRNumber, r.PRURL,
			nonNilSlice(r.Assignees), r.CIFixes, r.MergedAt, r.ClosedAt, string(repoStateOr(r.State)), r.PushError, r.Files); err != nil {
			return err
		}
	}
	return nil
}

func repoStateOr(s domain.TicketRepoState) domain.TicketRepoState {
	if s == "" {
		return domain.RepoPending
	}
	return s
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
	shots, _ := json.Marshal(t.FeedbackShots)
	if t.FeedbackShots == nil {
		shots = []byte("[]")
	}
	files, _ := json.Marshal(t.FeedbackFiles)
	if t.FeedbackFiles == nil {
		files = []byte("[]")
	}
	t.SyncRepos()
	if err := saveTicketRepos(ctx, tx, t); err != nil {
		return domain.Ticket{}, err
	}
	return scanTicket(tx.QueryRow(ctx, `UPDATE tickets SET
		repo_id = $2, title = $3, description = $4, priority = $5, state = $6, resume_state = $7,
		revision = $8, turns = $9, models = $10, after_approve = $11, branch = $12, head_sha = $13,
		pr_number = $14, pr_url = $15, feedback = $16, held = $17, ask_first = $18, merged_at = $19, assignees = $20, learn_state = $21,
		kind = $22, kind_auto = $23, post_report = $24, review_state = $25, suggest_follow_ups = $26,
		preview_state = $27, preview_compare = $28, feedback_shots = $29, feedback_files = $30, member_id = $31,
		self_fixes = $32, quiet_review = $33, pull_request = $34, tracker_update = $35, tracker_kept = $36, ci_fixes = $37,
		group_id = $38, base_sha = $39, ticket_number = $40, skip_checks = $41,
		wait_reason = CASE WHEN $6 IN ('new', 'coding', 'pushing') THEN wait_reason ELSE '' END,
		wait_message = CASE WHEN $6 IN ('new', 'coding', 'pushing') THEN wait_message ELSE '' END,
		queued_at = CASE WHEN $6 IN ('new', 'coding', 'pushing') THEN queued_at END,
		updated_at = now()
		WHERE id = $1 RETURNING `+ticketCols,
		t.ID, t.RepoID, t.Title, t.Description, t.Priority, string(t.State), string(t.ResumeState),
		t.Revision, t.Turns, models, t.AfterApprove, t.Branch, t.HeadSHA, t.PRNumber, t.PRURL, t.Feedback, t.Held, t.AskFirst, t.MergedAt, nonNilSlice(t.Assignees), t.LearnState,
		string(kindOr(t.Kind)), t.KindAuto, t.PostReport, t.ReviewState, t.SuggestFollowUps,
		t.PreviewState, t.PreviewCompare, shots, files, t.MemberID, t.SelfFixes, t.QuietReview, pullJSON(t.Pull), updateJSON(t.Update), t.Kept, t.CIFixes,
		t.GroupID, t.BaseSHA, t.TicketNumber, t.SkipChecks))
}

// updateJSON is a ticket's pending tracker version, nil (SQL NULL) for none.
func updateJSON(u *domain.TrackerUpdate) []byte {
	if u == nil {
		return nil
	}
	b, _ := json.Marshal(u)
	return b
}

// pullJSON is a ticket's pull request for the pull_request column, nil
// (SQL NULL) for tickets that review none.
func pullJSON(p *domain.PullRequest) []byte {
	if p == nil {
		return nil
	}
	b, _ := json.Marshal(p)
	return b
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

// ClaimNext starts a run for the next ticket waiting for a worker: the
// highest priority first, then the one more tickets wait for, then the
// oldest. A ticket whose dependencies are not merged, or whose conflicting
// ticket is changing the same code, does not start coding (see waitsSQL).
// Code reviews come next (the reviewer may be reading the change already),
// then previews, and learn runs only take the worker when nothing else is
// waiting.
func (s *Agent) ClaimNext(ctx context.Context) (domain.Ticket, domain.Run, bool, error) {
	var t domain.Ticket
	var r domain.Run
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
			WHERE state IN ('new', 'coding', 'pushing') AND NOT held
			  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
			  AND NOT `+waitsSQL+`
			ORDER BY `+priorityRankSQL+` DESC, `+unblocksSQL+` DESC, updated_at
			LIMIT 1 FOR UPDATE OF t SKIP LOCKED`))
		if errors.Is(err, domain.ErrNotFound) {
			t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
				WHERE state = 'waiting_for_review' AND review_state = 'pending'
				  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
				ORDER BY updated_at
				LIMIT 1 FOR UPDATE SKIP LOCKED`))
		}
		preview := false
		if errors.Is(err, domain.ErrNotFound) {
			t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
				WHERE state = 'waiting_for_review' AND preview_state = 'pending'
				  AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)
				ORDER BY updated_at
				LIMIT 1 FOR UPDATE SKIP LOCKED`))
			preview = err == nil
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
		t, r, err = startRun(ctx, tx, t, preview)
		return err
	})
	if errors.Is(err, domain.ErrNotFound) {
		return t, r, false, nil
	}
	return t, r, err == nil, err
}

// startRun starts the run a claimed (locked) ticket needs: its main stage,
// or the review, preview or learn side run.
func startRun(ctx context.Context, tx pgx.Tx, t domain.Ticket, preview bool) (domain.Ticket, domain.Run, error) {
	var r domain.Run
	stage := map[domain.TicketState]domain.Stage{
		domain.StateNew: domain.StageAnalyze, domain.StateCoding: domain.StageCode, domain.StatePushing: domain.StagePush,
		domain.StateDone: domain.StageLearn, domain.StateWaitingForReview: domain.StageReview,
	}[t.State]
	if preview {
		stage = domain.StagePreview
	}
	var err error
	if r, err = scanRun(tx.QueryRow(ctx, `INSERT INTO runs (ticket_id, stage, model) VALUES ($1, $2, '') RETURNING `+runCols,
		t.ID, string(stage))); err != nil {
		return t, r, err
	}
	// It no longer waits for a worker.
	if _, err := tx.Exec(ctx, `UPDATE tickets SET wait_reason = '', wait_message = '', queued_at = NULL WHERE id = $1`, t.ID); err != nil {
		return t, r, err
	}
	t.WaitReason, t.WaitMessage, t.QueuedAt = domain.WaitNone, "", nil
	switch {
	case stage == domain.StageReview:
		t.ReviewState = domain.ReviewRunning
		t, err = saveTicket(ctx, tx, t)
	case stage == domain.StagePreview:
		t.PreviewState = domain.PreviewRunning
		t, err = saveTicket(ctx, tx, t)
	case t.State == domain.StateNew:
		from := t.State
		t.State = domain.StateAnalyzing
		if t, err = saveTicket(ctx, tx, t); err != nil {
			return t, r, err
		}
		err = insertEvent(ctx, tx, domain.Event{
			WorkspaceID: t.WorkspaceID, TicketKey: t.Key, RunID: &r.ID, Type: domain.EventStateChanged, Step: string(stage),
			Message: "picked up for analysis", Data: map[string]any{"from": string(from), "to": string(t.State)},
		})
	}
	return t, r, err
}

// queueClassSQL says which run a ticket waits for: main (its next
// stage), review, preview or learn; NULL when none.
const queueClassSQL = `(CASE
	WHEN t.state IN ('new', 'coding', 'pushing') THEN 'main'
	WHEN t.state = 'waiting_for_review' AND t.review_state = 'pending' THEN 'review'
	WHEN t.state = 'waiting_for_review' AND t.preview_state = 'pending' THEN 'preview'
	WHEN t.state = 'done' AND t.learn_state = 'pending' THEN 'learn' END)`

// QueueItems returns every ticket that waits for a run, in every workspace
// the context sees, with what the scheduler needs to pick and explain.
func (s *Agent) QueueItems(ctx context.Context) ([]orchestrator.QueueItem, error) {
	rows, err := s.db.Query(ctx, `SELECT t.id, t.workspace_id, t.key, t.state, `+queueClassSQL+`, t.held, `+waitsSQL+`,
			`+priorityRankSQL+`, `+unblocksSQL+`, t.updated_at, t.queued_at, t.wait_reason, t.member_id, t.repo_id,
			-- The run's checks go one repository at a time: the most any needs.
			COALESCE((SELECT max(r.memory_mb) FROM ticket_repos tr JOIN repositories r ON r.id = tr.repo_id WHERE tr.ticket_id = t.id), 0),
			t.kind, t.wait_message
		FROM tickets t
		WHERE `+queueClassSQL+` IS NOT NULL
		  AND NOT EXISTS (SELECT 1 FROM runs x WHERE x.ticket_id = t.id AND x.finished_at IS NULL)`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.QueueItem
	for rows.Next() {
		var q orchestrator.QueueItem
		var state, class, wait, kind string
		if err := rows.Scan(&q.TicketID, &q.WorkspaceID, &q.Key, &state, &class, &q.Held, &q.Blocked, &q.Priority, &q.Unblocks,
			&q.UpdatedAt, &q.QueuedAt, &wait, &q.MemberID, &q.RepoID, &q.MemoryMB, &kind, &q.WaitMessage); err != nil {
			return nil, err
		}
		q.State, q.Class, q.WaitReason, q.Kind = domain.TicketState(state), orchestrator.QueueClass(class), domain.WaitReason(wait), domain.TicketKind(kind)
		out = append(out, q)
	}
	return out, rows.Err()
}

// ClaimTicket starts the run of class one ticket waits for, when it still
// waits for it and nothing else claimed it; ok is false otherwise.
func (s *Agent) ClaimTicket(ctx context.Context, ticketID int64, class orchestrator.QueueClass) (domain.Ticket, domain.Run, bool, error) {
	var t domain.Ticket
	var r domain.Run
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		t, err = scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets t
			WHERE t.id = $1 AND `+queueClassSQL+` = $2
			  AND ($2 <> 'main' OR (NOT t.held AND NOT `+waitsSQL+`))
			  AND NOT EXISTS (SELECT 1 FROM runs x WHERE x.ticket_id = t.id AND x.finished_at IS NULL)
			FOR UPDATE OF t SKIP LOCKED`, ticketID, string(class)))
		if err != nil {
			return err
		}
		t, r, err = startRun(ctx, tx, t, class == orchestrator.ClassPreview)
		return err
	})
	if errors.Is(err, domain.ErrNotFound) {
		return t, r, false, nil
	}
	return t, r, err == nil, err
}

// SetWaitReasons records why tickets wait (only the ones that changed are
// passed), with an event on each so the reason shows in the history.
func (s *Agent) SetWaitReasons(ctx context.Context, changes []orchestrator.WaitChange) error {
	if len(changes) == 0 {
		return nil
	}
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		for _, c := range changes {
			tag, err := tx.Exec(ctx, `UPDATE tickets SET wait_reason = $2, wait_message = $3,
				queued_at = CASE WHEN $2 = '' THEN NULL ELSE COALESCE(queued_at, now()) END
				WHERE id = $1 AND state IN ('new', 'coding', 'pushing') AND (wait_reason <> $2 OR wait_message <> $3)`,
				c.TicketID, string(c.Reason), c.Message)
			if err != nil {
				return err
			}
			if tag.RowsAffected() == 0 || c.Message == "" || !c.Announce {
				continue
			}
			if err := insertEvent(ctx, tx, domain.Event{WorkspaceID: c.WorkspaceID, TicketKey: c.Key, Type: domain.EventQueued,
				Message: c.Message, Data: map[string]any{"reason": string(c.Reason)}}); err != nil {
				return err
			}
		}
		return nil
	})
}

// FinishRun records how a run ended.
func (s *Agent) FinishRun(ctx context.Context, r domain.Run) error {
	harness, _ := json.Marshal(r.Harness)
	_, err := s.db.Exec(ctx, `UPDATE runs SET session_id = $2, container_id = $3, finished_at = $4, turns = $5, exit_reason = $6, model = $7,
		prompt_version = $8, fix_attempts = $9, harness = $10 WHERE id = $1`,
		r.ID, r.SessionID, r.ContainerID, r.FinishedAt, r.Turns, r.ExitReason, r.Model, r.PromptVersion, r.FixAttempts, harness)
	return err
}

// SetRepoHarness stores the harness settings people chose for a
// repository, keeping agnts's scan of its agent files.
func (s *Agent) SetRepoHarness(ctx context.Context, id int64, h domain.RepoHarness) (domain.Repository, error) {
	h.AgentConfig = nil
	raw, err := json.Marshal(h)
	if err != nil {
		return domain.Repository{}, err
	}
	return scanRepo(s.db.QueryRow(ctx, `UPDATE repositories SET
		harness = CASE WHEN harness ? 'agentConfig' THEN $2::jsonb || jsonb_build_object('agentConfig', harness->'agentConfig') ELSE $2::jsonb END,
		updated_at = now() WHERE id = $1 RETURNING `+repoCols, id, raw))
}

// SetAgentConfigScan stores what agnts found in a repository's agent files.
func (s *Agent) SetAgentConfigScan(ctx context.Context, id int64, scan domain.AgentConfigScan) error {
	if scan.Findings == nil {
		scan.Findings = []domain.AgentConfigFinding{}
	}
	raw, err := json.Marshal(scan)
	if err != nil {
		return err
	}
	_, err = s.db.Exec(ctx, `UPDATE repositories SET harness = jsonb_set(harness, '{agentConfig}', $2::jsonb) WHERE id = $1`, id, raw)
	return err
}

// LastSessionID returns the newest Claude session of a ticket's own work
// (analysis and coding), or "". Learn and review sessions are not resumed.
func (s *Agent) LastSessionID(ctx context.Context, ticketID int64) (string, error) {
	var id string
	err := s.db.QueryRow(ctx, `SELECT session_id FROM runs WHERE ticket_id = $1 AND session_id <> '' AND stage NOT IN ('learn', 'review', 'preview')
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
				preview_state = CASE preview_state WHEN 'running' THEN 'pending' ELSE preview_state END,
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
			if _, err := tx.Exec(ctx, `INSERT INTO questions (ticket_id, position, text, options, multiple) VALUES ($1, $2, $3, $4, $5)`,
				ticketID, q.Position, q.Text, opts, q.Multiple); err != nil {
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
	rows, err := s.db.Query(ctx, `SELECT id, ticket_id, position, text, options, multiple, answer, note
		FROM questions WHERE ticket_id = $1 ORDER BY position`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Question
	for rows.Next() {
		var q domain.Question
		var opts []byte
		if err := rows.Scan(&q.ID, &q.TicketID, &q.Position, &q.Text, &opts, &q.Multiple, &q.Answer, &q.Note); err != nil {
			return nil, err
		}
		_ = json.Unmarshal(opts, &q.Options)
		out = append(out, q)
	}
	return out, rows.Err()
}

// SaveAnswers stores answers to a ticket's questions and links the
// uploads each answer attaches, or fails with ErrConflict when one of them
// is no longer pending.
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
			qid := a.QuestionID
			if err := linkAttachments(ctx, tx, a.Attachments, ticketID, &qid, domain.AttachAnswer); err != nil {
				return err
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
	flags, _ := json.Marshal(r.RedFlags)
	if r.RedFlags == nil {
		flags = []byte("[]")
	}
	harness, _ := json.Marshal(r.Harness)
	_, err := s.db.Exec(ctx, `INSERT INTO results (run_id, summary, tests, lint, files, report, red_flags, harness) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (run_id) DO UPDATE SET summary = $2, tests = $3, lint = $4, files = $5, report = $6, red_flags = $7, harness = $8`,
		r.RunID, jsonOr(r.Summary, "{}"), jsonOr(r.Tests, "{}"), r.Lint, files, r.Report, flags, harness)
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
	var files, flags, harness []byte
	err := s.db.QueryRow(ctx, `SELECT res.id, res.run_id, res.summary, res.tests, res.lint, res.files, res.report, res.red_flags, res.harness, res.created_at
		FROM results res JOIN runs ON runs.id = res.run_id
		WHERE runs.ticket_id = $1 AND runs.stage = $2 ORDER BY res.created_at DESC LIMIT 1`, ticketID, string(stage)).
		Scan(&r.ID, &r.RunID, &r.Summary, &r.Tests, &r.Lint, &files, &r.Report, &flags, &harness, &r.CreatedAt)
	if err != nil {
		return r, notFound(err)
	}
	_ = json.Unmarshal(files, &r.Files)
	_ = json.Unmarshal(flags, &r.RedFlags)
	_ = json.Unmarshal(harness, &r.Harness)
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
	var user *int64
	if ev.UserID > 0 {
		user = &ev.UserID
	} else if a, ok := domain.ActorOf(ctx); ok {
		user = &a.UserID
	}
	var ws *int64
	if ev.WorkspaceID > 0 {
		ws = &ev.WorkspaceID
	}
	_, err = db.Exec(ctx, `INSERT INTO events (ticket_key, run_id, step, type, level, origin, message, data, duration_ms, user_id, workspace_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, COALESCE($11, agnts_ws()))`,
		key, ev.RunID, ev.Step, ev.Type, string(ev.Level), string(ev.Origin), ev.Message, data, ev.DurationMS, user, ws)
	return err
}

// Events returns events after a cursor, oldest first.
func (s *Agent) Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error) {
	limit := f.Limit
	if limit <= 0 || limit > 1000 {
		limit = 500
	}
	rows, err := s.db.Query(ctx, `SELECT `+eventCols+` FROM `+eventFrom+`
		WHERE ($1 = '' OR e.ticket_key = $1) AND e.id > $2 ORDER BY e.id LIMIT $3`, f.TicketKey, f.AfterID, limit)
	if err != nil {
		return nil, err
	}
	return scanEvents(rows)
}

const repoCols = `id, name, kind, provider, clone_url, default_branch, stack, build_cmd, lint_cmd, test_cmd, branch_prefix, claude_md, jira_project, task_prefix, claude_md_status, deploy_workflow, archived_at,
	preview_cmd, preview_port, preview_ready_path, preview_routes, preview_ui_paths, preview_login, preview_env IS NOT NULL, preview_env_names,
	toolchains, toolchains_override, toolchains_detected_at, toolchain_notes, runner_image, memory_mb, build_env IS NOT NULL, build_env_names,
	plane_project, workspace_id, harness, branch_template, commit_template`

func scanRepo(row pgx.Row) (domain.Repository, error) {
	var r domain.Repository
	var tcs, harness []byte
	err := row.Scan(&r.ID, &r.Name, &r.Kind, &r.Provider, &r.CloneURL, &r.DefaultBranch, &r.Stack,
		&r.BuildCmd, &r.LintCmd, &r.TestCmd, &r.BranchPrefix, &r.ClaudeMD, &r.JiraProject, &r.TaskPrefix, &r.ClaudeMDState, &r.DeployWorkflow, &r.ArchivedAt,
		&r.Preview.Command, &r.Preview.Port, &r.Preview.ReadyPath, &r.Preview.Routes, &r.Preview.UIPaths, &r.Preview.Login, &r.Preview.EnvSet, &r.Preview.EnvNames,
		&tcs, &r.ToolchainsOverride, &r.ToolchainsDetectedAt, &r.ToolchainNotes, &r.RunnerImage, &r.MemoryMB, &r.BuildEnvSet, &r.BuildEnvNames,
		&r.PlaneProject, &r.WorkspaceID, &harness, &r.BranchTemplate, &r.CommitTemplate)
	if err == nil {
		_ = json.Unmarshal(tcs, &r.Toolchains)
		_ = json.Unmarshal(harness, &r.Harness)
	}
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

// RepositoryByTrackerProject returns the repository linked to a project
// of the tracker source: a Jira project key or a Plane project identifier.
func (s *Agent) RepositoryByTrackerProject(ctx context.Context, source domain.TicketSource, project string) (domain.Repository, error) {
	col := ""
	switch source {
	case domain.SourceJira:
		col = "jira_project"
	case domain.SourcePlane:
		col = "plane_project"
	}
	if project == "" || col == "" {
		return domain.Repository{}, domain.ErrNotFound
	}
	return scanRepo(s.db.QueryRow(ctx, `SELECT `+repoCols+` FROM repositories WHERE `+col+` = $1`, project))
}

// RepositoryByName returns the repository named name, in any case.
func (s *Agent) RepositoryByName(ctx context.Context, name string) (domain.Repository, error) {
	return scanRepo(s.db.QueryRow(ctx, `SELECT `+repoCols+` FROM repositories WHERE lower(name) = lower($1)
		ORDER BY name = $1 DESC, id LIMIT 1`, name))
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

// SaveRepository inserts or updates a repository by name. Updating keeps
// its preview settings: they are only changed by id (UpdateRepository).
func (s *Agent) SaveRepository(ctx context.Context, r domain.Repository) (domain.Repository, error) {
	if r.BranchPrefix == "" {
		r.BranchPrefix = "agnts/"
	}
	if r.DefaultBranch == "" {
		r.DefaultBranch = "main"
	}
	out, err := scanRepo(s.db.QueryRow(ctx, `INSERT INTO repositories
		(name, kind, provider, clone_url, default_branch, stack, build_cmd, lint_cmd, test_cmd, branch_prefix, claude_md, jira_project, task_prefix, deploy_workflow,
		 preview_cmd, preview_port, preview_ready_path, preview_routes, preview_ui_paths, preview_login,
		 toolchains, toolchains_override, runner_image, memory_mb, plane_project, branch_template, commit_template)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27)
		ON CONFLICT (workspace_id, name) DO UPDATE SET kind = $2, provider = $3, clone_url = $4, default_branch = $5, stack = $6,
			build_cmd = $7, lint_cmd = $8, test_cmd = $9, branch_prefix = $10, claude_md = $11, jira_project = $12,
			task_prefix = $13, deploy_workflow = $14,
			toolchains = CASE WHEN $22 OR $21::jsonb <> '[]'::jsonb THEN $21 ELSE repositories.toolchains END,
			toolchains_override = $22 OR (repositories.toolchains_override AND $21::jsonb = '[]'::jsonb),
			runner_image = $23, memory_mb = $24, plane_project = $25, branch_template = $26, commit_template = $27, updated_at = now()
		RETURNING `+repoCols,
		r.Name, r.Kind, r.Provider, r.CloneURL, r.DefaultBranch, stackOf(r), r.BuildCmd, r.LintCmd, r.TestCmd,
		r.BranchPrefix, r.ClaudeMD, r.JiraProject, r.TaskPrefix, r.DeployWorkflow,
		r.Preview.Command, r.Preview.Port, readyPath(r.Preview.ReadyPath), nonNilSlice(r.Preview.Routes), nonNilSlice(r.Preview.UIPaths), r.Preview.Login,
		toolchainsJSON(r.Toolchains), r.ToolchainsOverride, r.RunnerImage, r.MemoryMB, r.PlaneProject, r.BranchTemplate, r.CommitTemplate))
	return out, uniqueConflict(err)
}

// UpdateRepository changes a repository by id.
func (s *Agent) UpdateRepository(ctx context.Context, r domain.Repository) (domain.Repository, error) {
	out, err := scanRepo(s.db.QueryRow(ctx, `UPDATE repositories SET name = $2, kind = $3, provider = $4, clone_url = $5,
		default_branch = $6, build_cmd = $7, lint_cmd = $8, test_cmd = $9, branch_prefix = $10, claude_md = $11,
		jira_project = $12, task_prefix = $13, deploy_workflow = $14, preview_cmd = $15, preview_port = $16,
		preview_ready_path = $17, preview_routes = $18, preview_ui_paths = $19, preview_login = $20,
		toolchains = $21, toolchains_override = $22, runner_image = $23, memory_mb = $24, stack = $25,
		plane_project = $26, branch_template = $27, commit_template = $28, updated_at = now() WHERE id = $1 RETURNING `+repoCols,
		r.ID, r.Name, r.Kind, r.Provider, r.CloneURL, r.DefaultBranch, r.BuildCmd, r.LintCmd, r.TestCmd,
		r.BranchPrefix, r.ClaudeMD, r.JiraProject, r.TaskPrefix, r.DeployWorkflow,
		r.Preview.Command, r.Preview.Port, readyPath(r.Preview.ReadyPath), nonNilSlice(r.Preview.Routes), nonNilSlice(r.Preview.UIPaths), r.Preview.Login,
		toolchainsJSON(r.Toolchains), r.ToolchainsOverride, r.RunnerImage, r.MemoryMB, stackOf(r), r.PlaneProject, r.BranchTemplate, r.CommitTemplate))
	return out, uniqueConflict(err)
}

// SetDetectedToolchains stores what detection found for a repository
// whose toolchains nobody set by hand (an override is left alone), and
// fills its check commands when all three are empty. It returns the
// repository as stored.
func (s *Agent) SetDetectedToolchains(ctx context.Context, id int64, tcs []domain.Toolchain, notes []string, build, lint, test string) (domain.Repository, error) {
	return scanRepo(s.db.QueryRow(ctx, `UPDATE repositories SET
		toolchains = CASE WHEN toolchains_override THEN toolchains ELSE $2 END,
		stack = CASE WHEN toolchains_override THEN stack ELSE $3 END,
		toolchain_notes = $4, toolchains_detected_at = now(),
		build_cmd = CASE WHEN build_cmd = '' AND lint_cmd = '' AND test_cmd = '' THEN $5 ELSE build_cmd END,
		lint_cmd  = CASE WHEN build_cmd = '' AND lint_cmd = '' AND test_cmd = '' THEN $6 ELSE lint_cmd END,
		test_cmd  = CASE WHEN build_cmd = '' AND lint_cmd = '' AND test_cmd = '' THEN $7 ELSE test_cmd END
		WHERE id = $1 RETURNING `+repoCols,
		id, toolchainsJSON(tcs), domain.StackOf(tcs), nonNilSlice(notes), build, lint, test))
}

func toolchainsJSON(tcs []domain.Toolchain) []byte {
	if tcs == nil {
		tcs = []domain.Toolchain{}
	}
	b, _ := json.Marshal(tcs)
	return b
}

// stackOf is the stack column: the toolchain names, else what was stored.
func stackOf(r domain.Repository) string {
	if len(r.Toolchains) > 0 {
		return domain.StackOf(r.Toolchains)
	}
	return r.Stack
}

func readyPath(p string) string {
	if p == "" {
		return "/"
	}
	return p
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
		ws, err := domain.MustWorkspace(ctx)
		if err != nil {
			return 0, err
		}
		err = s.db.QueryRow(ctx, `UPDATE workspaces SET task_seq = task_seq + 1 WHERE id = $1 RETURNING task_seq`, ws).Scan(&n)
		return n, notFound(err)
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
	// A ticket counts in every repository it works in.
	rows, err := s.db.Query(ctx, `SELECT tr.repo_id, count(*) FROM ticket_repos tr JOIN tickets t ON t.id = tr.ticket_id
		WHERE t.state NOT IN ('done', 'rejected') GROUP BY tr.repo_id`)
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

// OpenTicketWithNumber returns an open ticket other than except whose
// number (Ticket.Number) is n: its branch would be the same.
func (s *Agent) OpenTicketWithNumber(ctx context.Context, n, except string) (domain.Ticket, error) {
	return scanTicket(s.db.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE (ticket_number = $1 OR (ticket_number = '' AND key = $1)) AND key <> $2 AND state NOT IN ('done', 'rejected')
		ORDER BY id LIMIT 1`, n, except))
}

// TicketBranches maps the branches agnts made in a repository to their
// ticket keys.
func (s *Agent) TicketBranches(ctx context.Context, repoID int64) (map[string]string, error) {
	rows, err := s.db.Query(ctx, `SELECT tr.branch, t.key FROM ticket_repos tr JOIN tickets t ON t.id = tr.ticket_id
		WHERE tr.repo_id = $1 AND tr.branch <> ''`, repoID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]string{}
	for rows.Next() {
		var branch, key string
		if err := rows.Scan(&branch, &key); err != nil {
			return nil, err
		}
		out[branch] = key
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

// TicketByPR finds the ticket and the repository whose pull request ref
// names, for merge webhooks and CI runs: by the pull request's address
// first, else by its branch in that repository (the branch name alone is
// ambiguous: every repository of a ticket has agnts/KEY).
func (s *Agent) TicketByPR(ctx context.Context, ref domain.PRRef) (domain.Ticket, int64, error) {
	var repoID int64
	t, err := scanTicket(scanAppend{s.db.QueryRow(ctx, `SELECT `+ticketCols+`, x.rid FROM tickets JOIN (
			SELECT tr.ticket_id AS tid, tr.repo_id AS rid, tr.pr_url AS url, tr.branch AS br, r.clone_url AS clone
			FROM ticket_repos tr JOIN repositories r ON r.id = tr.repo_id) x ON x.tid = tickets.id
		WHERE ($1 <> '' AND x.url = $1)
		   OR ($2 <> '' AND x.br = $2 AND ($3 = 0 OR x.rid = $3)
		       AND ($4 = '' OR right(lower(rtrim(regexp_replace(regexp_replace(x.clone, '^[^@/]+@([^:/]+):', '\1/'), '\.git$', ''), '/')),
		           length($4) + 1) = '/' || lower($4)))
		ORDER BY ($1 <> '' AND x.url = $1) DESC, tickets.updated_at DESC LIMIT 1`,
		ref.URL, ref.Branch, ref.RepoID, strings.Trim(ref.Repo, "/")), &repoID})
	return t, repoID, err
}

// UnmergedPRs returns done tickets with a pull request not known to be
// merged or closed, least recently updated first.
func (s *Agent) UnmergedPRs(ctx context.Context, limit int) ([]domain.Ticket, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE state = 'done' AND repo_id IS NOT NULL AND EXISTS (SELECT 1 FROM ticket_repos tr WHERE tr.ticket_id = tickets.id
			AND tr.pr_number IS NOT NULL AND tr.merged_at IS NULL AND tr.closed_at IS NULL)
		ORDER BY updated_at LIMIT $1`, limit)
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

// SetPRClosed records that a ticket's pull request in repoID was closed
// without a merge, or clears it on reopen. It reports whether anything
// changed. The ticket's own closed_at follows its primary repository's.
func (s *Agent) SetPRClosed(ctx context.Context, key string, repoID int64, closed bool) (bool, error) {
	changed := false
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// The ticket row first, as every other ticket write locks it: else
		// a save in flight could deadlock with this, or write back its
		// older copy of the row.
		var id int64
		if err := tx.QueryRow(ctx, `SELECT id FROM tickets WHERE key = $1 FOR UPDATE`, key).Scan(&id); err != nil {
			return notFound(err)
		}
		q := `UPDATE ticket_repos tr SET closed_at = now(), state = 'dropped' FROM tickets t
			WHERE t.id = tr.ticket_id AND t.key = $1 AND tr.repo_id = $2 AND tr.closed_at IS NULL AND tr.merged_at IS NULL`
		if !closed {
			q = `UPDATE ticket_repos tr SET closed_at = NULL, state = 'pushed' FROM tickets t
				WHERE t.id = tr.ticket_id AND t.key = $1 AND tr.repo_id = $2 AND tr.closed_at IS NOT NULL`
		}
		tag, err := tx.Exec(ctx, q, key, repoID)
		if err != nil {
			return err
		}
		changed = tag.RowsAffected() > 0
		q = `UPDATE tickets SET closed_at = now() WHERE key = $1 AND repo_id = $2 AND closed_at IS NULL AND merged_at IS NULL`
		if !closed {
			q = `UPDATE tickets SET closed_at = NULL WHERE key = $1 AND repo_id = $2 AND closed_at IS NOT NULL`
		}
		tag, err = tx.Exec(ctx, q, key, repoID)
		changed = changed || tag.RowsAffected() > 0
		return err
	})
	return changed, err
}

// SetRunAccount records which Claude account a run used.
func (s *Agent) SetRunAccount(ctx context.Context, runID int64, connection *int64, credits bool) error {
	_, err := s.db.Exec(ctx, `UPDATE runs SET claude_connection_id = $2, on_credits = $3 WHERE id = $1`, runID, connection, credits)
	return err
}

// ReopenForCI moves a done ticket whose pull request is still open back to
// coding, when domain.CanReopenForCI allows it at the time of the lock.
func (s *Agent) ReopenForCI(ctx context.Context, key string, ev domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error) {
	var out domain.Ticket
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		t, err := scanTicket(tx.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets WHERE key = $1 FOR UPDATE`, key))
		if err != nil {
			return err
		}
		if !domain.CanReopenForCI(t) {
			return &domain.TransitionError{Key: key, From: t.State, To: domain.StateCoding}
		}
		if mut != nil {
			mut(&t)
		}
		from := t.State
		t.State = domain.StateCoding
		if out, err = saveTicket(ctx, tx, t); err != nil {
			return err
		}
		if ev.Data == nil {
			ev.Data = map[string]any{}
		}
		ev.Data["from"], ev.Data["to"] = string(from), string(domain.StateCoding)
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}
