package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"agnts/internal/auth"
	"agnts/internal/billing"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// BillingService runs plans, slots and credits.
type BillingService interface {
	Enabled() bool
	View(ctx context.Context, ws int64) (billing.View, error)
	SetSlots(ctx context.Context, ws int64, slots int, by int64) (billing.View, error)
	Checkout(ctx context.Context, ws, by, amountUZS int64, provider string) (string, int64, error)
	Grant(ctx context.Context, ws, amount int64, note string, by int64) (int64, error)
}

func (s *Server) platformWorkspace(m domain.WorkspaceMembership, running int, owner string) gen.PlatformWorkspace {
	out := gen.PlatformWorkspace{Id: m.ID, Slug: m.Slug, Name: m.Name, Plan: m.Plan, Slots: m.Slots, MemberLimit: m.MemberLimit,
		Members: m.Members, CreditsBalance: m.CreditsBalance, Running: running, DeletedAt: m.DeletedAt, CreatedAt: m.CreatedAt}
	if m.SuspendedAt != nil {
		t := true
		out.Suspended = &t
	}
	if owner != "" {
		out.Owner = &owner
	}
	return out
}

// names returns usernames by id.
func (s *Server) names(ctx context.Context) map[int64]string {
	out := map[int64]string{}
	if s.opt.Users == nil {
		return out
	}
	us, err := s.opt.Users.List(ctx)
	if err != nil {
		return out
	}
	for _, u := range us {
		out[u.ID] = u.Username
	}
	return out
}

// GetPlatformOverview implements gen.ServerInterface.
func (s *Server) GetPlatformOverview(w http.ResponseWriter, r *http.Request) {
	ctx := domain.System(r.Context())
	ws, err := s.opt.Workspaces.List(ctx, false)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	slugs := map[int64]string{}
	for _, x := range ws {
		slugs[x.ID] = x.Slug
	}
	users := 0
	if s.opt.Users != nil {
		users, _ = s.opt.Users.Count(ctx)
	}
	out := gen.PlatformOverview{Workspaces: len(ws), Users: users}
	if s.opt.Queue != nil {
		st := s.opt.Queue.ServerStatus()
		out.Capacity = toCapacity(st.Capacity)
		for _, run := range st.Runs {
			slug := slugs[run.WorkspaceID]
			out.Runs = append(out.Runs, struct {
				Stage       string    `json:"stage"`
				StartedAt   time.Time `json:"startedAt"`
				TicketKey   string    `json:"ticketKey"`
				Workspace   *string   `json:"workspace,omitempty"`
				WorkspaceId int64     `json:"workspaceId"`
			}{Stage: string(run.Stage), StartedAt: run.Started, TicketKey: run.Key, Workspace: &slug, WorkspaceId: run.WorkspaceID})
		}
		for _, ref := range st.ServerQueue {
			slug := slugs[ref.WorkspaceID]
			out.ServerQueue = append(out.ServerQueue, struct {
				TicketKey   string  `json:"ticketKey"`
				Workspace   *string `json:"workspace,omitempty"`
				WorkspaceId int64   `json:"workspaceId"`
			}{TicketKey: ref.Key, Workspace: &slug, WorkspaceId: ref.WorkspaceID})
		}
	}
	if out.Runs == nil {
		out.Runs = []struct {
			Stage       string    `json:"stage"`
			StartedAt   time.Time `json:"startedAt"`
			TicketKey   string    `json:"ticketKey"`
			Workspace   *string   `json:"workspace,omitempty"`
			WorkspaceId int64     `json:"workspaceId"`
		}{}
	}
	if out.ServerQueue == nil {
		out.ServerQueue = []struct {
			TicketKey   string  `json:"ticketKey"`
			Workspace   *string `json:"workspace,omitempty"`
			WorkspaceId int64   `json:"workspaceId"`
		}{}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListPlatformWorkspaces implements gen.ServerInterface: metadata only;
// an Admin sees no tickets of a workspace they are not a member of.
func (s *Server) ListPlatformWorkspaces(w http.ResponseWriter, r *http.Request) {
	ctx := domain.System(r.Context())
	ws, err := s.opt.Workspaces.List(ctx, true)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	running := map[int64]int{}
	if s.opt.Queue != nil {
		running = s.opt.Queue.ServerStatus().Running
	}
	names := s.names(ctx)
	out := make([]gen.PlatformWorkspace, 0, len(ws))
	for _, x := range ws {
		out = append(out, s.platformWorkspace(x, running[x.ID], names[x.OwnerID]))
	}
	writeJSON(w, http.StatusOK, out)
}

// platformOne returns one workspace as the console shows it.
func (s *Server) platformOne(ctx context.Context, id int64) (gen.PlatformWorkspace, error) {
	ws, err := s.opt.Workspaces.List(ctx, true)
	if err != nil {
		return gen.PlatformWorkspace{}, err
	}
	running := map[int64]int{}
	if s.opt.Queue != nil {
		running = s.opt.Queue.ServerStatus().Running
	}
	for _, x := range ws {
		if x.ID == id {
			return s.platformWorkspace(x, running[x.ID], s.names(ctx)[x.OwnerID]), nil
		}
	}
	return gen.PlatformWorkspace{}, domain.ErrNotFound
}

// UpdatePlatformWorkspace implements gen.ServerInterface.
func (s *Server) UpdatePlatformWorkspace(w http.ResponseWriter, r *http.Request, id int64) {
	ctx := domain.System(r.Context())
	var req gen.UpdatePlatformWorkspaceJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if _, err := s.opt.Workspaces.ByID(ctx, id); err != nil {
		s.authError(w, r, err)
		return
	}
	if req.Plan != nil || req.Slots != nil || req.MemberLimit != nil {
		p := postgres.PlanUpdate{Plan: req.Plan, Slots: req.Slots, MemberLimit: req.MemberLimit}
		if p.Plan != nil {
			plan := strings.TrimSpace(*p.Plan)
			if plan == "" {
				writeError(w, http.StatusBadRequest, "bad_request", "a plan needs a name")
				return
			}
			p.Plan = &plan
		}
		if _, err := s.opt.Workspaces.SetPlan(ctx, id, p); err != nil {
			s.writeInternal(w, r, err)
			return
		}
	}
	if req.Suspended != nil {
		if _, err := s.opt.Workspaces.SetSuspended(ctx, id, *req.Suspended); err != nil {
			s.writeInternal(w, r, err)
			return
		}
	}
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(id)
	}
	out, err := s.platformOne(ctx, id)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, out)
}

