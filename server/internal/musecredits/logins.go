package musecredits

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"log/slog"
	"sync"
	"time"

	"github.com/rustambekabdusalomov/agnts-muse/credential"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Savers keep a Muse account as a connection (claude.Service does).
type Savers interface {
	SetWorkspace(ctx context.Context, ws int64, kind, token string) (postgres.ClaudeConnection, error)
	SetUser(ctx context.Context, userID int64, kind, token string) (postgres.ClaudeConnection, error)
}

// Login statuses.
const (
	LoginPending   = "pending"
	LoginConnected = "connected"
	LoginDenied    = "denied"
	LoginExpired   = "expired"
	LoginFailed    = "failed"
)

// Login is a Meta sign-in in progress: the code a person confirms on
// Meta's page, and how it went.
type Login struct {
	ID                      string
	UserCode                string
	VerificationURI         string
	VerificationURIComplete string
	ExpiresAt               time.Time
	Status                  string
	Error                   string
	Account                 string

	ws, user int64
}

// Logins connects Muse accounts by signing in with Meta (OAuth device
// flow), the way `muse login` does: agnts shows the code, the person
// approves it on Meta's page, and agnts keeps the account's token sealed as
// the person's or the workspace's Muse connection. Nobody copies a token.
type Logins struct {
	Flow  credential.DeviceFlow
	saver Savers
	log   *slog.Logger

	mu      sync.Mutex
	pending map[string]*Login
}

// NewLogins returns the sign-in service.
func NewLogins(saver Savers, log *slog.Logger) *Logins {
	return &Logins{saver: saver, log: log, pending: map[string]*Login{}}
}

// Start begins a sign-in for a workspace (ws > 0) or a person (user > 0).
func (l *Logins) Start(ctx context.Context, ws, user int64) (Login, error) {
	if (ws > 0) == (user > 0) {
		return Login{}, errors.New("a Muse sign-in is for a workspace or a person")
	}
	a, err := l.Flow.Start(ctx)
	if err != nil {
		return Login{}, err
	}
	var b [12]byte
	_, _ = rand.Read(b[:])
	lg := &Login{ID: hex.EncodeToString(b[:]), UserCode: a.UserCode, VerificationURI: a.VerificationURI,
		VerificationURIComplete: a.VerificationURIComplete, ExpiresAt: a.ExpiresAt, Status: LoginPending, ws: ws, user: user}
	l.mu.Lock()
	l.prune()
	l.pending[lg.ID] = lg
	l.mu.Unlock()
	go l.wait(lg, a) //nolint:gosec // G118: the sign-in outlives the request that started it
	return *lg, nil
}

// Status returns a sign-in of the same workspace or person.
func (l *Logins) Status(id string, ws, user int64) (Login, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	lg, ok := l.pending[id]
	if !ok || lg.ws != ws || lg.user != user {
		return Login{}, false
	}
	return *lg, true
}

func (l *Logins) wait(lg *Login, a credential.Authorization) {
	ctx, cancel := context.WithDeadline(domain.System(context.Background()), a.ExpiresAt.Add(time.Minute))
	defer cancel()
	tok, err := l.Flow.Wait(ctx, a)
	status, msg, account := LoginConnected, "", ""
	if err == nil {
		var c credential.Credential
		var file []byte
		if c, err = credential.Login(tok, ""); err == nil {
			file, err = c.AuthFile()
		}
		if err == nil {
			var conn postgres.ClaudeConnection
			if lg.ws > 0 {
				conn, err = l.saver.SetWorkspace(domain.WithWorkspace(ctx, lg.ws), lg.ws, postgres.MuseLogin, string(file))
			} else {
				conn, err = l.saver.SetUser(ctx, lg.user, postgres.MuseLogin, string(file))
			}
			account = conn.Account
		}
	}
	switch {
	case errors.Is(err, credential.ErrDenied):
		status, msg = LoginDenied, "the sign-in was declined on Meta's page"
	case errors.Is(err, credential.ErrExpired), errors.Is(err, context.DeadlineExceeded):
		status, msg = LoginExpired, "the code expired before it was approved; start again"
	case err != nil:
		status, msg = LoginFailed, err.Error()
		l.log.Warn("muse sign-in failed", "err", err)
	}
	l.mu.Lock()
	lg.Status, lg.Error, lg.Account = status, msg, account
	l.mu.Unlock()
}

// prune forgets sign-ins that ended over an hour ago (l.mu held).
func (l *Logins) prune() {
	for id, lg := range l.pending {
		if time.Since(lg.ExpiresAt) > time.Hour {
			delete(l.pending, id)
		}
	}
}
