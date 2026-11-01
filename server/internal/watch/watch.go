// Package watch is agnts-watch, the agent that runs on a server whose
// projects have no logging system agnts can read. It follows the logs of
// labelled Docker containers and of log files, turns container crashes,
// OOM kills and failed health checks into log entries, keeps only what
// the log watcher's detectors may want (the same prefilter as the
// server), and pushes it to agnts's push endpoint with a source's token.
// It connects outbound only; agnts never reaches the server.
package watch

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
)

// Config is how the agent is set up (environment variables, see
// FromEnv).
type Config struct {
	// URL is agnts's address (https://agnts.example.com).
	URL string
	// Token is a push source's token (agl_…).
	Token string
	// Docker is the Docker API: unix:///var/run/docker.sock, or
	// tcp://socket-proxy:2375 for a read-only socket proxy. Empty: no
	// containers are watched.
	Docker string
	// Label marks the containers to watch: <label>=logs follows logs and
	// events, <label>=crash events only.
	Label string
	// Files are service=glob pairs of log files to follow.
	Files map[string]string
	// Flush is how often a batch is sent at most.
	Flush time.Duration
}

// Agent runs the watchers and the sender.
type Agent struct {
	cfg  Config
	log  *slog.Logger
	http *http.Client
	now  func() time.Time

	mu      sync.Mutex
	queue   []domain.LogEntry
	dropped int
	wake    chan struct{}

	// context: after an error start, a stream's next lines go out
	// unfiltered for a moment (a stack trace written line by line).
	ctxMu sync.Mutex
	open  map[string]time.Time
	// rate caps each stream's lines per second.
	rate map[string]*second
}

type second struct {
	at time.Time
	n  int
}

// Limits of the agent.
const (
	maxQueue      = 20000           // entries held while agnts is unreachable
	maxBatch      = 5000            // entries per push
	streamPerSec  = 2000            // lines per stream per second, then dropped
	contextWindow = 2 * time.Second // lines kept after an error start
)

// New returns an agent.
func New(cfg Config, log *slog.Logger) *Agent {
	if cfg.Label == "" {
		cfg.Label = "agnts.watch"
	}
	if cfg.Flush <= 0 {
		cfg.Flush = 5 * time.Second
	}
	cfg.URL = strings.TrimRight(cfg.URL, "/")
	return &Agent{cfg: cfg, log: log, http: &http.Client{Timeout: 60 * time.Second}, now: time.Now,
		wake: make(chan struct{}, 1), open: map[string]time.Time{}, rate: map[string]*second{}}
}

// Run watches until ctx ends.
func (a *Agent) Run(ctx context.Context) error {
	if a.cfg.URL == "" || !strings.HasPrefix(a.cfg.Token, "agl_") {
		return errors.New("set AGNTS_URL and AGNTS_WATCH_TOKEN (a push source's token, agl_…)")
	}
	var wg sync.WaitGroup
	if a.cfg.Docker != "" {
		d, err := newDocker(a.cfg.Docker)
		if err != nil {
			return err
		}
		if err := d.ping(ctx); err != nil {
			return fmt.Errorf("docker at %s: %w", a.cfg.Docker, err)
		}
		wg.Add(1)
		go func() { defer wg.Done(); a.watchDocker(ctx, d) }()
	}
	for svc, glob := range a.cfg.Files {
		wg.Add(1)
		go func() { defer wg.Done(); a.watchFiles(ctx, svc, glob) }()
	}
	if a.cfg.Docker == "" && len(a.cfg.Files) == 0 {
		return errors.New("nothing to watch: set AGNTS_WATCH_DOCKER and/or AGNTS_WATCH_FILES")
	}
	a.send(ctx)
	wg.Wait()
	return nil
}

// emit takes one line of a stream and queues it when the detectors may
// want it.
func (a *Agent) emit(e domain.LogEntry) {
	if e.Time.IsZero() {
		e.Time = a.now()
	}
	if !a.keep(e) {
		return
	}
	a.mu.Lock()
	if len(a.queue) >= maxQueue {
		a.queue = a.queue[1:]
		a.dropped++
	}
	a.queue = append(a.queue, e)
	full := len(a.queue) >= maxBatch
	a.mu.Unlock()
	if full {
		select {
		case a.wake <- struct{}{}:
		default:
		}
	}
}

// keep is the agent's filter: the server's prefilter, plus the lines just
// after an error start, under a per-stream rate cap.
func (a *Agent) keep(e domain.LogEntry) bool {
	a.ctxMu.Lock()
	defer a.ctxMu.Unlock()
	r := a.rate[e.Stream]
	if r == nil || e.Time.Sub(r.at) >= time.Second {
		r = &second{at: e.Time}
		a.rate[e.Stream] = r
	}
	r.n++
	if r.n > streamPerSec {
		return false
	}
	if until, ok := a.open[e.Stream]; ok && !e.Time.After(until) {
		return true
	}
	delete(a.open, e.Stream)
	ev := domain.ParseLogEntry(e, domain.LogFields{})
	if !domain.PassesLogPrefilter(ev, nil) {
		return false
	}
	if domain.LogErrorStart(strings.TrimSpace(e.Message)) || ev.Level == "error" || ev.Level == "fatal" {
		a.open[e.Stream] = e.Time.Add(contextWindow)
	}
	return true
}

