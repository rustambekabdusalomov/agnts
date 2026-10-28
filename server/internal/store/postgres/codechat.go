package postgres

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Code-mode conversations: the repositories they work in and the tickets
// they drive. Like Chat ones, every read names the person.

// repoChoiceJSON is domain.RepoChoice as stored in repo_choice.
type repoChoiceJSON struct {
	RepoID  int64   `json:"repo_id,omitempty"`
	RepoIDs []int64 `json:"repo_ids,omitempty"`
	GroupID int64   `json:"group_id,omitempty"`
}

func (r repoChoiceJSON) choice() domain.RepoChoice {
	return domain.RepoChoice{RepoID: r.RepoID, RepoIDs: r.RepoIDs, GroupID: r.GroupID}
}

func repoChoiceOf(c domain.RepoChoice) ([]byte, error) {
	return json.Marshal(repoChoiceJSON{RepoID: c.RepoID, RepoIDs: c.RepoIDs, GroupID: c.GroupID})
}

// CreateCodeConversation starts a Code conversation of userID working in
// repos.
func (s *Assistant) CreateCodeConversation(ctx context.Context, userID int64, title string, repos domain.RepoChoice, kind string, quick bool) (domain.AssistantConversation, error) {
	rc, err := repoChoiceOf(repos)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	c := domain.AssistantConversation{UserID: userID, Title: title, Mode: domain.ChatModeCode, Repos: repos, Kind: kind, Quick: quick}
	err = s.db.QueryRow(ctx, `INSERT INTO assistant_conversations (user_id, title, mode, repo_choice, kind, quick)
		VALUES ($1, $2, 'code', $3, $4, $5) RETURNING id, created_at, updated_at`, userID, title, rc, kind, quick).
		Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
	return c, err
}

// SetCodeRepos changes the repositories of one of userID's Code
// conversations.
func (s *Assistant) SetCodeRepos(ctx context.Context, userID, id int64, repos domain.RepoChoice) error {
	rc, err := repoChoiceOf(repos)
	if err != nil {
		return err
	}
	tag, err := s.db.Exec(ctx, `UPDATE assistant_conversations SET repo_choice = $3, updated_at = now()
		WHERE id = $1 AND user_id = $2 AND mode = 'code'`, id, userID, rc)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// LinkCodeTicket makes the ticket key the current ticket of a Code
// conversation. A ticket lives in one of a person's conversations at a
// time: the one it was in before is returned (0 for none) and no longer
// has it.
func (s *Assistant) LinkCodeTicket(ctx context.Context, conversationID int64, key string) (int64, error) {
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return 0, err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	var ticketID, userID int64
	if err := tx.QueryRow(ctx, `SELECT id FROM tickets WHERE key = $1`, key).Scan(&ticketID); err != nil {
		return 0, notFound(err)
	}
	if err := tx.QueryRow(ctx, `SELECT user_id FROM assistant_conversations WHERE id = $1 FOR UPDATE`, conversationID).Scan(&userID); err != nil {
		return 0, notFound(err)
	}
	var from int64
	err = tx.QueryRow(ctx, `UPDATE code_conversation_tickets SET detached_at = now()
		WHERE ticket_id = $1 AND user_id = $2 AND detached_at IS NULL RETURNING conversation_id`, ticketID, userID).Scan(&from)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return 0, err
	}
	if from == conversationID {
		// Already here: the old row goes, and a new one makes it current.
		if _, err := tx.Exec(ctx, `DELETE FROM code_conversation_tickets WHERE ticket_id = $1 AND conversation_id = $2`, ticketID, conversationID); err != nil {
			return 0, err
		}
		from = 0
	}
	if _, err := tx.Exec(ctx, `INSERT INTO code_conversation_tickets (conversation_id, user_id, ticket_id) VALUES ($1, $2, $3)`,
		conversationID, userID, ticketID); err != nil {
		return 0, err
	}
	if _, err := tx.Exec(ctx, `UPDATE assistant_conversations SET updated_at = now() WHERE id = $1`, conversationID); err != nil {
		return 0, err
	}
	return from, tx.Commit(ctx)
}

// codeTickets returns the tickets of conversations, oldest first;
// currentOnly keeps only each one's current ticket (lists).
func (s *Assistant) codeTickets(ctx context.Context, conversations []int64, currentOnly bool) (map[int64][]domain.CodeTicket, error) {
	out := map[int64][]domain.CodeTicket{}
	if len(conversations) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `WITH cur AS (
			SELECT conversation_id, max(id) AS id FROM code_conversation_tickets
			WHERE conversation_id = ANY($1) AND detached_at IS NULL GROUP BY conversation_id)
		SELECT l.conversation_id, t.key, t.title, t.state, t.kind, l.attached_at, l.detached_at IS NOT NULL, cur.id IS NOT NULL,
			COALESCE((SELECT array_agg(r.name ORDER BY tr.position) FROM ticket_repos tr JOIN repositories r ON r.id = tr.repo_id
				WHERE tr.ticket_id = t.id), '{}')
		FROM code_conversation_tickets l JOIN tickets t ON t.id = l.ticket_id LEFT JOIN cur ON cur.id = l.id
		WHERE l.conversation_id = ANY($1) AND (NOT $2 OR cur.id IS NOT NULL) ORDER BY l.id`, conversations, currentOnly)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var conv int64
		var t domain.CodeTicket
		var state, kind string
		if err := rows.Scan(&conv, &t.Key, &t.Title, &state, &kind, &t.AttachedAt, &t.Moved, &t.Current, &t.Repos); err != nil {
			return nil, err
		}
		t.State, t.Kind = domain.TicketState(state), domain.TicketKind(kind)
		out[conv] = append(out[conv], t)
	}
	return out, rows.Err()
}

