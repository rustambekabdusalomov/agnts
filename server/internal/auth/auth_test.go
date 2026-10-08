package auth

import (
	"bytes"
	"context"
	"errors"
	"testing"
	"time"

	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"

	"agnts/internal/auth/authtest"
	"agnts/internal/domain"
	"agnts/internal/secret"
)

type fixture struct {
	svc  *Service
	now  time.Time
	seed string
}

func (f *fixture) code(t *testing.T, at time.Time) string {
	t.Helper()
	c, err := totp.GenerateCodeCustom(f.seed, at, totp.ValidateOpts{Period: 30, Digits: otp.DigitsSix, Algorithm: otp.AlgorithmSHA1})
	if err != nil {
		t.Fatal(err)
	}
	return c
}

func setup(t *testing.T) *fixture {
	t.Helper()
	box, err := secret.NewBox(bytes.Repeat([]byte{1}, 32))
	if err != nil {
		t.Fatal(err)
	}
	svc, err := New(&authtest.Users{}, &authtest.Sessions{}, box, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	f := &fixture{svc: svc, now: time.Date(2026, 10, 4, 12, 0, 0, 0, time.UTC)}
	svc.now = func() time.Time { return f.now }

	e, err := svc.BeginEnrollment("rustam")
	if err != nil {
		t.Fatal(err)
	}
	f.seed = e.Secret
	if _, err := svc.CreateUser(context.Background(), e, "a long enough password", f.code(t, f.now)); err != nil {
		t.Fatal(err)
	}
	f.now = f.now.Add(time.Minute) // move past the enrollment code's step
	return f
}

func TestLoginAndAuthenticate(t *testing.T) {
	ctx := context.Background()
	f := setup(t)

	token, sess, u, err := f.svc.Login(ctx, LoginInput{
		Username: "rustam", Password: "a long enough password", Code: f.code(t, f.now), Client: domain.ClientWeb,
	})
	if err != nil {
		t.Fatal(err)
	}
	if u.Username != "rustam" || !sess.ExpiresAt.Equal(f.now.Add(time.Hour)) {
		t.Fatalf("unexpected user or session: %+v %+v", u, sess)
	}
	if got, err := f.svc.Authenticate(ctx, token); err != nil || got.ID != u.ID {
		t.Fatalf("authenticate: %+v %v", got, err)
	}

	f.now = f.now.Add(2 * time.Hour)
	if _, err := f.svc.Authenticate(ctx, token); !errors.Is(err, domain.ErrUnauthorized) {
		t.Fatalf("expired session accepted: %v", err)
	}
}

func TestLoginRejects(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	good := func() LoginInput {
		return LoginInput{Username: "rustam", Password: "a long enough password", Code: f.code(t, f.now), Client: domain.ClientMobile}
	}

	cases := map[string]func(*LoginInput){
		"unknown user":   func(in *LoginInput) { in.Username = "nobody" },
		"wrong password": func(in *LoginInput) { in.Password = "nope" },
		"wrong code":     func(in *LoginInput) { in.Code = "000000" },
		"stale code":     func(in *LoginInput) { in.Code = f.code(t, f.now.Add(-5*time.Minute)) },
	}
	for name, mutate := range cases {
		in := good()
		mutate(&in)
		if _, _, _, err := f.svc.Login(ctx, in); !errors.Is(err, domain.ErrUnauthorized) {
			t.Errorf("%s: got %v, want ErrUnauthorized", name, err)
		}
	}

	in := good()
	if _, _, _, err := f.svc.Login(ctx, in); err != nil {
		t.Fatalf("first use of code: %v", err)
	}
	if _, _, _, err := f.svc.Login(ctx, in); !errors.Is(err, domain.ErrUnauthorized) {
		t.Fatalf("replayed code accepted: %v", err)
	}
}

func TestLogout(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	token, _, _, err := f.svc.Login(ctx, LoginInput{
		Username: "rustam", Password: "a long enough password", Code: f.code(t, f.now), Client: domain.ClientWeb,
	})
	if err != nil {
		t.Fatal(err)
	}
	if err := f.svc.Logout(ctx, token); err != nil {
		t.Fatal(err)
	}
	if _, err := f.svc.Authenticate(ctx, token); !errors.Is(err, domain.ErrUnauthorized) {
		t.Fatalf("token still valid after logout: %v", err)
	}
}

func TestCreateUserFirstIsAdminAndChecks(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	first, err := f.svc.users.ByUsername(ctx, "rustam")
	if err != nil || !first.IsAdmin {
		t.Fatalf("first user: %+v %v, want an Admin", first, err)
	}
	e, _ := f.svc.BeginEnrollment("second")
	second, err := f.svc.CreateUser(ctx, e, "another long password", totpAt(t, e.Secret, f.now))
	if err != nil {
		t.Fatalf("second user: %v", err)
	}
	if second.IsAdmin {
		t.Fatal("the second user is an Admin")
	}
	e, _ = f.svc.BeginEnrollment("second")
	if _, err := f.svc.CreateUser(ctx, e, "another long password", totpAt(t, e.Secret, f.now)); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("taken username: got %v, want ErrConflict", err)
	}

	box, _ := secret.NewBox(bytes.Repeat([]byte{1}, 32))
	svc, _ := New(&authtest.Users{}, &authtest.Sessions{}, box, time.Hour)
	e, _ = svc.BeginEnrollment("x")
	if _, err := svc.CreateUser(ctx, e, "short", "123456"); err == nil {
		t.Fatal("short password accepted")
	}
	if _, err := svc.CreateUser(ctx, e, "a long enough password", "000000"); err == nil {
		t.Fatal("wrong enrollment code accepted")
	}
}

