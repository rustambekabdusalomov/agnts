package postgres

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Workspaces stores workspaces, their members and invites. These tables
// have no row-level policy: every query names the workspace or the user.
type Workspaces struct{ db *pgxpool.Pool }

// NewWorkspaces returns the workspaces store.
func NewWorkspaces(db *pgxpool.Pool) *Workspaces { return &Workspaces{db: db} }

const workspaceCols = `w.id, w.slug, w.name, COALESCE(w.owner_id, 0), w.plan, w.slots, w.member_limit, w.claude_mode, w.claude_fallback,
	w.default_member_id, w.credits_balance, w.hook_id, w.trial_ends_at, w.suspended_at, w.deleted_at, w.created_at`

func scanWorkspace(row pgx.Row, extra ...any) (domain.Workspace, error) {
	var w domain.Workspace
	var mode string
	dest := append([]any{&w.ID, &w.Slug, &w.Name, &w.OwnerID, &w.Plan, &w.Slots, &w.MemberLimit, &mode, &w.ClaudeFallback,
		&w.DefaultMemberID, &w.CreditsBalance, &w.HookID, &w.TrialEndsAt, &w.SuspendedAt, &w.DeletedAt, &w.CreatedAt}, extra...)
	err := row.Scan(dest...)
	w.ClaudeMode = domain.ClaudeMode(mode)
	return w, notFound(err)
}

// NewWorkspace is what Create needs.
type NewWorkspace struct {
	Name        string
	Slug        string // "" derives one from Name
	OwnerID     int64
	Plan        string
	Slots       int
	MemberLimit int
	TrialEndsAt *time.Time
}

