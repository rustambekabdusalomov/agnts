package postgres

import (
	"context"
	"strings"
	"time"

	"agnts/internal/domain"
)

// ChatCandidate is something a message may be about: a ticket, a pull
// request, a repository or a log finding, with a title to judge by.
type ChatCandidate struct {
	Type  string    `json:"type"`
	ID    string    `json:"id"`
	Title string    `json:"title"`
	State string    `json:"state,omitempty"`
	URL   string    `json:"url,omitempty"`
	At    time.Time `json:"at"`
}

// Key is "type:id".
func (c ChatCandidate) Key() string { return c.Type + ":" + c.ID }

// ChatCandidates are what the linker may pick from: open and recent
// tickets, repositories, the newest pull requests agnts opened, and open
// log findings.
func (s *Chat) ChatCandidates(ctx context.Context) ([]ChatCandidate, error) {
	var out []ChatCandidate
	add := func(q string, args ...any) error {
		rows, err := s.db.Query(ctx, q, args...)
		if err != nil {
			return err
		}
		defer rows.Close()
		for rows.Next() {
			var c ChatCandidate
			if err := rows.Scan(&c.Type, &c.ID, &c.Title, &c.State, &c.URL, &c.At); err != nil {
				return err
			}
			out = append(out, c)
		}
		return rows.Err()
	}
	err := add(`SELECT 'ticket', key, title, state, '', updated_at FROM tickets
		WHERE state NOT IN ('done', 'rejected') OR updated_at > now() - interval '14 days'
		ORDER BY (state NOT IN ('done', 'rejected')) DESC, updated_at DESC LIMIT 50`)
	if err == nil {
		err = add(`SELECT 'repo', name, name || CASE WHEN stack <> '' THEN ' (' || stack || ')' ELSE '' END, '', '', created_at
			FROM repositories WHERE archived_at IS NULL ORDER BY name LIMIT 40`)
	}
	if err == nil {
		err = add(`SELECT 'pr', r.name || '#' || tr.pr_number, t.key || ': ' || t.title,
				CASE WHEN tr.merged_at IS NOT NULL THEN 'merged' WHEN tr.closed_at IS NOT NULL THEN 'closed' ELSE 'open' END,
				tr.pr_url, COALESCE(tr.merged_at, t.updated_at)
			FROM ticket_repos tr JOIN tickets t ON t.id = tr.ticket_id JOIN repositories r ON r.id = tr.repo_id
			WHERE tr.pr_number IS NOT NULL ORDER BY t.updated_at DESC LIMIT 20`)
	}
	if err == nil {
		err = add(`SELECT 'finding', id::text, service || ': ' || title, status, '', last_seen_at FROM log_findings
			WHERE status NOT IN ('muted', 'fixed', 'resolved') ORDER BY last_seen_at DESC LIMIT 10`)
	}
	return out, err
}

// TicketKeys reports which of keys are tickets of the workspace.
func (s *Chat) TicketKeys(ctx context.Context, keys []string) (map[string]bool, error) {
	out := map[string]bool{}
	if len(keys) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT key FROM tickets WHERE key = ANY($1)`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var k string
		if err := rows.Scan(&k); err != nil {
			return nil, err
		}
		out[k] = true
	}
	return out, rows.Err()
}

// RepoNames lists the workspace's repositories by name.
func (s *Chat) RepoNames(ctx context.Context) (map[string]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT name, id FROM repositories WHERE archived_at IS NULL`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]int64{}
	for rows.Next() {
		var n string
		var id int64
		if err := rows.Scan(&n, &id); err != nil {
			return nil, err
		}
		out[n] = id
	}
	return out, rows.Err()
}

// SearchMessages finds people's and agnts's messages matching a question
// (full-text, 'simple' configuration: no stemming, any language), best
// first, of the last 180 days.
func (s *Chat) SearchMessages(ctx context.Context, question string, limit int) ([]domain.ChatMessage, error) {
	q := searchQuery(question)
	if q == "" {
		return nil, nil
	}
	rows, err := s.db.Query(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+`, to_tsquery('simple', $1) q
		WHERE m.search @@ q AND m.created_at > now() - interval '180 days' AND m.kind IN ('text', 'agent_text')
		ORDER BY ts_rank(m.search, q) DESC, m.id DESC LIMIT $2`, q, limit)
	if err != nil {
		return nil, err
	}
	out, err := collectMessages(rows)
	if err != nil {
		return nil, err
	}
	return out, withRefs(ctx, nil, s.db, out)
}

