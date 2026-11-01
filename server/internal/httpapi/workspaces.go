package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"agnts/internal/ai/connections"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

// ClaudeService manages the Claude accounts runs use.
type ClaudeService interface {
	SubscriptionsAllowed() bool
	CreditsEnabled(provider string) bool
	AnyCredits() bool
	WorkspaceConnection(ctx context.Context, ws int64, provider string) (postgres.ClaudeConnection, error)
	UserConnection(ctx context.Context, userID int64, provider string) (postgres.ClaudeConnection, error)
	SetWorkspace(ctx context.Context, ws int64, kind, token string) (postgres.ClaudeConnection, error)
	SetUser(ctx context.Context, userID int64, kind, token string) (postgres.ClaudeConnection, error)
	DeleteWorkspaceConnection(ctx context.Context, ws int64, provider string) error
	DeleteUserConnection(ctx context.Context, userID int64, provider string) error
	MemberConnections(ctx context.Context, ws int64, provider string) (map[int64]*time.Time, error)
	UsageOf(ctx context.Context, c postgres.ClaudeConnection) (usage.View, error)
	AccountFor(ctx context.Context, w domain.Workspace, userID int64, provider string) (domain.ClaudeAccount, bool)
}

// QueueReporter is the scheduler's view of the queue.
type QueueReporter interface {
	QueueStatus(ctx context.Context) (orchestrator.QueueStatus, error)
	ServerStatus() orchestrator.ServerStatus
	ForgetWorkspace(id int64)
}

func toWorkspaceSummary(m domain.WorkspaceMembership) gen.WorkspaceSummary {
	out := gen.WorkspaceSummary{Id: m.ID, Slug: m.Slug, Name: m.Name, Role: gen.WorkspaceRole(m.Role), Members: m.Members,
		Plan: m.Plan, Slots: m.Slots}
	if m.SuspendedAt != nil {
		t := true
		out.Suspended = &t
	}
	return out
}

func toWorkspaceDetail(w domain.Workspace, role domain.WorkspaceRole, members int) gen.WorkspaceDetail {
	out := gen.WorkspaceDetail{Id: w.ID, Slug: w.Slug, Name: w.Name, Role: gen.WorkspaceRole(role), OwnerId: w.OwnerID, Plan: w.Plan,
		Slots: w.Slots, MemberLimit: w.MemberLimit, Members: members, ClaudeMode: gen.WorkspaceDetailClaudeMode(w.ClaudeMode),
		ClaudeFallback: w.ClaudeFallback, DefaultMemberId: w.DefaultMemberID, CreditsBalance: w.CreditsBalance,
		TrialEndsAt: w.TrialEndsAt, DeletedAt: w.DeletedAt, CreatedAt: w.CreatedAt}
	if w.SuspendedAt != nil {
		t := true
		out.Suspended = &t
	}
	return out
}

