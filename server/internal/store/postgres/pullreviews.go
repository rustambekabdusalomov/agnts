package postgres

import (
	"context"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.PullReviews = (*Agent)(nil)

// TicketByPull returns the newest review ticket of pull request number in
// repoID, or domain.ErrNotFound.
func (s *Agent) TicketByPull(ctx context.Context, repoID int64, number int) (domain.Ticket, error) {
	return scanTicket(s.db.QueryRow(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE repo_id = $1 AND pr_number = $2 AND kind = 'review' ORDER BY id DESC LIMIT 1`, repoID, number))
}

// OpenReviews returns the review tickets that are not done or rejected,
// oldest first.
func (s *Agent) OpenReviews(ctx context.Context) ([]domain.Ticket, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE kind = 'review' AND state NOT IN ('done', 'rejected') ORDER BY id LIMIT 500`)
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

const noteCols = `n.id, n.workspace_id, n.login, n.user_id, COALESCE(u.username, ''), n.repo_id, COALESCE(r.name, ''),
	n.ticket_key, n.pull_title, n.kind, n.note, n.created_at`

const noteFrom = ` FROM reviewer_notes n LEFT JOIN users u ON u.id = n.user_id LEFT JOIN repositories r ON r.id = n.repo_id`

func scanNote(row pgx.Row) (domain.ReviewerNote, error) {
	var n domain.ReviewerNote
	err := row.Scan(&n.ID, &n.WorkspaceID, &n.Login, &n.UserID, &n.Username, &n.RepoID, &n.RepoName,
		&n.TicketKey, &n.PullTitle, &n.Kind, &n.Note, &n.CreatedAt)
	return n, notFound(err)
}

// AddReviewerNote stores a note about a review.
func (s *Agent) AddReviewerNote(ctx context.Context, n domain.ReviewerNote) (domain.ReviewerNote, error) {
	if a, ok := domain.ActorOf(ctx); ok && n.UserID == nil {
		n.UserID = &a.UserID
	}
	var id int64
	if err := s.db.QueryRow(ctx, `INSERT INTO reviewer_notes (login, user_id, repo_id, ticket_key, pull_title, kind, note)
		VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
		n.Login, n.UserID, n.RepoID, n.TicketKey, n.PullTitle, n.Kind, n.Note).Scan(&id); err != nil {
		return n, err
	}
	return scanNote(s.db.QueryRow(ctx, `SELECT `+noteCols+noteFrom+` WHERE n.id = $1`, id))
}

// ReviewerNotes returns login's notes newer than afterID, newest first, at
// most limit; an empty login gives everyone's.
func (s *Agent) ReviewerNotes(ctx context.Context, login string, afterID int64, limit int) ([]domain.ReviewerNote, error) {
	if limit <= 0 || limit > 500 {
		limit = 200
	}
	rows, err := s.db.Query(ctx, `SELECT `+noteCols+noteFrom+`
		WHERE ($1 = '' OR n.login = $1) AND n.id > $2 ORDER BY n.id DESC LIMIT $3`, login, afterID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.ReviewerNote
	for rows.Next() {
		n, err := scanNote(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, n)
	}
	return out, rows.Err()
}

// DeleteReviewerNote removes a note; domain.ErrNotFound when there is none.
func (s *Agent) DeleteReviewerNote(ctx context.Context, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM reviewer_notes WHERE id = $1`, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

const profileCols = `workspace_id, login, body, learned_through, notes, updated_at`

func scanProfile(row pgx.Row) (domain.ReviewerProfile, error) {
	var p domain.ReviewerProfile
	err := row.Scan(&p.WorkspaceID, &p.Login, &p.Body, &p.LearnedThrough, &p.Notes, &p.UpdatedAt)
	return p, notFound(err)
}

// ReviewerProfiles returns every profile, by login.
func (s *Agent) ReviewerProfiles(ctx context.Context) ([]domain.ReviewerProfile, error) {
	rows, err := s.db.Query(ctx, `SELECT `+profileCols+` FROM reviewer_profiles ORDER BY login`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.ReviewerProfile
	for rows.Next() {
		p, err := scanProfile(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// ReviewerProfile returns login's profile, or domain.ErrNotFound.
func (s *Agent) ReviewerProfile(ctx context.Context, login string) (domain.ReviewerProfile, error) {
	return scanProfile(s.db.QueryRow(ctx, `SELECT `+profileCols+` FROM reviewer_profiles WHERE login = $1`, login))
}

// SaveReviewerProfile stores body as login's profile. learnedThrough > 0
// also records that the notes up to it were folded in (folded more of
// them); it never moves back.
func (s *Agent) SaveReviewerProfile(ctx context.Context, login, body string, learnedThrough int64, folded int) (domain.ReviewerProfile, error) {
	return scanProfile(s.db.QueryRow(ctx, `INSERT INTO reviewer_profiles (login, body, learned_through, notes)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (workspace_id, login) DO UPDATE SET body = $2,
			learned_through = GREATEST(reviewer_profiles.learned_through, $3),
			notes = reviewer_profiles.notes + $4, updated_at = now()
		RETURNING `+profileCols, login, body, learnedThrough, folded))
}
