package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
)

// A bug is a planted bug in one file of a repository: it is on main while
// the file holds every string of has and none of lacks (the fix's text).
type bug struct {
	repo, file string
	has        []string
	lacks      []string
}

func (b *bug) in(src string) bool {
	for _, s := range b.has {
		if !strings.Contains(src, s) {
			return false
		}
	}
	for _, s := range b.lacks {
		if strings.Contains(src, s) {
			return false
		}
	}
	return true
}

// bugState remembers which bugs are on main. A bug never checked, or whose
// file could not be read, counts as present: a GitHub outage must not
// silence the demo.
type bugState struct {
	owner  string
	client *http.Client
	mu     sync.Mutex
	fixed  map[*bug]bool
}

func newBugState(owner string) *bugState {
	return &bugState{owner: owner, client: http.DefaultClient, fixed: map[*bug]bool{}}
}

func (s *bugState) present(b *bug) bool {
	if b == nil {
		return true
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	return !s.fixed[b]
}

// refresh reads every bug's file from main once.
func (s *bugState) refresh(ctx context.Context, svc *service) {
	files := map[string]string{}
	for _, in := range svc.incidents {
		b := in.bug
		if b == nil {
			continue
		}
		key := b.repo + "/" + b.file
		src, ok := files[key]
		if !ok {
			var err error
			if src, err = s.fetch(ctx, b.repo, b.file); err != nil {
				continue // keep the last answer
			}
			files[key] = src
		}
		s.mu.Lock()
		s.fixed[b] = !b.in(src)
		s.mu.Unlock()
	}
}

func (s *bugState) fetch(ctx context.Context, repo, file string) (string, error) {
	url := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/%s", s.owner, repo, file)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}
	resp, err := s.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusNotFound {
		return "", nil // the file is gone: its bug is too
	}
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%s: %s", url, resp.Status)
	}
	b, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	return string(b), err
}
