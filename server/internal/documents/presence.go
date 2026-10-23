package documents

import (
	"slices"
	"sync"
	"time"

	"agnts/internal/domain"
)

// presenceTTL is how long a viewer stays listed after their page last
// said it is open (pages say so every 10 seconds).
const presenceTTL = 30 * time.Second

// presence is who has each document open now. It lives in this server's
// memory: there is one agnts server.
type presence struct {
	mu   sync.Mutex
	docs map[int64]map[string]seen
}

type seen struct {
	v      domain.Viewer
	since  time.Time // first seen, for a stable order
	seenAt time.Time
}

func newPresence() *presence { return &presence{docs: map[int64]map[string]seen{}} }

// touch records v on document doc at now (or removes them when leaving),
// drops whoever went quiet, and returns the viewers in the order they
// arrived.
func (p *presence) touch(doc int64, v domain.Viewer, leaving bool, now time.Time) []domain.Viewer {
	p.mu.Lock()
	defer p.mu.Unlock()
	m := p.docs[doc]
	if m == nil {
		m = map[string]seen{}
		p.docs[doc] = m
	}
	for k, s := range m {
		if now.Sub(s.seenAt) > presenceTTL {
			delete(m, k)
		}
	}
	if leaving {
		delete(m, v.Key())
	} else {
		s, ok := m[v.Key()]
		if !ok {
			s.since = now
		}
		s.v, s.seenAt = v, now
		m[v.Key()] = s
	}
	all := make([]seen, 0, len(m))
	for _, s := range m {
		all = append(all, s)
	}
	if len(m) == 0 {
		delete(p.docs, doc)
	}
	slices.SortFunc(all, func(a, b seen) int {
		if c := a.since.Compare(b.since); c != 0 {
			return c
		}
		return compareStrings(a.v.Key(), b.v.Key())
	})
	out := make([]domain.Viewer, len(all))
	for i, s := range all {
		out[i] = s.v
	}
	return out
}

func compareStrings(a, b string) int {
	switch {
	case a < b:
		return -1
	case a > b:
		return 1
	}
	return 0
}
