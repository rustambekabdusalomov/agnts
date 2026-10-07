package postgres

import (
	"context"
	"strconv"

	"agnts/internal/domain"
)

func buildEnvAAD(repoID int64) []byte {
	return []byte("build-env:" + strconv.FormatInt(repoID, 10))
}

// BuildEnv returns a repository's build environment (registry tokens and
// the like given to every run), "" when none is set. It shares the box and
// pool of the preview environments.
func (s *PreviewEnvs) BuildEnv(ctx context.Context, repoID int64) (string, error) {
	var enc []byte
	if err := s.db.QueryRow(ctx, `SELECT build_env FROM repositories WHERE id = $1`, repoID).Scan(&enc); err != nil {
		return "", notFound(err)
	}
	if len(enc) == 0 {
		return "", nil
	}
	pt, err := s.box.Open(enc, buildEnvAAD(repoID))
	return string(pt), err
}

// SetBuildEnv replaces a repository's build environment; "" clears it.
func (s *PreviewEnvs) SetBuildEnv(ctx context.Context, repoID int64, env string) error {
	names, err := domain.ParseEnv(env)
	if err != nil {
		return err
	}
	var enc []byte
	if len(names) > 0 {
		if enc, err = s.box.Seal([]byte(env), buildEnvAAD(repoID)); err != nil {
			return err
		}
	}
	tag, err := s.db.Exec(ctx, `UPDATE repositories SET build_env = $2, build_env_names = $3, updated_at = now() WHERE id = $1`,
		repoID, enc, names)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}
