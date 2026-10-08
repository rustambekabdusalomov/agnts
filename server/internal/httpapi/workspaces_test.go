package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// fakeWorkspaces is an in-memory WorkspaceStore: "acme" (1), whose owner
// is user 1, and "other" (2), owned by user 99.
type fakeWorkspaces struct {
	mu    sync.Mutex
	ws    map[int64]domain.Workspace
	roles map[[2]int64]domain.WorkspaceRole
	last  map[int64]int64
}

func newFakeWorkspaces() *fakeWorkspaces {
	return &fakeWorkspaces{
		ws: map[int64]domain.Workspace{
			1: {ID: 1, Slug: "acme", Name: "Acme", OwnerID: 1, Slots: 1, HookID: "hook-acme", ClaudeMode: domain.ClaudeShared},
			2: {ID: 2, Slug: "other", Name: "Other", OwnerID: 99, Slots: 1, HookID: "hook-other", ClaudeMode: domain.ClaudeShared},
		},
		roles: map[[2]int64]domain.WorkspaceRole{{1, 1}: domain.RoleOwner, {2, 99}: domain.RoleOwner},
		last:  map[int64]int64{},
	}
}

func (f *fakeWorkspaces) BySlug(_ context.Context, slug string) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, w := range f.ws {
		if w.Slug == slug {
			return w, nil
		}
	}
	return domain.Workspace{}, domain.ErrNotFound
}

func (f *fakeWorkspaces) ByID(_ context.Context, id int64) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if w, ok := f.ws[id]; ok {
		return w, nil
	}
	return domain.Workspace{}, domain.ErrNotFound
}

func (f *fakeWorkspaces) ByHookID(_ context.Context, hook string) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, w := range f.ws {
		if w.HookID == hook {
			return w, nil
		}
	}
	return domain.Workspace{}, domain.ErrNotFound
}

func (f *fakeWorkspaces) Default(ctx context.Context) (domain.Workspace, error) { return f.ByID(ctx, 1) }

func (f *fakeWorkspaces) Role(_ context.Context, ws, user int64) (domain.WorkspaceRole, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if r, ok := f.roles[[2]int64{ws, user}]; ok {
		return r, nil
	}
	return "", domain.ErrNotFound
}

func (f *fakeWorkspaces) Of(_ context.Context, user int64) ([]domain.WorkspaceMembership, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []domain.WorkspaceMembership
	for k, r := range f.roles {
		if k[1] == user {
			out = append(out, domain.WorkspaceMembership{Workspace: f.ws[k[0]], Role: r, Members: 1})
		}
	}
	return out, nil
}

func (f *fakeWorkspaces) Members(_ context.Context, ws int64) ([]domain.Member, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []domain.Member
	for k, r := range f.roles {
		if k[0] == ws {
			out = append(out, domain.Member{WorkspaceID: ws, UserID: k[1], Username: "u" + string(rune('0'+k[1]%10)), Role: r})
		}
	}
	return out, nil
}

func (f *fakeWorkspaces) Invites(context.Context, int64) ([]domain.Invite, error) { return nil, nil }

func (f *fakeWorkspaces) Update(ctx context.Context, ws int64, u postgres.WorkspaceUpdate) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	w := f.ws[ws]
	if u.Name != nil {
		w.Name = *u.Name
	}
	if u.Slug != nil {
		w.Slug = *u.Slug
	}
	if u.ClaudeMode != nil {
		w.ClaudeMode = *u.ClaudeMode
	}
	f.ws[ws] = w
	return w, nil
}

func (f *fakeWorkspaces) SetLastWorkspace(_ context.Context, user, ws int64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.last[user] = ws
	return nil
}

func (f *fakeWorkspaces) RevokeInvite(context.Context, int64, int64) error { return domain.ErrNotFound }

func (f *fakeWorkspaces) List(context.Context, bool) ([]domain.WorkspaceMembership, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []domain.WorkspaceMembership
	for _, w := range f.ws {
		out = append(out, domain.WorkspaceMembership{Workspace: w})
	}
	return out, nil
}

func (f *fakeWorkspaces) SetPlan(ctx context.Context, ws int64, p postgres.PlanUpdate) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	w := f.ws[ws]
	if p.Slots != nil {
		w.Slots = *p.Slots
	}
	f.ws[ws] = w
	return w, nil
}

func (f *fakeWorkspaces) SetSuspended(_ context.Context, ws int64, s bool) (domain.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.ws[ws], nil
}

// signIn signs the harness user in on the web and returns the cookie.
func (h *harness) signIn(t *testing.T) map[string]string {
	t.Helper()
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("login: %d %s", rec.Code, rec.Body)
	}
	return map[string]string{"Cookie": SessionCookie + "=" + rec.Result().Cookies()[0].Value}
}

