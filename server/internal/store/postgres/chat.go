package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Chat stores the team chat: channels, messages, their refs, the outbox
// of model work, and where each person last read. Every change writes an
// event in the same transaction, so the stream and a reconnect see it.
type Chat struct{ db *pgxpool.Pool }

// NewChat returns the team chat's store.
func NewChat(db *pgxpool.Pool) *Chat { return &Chat{db: db} }

// ErrChatDuplicate is a channel name the workspace already has.
var ErrChatDuplicate = errors.New("a channel with that name exists")

// ---------------------------------------------------------------------
// Channels

// ensureDefault makes #general, agnts's channel, when the workspace has
// no channel yet.
func (s *Chat) ensureDefault(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `INSERT INTO chat_channels (name, topic, agents)
		SELECT $1, 'Everyone in the workspace, and agnts', true
		WHERE NOT EXISTS (SELECT 1 FROM chat_channels WHERE workspace_id = agnts_ws())
		ON CONFLICT DO NOTHING`, domain.DefaultChatChannel)
	return err
}

const chatChannelCols = `c.id, c.workspace_id, c.name, c.topic, c.agents, c.created_at, c.archived_at,
	COALESCE((SELECT max(m.id) FROM chat_messages m WHERE m.channel_id = c.id), 0)`

func scanChannel(row pgx.Row, extra ...any) (domain.ChatChannel, error) {
	var c domain.ChatChannel
	err := row.Scan(append([]any{&c.ID, &c.WorkspaceID, &c.Name, &c.Topic, &c.Agents, &c.CreatedAt, &c.ArchivedAt, &c.LastID}, extra...)...)
	return c, notFound(err)
}

// Channels lists the workspace's open channels with user's unread counts,
// making #general first when there is none.
func (s *Chat) Channels(ctx context.Context, user int64) ([]domain.ChatChannel, error) {
	if err := s.ensureDefault(ctx); err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, `SELECT `+chatChannelCols+`, COALESCE(r.last_read_id, 0),
			(SELECT count(*) FROM chat_messages m WHERE m.channel_id = c.id AND m.id > COALESCE(r.last_read_id, 0)
			   AND m.author_user_id IS DISTINCT FROM $1)
		FROM chat_channels c LEFT JOIN chat_reads r ON r.channel_id = c.id AND r.user_id = $1
		WHERE c.archived_at IS NULL ORDER BY c.agents DESC, c.name`, user)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.ChatChannel
	for rows.Next() {
		var c domain.ChatChannel
		if c, err = scanChannelUnread(rows); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func scanChannelUnread(row pgx.Row) (domain.ChatChannel, error) {
	var read int64
	var unread int
	c, err := scanChannel(row, &read, &unread)
	c.LastReadID, c.Unread = read, unread
	return c, err
}

// Channel returns one channel.
func (s *Chat) Channel(ctx context.Context, id int64) (domain.ChatChannel, error) {
	return scanChannel(s.db.QueryRow(ctx, `SELECT `+chatChannelCols+` FROM chat_channels c WHERE c.id = $1`, id))
}

// AgentChannel returns the channel agnts posts its cards to: the one
// marked, else #general, made if need be.
func (s *Chat) AgentChannel(ctx context.Context) (domain.ChatChannel, error) {
	if err := s.ensureDefault(ctx); err != nil {
		return domain.ChatChannel{}, err
	}
	return scanChannel(s.db.QueryRow(ctx, `SELECT `+chatChannelCols+` FROM chat_channels c
		WHERE c.archived_at IS NULL ORDER BY c.agents DESC, (c.name = $1) DESC, c.id LIMIT 1`, domain.DefaultChatChannel))
}

// CreateChannel makes a channel; agents moves agnts's cards to it.
func (s *Chat) CreateChannel(ctx context.Context, name, topic string, agents bool, user int64) (domain.ChatChannel, error) {
	var c domain.ChatChannel
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if agents {
			if _, err := tx.Exec(ctx, `UPDATE chat_channels SET agents = false WHERE agents`); err != nil {
				return err
			}
		}
		var by *int64
		if user > 0 {
			by = &user
		}
		var err error
		c, err = scanChannel(tx.QueryRow(ctx, `INSERT INTO chat_channels AS c (name, topic, agents, created_by) VALUES ($1, $2, $3, $4)
			ON CONFLICT (workspace_id, name) DO NOTHING
			RETURNING `+chatChannelCols, name, topic, agents, by))
		if errors.Is(err, domain.ErrNotFound) {
			return ErrChatDuplicate
		}
		if err != nil {
			return err
		}
		return insertEvent(ctx, tx, domain.Event{Type: domain.EventChatChannel, WorkspaceID: c.WorkspaceID,
			Message: "#" + c.Name, Data: map[string]any{"channel": toMap(c)}})
	})
	return c, err
}

