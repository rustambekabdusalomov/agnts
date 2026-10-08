// Package accounts is the people side of workspaces: signing up, creating
// workspaces, inviting members and the owner's choices about them.
package accounts

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"agnts/internal/auth"
	"agnts/internal/domain"
	"agnts/internal/mail"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
)

// Workspaces is the workspace store the service needs.
type Workspaces interface {
	Create(ctx context.Context, n postgres.NewWorkspace) (domain.Workspace, error)
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
	Of(ctx context.Context, userID int64) ([]domain.WorkspaceMembership, error)
	Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
	Members(ctx context.Context, ws int64) ([]domain.Member, error)
	RemoveMember(ctx context.Context, ws, userID int64) error
	TransferOwnership(ctx context.Context, ws, to int64) error
	SetRole(ctx context.Context, ws, userID int64, role domain.WorkspaceRole) error
	Update(ctx context.Context, ws int64, u postgres.WorkspaceUpdate) (domain.Workspace, error)
	SetDeleted(ctx context.Context, ws int64, deleted bool) (domain.Workspace, error)
	DeletedBefore(ctx context.Context, t time.Time) ([]domain.Workspace, error)
	Purge(ctx context.Context, ws int64) error
	ClaimOwnerless(ctx context.Context, userID int64) error
	CreateInvite(ctx context.Context, inv domain.Invite, tokenHash []byte) (domain.Invite, error)
	Invites(ctx context.Context, ws int64) ([]domain.Invite, error)
	InviteByToken(ctx context.Context, tokenHash []byte) (domain.Invite, error)
	AcceptInvite(ctx context.Context, tokenHash []byte, userID int64) (domain.Invite, error)
	RevokeInvite(ctx context.Context, ws, id int64) error
}

// Users is the user store the service needs.
type Users interface {
	ByID(ctx context.Context, id int64) (domain.User, error)
	ByEmail(ctx context.Context, email string) (domain.User, error)
	Count(ctx context.Context) (int, error)
	Delete(ctx context.Context, id int64) error
}

