package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"hiro/internal/domain"
	"hiro/internal/secret"
)

// Integration is a connected external service. Token is decrypted.
type Integration struct {
	Provider  string
	Connected bool
	Token     string
	Settings  map[string]string
	CheckedAt *time.Time
	Account   string
	LastError string
}

// Integrations stores provider credentials, encrypted with the server key.
type Integrations struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewIntegrations returns the integrations store.
func NewIntegrations(db *pgxpool.Pool, box *secret.Box) *Integrations {
	return &Integrations{db: db, box: box}
}

func integrationAAD(provider string) []byte { return []byte("integration:" + provider) }

// Get returns a provider's integration, or domain.ErrNotFound.
func (s *Integrations) Get(ctx context.Context, provider string) (Integration, error) {
	in := Integration{Provider: provider}
	var enc, settings []byte
	err := s.db.QueryRow(ctx, `SELECT connected, token_enc, settings, checked_at, account, last_error FROM integrations WHERE provider = $1`, provider).
		Scan(&in.Connected, &enc, &settings, &in.CheckedAt, &in.Account, &in.LastError)
	if err != nil {
		return in, notFound(err)
	}
	if len(enc) > 0 {
		pt, err := s.box.Open(enc, integrationAAD(provider))
		if err != nil {
			return in, err
		}
		in.Token = string(pt)
	}
	_ = json.Unmarshal(settings, &in.Settings)
	if in.Settings == nil {
		in.Settings = map[string]string{}
	}
	return in, nil
}

// Put saves a provider's token and settings and marks it connected.
func (s *Integrations) Put(ctx context.Context, in Integration) error {
	var enc []byte
	if in.Token != "" {
		var err error
		if enc, err = s.box.Seal([]byte(in.Token), integrationAAD(in.Provider)); err != nil {
			return err
		}
	}
	settings, _ := json.Marshal(in.Settings)
	_, err := s.db.Exec(ctx, `INSERT INTO integrations (provider, connected, token_enc, settings, checked_at, account, last_error)
		VALUES ($1, true, $2, $3, now(), $4, '')
		ON CONFLICT (provider) DO UPDATE SET connected = true, token_enc = COALESCE($2, integrations.token_enc),
			settings = $3, checked_at = now(), account = $4, last_error = '', updated_at = now()`, in.Provider, enc, settings, in.Account)
	return err
}

// UpdateSettings replaces a provider's non-secret settings.
func (s *Integrations) UpdateSettings(ctx context.Context, provider string, settings map[string]string) error {
	b, _ := json.Marshal(settings)
	tag, err := s.db.Exec(ctx, `UPDATE integrations SET settings = $2, updated_at = now() WHERE provider = $1`, provider, b)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// SetCheck records the result of a connection test.
func (s *Integrations) SetCheck(ctx context.Context, provider, account, lastError string) error {
	_, err := s.db.Exec(ctx, `UPDATE integrations SET checked_at = now(), account = CASE WHEN $2 = '' THEN account ELSE $2 END,
		last_error = $3, updated_at = now() WHERE provider = $1`, provider, account, lastError)
	return err
}

// Disconnect forgets a provider's token.
func (s *Integrations) Disconnect(ctx context.Context, provider string) error {
	_, err := s.db.Exec(ctx, `UPDATE integrations SET connected = false, token_enc = NULL, last_error = '', updated_at = now() WHERE provider = $1`, provider)
	return err
}

// List returns every stored integration.
func (s *Integrations) List(ctx context.Context) ([]Integration, error) {
	rows, err := s.db.Query(ctx, `SELECT provider FROM integrations ORDER BY provider`)
	if err != nil {
		return nil, err
	}
	var names []string
	for rows.Next() {
		var n string
		if err := rows.Scan(&n); err != nil {
			rows.Close()
			return nil, err
		}
		names = append(names, n)
	}
	rows.Close()
	out := make([]Integration, 0, len(names))
	for _, n := range names {
		in, err := s.Get(ctx, n)
		if err != nil {
			return nil, err
		}
		out = append(out, in)
	}
	return out, nil
}

// Token returns just a provider's token; empty when not connected.
func (s *Integrations) Token(ctx context.Context, provider string) (string, error) {
	in, err := s.Get(ctx, provider)
	if errors.Is(err, domain.ErrNotFound) {
		return "", nil
	}
	return in.Token, err
}
