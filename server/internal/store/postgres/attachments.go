package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

const attachmentCols = `id, ticket_id, question_id, chat_message_id, assistant_message_id, uploaded_by,
	purpose, name, content_type, size, created_at`

func attachmentDest(a *domain.Attachment, purpose *string) []any {
	return []any{&a.ID, &a.TicketID, &a.QuestionID, &a.ChatMessageID, &a.AssistantMessageID, &a.UploadedBy,
		purpose, &a.Name, &a.ContentType, &a.Size, &a.CreatedAt}
}

func scanAttachment(row pgx.Row) (domain.Attachment, error) {
	var a domain.Attachment
	var purpose string
	err := row.Scan(attachmentDest(&a, &purpose)...)
	a.Purpose = domain.AttachmentPurpose(purpose)
	return a, notFound(err)
}

// SaveAttachment stores an upload as pending, as a.UploadedBy's.
func (s *Agent) SaveAttachment(ctx context.Context, a domain.Attachment, data []byte) (domain.Attachment, error) {
	return scanAttachment(s.db.QueryRow(ctx, `INSERT INTO attachments (purpose, name, content_type, size, data, uploaded_by)
		VALUES ('pending', $1, $2, $3, $4, $5) RETURNING `+attachmentCols,
		a.Name, a.ContentType, int64(len(data)), data, a.UploadedBy))
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
		Scan(append(attachmentDest(&a, &purpose), &data)...)
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

// AssistantFileOwner returns whose conversation assistant message id is
// in: only they may open its files.
func (s *Agent) AssistantFileOwner(ctx context.Context, messageID int64) (int64, error) {
	var user int64
	err := s.db.QueryRow(ctx, `SELECT c.user_id FROM assistant_messages m
		JOIN assistant_conversations c ON c.id = m.conversation_id WHERE m.id = $1`, messageID).Scan(&user)
	return user, notFound(err)
}

// linkMessageFiles links user's pending uploads ids to a chat message
// (col chat_message_id) or an assistant message (assistant_message_id),
// or fails with ErrConflict when one is not a pending upload of theirs.
func linkMessageFiles(ctx context.Context, tx pgx.Tx, ids []int64, col string, msg, user int64, purpose domain.AttachmentPurpose) error {
	if len(ids) == 0 {
		return nil
	}
	tag, err := tx.Exec(ctx, `UPDATE attachments SET `+col+` = $2, purpose = $3
		WHERE id = ANY($1) AND purpose = 'pending' AND (uploaded_by IS NULL OR uploaded_by = $4)`,
		ids, msg, string(purpose), user)
	if err != nil {
		return err
	}
	if tag.RowsAffected() != int64(len(ids)) {
		return fmt.Errorf("attachments already used or gone: %w", domain.ErrConflict)
	}
	if col == "chat_message_id" {
		_, err = tx.Exec(ctx, `UPDATE chat_messages SET file_names = (SELECT string_agg(replace(name, '_', ' '), ' ' ORDER BY id)
			FROM attachments WHERE chat_message_id = $1) WHERE id = $1`, msg)
	}
	return err
}

// LinkAssistantFiles links user's pending uploads to their Ask question.
func (s *Agent) LinkAssistantFiles(ctx context.Context, ids []int64, messageID, user int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		return linkMessageFiles(ctx, tx, ids, "assistant_message_id", messageID, user, domain.AttachAssistant)
	})
}

// fileRefs returns the files linked to each message of ids, by the
// owner column col, oldest first.
func fileRefs(ctx context.Context, q interface {
	Query(context.Context, string, ...any) (pgx.Rows, error)
}, col string, ids []int64) (map[int64][]domain.FileRef, error) {
	out := map[int64][]domain.FileRef{}
	if len(ids) == 0 {
		return out, nil
	}
	rows, err := q.Query(ctx, `SELECT `+attachmentCols+` FROM attachments WHERE `+col+` = ANY($1) ORDER BY id`, ids)
	if err != nil {
		return nil, err
	}
	as, err := collectAttachments(rows)
	if err != nil {
		return nil, err
	}
	for _, a := range as {
		var owner int64
		if col == "chat_message_id" {
			owner = *a.ChatMessageID
		} else {
			owner = *a.AssistantMessageID
		}
		out[owner] = append(out[owner], a.Ref())
	}
	return out, nil
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