// ListWorkspaces implements gen.ServerInterface.
func (s *Server) ListWorkspaces(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	ws, err := s.opt.Workspaces.Of(r.Context(), u.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.WorkspaceSummary, 0, len(ws))
	for _, m := range ws {
		out = append(out, toWorkspaceSummary(m))
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateWorkspace implements gen.ServerInterface.
func (s *Server) CreateWorkspace(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	var req gen.CreateWorkspaceJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if s.opt.Cloud && u.EmailVerifiedAt == nil {
		ws, _ := s.opt.Workspaces.Of(r.Context(), u.ID)
		owned := 0
		for _, m := range ws {
			if m.Role == domain.RoleOwner {
				owned++
			}
		}
		if owned > 0 {
			writeError(w, http.StatusForbidden, "forbidden", "confirm your email address before creating more workspaces")
			return
		}
	}
	ws, err := s.opt.Accounts.CreateWorkspace(r.Context(), u, req.Name, deref(req.Slug))
	if err != nil {
		s.authError(w, r, err)
		return
	}
	_ = s.opt.Workspaces.SetLastWorkspace(r.Context(), u.ID, ws.ID)
	writeJSON(w, http.StatusCreated, toWorkspaceSummary(domain.WorkspaceMembership{Workspace: ws, Role: domain.RoleOwner, Members: 1}))
}

// GetInvite implements gen.ServerInterface.
func (s *Server) GetInvite(w http.ResponseWriter, r *http.Request, token string) {
	if s.accountsOff(w) {
		return
	}
	p, err := s.opt.Accounts.PreviewInvite(r.Context(), token)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found", "this invite link is invalid or expired")
		return
	}
	out := gen.InvitePreview{Workspace: p.Workspace, ExpiresAt: p.ExpiresAt}
	if p.InvitedBy != "" {
		out.InvitedBy = &p.InvitedBy
	}
	if p.Email != "" {
		out.Email = &p.Email
	}
	writeJSON(w, http.StatusOK, out)
}

// AcceptInvite implements gen.ServerInterface.
func (s *Server) AcceptInvite(w http.ResponseWriter, r *http.Request, token string) {
	if s.accountsOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	ws, err := s.opt.Accounts.AcceptInvite(r.Context(), u, token)
	if errors.Is(err, domain.ErrNotFound) {
		writeError(w, http.StatusNotFound, "not_found", "this invite link is invalid or expired")
		return
	}
	if err != nil {
		s.authError(w, r, err)
		return
	}
	_ = s.opt.Workspaces.SetLastWorkspace(r.Context(), u.ID, ws.ID)
	members, _ := s.opt.Workspaces.Members(r.Context(), ws.ID)
	writeJSON(w, http.StatusOK, toWorkspaceSummary(domain.WorkspaceMembership{Workspace: ws, Role: domain.RoleUser, Members: len(members)}))
}

// GetWorkspace implements gen.ServerInterface. Opening a workspace makes
// it the one the person lands in next time.
func (s *Server) GetWorkspace(w http.ResponseWriter, r *http.Request) {
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	if u.LastWorkspaceID == nil || *u.LastWorkspaceID != m.w.ID {
		_ = s.opt.Workspaces.SetLastWorkspace(r.Context(), u.ID, m.w.ID)
	}
	members, err := s.opt.Workspaces.Members(r.Context(), m.w.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toWorkspaceDetail(m.w, m.role, len(members)))
}

// UpdateWorkspace implements gen.ServerInterface.
func (s *Server) UpdateWorkspace(w http.ResponseWriter, r *http.Request) {
	m, _ := memberFrom(r.Context())
	var req gen.UpdateWorkspaceJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	upd := postgres.WorkspaceUpdate{}
	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if name == "" || len(name) > 80 {
			writeError(w, http.StatusBadRequest, "bad_request", "a workspace needs a name of up to 80 characters")
			return
		}
		upd.Name = &name
	}
	if req.Slug != nil {
		slug := strings.ToLower(strings.TrimSpace(*req.Slug))
		if !domain.ValidSlug(slug) {
			writeError(w, http.StatusBadRequest, "bad_request", "an address has 1 to 40 lowercase letters, digits and dashes")
			return
		}
		upd.Slug = &slug
	}
	out, err := s.opt.Workspaces.Update(r.Context(), m.w.ID, upd)
	if errors.Is(err, domain.ErrConflict) {
		writeError(w, http.StatusConflict, "conflict", "this address is taken")
		return
	}
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.workspaceChanged(r.Context(), out.ID, "workspace settings changed")
	members, _ := s.opt.Workspaces.Members(r.Context(), out.ID)
	writeJSON(w, http.StatusOK, toWorkspaceDetail(out, m.role, len(members)))
}

// workspaceChanged records a change in the workspace's log and drops the
// scheduler's cached copy.
func (s *Server) workspaceChanged(ctx context.Context, ws int64, msg string) {
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(ws)
	}
	if s.opt.EventLog != nil {
		_ = s.opt.EventLog.AppendEvent(ctx, domain.Event{Type: domain.EventWorkspace, Origin: domain.OriginWeb, Message: msg})
	}
}

// DeleteWorkspace implements gen.ServerInterface.
func (s *Server) DeleteWorkspace(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.DeleteWorkspaceJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Accounts.Delete(r.Context(), m.w.ID, u, req.Confirm); err != nil {
		s.authError(w, r, err)
		return
	}
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(m.w.ID)
	}
	w.WriteHeader(http.StatusNoContent)
}

