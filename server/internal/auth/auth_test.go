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

func TestCreateUserSingleUserAndChecks(t *testing.T) {
	ctx := context.Background()
	f := setup(t)
	e, _ := f.svc.BeginEnrollment("second")
	if _, err := f.svc.CreateUser(ctx, e, "another long password", f.code(t, f.now)); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("second user: got %v, want ErrConflict", err)
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
