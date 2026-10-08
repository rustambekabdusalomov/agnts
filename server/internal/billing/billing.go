// Package billing charges workspaces: the base plan and extra slots and
// members, paid a month at a time from a prepaid balance of credits, and
// the runs that ran on agnts's API key. Credits are bought through Payme or
// Click (see payme.go and click.go). 1 credit is $0.01 of Anthropic API
// cost; its price in so'm includes the markup.
package billing

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"math"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Config is the platform's prices and rules.
type Config struct {
	// Enabled turns billing on (the hosted product). Off, workspaces are
	// self-hosted: no fees, slots set by the Admin.
	Enabled bool
	// Prices in so'm.
	WorkspaceUZS, SlotUZS, MemberUZS, CreditUZS int64
	IncludedMembers, MaxSlots                   int
	// Markup is what a credit's price adds to API cost (1.4 = 40%).
	Markup float64
	// RunCap is the most credits one run may spend.
	RunCap int64
	// PublicURL is where payment pages send the person back to.
	PublicURL string
	Payme     PaymeConfig
	Click     ClickConfig
}

// Store is what billing reads and writes.
type Store interface {
	Add(ctx context.Context, e postgres.LedgerEntry) (int64, error)
	Balance(ctx context.Context, ws int64) (int64, error)
	Ledger(ctx context.Context, ws int64, limit int) ([]postgres.LedgerEntry, error)
	RunCostUSD(ctx context.Context, runID int64) (float64, error)
	CreatePayment(ctx context.Context, p postgres.Payment) (postgres.Payment, error)
	PaymentByID(ctx context.Context, id int64) (postgres.Payment, error)
	PaymentByTxn(ctx context.Context, provider, txn string) (postgres.Payment, error)
	BeginPayment(ctx context.Context, id int64, txn string, at int64) (postgres.Payment, error)
	CompletePayment(ctx context.Context, id int64) (postgres.Payment, error)
	CancelPayment(ctx context.Context, id int64, reason int) (postgres.Payment, error)
	PaymentsBetween(ctx context.Context, provider string, from, to int64) ([]postgres.Payment, error)
}

// Workspaces changes plans and reads members.
type Workspaces interface {
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
	Members(ctx context.Context, ws int64) ([]domain.Member, error)
	SetPlan(ctx context.Context, ws int64, p postgres.PlanUpdate) (domain.Workspace, error)
	SetSuspended(ctx context.Context, ws int64, suspended bool) (domain.Workspace, error)
	Active(ctx context.Context) ([]int64, error)
	SetPaidUntil(ctx context.Context, ws int64, t time.Time) error
	PaidUntil(ctx context.Context, ws int64) (*time.Time, error)
}

