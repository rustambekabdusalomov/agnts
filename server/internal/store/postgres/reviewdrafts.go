package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.ReviewDrafts = (*Agent)(nil)

const reviewDraftCols = `d.id, d.ticket_id, d.repo_id, d.number, d.kind, d.key, d.severity, d.category, d.title, d.confidence, d.pass,
	d.path, d.line, d.head_sha, d.base_sha, d.start_sha, d.body, d.edited, d.state, d.dismiss_reason, d.error, d.post_id, d.noted,
	d.author_id, COALESCE(a.username, ''), d.decided_by, COALESCE(b.username, ''), d.decided_at, d.created_at, d.updated_at`

const reviewDraftFrom = ` FROM review_drafts d LEFT JOIN users a ON a.id = d.author_id LEFT JOIN users b ON b.id = d.decided_by`

func scanReviewDraft(row pgx.Row) (domain.ReviewDraft, error) {
	var d domain.ReviewDraft
	var conf float32
	err := row.Scan(&d.ID, &d.TicketID, &d.RepoID, &d.Number, &d.Kind, &d.Key, &d.Severity, &d.Category, &d.Title, &conf, &d.Pass,
		&d.Path, &d.Line, &d.HeadSHA, &d.BaseSHA, &d.StartSHA, &d.Body, &d.Edited, &d.State, &d.DismissReason, &d.Error, &d.PostID, &d.Noted,
		&d.AuthorID, &d.Author, &d.DecidedBy, &d.Decider, &d.DecidedAt, &d.CreatedAt, &d.UpdatedAt)
	d.Confidence = float64(conf)
	return d, notFound(err)
}

func scanReviewDrafts(rows pgx.Rows, err error) ([]domain.ReviewDraft, error) {
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.ReviewDraft{}
	for rows.Next() {
		d, err := scanReviewDraft(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, d)
	}
	return out, rows.Err()
}

// ReviewDrafts returns a ticket's drafts, the summary first, then by file
// and line.
func (s *Agent) ReviewDrafts(ctx context.Context, ticketID int64) ([]domain.ReviewDraft, error) {
	return scanReviewDrafts(s.db.Query(ctx, `SELECT `+reviewDraftCols+reviewDraftFrom+` WHERE d.ticket_id = $1
		ORDER BY d.kind <> 'summary', d.path, d.line, d.id LIMIT 500`, ticketID))
}

// ReviewDraft returns one draft of a ticket.
func (s *Agent) ReviewDraft(ctx context.Context, ticketID, id int64) (domain.ReviewDraft, error) {
	return scanReviewDraft(s.db.QueryRow(ctx, `SELECT `+reviewDraftCols+reviewDraftFrom+` WHERE d.ticket_id = $1 AND d.id = $2`, ticketID, id))
}

func lockDrafts(ctx context.Context, tx pgx.Tx, ticketID int64) ([]domain.ReviewDraft, error) {
	return scanReviewDrafts(tx.Query(ctx, `SELECT `+reviewDraftCols+reviewDraftFrom+` WHERE d.ticket_id = $1 ORDER BY d.id FOR UPDATE OF d`, ticketID))
}

func saveDraft(ctx context.Context, tx pgx.Tx, d domain.ReviewDraft) (int64, error) {
	if d.ID == 0 {
		var id int64
		err := tx.QueryRow(ctx, `INSERT INTO review_drafts (ticket_id, repo_id, number, kind, key, severity, category, title, confidence, pass,
				path, line, head_sha, base_sha, start_sha, body, edited, state, dismiss_reason, error, post_id, noted, author_id, decided_by, decided_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25) RETURNING id`,
			d.TicketID, d.RepoID, d.Number, d.Kind, d.Key, d.Severity, d.Category, d.Title, float32(d.Confidence), d.Pass,
			d.Path, d.Line, d.HeadSHA, d.BaseSHA, d.StartSHA, d.Body, d.Edited, d.State, d.DismissReason, d.Error, d.PostID, d.Noted,
			d.AuthorID, d.DecidedBy, d.DecidedAt).Scan(&id)
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return 0, domain.ErrConflict
		}
		return id, err
	}
	_, err := tx.Exec(ctx, `UPDATE review_drafts SET severity = $2, category = $3, title = $4, confidence = $5, pass = $6,
			path = $7, line = $8, head_sha = $9, base_sha = $10, start_sha = $11, body = $12, edited = $13, state = $14,
			dismiss_reason = $15, error = $16, post_id = $17, noted = $18, decided_by = $19, decided_at = $20, updated_at = now()
		WHERE id = $1`,
		d.ID, d.Severity, d.Category, d.Title, float32(d.Confidence), d.Pass, d.Path, d.Line, d.HeadSHA, d.BaseSHA, d.StartSHA,
		d.Body, d.Edited, d.State, d.DismissReason, d.Error, d.PostID, d.Noted, d.DecidedBy, d.DecidedAt)
	return d.ID, err
}

