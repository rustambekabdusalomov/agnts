package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// CreateGuest adds a guest of a document (g's name, email, via and user),
// with the hash of its token.
func (s *Documents) CreateGuest(ctx context.Context, g domain.DocumentGuest, tokenHash []byte) (domain.DocumentGuest, error) {
	err := s.db.QueryRow(ctx, `INSERT INTO document_guests (workspace_id, document_id, name, email, via, user_id, token_hash)
		SELECT workspace_id, id, $2, $3, $4, $5, $6 FROM documents WHERE id = $1 RETURNING id, created_at`,
		g.DocumentID, g.Name, g.Email, string(g.Via), g.UserID, tokenHash).Scan(&g.ID, &g.CreatedAt)
	return g, notFound(err)
}

// GuestByToken returns the guest whose token hashes to tokenHash, on the
// document docID; domain.ErrNotFound for anyone else.
func (s *Documents) GuestByToken(ctx context.Context, docID int64, tokenHash []byte) (domain.DocumentGuest, error) {
	var g domain.DocumentGuest
	var via string
	err := s.db.QueryRow(ctx, `SELECT id, document_id, name, email, via, user_id, created_at FROM document_guests
		WHERE token_hash = $1 AND document_id = $2`, tokenHash, docID).Scan(&g.ID, &g.DocumentID, &g.Name, &g.Email, &via, &g.UserID, &g.CreatedAt)
	g.Via = domain.GuestVia(via)
	return g, notFound(err)
}

const commentCols = `c.id, c.document_id, c.parent_id, c.author_user_id, c.author_guest_id, c.author_name, COALESCE(g.email, ''), COALESCE(g.via, ''),
	c.body, c.quote, c.prefix, c.suffix, c.slide, c.version, c.resolved_at, c.resolved_by, c.created_at, c.updated_at`

const commentFrom = ` FROM document_comments c LEFT JOIN document_guests g ON g.id = c.author_guest_id`

func scanComment(row pgx.Row) (domain.DocumentComment, error) {
	var c domain.DocumentComment
	var via string
	err := row.Scan(&c.ID, &c.DocumentID, &c.ParentID, &c.AuthorUserID, &c.AuthorGuestID, &c.AuthorName, &c.AuthorEmail, &via,
		&c.Body, &c.Quote, &c.Prefix, &c.Suffix, &c.Slide, &c.Version, &c.ResolvedAt, &c.ResolvedBy, &c.CreatedAt, &c.UpdatedAt)
	c.AuthorVia = domain.GuestVia(via)
	return c, notFound(err)
}

// Comments returns a document's comments, oldest first.
func (s *Documents) Comments(ctx context.Context, docID int64) ([]domain.DocumentComment, error) {
	rows, err := s.db.Query(ctx, `SELECT `+commentCols+commentFrom+` WHERE c.document_id = $1 ORDER BY c.created_at, c.id`, docID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.DocumentComment{}
	for rows.Next() {
		c, err := scanComment(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// Comment returns one comment.
func (s *Documents) Comment(ctx context.Context, id int64) (domain.DocumentComment, error) {
	return scanComment(s.db.QueryRow(ctx, `SELECT `+commentCols+commentFrom+` WHERE c.id = $1`, id))
}

// CreateComment adds a comment. A reply must answer a thread of the same
// document (domain.ErrNotFound otherwise).
func (s *Documents) CreateComment(ctx context.Context, c domain.DocumentComment) (domain.DocumentComment, error) {
	var id int64
	err := s.db.QueryRow(ctx, `INSERT INTO document_comments (workspace_id, document_id, parent_id, author_user_id, author_guest_id, author_name,
			body, quote, prefix, suffix, slide, version)
		SELECT d.workspace_id, d.id, $2, $3, $4, $5, $6, $7, $8, $9, $10, d.version FROM documents d
		WHERE d.id = $1 AND ($2::bigint IS NULL OR EXISTS (SELECT 1 FROM document_comments p WHERE p.id = $2 AND p.document_id = d.id AND p.parent_id IS NULL))
		RETURNING id`,
		c.DocumentID, c.ParentID, c.AuthorUserID, c.AuthorGuestID, c.AuthorName, c.Body, c.Quote, c.Prefix, c.Suffix, c.Slide).Scan(&id)
	if err != nil {
		return domain.DocumentComment{}, notFound(err)
	}
	return s.Comment(ctx, id)
}

// EditComment changes a comment's text.
func (s *Documents) EditComment(ctx context.Context, id int64, body string) (domain.DocumentComment, error) {
	if _, err := s.db.Exec(ctx, `UPDATE document_comments SET body = $2, updated_at = now() WHERE id = $1`, id, body); err != nil {
		return domain.DocumentComment{}, err
	}
	return s.Comment(ctx, id)
}

// ResolveComment resolves a thread (by names who did it) or reopens it.
func (s *Documents) ResolveComment(ctx context.Context, id int64, resolved bool, by string) (domain.DocumentComment, error) {
	var err error
	if resolved {
		_, err = s.db.Exec(ctx, `UPDATE document_comments SET resolved_at = now(), resolved_by = $2, updated_at = now() WHERE id = $1`, id, by)
	} else {
		_, err = s.db.Exec(ctx, `UPDATE document_comments SET resolved_at = NULL, resolved_by = '', updated_at = now() WHERE id = $1`, id)
	}
	if err != nil {
		return domain.DocumentComment{}, err
	}
	return s.Comment(ctx, id)
}

// DeleteComment removes a comment and, for a thread, its replies.
func (s *Documents) DeleteComment(ctx context.Context, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM document_comments WHERE id = $1`, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// OpenThreads counts a document's unresolved threads.
func (s *Documents) OpenThreads(ctx context.Context, docID int64) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM document_comments WHERE document_id = $1 AND parent_id IS NULL AND resolved_at IS NULL`, docID).Scan(&n)
	return n, err
}

// GuestCommentsSince counts what a guest posted since a time, for the rate limit.
func (s *Documents) GuestCommentsSince(ctx context.Context, guestID int64, since time.Time) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM document_comments WHERE author_guest_id = $1 AND created_at > $2`, guestID, since).Scan(&n)
	return n, err
}

// CommentsStamp changes whenever a document's comments do: added, edited,
// resolved or deleted. Pages compare it to know when to fetch them again.
func (s *Documents) CommentsStamp(ctx context.Context, docID int64) (string, error) {
	var n int
	var at *time.Time
	if err := s.db.QueryRow(ctx, `SELECT count(*), max(updated_at) FROM document_comments WHERE document_id = $1`, docID).Scan(&n, &at); err != nil {
		return "", err
	}
	if at == nil {
		return "0", nil
	}
	return fmt.Sprintf("%d-%d", n, at.UnixMicro()), nil
}

// UserName is the name a person is shown by: their display name, else
// their username.
func (s *Documents) UserName(ctx context.Context, userID int64) (string, error) {
	var name string
	err := s.db.QueryRow(ctx, `SELECT COALESCE(NULLIF(display_name, ''), username) FROM users WHERE id = $1`, userID).Scan(&name)
	return name, notFound(err)
}