// Create inserts a workspace and makes its owner a member. A slug taken
// already gets a number appended when it was derived from the name;
// a chosen one fails with ErrConflict.
func (s *Workspaces) Create(ctx context.Context, n NewWorkspace) (domain.Workspace, error) {
	chosen := n.Slug != ""
	base := n.Slug
	if !chosen {
		base = domain.WorkspaceSlug(n.Name)
	}
	if !domain.ValidSlug(base) {
		return domain.Workspace{}, fmt.Errorf("%w: invalid slug %q", domain.ErrConflict, base)
	}
	if n.Plan == "" {
		n.Plan = "base"
	}
	n.Slots = max(n.Slots, 1)
	for i := 1; i < 100; i++ {
		slug := base
		if i > 1 {
			slug = base + "-" + strconv.Itoa(i)
		}
		var w domain.Workspace
		err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
			var err error
			w, err = scanWorkspace(tx.QueryRow(ctx, `INSERT INTO workspaces AS w (slug, name, owner_id, plan, slots, member_limit, trial_ends_at)
				VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING `+workspaceCols,
				slug, n.Name, n.OwnerID, n.Plan, n.Slots, n.MemberLimit, n.TrialEndsAt))
			if err != nil {
				return err
			}
			_, err = tx.Exec(ctx, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'owner')`, w.ID, n.OwnerID)
			return err
		})
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" && pgErr.ConstraintName == "workspaces_slug_key" {
			if chosen {
				return w, fmt.Errorf("%w: the address %q is taken", domain.ErrConflict, slug)
			}
			continue
		}
		return w, err
	}
	return domain.Workspace{}, fmt.Errorf("%w: no free address for %q", domain.ErrConflict, base)
}

// ByID returns a workspace (deleted ones included).
func (s *Workspaces) ByID(ctx context.Context, id int64) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `SELECT `+workspaceCols+` FROM workspaces w WHERE w.id = $1`, id))
}

// BySlug returns a workspace that is not deleted.
func (s *Workspaces) BySlug(ctx context.Context, slug string) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `SELECT `+workspaceCols+` FROM workspaces w WHERE w.slug = $1 AND w.deleted_at IS NULL`, slug))
}

// ByHookID returns the workspace whose webhook URLs carry hookID.
func (s *Workspaces) ByHookID(ctx context.Context, hookID string) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `SELECT `+workspaceCols+` FROM workspaces w WHERE w.hook_id = $1 AND w.deleted_at IS NULL`, hookID))
}

// Default returns the workspace an install migrated into (slug "default"),
// or the oldest one: the old webhook URLs without a hook id go there.
func (s *Workspaces) Default(ctx context.Context) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `SELECT `+workspaceCols+` FROM workspaces w WHERE w.deleted_at IS NULL
		ORDER BY (w.slug = 'default') DESC, w.id LIMIT 1`))
}

// Active returns the ids of the workspaces that are not deleted or
// suspended, for loops that run per workspace.
func (s *Workspaces) Active(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT id FROM workspaces WHERE deleted_at IS NULL AND suspended_at IS NULL ORDER BY id`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// List returns every workspace with its member count, for the operator
// console; deleted ones only when withDeleted.
func (s *Workspaces) List(ctx context.Context, withDeleted bool) ([]domain.WorkspaceMembership, error) {
	rows, err := s.db.Query(ctx, `SELECT `+workspaceCols+`, (SELECT count(*) FROM memberships m WHERE m.workspace_id = w.id)
		FROM workspaces w WHERE $1 OR w.deleted_at IS NULL ORDER BY w.id`, withDeleted)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.WorkspaceMembership
	for rows.Next() {
		var m domain.WorkspaceMembership
		w, err := scanWorkspace(rows, &m.Members)
		if err != nil {
			return nil, err
		}
		m.Workspace = w
		out = append(out, m)
	}
	return out, rows.Err()
}

// Of returns the workspaces userID is a member of, with their role.
func (s *Workspaces) Of(ctx context.Context, userID int64) ([]domain.WorkspaceMembership, error) {
	rows, err := s.db.Query(ctx, `SELECT `+workspaceCols+`, m.role, (SELECT count(*) FROM memberships x WHERE x.workspace_id = w.id)
		FROM memberships m JOIN workspaces w ON w.id = m.workspace_id
		WHERE m.user_id = $1 AND w.deleted_at IS NULL ORDER BY w.name, w.id`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.WorkspaceMembership
	for rows.Next() {
		var m domain.WorkspaceMembership
		var role string
		w, err := scanWorkspace(rows, &role, &m.Members)
		if err != nil {
			return nil, err
		}
		m.Workspace, m.Role = w, domain.WorkspaceRole(role)
		out = append(out, m)
	}
	return out, rows.Err()
}

// Memberships returns every membership of a workspace that is not
// deleted, for the Admin's user list.
func (s *Workspaces) Memberships(ctx context.Context) ([]domain.Member, error) {
	rows, err := s.db.Query(ctx, `SELECT m.workspace_id, m.user_id, m.role, m.created_at
		FROM memberships m JOIN workspaces w ON w.id = m.workspace_id WHERE w.deleted_at IS NULL ORDER BY w.name, w.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Member
	for rows.Next() {
		var m domain.Member
		var role string
		if err := rows.Scan(&m.WorkspaceID, &m.UserID, &role, &m.CreatedAt); err != nil {
			return nil, err
		}
		m.Role = domain.WorkspaceRole(role)
		out = append(out, m)
	}
	return out, rows.Err()
}

// Role returns userID's role in workspace ws, or ErrNotFound when they
// are not a member.
func (s *Workspaces) Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error) {
	var role string
	err := s.db.QueryRow(ctx, `SELECT role FROM memberships WHERE workspace_id = $1 AND user_id = $2`, ws, userID).Scan(&role)
	return domain.WorkspaceRole(role), notFound(err)
}

// Members returns a workspace's members, the owner first.
func (s *Workspaces) Members(ctx context.Context, ws int64) ([]domain.Member, error) {
	rows, err := s.db.Query(ctx, `SELECT m.workspace_id, m.user_id, u.username, COALESCE(u.email, ''), m.role, m.created_at
		FROM memberships m JOIN users u ON u.id = m.user_id WHERE m.workspace_id = $1
		ORDER BY (m.role = 'owner') DESC, u.username`, ws)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Member
	for rows.Next() {
		var m domain.Member
		var role string
		if err := rows.Scan(&m.WorkspaceID, &m.UserID, &m.Username, &m.Email, &role, &m.CreatedAt); err != nil {
			return nil, err
		}
		m.Role = domain.WorkspaceRole(role)
		out = append(out, m)
	}
	return out, rows.Err()
}

// AddMember makes userID a member (a user). It fails with ErrMemberLimit
// when the plan's member limit is reached, and does nothing for someone
// who is a member already.
func (s *Workspaces) AddMember(ctx context.Context, ws, userID int64, role domain.WorkspaceRole) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error { return addMember(ctx, tx, ws, userID, role) })
}

// addMember joins userID to ws as a user or a viewer (never the owner).
func addMember(ctx context.Context, tx pgx.Tx, ws, userID int64, role domain.WorkspaceRole) error {
	if role != domain.RoleViewer {
		role = domain.RoleUser
	}
	var limit, n int
	var member bool
	// Locking the workspace row serializes joins, so two invites cannot
	// both take the last seat.
	if err := tx.QueryRow(ctx, `SELECT member_limit, (SELECT count(*) FROM memberships WHERE workspace_id = $1),
		EXISTS (SELECT 1 FROM memberships WHERE workspace_id = $1 AND user_id = $2)
		FROM workspaces WHERE id = $1 AND deleted_at IS NULL FOR UPDATE`, ws, userID).Scan(&limit, &n, &member); err != nil {
		return notFound(err)
	}
	if member {
		return nil
	}
	if limit > 0 && n >= limit {
		return domain.ErrMemberLimit
	}
	_, err := tx.Exec(ctx, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, $3)`, ws, userID, string(role))
	return err
}

// SetRole makes a member who is not the owner a user or a viewer. A viewer
// runs nothing, so they stop being the default member for Claude.
func (s *Workspaces) SetRole(ctx context.Context, ws, userID int64, role domain.WorkspaceRole) error {
	if role != domain.RoleUser && role != domain.RoleViewer {
		return fmt.Errorf("%w: a member is a user or a viewer; transfer ownership to make an owner", domain.ErrConflict)
	}
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var cur string
		if err := tx.QueryRow(ctx, `SELECT role FROM memberships WHERE workspace_id = $1 AND user_id = $2 FOR UPDATE`, ws, userID).Scan(&cur); err != nil {
			return notFound(err)
		}
		if cur == string(domain.RoleOwner) {
			return fmt.Errorf("%w: the owner's role changes only by transferring ownership", domain.ErrLastOwner)
		}
		if _, err := tx.Exec(ctx, `UPDATE memberships SET role = $3 WHERE workspace_id = $1 AND user_id = $2`, ws, userID, string(role)); err != nil {
			return err
		}
		if role != domain.RoleViewer {
			return nil
		}
		_, err := tx.Exec(ctx, `UPDATE workspaces SET default_member_id = NULL, updated_at = now()
			WHERE id = $1 AND default_member_id = $2`, ws, userID)
		return err
	})
}

// RemoveMember removes a member who is not the owner.
func (s *Workspaces) RemoveMember(ctx context.Context, ws, userID int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var role string
		if err := tx.QueryRow(ctx, `SELECT role FROM memberships WHERE workspace_id = $1 AND user_id = $2 FOR UPDATE`, ws, userID).Scan(&role); err != nil {
			return notFound(err)
		}
		if role == string(domain.RoleOwner) {
			return domain.ErrLastOwner
		}
		if _, err := tx.Exec(ctx, `DELETE FROM memberships WHERE workspace_id = $1 AND user_id = $2`, ws, userID); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `UPDATE workspaces SET default_member_id = NULL, updated_at = now()
			WHERE id = $1 AND default_member_id = $2`, ws, userID)
		return err
	})
}