// Events records what changed in a workspace.
type Events interface {
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Files removes a deleted workspace's files: repository mirrors, Claude
// session homes, screenshots, package caches.
type Files interface {
	RemoveWorkspace(ctx context.Context, ws int64) error
}

// Config is the platform's rules for new workspaces.
type Config struct {
	PublicURL string
	// Open lets anyone register; otherwise only with an invite (the first
	// account of an install always may).
	Open bool
	// Cloud gives new workspaces the base plan (1 slot, a member limit
	// and a trial); a self-hosted install gives them DefaultSlots and no
	// member limit.
	Cloud           bool
	TrialDays       int
	IncludedMembers int
	DefaultSlots    int
}

// Service runs the people side of workspaces.
type Service struct {
	cfg        Config
	auth       *auth.Service
	users      Users
	workspaces Workspaces
	events     Events
	mail       mail.Sender
	files      Files
	log        *slog.Logger
	now        func() time.Time
}

// New returns the accounts service.
func New(cfg Config, a *auth.Service, users Users, ws Workspaces, events Events, m mail.Sender, files Files, log *slog.Logger) *Service {
	cfg.PublicURL = strings.TrimRight(cfg.PublicURL, "/")
	return &Service{cfg: cfg, auth: a, users: users, workspaces: ws, events: events, mail: m, files: files, log: log, now: time.Now}
}

// InviteTTL is how long an invite link works.
const InviteTTL = 7 * 24 * time.Hour

// DeleteGrace is how long a deleted workspace is kept for undo.
const DeleteGrace = 7 * 24 * time.Hour

// SignupInfo says who may register here, and how.
type SignupInfo struct {
	Open, FirstUser, EmailEnabled bool
	// PasswordSignup is registering with a password; when only Admins
	// sign in with one, only the install's first account (the Admin) may.
	PasswordSignup bool
}

// Signup returns who may register.
func (s *Service) Signup(ctx context.Context) (SignupInfo, error) {
	n, err := s.users.Count(ctx)
	return SignupInfo{Open: s.cfg.Open || n == 0, FirstUser: n == 0, EmailEnabled: s.mail.Enabled(),
		PasswordSignup: n == 0 || !s.auth.AdminPasswordsOnly()}, err
}

// RegisterInput is a sign-up.
type RegisterInput struct {
	auth.RegisterInput
	WorkspaceName string
	Invite        string // an invite token to join with
}

// Register creates an account, then either joins the invite's workspace
// or creates the person's first workspace. The first account of an
// install becomes Admin and takes over the migrated workspace.
func (s *Service) Register(ctx context.Context, in RegisterInput) (string, domain.Session, domain.User, error) {
	var none domain.Session
	info, err := s.Signup(ctx)
	if err != nil {
		return "", none, domain.User{}, err
	}
	if !info.PasswordSignup {
		return "", none, domain.User{}, auth.ErrUseGoogle
	}
	var inv domain.Invite
	if in.Invite != "" {
		if inv, err = s.workspaces.InviteByToken(ctx, secret.HashToken(in.Invite)); err != nil {
			return "", none, domain.User{}, auth.Invalid("this invite link is invalid or expired; ask for a new one")
		}
		if inv.Email != "" && !strings.EqualFold(inv.Email, strings.TrimSpace(in.Email)) {
			return "", none, domain.User{}, auth.Invalid("this invite is for " + inv.Email + "; sign up with that address")
		}
	} else if !info.Open {
		return "", none, domain.User{}, domain.ErrForbidden
	}
	token, sess, u, err := s.auth.Register(ctx, in.RegisterInput)
	if err != nil {
		return "", none, domain.User{}, err
	}
	// With separate roles the first account is the Admin: no workspace.
	if !u.IsAdmin || !s.auth.AdminPasswordsOnly() {
		if err := s.firstWorkspace(ctx, u, info.FirstUser, in.WorkspaceName, in.Invite); err != nil {
			return "", none, u, err
		}
	}
	// An invite sent to this address proves it already.
	if inv.Email != "" {
		if err := s.auth.MarkVerified(ctx, u); err != nil {
			s.log.Warn("mark email verified", "user", u.ID, "err", err)
		}
	} else if err := s.SendVerification(ctx, u); err != nil {
		s.log.Warn("send verification email", "user", u.ID, "err", err)
	}
	if u, err = s.users.ByID(ctx, u.ID); err != nil {
		return "", none, u, err
	}
	return token, sess, u, nil
}

// firstWorkspace puts a new account in a workspace: the invite's, or a
// personal one it owns (the first account of an install also takes over
// the workspace migrated from before workspaces).
func (s *Service) firstWorkspace(ctx context.Context, u domain.User, firstUser bool, name, invite string) error {
	switch {
	case firstUser:
		if err := s.workspaces.ClaimOwnerless(ctx, u.ID); err != nil {
			return err
		}
		if ws, err := s.workspaces.Of(ctx, u.ID); err == nil && len(ws) == 0 {
			_, err = s.CreateWorkspace(ctx, u, firstName(name, u), "")
			return err
		}
		return nil
	case invite != "":
		_, err := s.AcceptInvite(ctx, u, invite)
		return err
	default:
		_, err := s.CreateWorkspace(ctx, u, firstName(name, u), "")
		return err
	}
}

// GoogleInput is a sign-in with an address Google verified.
type GoogleInput struct {
	Email       string
	DisplayName string
	// Invite is an invite token to join with ("" for none).
	Invite    string
	Client    domain.Client
	UserAgent string
	IP        string
}

// GoogleResult is a Google sign-in's session and the workspace to open
// ("" for the one they used last).
type GoogleResult struct {
	Token     string
	Session   domain.Session
	User      domain.User
	Workspace string
}

// SignInWithGoogle signs in the account with in.Email, registering it when
// sign-up is open here, it comes with an invite, or it is the install's
// first account. A new account starts as a solo developer, the owner of a
// personal workspace where it can invite people or create more workspaces;
// with an invite it joins that workspace instead (an existing account joins
// it too).
func (s *Service) SignInWithGoogle(ctx context.Context, in GoogleInput) (GoogleResult, error) {
	info, err := s.Signup(ctx)
	if err != nil {
		return GoogleResult{}, err
	}
	var invited int64 // the invite's workspace
	if in.Invite != "" {
		inv, err := s.workspaces.InviteByToken(ctx, secret.HashToken(in.Invite))
		if err != nil {
			return GoogleResult{}, auth.Invalid("this invite link is invalid or expired; ask for a new one")
		}
		if inv.Email != "" && !strings.EqualFold(inv.Email, strings.TrimSpace(in.Email)) {
			return GoogleResult{}, auth.Invalid("this invite is for " + inv.Email + "; sign in with that Google account")
		}
		invited = inv.WorkspaceID
	}
	if _, err := s.users.ByEmail(ctx, strings.TrimSpace(in.Email)); errors.Is(err, domain.ErrNotFound) && !info.Open && in.Invite == "" {
		return GoogleResult{}, domain.ErrForbidden
	} else if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return GoogleResult{}, err
	}
	token, sess, u, created, err := s.auth.SignInVerified(ctx, auth.Verified{Email: in.Email, DisplayName: in.DisplayName,
		Client: in.Client, UserAgent: in.UserAgent, IP: in.IP})
	if err != nil {
		return GoogleResult{}, err
	}
	res := GoogleResult{Token: token, Session: sess, User: u}
	// With separate roles a new Google account never takes over the
	// install's migrated workspace (that is the Admin's install).
	first := info.FirstUser && in.Invite == "" && !s.auth.AdminPasswordsOnly()
	switch {
	case created:
		if err := s.firstWorkspace(ctx, u, first, "", in.Invite); err != nil {
			return GoogleResult{}, err
		}
		s.log.Info("registered with Google", "user", u.ID)
	case in.Invite != "":
		if _, err := s.AcceptInvite(ctx, u, in.Invite); err != nil {
			return GoogleResult{}, err
		}
	}
	if invited != 0 {
		if w, err := s.workspaces.ByID(ctx, invited); err == nil {
			res.Workspace = w.Slug
		}
	}
	return res, nil
}

