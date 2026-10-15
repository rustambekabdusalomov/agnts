package postgres

import (
	"context"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.PRPosts = (*Agent)(nil)

const prPostCols = `id, repo_id, number, ticket_id, comment_id, thread_id, kind, finding_key, head_sha, resolved, posted_by, created_at`

func scanPRPost(row pgx.Row) (domain.PRPost, error) {
	var p domain.PRPost
	err := row.Scan(&p.ID, &p.RepoID, &p.Number, &p.TicketID, &p.CommentID, &p.ThreadID, &p.Kind, &p.FindingKey,
		&p.HeadSHA, &p.Resolved, &p.PostedBy, &p.CreatedAt)
	return p, notFound(err)
}

// AddPRPost records a comment agnts posted; posting the same comment
// again updates the record.
func (s *Agent) AddPRPost(ctx context.Context, p domain.PRPost) (domain.PRPost, error) {
	if a, ok := domain.ActorOf(ctx); ok && p.PostedBy == nil && a.UserID > 0 {
		p.PostedBy = &a.UserID
	}
	return scanPRPost(s.db.QueryRow(ctx, `INSERT INTO pr_posts
		(repo_id, number, ticket_id, comment_id, thread_id, kind, finding_key, head_sha, posted_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (repo_id, number, comment_id) DO UPDATE SET thread_id = EXCLUDED.thread_id, kind = EXCLUDED.kind,
			finding_key = EXCLUDED.finding_key, head_sha = EXCLUDED.head_sha
		RETURNING `+prPostCols,
		p.RepoID, p.Number, p.TicketID, p.CommentID, p.ThreadID, p.Kind, p.FindingKey, p.HeadSHA, p.PostedBy))
}

// PRPosts returns what agnts posted on a pull request, oldest first.
func (s *Agent) PRPosts(ctx context.Context, repoID int64, number int) ([]domain.PRPost, error) {
	rows, err := s.db.Query(ctx, `SELECT `+prPostCols+` FROM pr_posts WHERE repo_id = $1 AND number = $2 ORDER BY id LIMIT 1000`, repoID, number)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.PRPost
	for rows.Next() {
		p, err := scanPRPost(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// UpdatePRPost stores a post's commit and whether agnts resolved its thread.
func (s *Agent) UpdatePRPost(ctx context.Context, id int64, headSHA string, resolved bool) error {
	_, err := s.db.Exec(ctx, `UPDATE pr_posts SET head_sha = $2, resolved = $3 WHERE id = $1`, id, headSHA, resolved)
	return err
}

// DeletePRPost forgets a comment that was deleted.
func (s *Agent) DeletePRPost(ctx context.Context, repoID int64, number int, commentID string) error {
	_, err := s.db.Exec(ctx, `DELETE FROM pr_posts WHERE repo_id = $1 AND number = $2 AND comment_id = $3`, repoID, number, commentID)
	return err
}

// SaveThreadFeedback records reviewer threads sent back to a ticket; a
// thread sent again is reset to not answered.
func (s *Agent) SaveThreadFeedback(ctx context.Context, fs []domain.PRThreadFeedback) error {
	if len(fs) == 0 {
		return nil
	}
	b := &pgx.Batch{}
	for _, f := range fs {
		b.Queue(`INSERT INTO pr_thread_feedback (ticket_id, repo_id, number, thread_id, last_comment_id, revision)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (ticket_id, thread_id) DO UPDATE SET last_comment_id = EXCLUDED.last_comment_id,
				revision = EXCLUDED.revision, replied = false`,
			f.TicketID, f.RepoID, f.Number, f.ThreadID, f.LastCommentID, f.Revision)
	}
	return s.db.SendBatch(ctx, b).Close()
}

// ThreadFeedback returns the reviewer threads sent back to a ticket.
func (s *Agent) ThreadFeedback(ctx context.Context, ticketID int64) ([]domain.PRThreadFeedback, error) {
	rows, err := s.db.Query(ctx, `SELECT ticket_id, repo_id, number, thread_id, last_comment_id, revision, replied, created_at
		FROM pr_thread_feedback WHERE ticket_id = $1 ORDER BY created_at, thread_id`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.PRThreadFeedback
	for rows.Next() {
		var f domain.PRThreadFeedback
		if err := rows.Scan(&f.TicketID, &f.RepoID, &f.Number, &f.ThreadID, &f.LastCommentID, &f.Revision, &f.Replied, &f.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

// MarkThreadReplied records that agnts answered a reviewer's thread.
func (s *Agent) MarkThreadReplied(ctx context.Context, ticketID int64, threadID string) error {
	_, err := s.db.Exec(ctx, `UPDATE pr_thread_feedback SET replied = true WHERE ticket_id = $1 AND thread_id = $2`, ticketID, threadID)
	return err
}
