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

// Spend on the fallback provider (Baseten's prepaid hackathon credit) is
// the platform's cost, not people's: the platform account
// platform:fallback pays for it (muse.Budget.FallbackPayers), holding what
// is left of AGNTS_MUSE_FALLBACK_CAP_USD, so no one's free credits or
// wallet are charged and billing leaves it out (FreeChargedUSD). What a
// person may use there is limited by a monthly allowance, a cap account
// (fcap:user:<id>:<YYYY-MM>) that only spend on the fallback counts
// against. A fallback run's hold key ends in ":" + the provider's name,
// which is how its spend is counted.

func (s *Service) userFallbackCap(user int64) budget.AccountID {
	return budget.AccountID("fcap:user:" + strconv.FormatInt(user, 10) + ":" + s.now().UTC().Format("2006-01"))
}

// platformFallback pays for every run's spend on the fallback.
const platformFallback budget.AccountID = "platform:fallback"

// unlimitedFallback is what platformFallback holds when the server sets no
// cap: far beyond any month's runs.
const unlimitedFallback = 1_000_000 * money.Dollar

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

// fallbackBudget makes the platform pay for a run's spend on the
// fallback, within the person's monthly room there and what is left of
// the server's total. With no room left, the run may not move there
// (muse.ErrFallbackLimit).
func (s *Service) fallbackBudget(ctx context.Context, b *muse.Budget, user int64) error {
	room, limited, caps, err := s.fallbackRoom(ctx, user)
	if err != nil || s.cfg.Fallback == "" {
		return err
	}
	b.FallbackPayers, b.FallbackCaps = []budget.AccountID{platformFallback}, caps
	switch {
	case room <= 0:
		b.FallbackLimit = -1
	case limited:
		b.FallbackLimit = room
	}
	return nil
}

// fallbackRoom syncs the platform's fallback account and the person's
// allowance, and returns what they may still spend there (limited is
// false when only the platform's account bounds it) and their caps.
func (s *Service) fallbackRoom(ctx context.Context, user int64) (room money.USD, limited bool, caps []budget.AccountID, err error) {
	if s.cfg.Fallback == "" {
		return 0, false, nil, nil
	}
	used, err := s.fallbackSpent(ctx, "ws:%:run:%", time.Time{})
	if err != nil {
		return 0, false, nil, err
	}
	target := unlimitedFallback
	if s.cfg.FallbackCapUSD > 0 {
		target, limited = money.Dollars(s.cfg.FallbackCapUSD)-used, true
	}
	if room, err = s.fillCap(ctx, platformFallback, target, fmt.Sprintf("fpay:%d:%d", int64(target+used), int64(used))); err != nil {
		return 0, false, nil, err
	}
	if user > 0 {
		f, err := s.fallbackUsage(ctx, user)
		if err != nil {
			return 0, false, nil, err
		}
		if f.MonthLimit > 0 {
			acct := s.userFallbackCap(user)
			left, err := s.fillCap(ctx, acct, money.USD(f.MonthLimit)*CreditUSD-f.spent, fmt.Sprintf("fcap:%s:%d:%d", acct, f.MonthLimit, int64(f.spent)))
			if err != nil {
				return 0, false, nil, err
			}
			caps = append(caps, acct)
			room, limited = money.Min(room, left), true
		}
	}
	return room, limited, caps, nil
}

// FallbackAvailable is claude.Config.Fallback: whether a person's runs may
// use the fallback provider now (one is configured, an Admin has not
// chosen Meta only, and the person and the server have room left there).
func (s *Service) FallbackAvailable(ctx context.Context, user int64) bool {
	if s.cfg.Fallback == "" || s.Mode() == muse.ModePrimary {
		return false
	}
	room, _, _, err := s.fallbackRoom(domain.System(ctx), user)
	return err == nil && room > 0
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