func totpAt(t *testing.T, seed string, at time.Time) string {
	t.Helper()
	c, err := totp.GenerateCodeCustom(seed, at, totp.ValidateOpts{Period: 30, Digits: otp.DigitsSix, Algorithm: otp.AlgorithmSHA1})
	if err != nil {
		t.Fatal(err)
	}
	return c
}

func TestRegisterSignsInWithoutCode(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	in := RegisterInput{Email: "Ann@Example.com", Password: "a long enough password", Client: domain.ClientWeb}
	tok, _, u, err := f.svc.Register(ctx, in)
	if err != nil {
		t.Fatal(err)
	}
	if u.Username != "ann" || u.IsAdmin || u.HasTOTP() || u.EmailVerifiedAt != nil {
		t.Fatalf("registered %+v", u)
	}
	if got, err := f.svc.Authenticate(ctx, tok); err != nil || got.ID != u.ID {
		t.Fatalf("session: %+v %v", got, err)
	}
	if _, _, _, err := f.svc.Register(ctx, in); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("same email again: %v, want ErrConflict", err)
	}
	// A second Ann gets another username.
	_, _, u2, err := f.svc.Register(ctx, RegisterInput{Email: "ann@other.org", Password: "a long enough password", Client: domain.ClientWeb})
	if err != nil || u2.Username != "ann2" {
		t.Fatalf("second ann: %+v %v", u2, err)
	}
	// Signs in by email, without a code.
	if _, _, _, err := f.svc.Login(ctx, LoginInput{Username: "ann@example.com", Password: "a long enough password", Client: domain.ClientWeb}); err != nil {
		t.Fatalf("login by email: %v", err)
	}
	var inv *InvalidError
	if _, _, _, err := f.svc.Register(ctx, RegisterInput{Email: "nope", Password: "a long enough password", Client: domain.ClientWeb}); !errors.As(err, &inv) {
		t.Fatalf("bad email: %v", err)
	}
	if _, _, _, err := f.svc.Register(ctx, RegisterInput{Email: "b@b.io", Password: "short", Client: domain.ClientWeb}); !errors.As(err, &inv) {
		t.Fatalf("short password: %v", err)
	}
}