// UpdateChannel changes a channel's topic, makes it agnts's channel, or
// archives it.
func (s *Chat) UpdateChannel(ctx context.Context, id int64, topic *string, agents *bool, archive bool) (domain.ChatChannel, error) {
	var c domain.ChatChannel
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if agents != nil && *agents {
			if _, err := tx.Exec(ctx, `UPDATE chat_channels SET agents = false WHERE agents AND id <> $1`, id); err != nil {
				return err
			}
		}
		var err error
		c, err = scanChannel(tx.QueryRow(ctx, `UPDATE chat_channels c SET topic = COALESCE($2, topic),
				agents = COALESCE($3, agents) AND NOT $4,
				archived_at = CASE WHEN $4 THEN now() ELSE archived_at END
			WHERE id = $1 RETURNING `+chatChannelCols, id, topic, agents, archive))
		if err != nil {
			return err
		}
		return insertEvent(ctx, tx, domain.Event{Type: domain.EventChatChannel, WorkspaceID: c.WorkspaceID,
			Message: "#" + c.Name, Data: map[string]any{"channel": toMap(c)}})
	})
	return c, err
}

// MarkRead saves how far user has read a channel; it never moves back.
func (s *Chat) MarkRead(ctx context.Context, user, channel, last int64) error {
	_, err := s.db.Exec(ctx, `INSERT INTO chat_reads (user_id, channel_id, last_read_id) VALUES ($1, $2, $3)
		ON CONFLICT (user_id, channel_id) DO UPDATE SET last_read_id = greatest(chat_reads.last_read_id, EXCLUDED.last_read_id)`,
		user, channel, last)
	return err
}

// ---------------------------------------------------------------------
// Messages

const chatMsgCols = `m.id, m.workspace_id, m.channel_id, m.reply_to, m.author_user_id, COALESCE(u.username, m.author_agent, ''),
	m.kind, m.body, m.card, m.ai, COALESCE(m.ticket_key, ''), COALESCE(m.client_msg_id::text, ''), m.created_at, m.audio,
	COALESCE(u.avatar_version, 0)`

const chatMsgFrom = `chat_messages m LEFT JOIN users u ON u.id = m.author_user_id`

func scanMessage(row pgx.Row) (domain.ChatMessage, error) {
	var m domain.ChatMessage
	var kind string
	var card, ai, audio []byte
	var avatar int64
	err := row.Scan(&m.ID, &m.WorkspaceID, &m.ChannelID, &m.ReplyTo, &m.AuthorID, &m.Author, &kind, &m.Body, &card, &ai,
		&m.TicketKey, &m.ClientMsgID, &m.CreatedAt, &audio, &avatar)
	if err != nil {
		return m, notFound(err)
	}
	m.Kind = domain.ChatMessageKind(kind)
	if len(card) > 0 {
		m.Card = &domain.ChatCard{}
		_ = json.Unmarshal(card, m.Card)
	}
	if len(ai) > 0 {
		m.AI = &domain.ChatAI{}
		_ = json.Unmarshal(ai, m.AI)
	}
	if len(audio) > 0 {
		m.Audio = &domain.ChatAudio{}
		_ = json.Unmarshal(audio, m.Audio)
	}
	if m.AuthorID != nil {
		m.AuthorAvatar = domain.AvatarURL(*m.AuthorID, avatar)
	}
	m.Refs = []domain.ChatRef{}
	return m, nil
}

