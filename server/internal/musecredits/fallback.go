package musecredits

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"time"

	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/money"

	"agnts/internal/domain"
)

// Spend on the fallback provider is limited apart from agnts's Meta key:
// a person's monthly allowance there (fcap:user:<id>:<YYYY-MM>) and the
// fallback's total for the whole server (fcap:platform). Both are cap
// accounts that muse.Failover adds to a run's caps only when it moves to
// the fallback (muse.Budget.FallbackCaps), so spend on Meta never uses
// them up. A fallback run's hold key ends in ":" + the provider's name,
// which is how its spend is counted.

func (s *Service) userFallbackCap(user int64) budget.AccountID {
	return budget.AccountID("fcap:user:" + strconv.FormatInt(user, 10) + ":" + s.now().UTC().Format("2006-01"))
}

const platformFallbackCap budget.AccountID = "fcap:platform"

// FallbackUsage is what a person spent on the fallback provider this
// month and their limit there, in credits.
type FallbackUsage struct {
	Provider   string
	MonthLimit int64 // 0: no limit
	MonthUsed  int64
	// Default is true while the limit is the server's
	// (AGNTS_MUSE_FALLBACK_USER_LIMIT), not one an Admin set.
	Default bool
	SetBy   *int64
	SetAt   *time.Time

	spent money.USD // MonthUsed exactly
}

// fallbackBudget limits what a run may spend on the fallback: the
// person's monthly room there and what is left of the server's total.
// With no room left, the run may not move (muse.ErrFallbackLimit).
func (s *Service) fallbackBudget(ctx context.Context, b *muse.Budget, user int64) error {
	if s.cfg.Fallback == "" {
		return nil
	}
	limited, room := false, money.USD(0)
	narrow := func(left money.USD) {
		if !limited || left < room {
			room = left
		}
		limited = true
	}
	if user > 0 {
		f, err := s.fallbackUsage(ctx, user)
		if err != nil {
			return err
		}
		if f.MonthLimit > 0 {
			acct := s.userFallbackCap(user)
			used := f.spent
			left, err := s.fillCap(ctx, acct, money.USD(f.MonthLimit)*CreditUSD-used, fmt.Sprintf("fcap:%s:%d:%d", acct, f.MonthLimit, int64(used)))
			if err != nil {
				return err
			}
			b.FallbackCaps = append(b.FallbackCaps, acct)
			narrow(left)
		}
	}
	if s.cfg.FallbackCapUSD > 0 {
		used, err := s.fallbackSpent(ctx, "ws:%:run:%", time.Time{})
		if err != nil {
			return err
		}
		capUSD := money.Dollars(s.cfg.FallbackCapUSD)
		left, err := s.fillCap(ctx, platformFallbackCap, capUSD-used, fmt.Sprintf("fcap:%s:%d:%d", platformFallbackCap, int64(capUSD), int64(used)))
		if err != nil {
			return err
		}
		b.FallbackCaps = append(b.FallbackCaps, platformFallbackCap)
		narrow(left)
	}
	switch {
	case limited && room <= 0:
		b.FallbackLimit = -1
	case limited:
		b.FallbackLimit = room
	}
	return nil
}

// fallbackSpent is what runs whose hold key starts with prefix (a LIKE
// pattern) spent on the fallback provider since t.
func (s *Service) fallbackSpent(ctx context.Context, prefix string, t time.Time) (money.USD, error) {
	var micro int64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(l.charged), 0) FROM muse_hold_legs l JOIN muse_holds h ON h.id = l.hold_id
		WHERE NOT l.is_cap AND h.created_at >= $1 AND h.key LIKE $2`, t, prefix+"%:"+s.cfg.Fallback).Scan(&micro)
	return money.USD(micro), err
}

// fallbackUsage is a person's spend on the fallback this month and the
// limit that applies to them.
func (s *Service) fallbackUsage(ctx context.Context, user int64) (FallbackUsage, error) {
	f := FallbackUsage{Provider: s.cfg.Fallback}
	var limit *int64
	if err := s.db.QueryRow(ctx, `SELECT fallback_limit_monthly, fallback_limit_set_by, fallback_limit_set_at FROM users WHERE id = $1`, user).
		Scan(&limit, &f.SetBy, &f.SetAt); err != nil {
		return f, fmt.Errorf("read fallback limit: %w", err)
	}
	f.MonthLimit, f.Default = s.cfg.FallbackUserLimit, limit == nil
	if limit != nil {
		f.MonthLimit = *limit
	}
	used, err := s.fallbackSpent(ctx, "ws:%:run:%:"+userKeyPart(user), monthStart(s.now()))
	if err != nil {
		return f, err
	}
	f.spent, f.MonthUsed = used, toCredits(used)
	return f, nil
}

// SetFallbackLimit sets the credits a person may spend on the fallback
// provider a month (0: no limit; nil: the server's default). It applies to
// the next run; a running one keeps what it reserved.
func (s *Service) SetFallbackLimit(ctx context.Context, user int64, limit *int64, by int64) (Usage, error) {
	if s.cfg.Fallback == "" {
		return Usage{}, errors.New("this server has no fallback provider (AGNTS_MUSE_FALLBACK_KEY)")
	}
	if limit != nil && (*limit < 0 || *limit > 10_000_000) {
		return Usage{}, errors.New("the fallback limit must be between 0 and 10,000,000 credits")
	}
	sys := domain.System(ctx)
	tag, err := s.db.Exec(sys, `UPDATE users SET fallback_limit_monthly = $2, fallback_limit_set_by = $3, fallback_limit_set_at = now() WHERE id = $1`,
		user, limit, by)
	if err != nil {
		return Usage{}, err
	}
	if tag.RowsAffected() == 0 {
		return Usage{}, domain.ErrNotFound
	}
	return s.Usage(ctx, user)
}
