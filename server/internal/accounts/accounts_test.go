package accounts

import (
	"bytes"
	"context"
	"errors"
	"io"
	"log/slog"
	"regexp"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/auth"
	"agnts/internal/domain"
	"agnts/internal/mail"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

type outbox struct {
	mu   sync.Mutex
	sent []mail.Message
}

func (o *outbox) Send(_ context.Context, m mail.Message) error {
	o.mu.Lock()
	defer o.mu.Unlock()
	o.sent = append(o.sent, m)
	return nil
}
func (o *outbox) Enabled() bool { return true }

func (o *outbox) last(t *testing.T) mail.Message {
	t.Helper()
	o.mu.Lock()
	defer o.mu.Unlock()
	if len(o.sent) == 0 {
		t.Fatal("no email sent")
	}
	return o.sent[len(o.sent)-1]
}

var linkRe = regexp.MustCompile(`https://agnts\.example\.com/\S+`)

type removed struct{ ws []int64 }

func (r *removed) RemoveWorkspace(_ context.Context, ws int64) error {
	r.ws = append(r.ws, ws)
	return nil
}

func setup(t *testing.T, open bool) (*Service, *outbox, *removed) {
	t.Helper()
	pool := pgtest.Open(t)
	// A fresh install: no users, no workspaces.
	pgtest.Exec(t, pool, `TRUNCATE workspaces, users CASCADE`)
	box, _ := secret.NewBox(bytes.Repeat([]byte{5}, 32))
	a, err := auth.New(postgres.NewUsers(pool), postgres.NewSessions(pool), box, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	ob, rm := &outbox{}, &removed{}
	s := New(Config{PublicURL: "https://agnts.example.com", Open: open, Cloud: true, TrialDays: 14, IncludedMembers: 2, DefaultSlots: 1},
		a, postgres.NewUsers(pool), postgres.NewWorkspaces(pool), postgres.NewAgent(pool), ob, rm, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return s, ob, rm
}

func reg(email string) RegisterInput {
	return RegisterInput{RegisterInput: auth.RegisterInput{Email: email, Password: "a long enough password", Client: domain.ClientWeb}}
}

func TestSignupInviteOnly(t *testing.T) {
	ctx := domain.System(context.Background())
	s, ob, _ := setup(t, false)

	info, _ := s.Signup(ctx)
	if !info.Open || !info.FirstUser {
		t.Fatalf("fresh install: %+v", info)
	}
	_, _, owner, err := s.Register(ctx, reg("owner@acme.io"))
	if err != nil {
		t.Fatal(err)
	}
	if !owner.IsAdmin {
		t.Fatal("the first account is not the Admin")
	}
	ws, _ := s.workspaces.Of(ctx, owner.ID)
	if len(ws) != 1 || ws[0].Role != domain.RoleOwner || ws[0].Plan != "base" || ws[0].TrialEndsAt == nil {
		t.Fatalf("first workspace %+v", ws)
	}
	// The verification link works.
	link := linkRe.FindString(ob.last(t).Body)
	if !strings.Contains(link, "/verify?token=") {
		t.Fatalf("verify email: %q", ob.last(t).Body)
	}
	tok := link[strings.Index(link, "token=")+6:]
	if _, err := s.auth.VerifyEmail(ctx, tok); err != nil {
		t.Fatal(err)
	}
	owner, _ = s.users.ByID(ctx, owner.ID)

	// Invite-only now: nobody registers without a link.
	if info, _ := s.Signup(ctx); info.Open {
		t.Fatal("still open after the first account")
	}
	if _, _, _, err := s.Register(ctx, reg("stranger@x.io")); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("stranger: %v", err)
	}

	res, err := s.Invite(ctx, ws[0].ID, owner, "ann@x.io", domain.RoleUser)
	if err != nil {
		t.Fatal(err)
	}
	if !res.Emailed || !strings.Contains(ob.last(t).Body, res.URL) || ob.last(t).To != "ann@x.io" {
		t.Fatalf("invite email: %+v", ob.last(t))
	}
	invTok := res.URL[strings.LastIndex(res.URL, "/")+1:]
	if p, err := s.PreviewInvite(ctx, invTok); err != nil || p.Workspace != ws[0].Name || p.InvitedBy == "" {
		t.Fatalf("preview %+v %v", p, err)
	}
	// Only the invited address may use it.
	in := reg("other@x.io")
	in.Invite = invTok
	var inv *auth.InvalidError
	if _, _, _, err := s.Register(ctx, in); !errors.As(err, &inv) {
		t.Fatalf("wrong address: %v", err)
	}
	in = reg("ann@x.io")
	in.Invite = invTok
	_, _, ann, err := s.Register(ctx, in)
	if err != nil {
		t.Fatal(err)
	}
	if ann.IsAdmin || ann.EmailVerifiedAt == nil {
		t.Fatalf("ann %+v (the invite proves her address)", ann)
	}
	annWS, _ := s.workspaces.Of(ctx, ann.ID)
	if len(annWS) != 1 || annWS[0].ID != ws[0].ID || annWS[0].Role != domain.RoleUser {
		t.Fatalf("ann joined %+v", annWS)
	}
	if _, err := s.AcceptInvite(ctx, ann, invTok); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("invite reused: %v", err)
	}
	// The plan includes two members: a third invite is refused.
	if _, err := s.Invite(ctx, ws[0].ID, owner, "", domain.RoleUser); !errors.Is(err, domain.ErrMemberLimit) {
		t.Fatalf("over the member limit: %v", err)
	}
}

func TestOpenSignupMembersAndDelete(t *testing.T) {
	ctx := domain.System(context.Background())
	s, _, rm := setup(t, true)
	_, _, owner, err := s.Register(ctx, reg("o@x.io"))
	if err != nil {
		t.Fatal(err)
	}
	in := reg("b@x.io")
	in.WorkspaceName = "Bob's lab"
	_, _, bob, err := s.Register(ctx, in)
	if err != nil {
		t.Fatal(err)
	}
	bws, _ := s.workspaces.Of(ctx, bob.ID)
	if len(bws) != 1 || bws[0].Name != "Bob's lab" || bws[0].Slug != "bob-s-lab" || bob.IsAdmin {
		t.Fatalf("bob's workspace %+v", bws)
	}
	ows, _ := s.workspaces.Of(ctx, owner.ID)
	w := ows[0].Workspace
	// Inviting needs a verified address on the cloud.
	if _, err := s.Invite(ctx, w.ID, owner, "", domain.RoleUser); err == nil {
		t.Fatal("an unverified owner invited")
	}
	_ = s.auth.MarkVerified(ctx, owner)
	owner, _ = s.users.ByID(ctx, owner.ID)
	res, err := s.Invite(ctx, w.ID, owner, "", domain.RoleUser)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.AcceptInvite(ctx, bob, res.URL[strings.LastIndex(res.URL, "/")+1:]); err != nil {
		t.Fatal(err)
	}
	if err := s.Leave(ctx, w.ID, owner); !errors.Is(err, domain.ErrLastOwner) {
		t.Fatalf("owner left: %v", err)
	}
	if err := s.Transfer(ctx, w.ID, owner, bob.ID); err != nil {
		t.Fatal(err)
	}
	if err := s.Leave(ctx, w.ID, owner); err != nil {
		t.Fatalf("former owner leaves: %v", err)
	}
	if err := s.Delete(ctx, w.ID, bob, "nope"); err == nil {
		t.Fatal("deleted without confirming")
	}
	if err := s.Delete(ctx, w.ID, bob, w.Slug); err != nil {
		t.Fatal(err)
	}
	// Purged only after the grace period.
	if err := s.PurgeDeleted(ctx); err != nil || len(rm.ws) != 0 {
		t.Fatalf("purged early: %v %v", rm.ws, err)
	}
	s.now = func() time.Time { return time.Now().Add(DeleteGrace + time.Hour) }
	if err := s.PurgeDeleted(ctx); err != nil || len(rm.ws) != 1 || rm.ws[0] != w.ID {
		t.Fatalf("purge: %v %v", rm.ws, err)
	}
	if _, err := s.workspaces.ByID(ctx, w.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("workspace row kept: %v", err)
	}
}

func TestForgotPassword(t *testing.T) {
	ctx := domain.System(context.Background())
	s, ob, _ := setup(t, true)
	if _, _, _, err := s.Register(ctx, reg("f@x.io")); err != nil {
		t.Fatal(err)
	}
	n := len(ob.sent)
	if err := s.ForgotPassword(ctx, "nobody@x.io"); err != nil || len(ob.sent) != n {
		t.Fatalf("unknown address: %v (sent %d)", err, len(ob.sent)-n)
	}
	if err := s.ForgotPassword(ctx, "F@X.io"); err != nil {
		t.Fatal(err)
	}
	link := linkRe.FindString(ob.last(t).Body)
	tok := link[strings.Index(link, "token=")+6:]
	if err := s.auth.ResetPassword(ctx, tok, "a whole new password"); err != nil {
		t.Fatal(err)
	}
}