// withRefs fills each message's refs (removed ones left out) and files.
func withRefs(ctx context.Context, db pgx.Tx, pool *pgxpool.Pool, ms []domain.ChatMessage) error {
	if len(ms) == 0 {
		return nil
	}
	if err := withFiles(ctx, db, pool, ms); err != nil {
		return err
	}
	ids := make([]int64, len(ms))
	at := make(map[int64]int, len(ms))
	for i, m := range ms {
		ids[i], at[m.ID] = m.ID, i
	}
	q := `SELECT message_id, ref_type, ref_id, source, confidence, reason, ai FROM chat_refs
		WHERE message_id = ANY($1) AND source <> 'removed' ORDER BY created_at, ref_type, ref_id`
	var rows pgx.Rows
	var err error
	if db != nil {
		rows, err = db.Query(ctx, q, ids)
	} else {
		rows, err = pool.Query(ctx, q, ids)
	}
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var id int64
		var r domain.ChatRef
		var ai []byte
		if err := rows.Scan(&id, &r.Type, &r.ID, &r.Source, &r.Confidence, &r.Reason, &ai); err != nil {
			return err
		}
		if len(ai) > 0 {
			r.AI = &domain.ChatAI{}
			_ = json.Unmarshal(ai, r.AI)
		}
		ms[at[id]].Refs = append(ms[at[id]].Refs, r)
	}
	return rows.Err()
}

// withFiles fills each message's files.
func withFiles(ctx context.Context, db pgx.Tx, pool *pgxpool.Pool, ms []domain.ChatMessage) error {
	ids := make([]int64, len(ms))
	for i, m := range ms {
		ids[i] = m.ID
	}
	var files map[int64][]domain.FileRef
	var err error
	if db != nil {
		files, err = fileRefs(ctx, db, "chat_message_id", ids)
	} else {
		files, err = fileRefs(ctx, pool, "chat_message_id", ids)
	}
	if err != nil {
		return err
	}
	for i := range ms {
		ms[i].Files = files[ms[i].ID]
	}
	return nil
}

