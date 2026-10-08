// Package auth implements sign-in with password plus TOTP and session tokens.
package auth

import (
	"context"
	"crypto/subtle"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// Users is the user store the service needs.
type Users interface {
	ByUsername(ctx context.Context, username string) (domain.User, error)
	// ByLogin finds a user by username or email.
	ByLogin(ctx context.Context, login string) (domain.User, error)
	ByEmail(ctx context.Context, email string) (domain.User, error)
	ByID(ctx context.Context, id int64) (domain.User, error)
	Count(ctx context.Context) (int, error)
	Create(ctx context.Context, u domain.User) (domain.User, error)
	// AdvanceTOTPStep atomically records step as used if it is later than the
	// last used step, and reports whether it did.
	AdvanceTOTPStep(ctx context.Context, userID, step int64) (bool, error)
	SetPassword(ctx context.Context, id int64, hash string) error
	SetTOTP(ctx context.Context, id int64, enc []byte, step int64) error
	SetProfile(ctx context.Context, id int64, displayName, email string) (domain.User, error)
	MarkEmailVerified(ctx context.Context, id int64, email string) error
	CreateToken(ctx context.Context, hash []byte, userID int64, purpose, email string, expires time.Time) error
	UseToken(ctx context.Context, hash []byte, purpose string) (int64, string, error)
}

// Sessions is the session store the service needs.
type Sessions interface {
	Create(ctx context.Context, s domain.Session) error
	ByTokenHash(ctx context.Context, hash []byte) (domain.Session, error)
	Delete(ctx context.Context, hash []byte) error
	DeleteExpired(ctx context.Context, now time.Time) (int64, error)
	// DeleteForUser ends every session of a user but keep (a hash, or nil).
	DeleteForUser(ctx context.Context, userID int64, keep []byte) error
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

// Login checks the password (and the TOTP code, for users who turned
// two-factor sign-in on) and starts a session. Every failure returns
// domain.ErrUnauthorized without saying which part failed.
func (s *Service) Login(ctx context.Context, in LoginInput) (string, domain.Session, domain.User, error) {
	var none domain.Session
	if in.Client != domain.ClientWeb && in.Client != domain.ClientMobile {
		return "", none, domain.User{}, fmt.Errorf("auth: unknown client %q", in.Client)
	}

	u, err := s.users.ByLogin(ctx, in.Username)
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
	if u.HasTOTP() {
		if in.Code == "" {
			return "", none, domain.User{}, ErrCodeRequired
		}
		if err := s.checkCode(ctx, u, in.Code); err != nil {
			return "", none, domain.User{}, err
		}
	}
	token, sess, err := s.startSession(ctx, u, in.Client, in.UserAgent, in.IP)
	return token, sess, u, err
}

// ErrCodeRequired means the password was right but the account needs its
// two-factor code too.
var ErrCodeRequired = errors.New("auth: two-factor code required")

// checkCode verifies a TOTP code once (a code is never accepted twice).
func (s *Service) checkCode(ctx context.Context, u domain.User, code string) error {
	seed, err := s.box.Open(u.TOTPSecretEnc, totpAAD(u.Username))
	if err != nil {
		return fmt.Errorf("auth: decrypt totp secret: %w", err)
	}
	step, ok := matchTOTP(string(seed), code, s.now())
	if !ok {
		return domain.ErrUnauthorized
	}
	fresh, err := s.users.AdvanceTOTPStep(ctx, u.ID, step)
	if err != nil {
		return err
	}
	if !fresh {
		return domain.ErrUnauthorized // code already used
	}
	return nil
}

// startSession creates a session for u and returns its token.
func (s *Service) startSession(ctx context.Context, u domain.User, client domain.Client, ua, ip string) (string, domain.Session, error) {
	token, err := secret.NewToken()
	if err != nil {
		return "", domain.Session{}, err
	}
	now := s.now()
	sess := domain.Session{
		TokenHash: secret.HashToken(token),
		UserID:    u.ID,
		Client:    client,
		UserAgent: truncate(ua, 512),
		IP:        ip,
		CreatedAt: now,
		ExpiresAt: now.Add(s.ttl),
	}
	if err := s.sessions.Create(ctx, sess); err != nil {
		return "", domain.Session{}, err
	}
	return token, sess, nil
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
// app has the enrollment secret (the CLI's `agnts user create`). The first
// user of an install becomes Admin.
func (s *Service) CreateUser(ctx context.Context, e Enrollment, password, code string) (domain.User, error) {
	if len(password) < MinPasswordLength {
		return domain.User{}, fmt.Errorf("password must be at least %d characters", MinPasswordLength)
	}
	if !usernameRe.MatchString(e.Username) {
		return domain.User{}, errors.New("a username has 2 to 32 letters, digits, dots, dashes or underscores")
	}
	n, err := s.users.Count(ctx)
	if err != nil {
		return domain.User{}, err
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
	u, err := s.users.Create(ctx, domain.User{Username: e.Username, PasswordHash: hash, TOTPSecretEnc: enc, IsAdmin: n == 0})
	if err != nil {
		return domain.User{}, err
	}
	if _, err := s.users.AdvanceTOTPStep(ctx, u.ID, step); err != nil {
		return domain.User{}, err
	}
	return u, nil
}

var (
	usernameRe = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9._-]{1,31}$`)
	emailRe    = regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)
)

// ValidEmail reports whether s looks like an email address.
func ValidEmail(s string) bool { return len(s) <= 254 && emailRe.MatchString(s) }

// RegisterInput is a new account from the sign-up page.
type RegisterInput struct {
	Email       string
	Username    string // "" derives one from the email
	DisplayName string
	Password    string
	Client      domain.Client
	UserAgent   string
	IP          string
}

// Register creates an account without two-factor sign-in (it can be turned
// on later) and signs it in. The first account of an install becomes Admin.
// The email is unverified until its link is opened.
func (s *Service) Register(ctx context.Context, in RegisterInput) (string, domain.Session, domain.User, error) {
	var none domain.Session
	in.Email = strings.TrimSpace(in.Email)
	if !ValidEmail(in.Email) {
		return "", none, domain.User{}, Invalid("enter a valid email address")
	}
	if len(in.Password) < MinPasswordLength {
		return "", none, domain.User{}, Invalid(fmt.Sprintf("the password must be at least %d characters", MinPasswordLength))
	}
	if in.Client != domain.ClientWeb && in.Client != domain.ClientMobile {
		return "", none, domain.User{}, Invalid("unknown client")
	}
	if _, err := s.users.ByEmail(ctx, in.Email); err == nil {
		return "", none, domain.User{}, fmt.Errorf("%w: an account with this email exists; sign in instead", domain.ErrConflict)
	}
	name := strings.TrimSpace(in.Username)
	if name != "" && !usernameRe.MatchString(name) {
		return "", none, domain.User{}, Invalid("a username has 2 to 32 letters, digits, dots, dashes or underscores")
	}
	if name == "" {
		var err error
		if name, err = s.freeUsername(ctx, in.Email); err != nil {
			return "", none, domain.User{}, err
		}
	}
	n, err := s.users.Count(ctx)
	if err != nil {
		return "", none, domain.User{}, err
	}
	hash, err := secret.HashPassword(in.Password)
	if err != nil {
		return "", none, domain.User{}, err
	}
	u, err := s.users.Create(ctx, domain.User{Username: name, Email: in.Email, DisplayName: strings.TrimSpace(in.DisplayName),
		PasswordHash: hash, IsAdmin: n == 0})
	if errors.Is(err, domain.ErrConflict) {
		return "", none, domain.User{}, fmt.Errorf("%w: the username %q is taken", domain.ErrConflict, name)
	}
	if err != nil {
		return "", none, domain.User{}, err
	}
	token, sess, err := s.startSession(ctx, u, in.Client, in.UserAgent, in.IP)
	return token, sess, u, err
}

// freeUsername derives a username from an email that nobody has yet.
func (s *Service) freeUsername(ctx context.Context, email string) (string, error) {
	local, _, _ := strings.Cut(strings.ToLower(email), "@")
	base := strings.Map(func(r rune) rune {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '.', r == '-', r == '_':
			return r
		}
		return -1
	}, local)
	base = strings.TrimLeft(base, "._-")
	if len(base) > 24 {
		base = base[:24]
	}
	if len(base) < 2 {
		base = "user"
	}
	for i := 1; i < 1000; i++ {
		name := base
		if i > 1 {
			name = fmt.Sprintf("%s%d", base, i)
		}
		if _, err := s.users.ByUsername(ctx, name); errors.Is(err, domain.ErrNotFound) {
			return name, nil
		} else if err != nil {
			return "", err
		}
	}
	return "", fmt.Errorf("%w: no free username for %s", domain.ErrConflict, email)
}

// InvalidError is input the user can fix.
type InvalidError struct{ Msg string }

func (e *InvalidError) Error() string { return e.Msg }

// Invalid returns an *InvalidError.
func Invalid(msg string) error { return &InvalidError{Msg: msg} }

// Link purposes.
const (
	PurposeVerify = "verify"
	PurposeReset  = "reset"
)

// linkTTL is how long an emailed link works.
var linkTTL = map[string]time.Duration{PurposeVerify: 7 * 24 * time.Hour, PurposeReset: time.Hour}

// NewLink creates a one-time link token for u (verify the email it is sent
// to, or reset the password) and returns it.
func (s *Service) NewLink(ctx context.Context, u domain.User, purpose string) (string, error) {
	tok, err := secret.NewToken()
	if err != nil {
		return "", err
	}
	if err := s.users.CreateToken(ctx, secret.HashToken(tok), u.ID, purpose, u.Email, s.now().Add(linkTTL[purpose])); err != nil {
		return "", err
	}
	return tok, nil
}

// VerifyEmail marks the address a verification link was sent to as
// verified.
func (s *Service) VerifyEmail(ctx context.Context, token string) (int64, error) {
	id, email, err := s.users.UseToken(ctx, secret.HashToken(token), PurposeVerify)
	if errors.Is(err, domain.ErrNotFound) {
		return 0, Invalid("this link is invalid or expired; send a new one from your profile")
	}
	if err != nil {
		return 0, err
	}
	if err := s.users.MarkEmailVerified(ctx, id, email); errors.Is(err, domain.ErrNotFound) {
		return 0, Invalid("this link was for an address you no longer use")
	} else if err != nil {
		return 0, err
	}
	return id, nil
}

// MarkVerified records u's email as verified without a link (they
// followed an invite sent to it).
func (s *Service) MarkVerified(ctx context.Context, u domain.User) error {
	return s.users.MarkEmailVerified(ctx, u.ID, u.Email)
}

// ResetPassword sets a new password with a reset link and ends every
// session of the account.
func (s *Service) ResetPassword(ctx context.Context, token, password string) error {
	if len(password) < MinPasswordLength {
		return Invalid(fmt.Sprintf("the password must be at least %d characters", MinPasswordLength))
	}
	id, _, err := s.users.UseToken(ctx, secret.HashToken(token), PurposeReset)
	if errors.Is(err, domain.ErrNotFound) {
		return Invalid("this link is invalid or expired; ask for a new one")
	}
	if err != nil {
		return err
	}
	hash, err := secret.HashPassword(password)
	if err != nil {
		return err
	}
	if err := s.users.SetPassword(ctx, id, hash); err != nil {
		return err
	}
	return s.sessions.DeleteForUser(ctx, id, nil)
}

// ChangePassword replaces the password after checking the current one, and
// ends the user's other sessions.
func (s *Service) ChangePassword(ctx context.Context, u domain.User, current, password, keepToken string) error {
	ok, err := secret.VerifyPassword(u.PasswordHash, current)
	if err != nil {
		return err
	}
	if !ok {
		return Invalid("the current password is wrong")
	}
	if len(password) < MinPasswordLength {
		return Invalid(fmt.Sprintf("the new password must be at least %d characters", MinPasswordLength))
	}
	hash, err := secret.HashPassword(password)
	if err != nil {
		return err
	}
	if err := s.users.SetPassword(ctx, u.ID, hash); err != nil {
		return err
	}
	return s.sessions.DeleteForUser(ctx, u.ID, secret.HashToken(keepToken))
}

// ConfirmTOTP turns two-factor sign-in on once code proves the
// authenticator app has the secret from BeginEnrollment.
func (s *Service) ConfirmTOTP(ctx context.Context, u domain.User, seed, code string) error {
	step, ok := matchTOTP(seed, code, s.now())
	if !ok {
		return Invalid("the code does not match; check the authenticator app and your clock")
	}
	enc, err := s.box.Seal([]byte(seed), totpAAD(u.Username))
	if err != nil {
		return err
	}
	return s.users.SetTOTP(ctx, u.ID, enc, step)
}

// DisableTOTP turns two-factor sign-in off after checking the password and
// a current code.
func (s *Service) DisableTOTP(ctx context.Context, u domain.User, password, code string) error {
	ok, err := secret.VerifyPassword(u.PasswordHash, password)
	if err != nil {
		return err
	}
	if !ok {
		return Invalid("the password is wrong")
	}
	if u.HasTOTP() {
		if err := s.checkCode(ctx, u, code); err != nil {
			return Invalid("the code is wrong or already used")
		}
	}
	return s.users.SetTOTP(ctx, u.ID, nil, 0)
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