// pushLine is one entry as the push endpoint reads it (NDJSON).
type pushLine struct {
	Time    string `json:"@timestamp"`
	Service string `json:"service"`
	Stream  string `json:"container_id,omitempty"`
	Level   string `json:"level,omitempty"`
	Rev     string `json:"revision,omitempty"`
	Message string `json:"message"`
}

// send pushes the queue every Flush, or when a batch is full, until ctx
// ends; a failed push keeps the entries and backs off.
func (a *Agent) send(ctx context.Context) {
	t := time.NewTicker(a.cfg.Flush)
	defer t.Stop()
	backoff := time.Duration(0)
	for {
		select {
		case <-ctx.Done():
			a.flush(context.WithoutCancel(ctx)) // what is left, once
			return
		case <-t.C:
		case <-a.wake:
		}
		if backoff > 0 {
			select {
			case <-ctx.Done():
				return
			case <-time.After(backoff):
			}
		}
		if err := a.flush(ctx); err != nil {
			a.log.Warn("push to agnts", "err", err)
			backoff = min(max(backoff*2, 5*time.Second), 5*time.Minute)
		} else {
			backoff = 0
		}
	}
}

// flush sends one batch.
func (a *Agent) flush(ctx context.Context) error {
	a.mu.Lock()
	n := min(len(a.queue), maxBatch)
	batch := append([]domain.LogEntry(nil), a.queue[:n]...)
	dropped := a.dropped
	a.mu.Unlock()
	if n == 0 {
		return nil
	}
	var buf bytes.Buffer
	zw := gzip.NewWriter(&buf)
	enc := json.NewEncoder(zw)
	for _, e := range batch {
		_ = enc.Encode(pushLine{Time: e.Time.UTC().Format(time.RFC3339Nano), Service: e.Service, Stream: e.Stream, Level: e.Level, Rev: e.Revision, Message: e.Message})
	}
	if err := zw.Close(); err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, a.cfg.URL+"/webhooks/logs", &buf)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+a.cfg.Token)
	req.Header.Set("Content-Type", "application/x-ndjson")
	req.Header.Set("Content-Encoding", "gzip")
	req.Header.Set("User-Agent", "agnts-watch")
	resp, err := a.http.Do(req)
	if err != nil {
		return err
	}
	_ = resp.Body.Close()
	switch {
	case resp.StatusCode == http.StatusUnauthorized:
		return errors.New("agnts refused the token: make a new one on Log sources and update AGNTS_WATCH_TOKEN")
	case resp.StatusCode == http.StatusRequestEntityTooLarge:
		// Drop the batch rather than retry it for ever.
	case resp.StatusCode/100 != 2:
		return fmt.Errorf("agnts answered %d", resp.StatusCode)
	}
	a.mu.Lock()
	a.queue = a.queue[min(n, len(a.queue)):]
	if a.dropped == dropped {
		a.dropped = 0
	}
	a.mu.Unlock()
	if dropped > 0 {
		a.log.Warn("entries dropped while agnts was unreachable", "count", dropped)
	}
	return nil
}

// FromEnv reads the agent's configuration:
//
//	AGNTS_URL           agnts's address
//	AGNTS_WATCH_TOKEN   a push source's token
//	AGNTS_WATCH_DOCKER  unix:///var/run/docker.sock or tcp://socket-proxy:2375
//	AGNTS_WATCH_LABEL   the container label to watch (agnts.watch)
//	AGNTS_WATCH_FILES   service=glob pairs, comma-separated
func FromEnv(getenv func(string) string) (Config, error) {
	cfg := Config{URL: getenv("AGNTS_URL"), Token: getenv("AGNTS_WATCH_TOKEN"), Docker: getenv("AGNTS_WATCH_DOCKER"),
		Label: getenv("AGNTS_WATCH_LABEL"), Files: map[string]string{}}
	for _, pair := range strings.Split(getenv("AGNTS_WATCH_FILES"), ",") {
		if pair = strings.TrimSpace(pair); pair == "" {
			continue
		}
		svc, glob, ok := strings.Cut(pair, "=")
		if !ok || strings.TrimSpace(svc) == "" || strings.TrimSpace(glob) == "" {
			return cfg, fmt.Errorf("AGNTS_WATCH_FILES: %q is not service=glob", pair)
		}
		cfg.Files[strings.TrimSpace(svc)] = strings.TrimSpace(glob)
	}
	return cfg, nil
}