// ListMembers implements gen.ServerInterface. Emails are the owner's to see.
func (s *Server) ListMembers(w http.ResponseWriter, r *http.Request) {
	m, _ := memberFrom(r.Context())
	ms, err := s.opt.Workspaces.Members(r.Context(), m.w.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	var conns map[int64]*time.Time
	if s.opt.Claude != nil {
		conns, _ = s.opt.Claude.MemberConnections(r.Context(), m.w.ID, s.connProvider(r.Context(), nil))
	}
	out := make([]gen.Member, 0, len(ms))
	for _, x := range ms {
		_, connected := conns[x.UserID]
		g := gen.Member{UserId: x.UserID, Username: x.Username, Role: gen.WorkspaceRole(x.Role), JoinedAt: x.CreatedAt, ClaudeConnected: connected}
		if m.role == domain.RoleOwner && x.Email != "" {
			e := x.Email
			g.Email = &e
		}
		if s.opt.Users != nil {
			if u, err := s.opt.Users.ByID(r.Context(), x.UserID); err == nil && u.DisplayName != "" {
				n := u.DisplayName
				g.DisplayName = &n
			}
		}
		out = append(out, g)
	}
	writeJSON(w, http.StatusOK, out)
}

// RemoveMember implements gen.ServerInterface.
func (s *Server) RemoveMember(w http.ResponseWriter, r *http.Request, userID int64) {
	if s.accountsOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	if err := s.opt.Accounts.RemoveMember(r.Context(), m.w.ID, u, userID); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// SetMemberRole implements gen.ServerInterface.
func (s *Server) SetMemberRole(w http.ResponseWriter, r *http.Request, userID int64) {
	if s.accountsOff(w) {
		return
	}
	var req gen.SetMemberRoleJSONBody
	if err := decodeJSON(r, &req); err != nil || !req.Role.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "role is user or viewer")
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	if err := s.opt.Accounts.SetRole(r.Context(), m.w.ID, u, userID, domain.WorkspaceRole(req.Role)); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// TransferWorkspace implements gen.ServerInterface.
func (s *Server) TransferWorkspace(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.TransferWorkspaceJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Accounts.Transfer(r.Context(), m.w.ID, u, req.UserId); err != nil {
		s.authError(w, r, err)
		return
	}
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(m.w.ID)
	}
	w.WriteHeader(http.StatusNoContent)
}

// LeaveWorkspace implements gen.ServerInterface.
func (s *Server) LeaveWorkspace(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	if err := s.opt.Accounts.Leave(r.Context(), m.w.ID, u); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) toInvite(ctx context.Context, inv domain.Invite) gen.Invite {
	out := gen.Invite{Id: inv.ID, Email: inv.Email, Role: gen.WorkspaceRole(inv.Role), ExpiresAt: inv.ExpiresAt, CreatedAt: inv.CreatedAt}
	if s.opt.Users != nil && inv.InvitedBy > 0 {
		if u, err := s.opt.Users.ByID(ctx, inv.InvitedBy); err == nil {
			out.InvitedBy = &u.Username
		}
	}
	return out
}

// ListInvites implements gen.ServerInterface.
func (s *Server) ListInvites(w http.ResponseWriter, r *http.Request) {
	m, _ := memberFrom(r.Context())
	invs, err := s.opt.Workspaces.Invites(r.Context(), m.w.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.Invite, 0, len(invs))
	for _, inv := range invs {
		out = append(out, s.toInvite(r.Context(), inv))
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateInvite implements gen.ServerInterface.
func (s *Server) CreateInvite(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) || !s.limit(w, r, s.mailLimiter, "too many invites, try again later") {
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.CreateInviteJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	role := domain.RoleUser
	if req.Role != nil {
		role = domain.WorkspaceRole(*req.Role)
	}
	res, err := s.opt.Accounts.Invite(r.Context(), m.w.ID, u, deref(req.Email), role)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	emailed := res.Emailed
	writeJSON(w, http.StatusCreated, map[string]any{"invite": s.toInvite(r.Context(), res.Invite), "url": res.URL, "emailed": emailed})
}

// RevokeInvite implements gen.ServerInterface.
func (s *Server) RevokeInvite(w http.ResponseWriter, r *http.Request, id int64) {
	m, _ := memberFrom(r.Context())
	if err := s.opt.Workspaces.RevokeInvite(r.Context(), m.w.ID, id); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func toCapacity(c orchestrator.CapacityStatus) gen.Capacity {
	out := gen.Capacity{BudgetMb: c.BudgetMB, ReservedMb: c.ReservedMB, Runs: c.Runs, Full: c.Full}
	if c.DiskFreeMB >= 0 {
		d := c.DiskFreeMB
		out.DiskFreeMb = &d
	}
	return out
}

// GetQueue implements gen.ServerInterface.
func (s *Server) GetQueue(w http.ResponseWriter, r *http.Request) {
	if s.opt.Queue == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "the queue is not available")
		return
	}
	q, err := s.opt.Queue.QueueStatus(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.QueueStatus{Running: q.Running, Slots: q.Slots, ServerQueueLength: q.ServerQueueLen, Capacity: toCapacity(q.Capacity)}
	count := func(r domain.WaitReason) *int {
		if n := q.Waiting[r]; n > 0 {
			return &n
		}
		return nil
	}
	out.Waiting.Blocked, out.Waiting.Slots, out.Waiting.Server, out.Waiting.Claude =
		count(domain.WaitBlocked), count(domain.WaitSlots), count(domain.WaitServer), count(domain.WaitClaude)
	out.ServerQueue = make([]struct {
		EstimateSec *int   `json:"estimateSec,omitempty"`
		Key         string `json:"key"`
		Others      int    `json:"others"`
		Position    int    `json:"position"`
	}, 0, len(q.ServerQueue))
	for _, e := range q.ServerQueue {
		x := struct {
			EstimateSec *int   `json:"estimateSec,omitempty"`
			Key         string `json:"key"`
			Others      int    `json:"others"`
			Position    int    `json:"position"`
		}{Key: e.Key, Others: e.Others, Position: e.Position}
		if e.Estimate > 0 {
			sec := int(e.Estimate.Seconds())
			x.EstimateSec = &sec
		}
		out.ServerQueue = append(out.ServerQueue, x)
	}
	writeJSON(w, http.StatusOK, out)
}

// connectionState shows a connection without its token.
func (s *Server) connectionState(ctx context.Context, c postgres.ClaudeConnection, err error) gen.ClaudeConnectionState {
	if err != nil {
		return gen.ClaudeConnectionState{Connected: false}
	}
	kind := gen.ClaudeConnectionStateKind(c.Kind)
	out := gen.ClaudeConnectionState{Connected: true, Kind: &kind, PausedUntil: c.PausedUntil, CheckedAt: c.CheckedAt}
	if len(c.Token) >= 4 {
		hint := c.Token[len(c.Token)-4:]
		out.TokenHint = &hint
	}
	if c.Account != "" {
		out.Account = &c.Account
	}
	if c.LastError != "" {
		out.LastError = &c.LastError
	}
	if v, uerr := s.opt.Claude.UsageOf(ctx, c); uerr == nil {
		u := toUsage(v)
		out.Usage = &u
	}
	return out
}

func (s *Server) claudeOff(w http.ResponseWriter) bool {
	if s.opt.Claude == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return true
	}
	return false
}

// workspaceClaude is the Claude (or Muse: provider) page of Workspace
// settings.
func (s *Server) workspaceClaude(ctx context.Context, wsp domain.Workspace, provider string) (gen.WorkspaceClaude, error) {
	c, err := s.opt.Claude.WorkspaceConnection(ctx, wsp.ID, provider)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return gen.WorkspaceClaude{}, err
	}
	out := gen.WorkspaceClaude{Mode: gen.WorkspaceClaudeMode(wsp.ClaudeMode), Fallback: wsp.ClaudeFallback, DefaultMemberId: wsp.DefaultMemberID,
		Connection: s.connectionState(ctx, c, err), CreditsBalance: wsp.CreditsBalance, SubscriptionsAllowed: s.opt.Claude.SubscriptionsAllowed()}
	conns, err := s.opt.Claude.MemberConnections(ctx, wsp.ID, provider)
	if err != nil {
		return out, err
	}
	members, err := s.opt.Workspaces.Members(ctx, wsp.ID)
	if err != nil {
		return out, err
	}
	for _, m := range members {
		if !m.Role.CanEdit() {
			continue // viewers run nothing, so their accounts are never used
		}
		until, connected := conns[m.UserID]
		out.Members = append(out.Members, struct {
			Connected   bool       `json:"connected"`
			PausedUntil *time.Time `json:"pausedUntil,omitempty"`
			UserId      int64      `json:"userId"`
			Username    string     `json:"username"`
		}{Connected: connected, PausedUntil: until, UserId: m.UserID, Username: m.Username})
	}
	return out, nil
}

// GetWorkspaceClaude implements gen.ServerInterface.
func (s *Server) GetWorkspaceClaude(w http.ResponseWriter, r *http.Request, p gen.GetWorkspaceClaudeParams) {
	if s.claudeOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	out, err := s.workspaceClaude(r.Context(), m.w, s.connProvider(r.Context(), (*string)(p.Provider)))
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, out)
}