// notAdmin refuses workspaces to an Admin when Admins and Users are
// separate: an Admin runs the platform, a User works in workspaces.
func (s *Service) notAdmin(u domain.User) error {
	if u.IsAdmin && s.auth.AdminPasswordsOnly() {
		return auth.Invalid("Admins run the platform and have no workspaces: sign in with a Google account to work in one")
	}
	return nil
}

// CreateAdmin makes a new Admin account (by another Admin).
func (s *Service) CreateAdmin(ctx context.Context, by domain.User, in auth.AdminInput) (domain.User, error) {
	u, err := s.auth.CreateAdmin(ctx, in)
	if err != nil {
		return u, err
	}
	s.log.Info("admin created", "admin", u.ID, "by", by.ID)
	return u, nil
}

// DeleteAdmin deletes an Admin account: never your own, never the last
// Admin, and never one that owns a workspace.
func (s *Service) DeleteAdmin(ctx context.Context, by domain.User, id int64) error {
	if id == by.ID {
		return auth.Invalid("you cannot delete your own Admin account; ask another Admin")
	}
	u, err := s.users.ByID(ctx, id)
	if err != nil {
		return err
	}
	if !u.IsAdmin {
		return auth.Invalid("this account is a User, not an Admin")
	}
	if ws, err := s.workspaces.Of(ctx, id); err != nil {
		return err
	} else if len(ws) > 0 {
		return auth.Invalid("this Admin is in a workspace; transfer or leave it first")
	}
	if err := s.users.Delete(ctx, id); err != nil {
		return err
	}
	s.log.Info("admin deleted", "admin", id, "by", by.ID)
	return nil
}

