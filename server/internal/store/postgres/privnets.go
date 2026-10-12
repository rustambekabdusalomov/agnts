package postgres

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/privnet"
)

// PrivateNetwork is one of a workspace's stored private networks.
// SecretEnc is sealed (privnet.SecretAAD, or privnet.LegacySecretAAD while
// SecretV is 1); the store never opens it.
type PrivateNetwork struct {
	ID          int64
	Workspace   int64
	Name        string
	Kind        privnet.Kind
	Enabled     bool
	SecretEnc   []byte
	SecretV     int
	Summary     string
	TokenHash   string
	Routes      []privnet.Route
	CAPEM       string
	Status      string
	LastError   string
	UpAt        *time.Time
	HandshakeAt *time.Time
	Detail      string
	UpdatedAt   time.Time
}

// PrivateNetworks stores private networks and the connections made
// through them.
type PrivateNetworks struct{ db *pgxpool.Pool }

// NewPrivateNetworks returns the private network store.
func NewPrivateNetworks(db *pgxpool.Pool) *PrivateNetworks { return &PrivateNetworks{db: db} }

const privnetCols = `id, workspace_id, name, kind, enabled, secret_enc, secret_v, summary, token_hash, routes, ca_pem, status, last_error,
	up_at, handshake_at, detail, updated_at`

func scanPrivnet(row pgx.Row) (PrivateNetwork, error) {
	var n PrivateNetwork
	var routes []byte
	err := row.Scan(&n.ID, &n.Workspace, &n.Name, &n.Kind, &n.Enabled, &n.SecretEnc, &n.SecretV, &n.Summary, &n.TokenHash, &routes, &n.CAPEM,
		&n.Status, &n.LastError, &n.UpAt, &n.HandshakeAt, &n.Detail, &n.UpdatedAt)
	if err != nil {
		return n, notFound(err)
	}
	_ = json.Unmarshal(routes, &n.Routes)
	return n, nil
}

func scanPrivnets(rows pgx.Rows, err error) ([]PrivateNetwork, error) {
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []PrivateNetwork
	for rows.Next() {
		n, err := scanPrivnet(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, n)
	}
	return out, rows.Err()
}

// List returns the private networks of the workspace ctx acts in, oldest
// first.
func (s *PrivateNetworks) List(ctx context.Context) ([]PrivateNetwork, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return nil, err
	}
	return scanPrivnets(s.db.Query(ctx, `SELECT `+privnetCols+` FROM private_networks WHERE workspace_id = $1 ORDER BY id`, ws))
}

// Get returns one of the workspace's networks, or domain.ErrNotFound.
func (s *PrivateNetworks) Get(ctx context.Context, id int64) (PrivateNetwork, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return PrivateNetwork{}, err
	}
	return scanPrivnet(s.db.QueryRow(ctx, `SELECT `+privnetCols+` FROM private_networks WHERE workspace_id = $1 AND id = $2`, ws, id))
}

// privnetLock is the advisory lock class of private network saves.
const privnetLock int32 = 73001

// SaveFunc builds the row to save from the stored one (nil when creating),
// the workspace's other networks (no other save runs until this one ends)
// and the id the row has or will get. An error stops the save.
type SaveFunc func(id int64, cur *PrivateNetwork, others []PrivateNetwork) (PrivateNetwork, error)

// Save creates (id 0) or updates one of the workspace's networks. The
// workspace's rows stay locked while build runs, so two saves cannot both
// pass a check against each other. A nil SecretEnc keeps the stored
// secret; the reported status starts over.
func (s *PrivateNetworks) Save(ctx context.Context, id int64, build SaveFunc) (PrivateNetwork, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return PrivateNetwork{}, err
	}
	var saved PrivateNetwork
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// One save per workspace at a time, even when it has no network yet.
		if _, err := tx.Exec(ctx, `SELECT pg_advisory_xact_lock($1, $2)`, privnetLock, int32(ws)); err != nil { //nolint:gosec // G115: a lock key; a wrap only shares a lock
			return err
		}
		all, err := scanPrivnets(tx.Query(ctx, `SELECT `+privnetCols+` FROM private_networks WHERE workspace_id = $1 ORDER BY id`, ws))
		if err != nil {
			return err
		}
		others := make([]PrivateNetwork, 0, len(all))
		var cur *PrivateNetwork
		for i, n := range all {
			if n.ID == id {
				cur = &all[i]
				continue
			}
			others = append(others, n)
		}
		if id != 0 && cur == nil {
			return domain.ErrNotFound
		}
		if id == 0 {
			if err := tx.QueryRow(ctx, `SELECT nextval(pg_get_serial_sequence('private_networks', 'id'))`).Scan(&id); err != nil {
				return err
			}
		}
		n, err := build(id, cur, others)
		if err != nil {
			return err
		}
		routes, _ := json.Marshal(n.Routes)
		if n.Routes == nil {
			routes = []byte("[]")
		}
		saved, err = scanPrivnet(tx.QueryRow(ctx, `INSERT INTO private_networks
				(id, workspace_id, name, kind, enabled, secret_enc, secret_v, summary, token_hash, routes, ca_pem)
			VALUES ($1, $2, $3, $4, $5, $6, 2, $7, $8, $9, $10)
			ON CONFLICT (id) DO UPDATE SET name = $3, kind = $4, enabled = $5,
				secret_enc = COALESCE($6, private_networks.secret_enc),
				secret_v = CASE WHEN $6::bytea IS NULL THEN private_networks.secret_v ELSE 2 END,
				summary = $7, token_hash = $8, routes = $9, ca_pem = $10,
				status = 'connecting', last_error = '', up_at = NULL, handshake_at = NULL, detail = '', updated_at = now()
			RETURNING `+privnetCols, id, ws, n.Name, n.Kind, n.Enabled, n.SecretEnc, n.Summary, n.TokenHash, routes, n.CAPEM))
		return err
	})
	return saved, err
}

