package domain

import (
	"context"
	"errors"
	"regexp"
	"strings"
	"time"
)

// Workspace is one project: its own members, repositories, tickets,
// settings, integrations, Claude connection, slots and credits. A solo
// developer is a workspace with one member.
type Workspace struct {
	ID      int64
	Slug    string
	Name    string
	OwnerID int64
	Plan    string
	// Slots is how many runs of this workspace may run at once.
	Slots int
	// MemberLimit is how many members the plan includes (0: no limit).
	MemberLimit int
	ClaudeMode  ClaudeMode
	// ClaudeFallback lets runs continue on credits when the chosen Claude
	// account is at its limit or missing.
	ClaudeFallback bool
	// DefaultMemberID owns tickets that arrive without a person (webhooks,
	// follow-ups) in per-member mode; nil means the owner.
	DefaultMemberID *int64
	// CreditsBalance is in credits (1 credit = $0.01 of API cost at the
	// markup).
	CreditsBalance int64
	// HookID names the workspace's webhook URLs (/webhooks/<provider>/<hook id>).
	HookID      string
	TrialEndsAt *time.Time
	SuspendedAt *time.Time
	DeletedAt   *time.Time
	CreatedAt   time.Time
}

// ClaudeMode says which Claude account a workspace's runs use.
type ClaudeMode string

// Claude modes.
const (
	// ClaudeShared: every run uses the workspace's connection.
	ClaudeShared ClaudeMode = "shared"
	// ClaudePerMember: a run uses the connection of the ticket's member.
	ClaudePerMember ClaudeMode = "member"
)

// Valid reports whether m is a known mode.
func (m ClaudeMode) Valid() bool { return m == ClaudeShared || m == ClaudePerMember }

// WorkspaceRole is a member's role inside a workspace.
type WorkspaceRole string

// Workspace roles. A workspace has exactly one owner. A viewer sees
// everything a member sees but changes nothing.
const (
	RoleOwner  WorkspaceRole = "owner"
	RoleUser   WorkspaceRole = "user"
	RoleViewer WorkspaceRole = "viewer"
)

// Valid reports whether r is a known role.
func (r WorkspaceRole) Valid() bool { return r == RoleOwner || r == RoleUser || r == RoleViewer }

// CanEdit reports whether the role may change anything in the workspace.
func (r WorkspaceRole) CanEdit() bool { return r == RoleOwner || r == RoleUser }

// Member is a user's membership of a workspace.
type Member struct {
	WorkspaceID int64
	UserID      int64
	Username    string
	Email       string
	Role        WorkspaceRole
	CreatedAt   time.Time
}

// WorkspaceMembership is a workspace as one of its members sees it.
type WorkspaceMembership struct {
	Workspace
	Role    WorkspaceRole
	Members int
}

// Invite asks someone to join a workspace. Only the token's hash is stored.
type Invite struct {
	ID          int64
	WorkspaceID int64
	Email       string
	Role        WorkspaceRole
	InvitedBy   int64
	ExpiresAt   time.Time
	AcceptedAt  *time.Time
	CreatedAt   time.Time
}

// Workspace errors.
var (
	ErrForbidden      = errors.New("forbidden")
	ErrNoWorkspace    = errors.New("no workspace in context")
	ErrSuspended      = errors.New("workspace suspended")
	ErrMemberLimit    = errors.New("member limit reached")
	ErrLastOwner      = errors.New("the owner cannot leave; transfer ownership first")
	ErrInviteInvalid  = errors.New("invite is invalid or expired")
	ErrInsufficientCr = errors.New("not enough credits")
)

var workspaceSlugRe = regexp.MustCompile(`^[a-z0-9](?:[a-z0-9-]{0,38}[a-z0-9])?$`)

// ValidSlug reports whether s can name a workspace in URLs.
func ValidSlug(s string) bool { return workspaceSlugRe.MatchString(s) && !reservedSlugs[s] }

var reservedSlugs = map[string]bool{"new": true, "admin": true, "api": true, "settings": true, "login": true, "signup": true}

