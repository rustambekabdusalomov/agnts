package httpapi

import (
	"bufio"
	"context"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type memEvents struct {
	mu  sync.Mutex
	evs []domain.Event
}

func (m *memEvents) add(msg string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.evs = append(m.evs, domain.Event{ID: int64(len(m.evs) + 1), TicketKey: "PAY-1", Type: "claude_tool", Message: msg})
}

func (m *memEvents) Events(_ context.Context, f orchestrator.EventFilter) ([]domain.Event, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var out []domain.Event
	for _, e := range m.evs {
		if e.ID > f.AfterID {
			out = append(out, e)
		}
	}
	return out, nil
}

func (m *memEvents) MaxEventID(context.Context) (int64, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	return int64(len(m.evs)), nil
}

type streamTickets struct {
	fakeTickets
	src *memEvents
}

func (s *streamTickets) Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error) {
	return s.src.Events(ctx, f)
}

func TestStreamReplaysAndGoesLive(t *testing.T) {
	src := &memEvents{}
	src.add("one")
	src.add("two")
	src.add("three")
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	b := NewBroker(src, log)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go b.Run(ctx)
	time.Sleep(50 * time.Millisecond)

	s := &Server{opt: Options{Broker: b, Tickets: &streamTickets{src: src}, Log: log}}
	srv := httptest.NewServer(http.HandlerFunc(s.StreamEvents))
	defer srv.Close()

	req, _ := http.NewRequestWithContext(ctx, "GET", srv.URL, nil)
	req.Header.Set("Last-Event-ID", "1") // the client saw "one"
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = resp.Body.Close() }()
	if ct := resp.Header.Get("Content-Type"); ct != "text/event-stream" {
		t.Fatalf("content type %q", ct)
	}

	lines := make(chan string, 100)
	go func() {
		sc := bufio.NewScanner(resp.Body)
		for sc.Scan() {
			if l := sc.Text(); strings.HasPrefix(l, "data: ") {
				lines <- l
			}
		}
	}()
	next := func() string {
		select {
		case l := <-lines:
			return l
		case <-time.After(3 * time.Second):
			t.Fatal("timed out waiting for an event")
			return ""
		}
	}
	if l := next(); !strings.Contains(l, `"message":"two"`) {
		t.Fatalf("replay: %s", l)
	}
	if l := next(); !strings.Contains(l, `"message":"three"`) {
		t.Fatalf("replay: %s", l)
	}
	src.add("four")
	b.Notify()
	if l := next(); !strings.Contains(l, `"message":"four"`) || !strings.Contains(l, `"id":4`) {
		t.Fatalf("live: %s", l)
	}
	select {
	case l := <-lines:
		t.Fatalf("duplicate or unexpected event: %s", l)
	case <-time.After(200 * time.Millisecond):
	}
}