// UpdateWorkspaceClaude implements gen.ServerInterface.
func (s *Server) UpdateWorkspaceClaude(w http.ResponseWriter, r *http.Request) {
	if s.claudeOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	var req gen.UpdateWorkspaceClaudeJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	upd := postgres.WorkspaceUpdate{ClaudeFallback: req.Fallback, DefaultMemberID: req.DefaultMemberId}
	if req.Mode != nil {
		mode := domain.ClaudeMode(*req.Mode)
		upd.ClaudeMode = &mode
	}
	if req.Fallback != nil && *req.Fallback && !s.opt.Claude.AnyCredits() {
		writeError(w, http.StatusBadRequest, "bad_request", "credits are not available on this server")
		return
	}
	wsp, err := s.opt.Workspaces.Update(r.Context(), m.w.ID, upd)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusBadRequest, "bad_request", "the default member must be a member of the workspace")
			return
		}
		s.writeInternal(w, r, err)
		return
	}
	s.workspaceChanged(r.Context(), wsp.ID, "account settings changed: mode "+string(wsp.ClaudeMode))
	out, err := s.workspaceClaude(r.Context(), wsp, s.connProvider(r.Context(), nil))
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, out)
}

func (s *Server) claudeError(w http.ResponseWriter, r *http.Request, err error) {
	var inv *connections.InvalidError
	if errors.As(err, &inv) {
		writeError(w, http.StatusBadRequest, "bad_request", inv.Msg)
		return
	}
	s.writeInternal(w, r, err)
}