func collectMessages(rows pgx.Rows) ([]domain.ChatMessage, error) {
	defer rows.Close()
	out := []domain.ChatMessage{}
	for rows.Next() {
		m, err := scanMessage(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// Messages pages a channel, oldest first: before > 0 gives the limit
// messages before it, after > 0 the ones after it (a reconnect filling
// its gap), neither the newest.
func (s *Chat) Messages(ctx context.Context, channel, before, after int64, limit int) ([]domain.ChatMessage, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	var rows pgx.Rows
	var err error
	switch {
	case after > 0:
		rows, err = s.db.Query(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+`
			WHERE m.channel_id = $1 AND m.id > $2 ORDER BY m.id LIMIT $3`, channel, after, limit)
	default:
		if before <= 0 {
			before = 1 << 62
		}
		rows, err = s.db.Query(ctx, `SELECT * FROM (SELECT `+chatMsgCols+` FROM `+chatMsgFrom+`
			WHERE m.channel_id = $1 AND m.id < $2 ORDER BY m.id DESC LIMIT $3) x ORDER BY id`, channel, before, limit)
	}
	if err != nil {
		return nil, err
	}
	out, err := collectMessages(rows)
	if err != nil {
		return nil, err
	}
	return out, withRefs(ctx, nil, s.db, out)
}

// Message returns one message with its refs.
func (s *Chat) Message(ctx context.Context, id int64) (domain.ChatMessage, error) {
	m, err := scanMessage(s.db.QueryRow(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+` WHERE m.id = $1`, id))
	if err != nil {
		return m, err
	}
	ms := []domain.ChatMessage{m}
	err = withRefs(ctx, nil, s.db, ms)
	return ms[0], err
}

// MessagesByID returns messages by id, oldest first, with their refs.
func (s *Chat) MessagesByID(ctx context.Context, ids []int64) ([]domain.ChatMessage, error) {
	rows, err := s.db.Query(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+` WHERE m.id = ANY($1) ORDER BY m.id`, ids)
	if err != nil {
		return nil, err
	}
	out, err := collectMessages(rows)
	if err != nil {
		return nil, err
	}
	return out, withRefs(ctx, nil, s.db, out)
}

func messageTx(ctx context.Context, tx pgx.Tx, id int64) (domain.ChatMessage, error) {
	m, err := scanMessage(tx.QueryRow(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+` WHERE m.id = $1`, id))
	if err != nil {
		return m, err
	}
	ms := []domain.ChatMessage{m}
	err = withRefs(ctx, tx, nil, ms)
	return ms[0], err
}

// messageEvent records that m is new or changed: the event carries the
// whole message, so clients redraw it without asking.
func messageEvent(ctx context.Context, tx pgx.Tx, typ string, m domain.ChatMessage) error {
	return insertEvent(ctx, tx, domain.Event{Type: typ, WorkspaceID: m.WorkspaceID, TicketKey: "",
		Data: map[string]any{"message": toMap(m)}})
}

// toMap turns v into the JSON object an event's data holds.
func toMap(v any) map[string]any {
	b, _ := json.Marshal(v)
	var out map[string]any
	_ = json.Unmarshal(b, &out)
	return out
}

// ChatJob is model work waiting in the outbox.
type ChatJob struct {
	ID          int64
	WorkspaceID int64
	MessageID   int64
	Kind        string
	UserID      int64
	Attempts    int
	Data        map[string]any
}

// Chat job kinds.
const (
	ChatJobLink       = "link"
	ChatJobAnswer     = "answer"
	ChatJobCodeAnswer = "code_answer"
	ChatJobTicket     = "ticket"
	ChatJobTranscribe = "transcribe"
)

// Send stores user's message, with its files and the jobs to run on it,
// in one transaction. A message whose client id was already stored comes back
// as it is, with created false and no new jobs.
func (s *Chat) Send(ctx context.Context, user int64, in domain.ChatSend, jobs []string) (domain.ChatMessage, bool, error) {
	var m domain.ChatMessage
	created := false
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var cid *string
		if in.ClientMsgID != "" {
			cid = &in.ClientMsgID
		}
		var id int64
		err := tx.QueryRow(ctx, `INSERT INTO chat_messages (channel_id, reply_to, author_user_id, kind, body, client_msg_id)
			SELECT $1, $2, $3, 'text', $4, $5::uuid FROM chat_channels WHERE id = $1 AND archived_at IS NULL
			ON CONFLICT (workspace_id, author_user_id, client_msg_id) WHERE client_msg_id IS NOT NULL DO NOTHING
			RETURNING id`, in.ChannelID, in.ReplyTo, user, in.Body, cid).Scan(&id)
		if errors.Is(err, pgx.ErrNoRows) {
			if cid == nil {
				return domain.ErrNotFound // no such open channel
			}
			err = tx.QueryRow(ctx, `SELECT id FROM chat_messages WHERE author_user_id = $1 AND client_msg_id = $2::uuid`, user, *cid).Scan(&id)
			if err != nil {
				return notFound(err)
			}
			m, err = messageTx(ctx, tx, id)
			return err
		}
		if err != nil {
			return err
		}
		created = true
		if err := linkMessageFiles(ctx, tx, in.Files, "chat_message_id", id, user, domain.AttachChat); err != nil {
			return err
		}
		if m, err = messageTx(ctx, tx, id); err != nil {
			return err
		}
		for _, k := range jobs {
			if _, err := tx.Exec(ctx, `INSERT INTO chat_jobs (message_id, kind, user_id) VALUES ($1, $2, $3)`, id, k, user); err != nil {
				return err
			}
		}
		return messageEvent(ctx, tx, domain.EventChatMessage, m)
	})
	return m, created, err
}

// FileData returns the bytes of a file a chat message brought.
func (s *Chat) FileData(ctx context.Context, id int64) ([]byte, error) {
	var data []byte
	err := s.db.QueryRow(ctx, `SELECT data FROM attachments WHERE id = $1 AND chat_message_id IS NOT NULL`, id).Scan(&data)
	return data, notFound(err)
}

// CopyFilesToTicket copies chat message msg's files to ticket key, as
// files of its description, so its runs get them; it returns how many.
func (s *Chat) CopyFilesToTicket(ctx context.Context, msg int64, key string) (int64, error) {
	tag, err := s.db.Exec(ctx, `INSERT INTO attachments (ticket_id, purpose, name, content_type, size, data, uploaded_by)
		SELECT t.id, 'ticket', a.name, a.content_type, a.size, a.data, a.uploaded_by
		FROM attachments a JOIN tickets t ON t.key = $2
		WHERE a.chat_message_id = $1 ORDER BY a.id`, msg, key)
	return tag.RowsAffected(), err
}

// Post stores agnts's message (a card or text) in a channel.
func (s *Chat) Post(ctx context.Context, m domain.ChatMessage) (domain.ChatMessage, error) {
	var out domain.ChatMessage
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		card, ai, err := cardAI(m)
		if err != nil {
			return err
		}
		var key *string
		if m.TicketKey != "" {
			key = &m.TicketKey
		}
		ws := m.WorkspaceID
		var wsArg *int64
		if ws > 0 {
			wsArg = &ws
		}
		var id int64
		err = tx.QueryRow(ctx, `INSERT INTO chat_messages (workspace_id, channel_id, reply_to, author_agent, kind, body, card, ai, ticket_key)
			VALUES (COALESCE($1, agnts_ws()), $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
			wsArg, m.ChannelID, m.ReplyTo, domain.ChatAgent, string(m.Kind), m.Body, card, ai, key).Scan(&id)
		if err != nil {
			return err
		}
		for _, r := range m.Refs {
			if err := insertRef(ctx, tx, id, r); err != nil {
				return err
			}
		}
		if out, err = messageTx(ctx, tx, id); err != nil {
			return err
		}
		return messageEvent(ctx, tx, domain.EventChatMessage, out)
	})
	return out, err
}

func cardAI(m domain.ChatMessage) (card, ai []byte, err error) {
	if m.Card != nil {
		if card, err = json.Marshal(m.Card); err != nil {
			return nil, nil, err
		}
	}
	if m.AI != nil {
		if ai, err = json.Marshal(m.AI); err != nil {
			return nil, nil, err
		}
	}
	return card, ai, nil
}

// Update changes agnts's message under a row lock: fn edits it, and the
// store saves its body, card, ai and ticket key and records the change.
// fn returning an error leaves the message as it was.
func (s *Chat) Update(ctx context.Context, id int64, fn func(*domain.ChatMessage) error) (domain.ChatMessage, error) {
	var m domain.ChatMessage
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `SELECT 1 FROM chat_messages WHERE id = $1 FOR UPDATE`, id); err != nil {
			return err
		}
		var err error
		if m, err = messageTx(ctx, tx, id); err != nil {
			return err
		}
		if m.Kind == domain.ChatKindText {
			return fmt.Errorf("message %d is a person's: agnts does not change it", id)
		}
		if err := fn(&m); err != nil {
			return err
		}
		card, ai, err := cardAI(m)
		if err != nil {
			return err
		}
		var key *string
		if m.TicketKey != "" {
			key = &m.TicketKey
		}
		if _, err := tx.Exec(ctx, `UPDATE chat_messages SET body = $2, card = $3, ai = $4, ticket_key = $5, edited_at = now() WHERE id = $1`,
			id, m.Body, card, ai, key); err != nil {
			return err
		}
		typ := domain.EventChatMessage
		if m.Card != nil {
			typ = domain.EventChatCard
		}
		return messageEvent(ctx, tx, typ, m)
	})
	return m, err
}

// CardsOf returns agnts's cards about a ticket, oldest first.
func (s *Chat) CardsOf(ctx context.Context, key string) ([]domain.ChatMessage, error) {
	rows, err := s.db.Query(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+`
		WHERE m.ticket_key = $1 AND m.kind = 'agent_card' ORDER BY m.id`, key)
	if err != nil {
		return nil, err
	}
	return collectMessages(rows)
}

// ---------------------------------------------------------------------
// Refs

func insertRef(ctx context.Context, tx pgx.Tx, msg int64, r domain.ChatRef) error {
	var ai []byte
	if r.AI != nil {
		ai, _ = json.Marshal(r.AI)
	}
	_, err := tx.Exec(ctx, `INSERT INTO chat_refs (workspace_id, message_id, ref_type, ref_id, source, confidence, reason, ai)
		SELECT workspace_id, id, $2, $3, $4, $5, $6, $7 FROM chat_messages WHERE id = $1
		ON CONFLICT (message_id, ref_type, ref_id) DO NOTHING`, msg, r.Type, r.ID, r.Source, r.Confidence, r.Reason, ai)
	return err
}

// AddRefs links a message to refs it has no link to yet (a ref a member
// removed stays removed) and records the change when there was one.
func (s *Chat) AddRefs(ctx context.Context, msg int64, refs []domain.ChatRef) (domain.ChatMessage, error) {
	var m domain.ChatMessage
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var before int
		if err := tx.QueryRow(ctx, `SELECT count(*) FROM chat_refs WHERE message_id = $1`, msg).Scan(&before); err != nil {
			return err
		}
		for _, r := range refs {
			if err := insertRef(ctx, tx, msg, r); err != nil {
				return err
			}
		}
		var after int
		if err := tx.QueryRow(ctx, `SELECT count(*) FROM chat_refs WHERE message_id = $1`, msg).Scan(&after); err != nil {
			return err
		}
		var err error
		if m, err = messageTx(ctx, tx, msg); err != nil {
			return err
		}
		if after == before {
			return nil
		}
		return messageEvent(ctx, tx, domain.EventChatRef, m)
	})
	return m, err
}

// RemoveRef marks a wrong link removed, so the linker does not add it back.
func (s *Chat) RemoveRef(ctx context.Context, msg int64, typ, id string) (domain.ChatMessage, error) {
	var m domain.ChatMessage
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `UPDATE chat_refs SET source = 'removed' WHERE message_id = $1 AND ref_type = $2 AND ref_id = $3`, msg, typ, id)
		if err != nil {
			return err
		}
		if tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		if m, err = messageTx(ctx, tx, msg); err != nil {
			return err
		}
		return messageEvent(ctx, tx, domain.EventChatRef, m)
	})
	return m, err
}

// ---------------------------------------------------------------------
// Jobs (the outbox)

// AddJob queues model work on a message.
func (s *Chat) AddJob(ctx context.Context, msg int64, kind string, user int64, data map[string]any) error {
	if data == nil {
		data = map[string]any{}
	}
	var by *int64
	if user > 0 {
		by = &user
	}
	_, err := s.db.Exec(ctx, `INSERT INTO chat_jobs (workspace_id, message_id, kind, user_id, data)
		SELECT workspace_id, id, $2, $3, $4 FROM chat_messages WHERE id = $1`, msg, kind, by, data)
	return err
}

// TakeJob claims the oldest due job of any workspace (ctx must be the
// system's), or returns false when there is none.
func (s *Chat) TakeJob(ctx context.Context) (ChatJob, bool, error) {
	var j ChatJob
	var user *int64
	var data []byte
	err := s.db.QueryRow(ctx, `UPDATE chat_jobs SET state = 'running', attempts = attempts + 1
		WHERE id = (SELECT id FROM chat_jobs WHERE state = 'queued' AND run_after <= now() ORDER BY id FOR UPDATE SKIP LOCKED LIMIT 1)
		RETURNING id, workspace_id, message_id, kind, user_id, attempts, data`).Scan(&j.ID, &j.WorkspaceID, &j.MessageID, &j.Kind, &user, &j.Attempts, &data)
	if errors.Is(err, pgx.ErrNoRows) {
		return j, false, nil
	}
	if err != nil {
		return j, false, err
	}
	if user != nil {
		j.UserID = *user
	}
	_ = json.Unmarshal(data, &j.Data)
	return j, true, nil
}

// FinishJob settles a job: done, retried after a backoff, or failed once
// it has had maxAttempts.
func (s *Chat) FinishJob(ctx context.Context, j ChatJob, jobErr error, maxAttempts int) error {
	if jobErr == nil {
		_, err := s.db.Exec(ctx, `UPDATE chat_jobs SET state = 'done', last_error = '' WHERE id = $1`, j.ID)
		return err
	}
	msg := jobErr.Error()
	if len(msg) > 1000 {
		msg = msg[:1000]
	}
	if j.Attempts >= maxAttempts {
		_, err := s.db.Exec(ctx, `UPDATE chat_jobs SET state = 'failed', last_error = $2 WHERE id = $1`, j.ID, msg)
		return err
	}
	_, err := s.db.Exec(ctx, `UPDATE chat_jobs SET state = 'queued', last_error = $2, run_after = now() + $3::interval WHERE id = $1`,
		j.ID, msg, fmt.Sprintf("%d seconds", 5*j.Attempts*j.Attempts))
	return err
}

// RequeueStale puts jobs left running by a stopped server back in the queue.
func (s *Chat) RequeueStale(ctx context.Context, older time.Duration) error {
	_, err := s.db.Exec(ctx, `UPDATE chat_jobs SET state = 'queued'
		WHERE state = 'running' AND created_at < now() - $1::interval`, fmt.Sprintf("%d seconds", int(older.Seconds())))
	return err
}

// JobsToday counts a workspace's jobs of a kind since midnight UTC (the
// daily caps).
func (s *Chat) JobsToday(ctx context.Context, kind string) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM chat_jobs WHERE kind = $1 AND created_at >= date_trunc('day', now() AT TIME ZONE 'UTC') AT TIME ZONE 'UTC'`, kind).Scan(&n)
	return n, err
}

// OpenPRWorkspaces are the workspaces with an open pull request card of
// the last day.
func (s *Chat) OpenPRWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT workspace_id FROM chat_messages
		WHERE kind = 'agent_card' AND card->>'type' = 'pr_opened' AND card->>'state' = 'open' AND created_at > now() - interval '1 day'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out = append(out, id)
	}
	return out, rows.Err()
}

