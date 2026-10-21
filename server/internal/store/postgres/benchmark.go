package postgres

import (
	"context"
	"encoding/json"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// SaveMergedChange keeps what a ticket's pull request merged as, replacing
// an earlier record of the same repository (a reopened, merged again pull
// request).
func (s *Agent) SaveMergedChange(ctx context.Context, m domain.MergedChange) error {
	files, _ := json.Marshal(m.Files)
	if m.Files == nil {
		files = []byte("[]")
	}
	_, err := s.db.Exec(ctx, `INSERT INTO merged_changes (ticket_id, repo_id, pr_number, head_sha, files)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (ticket_id, repo_id) DO UPDATE SET pr_number = $3, head_sha = $4, files = $5, created_at = now()`,
		m.TicketID, m.RepoID, m.Number, m.HeadSHA, files)
	return err
}

// MergedChanges returns what a ticket's pull requests merged as, by
// repository.
func (s *Agent) MergedChanges(ctx context.Context, ticketID int64) ([]domain.MergedChange, error) {
	rows, err := s.db.Query(ctx, `SELECT ticket_id, repo_id, pr_number, head_sha, files, created_at
		FROM merged_changes WHERE ticket_id = $1 ORDER BY repo_id`, ticketID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(row pgx.CollectableRow) (domain.MergedChange, error) {
		var m domain.MergedChange
		var files []byte
		if err := row.Scan(&m.TicketID, &m.RepoID, &m.Number, &m.HeadSHA, &files, &m.CreatedAt); err != nil {
			return m, err
		}
		_ = json.Unmarshal(files, &m.Files)
		return m, nil
	})
}

// BenchmarkTickets returns the tickets in the benchmark, oldest merge first.
func (s *Agent) BenchmarkTickets(ctx context.Context) ([]domain.Ticket, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets WHERE benchmark ORDER BY merged_at NULLS LAST, id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Ticket
	for rows.Next() {
		t, err := scanTicket(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}
