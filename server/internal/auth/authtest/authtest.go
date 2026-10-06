// Package authtest provides in-memory auth stores for tests.
package authtest

import (
	"bytes"
	"context"
	"sync"
	"time"

	"agnts/internal/domain"
)

// Users is an in-memory auth.Users.
type Users struct {
	mu    sync.Mutex
	users []domain.User
	steps map[int64]int64
}

// ByUsername implements the store interface.
func (m *Users) ByUsername(_ context.Context, name string) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, u := range m.users {
		if u.Username == name {
			return u, nil
		}
	}
	return domain.User{}, domain.ErrNotFound
}

// ByID implements the store interface.
func (m *Users) ByID(_ context.Context, id int64) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, u := range m.users {
		if u.ID == id {
			return u, nil
		}
	}
	return domain.User{}, domain.ErrNotFound
}

// Count implements the store interface.
func (m *Users) Count(context.Context) (int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	return len(m.users), nil
}

// Create implements the store interface.
func (m *Users) Create(_ context.Context, u domain.User) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	u.ID = int64(len(m.users) + 1)
	m.users = append(m.users, u)
	return u, nil
}

// AdvanceTOTPStep implements the store interface.
func (m *Users) AdvanceTOTPStep(_ context.Context, id, step int64) (bool, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.steps == nil {
		m.steps = map[int64]int64{}
	}
	if step <= m.steps[id] {
		return false, nil
	}
	m.steps[id] = step
	return true, nil
}

// Sessions is an in-memory auth.Sessions.
type Sessions struct {
	mu   sync.Mutex
	list []domain.Session
}

// Create implements the store interface.
func (m *Sessions) Create(_ context.Context, s domain.Session) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.list = append(m.list, s)
	return nil
}

// ByTokenHash implements the store interface.
func (m *Sessions) ByTokenHash(_ context.Context, h []byte) (domain.Session, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, s := range m.list {
		if bytes.Equal(s.TokenHash, h) {
			return s, nil
		}
	}
	return domain.Session{}, domain.ErrNotFound
}

// Delete implements the store interface.
func (m *Sessions) Delete(_ context.Context, h []byte) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for i, s := range m.list {
		if bytes.Equal(s.TokenHash, h) {
			m.list = append(m.list[:i], m.list[i+1:]...)
			return nil
		}
	}
	return nil
}

// DeleteExpired implements the store interface.
func (m *Sessions) DeleteExpired(_ context.Context, now time.Time) (int64, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var keep []domain.Session
	for _, s := range m.list {
		if now.Before(s.ExpiresAt) {
			keep = append(keep, s)
		}
	}
	n := int64(len(m.list) - len(keep))
	m.list = keep
	return n, nil
}