// GrantCredits implements gen.ServerInterface.
func (s *Server) GrantCredits(w http.ResponseWriter, r *http.Request, id int64) {
	if s.opt.Billing == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "billing is not available")
		return
	}
	ctx := domain.System(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.GrantCreditsJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if _, err := s.opt.Billing.Grant(ctx, id, req.Amount, deref(req.Note), u.ID); err != nil {
		s.billingError(w, r, err)
		return
	}
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(id)
	}
	out, err := s.platformOne(ctx, id)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, out)
}

// ListPlatformUsers implements gen.ServerInterface: every user with the
// workspaces they belong to, how they sign in and when they last did.
func (s *Server) ListPlatformUsers(w http.ResponseWriter, r *http.Request) {
	ctx := domain.System(r.Context())
	us, err := s.opt.Users.List(ctx)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	ws, err := s.opt.Workspaces.List(ctx, false)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	members, err := s.opt.Workspaces.Memberships(ctx)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	last, err := s.opt.Users.LastSignIns(ctx)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	byID := make(map[int64]domain.WorkspaceMembership, len(ws))
	for _, x := range ws {
		byID[x.ID] = x
	}
	of := map[int64][]gen.WorkspaceSummary{}
	for _, m := range members {
		if x, ok := byID[m.WorkspaceID]; ok {
			x.Role = m.Role
			of[m.UserID] = append(of[m.UserID], toWorkspaceSummary(x))
		}
	}
	out := make([]gen.PlatformUser, 0, len(us))
	for _, u := range us {
		p := gen.PlatformUser{User: toUser(u), HasPassword: u.HasPassword(), Workspaces: of[u.ID]}
		if p.Workspaces == nil {
			p.Workspaces = []gen.WorkspaceSummary{}
		}
		if t, ok := last[u.ID]; ok {
			p.LastSignInAt = &t
		}
		if s.opt.Muse != nil {
			if f, err := s.opt.Muse.Free(ctx, u.ID); err == nil {
				fc := toFreeCredits(f)
				p.FreeCredits = &fc
			}
			if cu, err := s.opt.Muse.Usage(ctx, u.ID); err == nil {
				c := toCreditUsage(cu)
				p.CreditUsage = &c
			}
		}
		out = append(out, p)
	}
	writeJSON(w, http.StatusOK, out)
}

// UpdatePlatformUser implements gen.ServerInterface.
func (s *Server) UpdatePlatformUser(w http.ResponseWriter, r *http.Request, id int64) {
	me, _ := userFrom(r.Context())
	var req gen.UpdatePlatformUserJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if s.opt.Auth != nil && s.opt.Auth.AdminPasswordsOnly() {
		writeError(w, http.StatusBadRequest, "bad_request", "an account is either an Admin or a User: create Admins on the Admins page")
		return
	}
	if id == me.ID && !req.IsAdmin {
		writeError(w, http.StatusBadRequest, "bad_request", "you cannot remove your own Admin role; ask another Admin")
		return
	}
	if err := s.opt.Users.SetAdmin(r.Context(), id, req.IsAdmin); err != nil {
		s.authError(w, r, err)
		return
	}
	u, err := s.opt.Users.ByID(r.Context(), id)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toUser(u))
}

