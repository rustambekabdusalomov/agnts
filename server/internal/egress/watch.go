package egress

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// FetchStatus reads egress's status page at base (its proxy address, e.g.
// http://egress:3128).
func FetchStatus(ctx context.Context, base string) (UpstreamStatus, error) {
	var st UpstreamStatus
	if base == "" {
		return st, fmt.Errorf("this server runs without the egress proxy (AGNTS_RUN_PROXY is not set)")
	}
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(base, "/")+StatusPath, nil)
	if err != nil {
		return st, err
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return st, fmt.Errorf("egress did not answer: %w", err)
	}
	defer func() { _ = res.Body.Close() }()
	if res.StatusCode != http.StatusOK {
		return st, fmt.Errorf("egress answered %s (an egress from before the status page?)", res.Status)
	}
	if err := json.NewDecoder(io.LimitReader(res.Body, 1<<20)).Decode(&st); err != nil {
		return st, fmt.Errorf("egress status: %w", err)
	}
	return st, nil
}

// Alert is a change of the upstream's state worth telling the platform's
// Admin: Down when it stopped working, else back up. Status is the last
// one read (empty when egress itself did not answer, Err says why).
type Alert struct {
	Down   bool
	Since  time.Time
	Status UpstreamStatus
	Err    error
}

// Watch polls egress every interval and calls alert when the upstream goes
// down (failing failAfter checks in a row, or egress silent three times as
// long, which a restart is not) and when it works again after an alert.
// Without an upstream it says nothing.
func Watch(ctx context.Context, base string, every time.Duration, failAfter int, alert func(context.Context, Alert)) {
	w := watcher{failAfter: failAfter, alert: alert}
	t := time.NewTicker(every)
	defer t.Stop()
	for {
		st, err := FetchStatus(ctx, base)
		w.observe(ctx, st, err, time.Now())
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

// watcher decides when a change is an alert.
type watcher struct {
	failAfter int
	alert     func(context.Context, Alert)

	bad       int // checks in a row that failed
	silent    int // reads in a row egress did not answer
	lastCheck time.Time
	since     time.Time // when the run of failures started
	alerted   bool      // a down alert went out and no recovery since
}

func (w *watcher) observe(ctx context.Context, st UpstreamStatus, err error, now time.Time) {
	if err != nil {
		if w.silent == 0 && w.bad == 0 {
			w.since = now
		}
		w.silent++
		if w.silent >= 3*w.failAfter && !w.alerted {
			w.alerted = true
			w.alert(ctx, Alert{Down: true, Since: w.since, Err: err})
		}
		return
	}
	w.silent = 0
	switch {
	case !st.Configured:
		w.bad, w.alerted = 0, false // going direct: nothing to watch
		return
	case st.CheckedAt == nil || !st.CheckedAt.After(w.lastCheck):
		return // no new check since the last read
	default:
		w.lastCheck = *st.CheckedAt
		if st.OK {
			if w.alerted {
				w.alert(ctx, Alert{Down: false, Since: w.since, Status: st})
			}
			w.bad, w.alerted = 0, false
			return
		}
		w.fail(now)
		if st.DownSince != nil {
			w.since = *st.DownSince
		}
	}
	if w.bad >= w.failAfter && !w.alerted {
		w.alerted = true
		w.alert(ctx, Alert{Down: true, Since: w.since, Status: st})
	}
}

func (w *watcher) fail(now time.Time) {
	if w.bad == 0 {
		w.since = now
	}
	w.bad++
}