func firstName(name string, u domain.User) string {
	if name = strings.TrimSpace(name); name != "" {
		return name
	}
	who := u.DisplayName
	if who == "" {
		who = u.Username
	}
	return who + "'s workspace"
}

// CreateWorkspace creates a workspace owned by u, on the plan new
// workspaces get here.
func (s *Service) CreateWorkspace(ctx context.Context, u domain.User, name, slug string) (domain.Workspace, error) {
	if err := s.notAdmin(u); err != nil {
		return domain.Workspace{}, err
	}
	name = strings.TrimSpace(name)
	if name == "" || len(name) > 80 {
		return domain.Workspace{}, auth.Invalid("a workspace needs a name of up to 80 characters")
	}
	slug = strings.ToLower(strings.TrimSpace(slug))
	if slug != "" && !domain.ValidSlug(slug) {
		return domain.Workspace{}, auth.Invalid("an address has 1 to 40 lowercase letters, digits and dashes")
	}
	n := postgres.NewWorkspace{Name: name, Slug: slug, OwnerID: u.ID, Plan: "self-hosted", Slots: max(1, s.cfg.DefaultSlots)}
	if s.cfg.Cloud {
		n.Plan, n.Slots, n.MemberLimit = "base", 1, s.cfg.IncludedMembers
		if s.cfg.TrialDays > 0 {
			t := s.now().Add(time.Duration(s.cfg.TrialDays) * 24 * time.Hour)
			n.TrialEndsAt = &t
		}
	}
	w, err := s.workspaces.Create(ctx, n)
	if err != nil {
		return w, err
	}
	s.event(domain.WithWorkspace(ctx, w.ID), "workspace "+w.Name+" created")
	return w, nil
}

func (s *Service) event(ctx context.Context, msg string) {
	if err := s.events.AppendEvent(ctx, domain.Event{Type: domain.EventWorkspace, Origin: domain.OriginWeb, Message: msg}); err != nil {
		s.log.Warn("workspace event", "err", err)
	}
}

// SendVerification emails u a link that confirms their address.
func (s *Service) SendVerification(ctx context.Context, u domain.User) error {
	if u.Email == "" {
		return auth.Invalid("add an email address to your profile first")
	}
	if u.EmailVerifiedAt != nil {
		return nil
	}
	tok, err := s.auth.NewLink(ctx, u, auth.PurposeVerify)
	if err != nil {
		return err
	}
	return s.mail.Send(ctx, mail.Message{To: u.Email, Subject: "Confirm your email for agnts",
		Body: "Hi " + nameOf(u) + ",\n\nOpen this link to confirm your email address:\n\n" +
			s.cfg.PublicURL + "/verify?token=" + tok + "\n\nThe link works for 7 days. If you did not sign up for agnts, ignore this email.\n"})
}

