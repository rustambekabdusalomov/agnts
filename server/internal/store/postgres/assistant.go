package postgres

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// Assistant stores assistant conversations. Every read and write names the
// person: a conversation is theirs alone, and another person's is not
// found. Snapshots kept for replays are sealed.
type Assistant struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewAssistant returns the assistant store.
func NewAssistant(db *pgxpool.Pool, box *secret.Box) *Assistant { return &Assistant{db: db, box: box} }

var replayAAD = []byte("assistant_replay")

const assistantMsgCols = `m.id, m.conversation_id, m.role, m.text, m.speech, m.links, m.status, m.error, m.lang, m.prompt_version, m.model,
	m.tokens, m.cost_usd, m.duration_ms, m.timing, m.files, m.rating, m.rating_comment, m.shared, m.action_errors, m.created_at`

func scanAssistantMsg(row pgx.Row) (domain.AssistantMessage, error) {
	var m domain.AssistantMessage
	var role, status string
	var links, timing []byte
	err := row.Scan(&m.ID, &m.ConversationID, &role, &m.Text, &m.Speech, &links, &status, &m.Error, &m.Lang, &m.PromptVersion, &m.Model,
		&m.Tokens, &m.CostUSD, &m.DurationMS, &timing, &m.Files, &m.Rating, &m.RatingComment, &m.Shared, &m.ActionErrors, &m.CreatedAt)
	if err != nil {
		return m, notFound(err)
	}
	m.Role, m.Status = domain.AssistantRole(role), domain.AssistantStatus(status)
	_ = json.Unmarshal(links, &m.Links)
	_ = json.Unmarshal(timing, &m.Timing)
	return m, nil
}