func TestLoginNeedsCodeWhenTOTPIsOn(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	_, _, _, err := f.svc.Login(ctx, LoginInput{Username: "rustam", Password: "a long enough password", Client: domain.ClientWeb})
	if !errors.Is(err, ErrCodeRequired) {
		t.Fatalf("no code: %v, want ErrCodeRequired", err)
	}
	if _, _, _, err := f.svc.Login(ctx, LoginInput{Username: "rustam", Password: "wrong one", Client: domain.ClientWeb}); !errors.Is(err, domain.ErrUnauthorized) {
		t.Fatalf("wrong password without a code: %v", err)
	}
}

func TestLinksVerifyAndReset(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	_, _, u, err := f.svc.Register(ctx, RegisterInput{Email: "c@c.io", Password: "a long enough password", Client: domain.ClientWeb})
	if err != nil {
		t.Fatal(err)
	}
	tok, err := f.svc.NewLink(ctx, u, PurposeVerify)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := f.svc.VerifyEmail(ctx, tok); err != nil {
		t.Fatal(err)
	}
	if got, _ := f.svc.users.ByID(ctx, u.ID); got.EmailVerifiedAt == nil {
		t.Fatal("email not verified")
	}
	if _, err := f.svc.VerifyEmail(ctx, tok); err == nil {
		t.Fatal("a link worked twice")
	}

	session, _, _, err := f.svc.Login(ctx, LoginInput{Username: "c@c.io", Password: "a long enough password", Client: domain.ClientWeb})
	if err != nil {
		t.Fatal(err)
	}
	reset, _ := f.svc.NewLink(ctx, u, PurposeReset)
	if err := f.svc.ResetPassword(ctx, reset, "a brand new password"); err != nil {
		t.Fatal(err)
	}
	if _, err := f.svc.Authenticate(ctx, session); !errors.Is(err, domain.ErrUnauthorized) {
		t.Fatal("a session outlived the password reset")
	}
	if _, _, _, err := f.svc.Login(ctx, LoginInput{Username: "c@c.io", Password: "a brand new password", Client: domain.ClientWeb}); err != nil {
		t.Fatalf("new password: %v", err)
	}
	// A verify link cannot reset.
	v, _ := f.svc.NewLink(ctx, u, PurposeVerify)
	if err := f.svc.ResetPassword(ctx, v, "yet another password"); err == nil {
		t.Fatal("a verify link reset the password")
	}
}

func TestTOTPOnAndOff(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	_, _, u, err := f.svc.Register(ctx, RegisterInput{Email: "d@d.io", Password: "a long enough password", Client: domain.ClientWeb})
	if err != nil {
		t.Fatal(err)
	}
	e, _ := f.svc.BeginEnrollment(u.Username)
	if err := f.svc.ConfirmTOTP(ctx, u, e.Secret, "000000"); err == nil {
		t.Fatal("wrong code turned TOTP on")
	}
	if err := f.svc.ConfirmTOTP(ctx, u, e.Secret, totpAt(t, e.Secret, f.now)); err != nil {
		t.Fatal(err)
	}
	u, _ = f.svc.users.ByID(ctx, u.ID)
	if !u.HasTOTP() {
		t.Fatal("TOTP not on")
	}
	f.now = f.now.Add(time.Minute)
	if _, _, _, err := f.svc.Login(ctx, LoginInput{Username: "d@d.io", Password: "a long enough password", Client: domain.ClientWeb}); !errors.Is(err, ErrCodeRequired) {
		t.Fatalf("login without code: %v", err)
	}
	if err := f.svc.DisableTOTP(ctx, u, "a long enough password", totpAt(t, e.Secret, f.now)); err != nil {
		t.Fatal(err)
	}
	u, _ = f.svc.users.ByID(ctx, u.ID)
	if u.HasTOTP() {
		t.Fatal("TOTP still on")
	}
}