// ForgotPassword emails a reset link when email belongs to an account; it
// never says whether it does.
func (s *Service) ForgotPassword(ctx context.Context, email string) error {
	u, err := s.users.ByEmail(ctx, strings.TrimSpace(email))
	if errors.Is(err, domain.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	tok, err := s.auth.NewLink(ctx, u, auth.PurposeReset)
	if err != nil {
		return err
	}
	return s.mail.Send(ctx, mail.Message{To: u.Email, Subject: "Reset your agnts password",
		Body: "Hi " + nameOf(u) + ",\n\nOpen this link to choose a new password:\n\n" +
			s.cfg.PublicURL + "/reset-password?token=" + tok + "\n\nThe link works for an hour. If you did not ask for it, ignore this email: your password stays as it is.\n"})
}

func nameOf(u domain.User) string {
	if u.DisplayName != "" {
		return u.DisplayName
	}
	return u.Username
}

// InviteResult is a new invite with its link (shown once).
type InviteResult struct {
	Invite  domain.Invite
	URL     string
	Emailed bool
}

// Invite creates an invite link to workspace ws that joins as role (a user
// or a viewer), and emails it when email is given.
func (s *Service) Invite(ctx context.Context, ws int64, by domain.User, email string, role domain.WorkspaceRole) (InviteResult, error) {
	if role == "" {
		role = domain.RoleUser
	}
	if role != domain.RoleUser && role != domain.RoleViewer {
		return InviteResult{}, auth.Invalid("an invite joins as a member or a viewer")
	}
	email = strings.TrimSpace(email)
	if email != "" && !auth.ValidEmail(email) {
		return InviteResult{}, auth.Invalid("enter a valid email address")
	}
	if s.cfg.Cloud && by.EmailVerifiedAt == nil {
		return InviteResult{}, auth.Invalid("confirm your own email address before inviting people")
	}
	w, err := s.workspaces.ByID(ctx, ws)
	if err != nil {
		return InviteResult{}, err
	}
	if email != "" {
		if u, err := s.users.ByEmail(ctx, email); err == nil {
			if _, err := s.workspaces.Role(ctx, ws, u.ID); err == nil {
				return InviteResult{}, fmt.Errorf("%w: %s is a member already", domain.ErrConflict, email)
			}
		}
	}
	if members, err := s.workspaces.Members(ctx, ws); err == nil && w.MemberLimit > 0 && len(members) >= w.MemberLimit {
		return InviteResult{}, fmt.Errorf("%w: the plan includes %d members; add more in Billing", domain.ErrMemberLimit, w.MemberLimit)
	}
	tok, err := secret.NewToken()
	if err != nil {
		return InviteResult{}, err
	}
	inv, err := s.workspaces.CreateInvite(ctx, domain.Invite{WorkspaceID: ws, Email: email, Role: role, InvitedBy: by.ID,
		ExpiresAt: s.now().Add(InviteTTL)}, secret.HashToken(tok))
	if err != nil {
		return InviteResult{}, err
	}
	res := InviteResult{Invite: inv, URL: s.cfg.PublicURL + "/invite/" + tok}
	if email != "" {
		err := s.mail.Send(ctx, mail.Message{To: email, Subject: nameOf(by) + " invited you to " + w.Name + " on agnts",
			Body: nameOf(by) + " invited you to join the workspace " + w.Name + " on agnts.\n\nOpen this link to join:\n\n" +
				res.URL + "\n\nThe link works for 7 days.\n"})
		if err != nil {
			s.log.Warn("send invite email", "workspace", ws, "err", err)
		} else {
			res.Emailed = s.mail.Enabled()
		}
	}
	who := email
	if who == "" {
		who = "someone with a link"
	}
	s.event(ctx, nameOf(by)+" invited "+who)
	return res, nil
}

// InvitePreview is what an invite link shows before joining.
type InvitePreview struct {
	Workspace string
	InvitedBy string
	Email     string
	ExpiresAt time.Time
}

// PreviewInvite describes an open invite.
func (s *Service) PreviewInvite(ctx context.Context, token string) (InvitePreview, error) {
	inv, err := s.workspaces.InviteByToken(ctx, secret.HashToken(token))
	if err != nil {
		return InvitePreview{}, domain.ErrNotFound
	}
	w, err := s.workspaces.ByID(ctx, inv.WorkspaceID)
	if err != nil {
		return InvitePreview{}, err
	}
	p := InvitePreview{Workspace: w.Name, Email: inv.Email, ExpiresAt: inv.ExpiresAt}
	if by, err := s.users.ByID(ctx, inv.InvitedBy); err == nil {
		p.InvitedBy = nameOf(by)
	}
	return p, nil
}

// AcceptInvite makes u a member of the invite's workspace.
func (s *Service) AcceptInvite(ctx context.Context, u domain.User, token string) (domain.Workspace, error) {
	if err := s.notAdmin(u); err != nil {
		return domain.Workspace{}, err
	}
	inv, err := s.workspaces.InviteByToken(ctx, secret.HashToken(token))
	if err != nil {
		return domain.Workspace{}, domain.ErrNotFound
	}
	if inv.Email != "" && !strings.EqualFold(inv.Email, u.Email) {
		return domain.Workspace{}, auth.Invalid("this invite is for " + inv.Email + "; sign in with that account")
	}
	if inv, err = s.workspaces.AcceptInvite(ctx, secret.HashToken(token), u.ID); err != nil {
		if errors.Is(err, domain.ErrInviteInvalid) {
			return domain.Workspace{}, domain.ErrNotFound
		}
		return domain.Workspace{}, err
	}
	w, err := s.workspaces.ByID(ctx, inv.WorkspaceID)
	if err != nil {
		return w, err
	}
	s.event(domain.WithWorkspace(ctx, w.ID), nameOf(u)+" joined")
	return w, nil
}

// SetRole makes a member (not the owner) a user or a viewer.
func (s *Service) SetRole(ctx context.Context, ws int64, by domain.User, userID int64, role domain.WorkspaceRole) error {
	u, err := s.users.ByID(ctx, userID)
	if err != nil {
		return err
	}
	if err := s.workspaces.SetRole(ctx, ws, userID, role); err != nil {
		return err
	}
	what := "a member"
	if role == domain.RoleViewer {
		what = "a viewer"
	}
	s.event(ctx, nameOf(by)+" made "+nameOf(u)+" "+what)
	return nil
}

// RemoveMember removes a member (not the owner).
func (s *Service) RemoveMember(ctx context.Context, ws int64, by domain.User, userID int64) error {
	u, err := s.users.ByID(ctx, userID)
	if err != nil {
		return err
	}
	if err := s.workspaces.RemoveMember(ctx, ws, userID); err != nil {
		return err
	}
	s.event(ctx, nameOf(by)+" removed "+nameOf(u))
	return nil
}

// Leave takes u out of a workspace; the owner transfers it first.
func (s *Service) Leave(ctx context.Context, ws int64, u domain.User) error {
	if err := s.workspaces.RemoveMember(ctx, ws, u.ID); err != nil {
		return err
	}
	s.event(ctx, nameOf(u)+" left")
	return nil
}

// Transfer makes member to the owner.
func (s *Service) Transfer(ctx context.Context, ws int64, by domain.User, to int64) error {
	u, err := s.users.ByID(ctx, to)
	if err != nil {
		return err
	}
	if err := s.workspaces.TransferOwnership(ctx, ws, to); err != nil {
		return err
	}
	s.event(ctx, nameOf(by)+" made "+nameOf(u)+" the owner")
	return nil
}

// Delete marks a workspace deleted. Its runs stop being started; it is
// purged after DeleteGrace.
func (s *Service) Delete(ctx context.Context, ws int64, by domain.User, confirm string) error {
	w, err := s.workspaces.ByID(ctx, ws)
	if err != nil {
		return err
	}
	if confirm != w.Slug {
		return auth.Invalid("type the workspace's address (" + w.Slug + ") to confirm")
	}
	if _, err := s.workspaces.SetDeleted(ctx, ws, true); err != nil {
		return err
	}
	s.event(ctx, nameOf(by)+" deleted the workspace; it is purged in 7 days")
	return nil
}

// PurgeDeleted removes the workspaces deleted more than DeleteGrace ago:
// their files, then their rows.
func (s *Service) PurgeDeleted(ctx context.Context) error {
	ws, err := s.workspaces.DeletedBefore(ctx, s.now().Add(-DeleteGrace))
	if err != nil {
		return err
	}
	var errs []error
	for _, w := range ws {
		if s.files != nil {
			if err := s.files.RemoveWorkspace(ctx, w.ID); err != nil {
				errs = append(errs, fmt.Errorf("workspace %d files: %w", w.ID, err))
				continue
			}
		}
		if err := s.workspaces.Purge(ctx, w.ID); err != nil {
			errs = append(errs, fmt.Errorf("workspace %d: %w", w.ID, err))
			continue
		}
		s.log.Info("purged a deleted workspace", "workspace", w.ID, "slug", w.Slug)
	}
	return errors.Join(errs...)
}
