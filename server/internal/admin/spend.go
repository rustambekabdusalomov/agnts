package admin

import (
	"context"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// TicketSpendView is the period total and the tickets that spent most.
type TicketSpendView struct {
	Days    int
	Total   domain.TokenUsage
	Tickets []postgres.TicketSpend
}

// TicketSpend returns the limit tickets that used most of the plan in the
// last days calendar days (today included, as on the Analytics page).
func (d *Dashboard) TicketSpend(ctx context.Context, days, limit int) (TicketSpendView, error) {
	if days != 7 && days != 30 && days != 90 {
		days = 30
	}
	limit = min(max(limit, 1), 50)
	now := time.Now().In(d.tz)
	start := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, d.tz).AddDate(0, 0, 1-days)
	total, ts, err := d.store.TopTicketSpend(ctx, start, limit)
	if err != nil {
		return TicketSpendView{}, err
	}
	return TicketSpendView{Days: days, Total: total, Tickets: ts}, nil
}