// searchQuery turns a question into an OR query of its words of three
// letters or more (a question rarely repeats a message word for word).
func searchQuery(q string) string {
	var words []string
	seen := map[string]bool{}
	for _, w := range strings.FieldsFunc(strings.ToLower(q), func(r rune) bool {
		return r != '_' && r != '-' && (r < '0' || r > '9') && (r < 'a' || r > 'z') && r <= 127
	}) {
		w = strings.Trim(w, "-_")
		if len([]rune(w)) < 3 || stopWords[w] || seen[w] {
			continue
		}
		seen[w] = true
		words = append(words, strings.ReplaceAll(w, "-", " <-> ")+":*")
		if len(words) == 12 {
			break
		}
	}
	return strings.Join(words, " | ")
}

var stopWords = map[string]bool{"the": true, "and": true, "how": true, "what": true, "why": true, "who": true, "when": true,
	"where": true, "does": true, "did": true, "was": true, "were": true, "are": true, "is": true, "for": true, "with": true,
	"this": true, "that": true, "from": true, "about": true, "agnts": true, "can": true, "you": true, "our": true, "has": true,
	"have": true, "last": true, "week": true, "into": true, "there": true, "which": true}

// MessagesSharingRefs are messages linked to any of refs (people's and
// agnts's), newest first, of the last 90 days.
func (s *Chat) MessagesSharingRefs(ctx context.Context, refs []domain.ChatRef, except int64, limit int) ([]domain.ChatMessage, error) {
	if len(refs) == 0 {
		return nil, nil
	}
	keys := make([]string, len(refs))
	for i, r := range refs {
		keys[i] = r.Key()
	}
	rows, err := s.db.Query(ctx, `SELECT `+chatMsgCols+` FROM `+chatMsgFrom+`
		WHERE m.id IN (SELECT message_id FROM chat_refs WHERE source <> 'removed' AND ref_type || ':' || ref_id = ANY($1))
		  AND m.id <> $2 AND m.created_at > now() - interval '90 days'
		ORDER BY m.id DESC LIMIT $3`, keys, except, limit)
	if err != nil {
		return nil, err
	}
	out, err := collectMessages(rows)
	if err != nil {
		return nil, err
	}
	return out, withRefs(ctx, nil, s.db, out)
}

// SearchTickets finds tickets whose title or description match a
// question, best first.
func (s *Chat) SearchTickets(ctx context.Context, question string, limit int) ([]string, error) {
	q := searchQuery(question)
	if q == "" {
		return nil, nil
	}
	rows, err := s.db.Query(ctx, `SELECT key FROM tickets, to_tsquery('simple', $1) q
		WHERE to_tsvector('simple', title || ' ' || description) @@ q
		ORDER BY ts_rank(to_tsvector('simple', title || ' ' || description), q) DESC, updated_at DESC LIMIT $2`, q, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []string
	for rows.Next() {
		var k string
		if err := rows.Scan(&k); err != nil {
			return nil, err
		}
		out = append(out, k)
	}
	return out, rows.Err()
}

// ChatStats is what the model did in the chat today.
type ChatStats struct {
	Links, Answers, Drafts int
	MedianMS               int64
}

// Stats counts today's model links, answers and drafts, and their median
// time.
func (s *Chat) Stats(ctx context.Context) (ChatStats, error) {
	var st ChatStats
	err := s.db.QueryRow(ctx, `SELECT
			(SELECT count(*) FROM chat_refs WHERE source = 'model' AND created_at >= date_trunc('day', now())),
			(SELECT count(*) FROM chat_messages WHERE kind = 'agent_text' AND ai IS NOT NULL AND created_at >= date_trunc('day', now())),
			(SELECT count(*) FROM chat_messages WHERE card->>'type' = 'ticket_draft' AND created_at >= date_trunc('day', now())),
			COALESCE((SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY (ai->>'ms')::bigint) FROM (
				SELECT ai FROM chat_messages WHERE ai IS NOT NULL AND created_at >= date_trunc('day', now())
				UNION ALL SELECT ai FROM chat_refs WHERE ai IS NOT NULL AND created_at >= date_trunc('day', now())) x), 0)::bigint`).
		Scan(&st.Links, &st.Answers, &st.Drafts, &st.MedianMS)
	return st, err
}