// TransferOwnership makes member to the owner; the old owner stays a user.
func (s *Workspaces) TransferOwnership(ctx context.Context, ws, to int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var role string
		if err := tx.QueryRow(ctx, `SELECT role FROM memberships WHERE workspace_id = $1 AND user_id = $2 FOR UPDATE`, ws, to).Scan(&role); err != nil {
			return notFound(err)
		}
		if role == string(domain.RoleOwner) {
			return nil
		}
		if _, err := tx.Exec(ctx, `UPDATE memberships SET role = 'user' WHERE workspace_id = $1 AND role = 'owner'`, ws); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `UPDATE memberships SET role = 'owner' WHERE workspace_id = $1 AND user_id = $2`, ws, to); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `UPDATE workspaces SET owner_id = $2, updated_at = now() WHERE id = $1`, ws, to)
		return err
	})
}

// WorkspaceUpdate is what an owner may change in General and Claude settings.
type WorkspaceUpdate struct {
	Name            *string
	Slug            *string
	ClaudeMode      *domain.ClaudeMode
	ClaudeFallback  *bool
	DefaultMemberID *int64 // 0 clears it (the owner)
}

// Update changes a workspace's name, address and Claude choices.
func (s *Workspaces) Update(ctx context.Context, ws int64, u WorkspaceUpdate) (domain.Workspace, error) {
	if u.Slug != nil && !domain.ValidSlug(*u.Slug) {
		return domain.Workspace{}, fmt.Errorf("%w: invalid address %q", domain.ErrConflict, *u.Slug)
	}
	if u.ClaudeMode != nil && !u.ClaudeMode.Valid() {
		return domain.Workspace{}, fmt.Errorf("unknown Claude mode %q", *u.ClaudeMode)
	}
	var mode *string
	if u.ClaudeMode != nil {
		m := string(*u.ClaudeMode)
		mode = &m
	}
	clearDefault := u.DefaultMemberID != nil && *u.DefaultMemberID == 0
	if u.DefaultMemberID != nil && *u.DefaultMemberID > 0 {
		role, err := s.Role(ctx, ws, *u.DefaultMemberID)
		if err != nil {
			return domain.Workspace{}, fmt.Errorf("the default member must be a member: %w", err)
		}
		if role == domain.RoleViewer {
			return domain.Workspace{}, fmt.Errorf("%w: a viewer cannot run tickets on their Claude account", domain.ErrConflict)
		}
	}
	w, err := scanWorkspace(s.db.QueryRow(ctx, `UPDATE workspaces w SET
		name = COALESCE($2, name), slug = COALESCE($3, slug), claude_mode = COALESCE($4, claude_mode),
		claude_fallback = COALESCE($5, claude_fallback),
		default_member_id = CASE WHEN $7 THEN NULL ELSE COALESCE($6, default_member_id) END, updated_at = now()
		WHERE id = $1 AND deleted_at IS NULL RETURNING `+workspaceCols,
		ws, u.Name, u.Slug, mode, u.ClaudeFallback, u.DefaultMemberID, clearDefault))
	return w, uniqueConflict(err)
}

