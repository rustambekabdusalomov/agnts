package main

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// The crash BW-1 causes, recorded from the real worker (no recover around
// the handler, so the process dies; built without -trimpath in /src).
//
//go:embed traces/bw-1.txt
var bw1Trace string

var (
	// BW-1: checkTotals divides by a quantity nobody checked (internal/jobs/charge.go:105).
	bugBW1 = &bug{repo: "billing-worker", file: "internal/jobs/charge.go",
		has: []string{"l.TotalCents/l.Quantity"}, lacks: []string{"l.Quantity <= 0"}}
	// BW-2: a decline logs the whole payload, card included (internal/jobs/charge.go:46).
	bugBW2 = &bug{repo: "billing-worker", file: "internal/jobs/charge.go", has: []string{`"payload", string(raw)`}}
	// BW-3: the database URL, password included, is logged at start (cmd/billing-worker/main.go:98).
	bugBW3 = &bug{repo: "billing-worker", file: "cmd/billing-worker/main.go", has: []string{`"connecting to " + cfg.DatabaseURL`}}
	// BW-4: an unknown currency has rate 0 instead of an error (internal/fx/fx.go:25).
	bugBW4 = &bug{repo: "billing-worker", file: "internal/fx/fx.go", has: []string{"errors.Is(err, pgx.ErrNoRows) {\n\t\treturn 0, nil"}}
)

// The database URL from the stack's .env (a throwaway secret).
const billingDatabaseURL = "postgres://billing:Sup3rS3cret-2026@postgres:5432/shop"

var billingItems = []struct {
	sku, name string
	cents     int64
}{
	{"SKU-0007", "Linen tote bag", 2990}, {"SKU-0012", "Ceramic mug", 1450}, {"SKU-0019", "Desk lamp", 4900},
	{"SKU-0023", "USB-C cable", 990}, {"SKU-0031", "Wireless headphones", 8900}, {"SKU-0038", "Dot grid notebook", 1295},
}

// billingLine is internal/logging's line: time, level, component, message,
// then key=value attributes (quoted when they hold spaces, quotes or =).
func billingLine(e *emitter, level, component, msg string, kv ...any) {
	var b strings.Builder
	b.WriteString(time.Now().UTC().Format("2006-01-02T15:04:05.000Z07:00"))
	b.WriteString(" " + level + " " + component + ": " + msg)
	for i := 0; i+1 < len(kv); i += 2 {
		s := fmt.Sprint(kv[i+1])
		if s == "" || strings.ContainsAny(s, " \t\r\n\"=") {
			s = strconv.Quote(s)
		}
		b.WriteString(fmt.Sprintf(" %v=%s", kv[i], s))
	}
	fmt.Fprintln(e.out, b.String())
}

func money(cents int64, currency string) string {
	return fmt.Sprintf("%d.%02d %s", cents/100, cents%100, currency)
}

type billingState struct{ order, job, invoice int }

func billingWorker() *service {
	st := &billingState{order: 1200, job: 3400, invoice: 410}
	s := &service{name: "billing-worker"}
	start := func(e *emitter) {
		if e.has(bugBW3) {
			billingLine(e, "INFO", "billing.main", "connecting to "+billingDatabaseURL)
		} else {
			billingLine(e, "INFO", "billing.main", "connecting to database")
		}
		billingLine(e, "INFO", "billing.main", "started 2 workers")
	}
	s.start = start
	s.normal = func(e *emitter) {
		// Jobs come with orders: roughly one every ten seconds.
		if e.rng.IntN(5) != 0 {
			return
		}
		st.order++
		it := billingItems[e.rng.IntN(len(billingItems))]
		total := it.cents * int64(1+e.rng.IntN(3))
		if e.rng.IntN(4) == 0 {
			st.invoice++
			currency := []string{"EUR", "GBP"}[e.rng.IntN(2)]
			billingLine(e, "INFO", "billing.jobs", fmt.Sprintf("invoice INV-2026-%06d written", st.invoice),
				"order_id", st.order, "total", money(total*92/100, currency))
			return
		}
		billingLine(e, "INFO", "billing.jobs", fmt.Sprintf("charged order %d (%s)", st.order, money(total, "USD")))
	}
	s.incidents = []*incident{
		{id: "bw-1", title: "quantity 0 divides by zero; the worker crashes and takes the job again", bug: bugBW1, run: func(e *emitter) {
			// The job is never counted as an attempt (BW-5), so the crash
			// repeats; the real one never stops, this one stops after a while.
			for i := range 6 {
				if i > 0 {
					e.pauseMs(1800, 2600) // compose restarts the container
					start(e)
					e.pauseMs(30, 120)
				}
				e.lines(e.goroutine(bw1Trace))
			}
			e.pauseMs(1800, 2600)
			start(e)
		}},
		{id: "bw-2", title: "a declined card: the whole payload, card number included, goes to the log", bug: bugBW2, run: func(e *emitter) {
			st.order++
			st.job++
			it := billingItems[e.rng.IntN(len(billingItems))]
			// As the worker reads it back from billing.jobs: jsonb's key order
			// (shorter keys first) and spacing.
			name, _ := json.Marshal(it.name)
			raw := fmt.Sprintf(`{"card": {"cvc": "123", "exp": "12/30", "number": "4000000000000002"}, `+
				`"items": [{"sku": %q, "name": %s, "quantity": 1, "unit_price_cents": %d}], "user_id": %d, `+
				`"currency": "USD", "order_id": %d, "total_cents": %d, "discount_cents": 0, "subtotal_cents": %d}`,
				it.sku, name, it.cents, 1+e.rng.IntN(5000), st.order, it.cents, it.cents)
			for attempt := 1; attempt <= 5; attempt++ {
				if attempt > 1 {
					e.pause(time.Duration(1<<(attempt-1)) * time.Second) // 2^attempts seconds
				}
				billingLine(e, "ERROR", "billing.jobs", fmt.Sprintf("charge declined for order %d", st.order), "payload", raw)
				billingLine(e, "ERROR", "billing.queue", "job failed", "kind", "charge_order", "id", st.job,
					"attempt", attempt, "error", fmt.Sprintf("charge order %d: card declined", st.order))
			}
			billingLine(e, "ERROR", "billing.queue", "job is dead", "kind", "charge_order", "id", st.job)
		}},
		{id: "bw-3", title: "a restart: the database URL, password included, goes to the log", bug: bugBW3, run: func(e *emitter) {
			start(e)
		}},
		{id: "bw-4", title: "an invoice in UZS: no rate, so the total is 0", bug: bugBW4, run: func(e *emitter) {
			st.order++
			st.invoice++
			number := fmt.Sprintf("INV-2026-%06d", st.invoice)
			billingLine(e, "INFO", "billing.jobs", fmt.Sprintf("invoice %s written", number), "order_id", st.order, "total", money(0, "UZS"))
			billingLine(e, "ERROR", "billing.jobs", fmt.Sprintf("invoice %s total is 0", number), "order_id", st.order, "currency", "UZS")
		}},
	}
	return s
}
