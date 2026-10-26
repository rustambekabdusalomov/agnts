package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

const attachmentCols = `id, ticket_id, question_id, purpose, name, content_type, size, created_at`

func scanAttachment(row pgx.Row) (domain.Attachment, error) {
	var a domain.Attachment
	var purpose string
	err := row.Scan(&a.ID, &a.TicketID, &a.QuestionID, &purpose, &a.Name, &a.ContentType, &a.Size, &a.CreatedAt)
	a.Purpose = domain.AttachmentPurpose(purpose)
	return a, notFound(err)
}

// SaveAttachment stores an upload as pending.
func (s *Agent) SaveAttachment(ctx context.Context, a domain.Attachment, data []byte) (domain.Attachment, error) {
	return scanAttachment(s.db.QueryRow(ctx, `INSERT INTO attachments (purpose, name, content_type, size, data)
		VALUES ('pending', $1, $2, $3, $4) RETURNING `+attachmentCols,
		a.Name, a.ContentType, int64(len(data)), data))
}

// Attachments returns attachments by id, in the order given; unknown ids
// are left out.
func (s *Agent) Attachments(ctx context.Context, ids []int64) ([]domain.Attachment, error) {
	rows, err := s.db.Query(ctx, `SELECT `+attachmentCols+` FROM attachments WHERE id = ANY($1)
		ORDER BY array_position($1, id)`, ids)
	if err != nil {
		return nil, err
	}
	return collectAttachments(rows)
}

// TicketAttachments returns a ticket's attachments, oldest first.
func (s *Agent) TicketAttachments(ctx context.Context, ticketID int64) ([]domain.Attachment, error) {
	rows, err := s.db.Query(ctx, `SELECT `+attachmentCols+` FROM attachments WHERE ticket_id = $1 ORDER BY id`, ticketID)
	if err != nil {
		return nil, err
	}
	return collectAttachments(rows)
}

func collectAttachments(rows pgx.Rows) ([]domain.Attachment, error) {
	defer rows.Close()
	out := []domain.Attachment{}
	for rows.Next() {
		a, err := scanAttachment(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

// AttachmentData returns an attachment with its bytes.
func (s *Agent) AttachmentData(ctx context.Context, id int64) (domain.Attachment, []byte, error) {
	var a domain.Attachment
	var purpose string
	var data []byte
	err := s.db.QueryRow(ctx, `SELECT `+attachmentCols+`, data FROM attachments WHERE id = $1`, id).
		Scan(&a.ID, &a.TicketID, &a.QuestionID, &purpose, &a.Name, &a.ContentType, &a.Size, &a.CreatedAt, &data)
	a.Purpose = domain.AttachmentPurpose(purpose)
	return a, data, notFound(err)
}

// LinkAttachments links pending uploads to a ticket (and a question, for
// answers), or fails with ErrConflict when one is not pending any more.
func (s *Agent) LinkAttachments(ctx context.Context, ids []int64, ticketID int64, questionID *int64, purpose domain.AttachmentPurpose) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		return linkAttachments(ctx, tx, ids, ticketID, questionID, purpose)
	})
}

func linkAttachments(ctx context.Context, tx pgx.Tx, ids []int64, ticketID int64, questionID *int64, purpose domain.AttachmentPurpose) error {
	if len(ids) == 0 {
		return nil
	}
	tag, err := tx.Exec(ctx, `UPDATE attachments SET ticket_id = $2, question_id = $3, purpose = $4
		WHERE id = ANY($1) AND purpose = 'pending'`, ids, ticketID, questionID, string(purpose))
	if err != nil {
		return err
	}
	if tag.RowsAffected() != int64(len(ids)) {
		return fmt.Errorf("attachments already used or gone: %w", domain.ErrConflict)
	}
	return nil
}

// DeleteAttachments deletes attachments by id.
func (s *Agent) DeleteAttachments(ctx context.Context, ids []int64) error {
	if len(ids) == 0 {
		return nil
	}
	_, err := s.db.Exec(ctx, `DELETE FROM attachments WHERE id = ANY($1)`, ids)
	return err
}

// PrunePendingAttachments deletes uploads nobody used that are older than
// before, and returns how many. Uploads an answer draft names are kept
// while its ticket waits for the answers; a ticket rejected or closed
// before they were sent lets them go.
func (s *Agent) PrunePendingAttachments(ctx context.Context, before time.Time) (int64, error) {
	tag, err := s.db.Exec(ctx, `DELETE FROM attachments WHERE purpose = 'pending' AND created_at < $1
		AND id NOT IN (SELECT jsonb_array_elements_text(q.draft_attachments)::bigint FROM questions q
			JOIN tickets t ON t.id = q.ticket_id
			WHERE q.draft_attachments <> '[]' AND t.state = 'waiting_for_answers')`, before)
	return tag.RowsAffected(), err
}