// PlanUpdate is what the platform (an Admin, or billing) changes.
type PlanUpdate struct {
	Plan        *string
	Slots       *int
	MemberLimit *int
	TrialEndsAt *time.Time
}

// SetPlan changes a workspace's plan, slots and member limit.
func (s *Workspaces) SetPlan(ctx context.Context, ws int64, p PlanUpdate) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `UPDATE workspaces w SET plan = COALESCE($2, plan), slots = COALESCE($3, slots),
		member_limit = COALESCE($4, member_limit), trial_ends_at = COALESCE($5, trial_ends_at), updated_at = now()
		WHERE id = $1 RETURNING `+workspaceCols, ws, p.Plan, p.Slots, p.MemberLimit, p.TrialEndsAt))
}

// SetSuspended suspends a workspace (its runs stop being started) or lifts it.
func (s *Workspaces) SetSuspended(ctx context.Context, ws int64, suspended bool) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `UPDATE workspaces w SET
		suspended_at = CASE WHEN $2 THEN COALESCE(suspended_at, now()) END, updated_at = now()
		WHERE id = $1 RETURNING `+workspaceCols, ws, suspended))
}

// SetDeleted marks a workspace deleted (kept for undo until purged) or
// restores it.
func (s *Workspaces) SetDeleted(ctx context.Context, ws int64, deleted bool) (domain.Workspace, error) {
	return scanWorkspace(s.db.QueryRow(ctx, `UPDATE workspaces w SET
		deleted_at = CASE WHEN $2 THEN COALESCE(deleted_at, now()) END, updated_at = now()
		WHERE id = $1 RETURNING `+workspaceCols, ws, deleted))
}

// DeletedBefore returns workspaces deleted before t, due to be purged.
func (s *Workspaces) DeletedBefore(ctx context.Context, t time.Time) ([]domain.Workspace, error) {
	rows, err := s.db.Query(ctx, `SELECT `+workspaceCols+` FROM workspaces w WHERE w.deleted_at < $1 ORDER BY w.id`, t)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Workspace
	for rows.Next() {
		w, err := scanWorkspace(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, w)
	}
	return out, rows.Err()
}

// Purge deletes a workspace and every row that belongs to it. The caller
// removes its files first. ctx must be a system context: the rows of
// several tables go with it.
func (s *Workspaces) Purge(ctx context.Context, ws int64) error {
	_, err := s.db.Exec(domain.System(ctx), `DELETE FROM workspaces WHERE id = $1`, ws)
	return err
}

// PaidUntil returns when a workspace's next month of the plan is due.
func (s *Workspaces) PaidUntil(ctx context.Context, ws int64) (*time.Time, error) {
	var t *time.Time
	err := s.db.QueryRow(ctx, `SELECT paid_until FROM workspaces WHERE id = $1`, ws).Scan(&t)
	return t, notFound(err)
}

// SetPaidUntil records that a workspace's plan is paid until t.
func (s *Workspaces) SetPaidUntil(ctx context.Context, ws int64, t time.Time) error {
	_, err := s.db.Exec(ctx, `UPDATE workspaces SET paid_until = $2, updated_at = now() WHERE id = $1`, ws, t)
	return err
}