// SetWorkspaceClaudeConnection implements gen.ServerInterface.
func (s *Server) SetWorkspaceClaudeConnection(w http.ResponseWriter, r *http.Request) {
	if s.claudeOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	var req gen.ClaudeConnectionInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	provider := postgres.ProviderOfKind(string(req.Kind))
	if !s.moduleEnabled(r.Context(), provider) {
		writeError(w, http.StatusForbidden, "module_disabled", domain.ModuleName(provider)+" is not enabled on this server")
		return
	}
	if _, err := s.opt.Claude.SetWorkspace(r.Context(), m.w.ID, string(req.Kind), req.Token); err != nil {
		s.claudeError(w, r, err)
		return
	}
	s.workspaceChanged(r.Context(), m.w.ID, "the workspace's "+domain.ModuleName(provider)+" account was connected")
	out, err := s.workspaceClaude(r.Context(), m.w, provider)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, out)
}

// DeleteWorkspaceClaudeConnection implements gen.ServerInterface.
func (s *Server) DeleteWorkspaceClaudeConnection(w http.ResponseWriter, r *http.Request, p gen.DeleteWorkspaceClaudeConnectionParams) {
	if s.claudeOff(w) {
		return
	}
	m, _ := memberFrom(r.Context())
	provider := s.connProvider(r.Context(), (*string)(p.Provider))
	if err := s.opt.Claude.DeleteWorkspaceConnection(r.Context(), m.w.ID, provider); err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.workspaceChanged(r.Context(), m.w.ID, "the workspace's "+domain.ModuleName(provider)+" account was disconnected")
	w.WriteHeader(http.StatusNoContent)
}

// GetMyClaude implements gen.ServerInterface.
func (s *Server) GetMyClaude(w http.ResponseWriter, r *http.Request, p gen.GetMyClaudeParams) {
	if s.claudeOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	c, err := s.opt.Claude.UserConnection(r.Context(), u.ID, s.connProvider(r.Context(), (*string)(p.Provider)))
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.connectionState(r.Context(), c, err))
}

// SetMyClaude implements gen.ServerInterface.
func (s *Server) SetMyClaude(w http.ResponseWriter, r *http.Request) {
	if s.claudeOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	var req gen.ClaudeConnectionInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if provider := postgres.ProviderOfKind(string(req.Kind)); !s.accessOf(r.Context(), u.ID).Allows(provider) {
		writeError(w, http.StatusForbidden, "module_disabled", domain.ModuleName(provider)+" is not enabled for you; ask an Admin")
		return
	}
	c, err := s.opt.Claude.SetUser(r.Context(), u.ID, string(req.Kind), req.Token)
	if err != nil {
		s.claudeError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.connectionState(r.Context(), c, nil))
}

// DeleteMyClaude implements gen.ServerInterface.
func (s *Server) DeleteMyClaude(w http.ResponseWriter, r *http.Request, p gen.DeleteMyClaudeParams) {
	if s.claudeOff(w) {
		return
	}
	u, _ := userFrom(r.Context())
	if err := s.opt.Claude.DeleteUserConnection(r.Context(), u.ID, s.connProvider(r.Context(), (*string)(p.Provider))); err != nil {
		s.writeInternal(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
