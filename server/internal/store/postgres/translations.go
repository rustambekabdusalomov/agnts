package postgres

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/orchestrator"
)

// Translations stores translated ticket texts.
type Translations struct{ db *pgxpool.Pool }

var _ orchestrator.Translations = (*Translations)(nil)

// NewTranslations returns the translation store.
func NewTranslations(db *pgxpool.Pool) *Translations { return &Translations{db: db} }

// Translated returns the stored translations into lang of the texts with
// these hashes, by hash; texts never translated are absent.
func (s *Translations) Translated(ctx context.Context, lang string, hashes []string) (map[string]string, error) {
	rows, err := s.db.Query(ctx, `SELECT source_hash, text FROM translations WHERE lang = $1 AND source_hash = ANY($2)`, lang, hashes)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make(map[string]string, len(hashes))
	for rows.Next() {
		var h, text string
		if err := rows.Scan(&h, &text); err != nil {
			return nil, err
		}
		out[h] = text
	}
	return out, rows.Err()
}

// SaveTranslations stores translations into lang, by source hash. A text
// translated meanwhile by another request keeps its first translation.
func (s *Translations) SaveTranslations(ctx context.Context, lang string, texts map[string]string) error {
	hashes := make([]string, 0, len(texts))
	values := make([]string, 0, len(texts))
	for h, t := range texts {
		hashes, values = append(hashes, h), append(values, t)
	}
	_, err := s.db.Exec(ctx, `INSERT INTO translations (source_hash, lang, text)
		SELECT h, $1, t FROM unnest($2::text[], $3::text[]) AS x(h, t)
		ON CONFLICT (source_hash, lang) DO NOTHING`, lang, hashes, values)
	return err
}