// SetCodeRouted records what Code messages ids did, and to which ticket;
// failed ones get why in their error.
func (s *Assistant) SetCodeRouted(ctx context.Context, ids []int64, routed domain.CodeRouted, key, why string) error {
	_, err := s.db.Exec(ctx, `UPDATE assistant_messages SET routed = $2, ticket_key = $3, error = $4,
		status = CASE WHEN $2 = 'failed' THEN 'failed' ELSE status END WHERE id = ANY($1)`, ids, string(routed), key, why)
	return err
}

// QueuedCodeMessages returns the messages of a conversation waiting for
// ticket key's running stage to end, oldest first.
func (s *Assistant) QueuedCodeMessages(ctx context.Context, conversationID int64, key string) ([]domain.AssistantMessage, error) {
	rows, err := s.db.Query(ctx, `SELECT `+assistantMsgCols+` FROM assistant_messages m
		WHERE m.routed = 'queued' AND m.conversation_id = $1 AND m.ticket_key = $2 ORDER BY m.id`, conversationID, key)
	if err != nil {
		return nil, err
	}
	return scanAssistantMsgs(rows)
}

// QueuedCodeTickets returns, in every workspace, the tickets that stopped
// running while Code messages waited for them.
func (s *Assistant) QueuedCodeTickets(ctx context.Context) ([]orchestrator.QueuedCode, error) {
	rows, err := s.db.Query(domain.System(ctx), `SELECT DISTINCT ON (m.ticket_key, c.id) c.workspace_id, c.user_id, COALESCE(u.username, ''), c.id, m.ticket_key
		FROM assistant_messages m JOIN assistant_conversations c ON c.id = m.conversation_id
		JOIN tickets t ON t.workspace_id = c.workspace_id AND t.key = m.ticket_key LEFT JOIN users u ON u.id = c.user_id
		WHERE m.routed = 'queued' AND t.state IN ('waiting_for_answers', 'waiting_for_review', 'failed', 'rate_limited', 'rejected', 'done')
		ORDER BY m.ticket_key, c.id, m.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.QueuedCode
	for rows.Next() {
		var q orchestrator.QueuedCode
		if err := rows.Scan(&q.WorkspaceID, &q.UserID, &q.Username, &q.ConversationID, &q.TicketKey); err != nil {
			return nil, err
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

// CodeEvents returns the newest limit events of tickets keys whose type is
// one of types, oldest first.
func (s *Assistant) CodeEvents(ctx context.Context, keys, types []string, limit int) ([]domain.Event, error) {
	if len(keys) == 0 {
		return nil, nil
	}
	rows, err := s.db.Query(ctx, `SELECT * FROM (SELECT `+eventCols+` FROM `+eventFrom+`
		WHERE e.ticket_key = ANY($1) AND e.type = ANY($2) ORDER BY e.id DESC LIMIT $3) x ORDER BY id`, keys, types, limit)
	if err != nil {
		return nil, err
	}
	return scanEvents(rows)
}

// RunningCodeTickets counts userID's current Code tickets that are being
// worked on (not waiting for them, and not finished).
func (s *Assistant) RunningCodeTickets(ctx context.Context, userID int64) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM code_conversation_tickets l
		JOIN assistant_conversations c ON c.id = l.conversation_id JOIN tickets t ON t.id = l.ticket_id
		WHERE c.user_id = $1 AND l.detached_at IS NULL AND t.state IN ('new', 'analyzing', 'coding', 'testing', 'pushing')
		AND l.id = (SELECT max(x.id) FROM code_conversation_tickets x WHERE x.conversation_id = l.conversation_id AND x.detached_at IS NULL)`,
		userID).Scan(&n)
	return n, err
}

// CodeConversationOfTicket returns userID's Code conversation that has
// ticket key now, or ErrNotFound.
func (s *Assistant) CodeConversationOfTicket(ctx context.Context, userID int64, key string) (int64, error) {
	var id int64
	err := s.db.QueryRow(ctx, `SELECT l.conversation_id FROM code_conversation_tickets l
		JOIN tickets t ON t.id = l.ticket_id WHERE t.key = $1 AND l.user_id = $2 AND l.detached_at IS NULL`, key, userID).Scan(&id)
	return id, notFound(err)
}

// CodeOwnersOfTicket returns the Code conversations that have ticket key
// now, and whose they are: the people following its work in a chat.
func (s *Assistant) CodeOwnersOfTicket(ctx context.Context, key string) ([]orchestrator.CodeOwner, error) {
	rows, err := s.db.Query(ctx, `SELECT l.conversation_id, l.user_id FROM code_conversation_tickets l
		JOIN tickets t ON t.id = l.ticket_id WHERE t.key = $1 AND l.detached_at IS NULL ORDER BY l.id`, key)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.CodeOwner
	for rows.Next() {
		var o orchestrator.CodeOwner
		if err := rows.Scan(&o.ConversationID, &o.UserID); err != nil {
			return nil, err
		}
		out = append(out, o)
	}
	return out, rows.Err()
}
