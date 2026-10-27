// Package musecredits keeps the money of Muse runs on agnts's own Meta
// key: free credits an Admin gives a person (hackathon judges, trials),
// the live hold of every run, and the platform's monthly cap. It uses
// agnts-muse's PostgreSQL ledger in agnts's database.
//
// Bought credits stay where they are: a workspace's wallet
// (workspaces.credits_balance), paid through Payme and Click, charged by
// billing when a run ends. The ledger holds a copy of each wallet so runs
// can reserve from it while they run; the copy is synced from the wallet
// before every hold, counting what runs already spent but billing has not
// charged yet, so no money is counted twice or lost.
//
// A run pays its free credits first, then its wallet. billing.Settle
// charges the wallet only the part free credits did not pay.
package musecredits

import (
	"context"
	"errors"
	"fmt"
	"math"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/ledger/pgledger"
	"github.com/rustambekabdusalomov/agnts-muse/money"
	"github.com/rustambekabdusalomov/agnts-muse/msp"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// CreditUSD is what one agnts credit is worth: $0.01 of model cost.
const CreditUSD = money.Cent

// Config is the platform's limits.
type Config struct {
	// RunCap is the most credits one run may spend.
	RunCap int64
	// GlobalCapUSD caps every workspace's spend on agnts's key together,
	// per calendar month (0: no cap).
	GlobalCapUSD float64
}

// Spend reads a run's model spend so far (billing's store has it).
type Spend interface {
	RunCostUSD(ctx context.Context, runID int64) (float64, error)
}

// Service is the Muse money of a server.
type Service struct {
	cfg    Config
	db     *pgxpool.Pool
	ledger *pgledger.Ledger
	spend  Spend
	now    func() time.Time
}

// New returns the service. Call Migrate before use.
func New(cfg Config, db *pgxpool.Pool, spend Spend) *Service {
	return &Service{cfg: cfg, db: db, ledger: pgledger.New(db), spend: spend, now: time.Now}
}

// Migrate creates the ledger's tables.
func (s *Service) Migrate(ctx context.Context) error {
	return s.ledger.Migrate(domain.System(ctx))
}

// Ledger is the ledger Muse runs reserve from. The ledger's tables are
// the platform's, not a workspace's, so every call runs as the system,
// whatever workspace the run's context is scoped to.
func (s *Service) Ledger() budget.Ledger { return systemLedger{s.ledger} }

// Reap returns the money of holds whose runs died without settling.
func (s *Service) Reap(ctx context.Context) (int, error) {
	return s.ledger.Reap(domain.System(ctx), s.now())
}

type systemLedger struct{ l *pgledger.Ledger }

func (s systemLedger) Hold(ctx context.Context, r budget.HoldRequest) (budget.Hold, error) {
	return s.l.Hold(domain.System(ctx), r)
}

func (s systemLedger) Extend(ctx context.Context, id budget.HoldID, by money.USD) (budget.Hold, error) {
	return s.l.Extend(domain.System(ctx), id, by)
}

func (s systemLedger) Commit(ctx context.Context, id budget.HoldID, actual money.USD) (budget.Receipt, error) {
	return s.l.Commit(domain.System(ctx), id, actual)
}

func (s systemLedger) Release(ctx context.Context, id budget.HoldID) error {
	return s.l.Release(domain.System(ctx), id)
}

// Accounts.
func freeAccount(user int64) budget.AccountID {
	return budget.AccountID("user:" + strconv.FormatInt(user, 10) + ":free")
}

func walletAccount(ws int64) budget.AccountID {
	return budget.AccountID("ws:" + strconv.FormatInt(ws, 10) + ":wallet")
}

func (s *Service) capAccount() budget.AccountID {
	return budget.AccountID("cap:platform:" + s.now().UTC().Format("2006-01"))
}

// runKeyPrefix starts the hold keys of a run's invocations.
func runKeyPrefix(ws, run int64) string { return fmt.Sprintf("ws:%d:run:%d:", ws, run) }

// Budget implements runner.MuseBudgets: a ticket run on agnts's key pays
// its member's free credits first, then the workspace's wallet, and
// counts against the platform's monthly cap. Runs on a person's own Muse
// account, and calls outside a ticket run, get no budget (they are
// settled afterwards as before).
func (s *Service) Budget(ctx context.Context, req orchestrator.ClaudeRequest) (*muse.Budget, error) {
	acct, ok := domain.ClaudeOf(ctx)
	if !ok || !acct.Credits || req.RunID == 0 {
		return nil, nil
	}
	ws := req.WorkspaceID
	if ws == 0 {
		ws = domain.WorkspaceOf(ctx)
	}
	if ws == 0 {
		return nil, errors.New("a run on credits needs a workspace")
	}
	sys := domain.System(ctx)
	if err := s.syncWallet(sys, ws); err != nil {
		return nil, err
	}
	b := &muse.Budget{Key: runKeyPrefix(ws, req.RunID) + msp.NewCommandID(), Payers: []budget.AccountID{walletAccount(ws)}}
	if acct.UserID > 0 {
		b.Payers = []budget.AccountID{freeAccount(acct.UserID), walletAccount(ws)}
	}
	if s.cfg.GlobalCapUSD > 0 {
		capAcct := s.capAccount()
		if _, err := s.ledger.Deposit(sys, capAcct, money.Dollars(s.cfg.GlobalCapUSD), string(capAcct)); err != nil {
			return nil, err
		}
		b.Caps = []budget.AccountID{capAcct}
	}
	// The run's limit: the workspace's budget per run (Settings), else the
	// server's cap, less what the run spent already, and never more than
	// its payers have, so the ticket shows the limit that really applies.
	capCredits := s.cfg.RunCap
	if req.Budget > 0 && (capCredits <= 0 || req.Budget < capCredits) {
		capCredits = req.Budget
	}
	if capCredits > 0 {
		spent := 0.0
		if s.spend != nil {
			spent, _ = s.spend.RunCostUSD(sys, req.RunID)
		}
		left := money.USD(capCredits)*CreditUSD - money.Dollars(spent)
		if left <= 0 {
			return nil, fmt.Errorf("%w: this run reached its budget of %d credits", muse.ErrRunLimit, capCredits)
		}
		b.Limit = left
	}
	var funds money.USD
	for _, p := range b.Payers {
		if bal, err := s.ledger.Balance(sys, p); err == nil {
			funds += money.Max(bal.Available, 0)
		}
	}
	if funds <= 0 {
		return nil, fmt.Errorf("%w: no credits left (free credits and the workspace's)", muse.ErrBudget)
	}
	if b.Limit == 0 || funds < b.Limit {
		b.Limit = funds
	}
	return b, nil
}

// syncWallet makes the ledger's copy of a wallet match it: the wallet's
// balance, less what runs spent from it that billing has not charged yet.
// The deposit is keyed by the wallet's last ledger entry, so it happens
// once per change of the wallet.
func (s *Service) syncWallet(ctx context.Context, ws int64) error {
	var balance, last int64
	if err := s.db.QueryRow(ctx, `SELECT w.credits_balance, COALESCE((SELECT max(id) FROM credit_ledger WHERE workspace_id = w.id), 0)
		FROM workspaces w WHERE w.id = $1`, ws).Scan(&balance, &last); err != nil {
		return fmt.Errorf("read wallet: %w", err)
	}
	var unsettled int64
	if err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(l.charged), 0) FROM muse_hold_legs l JOIN muse_holds h ON h.id = l.hold_id
		WHERE l.account_id = $1 AND h.key LIKE $2 AND NOT EXISTS (
			SELECT 1 FROM credit_ledger c WHERE c.workspace_id = $3 AND c.reason = 'run'
			AND c.run_id = split_part(h.key, ':', 4)::bigint)`,
		string(walletAccount(ws)), fmt.Sprintf("ws:%d:run:%%", ws), ws).Scan(&unsettled); err != nil {
		return fmt.Errorf("read unsettled spend: %w", err)
	}
	cur, err := s.ledger.Balance(ctx, walletAccount(ws))
	if err != nil {
		return err
	}
	// What the copy should hold, before this run: the wallet minus what
	// finished invocations spent that billing has not charged yet.
	target := money.USD(balance)*CreditUSD - money.USD(unsettled)
	if delta := target - cur.Total; delta != 0 {
		key := fmt.Sprintf("sync:ws:%d:%d:%d", ws, last, int64(target))
		if _, err := s.ledger.Deposit(ctx, walletAccount(ws), delta, key); err != nil && !errors.Is(err, budget.ErrInsufficient) {
			return err
		} else if err != nil {
			// The wallet shrank below what running holds reserve (a
			// monthly fee came out): take what is free now.
			if b, berr := s.ledger.Balance(ctx, walletAccount(ws)); berr == nil && b.Available > 0 {
				_, _ = s.ledger.Deposit(ctx, walletAccount(ws), -b.Available, key+":partial")
			}
		}
	}
	return nil
}

// FreeChargedUSD is what free credits paid of a run (billing charges the
// wallet only the rest).
func (s *Service) FreeChargedUSD(ctx context.Context, runID int64) (float64, error) {
	var micro int64
	err := s.db.QueryRow(domain.System(ctx), `SELECT COALESCE(sum(l.charged), 0) FROM muse_hold_legs l JOIN muse_holds h ON h.id = l.hold_id
		WHERE l.account_id LIKE 'user:%:free' AND split_part(h.key, ':', 3) = 'run' AND split_part(h.key, ':', 4) = $1`,
		strconv.FormatInt(runID, 10)).Scan(&micro)
	return money.USD(micro).Float(), err
}

// FreeCredits is a person's free credits, in credits.
type FreeCredits struct {
	Limit     int64 // what an Admin set
	Used      int64
	Remaining int64
	SetBy     *int64
	SetAt     *time.Time
}

// Free returns a person's free credits.
func (s *Service) Free(ctx context.Context, user int64) (FreeCredits, error) {
	sys := domain.System(ctx)
	var f FreeCredits
	if err := s.db.QueryRow(sys, `SELECT free_credits_limit, free_credits_set_by, free_credits_set_at FROM users WHERE id = $1`, user).
		Scan(&f.Limit, &f.SetBy, &f.SetAt); err != nil {
		return f, err
	}
	granted, err := s.granted(sys, user)
	if err != nil {
		return f, err
	}
	b, err := s.ledger.Balance(sys, freeAccount(user))
	if err != nil {
		return f, err
	}
	f.Remaining = int64(b.Available / CreditUSD)
	f.Used = toCredits(granted - b.Total)
	return f, nil
}

// FreeAvailable is how much free money a person has for a new run.
func (s *Service) FreeAvailable(ctx context.Context, user int64) money.USD {
	b, err := s.ledger.Balance(domain.System(ctx), freeAccount(user))
	if err != nil {
		return 0
	}
	return b.Available
}

func (s *Service) granted(ctx context.Context, user int64) (money.USD, error) {
	var micro int64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(amount), 0) FROM muse_entries WHERE account_id = $1 AND kind = 'deposit'`,
		string(freeAccount(user))).Scan(&micro)
	return money.USD(micro), err
}