func TestWorkspaceRouting(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)

	// A workspace operation under the workspace's path acts in it.
	rec := h.do("GET", "/api/w/acme/tickets", "", cookie)
	if rec.Code != http.StatusOK || h.tickets.lastWS != 1 {
		t.Fatalf("/w/acme/tickets: %d (workspace %d) %s", rec.Code, h.tickets.lastWS, rec.Body)
	}
	// Without a path, the header's workspace or the last one opened.
	h.tickets.lastWS = 0
	if rec := h.do("GET", "/api/tickets", "", cookie); rec.Code != http.StatusOK || h.tickets.lastWS != 1 {
		t.Fatalf("/tickets: %d (workspace %d)", rec.Code, h.tickets.lastWS)
	}
	hdr := map[string]string{"Cookie": cookie["Cookie"], "X-Workspace": "acme"}
	if rec := h.do("GET", "/api/tickets", "", hdr); rec.Code != http.StatusOK {
		t.Fatalf("/tickets with header: %d", rec.Code)
	}
	// Someone else's workspace does not exist for this user.
	if rec := h.do("GET", "/api/w/other/tickets", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("another's workspace: %d", rec.Code)
	}
	hdr["X-Workspace"] = "other"
	if rec := h.do("GET", "/api/tickets", "", hdr); rec.Code != http.StatusNotFound {
		t.Fatalf("another's workspace by header: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/w/nope/tickets", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown workspace: %d", rec.Code)
	}
	// Account operations do not live under a workspace.
	if rec := h.do("GET", "/api/w/acme/auth/me", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("/w/acme/auth/me: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/w/acme/workspaces", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("/w/acme/workspaces: %d", rec.Code)
	}
	// Admin operations need the Admin role (the first user has it).
	if rec := h.do("GET", "/api/platform/workspaces", "", cookie); rec.Code != http.StatusOK {
		t.Fatalf("/platform/workspaces as Admin: %d %s", rec.Code, rec.Body)
	}

	// /auth/me lists the workspaces and the one opened last.
	rec = h.do("GET", "/api/auth/me", "", cookie)
	var me struct {
		IsAdmin       bool
		LastWorkspace string
		Workspaces    []struct{ Slug, Role string }
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &me); err != nil || !me.IsAdmin || me.LastWorkspace != "acme" ||
		len(me.Workspaces) != 1 || me.Workspaces[0].Role != "owner" {
		t.Fatalf("/auth/me: %s", rec.Body)
	}
}

func TestOwnerOnlyOperations(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	// As owner, settings can change.
	if rec := h.do("PUT", "/api/w/acme/workspace", `{"name":"Acme Inc"}`, cookie); rec.Code != http.StatusOK ||
		!strings.Contains(rec.Body.String(), `"name":"Acme Inc"`) {
		t.Fatalf("owner rename: %d %s", rec.Code, rec.Body)
	}
	// Demoted to a user, they cannot.
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleUser
	if rec := h.do("PUT", "/api/w/acme/workspace", `{"name":"Mine"}`, cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("user rename: %d", rec.Code)
	}
	if rec := h.do("PUT", "/api/w/acme/settings", `{}`, cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("user settings: %d", rec.Code)
	}
	// Reading and ticket work stay open to users.
	if rec := h.do("GET", "/api/w/acme/workspace", "", cookie); rec.Code != http.StatusOK ||
		!strings.Contains(rec.Body.String(), `"role":"user"`) {
		t.Fatalf("user reads the workspace: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/tickets", "", cookie); rec.Code != http.StatusOK {
		t.Fatalf("user lists tickets: %d", rec.Code)
	}
}

func TestWebhookWorkspace(t *testing.T) {
	h := newHarness(t, pinger{})
	if rec := h.do("POST", "/webhooks/test/hook-other", "{}", nil); rec.Code != http.StatusOK || h.hookWS != 2 {
		t.Fatalf("hook of other: %d workspace %d", rec.Code, h.hookWS)
	}
	if rec := h.do("POST", "/webhooks/test", "{}", nil); rec.Code != http.StatusOK || h.hookWS != 1 || h.hookID != "" {
		t.Fatalf("legacy hook: %d workspace %d", rec.Code, h.hookWS)
	}
	if rec := h.do("POST", "/webhooks/test/unknown", "{}", nil); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown hook: %d", rec.Code)
	}
}

func TestViewerReadsOnly(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleViewer
	for _, path := range []string{"/api/w/acme/tickets", "/api/w/acme/workspace"} {
		if rec := h.do("GET", path, "", cookie); rec.Code != http.StatusOK {
			t.Fatalf("viewer GET %s: %d %s", path, rec.Code, rec.Body)
		}
	}
	// Anything that changes the workspace is refused.
	for _, c := range []struct{ method, path, body string }{
		{"POST", "/api/w/acme/tasks", `{"title":"x","description":"y"}`},
		{"POST", "/api/w/acme/tickets/PAY-1/approve", `{}`},
		{"PUT", "/api/w/acme/tickets/PAY-1/answers", `{"answers":[]}`},
		{"PUT", "/api/w/acme/tickets/PAY-1/member", `{"userId":0}`},
		{"POST", "/api/w/acme/integrations/jira/sync", ``},
	} {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != http.StatusForbidden || !strings.Contains(rec.Body.String(), "viewers") {
			t.Fatalf("viewer %s %s: %d %s", c.method, c.path, rec.Code, rec.Body)
		}
	}
	// The few marked x-viewer stay open: reading a ticket in their language.
	if rec := h.do("POST", "/api/w/acme/tickets/PAY-1/translate", `{"lang":"ru"}`, cookie); rec.Code == http.StatusForbidden {
		t.Fatalf("viewer translate: %d %s", rec.Code, rec.Body)
	}
}
