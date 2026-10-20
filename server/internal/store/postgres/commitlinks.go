package postgres

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// TicketsByTokens returns the tickets whose number or key is one of the
// lower-case tokens, for domain.PickTicket to choose among.
func (s *Agent) TicketsByTokens(ctx context.Context, tokens []string) ([]domain.Ticket, error) {
	if len(tokens) == 0 {
		return nil, nil
	}
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets
		WHERE (ticket_number <> '' AND lower(ticket_number) = ANY($1)) OR lower(key) = ANY($1)
		ORDER BY id LIMIT 1000`, tokens)
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

// UpsertCommitLinks stores links; a link that is there already gains the
// new link's matched_on. It returns how many links each ticket gained.
func (s *Agent) UpsertCommitLinks(ctx context.Context, links []domain.CommitLink) (map[int64]int, error) {
	added := map[int64]int{}
	if len(links) == 0 {
		return added, nil
	}
	b := &pgx.Batch{}
	for _, l := range links {
		b.Queue(`INSERT INTO ticket_commits
			(ticket_id, repo_id, sha, branch, subject, author, author_login, url, committed_at, matched_on, token)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
			ON CONFLICT (ticket_id, repo_id, sha) DO UPDATE SET
				matched_on = ARRAY(SELECT DISTINCT m FROM unnest(ticket_commits.matched_on || EXCLUDED.matched_on) m ORDER BY m),
				branch = CASE WHEN ticket_commits.branch = '' THEN EXCLUDED.branch ELSE ticket_commits.branch END
			RETURNING (xmax = 0)`,
			l.TicketID, l.RepoID, l.SHA, l.Branch, l.Subject, l.Author, l.AuthorLogin, l.URL, l.CommittedAt, l.MatchedOn, l.Token)
	}
	br := s.db.SendBatch(ctx, b)
	for _, l := range links {
		var inserted bool
		if err := br.QueryRow().Scan(&inserted); err != nil {
			_ = br.Close()
			return nil, err
		}
		if inserted {
			added[l.TicketID]++
		}
	}
	return added, br.Close()
}

const commitLinkCols = `c.ticket_id, t.key, c.repo_id, r.name, c.sha, c.branch, c.subject, c.author, c.author_login, c.url,
	c.committed_at, c.matched_on, c.token, c.created_at`

func scanCommitLink(row pgx.Row) (domain.CommitLink, error) {
	var l domain.CommitLink
	err := row.Scan(&l.TicketID, &l.TicketKey, &l.RepoID, &l.RepoName, &l.SHA, &l.Branch, &l.Subject, &l.Author, &l.AuthorLogin,
		&l.URL, &l.CommittedAt, &l.MatchedOn, &l.Token, &l.CreatedAt)
	return l, err
}

// CommitLinksOfTicket returns up to limit of a ticket's linked commits,
// newest first, after skipping offset, and how many it has in all.
func (s *Agent) CommitLinksOfTicket(ctx context.Context, ticketID int64, limit, offset int) ([]domain.CommitLink, int, error) {
	var total int
	if err := s.db.QueryRow(ctx, `SELECT count(*) FROM ticket_commits WHERE ticket_id = $1`, ticketID).Scan(&total); err != nil {
		return nil, 0, err
	}
	rows, err := s.db.Query(ctx, `SELECT `+commitLinkCols+` FROM ticket_commits c
		JOIN tickets t ON t.id = c.ticket_id JOIN repositories r ON r.id = c.repo_id
		WHERE c.ticket_id = $1 ORDER BY c.committed_at DESC, c.sha LIMIT $2 OFFSET $3`, ticketID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()
	out := []domain.CommitLink{}
	for rows.Next() {
		l, err := scanCommitLink(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, l)
	}
	return out, total, rows.Err()
}

// TicketsOfCommits maps commits of a repository (full shas) to the
// tickets they are linked to, oldest link first.
func (s *Agent) TicketsOfCommits(ctx context.Context, repoID int64, shas []string) (map[string][]domain.LinkedTicket, error) {
	out := map[string][]domain.LinkedTicket{}
	if len(shas) == 0 {
		return out, nil
	}
	lower := make([]string, len(shas))
	for i, sha := range shas {
		lower[i] = strings.ToLower(sha)
	}
	rows, err := s.db.Query(ctx, `SELECT c.sha, t.key, t.ticket_number, t.title, t.state FROM ticket_commits c
		JOIN tickets t ON t.id = c.ticket_id
		WHERE c.repo_id = $1 AND c.sha = ANY($2) ORDER BY c.created_at, t.id`, repoID, lower)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var sha, state string
		var t domain.LinkedTicket
		if err := rows.Scan(&sha, &t.Key, &t.Number, &t.Title, &state); err != nil {
			return nil, err
		}
		t.State = domain.TicketState(state)
		out[sha] = append(out[sha], t)
	}
	return out, rows.Err()
}

// DeleteCommitLinksByToken removes the links a ticket got through token
// (lower case), as when its number changes.
func (s *Agent) DeleteCommitLinksByToken(ctx context.Context, ticketID int64, token string) error {
	_, err := s.db.Exec(ctx, `DELETE FROM ticket_commits WHERE ticket_id = $1 AND token = $2`, ticketID, strings.ToLower(token))
	return err
}
