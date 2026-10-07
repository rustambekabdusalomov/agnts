package vcs

import (
	"context"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"agnts/internal/domain"
)

// slowBranches is a Provider whose Branches blocks until release closes.
type slowBranches struct {
	Provider
	calls   atomic.Int32
	release chan struct{}
}

func (p *slowBranches) Branches(ctx context.Context, _ domain.Repository) ([]Branch, error) {
	n := p.calls.Add(1)
	<-p.release
	return []Branch{{Name: "main", SHA: itoa(int64(n))}}, ctx.Err()
}

// Concurrent misses share one provider read, which outlives the caller
// that started it.
func TestRememberSharesOneRead(t *testing.T) {
	p := &slowBranches{release: make(chan struct{})}
	m := NewMulti(map[string]Provider{"github": p})
	repo := domain.Repository{ID: 1, Provider: "github"}

	first, cancel := context.WithCancel(context.Background())
	var wg sync.WaitGroup
	errs := make([]error, 5)
	for i := range errs {
		ctx := context.Background()
		if i == 0 {
			ctx = first
		}
		wg.Add(1)
		go func() {
			defer wg.Done()
			_, errs[i] = m.Branches(ctx, repo)
		}()
	}
	for p.calls.Load() == 0 {
		time.Sleep(time.Millisecond)
	}
	time.Sleep(20 * time.Millisecond) // the others join the read in flight
	cancel()
	close(p.release)
	wg.Wait()
	for i, err := range errs {
		if err != nil {
			t.Errorf("caller %d: %v", i, err)
		}
	}
	if n := p.calls.Load(); n != 1 {
		t.Fatalf("provider read %d times", n)
	}
	if _, err := m.Branches(context.Background(), repo); err != nil || p.calls.Load() != 1 {
		t.Fatalf("not cached: %d reads, %v", p.calls.Load(), err)
	}
}

// A read that started before Forget is returned but not kept: it may
// predate what the webhook announced.
func TestForgetDropsReadsInFlight(t *testing.T) {
	p := &slowBranches{release: make(chan struct{})}
	m := NewMulti(map[string]Provider{"github": p})
	repo := domain.Repository{ID: 1, Provider: "github"}

	done := make(chan struct{})
	go func() {
		defer close(done)
		_, _ = m.Branches(context.Background(), repo)
	}()
	for p.calls.Load() == 0 {
		time.Sleep(time.Millisecond)
	}
	m.ForgetAll()
	close(p.release)
	<-done
	got, err := m.Branches(context.Background(), repo)
	if err != nil || p.calls.Load() != 2 || got[0].SHA != "2" {
		t.Fatalf("after forget: %+v, %d reads, %v", got, p.calls.Load(), err)
	}
}