// ChatVoice is a voice message's recording: as the browser made it, to
// play back, and the WAV Muse hears.
type ChatVoice struct {
	ContentType string
	Data, WAV   []byte
	DurationMS  int64
}

// SendVoice stores user's voice message, its recording and the job that
// hears it, in one transaction; a resend with the same client id returns
// the stored message, with created false.
func (s *Chat) SendVoice(ctx context.Context, user int64, in domain.ChatSend, v ChatVoice) (domain.ChatMessage, bool, error) {
	var m domain.ChatMessage
	created := false
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		audio, _ := json.Marshal(domain.ChatAudio{ContentType: v.ContentType, DurationMS: v.DurationMS, Transcript: domain.VoicePending})
		var id int64
		err := tx.QueryRow(ctx, `INSERT INTO chat_messages (channel_id, reply_to, author_user_id, kind, body, client_msg_id, audio)
			SELECT $1, $2, $3, 'text', '', $4::uuid, $5 FROM chat_channels WHERE id = $1 AND archived_at IS NULL
			ON CONFLICT (workspace_id, author_user_id, client_msg_id) WHERE client_msg_id IS NOT NULL DO NOTHING
			RETURNING id`, in.ChannelID, in.ReplyTo, user, in.ClientMsgID, audio).Scan(&id)
		if errors.Is(err, pgx.ErrNoRows) {
			err = tx.QueryRow(ctx, `SELECT id FROM chat_messages WHERE author_user_id = $1 AND client_msg_id = $2::uuid`, user, in.ClientMsgID).Scan(&id)
			if err != nil {
				return notFound(err) // no such open channel
			}
			m, err = messageTx(ctx, tx, id)
			return err
		}
		if err != nil {
			return err
		}
		created = true
		if _, err := tx.Exec(ctx, `INSERT INTO chat_audio (workspace_id, message_id, content_type, data, wav)
			SELECT workspace_id, id, $2, $3, $4 FROM chat_messages WHERE id = $1`, id, v.ContentType, v.Data, v.WAV); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `INSERT INTO chat_jobs (message_id, kind, user_id) VALUES ($1, 'transcribe', $2)`, id, user); err != nil {
			return err
		}
		if m, err = messageTx(ctx, tx, id); err != nil {
			return err
		}
		return messageEvent(ctx, tx, domain.EventChatMessage, m)
	})
	return m, created, err
}

