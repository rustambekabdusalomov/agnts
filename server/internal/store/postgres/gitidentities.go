package postgres

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/perfreview"
)

// GitIdentities lists the workspace's explicit git identities.
func (s *Agent) GitIdentities(ctx context.Context) ([]domain.GitIdentity, error) {
	rows, err := s.db.Query(ctx, `SELECT user_id, provider, login, email, auto_matched FROM member_git_identities ORDER BY user_id, login, email`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.GitIdentity, error) {
		var g domain.GitIdentity
		err := r.Scan(&g.UserID, &g.Provider, &g.Login, &g.Email, &g.AutoMatched)
		return g, err
	})
}

// MapGitIdentity gives a git login or email to a member of the workspace.
// One already given to another member fails with domain.ErrConflict until
// it is moved (UnmapGitIdentity first).
func (s *Agent) MapGitIdentity(ctx context.Context, userID int64, login, email string) error {
	login, email = strings.TrimSpace(login), strings.ToLower(strings.TrimSpace(email))
	if login == "" && email == "" {
		return fmt.Errorf("%w: a git login or email is needed", domain.ErrPerfInvalid)
	}
	var member bool
	if err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM memberships WHERE workspace_id = agnts_ws() AND user_id = $1)`, userID).Scan(&member); err != nil {
		return err
	}
	if !member {
		return fmt.Errorf("%w: that person is not a member of this workspace", domain.ErrPerfInvalid)
	}
	var other int64
	err := s.db.QueryRow(ctx, `SELECT user_id FROM member_git_identities
		WHERE (($1 <> '' AND lower(login) = lower($1)) OR ($2 <> '' AND lower(email) = $2)) AND user_id <> $3 LIMIT 1`, login, email, userID).Scan(&other)
	if err == nil {
		return fmt.Errorf("%w: that git identity belongs to another member; remove it there first", domain.ErrConflict)
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return err
	}
	_, err = s.db.Exec(ctx, `INSERT INTO member_git_identities (user_id, provider, login, email, auto_matched) VALUES ($1, '', $2, $3, false)
		ON CONFLICT DO NOTHING`, userID, login, email)
	return err
}

// UnmapGitIdentity removes a member's git login or email.
func (s *Agent) UnmapGitIdentity(ctx context.Context, userID int64, login, email string) error {
	_, err := s.db.Exec(ctx, `DELETE FROM member_git_identities WHERE user_id = $1 AND lower(login) = lower($2) AND lower(email) = lower($3)`,
		userID, strings.TrimSpace(login), strings.TrimSpace(email))
	return err
}

// IdentityResolver returns how git identities map to the workspace's
// members: the explicit identities first, then a member whose email is
// the commit's or whose username is the git login.
func (s *Agent) IdentityResolver(ctx context.Context) (perfreview.Resolve, error) {
	byLogin, byEmail := map[string]int64{}, map[string]int64{}
	ids, err := s.GitIdentities(ctx)
	if err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, `SELECT u.id, lower(u.username), lower(coalesce(u.email, '')) FROM memberships m JOIN users u ON u.id = m.user_id
		WHERE m.workspace_id = agnts_ws() ORDER BY u.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	autoLogin, autoEmail := map[string]int64{}, map[string]int64{}
	for rows.Next() {
		var id int64
		var username, email string
		if err := rows.Scan(&id, &username, &email); err != nil {
			return nil, err
		}
		if username != "" {
			if _, ok := autoLogin[username]; !ok {
				autoLogin[username] = id
			}
		}
		if email != "" {
			if _, ok := autoEmail[email]; !ok {
				autoEmail[email] = id
			}
		}
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	for _, g := range ids {
		if g.Login != "" {
			byLogin[strings.ToLower(g.Login)] = g.UserID
		}
		if g.Email != "" {
			byEmail[strings.ToLower(g.Email)] = g.UserID
		}
	}
	return func(login, email string) int64 {
		l, e := strings.ToLower(login), strings.ToLower(email)
		if id, ok := byLogin[l]; ok && l != "" {
			return id
		}
		if id, ok := byEmail[e]; ok && e != "" {
			return id
		}
		if id, ok := autoEmail[e]; ok && e != "" {
			return id
		}
		if id, ok := autoLogin[l]; ok && l != "" {
			return id
		}
		return 0
	}, nil
}

// ScoredEarners returns, per scored delivery, the earners its latest
// score recorded, for working its shares out again.
func (s *Agent) ScoredEarners(ctx context.Context) ([]domain.DeliveryEarners, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT ON (ticket_id, delivery) ticket_id, delivery, coalesce(factors->'earners', '[]')
		FROM ticket_scores WHERE status = 'scored' ORDER BY ticket_id, delivery, scored_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.DeliveryEarners, error) {
		var d domain.DeliveryEarners
		err := r.Scan(&d.TicketID, &d.Delivery, &d.Earners)
		return d, err
	})
}

// ReplaceScoreAuthors sets a delivery's shares.
func (s *Agent) ReplaceScoreAuthors(ctx context.Context, ticketID int64, delivery int, authors []domain.ScoreAuthor) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM ticket_score_authors WHERE ticket_id = $1 AND delivery = $2`, ticketID, delivery); err != nil {
			return err
		}
		for _, a := range authors {
			if a.Share <= 0 {
				continue
			}
			if _, err := tx.Exec(ctx, `INSERT INTO ticket_score_authors (ticket_id, delivery, author_key, share, days) VALUES ($1, $2, $3, $4, $5)`,
				ticketID, delivery, a.Key, a.Share, a.Days); err != nil {
				return err
			}
		}
		return nil
	})
}

// UnmappedAuthors lists the git identities that earned shares but map to
// no member, with how many deliveries each has.
func (s *Agent) UnmappedAuthors(ctx context.Context) ([]domain.UnmappedAuthor, error) {
	rows, err := s.db.Query(ctx, `SELECT author_key, count(*) FROM ticket_score_authors WHERE author_key LIKE 'unmapped:%'
		GROUP BY author_key ORDER BY count(*) DESC, author_key`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.UnmappedAuthor, error) {
		var u domain.UnmappedAuthor
		err := r.Scan(&u.Key, &u.Deliveries)
		u.Identity = strings.TrimPrefix(u.Key, "unmapped:")
		return u, err
	})
}
