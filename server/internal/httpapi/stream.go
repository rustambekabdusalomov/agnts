package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"sync"
	"time"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
)

// EventSource reads events after a cursor.
type EventSource interface {
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	MaxEventID(ctx context.Context) (int64, error)
}

// Broker fans new event rows out to SSE subscribers.
type Broker struct {
	src  EventSource
	log  *slog.Logger
	poke chan struct{}

	mu   sync.Mutex
	subs map[chan domain.Event]struct{}
	last int64
}

// NewBroker returns a broker; call Run, and Notify on each database notification.
func NewBroker(src EventSource, log *slog.Logger) *Broker {
	return &Broker{src: src, log: log, poke: make(chan struct{}, 1), subs: map[chan domain.Event]struct{}{}}
}

// Notify signals that new events may exist.
func (b *Broker) Notify() {
	select {
	case b.poke <- struct{}{}:
	default:
	}
}

// Run delivers events until ctx ends.
func (b *Broker) Run(ctx context.Context) {
	last, err := b.src.MaxEventID(ctx)
	if err != nil {
		b.log.Warn("broker: start", "err", err)
	}
	b.mu.Lock()
	b.last = last
	b.mu.Unlock()
	for {
		select {
		case <-ctx.Done():
			return
		case <-b.poke:
		}
		for {
			b.mu.Lock()
			after := b.last
			b.mu.Unlock()
			evs, err := b.src.Events(ctx, orchestrator.EventFilter{AfterID: after, Limit: 500})
			if err != nil {
				if ctx.Err() == nil {
					b.log.Warn("broker: read", "err", err)
				}
				break
			}
			b.mu.Lock()
			for _, e := range evs {
				b.last = e.ID
				for ch := range b.subs {
					select {
					case ch <- e:
					default:
						// Too slow: drop it; the client reconnects with Last-Event-ID.
						delete(b.subs, ch)
						close(ch)
					}
				}
			}
			b.mu.Unlock()
			if len(evs) < 500 {
				break
			}
		}
	}
}

func (b *Broker) subscribe() (chan domain.Event, int64, func()) {
	ch := make(chan domain.Event, 256)
	b.mu.Lock()
	b.subs[ch] = struct{}{}
	last := b.last
	b.mu.Unlock()
	return ch, last, func() {
		b.mu.Lock()
		if _, ok := b.subs[ch]; ok {
			delete(b.subs, ch)
			close(ch)
		}
		b.mu.Unlock()
	}
}

// StreamEvents implements gen.ServerInterface: Server-Sent Events.
func (s *Server) StreamEvents(w http.ResponseWriter, r *http.Request) {
	fl, ok := w.(http.Flusher)
	if !ok || s.opt.Broker == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "streaming is not available")
		return
	}
	ch, live, cancel := s.opt.Broker.subscribe()
	defer cancel()

	h := w.Header()
	h.Set("Content-Type", "text/event-stream")
	h.Set("Cache-Control", "no-cache")
	h.Set("X-Accel-Buffering", "no")
	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprint(w, "retry: 3000\n\n")

	sent := int64(0)
	send := func(e domain.Event) bool {
		if e.ID <= sent {
			return true
		}
		b, _ := json.Marshal(toEvent(e))
		if _, err := fmt.Fprintf(w, "id: %d\ndata: %s\n\n", e.ID, b); err != nil {
			return false
		}
		sent = e.ID
		return true
	}

	// Replay what the client missed (capped), then go live.
	if id, err := strconv.ParseInt(r.Header.Get("Last-Event-ID"), 10, 64); err == nil && id > 0 && id < live {
		backlog, err := s.opt.Tickets.Events(r.Context(), orchestrator.EventFilter{AfterID: id, Limit: 1000})
		if err == nil {
			for _, e := range backlog {
				if e.ID > live {
					break
				}
				if !send(e) {
					return
				}
			}
		}
	}
	fl.Flush()

	ping := time.NewTicker(25 * time.Second)
	defer ping.Stop()
	for {
		select {
		case <-r.Context().Done():
			return
		case e, ok := <-ch:
			if !ok || !send(e) {
				return
			}
			fl.Flush()
		case <-ping.C:
			if _, err := fmt.Fprint(w, ": ping\n\n"); err != nil {
				return
			}
			fl.Flush()
		}
	}
}
