package egress

import (
	"context"
	"errors"
	"testing"
	"time"
)

func TestWatcherAlerts(t *testing.T) {
	var got []Alert
	w := watcher{failAfter: 2, alert: func(_ context.Context, a Alert) { got = append(got, a) }}
	t0 := time.Date(2026, 11, 3, 14, 0, 0, 0, time.UTC)
	check := func(i int, ok bool) UpstreamStatus {
		at := t0.Add(time.Duration(i) * 30 * time.Second)
		st := UpstreamStatus{Configured: true, OK: ok, CheckedAt: &at}
		if !ok {
			st.DownSince = &t0
		}
		return st
	}
	ctx := context.Background()
	w.observe(ctx, check(1, true), nil, t0)
	w.observe(ctx, check(2, false), nil, t0)
	if len(got) != 0 {
		t.Fatalf("one failed check alerted: %+v", got)
	}
	w.observe(ctx, check(2, false), nil, t0) // the same check read again
	if len(got) != 0 {
		t.Fatalf("a check read twice counted twice: %+v", got)
	}
	w.observe(ctx, check(3, false), nil, t0)
	w.observe(ctx, check(4, false), nil, t0)
	if len(got) != 1 || !got[0].Down || !got[0].Since.Equal(t0) {
		t.Fatalf("down: %+v", got)
	}
	w.observe(ctx, check(5, true), nil, t0)
	if len(got) != 2 || got[1].Down {
		t.Fatalf("back up: %+v", got)
	}
	w.observe(ctx, check(6, true), nil, t0)
	if len(got) != 2 {
		t.Fatalf("up again alerted: %+v", got)
	}

	// egress itself silent: a restart (a few reads) is not an outage;
	// three times as long is.
	silent := errors.New("egress did not answer")
	for range 5 {
		w.observe(ctx, UpstreamStatus{}, silent, t0)
	}
	if len(got) != 2 {
		t.Fatalf("a restart alerted: %+v", got)
	}
	w.observe(ctx, UpstreamStatus{}, silent, t0)
	if len(got) != 3 || !got[2].Down || got[2].Err == nil {
		t.Fatalf("egress silent: %+v", got)
	}

	// Going direct is not an outage.
	w2 := watcher{failAfter: 1, alert: func(_ context.Context, a Alert) { got = append(got, a) }}
	w2.observe(ctx, UpstreamStatus{Configured: false}, nil, t0)
	if len(got) != 3 {
		t.Fatalf("no upstream alerted: %+v", got)
	}
}