// SetLastWorkspace remembers which workspace userID opened last.
func (s *Workspaces) SetLastWorkspace(ctx context.Context, userID, ws int64) error {
	_, err := s.db.Exec(ctx, `UPDATE users SET last_workspace_id = $2 WHERE id = $1 AND last_workspace_id IS DISTINCT FROM $2`, userID, ws)
	return err
}

// ClaimOwnerless gives every workspace without an owner (an install
// migrated before it had a user) to userID.
func (s *Workspaces) ClaimOwnerless(ctx context.Context, userID int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `UPDATE workspaces SET owner_id = $1, updated_at = now() WHERE owner_id IS NULL RETURNING id`, userID)
		if err != nil {
			return err
		}
		ids, err := pgx.CollectRows(rows, pgx.RowTo[int64])
		if err != nil {
			return err
		}
		for _, id := range ids {
			if _, err := tx.Exec(ctx, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'owner')
				ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'owner'`, id, userID); err != nil {
				return err
			}
			if _, err := tx.Exec(ctx, `UPDATE users SET last_workspace_id = COALESCE(last_workspace_id, $2) WHERE id = $1`, userID, id); err != nil {
				return err
			}
		}
		return nil
	})
}

// CreateInvite stores an invite by the hash of its token.
func (s *Workspaces) CreateInvite(ctx context.Context, inv domain.Invite, tokenHash []byte) (domain.Invite, error) {
	if inv.Role == "" {
		inv.Role = domain.RoleUser
	}
	err := s.db.QueryRow(ctx, `INSERT INTO invites (workspace_id, email, role, token_hash, invited_by, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, created_at`,
		inv.WorkspaceID, inv.Email, string(inv.Role), tokenHash, inv.InvitedBy, inv.ExpiresAt).Scan(&inv.ID, &inv.CreatedAt)
	return inv, err
}

const inviteCols = `id, workspace_id, email, role, COALESCE(invited_by, 0), expires_at, accepted_at, created_at`

func scanInvite(row pgx.Row) (domain.Invite, error) {
	var inv domain.Invite
	var role string
	err := row.Scan(&inv.ID, &inv.WorkspaceID, &inv.Email, &role, &inv.InvitedBy, &inv.ExpiresAt, &inv.AcceptedAt, &inv.CreatedAt)
	inv.Role = domain.WorkspaceRole(role)
	return inv, notFound(err)
}

// Invites returns a workspace's open invites, newest first.
func (s *Workspaces) Invites(ctx context.Context, ws int64) ([]domain.Invite, error) {
	rows, err := s.db.Query(ctx, `SELECT `+inviteCols+` FROM invites
		WHERE workspace_id = $1 AND accepted_at IS NULL AND expires_at > now() ORDER BY created_at DESC`, ws)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Invite
	for rows.Next() {
		inv, err := scanInvite(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, inv)
	}
	return out, rows.Err()
}

// InviteByToken returns an open invite by its token's hash.
func (s *Workspaces) InviteByToken(ctx context.Context, tokenHash []byte) (domain.Invite, error) {
	inv, err := scanInvite(s.db.QueryRow(ctx, `SELECT `+inviteCols+` FROM invites WHERE token_hash = $1`, tokenHash))
	if errors.Is(err, domain.ErrNotFound) || (err == nil && (inv.AcceptedAt != nil || !inv.ExpiresAt.After(time.Now()))) {
		return inv, domain.ErrInviteInvalid
	}
	return inv, err
}

// AcceptInvite makes userID a member through an open invite, once.
func (s *Workspaces) AcceptInvite(ctx context.Context, tokenHash []byte, userID int64) (domain.Invite, error) {
	var inv domain.Invite
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		inv, err = scanInvite(tx.QueryRow(ctx, `SELECT `+inviteCols+` FROM invites WHERE token_hash = $1
			AND accepted_at IS NULL AND expires_at > now() FOR UPDATE`, tokenHash))
		if errors.Is(err, domain.ErrNotFound) {
			return domain.ErrInviteInvalid
		}
		if err != nil {
			return err
		}
		if err := addMember(ctx, tx, inv.WorkspaceID, userID, inv.Role); err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `UPDATE invites SET accepted_at = now(), accepted_by = $2 WHERE id = $1`, inv.ID, userID)
		return err
	})
	return inv, err
}

// RevokeInvite deletes an open invite of a workspace.
func (s *Workspaces) RevokeInvite(ctx context.Context, ws, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM invites WHERE workspace_id = $1 AND id = $2 AND accepted_at IS NULL`, ws, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}