func scanAssistantMsgs(rows pgx.Rows) ([]domain.AssistantMessage, error) {
	defer rows.Close()
	var out []domain.AssistantMessage
	for rows.Next() {
		m, err := scanAssistantMsg(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// CreateAssistantConversation starts a conversation of userID.
func (s *Assistant) CreateAssistantConversation(ctx context.Context, userID int64, title string) (domain.AssistantConversation, error) {
	c := domain.AssistantConversation{UserID: userID, Title: title}
	err := s.db.QueryRow(ctx, `INSERT INTO assistant_conversations (user_id, title) VALUES ($1, $2)
		RETURNING id, created_at, updated_at`, userID, title).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
	return c, err
}

// AssistantConversation returns one of userID's conversations with all its
// messages.
func (s *Assistant) AssistantConversation(ctx context.Context, userID, id int64) (domain.AssistantConversation, error) {
	var c domain.AssistantConversation
	err := s.db.QueryRow(ctx, `SELECT id, user_id, title, created_at, updated_at FROM assistant_conversations
		WHERE id = $1 AND user_id = $2`, id, userID).Scan(&c.ID, &c.UserID, &c.Title, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return c, notFound(err)
	}
	rows, err := s.db.Query(ctx, `SELECT `+assistantMsgCols+` FROM assistant_messages m WHERE m.conversation_id = $1 ORDER BY m.id`, id)
	if err != nil {
		return c, err
	}
	if c.Messages, err = scanAssistantMsgs(rows); err != nil {
		return c, err
	}
	return c, attachAssistantActions(ctx, s.db, c.Messages)
}

// AssistantConversations returns userID's conversations, newest first, each
// with its last message.
func (s *Assistant) AssistantConversations(ctx context.Context, userID int64, limit int) ([]domain.AssistantConversation, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	rows, err := s.db.Query(ctx, `SELECT c.id, c.user_id, c.title, c.created_at, c.updated_at, `+assistantMsgCols+`
		FROM assistant_conversations c
		JOIN LATERAL (SELECT * FROM assistant_messages x WHERE x.conversation_id = c.id ORDER BY x.id DESC LIMIT 1) m ON true
		WHERE c.user_id = $1 ORDER BY c.updated_at DESC, c.id DESC LIMIT $2`, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.AssistantConversation
	for rows.Next() {
		var c domain.AssistantConversation
		var m domain.AssistantMessage
		var role, status string
		var links, timing []byte
		if err := rows.Scan(&c.ID, &c.UserID, &c.Title, &c.CreatedAt, &c.UpdatedAt,
			&m.ID, &m.ConversationID, &role, &m.Text, &m.Speech, &links, &status, &m.Error, &m.Lang, &m.PromptVersion, &m.Model,
			&m.Tokens, &m.CostUSD, &m.DurationMS, &timing, &m.Files, &m.Rating, &m.RatingComment, &m.Shared, &m.ActionErrors, &m.CreatedAt); err != nil {
			return nil, err
		}
		m.Role, m.Status = domain.AssistantRole(role), domain.AssistantStatus(status)
		_ = json.Unmarshal(links, &m.Links)
		_ = json.Unmarshal(timing, &m.Timing)
		c.Messages = []domain.AssistantMessage{m}
		out = append(out, c)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	rows.Close()
	last := make([]domain.AssistantMessage, len(out))
	for i, c := range out {
		last[i] = c.Messages[0]
	}
	if err := attachAssistantActions(ctx, s.db, last); err != nil {
		return nil, err
	}
	for i := range out {
		out[i].Messages[0] = last[i]
	}
	return out, nil
}

// DeleteAssistantConversation deletes one of userID's conversations.
func (s *Assistant) DeleteAssistantConversation(ctx context.Context, userID, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM assistant_conversations WHERE id = $1 AND user_id = $2`, id, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// AddAssistantMessage appends a message to a conversation and moves the
// conversation to the top of the person's list.
func (s *Assistant) AddAssistantMessage(ctx context.Context, m domain.AssistantMessage) (domain.AssistantMessage, error) {
	links, err := json.Marshal(nonNilLinks(m.Links))
	if err != nil {
		return m, err
	}
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return m, err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	err = tx.QueryRow(ctx, `INSERT INTO assistant_messages (conversation_id, role, text, links, status, lang, prompt_version)
		VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, created_at`,
		m.ConversationID, string(m.Role), m.Text, links, string(m.Status), m.Lang, m.PromptVersion).Scan(&m.ID, &m.CreatedAt)
	if err != nil {
		return m, err
	}
	if _, err := tx.Exec(ctx, `UPDATE assistant_conversations SET updated_at = now() WHERE id = $1`, m.ConversationID); err != nil {
		return m, err
	}
	return m, tx.Commit(ctx)
}

// SetAssistantStatus moves an open answer to status.
func (s *Assistant) SetAssistantStatus(ctx context.Context, id int64, status domain.AssistantStatus) error {
	_, err := s.db.Exec(ctx, `UPDATE assistant_messages SET status = $2 WHERE id = $1 AND status IN ('pending', 'answering')`, id, string(status))
	return err
}

// FinishAssistantMessage stores an answer (done or failed) and, when given,
// the snapshot it was made from.
func (s *Assistant) FinishAssistantMessage(ctx context.Context, m domain.AssistantMessage, snapshot []byte) error {
	links, err := json.Marshal(nonNilLinks(m.Links))
	if err != nil {
		return err
	}
	timing, err := json.Marshal(m.Timing)
	if err != nil {
		return err
	}
	var sealed []byte
	if len(snapshot) > 0 && s.box != nil {
		if sealed, err = s.box.Seal(snapshot, replayAAD); err != nil {
			return err
		}
	}
	files := m.Files
	if files == nil {
		files = []string{}
	}
	actionErrors := m.ActionErrors
	if actionErrors == nil {
		actionErrors = []string{}
	}
	_, err = s.db.Exec(ctx, `UPDATE assistant_messages SET text = $2, speech = $3, links = $4, status = $5, error = $6,
		prompt_version = $7, model = $8, tokens = $9, cost_usd = $10, duration_ms = $11, timing = $12, files = $13, replay = $14,
		action_errors = $15
		WHERE id = $1`, m.ID, m.Text, m.Speech, links, string(m.Status), m.Error, m.PromptVersion, m.Model, m.Tokens, m.CostUSD,
		m.DurationMS, timing, files, sealed, actionErrors)
	return err
}

// AssistantHistory returns the last n messages of a conversation before
// message id, oldest first: what a question sees of the talk so far.
// Failed and unfinished answers are left out.
func (s *Assistant) AssistantHistory(ctx context.Context, conversationID, beforeID int64, n int) ([]domain.AssistantMessage, error) {
	rows, err := s.db.Query(ctx, `SELECT * FROM (SELECT `+assistantMsgCols+` FROM assistant_messages m
		WHERE m.conversation_id = $1 AND m.id < $2 AND m.status = 'done' ORDER BY m.id DESC LIMIT $3) x ORDER BY id`,
		conversationID, beforeID, n)
	if err != nil {
		return nil, err
	}
	msgs, err := scanAssistantMsgs(rows)
	if err != nil {
		return nil, err
	}
	return msgs, attachAssistantActions(ctx, s.db, msgs)
}

// AssistantMessage returns one of userID's messages.
func (s *Assistant) AssistantMessage(ctx context.Context, userID, id int64) (domain.AssistantMessage, error) {
	return scanAssistantMsg(s.db.QueryRow(ctx, `SELECT `+assistantMsgCols+` FROM assistant_messages m
		JOIN assistant_conversations c ON c.id = m.conversation_id WHERE m.id = $1 AND c.user_id = $2`, id, userID))
}

// RateAssistantMessage stores userID's rating (-1, 0 to clear, or 1) of
// one of their answers, and whether its snapshot may be replayed.
func (s *Assistant) RateAssistantMessage(ctx context.Context, userID, id int64, rating int, comment string, share bool) (domain.AssistantMessage, error) {
	return scanAssistantMsg(s.db.QueryRow(ctx, `UPDATE assistant_messages m SET rating = $3::smallint, rating_comment = $4,
		shared = $5 AND m.replay IS NOT NULL, rated_at = CASE WHEN $3::smallint = 0 THEN NULL ELSE now() END
		FROM assistant_conversations c
		WHERE c.id = m.conversation_id AND m.id = $1 AND c.user_id = $2 AND m.role = 'assistant' AND m.status = 'done'
		RETURNING `+assistantMsgCols, id, userID, rating, comment, share))
}

// FailOpenAssistant fails every answer left open (pending or answering) in
// every workspace: the server stopped while making them.
func (s *Assistant) FailOpenAssistant(ctx context.Context, reason string) (int64, error) {
	tag, err := s.db.Exec(domain.System(ctx), `UPDATE assistant_messages SET status = 'failed', error = $1
		WHERE status IN ('pending', 'answering')`, reason)
	return tag.RowsAffected(), err
}

// PruneAssistant deletes conversations untouched since before, in every
// workspace.
func (s *Assistant) PruneAssistant(ctx context.Context, before time.Time) (int64, error) {
	tag, err := s.db.Exec(domain.System(ctx), `DELETE FROM assistant_conversations WHERE updated_at < $1`, before)
	return tag.RowsAffected(), err
}

// AssistantAsked counts the questions userID asked in the workspace since
// t, and when the oldest of them was asked.
func (s *Assistant) AssistantAsked(ctx context.Context, userID int64, t time.Time) (int, time.Time, error) {
	var n int
	var oldest *time.Time
	err := s.db.QueryRow(ctx, `SELECT count(*), min(m.created_at) FROM assistant_messages m JOIN assistant_conversations c ON c.id = m.conversation_id
		WHERE c.user_id = $1 AND m.role = 'user' AND m.created_at >= $2`, userID, t).Scan(&n, &oldest)
	if oldest == nil {
		return n, time.Time{}, err
	}
	return n, *oldest, err
}

// AssistantStats returns how the workspace's assistant did in the last
// days days.
func (s *Assistant) AssistantStats(ctx context.Context, days int) (domain.AssistantStats, error) {
	st := domain.AssistantStats{Days: days}
	since := time.Now().Add(-time.Duration(days) * 24 * time.Hour)
	err := s.db.QueryRow(ctx, `SELECT count(*), count(*) FILTER (WHERE m.status = 'done'), count(*) FILTER (WHERE m.status = 'failed'),
		count(DISTINCT c.user_id),
		COALESCE(percentile_disc(0.5) WITHIN GROUP (ORDER BY m.duration_ms) FILTER (WHERE m.status = 'done'), 0),
		COALESCE(percentile_disc(0.9) WITHIN GROUP (ORDER BY m.duration_ms) FILTER (WHERE m.status = 'done'), 0),
		COALESCE(percentile_disc(0.5) WITHIN GROUP (ORDER BY (m.timing->>'start_ms')::bigint) FILTER (WHERE m.status = 'done'), 0),
		COALESCE(percentile_disc(0.5) WITHIN GROUP (ORDER BY (m.timing->>'snapshot_ms')::bigint) FILTER (WHERE m.status = 'done'), 0),
		COALESCE(percentile_disc(0.5) WITHIN GROUP (ORDER BY (m.timing->>'claude_ms')::bigint) FILTER (WHERE m.status = 'done'), 0),
		count(*) FILTER (WHERE m.status = 'done' AND (m.timing->>'warm')::boolean),
		count(*) FILTER (WHERE m.rating = 1), count(*) FILTER (WHERE m.rating = -1),
		COALESCE(sum(m.tokens), 0), COALESCE(sum(m.cost_usd), 0)
		FROM assistant_messages m JOIN assistant_conversations c ON c.id = m.conversation_id
		WHERE m.role = 'assistant' AND m.created_at >= $1`, since).
		Scan(&st.Questions, &st.Answered, &st.Failed, &st.People, &st.MedianMS, &st.P90MS, &st.StartMS, &st.SnapshotMS, &st.ClaudeMS, &st.Warm,
			&st.Up, &st.Down, &st.Tokens, &st.CostUSD)
	if err != nil {
		return st, err
	}
	a := &st.Actions
	err = s.db.QueryRow(ctx, `SELECT count(*), count(*) FILTER (WHERE p.outcome = 'done'), count(*) FILTER (WHERE p.outcome = 'failed'),
		count(*) FILTER (WHERE p.outcome = 'cancelled'),
		count(*) FILTER (WHERE p.outcome IS NULL AND p.confirmed_at IS NULL AND p.expires_at <= now()),
		(SELECT COALESCE(sum(cardinality(m.action_errors)), 0) FROM assistant_messages m WHERE m.role = 'assistant' AND m.created_at >= $1)
		FROM pending_actions p WHERE p.origin = 'assistant' AND p.created_at >= $1`, since).
		Scan(&a.Proposed, &a.Done, &a.Failed, &a.Cancelled, &a.Expired, &a.NotOffered)
	if err != nil {
		return st, err
	}
	acts := map[string][2]int{} // per prompt version: proposed, done
	arows, err := s.db.Query(ctx, `SELECT m.prompt_version, count(*), count(*) FILTER (WHERE p.outcome = 'done')
		FROM pending_actions p JOIN assistant_messages m ON m.id = p.assistant_message_id
		WHERE p.origin = 'assistant' AND p.created_at >= $1 GROUP BY m.prompt_version`, since)
	if err != nil {
		return st, err
	}
	for arows.Next() {
		var v string
		var n [2]int
		if err := arows.Scan(&v, &n[0], &n[1]); err != nil {
			arows.Close()
			return st, err
		}
		acts[v] = n
	}
	arows.Close()
	if err := arows.Err(); err != nil {
		return st, err
	}
	rows, err := s.db.Query(ctx, `SELECT m.prompt_version, count(*) FILTER (WHERE m.status = 'done'), count(*) FILTER (WHERE m.status = 'failed'),
		count(*) FILTER (WHERE m.rating = 1), count(*) FILTER (WHERE m.rating = -1),
		COALESCE(percentile_disc(0.5) WITHIN GROUP (ORDER BY m.duration_ms) FILTER (WHERE m.status = 'done'), 0),
		COALESCE(sum(m.tokens), 0)
		FROM assistant_messages m
		WHERE m.role = 'assistant' AND m.created_at >= $1 AND m.status IN ('done', 'failed')
		GROUP BY m.prompt_version ORDER BY max(m.created_at) DESC`, since)
	if err != nil {
		return st, err
	}
	defer rows.Close()
	for rows.Next() {
		var v domain.AssistantVersionStats
		if err := rows.Scan(&v.PromptVersion, &v.Answered, &v.Failed, &v.Up, &v.Down, &v.MedianMS, &v.Tokens); err != nil {
			return st, err
		}
		v.Proposed, v.Done = acts[v.PromptVersion][0], acts[v.PromptVersion][1]
		st.Versions = append(st.Versions, v)
	}
	return st, rows.Err()
}

// AssistantRated returns the workspace's rated answers with their
// questions, newest rating first; rating 1 or -1 keeps one kind, 0 both.
func (s *Assistant) AssistantRated(ctx context.Context, rating, limit int) ([]domain.AssistantRated, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	rows, err := s.db.Query(ctx, `SELECT m.id, COALESCE(u.username, ''),
		COALESCE((SELECT q.text FROM assistant_messages q WHERE q.conversation_id = m.conversation_id AND q.id < m.id AND q.role = 'user'
			ORDER BY q.id DESC LIMIT 1), ''),
		m.text, m.rating, m.rating_comment, m.prompt_version, m.shared, m.rated_at
		FROM assistant_messages m JOIN assistant_conversations c ON c.id = m.conversation_id LEFT JOIN users u ON u.id = c.user_id
		WHERE m.rating <> 0 AND ($1::smallint = 0 OR m.rating = $1::smallint) ORDER BY m.rated_at DESC LIMIT $2`, rating, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.AssistantRated
	for rows.Next() {
		var r domain.AssistantRated
		if err := rows.Scan(&r.MessageID, &r.Username, &r.Question, &r.Answer, &r.Rating, &r.Comment, &r.PromptVersion, &r.Shared, &r.RatedAt); err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	rows.Close()
	ids := make([]int64, len(out))
	for i, r := range out {
		ids[i] = r.MessageID
	}
	by, err := assistantActionsOf(ctx, s.db, ids)
	if err != nil {
		return nil, err
	}
	for i := range out {
		out[i].Actions = by[out[i].MessageID]
	}
	return out, nil
}

// AssistantReplayCase is a shared answer with what it was made from.
type AssistantReplayCase struct {
	MessageID     int64
	UserID        int64
	Lang          string
	Question      string
	Answer        string
	Rating        int
	PromptVersion string
	Snapshot      []byte // the files, as AssistantSnapshot JSON
}

// AssistantReplays returns the workspace's shared answers, newest first,
// with their snapshots opened.
func (s *Assistant) AssistantReplays(ctx context.Context, limit int) ([]AssistantReplayCase, error) {
	if limit <= 0 || limit > 500 {
		limit = 50
	}
	rows, err := s.db.Query(ctx, `SELECT m.id, c.user_id, m.lang,
		COALESCE((SELECT q.text FROM assistant_messages q WHERE q.conversation_id = m.conversation_id AND q.id < m.id AND q.role = 'user'
			ORDER BY q.id DESC LIMIT 1), ''),
		m.text, m.rating, m.prompt_version, m.replay
		FROM assistant_messages m JOIN assistant_conversations c ON c.id = m.conversation_id
		WHERE m.shared AND m.replay IS NOT NULL ORDER BY m.id DESC LIMIT $1`, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []AssistantReplayCase
	for rows.Next() {
		var r AssistantReplayCase
		var sealed []byte
		if err := rows.Scan(&r.MessageID, &r.UserID, &r.Lang, &r.Question, &r.Answer, &r.Rating, &r.PromptVersion, &sealed); err != nil {
			return nil, err
		}
		if s.box != nil {
			if r.Snapshot, err = s.box.Open(sealed, replayAAD); err != nil {
				return nil, err
			}
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

func nonNilLinks(l []domain.AssistantLink) []domain.AssistantLink {
	if l == nil {
		return []domain.AssistantLink{}
	}
	return l
}
