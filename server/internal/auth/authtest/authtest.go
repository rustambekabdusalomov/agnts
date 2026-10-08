// Package authtest provides in-memory auth stores for tests.
package authtest

import (
	"bytes"
	"context"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
)

// Users is an in-memory auth.Users.
type Users struct {
	mu     sync.Mutex
	users  []domain.User
	steps  map[int64]int64
	tokens map[string]token
}

type token struct {
	userID  int64
	purpose string
	email   string
	expires time.Time
	used    bool
}

func (m *Users) find(id int64) *domain.User {
	for i := range m.users {
		if m.users[i].ID == id {
			return &m.users[i]
		}
	}
	return nil
}

// ByLogin implements the store interface.
func (m *Users) ByLogin(_ context.Context, login string) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, u := range m.users {
		if u.Username == login || (u.Email != "" && strings.EqualFold(u.Email, login)) {
			return u, nil
		}
	}
	return domain.User{}, domain.ErrNotFound
}

// ByEmail implements the store interface.
func (m *Users) ByEmail(_ context.Context, email string) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, u := range m.users {
		if u.Email != "" && strings.EqualFold(u.Email, email) {
			return u, nil
		}
	}
	return domain.User{}, domain.ErrNotFound
}

// SetPassword implements the store interface.
func (m *Users) SetPassword(_ context.Context, id int64, hash string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if u := m.find(id); u != nil {
		u.PasswordHash = hash
		return nil
	}
	return domain.ErrNotFound
}

// SetTOTP implements the store interface.
func (m *Users) SetTOTP(_ context.Context, id int64, enc []byte, step int64) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	u := m.find(id)
	if u == nil {
		return domain.ErrNotFound
	}
	u.TOTPSecretEnc = enc
	if m.steps == nil {
		m.steps = map[int64]int64{}
	}
	m.steps[id] = step
	return nil
}

// SetProfile implements the store interface.
func (m *Users) SetProfile(_ context.Context, id int64, name, email string) (domain.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	u := m.find(id)
	if u == nil {
		return domain.User{}, domain.ErrNotFound
	}
	if !strings.EqualFold(u.Email, email) {
		u.EmailVerifiedAt = nil
	}
	u.DisplayName, u.Email = name, email
	return *u, nil
}

// MarkEmailVerified implements the store interface.
func (m *Users) MarkEmailVerified(_ context.Context, id int64, email string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	u := m.find(id)
	if u == nil || !strings.EqualFold(u.Email, email) {
		return domain.ErrNotFound
	}
	now := time.Now()
	u.EmailVerifiedAt = &now
	return nil
}

// CreateToken implements the store interface.
func (m *Users) CreateToken(_ context.Context, hash []byte, userID int64, purpose, email string, expires time.Time) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.tokens == nil {
		m.tokens = map[string]token{}
	}
	m.tokens[string(hash)] = token{userID: userID, purpose: purpose, email: email, expires: expires}
	return nil
}

// UseToken implements the store interface.
func (m *Users) UseToken(_ context.Context, hash []byte, purpose string) (int64, string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	t, ok := m.tokens[string(hash)]
	// Expiry is the database's to check (its clock); tests run the service
	// on a fake one.
	if !ok || t.used || t.purpose != purpose {
		return 0, "", domain.ErrNotFound
	}
	t.used = true
	m.tokens[string(hash)] = t
	return t.userID, t.email, nil
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
	for _, x := range m.users {
		if x.Username == u.Username {
			return domain.User{}, domain.ErrConflict
		}
	}
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

// DeleteForUser implements the store interface.
func (m *Sessions) DeleteForUser(_ context.Context, userID int64, keep []byte) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	var out []domain.Session
	for _, s := range m.list {
		if s.UserID != userID || (keep != nil && bytes.Equal(s.TokenHash, keep)) {
			out = append(out, s)
		}
	}
	m.list = out
	return nil
}