// SyncReviewDrafts locks a ticket's drafts, hands them to merge and saves
// what it returns, in one transaction: a person's edit made meanwhile
// waits for it and is applied after, never lost.
func (s *Agent) SyncReviewDrafts(ctx context.Context, ticketID int64, merge func([]domain.ReviewDraft) []domain.ReviewDraft) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		cur, err := lockDrafts(ctx, tx, ticketID)
		if err != nil {
			return err
		}
		for _, d := range merge(cur) {
			d.TicketID = ticketID
			if _, err := saveDraft(ctx, tx, d); err != nil {
				return err
			}
		}
		return nil
	})
}

// AddReviewDraft stores a new draft (a person's comment).
func (s *Agent) AddReviewDraft(ctx context.Context, d domain.ReviewDraft) (domain.ReviewDraft, error) {
	var id int64
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		id, err = saveDraft(ctx, tx, d)
		return err
	})
	if err != nil {
		return domain.ReviewDraft{}, err
	}
	return s.ReviewDraft(ctx, d.TicketID, id)
}

// UpdateReviewDraft changes one draft under a row lock: change sees the
// draft as it is now and may refuse with an error.
func (s *Agent) UpdateReviewDraft(ctx context.Context, ticketID, id int64, change func(*domain.ReviewDraft) error) (domain.ReviewDraft, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		d, err := scanReviewDraft(tx.QueryRow(ctx, `SELECT `+reviewDraftCols+reviewDraftFrom+` WHERE d.ticket_id = $1 AND d.id = $2 FOR UPDATE OF d`,
			ticketID, id))
		if err != nil {
			return err
		}
		if err := change(&d); err != nil {
			return err
		}
		_, err = saveDraft(ctx, tx, d)
		return err
	})
	if err != nil {
		return domain.ReviewDraft{}, err
	}
	return s.ReviewDraft(ctx, ticketID, id)
}

// UpdateReviewDrafts changes several drafts of a ticket in one
// transaction; change returns whether it changed one.
func (s *Agent) UpdateReviewDrafts(ctx context.Context, ticketID int64, change func(*domain.ReviewDraft) bool) ([]domain.ReviewDraft, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		cur, err := lockDrafts(ctx, tx, ticketID)
		if err != nil {
			return err
		}
		for _, d := range cur {
			if change(&d) {
				if _, err := saveDraft(ctx, tx, d); err != nil {
					return err
				}
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return s.ReviewDrafts(ctx, ticketID)
}

// DeleteReviewDraft removes a draft.
func (s *Agent) DeleteReviewDraft(ctx context.Context, ticketID, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM review_drafts WHERE ticket_id = $1 AND id = $2`, ticketID, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// ClaimReviewDrafts moves a ticket's accepted drafts to publishing and
// returns them, in one statement, so two publishes at once never post the
// same draft. Drafts left publishing since before stale (a crash) are
// accepted again first.
func (s *Agent) ClaimReviewDrafts(ctx context.Context, ticketID int64, stale time.Time) ([]domain.ReviewDraft, error) {
	if _, err := s.db.Exec(ctx, `UPDATE review_drafts SET state = 'accepted', updated_at = now()
		WHERE ticket_id = $1 AND state = 'publishing' AND updated_at < $2`, ticketID, stale); err != nil {
		return nil, err
	}
	return scanReviewDrafts(s.db.Query(ctx, `WITH c AS (
			UPDATE review_drafts SET state = 'publishing', error = '', updated_at = now()
			WHERE ticket_id = $1 AND state = 'accepted' RETURNING *)
		SELECT `+reviewDraftCols+` FROM c d LEFT JOIN users a ON a.id = d.author_id LEFT JOIN users b ON b.id = d.decided_by
		ORDER BY d.kind <> 'summary', d.path, d.line, d.id`, ticketID))
}

// FinishReviewDraft records how publishing a claimed draft ended:
// published (with its post), or accepted again with the error.
func (s *Agent) FinishReviewDraft(ctx context.Context, id int64, published bool, postID *int64, errMsg string) error {
	if published {
		_, err := s.db.Exec(ctx, `UPDATE review_drafts SET state = 'published', post_id = COALESCE($2, post_id), error = '', updated_at = now()
			WHERE id = $1 AND state = 'publishing'`, id, postID)
		return err
	}
	_, err := s.db.Exec(ctx, `UPDATE review_drafts SET state = 'accepted', error = $2, updated_at = now() WHERE id = $1 AND state = 'publishing'`,
		id, errMsg)
	return err
}