// CreatePlatformAdmin implements gen.ServerInterface.
func (s *Server) CreatePlatformAdmin(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	me, _ := userFrom(r.Context())
	var req gen.CreatePlatformAdminJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	u, err := s.opt.Accounts.CreateAdmin(domain.System(r.Context()), me, auth.AdminInput{
		Username: req.Username, Email: deref(req.Email), DisplayName: deref(req.DisplayName), Password: req.Password,
	})
	if err != nil {
		s.authError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toUser(u))
}

// DeletePlatformAdmin implements gen.ServerInterface.
func (s *Server) DeletePlatformAdmin(w http.ResponseWriter, r *http.Request, id int64) {
	if s.accountsOff(w) {
		return
	}
	me, _ := userFrom(r.Context())
	if err := s.opt.Accounts.DeleteAdmin(domain.System(r.Context()), me, id); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) billingError(w http.ResponseWriter, r *http.Request, err error) {
	var be *billing.Error
	switch {
	case errors.As(err, &be) && be.Payment:
		writeError(w, http.StatusPaymentRequired, "payment_required", be.Msg)
	case errors.As(err, &be):
		writeError(w, http.StatusBadRequest, "bad_request", be.Msg)
	case errors.Is(err, billing.ErrProviderOff):
		writeError(w, http.StatusNotImplemented, "unsupported", err.Error())
	default:
		s.authError(w, r, err)
	}
}

func toBilling(v billing.View) gen.Billing {
	out := gen.Billing{Plan: v.Plan, Slots: v.Slots, MaxSlots: v.MaxSlots, MemberLimit: v.MemberLimit, Members: v.Members,
		CreditsBalance: v.Balance, TrialEndsAt: v.TrialEndsAt, PaymentsEnabled: v.PaymentsEnabled, Ledger: []gen.LedgerEntry{}}
	if v.MonthlyUZS > 0 {
		m := v.MonthlyUZS
		out.MonthlyUzs = &m
	}
	if v.MonthlyUSD > 0 {
		m := v.MonthlyUSD
		out.MonthlyUsd = &m
	}
	self := v.SelfHosted
	out.SelfHosted = &self
	out.Prices.WorkspaceUzs, out.Prices.SlotUzs, out.Prices.MemberUzs, out.Prices.CreditUzs = v.Prices.WorkspaceUZS, v.Prices.SlotUZS, v.Prices.MemberUZS, v.Prices.CreditUZS
	out.Prices.WorkspaceUsd, out.Prices.SlotUsd, out.Prices.MemberUsd, out.Prices.CreditUsd = v.Prices.WorkspaceUSD, v.Prices.SlotUSD, v.Prices.MemberUSD, v.Prices.CreditUSD
	out.Prices.IncludedMembers, out.Prices.Markup = v.Prices.IncludedMembers, float32(v.Prices.Markup)
	for _, e := range v.Ledger {
		g := gen.LedgerEntry{Id: e.ID, Amount: e.Amount, Reason: gen.LedgerEntryReason(e.Reason), CreatedAt: e.CreatedAt}
		if e.TicketKey != "" {
			k := e.TicketKey
			g.TicketKey = &k
		}
		if e.Note != "" {
			n := e.Note
			g.Note = &n
		}
		out.Ledger = append(out.Ledger, g)
	}
	return out
}

// GetBilling implements gen.ServerInterface.
func (s *Server) GetBilling(w http.ResponseWriter, r *http.Request) {
	if s.opt.Billing == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "billing is not available")
		return
	}
	m, _ := memberFrom(r.Context())
	v, err := s.opt.Billing.View(r.Context(), m.w.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toBilling(v))
}

// SetSlots implements gen.ServerInterface.
func (s *Server) SetSlots(w http.ResponseWriter, r *http.Request) {
	if s.opt.Billing == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "billing is not available")
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.SetSlotsJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Billing.SetSlots(r.Context(), m.w.ID, req.Slots, u.ID)
	if err != nil {
		s.billingError(w, r, err)
		return
	}
	if s.opt.Queue != nil {
		s.opt.Queue.ForgetWorkspace(m.w.ID)
	}
	writeJSON(w, http.StatusOK, toBilling(v))
}

// CheckoutCredits implements gen.ServerInterface.
func (s *Server) CheckoutCredits(w http.ResponseWriter, r *http.Request) {
	if s.opt.Billing == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "billing is not available")
		return
	}
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	var req gen.CheckoutCreditsJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	url, id, err := s.opt.Billing.Checkout(r.Context(), m.w.ID, u.ID, req.AmountUzs, string(req.Provider))
	if err != nil {
		s.billingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"url": url, "paymentId": id})
}