// SetFree sets a person's free-credit limit (credits, 0 to stop giving
// more). Raising it adds the difference; lowering it takes back what is
// still unspent, down to the new limit.
func (s *Service) SetFree(ctx context.Context, user, limit, by int64) (FreeCredits, error) {
	if limit < 0 || limit > 10_000_000 {
		return FreeCredits{}, errors.New("free credits must be between 0 and 10,000,000")
	}
	sys := domain.System(ctx)
	tag, err := s.db.Exec(sys, `UPDATE users SET free_credits_limit = $2, free_credits_set_by = $3, free_credits_set_at = now() WHERE id = $1`,
		user, limit, by)
	if err != nil {
		return FreeCredits{}, err
	}
	if tag.RowsAffected() == 0 {
		return FreeCredits{}, domain.ErrNotFound
	}
	granted, err := s.granted(sys, user)
	if err != nil {
		return FreeCredits{}, err
	}
	delta := money.USD(limit)*CreditUSD - granted
	if delta < 0 {
		// Take back only what is unspent: spent free credits stay spent.
		b, err := s.ledger.Balance(sys, freeAccount(user))
		if err != nil {
			return FreeCredits{}, err
		}
		delta = -money.Min(-delta, b.Available)
	}
	if delta != 0 {
		key := fmt.Sprintf("free:user:%d:%d:%d", user, limit, s.now().UnixNano())
		if _, err := s.ledger.Deposit(sys, freeAccount(user), delta, key); err != nil {
			return FreeCredits{}, err
		}
	}
	return s.Free(ctx, user)
}

func toCredits(u money.USD) int64 { return int64(math.Ceil(float64(u) / float64(CreditUSD))) }
