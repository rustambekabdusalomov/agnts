package postgres

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// The assistant's proposed actions are pending actions with origin
// assistant, bound to the person who asked and the answer that proposed
// them. Only that person confirms or declines one, once.

const assistantActionCols = `p.id, COALESCE(p.assistant_message_id, 0), COALESCE(m.conversation_id, 0), p.tool, p.ticket_key, p.summary,
	CASE WHEN p.outcome IS NOT NULL THEN p.outcome WHEN p.confirmed_at IS NOT NULL THEN 'running'
		WHEN p.expires_at <= now() THEN 'expired' ELSE 'proposed' END,
	p.result, p.expires_at`

func scanAssistantAction(row pgx.Row) (domain.AssistantAction, error) {
	var a domain.AssistantAction
	var status string
	if err := row.Scan(&a.ID, &a.MessageID, &a.ConversationID, &a.Tool, &a.TicketKey, &a.Summary, &status, &a.Result, &a.ExpiresAt); err != nil {
		return a, notFound(err)
	}
	a.Status, a.Destructive = domain.AssistantActionStatus(status), domain.DestructiveAction(a.Tool)
	return a, nil
}

// AssistantAction returns one of userID's proposed actions.
func (s *Agent) AssistantAction(ctx context.Context, userID int64, id string) (domain.AssistantAction, error) {
	return scanAssistantAction(s.db.QueryRow(ctx, `SELECT `+assistantActionCols+` FROM pending_actions p
		LEFT JOIN assistant_messages m ON m.id = p.assistant_message_id
		WHERE p.id = $1 AND p.origin = 'assistant' AND p.user_id = $2`, id, userID))
}

// ConfirmAssistantAction marks one of userID's proposed actions confirmed,
// exactly once, and returns it to run. Another person's or an unknown
// action is domain.ErrNotFound; one that is expired, declined or already
// confirmed is ErrExpired.
func (s *Agent) ConfirmAssistantAction(ctx context.Context, userID int64, id string) (PendingAction, error) {
	a := PendingAction{Origin: domain.OriginAssistant, UserID: userID}
	var args []byte
	var msg *int64
	err := s.db.QueryRow(ctx, `UPDATE pending_actions SET confirmed_at = now()
		WHERE id = $1 AND origin = 'assistant' AND user_id = $2 AND confirmed_at IS NULL AND outcome IS NULL AND expires_at > now()
		RETURNING id, tool, ticket_key, args, summary, expires_at, workspace_id, assistant_message_id`, id, userID).
		Scan(&a.ID, &a.Tool, &a.TicketKey, &args, &a.Summary, &a.ExpiresAt, &a.WorkspaceID, &msg)
	if errors.Is(err, pgx.ErrNoRows) {
		return a, s.assistantActionGone(ctx, userID, id)
	}
	if err != nil {
		return a, err
	}
	if msg != nil {
		a.MessageID = *msg
	}
	_ = json.Unmarshal(args, &a.Args)
	return a, nil
}

// CancelAssistantAction declines one of userID's proposed actions.
func (s *Agent) CancelAssistantAction(ctx context.Context, userID int64, id string) error {
	tag, err := s.db.Exec(ctx, `UPDATE pending_actions SET outcome = 'cancelled', finished_at = now()
		WHERE id = $1 AND origin = 'assistant' AND user_id = $2 AND confirmed_at IS NULL AND outcome IS NULL AND expires_at > now()`, id, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return s.assistantActionGone(ctx, userID, id)
	}
	return nil
}

// assistantActionGone says why an action could not be confirmed or
// declined: it is not userID's (or not there), or its time has passed.
func (s *Agent) assistantActionGone(ctx context.Context, userID int64, id string) error {
	var ok bool
	if err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM pending_actions WHERE id = $1 AND origin = 'assistant' AND user_id = $2)`,
		id, userID).Scan(&ok); err != nil {
		return err
	}
	if !ok {
		return domain.ErrNotFound
	}
	return ErrExpired
}

// FinishAssistantAction stores what a confirmed action did: outcome done
// or failed, its result, and the ticket it made (when it made one).
func (s *Agent) FinishAssistantAction(ctx context.Context, id string, outcome domain.AssistantActionStatus, result, ticketKey string) error {
	_, err := s.db.Exec(ctx, `UPDATE pending_actions SET outcome = $2, result = $3, finished_at = now(),
		ticket_key = CASE WHEN $4 = '' THEN ticket_key ELSE $4 END
		WHERE id = $1 AND origin = 'assistant'`, id, string(outcome), result, ticketKey)
	return err
}

// attachAssistantActions loads the actions each of msgs proposed.
func attachAssistantActions(ctx context.Context, db *pgxpool.Pool, msgs []domain.AssistantMessage) error {
	var ids []int64
	for _, m := range msgs {
		if m.Role == domain.AssistantReply {
			ids = append(ids, m.ID)
		}
	}
	by, err := assistantActionsOf(ctx, db, ids)
	if err != nil {
		return err
	}
	for i := range msgs {
		msgs[i].Actions = by[msgs[i].ID]
	}
	return nil
}

// assistantActionsOf returns the actions the answers ids proposed, by
// answer, oldest first.
func assistantActionsOf(ctx context.Context, db *pgxpool.Pool, ids []int64) (map[int64][]domain.AssistantAction, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	rows, err := db.Query(ctx, `SELECT `+assistantActionCols+` FROM pending_actions p
		JOIN assistant_messages m ON m.id = p.assistant_message_id
		WHERE p.origin = 'assistant' AND p.assistant_message_id = ANY($1) ORDER BY p.created_at, p.id`, ids)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64][]domain.AssistantAction{}
	for rows.Next() {
		a, err := scanAssistantAction(rows)
		if err != nil {
			return nil, err
		}
		out[a.MessageID] = append(out[a.MessageID], a)
	}
	return out, rows.Err()
}
