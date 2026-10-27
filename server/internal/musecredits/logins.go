package musecredits

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"log/slog"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Savers keep a Muse account as a connection (claude.Service does).
type Savers interface {
	SetWorkspace(ctx context.Context, ws int64, kind, token string) (postgres.ClaudeConnection, error)
	SetUser(ctx context.Context, userID int64, kind, token string) (postgres.ClaudeConnection, error)
}

// SignIn runs Muse Code's own `muse login` (the runner does it in a
// throwaway container): it returns the page and code to show, and later
// Muse's credential file.
type SignIn func(ctx context.Context) (page, code string, expires time.Time, result <-chan SignInResult, err error)

// SignInResult is how a sign-in ended.
type SignInResult struct {
	File []byte
	Err  error
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

// Logins connects Muse accounts the way `muse login` does, because it is
// `muse login`: it runs in a throwaway container, agnts shows its page and
// code, the person approves on Meta's page, and agnts keeps the
// credential file Muse saved, sealed, as the person's or the workspace's
// Muse connection. Runs then use that login, billed to the person's Meta
// account rather than to agnts credits.
type Logins struct {
	signIn SignIn
	saver  Savers
	log    *slog.Logger

	mu      sync.Mutex
	pending map[string]*Login
}

// NewLogins returns the sign-in service.
func NewLogins(signIn SignIn, saver Savers, log *slog.Logger) *Logins {
	return &Logins{signIn: signIn, saver: saver, log: log, pending: map[string]*Login{}}
}

// Start begins a sign-in for a workspace (ws > 0) or a person (user > 0).
func (l *Logins) Start(ctx context.Context, ws, user int64) (Login, error) {
	if (ws > 0) == (user > 0) {
		return Login{}, errors.New("a Muse sign-in is for a workspace or a person")
	}
	if l.signIn == nil {
		return Login{}, errors.New("signing in with Meta is not available on this server; use a Meta Model API key")
	}
	page, code, expires, result, err := l.signIn(ctx)
	if err != nil {
		return Login{}, err
	}
	var b [12]byte
	_, _ = rand.Read(b[:])
	lg := &Login{ID: hex.EncodeToString(b[:]), UserCode: code, VerificationURI: page, VerificationURIComplete: page,
		ExpiresAt: expires, Status: LoginPending, ws: ws, user: user}
	l.mu.Lock()
	l.prune()
	l.pending[lg.ID] = lg
	l.mu.Unlock()
	go l.wait(lg, result) //nolint:gosec // G118: the sign-in outlives the request that started it
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

func (l *Logins) wait(lg *Login, result <-chan SignInResult) {
	r := <-result
	status, msg, account := LoginConnected, "", ""
	err := r.Err
	if err == nil {
		ctx, cancel := context.WithTimeout(domain.System(context.Background()), time.Minute)
		defer cancel()
		var conn postgres.ClaudeConnection
		if lg.ws > 0 {
			conn, err = l.saver.SetWorkspace(domain.WithWorkspace(ctx, lg.ws), lg.ws, postgres.MuseLogin, string(r.File))
		} else {
			conn, err = l.saver.SetUser(ctx, lg.user, postgres.MuseLogin, string(r.File))
		}
		account = conn.Account
	}
	if err != nil {
		status, msg = LoginFailed, err.Error()
		if time.Now().After(lg.ExpiresAt) {
			status = LoginExpired
		}
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
