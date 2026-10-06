// Package auth implements sign-in with password plus TOTP and session tokens.
package auth

import (
	"context"
	"crypto/subtle"
	"errors"
	"fmt"
	"time"

	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// Users is the user store the service needs.
type Users interface {
	ByUsername(ctx context.Context, username string) (domain.User, error)
	ByID(ctx context.Context, id int64) (domain.User, error)
	Count(ctx context.Context) (int, error)
	Create(ctx context.Context, u domain.User) (domain.User, error)
	// AdvanceTOTPStep atomically records step as used if it is later than the
	// last used step, and reports whether it did.
	AdvanceTOTPStep(ctx context.Context, userID, step int64) (bool, error)
}

// Sessions is the session store the service needs.
type Sessions interface {
	Create(ctx context.Context, s domain.Session) error
	ByTokenHash(ctx context.Context, hash []byte) (domain.Session, error)
	Delete(ctx context.Context, hash []byte) error
	DeleteExpired(ctx context.Context, now time.Time) (int64, error)
}

// Issuer is the name shown in authenticator apps.
const Issuer = "agnts"

const (
	totpPeriod = 30
	totpSkew   = 1 // accept one step before and after, for clock drift
)

// Service is the auth use-case layer.
type Service struct {
	users    Users
	sessions Sessions
	box      *secret.Box
	ttl      time.Duration
	now      func() time.Time

	// dummyHash is verified when the username is unknown so that
	// response time does not reveal whether a user exists.
	dummyHash string
}

// New returns an auth service.
func New(users Users, sessions Sessions, box *secret.Box, ttl time.Duration) (*Service, error) {
	dummy, err := secret.HashPassword("agnts-dummy-password")
	if err != nil {
		return nil, err
	}
	return &Service{users: users, sessions: sessions, box: box, ttl: ttl, now: time.Now, dummyHash: dummy}, nil
}

// LoginInput is what a client sends to sign in.
type LoginInput struct {
	Username  string
	Password  string
	Code      string
	Client    domain.Client
	UserAgent string
	IP        string
}

// Login checks password and TOTP code and starts a session.
// Every failure returns domain.ErrUnauthorized without saying which part failed.
func (s *Service) Login(ctx context.Context, in LoginInput) (string, domain.Session, domain.User, error) {
	var none domain.Session
	if in.Client != domain.ClientWeb && in.Client != domain.ClientMobile {
		return "", none, domain.User{}, fmt.Errorf("auth: unknown client %q", in.Client)
	}

	u, err := s.users.ByUsername(ctx, in.Username)
	if errors.Is(err, domain.ErrNotFound) {
		_, _ = secret.VerifyPassword(s.dummyHash, in.Password)
		return "", none, domain.User{}, domain.ErrUnauthorized
	}
	if err != nil {
		return "", none, domain.User{}, err
	}
	ok, err := secret.VerifyPassword(u.PasswordHash, in.Password)
	if err != nil {
		return "", none, domain.User{}, err
	}
	if !ok {
		return "", none, domain.User{}, domain.ErrUnauthorized
	}

	seed, err := s.box.Open(u.TOTPSecretEnc, totpAAD(u.Username))
	if err != nil {
		return "", none, domain.User{}, fmt.Errorf("auth: decrypt totp secret: %w", err)
	}
	step, ok := matchTOTP(string(seed), in.Code, s.now())
	if !ok {
		return "", none, domain.User{}, domain.ErrUnauthorized
	}
	fresh, err := s.users.AdvanceTOTPStep(ctx, u.ID, step)
	if err != nil {
		return "", none, domain.User{}, err
	}
	if !fresh {
		return "", none, domain.User{}, domain.ErrUnauthorized // code already used
	}

	token, err := secret.NewToken()
	if err != nil {
		return "", none, domain.User{}, err
	}
	now := s.now()
	sess := domain.Session{
		TokenHash: secret.HashToken(token),
		UserID:    u.ID,
		Client:    in.Client,
		UserAgent: truncate(in.UserAgent, 512),
		IP:        in.IP,
		CreatedAt: now,
		ExpiresAt: now.Add(s.ttl),
	}
	if err := s.sessions.Create(ctx, sess); err != nil {
		return "", none, domain.User{}, err
	}
	return token, sess, u, nil
}

// Authenticate resolves a session token to its user.
func (s *Service) Authenticate(ctx context.Context, token string) (domain.User, error) {
	if token == "" {
		return domain.User{}, domain.ErrUnauthorized
	}
	sess, err := s.sessions.ByTokenHash(ctx, secret.HashToken(token))
	if errors.Is(err, domain.ErrNotFound) {
		return domain.User{}, domain.ErrUnauthorized
	}
	if err != nil {
		return domain.User{}, err
	}
	if !s.now().Before(sess.ExpiresAt) {
		return domain.User{}, domain.ErrUnauthorized
	}
	u, err := s.users.ByID(ctx, sess.UserID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.User{}, domain.ErrUnauthorized
	}
	return u, err
}

// Logout ends the session for token. Unknown tokens are not an error.
func (s *Service) Logout(ctx context.Context, token string) error {
	if token == "" {
		return nil
	}
	return s.sessions.Delete(ctx, secret.HashToken(token))
}

// PurgeExpired removes expired sessions.
func (s *Service) PurgeExpired(ctx context.Context) (int64, error) {
	return s.sessions.DeleteExpired(ctx, s.now())
}

// Enrollment is a TOTP secret generated for a new user, not yet saved.
type Enrollment struct {
	Username string
	Secret   string // base32, for manual entry
	URL      string // otpauth:// URL, for a QR code
}

// BeginEnrollment generates a TOTP secret for username.
func (s *Service) BeginEnrollment(username string) (Enrollment, error) {
	key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      Issuer,
		AccountName: username,
		Period:      totpPeriod,
		Digits:      otp.DigitsSix,
		Algorithm:   otp.AlgorithmSHA1, // the only one every authenticator app supports
	})
	if err != nil {
		return Enrollment{}, err
	}
	return Enrollment{Username: username, Secret: key.Secret(), URL: key.URL()}, nil
}

