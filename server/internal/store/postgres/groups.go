package postgres

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

const groupCols = `g.id, g.workspace_id, g.name, g.description, g.instructions, g.task_prefix, g.created_at, g.updated_at,
	coalesce((SELECT jsonb_agg(jsonb_build_object('repoId', m.repo_id, 'repoName', r.name, 'role', m.role, 'position', m.position,
		'archived', r.archived_at IS NOT NULL) ORDER BY m.position, r.name)
		FROM repository_group_members m JOIN repositories r ON r.id = m.repo_id WHERE m.group_id = g.id), '[]'::jsonb)`

func scanGroup(row pgx.Row) (domain.RepoGroup, error) {
	var g domain.RepoGroup
	var members []byte
	if err := row.Scan(&g.ID, &g.WorkspaceID, &g.Name, &g.Description, &g.Instructions, &g.TaskPrefix, &g.CreatedAt, &g.UpdatedAt, &members); err != nil {
		return g, notFound(err)
	}
	if err := json.Unmarshal(members, &g.Members); err != nil {
		return g, err
	}
	return g, nil
}

// ListGroups returns the workspace's repository groups by name.
func (s *Agent) ListGroups(ctx context.Context) ([]domain.RepoGroup, error) {
	rows, err := s.db.Query(ctx, `SELECT `+groupCols+` FROM repository_groups g ORDER BY lower(g.name), g.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.RepoGroup
	for rows.Next() {
		g, err := scanGroup(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// GroupByID returns one group, or ErrNotFound.
func (s *Agent) GroupByID(ctx context.Context, id int64) (domain.RepoGroup, error) {
	return scanGroup(s.db.QueryRow(ctx, `SELECT `+groupCols+` FROM repository_groups g WHERE g.id = $1`, id))
}

// GroupByName returns the group named name (in any case), or ErrNotFound.
func (s *Agent) GroupByName(ctx context.Context, name string) (domain.RepoGroup, error) {
	return scanGroup(s.db.QueryRow(ctx, `SELECT `+groupCols+` FROM repository_groups g WHERE lower(g.name) = lower($1)
		ORDER BY g.name = $1 DESC, g.id LIMIT 1`, name))
}

// GroupsOfRepos returns, per repository id, the groups it is a member of
// (id and name only), by name.
func (s *Agent) GroupsOfRepos(ctx context.Context) (map[int64][]domain.RepoGroup, error) {
	rows, err := s.db.Query(ctx, `SELECT m.repo_id, g.id, g.name FROM repository_group_members m
		JOIN repository_groups g ON g.id = m.group_id ORDER BY lower(g.name), g.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64][]domain.RepoGroup{}
	for rows.Next() {
		var repo int64
		var g domain.RepoGroup
		if err := rows.Scan(&repo, &g.ID, &g.Name); err != nil {
			return nil, err
		}
		out[repo] = append(out[repo], g)
	}
	return out, rows.Err()
}

// SaveGroup creates a group (ID 0) or replaces one's fields and members,
// in one transaction. A clashing name or prefix gives ErrConflict.
func (s *Agent) SaveGroup(ctx context.Context, g domain.RepoGroup) (domain.RepoGroup, error) {
	var id int64
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		if g.ID == 0 {
			err = tx.QueryRow(ctx, `INSERT INTO repository_groups (name, description, instructions, task_prefix)
				VALUES ($1, $2, $3, $4) RETURNING id`, g.Name, g.Description, g.Instructions, g.TaskPrefix).Scan(&id)
		} else {
			err = tx.QueryRow(ctx, `UPDATE repository_groups SET name = $2, description = $3, instructions = $4, task_prefix = $5,
				updated_at = now() WHERE id = $1 RETURNING id`, g.ID, g.Name, g.Description, g.Instructions, g.TaskPrefix).Scan(&id)
		}
		if err != nil {
			return notFound(err)
		}
		if _, err := tx.Exec(ctx, `DELETE FROM repository_group_members WHERE group_id = $1`, id); err != nil {
			return err
		}
		for i, m := range g.Members {
			if _, err := tx.Exec(ctx, `INSERT INTO repository_group_members (group_id, repo_id, role, position) VALUES ($1, $2, $3, $4)`,
				id, m.RepoID, m.Role, i); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return domain.RepoGroup{}, err
		}
		return domain.RepoGroup{}, uniqueConflict(err)
	}
	return s.GroupByID(ctx, id)
}

// DeleteGroup removes a group. Its tickets keep their repositories; their
// group_id goes NULL.
func (s *Agent) DeleteGroup(ctx context.Context, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM repository_groups WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// NextGroupTaskNumber reserves the next task number of a group.
func (s *Agent) NextGroupTaskNumber(ctx context.Context, groupID int64) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `UPDATE repository_groups SET task_seq = task_seq + 1 WHERE id = $1 RETURNING task_seq`, groupID).Scan(&n)
	return n, notFound(err)
}

// TaskPrefixTaken reports whether a repository other than exceptRepo, or a
// group other than exceptGroup, already uses prefix for its task keys.
func (s *Agent) TaskPrefixTaken(ctx context.Context, prefix string, exceptRepo, exceptGroup int64) (bool, error) {
	var taken bool
	err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM repositories WHERE upper(task_prefix) = upper($1) AND id <> $2)
		OR EXISTS (SELECT 1 FROM repository_groups WHERE upper(task_prefix) = upper($1) AND id <> $3)`,
		prefix, exceptRepo, exceptGroup).Scan(&taken)
	return taken, err
}