// SetToken replaces a connector's token hash.
func (s *PrivateNetworks) SetToken(ctx context.Context, id int64, hash string) error {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return err
	}
	tag, err := s.db.Exec(ctx, `UPDATE private_networks SET token_hash = $3, status = 'connecting', last_error = '',
		up_at = NULL, detail = '', updated_at = now() WHERE workspace_id = $1 AND id = $2`, ws, id, hash)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// Restart marks a network changed, so the gateway starts its tunnel
// again, and returns it.
func (s *PrivateNetworks) Restart(ctx context.Context, id int64) (PrivateNetwork, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return PrivateNetwork{}, err
	}
	return scanPrivnet(s.db.QueryRow(ctx, `UPDATE private_networks SET status = 'connecting', last_error = '', up_at = NULL,
		handshake_at = NULL, detail = '', updated_at = now() WHERE workspace_id = $1 AND id = $2 RETURNING `+privnetCols, ws, id))
}

// Delete removes one of the workspace's networks.
func (s *PrivateNetworks) Delete(ctx context.Context, id int64) error {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return err
	}
	tag, err := s.db.Exec(ctx, `DELETE FROM private_networks WHERE workspace_id = $1 AND id = $2`, ws, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// All returns every workspace's private networks (system work).
func (s *PrivateNetworks) All(ctx context.Context) ([]PrivateNetwork, error) {
	return scanPrivnets(s.db.Query(domain.System(ctx), `SELECT `+privnetCols+` FROM private_networks p
		WHERE EXISTS (SELECT 1 FROM workspaces w WHERE w.id = p.workspace_id AND w.deleted_at IS NULL)
		ORDER BY workspace_id, id`))
}

// Reseal replaces a network's sealed secret with one bound to the network
// (secret_v 2), if it is still the legacy one. It leaves updated_at alone:
// the config did not change, so the tunnel keeps running.
func (s *PrivateNetworks) Reseal(ctx context.Context, id int64, sealed []byte) error {
	_, err := s.db.Exec(domain.System(ctx), `UPDATE private_networks SET secret_enc = $2, secret_v = 2 WHERE id = $1 AND secret_v = 1`, id, sealed)
	return err
}

// SetStatus records what the gateway reported about a network's tunnel.
func (s *PrivateNetworks) SetStatus(ctx context.Context, st privnet.Status) error {
	_, err := s.db.Exec(domain.System(ctx), `UPDATE private_networks SET status = $3, last_error = $4, up_at = $5, handshake_at = $6, detail = $7
		WHERE id = $1 AND workspace_id = $2`, st.Network, st.Workspace, st.State, st.Error, st.Since, st.Handshake, st.Detail)
	return err
}

// AddDials records connections the gateway made. A network that is gone
// leaves the connection without one.
func (s *PrivateNetworks) AddDials(ctx context.Context, dials []privnet.Dial) error {
	if len(dials) == 0 {
		return nil
	}
	b := &pgx.Batch{}
	for _, d := range dials {
		b.Queue(`INSERT INTO private_dials (workspace_id, network_id, ticket_key, source, target, ok, error, bytes_in, bytes_out, at)
			SELECT $1, (SELECT id FROM private_networks WHERE id = $2 AND workspace_id = $1), $3, $4, $5, $6, $7, $8, $9, $10
			WHERE EXISTS (SELECT 1 FROM workspaces WHERE id = $1)`,
			d.Workspace, d.Network, d.Ticket, d.Source, d.Target, d.OK, d.Error, d.BytesIn, d.BytesOut, d.At)
	}
	return s.db.SendBatch(domain.System(ctx), b).Close()
}

// DialStats counts the workspace's connections since t, and those refused;
// network 0 counts every network's.
func (s *PrivateNetworks) DialStats(ctx context.Context, network int64, since time.Time) (total, refused int, err error) {
	err = s.db.QueryRow(ctx, `SELECT count(*), count(*) FILTER (WHERE NOT ok) FROM private_dials
		WHERE at >= $1 AND ($2 = 0 OR network_id = $2)`, since, network).Scan(&total, &refused)
	return total, refused, err
}

// Dials returns the workspace's latest connections, newest first; network
// 0 returns every network's.
func (s *PrivateNetworks) Dials(ctx context.Context, network int64, limit int) ([]privnet.Dial, error) {
	rows, err := s.db.Query(ctx, `SELECT workspace_id, COALESCE(network_id, 0), ticket_key, source, target, ok, error, bytes_in, bytes_out, at
		FROM private_dials WHERE $1 = 0 OR network_id = $1 ORDER BY at DESC, id DESC LIMIT $2`, network, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []privnet.Dial
	for rows.Next() {
		var d privnet.Dial
		if err := rows.Scan(&d.Workspace, &d.Network, &d.Ticket, &d.Source, &d.Target, &d.OK, &d.Error, &d.BytesIn, &d.BytesOut, &d.At); err != nil {
			return nil, err
		}
		out = append(out, d)
	}
	return out, rows.Err()
}

// PruneDials drops connections recorded before t.
func (s *PrivateNetworks) PruneDials(ctx context.Context, t time.Time) error {
	_, err := s.db.Exec(domain.System(ctx), `DELETE FROM private_dials WHERE at < $1`, t)
	return err
}