// Events records billing changes in the workspace's log.
type Events interface {
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Service is billing.
type Service struct {
	cfg    Config
	store  Store
	ws     Workspaces
	events Events
	log    *slog.Logger
	now    func() time.Time
	// changed is told when a workspace's plan or balance changed (the
	// scheduler's cache).
	changed func(ws int64)
}

// New returns the billing service.
func New(cfg Config, store Store, ws Workspaces, events Events, log *slog.Logger) *Service {
	if cfg.MaxSlots < 1 {
		cfg.MaxSlots = 5
	}
	if cfg.Markup < 1 {
		cfg.Markup = 1.4
	}
	return &Service{cfg: cfg, store: store, ws: ws, events: events, log: log, now: time.Now, changed: func(int64) {}}
}

// OnChange sets what is told when a workspace's plan or balance changed.
func (s *Service) OnChange(f func(ws int64)) { s.changed = f }

// Enabled reports whether workspaces pay here.
func (s *Service) Enabled() bool { return s.cfg.Enabled }

// PaymentsEnabled reports whether a payment provider is set up.
func (s *Service) PaymentsEnabled() bool { return s.cfg.Payme.enabled() || s.cfg.Click.enabled() }

// Prices is the price list.
type Prices struct {
	WorkspaceUZS, SlotUZS, MemberUZS, CreditUZS int64
	IncludedMembers                             int
	Markup                                      float64
}

// View is a workspace's billing page.
type View struct {
	Plan            string
	Slots, MaxSlots int
	MemberLimit     int
	Members         int
	Balance         int64
	TrialEndsAt     *time.Time
	PaidUntil       *time.Time
	MonthlyUZS      int64
	Ledger          []postgres.LedgerEntry
	Prices          Prices
	PaymentsEnabled bool
	SelfHosted      bool
}

// Monthly is what a workspace with slots slots and members members costs a
// month, in so'm.
func (s *Service) Monthly(slots, members int) int64 {
	extraMembers := max(0, members-s.cfg.IncludedMembers)
	return s.cfg.WorkspaceUZS + int64(max(0, slots-1))*s.cfg.SlotUZS + int64(extraMembers)*s.cfg.MemberUZS
}

// MonthlyCredits is a month's fee in credits.
func (s *Service) MonthlyCredits(slots, members int) int64 {
	if s.cfg.CreditUZS <= 0 {
		return 0
	}
	return ceilDiv(s.Monthly(slots, members), s.cfg.CreditUZS)
}

func ceilDiv(a, b int64) int64 { return (a + b - 1) / b }

// who is the person behind a change, nil for the platform itself.
func who(id int64) *int64 {
	if id <= 0 {
		return nil
	}
	return &id
}

// View returns a workspace's billing page.
func (s *Service) View(ctx context.Context, ws int64) (View, error) {
	w, err := s.ws.ByID(ctx, ws)
	if err != nil {
		return View{}, err
	}
	members, err := s.ws.Members(ctx, ws)
	if err != nil {
		return View{}, err
	}
	ledger, err := s.store.Ledger(ctx, ws, 50)
	if err != nil {
		return View{}, err
	}
	paid, err := s.ws.PaidUntil(ctx, ws)
	if err != nil {
		return View{}, err
	}
	v := View{Plan: w.Plan, Slots: w.Slots, MaxSlots: s.cfg.MaxSlots, MemberLimit: w.MemberLimit, Members: len(members),
		Balance: w.CreditsBalance, TrialEndsAt: w.TrialEndsAt, PaidUntil: paid, Ledger: ledger,
		Prices: Prices{WorkspaceUZS: s.cfg.WorkspaceUZS, SlotUZS: s.cfg.SlotUZS, MemberUZS: s.cfg.MemberUZS, CreditUZS: s.cfg.CreditUZS,
			IncludedMembers: s.cfg.IncludedMembers, Markup: s.cfg.Markup},
		PaymentsEnabled: s.PaymentsEnabled(), SelfHosted: !s.cfg.Enabled}
	if s.cfg.Enabled {
		v.MonthlyUZS = s.Monthly(w.Slots, len(members))
	}
	return v, nil
}

// Error is a billing refusal the person can act on.
type Error struct {
	Msg     string
	Payment bool // more credits are needed
}

func (e *Error) Error() string { return e.Msg }

// SetSlots changes a workspace's slots. The owner of a paying workspace
// pays the rest of this month's difference now, from credits; a
// self-hosted workspace's slots are the Admin's (admin is true).
func (s *Service) SetSlots(ctx context.Context, ws int64, slots int, by int64, admin bool) (View, error) {
	if slots < 1 || slots > s.cfg.MaxSlots {
		return View{}, &Error{Msg: fmt.Sprintf("slots must be from 1 to %d", s.cfg.MaxSlots)}
	}
	w, err := s.ws.ByID(ctx, ws)
	if err != nil {
		return View{}, err
	}
	if !s.cfg.Enabled && !admin {
		return View{}, &Error{Msg: "on this server the Admin sets slots"}
	}
	if s.cfg.Enabled && slots > w.Slots && !s.inTrial(w) {
		paid, err := s.ws.PaidUntil(ctx, ws)
		if err != nil {
			return View{}, err
		}
		if paid != nil && paid.After(s.now()) {
			left := paid.Sub(s.now()).Hours() / (30 * 24)
			cost := int64(math.Ceil(float64(int64(slots-w.Slots)*s.cfg.SlotUZS) * min(left, 1)))
			credits := ceilDiv(cost, max(s.cfg.CreditUZS, 1))
			if w.CreditsBalance < credits {
				return View{}, &Error{Msg: fmt.Sprintf("adding %d slot(s) costs %d credits for the rest of this month; buy credits first", slots-w.Slots, credits), Payment: true}
			}
			if _, err := s.store.Add(ctx, postgres.LedgerEntry{WorkspaceID: ws, Amount: -credits, Reason: postgres.CreditRun,
				Note: fmt.Sprintf("%d extra slot(s) for the rest of the month", slots-w.Slots), CreatedBy: who(by)}); err != nil &&
				!errors.Is(err, postgres.ErrAlreadyCharged) {
				return View{}, err
			}
		}
	}
	if _, err := s.ws.SetPlan(ctx, ws, postgres.PlanUpdate{Slots: &slots}); err != nil {
		return View{}, err
	}
	s.changed(ws)
	s.event(domain.WithWorkspace(ctx, ws), fmt.Sprintf("slots set to %d", slots))
	return s.View(ctx, ws)
}

func (s *Service) inTrial(w domain.Workspace) bool {
	return w.TrialEndsAt != nil && w.TrialEndsAt.After(s.now())
}

// Grant adds (or takes back) credits by hand (the Admin).
func (s *Service) Grant(ctx context.Context, ws, amount int64, note string, by int64) (int64, error) {
	if amount == 0 {
		return 0, &Error{Msg: "the amount cannot be zero"}
	}
	bal, err := s.store.Add(ctx, postgres.LedgerEntry{WorkspaceID: ws, Amount: amount, Reason: postgres.CreditGrant, Note: note, CreatedBy: who(by)})
	if err != nil {
		return 0, err
	}
	s.changed(ws)
	s.event(domain.WithWorkspace(ctx, ws), fmt.Sprintf("%+d credits granted by the platform", amount))
	return bal, nil
}

// Within implements orchestrator.Credits: a run on credits may go on while
// what it spent stays under the run cap and the balance.
func (s *Service) Within(ctx context.Context, ws, runID int64) (bool, string) {
	usd, err := s.store.RunCostUSD(ctx, runID)
	if err != nil {
		return true, ""
	}
	spent := int64(math.Ceil(usd * 100))
	if s.cfg.RunCap > 0 && spent >= s.cfg.RunCap {
		return false, fmt.Sprintf("stopped at the cap of %d credits a run", s.cfg.RunCap)
	}
	bal, err := s.store.Balance(ctx, ws)
	if err == nil && spent >= bal {
		return false, "the workspace ran out of credits"
	}
	return true, ""
}

// Settle implements orchestrator.Credits: it charges a finished run's API
// cost to its workspace, once.
func (s *Service) Settle(ctx context.Context, ws, runID int64, key string) error {
	usd, err := s.store.RunCostUSD(ctx, runID)
	if err != nil {
		return err
	}
	credits := int64(math.Ceil(usd * 100))
	if credits <= 0 {
		return nil
	}
	_, err = s.store.Add(ctx, postgres.LedgerEntry{WorkspaceID: ws, Amount: -credits, Reason: postgres.CreditRun, RunID: &runID, TicketKey: key,
		Note: fmt.Sprintf("$%.2f of API cost", usd)})
	if errors.Is(err, postgres.ErrAlreadyCharged) {
		return nil
	}
	if err == nil {
		s.changed(ws)
	}
	return err
}

func (s *Service) event(ctx context.Context, msg string) {
	if err := s.events.AppendEvent(ctx, domain.Event{Type: domain.EventCredits, Message: msg}); err != nil {
		s.log.Warn("billing event", "err", err)
	}
}

// Renew charges every paying workspace whose month is due, from its
// credits; one that cannot pay is suspended until it buys credits (and is
// renewed by the next Renew). Trials renew when they end.
func (s *Service) Renew(ctx context.Context) error {
	if !s.cfg.Enabled {
		return nil
	}
	ids, err := s.ws.Active(ctx)
	if err != nil {
		return err
	}
	var errs []error
	for _, id := range ids {
		if err := s.renewOne(ctx, id); err != nil {
			errs = append(errs, fmt.Errorf("workspace %d: %w", id, err))
		}
	}
	return errors.Join(errs...)
}

func (s *Service) renewOne(ctx context.Context, id int64) error {
	w, err := s.ws.ByID(ctx, id)
	if err != nil || w.Plan == "self-hosted" || s.inTrial(w) {
		return err
	}
	paid, err := s.ws.PaidUntil(ctx, id)
	if err != nil {
		return err
	}
	if paid != nil && paid.After(s.now()) {
		return nil
	}
	members, err := s.ws.Members(ctx, id)
	if err != nil {
		return err
	}
	fee := s.MonthlyCredits(w.Slots, len(members))
	if w.CreditsBalance < fee {
		if w.SuspendedAt == nil {
			if _, err := s.ws.SetSuspended(ctx, id, true); err != nil {
				return err
			}
			s.changed(id)
			s.event(domain.WithWorkspace(ctx, id), fmt.Sprintf("suspended: the month's fee is %d credits and the balance is %d; buy credits to continue", fee, w.CreditsBalance))
		}
		return nil
	}
	if _, err := s.store.Add(ctx, postgres.LedgerEntry{WorkspaceID: id, Amount: -fee, Reason: postgres.CreditRun,
		Note: fmt.Sprintf("plan for a month (%d slot(s), %d member(s))", w.Slots, len(members))}); err != nil {
		return err
	}
	from := s.now()
	if paid != nil && paid.After(from.AddDate(0, 0, -3)) {
		from = *paid // a late renewal keeps the cycle
	}
	if err := s.ws.SetPaidUntil(ctx, id, from.AddDate(0, 1, 0)); err != nil {
		return err
	}
	if w.SuspendedAt != nil {
		if _, err := s.ws.SetSuspended(ctx, id, false); err != nil {
			return err
		}
	}
	s.changed(id)
	s.event(domain.WithWorkspace(ctx, id), fmt.Sprintf("plan renewed for a month: %d credits", fee))
	return nil
}

// creditsFor is how many credits amountUZS buys.
func (s *Service) creditsFor(amountUZS int64) int64 {
	if s.cfg.CreditUZS <= 0 {
		return 0
	}
	return amountUZS / s.cfg.CreditUZS
}

// Checkout starts buying credits and returns the provider's payment page.
func (s *Service) Checkout(ctx context.Context, ws int64, by int64, amountUZS int64, provider string) (string, int64, error) {
	if amountUZS < 10000 {
		return "", 0, &Error{Msg: "the smallest payment is 10,000 so'm"}
	}
	credits := s.creditsFor(amountUZS)
	if credits <= 0 {
		return "", 0, &Error{Msg: "credits are not for sale on this server"}
	}
	switch provider {
	case "payme":
		if !s.cfg.Payme.enabled() {
			return "", 0, ErrProviderOff
		}
	case "click":
		if !s.cfg.Click.enabled() {
			return "", 0, ErrProviderOff
		}
	default:
		return "", 0, &Error{Msg: "unknown payment provider"}
	}
	p, err := s.store.CreatePayment(ctx, postgres.Payment{WorkspaceID: ws, Provider: provider, AmountUZS: amountUZS, Credits: credits, CreatedBy: who(by)})
	if err != nil {
		return "", 0, err
	}
	if provider == "payme" {
		return s.cfg.Payme.checkoutURL(p, s.cfg.PublicURL), p.ID, nil
	}
	return s.cfg.Click.checkoutURL(p, s.cfg.PublicURL), p.ID, nil
}

// ErrProviderOff means the payment provider is not set up here.
var ErrProviderOff = errors.New("this payment provider is not set up on this server")

// paid adds a completed payment's credits and lifts a suspension it pays for.
func (s *Service) paid(ctx context.Context, p postgres.Payment) {
	s.changed(p.WorkspaceID)
	s.event(domain.WithWorkspace(ctx, p.WorkspaceID), fmt.Sprintf("%d credits bought through %s", p.Credits, p.Provider))
	if err := s.renewOne(ctx, p.WorkspaceID); err != nil {
		s.log.Warn("renew after payment", "workspace", p.WorkspaceID, "err", err)
	}
}
