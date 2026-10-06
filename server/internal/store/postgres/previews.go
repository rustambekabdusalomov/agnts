package postgres

import (
	"context"
	"strconv"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// PreviewEnvs keeps each repository's preview environment sealed with
// AGNTS_ENC_KEY. The rest of the preview settings live on the repository.
type PreviewEnvs struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewPreviewEnvs returns the preview environment store.
func NewPreviewEnvs(db *pgxpool.Pool, box *secret.Box) *PreviewEnvs {
	return &PreviewEnvs{db: db, box: box}
}

func previewEnvAAD(repoID int64) []byte {
	return []byte("preview-env:" + strconv.FormatInt(repoID, 10))
}

// PreviewEnv returns a repository's preview environment, "" when none is set.
func (s *PreviewEnvs) PreviewEnv(ctx context.Context, repoID int64) (string, error) {
	var enc []byte
	if err := s.db.QueryRow(ctx, `SELECT preview_env FROM repositories WHERE id = $1`, repoID).Scan(&enc); err != nil {
		return "", notFound(err)
	}
	if len(enc) == 0 {
		return "", nil
	}
	pt, err := s.box.Open(enc, previewEnvAAD(repoID))
	return string(pt), err
}

// SetPreviewEnv replaces a repository's preview environment; "" clears it.
func (s *PreviewEnvs) SetPreviewEnv(ctx context.Context, repoID int64, env string) error {
	names, err := domain.ParseEnv(env)
	if err != nil {
		return err
	}
	var enc []byte
	if len(names) > 0 {
		if enc, err = s.box.Seal([]byte(env), previewEnvAAD(repoID)); err != nil {
			return err
		}
	}
	tag, err := s.db.Exec(ctx, `UPDATE repositories SET preview_env = $2, preview_env_names = $3, updated_at = now() WHERE id = $1`,
		repoID, enc, names)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}
