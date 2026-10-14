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

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// EventSource reads events after a cursor.
type EventSource interface {
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	MaxEventID(ctx context.Context) (int64, error)
}

// Broker fans new event rows out to SSE subscribers, each only the
// events of the workspace it subscribed in. It also delivers live events
// that are not stored (PublishTo) to one person's subscribers.
type Broker struct {
	src  EventSource
	log  *slog.Logger
	poke chan struct{}

	mu   sync.Mutex
	subs map[chan domain.Event]subscriber
	last int64
}

// subscriber is whose stream a channel feeds.
type subscriber struct{ ws, user int64 }

var _ orchestrator.AssistantEvents = (*Broker)(nil)

// NewBroker returns a broker; call Run, and Notify on each database notification.
func NewBroker(src EventSource, log *slog.Logger) *Broker {
	return &Broker{src: src, log: log, poke: make(chan struct{}, 1), subs: map[chan domain.Event]subscriber{}}
}

// PublishTo sends e, which is not stored and has no id, to user's streams
// in workspace ws only. A stream too slow to take it misses it.
func (b *Broker) PublishTo(ws, user int64, e domain.Event) {
	e.ID = 0
	b.mu.Lock()
	defer b.mu.Unlock()
	for ch, sub := range b.subs {
		if sub.ws != ws || sub.user != user {
			continue
		}
		select {
		case ch <- e:
		default:
		}
	}
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
	ctx = domain.System(ctx)
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
				for ch, sub := range b.subs {
					if e.WorkspaceID != sub.ws {
						continue
					}
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

func (b *Broker) subscribe(ws, user int64) (chan domain.Event, int64, func()) {
	ch := make(chan domain.Event, 256)
	b.mu.Lock()
	b.subs[ch] = subscriber{ws: ws, user: user}
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
	var user int64
	if a, ok := domain.ActorOf(r.Context()); ok {
		user = a.UserID
	}
	ch, live, cancel := s.opt.Broker.subscribe(domain.WorkspaceOf(r.Context()), user)
	defer cancel()

	h := w.Header()
	h.Set("Content-Type", "text/event-stream")
	h.Set("Cache-Control", "no-cache")
	h.Set("X-Accel-Buffering", "no")
	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprint(w, "retry: 3000\n\n")

	sent := int64(0)
	send := func(e domain.Event) bool {
		if e.ID == 0 {
			// A live event that is not stored: no id, so a reconnect does
			// not replay from it.
			b, _ := json.Marshal(toEvent(e))
			_, err := fmt.Fprintf(w, "data: %s\n\n", b)
			return err == nil
		}
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
