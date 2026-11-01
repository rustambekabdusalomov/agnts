package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// LedgerEntry is one change of a workspace's credits.
type LedgerEntry struct {
	ID          int64
	WorkspaceID int64
	Amount      int64
	Reason      string // purchase, run, document, refund, grant
	RunID       *int64
	// DocumentRunID is the document generation charged (reason document).
	DocumentRunID *int64
	TicketKey     string
	PaymentID     *int64
	Note          string
	CreatedBy     *int64
	CreatedAt     time.Time
}

// Ledger reasons.
const (
	CreditPurchase = "purchase"
	CreditRun      = "run"
	CreditDocument = "document"
	CreditRefund   = "refund"
	CreditGrant    = "grant"
)

// Credits keeps workspaces' credit balances and the ledger behind them.
type Credits struct{ db *pgxpool.Pool }

// NewCredits returns the credits store.
func NewCredits(db *pgxpool.Pool) *Credits { return &Credits{db: db} }

// ErrAlreadyCharged means a run was charged before.
var ErrAlreadyCharged = errors.New("this run was charged already")

// Add changes a workspace's balance by e.Amount and records why, in one
// transaction; it returns the new balance. A run is charged once.
func (s *Credits) Add(ctx context.Context, e LedgerEntry) (int64, error) {
	var bal int64
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error { return addCredits(ctx, tx, e, &bal) })
	return bal, err
}

func addCredits(ctx context.Context, tx pgx.Tx, e LedgerEntry, bal *int64) error {
	_, err := tx.Exec(ctx, `INSERT INTO credit_ledger (workspace_id, amount, reason, run_id, ticket_key, payment_id, note, created_by, document_run_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, e.WorkspaceID, e.Amount, e.Reason, e.RunID, e.TicketKey, e.PaymentID, e.Note, e.CreatedBy, e.DocumentRunID)
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return ErrAlreadyCharged
	}
	if err != nil {
		return err
	}
	return tx.QueryRow(ctx, `UPDATE workspaces SET credits_balance = credits_balance + $2, updated_at = now()
		WHERE id = $1 RETURNING credits_balance`, e.WorkspaceID, e.Amount).Scan(bal)
}

// Balance returns a workspace's credits.
func (s *Credits) Balance(ctx context.Context, ws int64) (int64, error) {
	var b int64
	err := s.db.QueryRow(ctx, `SELECT credits_balance FROM workspaces WHERE id = $1`, ws).Scan(&b)
	return b, notFound(err)
}

// Ledger returns a workspace's newest ledger entries.
func (s *Credits) Ledger(ctx context.Context, ws int64, limit int) ([]LedgerEntry, error) {
	rows, err := s.db.Query(ctx, `SELECT id, workspace_id, amount, reason, run_id, ticket_key, payment_id, note, created_by, created_at
		FROM credit_ledger WHERE workspace_id = $1 ORDER BY id DESC LIMIT $2`, ws, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []LedgerEntry
	for rows.Next() {
		var e LedgerEntry
		if err := rows.Scan(&e.ID, &e.WorkspaceID, &e.Amount, &e.Reason, &e.RunID, &e.TicketKey, &e.PaymentID, &e.Note, &e.CreatedBy, &e.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

// DocumentRunCostUSD returns what a document generation's calls on
// credits cost on the API.
func (s *Credits) DocumentRunCostUSD(ctx context.Context, runID int64) (float64, error) {
	var usd float64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(cost_usd), 0)::float8 FROM claude_calls WHERE document_run_id = $1 AND on_credits`, runID).Scan(&usd)
	return usd, err
}

