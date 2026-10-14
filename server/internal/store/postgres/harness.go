package postgres

import (
	"context"
	"encoding/json"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var (
	_ orchestrator.HarnessStore  = (*Agent)(nil)
	_ orchestrator.ChangeHistory = (*Agent)(nil)
)

// RecentChanges returns the changed files of the newest done tickets in
// repoID (nil: every repository), newest first: what Try on history checks
// an enforced rule against.
func (s *Agent) RecentChanges(ctx context.Context, repoID *int64, limit int) ([]orchestrator.InFlight, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+`, c.files FROM tickets t
		JOIN LATERAL (SELECT res.files FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) c ON true
		WHERE ($1::bigint IS NULL OR `+touchesSQL+`) AND t.replay_of = '' AND t.state = 'done' AND t.kind IN ('code', 'test')
		ORDER BY t.updated_at DESC LIMIT $2`, repoID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.InFlight
	for rows.Next() {
		var files []byte
		t, err := scanTicket(scanAppend{rows, &files})
		if err != nil {
			return nil, err
		}
		f := orchestrator.InFlight{Ticket: t}
		_ = json.Unmarshal(files, &f.Files)
		if repoID != nil {
			f.Files = domain.FilesIn(f.Files, *repoID, t.RepoID) // its change in this repository only
		}
		out = append(out, f)
	}
	return out, rows.Err()
}
