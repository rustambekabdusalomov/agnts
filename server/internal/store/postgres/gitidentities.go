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

// GitIdentity maps a git login or email to a workspace member.
type GitIdentity struct {
	UserID      int64  `json:"userId"`
	Provider    string `json:"provider"`
	Login       string `json:"login"`
	Email       string `json:"email"`
	AutoMatched bool   `json:"autoMatched"`
}

// GitIdentities lists the workspace's explicit git identities.
func (s *Agent) GitIdentities(ctx context.Context) ([]GitIdentity, error) {
	rows, err := s.db.Query(ctx, `SELECT user_id, provider, login, email, auto_matched FROM member_git_identities ORDER BY user_id, login, email`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (GitIdentity, error) {
		var g GitIdentity
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