// RunCostUSD returns what a run's calls on credits cost on the API: calls
// on a connection are paid by its owner, not the workspace's credits.
func (s *Credits) RunCostUSD(ctx context.Context, runID int64) (float64, error) {
	var usd float64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(cost_usd), 0)::float8 FROM claude_calls WHERE run_id = $1 AND on_credits`, runID).Scan(&usd)
	return usd, err
}

// Payment is a purchase of credits through a payment provider.
type Payment struct {
	ID           int64
	WorkspaceID  int64
	Provider     string // payme or click
	AmountUZS    int64
	Credits      int64
	State        string // created, pending, paid, cancelled
	ProviderTxn  string
	ProviderTime int64 // the provider's transaction time (ms), Payme
	Reason       *int
	CreatedBy    *int64
	CreatedAt    time.Time
	PerformedAt  *time.Time
	CancelledAt  *time.Time
}

// Payment states.
const (
	PaymentCreated   = "created"
	PaymentPending   = "pending"
	PaymentPaid      = "paid"
	PaymentCancelled = "cancelled"
)

const paymentCols = `id, workspace_id, provider, amount_uzs, credits, state, provider_txn, provider_time, reason, created_by, created_at, performed_at, cancelled_at`

func scanPayment(row pgx.Row) (Payment, error) {
	var p Payment
	err := row.Scan(&p.ID, &p.WorkspaceID, &p.Provider, &p.AmountUZS, &p.Credits, &p.State, &p.ProviderTxn, &p.ProviderTime,
		&p.Reason, &p.CreatedBy, &p.CreatedAt, &p.PerformedAt, &p.CancelledAt)
	return p, notFound(err)
}

// CreatePayment starts a purchase.
func (s *Credits) CreatePayment(ctx context.Context, p Payment) (Payment, error) {
	return scanPayment(s.db.QueryRow(ctx, `INSERT INTO payments (workspace_id, provider, amount_uzs, credits, created_by)
		VALUES ($1, $2, $3, $4, $5) RETURNING `+paymentCols, p.WorkspaceID, p.Provider, p.AmountUZS, p.Credits, p.CreatedBy))
}

// PaymentByID returns a payment.
func (s *Credits) PaymentByID(ctx context.Context, id int64) (Payment, error) {
	return scanPayment(s.db.QueryRow(ctx, `SELECT `+paymentCols+` FROM payments WHERE id = $1`, id))
}

// PaymentByTxn returns a payment by the provider's transaction id.
func (s *Credits) PaymentByTxn(ctx context.Context, provider, txn string) (Payment, error) {
	return scanPayment(s.db.QueryRow(ctx, `SELECT `+paymentCols+` FROM payments WHERE provider = $1 AND provider_txn = $2`, provider, txn))
}

// BeginPayment records the provider's transaction for a created payment
// and moves it to pending. It returns the payment as stored; a payment
// already bound to another transaction gives ErrConflict.
func (s *Credits) BeginPayment(ctx context.Context, id int64, txn string, at int64) (Payment, error) {
	var out Payment
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		p, err := scanPayment(tx.QueryRow(ctx, `SELECT `+paymentCols+` FROM payments WHERE id = $1 FOR UPDATE`, id))
		if err != nil {
			return err
		}
		if p.ProviderTxn != "" && p.ProviderTxn != txn {
			return domain.ErrConflict
		}
		if p.State != PaymentCreated && p.State != PaymentPending {
			out = p
			return nil
		}
		out, err = scanPayment(tx.QueryRow(ctx, `UPDATE payments SET provider_txn = $2, provider_time = $3, state = 'pending'
			WHERE id = $1 RETURNING `+paymentCols, id, txn, at))
		return err
	})
	return out, err
}

// CompletePayment marks a pending payment paid and adds its credits, once.
func (s *Credits) CompletePayment(ctx context.Context, id int64) (Payment, error) {
	var out Payment
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		p, err := scanPayment(tx.QueryRow(ctx, `SELECT `+paymentCols+` FROM payments WHERE id = $1 FOR UPDATE`, id))
		if err != nil {
			return err
		}
		if p.State == PaymentPaid || p.State == PaymentCancelled {
			out = p
			return nil
		}
		if out, err = scanPayment(tx.QueryRow(ctx, `UPDATE payments SET state = 'paid', performed_at = now()
			WHERE id = $1 RETURNING `+paymentCols, id)); err != nil {
			return err
		}
		var bal int64
		return addCredits(ctx, tx, LedgerEntry{WorkspaceID: p.WorkspaceID, Amount: p.Credits, Reason: CreditPurchase, PaymentID: &p.ID,
			Note: p.Provider, CreatedBy: p.CreatedBy}, &bal)
	})
	return out, err
}

// CancelPayment cancels a payment; a paid one gives its credits back (the
// balance may go below zero, holding further credit runs).
func (s *Credits) CancelPayment(ctx context.Context, id int64, reason int) (Payment, error) {
	var out Payment
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		p, err := scanPayment(tx.QueryRow(ctx, `SELECT `+paymentCols+` FROM payments WHERE id = $1 FOR UPDATE`, id))
		if err != nil {
			return err
		}
		if p.State == PaymentCancelled {
			out = p
			return nil
		}
		wasPaid := p.State == PaymentPaid
		if out, err = scanPayment(tx.QueryRow(ctx, `UPDATE payments SET state = 'cancelled', cancelled_at = now(), reason = $2
			WHERE id = $1 RETURNING `+paymentCols, id, reason)); err != nil {
			return err
		}
		if !wasPaid {
			return nil
		}
		var bal int64
		return addCredits(ctx, tx, LedgerEntry{WorkspaceID: p.WorkspaceID, Amount: -p.Credits, Reason: CreditRefund, PaymentID: &p.ID,
			Note: p.Provider + " payment cancelled"}, &bal)
	})
	return out, err
}

// PaymentsBetween returns a provider's payments made in [from, to] (Payme's
// GetStatement).
func (s *Credits) PaymentsBetween(ctx context.Context, provider string, from, to int64) ([]Payment, error) {
	rows, err := s.db.Query(ctx, `SELECT `+paymentCols+` FROM payments WHERE provider = $1 AND provider_txn <> ''
		AND provider_time BETWEEN $2 AND $3 ORDER BY provider_time`, provider, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Payment
	for rows.Next() {
		p, err := scanPayment(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}