// MinPasswordLength is the shortest password CreateUser accepts.
const MinPasswordLength = 12

// CreateUser saves a user after checking that code proves the authenticator
// app has the enrollment secret. v1 allows a single user.
func (s *Service) CreateUser(ctx context.Context, e Enrollment, password, code string) (domain.User, error) {
	if len(password) < MinPasswordLength {
		return domain.User{}, fmt.Errorf("password must be at least %d characters", MinPasswordLength)
	}
	n, err := s.users.Count(ctx)
	if err != nil {
		return domain.User{}, err
	}
	if n > 0 {
		return domain.User{}, fmt.Errorf("a user already exists: %w", domain.ErrConflict)
	}
	step, ok := matchTOTP(e.Secret, code, s.now())
	if !ok {
		return domain.User{}, errors.New("code does not match; check the authenticator app and the server clock")
	}
	hash, err := secret.HashPassword(password)
	if err != nil {
		return domain.User{}, err
	}
	enc, err := s.box.Seal([]byte(e.Secret), totpAAD(e.Username))
	if err != nil {
		return domain.User{}, err
	}
	u, err := s.users.Create(ctx, domain.User{Username: e.Username, PasswordHash: hash, TOTPSecretEnc: enc})
	if err != nil {
		return domain.User{}, err
	}
	if _, err := s.users.AdvanceTOTPStep(ctx, u.ID, step); err != nil {
		return domain.User{}, err
	}
	return u, nil
}

// matchTOTP returns the time step code is valid for, within the allowed skew.
func matchTOTP(seed, code string, now time.Time) (int64, bool) {
	if len(code) != 6 {
		return 0, false
	}
	opts := totp.ValidateOpts{Period: totpPeriod, Digits: otp.DigitsSix, Algorithm: otp.AlgorithmSHA1}
	for d := -totpSkew; d <= totpSkew; d++ {
		t := now.Add(time.Duration(d*totpPeriod) * time.Second)
		want, err := totp.GenerateCodeCustom(seed, t, opts)
		if err != nil {
			return 0, false
		}
		if subtle.ConstantTimeCompare([]byte(want), []byte(code)) == 1 {
			return t.Unix() / totpPeriod, true
		}
	}
	return 0, false
}

func totpAAD(username string) []byte { return []byte("totp:" + username) }

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n]
}
