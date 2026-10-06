package usage

import (
	"context"
	"io"
	"log/slog"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

type memStore struct{ snaps []postgres.UsageSnapshot }

func (m *memStore) Insert(_ context.Context, s postgres.UsageSnapshot) error {
	s.CreatedAt = time.Now()
	m.snaps = append(m.snaps, s)
	return nil
}

func (m *memStore) Latest(context.Context) (postgres.UsageSnapshot, bool, error) {
	if len(m.snaps) == 0 {
		return postgres.UsageSnapshot{}, false, nil
	}
	return m.snaps[len(m.snaps)-1], true, nil
}

type memEvents struct{ n int }

func (e *memEvents) AppendEvent(context.Context, domain.Event) error { e.n++; return nil }

func TestParseShapes(t *testing.T) {
	reset := time.Now().Add(2 * time.Hour).Unix()
	r := Parse(map[string]any{"type": "rate_limit_event", "rate_limit_info": map[string]any{
		"status": "allowed_warning", "rateLimitType": "five_hour", "utilization": 0.83, "resetsAt": float64(reset)}})
	if r.Status != "allowed_warning" || r.FiveHour == nil || *r.FiveHour != 0.83 || r.FiveHourResets == nil || r.FiveHourResets.Unix() != reset {
		t.Fatalf("flat: %+v", r)
	}
	r = Parse(map[string]any{"rate_limit_info": map[string]any{"status": "allowed",
		"unifiedWindows": map[string]any{"five_hour": map[string]any{"utilization": 42.0}, "seven_day": map[string]any{"utilization": 0.1, "resets_at": "2026-10-10T00:00:00Z"}}}})
	if r.FiveHour == nil || *r.FiveHour != 0.42 || r.SevenDay == nil || *r.SevenDay != 0.1 || r.SevenDayResets == nil {
		t.Fatalf("nested: %+v", r)
	}
	if r := Parse(map[string]any{"something": "else"}); !r.empty() {
		t.Fatalf("unknown shape should be empty: %+v", r)
	}
	ms := Parse(map[string]any{"rateLimitType": "five_hour", "resetsAt": float64(1791200000000)})
	if ms.FiveHourResets == nil || ms.FiveHourResets.Year() != 2026 {
		t.Fatalf("milliseconds: %+v", ms)
	}
}

func TestPauseAndRoll(t *testing.T) {
	st := &memStore{}
	tr := New(st, &memEvents{}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	ctx := context.Background()
	s := domain.DefaultSettings()
	s.PauseAbove = 80

	if paused, _ := tr.Paused(ctx, s); paused {
		t.Fatal("no data must not pause")
	}
	reset := time.Now().Add(time.Hour)
	tr.Record(ctx, map[string]any{"rateLimitType": "five_hour", "utilization": 0.85, "resetsAt": float64(reset.Unix()), "status": "allowed_warning"})
	if paused, until := tr.Paused(ctx, s); !paused || until.Unix() != reset.Unix() {
		t.Fatalf("85%% above 80%% threshold: %v %v", paused, until)
	}
	s.PauseAbove = 90
	if paused, _ := tr.Paused(ctx, s); paused {
		t.Fatal("85% under 90% threshold")
	}

	// A later line without utilization keeps the previous reading.
	tr.Record(ctx, map[string]any{"rate_limit_info": map[string]any{"status": "allowed"}})
	v, _ := tr.Current(ctx, s)
	if v.FiveHour == nil || *v.FiveHour != 0.85 || v.Status != "allowed" {
		t.Fatalf("merge: %+v", v)
	}

	// After the reset time the window reads as zero and nothing is paused.
	tr.now = func() time.Time { return reset.Add(time.Minute) }
	v, _ = tr.Current(ctx, s)
	if v.FiveHour == nil || *v.FiveHour != 0 || v.Paused {
		t.Fatalf("roll: %+v", v)
	}

	// Refused with no reset time: paused for 30 minutes.
	tr.now = time.Now
	tr.RecordLimited(ctx)
	if paused, _ := tr.Paused(ctx, s); !paused {
		t.Fatal("rejected should pause")
	}
}
