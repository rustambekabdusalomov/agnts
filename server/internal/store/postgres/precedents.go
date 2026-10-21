package postgres

import (
	"context"
	"encoding/json"
	"regexp"
	"strings"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.PrecedentStore = (*Agent)(nil)

var wordRe = regexp.MustCompile(`[\p{L}\p{N}_]{3,}`)

// orQuery turns free text into a tsquery that matches any of its words
// (at most 30), or "" when it has none.
func orQuery(text string) string {
	seen := map[string]bool{}
	var words []string
	for _, w := range wordRe.FindAllString(strings.ToLower(text), -1) {
		if !seen[w] && len(words) < 30 {
			seen[w] = true
			words = append(words, w)
		}
	}
	return strings.Join(words, " | ")
}

// Precedents returns the tickets of repoID most like the work at hand:
// the ones whose change touched the same files, then the ones whose text
// shares the most words with text. Up to limit merged tickets (or pushed
// straight to the default branch) come first, each with what agnts said
// it changed, its files, an excerpt of what merged and what people asked
// to change; then up to two rejected tickets, with why, as what not to do.
func (s *Agent) Precedents(ctx context.Context, repoID int64, except []string, files []string, text string, limit int) ([]orchestrator.Precedent, error) {
	good, err := s.precedents(ctx, repoID, except, files, text, limit, `t.state = 'done' AND (t.merged_at IS NOT NULL OR t.after_approve = 'main')`)
	if err != nil {
		return nil, err
	}
	bad, err := s.precedents(ctx, repoID, except, files, text, maxRejectedPrecedents, `t.state = 'rejected'`)
	if err != nil {
		return nil, err
	}
	for i := range bad {
		bad[i].Rejected = true
	}
	return append(good, bad...), nil
}

// maxRejectedPrecedents caps the rejected tickets shown as what not to do.
const maxRejectedPrecedents = 2

func (s *Agent) precedents(ctx context.Context, repoID int64, except []string, files []string, text string, limit int, state string) ([]orchestrator.Precedent, error) {
	if files == nil {
		files = []string{}
	}
	if except == nil {
		except = []string{}
	}
	rows, err := s.db.Query(ctx, `WITH cand AS (
			SELECT t.id, t.key, t.title, t.description, t.updated_at, c.summary, c.files
			FROM tickets t
			JOIN LATERAL (SELECT res.summary, res.files FROM results res JOIN runs ON runs.id = res.run_id
				WHERE runs.ticket_id = t.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) c ON true
			WHERE `+touchesSQL+` AND t.key <> ALL($2) AND t.replay_of = '' AND `+state+` AND t.kind IN ('code', 'test')
			ORDER BY t.updated_at DESC LIMIT 500),
		scored AS (
			SELECT id, key, title, summary, files, updated_at,
				(SELECT count(*) FROM jsonb_array_elements(files) f WHERE f->>'path' = ANY($3)
					AND coalesce((f->>'repoId')::bigint, 0) IN (0, $1)) AS overlap,
				CASE WHEN $4 = '' THEN 0 ELSE ts_rank(to_tsvector('simple', title || ' ' || description), to_tsquery('simple', $4)) END AS rank
			FROM cand)
		SELECT key, title, summary->>'summary', files, overlap,
			(SELECT mc.files FROM merged_changes mc WHERE mc.ticket_id = scored.id AND mc.repo_id = $1),
			COALESCE((SELECT e.message FROM events e WHERE e.ticket_key = scored.key AND e.type = 'state_changed'
				AND e.data->>'to' = 'rejected' ORDER BY e.id DESC LIMIT 1), '')
		FROM scored
		WHERE overlap > 0 OR rank > 0.01
		ORDER BY overlap DESC, rank DESC, updated_at DESC LIMIT $5`, repoID, except, files, orQuery(text), limit)
	if err != nil {
		return nil, err
	}
	out, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (orchestrator.Precedent, error) {
		var p orchestrator.Precedent
		var summary *string
		var raw, merged []byte
		var rejected string
		if err := row.Scan(&p.Key, &p.Title, &summary, &raw, &p.Overlap, &merged, &rejected); err != nil {
			return p, err
		}
		if summary != nil {
			p.Summary = *summary
		}
		p.Reason = strings.TrimSpace(strings.TrimPrefix(rejected, "rejected"))
		p.Reason = strings.TrimSpace(strings.TrimPrefix(p.Reason, ":"))
		var fs []domain.FileChange
		_ = json.Unmarshal(raw, &fs)
		var mine []domain.FileChange
		for _, f := range fs {
			if f.RepoID == 0 || f.RepoID == repoID { // its change in this repository
				p.Files = append(p.Files, f.Path)
				mine = append(mine, f)
			}
		}
		// What merged, when it was recorded; else agnts's last change.
		var landed []domain.FileChange
		if json.Unmarshal(merged, &landed) == nil && len(landed) > 0 {
			p.Merged = true
			mine = landed
		}
		p.Excerpt = orchestrator.DiffExcerpt(mine, files, 80)
		return p, nil
	})
	if err != nil || len(out) == 0 {
		return out, err
	}
	keys := make([]string, len(out))
	for i, p := range out {
		keys[i] = p.Key
	}
	rows, err = s.db.Query(ctx, `SELECT ticket_key, message FROM events
		WHERE ticket_key = ANY($1) AND type = 'feedback' AND origin <> 'system' AND COALESCE(data->>'ci', '') <> 'true'
			AND message <> '' ORDER BY id`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	at := map[string]int{}
	for i, p := range out {
		at[p.Key] = i
	}
	for rows.Next() {
		var key, msg string
		if err := rows.Scan(&key, &msg); err != nil {
			return nil, err
		}
		if i, ok := at[key]; ok && len(out[i].Feedback) < 3 {
			out[i].Feedback = append(out[i].Feedback, msg)
		}
	}
	return out, rows.Err()
}