// Voice returns a voice message's recording and its type; wav, when asked,
// is the WAV still waiting to be heard (nil once it was).
func (s *Chat) Voice(ctx context.Context, msg int64, wav bool) (string, []byte, error) {
	var ct string
	var data []byte
	col := "data"
	if wav {
		col = "wav"
	}
	err := s.db.QueryRow(ctx, `SELECT content_type, `+col+` FROM chat_audio WHERE message_id = $1`, msg).Scan(&ct, &data)
	return ct, data, notFound(err)
}

// SetTranscript saves what was heard in a voice message: its text becomes
// the body (state done), or the state says why there is none. The WAV is
// dropped, and jobs (links, an answer) are queued on the text.
func (s *Chat) SetTranscript(ctx context.Context, msg int64, text, state, why string, jobs []string, user int64) (domain.ChatMessage, error) {
	var m domain.ChatMessage
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `UPDATE chat_messages SET body = $2,
				audio = jsonb_set(jsonb_set(audio, '{transcript}', to_jsonb($3::text)), '{error}', to_jsonb($4::text))
			WHERE id = $1 AND audio IS NOT NULL`, msg, text, state, why)
		if err != nil {
			return err
		}
		if tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		if _, err := tx.Exec(ctx, `UPDATE chat_audio SET wav = NULL WHERE message_id = $1`, msg); err != nil {
			return err
		}
		var by *int64
		if user > 0 {
			by = &user
		}
		for _, k := range jobs {
			if _, err := tx.Exec(ctx, `INSERT INTO chat_jobs (workspace_id, message_id, kind, user_id)
				SELECT workspace_id, id, $2, $3 FROM chat_messages WHERE id = $1`, msg, k, by); err != nil {
				return err
			}
		}
		if m, err = messageTx(ctx, tx, msg); err != nil {
			return err
		}
		return messageEvent(ctx, tx, domain.EventChatMessage, m)
	})
	return m, err
}