// WorkspaceSlug turns a name into a slug candidate (it may still be taken).
func WorkspaceSlug(name string) string {
	var b strings.Builder
	dash := false
	for _, r := range strings.ToLower(name) {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
			dash = false
		case !dash && b.Len() > 0:
			b.WriteByte('-')
			dash = true
		}
		if b.Len() >= 40 {
			break
		}
	}
	s := strings.Trim(b.String(), "-")
	if s == "" || reservedSlugs[s] {
		s = "workspace"
	}
	return s
}

// TicketRef names a ticket across workspaces (keys are unique per
// workspace only).
type TicketRef struct {
	WorkspaceID int64
	Key         string
}

// Scope is what a context may see in the database.
type Scope struct {
	// WorkspaceID is the workspace a request or run acts in; 0 for none.
	WorkspaceID int64
	// All lets system code (the scheduler, background loops, migrations)
	// read every workspace. Requests never get it.
	All bool
}

type scopeKey struct{}
type actorKey struct{}

// WithWorkspace returns ctx acting in workspace id: database access is
// limited to that workspace's rows.
func WithWorkspace(ctx context.Context, id int64) context.Context {
	return context.WithValue(ctx, scopeKey{}, Scope{WorkspaceID: id})
}

// System returns ctx able to read every workspace, for background work
// that picks a workspace per item (and then calls WithWorkspace).
func System(ctx context.Context) context.Context {
	return context.WithValue(ctx, scopeKey{}, Scope{All: true})
}

// ScopeOf returns what ctx may see. Without a scope, ctx sees no
// workspace's rows.
func ScopeOf(ctx context.Context) Scope {
	s, _ := ctx.Value(scopeKey{}).(Scope)
	return s
}

// WorkspaceOf returns the workspace ctx acts in, or 0.
func WorkspaceOf(ctx context.Context) int64 { return ScopeOf(ctx).WorkspaceID }

// MustWorkspace returns the workspace ctx acts in, or ErrNoWorkspace.
func MustWorkspace(ctx context.Context) (int64, error) {
	if id := WorkspaceOf(ctx); id > 0 {
		return id, nil
	}
	return 0, ErrNoWorkspace
}

// Actor is the person behind an action, recorded on its events.
type Actor struct {
	UserID   int64
	Username string
}

// WithActor returns ctx acting for user.
func WithActor(ctx context.Context, a Actor) context.Context {
	return context.WithValue(ctx, actorKey{}, a)
}

// ActorOf returns the person acting in ctx; ok is false for system work.
func ActorOf(ctx context.Context) (Actor, bool) {
	a, ok := ctx.Value(actorKey{}).(Actor)
	return a, ok && a.UserID > 0
}

// ClaudeAccount is the Claude account a run uses: a connection (the
// workspace's or a member's), or agnts's API key paid with credits.
type ClaudeAccount struct {
	// ConnectionID is the claude_connections row; 0 with Credits for
	// agnts's key, 0 without it for the install's legacy connection.
	ConnectionID int64
	Credits      bool
	Label        string
}

type claudeKey struct{}

// WithClaude returns ctx running on account a.
func WithClaude(ctx context.Context, a ClaudeAccount) context.Context {
	return context.WithValue(ctx, claudeKey{}, a)
}

// ClaudeOf returns the account ctx runs on; ok is false when none was
// picked (legacy single-connection installs).
func ClaudeOf(ctx context.Context) (ClaudeAccount, bool) {
	a, ok := ctx.Value(claudeKey{}).(ClaudeAccount)
	return a, ok
}

type hookKey struct{}

// WithHook returns ctx handling a webhook delivered to a workspace's URL
// with hook id id ("" for the URLs from before workspaces).
func WithHook(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, hookKey{}, id)
}

// HookOf returns the hook id a webhook was delivered to, "" for the old
// URLs without one.
func HookOf(ctx context.Context) string {
	id, _ := ctx.Value(hookKey{}).(string)
	return id
}

type ticketKey struct{}

// WithTicket returns ctx working on ticket key, for what needs to know
// whose work it is (the author of its commits).
func WithTicket(ctx context.Context, key string) context.Context {
	return context.WithValue(ctx, ticketKey{}, key)
}

// TicketOf returns the ticket ctx works on, "" when none.
func TicketOf(ctx context.Context) string {
	key, _ := ctx.Value(ticketKey{}).(string)
	return key
}
