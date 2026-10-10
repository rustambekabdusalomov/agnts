package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
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

func (f *fakeWorkspaces) Default(ctx context.Context) (domain.Workspace, error) {
	return f.ByID(ctx, 1)
}

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

func (f *fakeWorkspaces) Memberships(context.Context) ([]domain.Member, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []domain.Member
	for k, role := range f.roles {
		out = append(out, domain.Member{WorkspaceID: k[0], UserID: k[1], Role: role})
	}
	return out, nil
}

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

func TestPlatformUsers(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	rec := h.do("GET", "/api/platform/users", "", cookie)
	if rec.Code != http.StatusOK {
		t.Fatalf("list: %d %s", rec.Code, rec.Body)
	}
	var got []gen.PlatformUser
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 {
		t.Fatalf("users %+v", got)
	}
	u := got[0]
	if u.User.Username != "rustam" || !u.HasPassword || u.LastSignInAt == nil {
		t.Fatalf("user %+v", u)
	}
	// Only their own workspace, with their role in it.
	if len(u.Workspaces) != 1 || u.Workspaces[0].Slug != "acme" || u.Workspaces[0].Role != gen.WorkspaceRoleOwner {
		t.Fatalf("workspaces %+v", u.Workspaces)
	}
}

// fakeFeedback is an in-memory FeedbackStore.
type fakeFeedback struct {
	mu   sync.Mutex
	list []postgres.Feedback
}

func (f *fakeFeedback) Create(_ context.Context, x postgres.Feedback) (postgres.Feedback, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	x.ID, x.Status = int64(len(f.list)+1), "new"
	if x.WorkspaceID != nil {
		x.Workspace = "Acme"
	}
	f.list = append(f.list, x)
	return x, nil
}

func (f *fakeFeedback) List(context.Context) ([]postgres.Feedback, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]postgres.Feedback(nil), f.list...), nil
}

func (f *fakeFeedback) SetStatus(_ context.Context, id int64, status string) (postgres.Feedback, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for i := range f.list {
		if f.list[i].ID == id {
			f.list[i].Status = status
			return f.list[i], nil
		}
	}
	return postgres.Feedback{}, domain.ErrNotFound
}

func TestFeedbackRoutes(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	send := func(body string) *httptest.ResponseRecorder { return h.do("POST", "/api/feedback", body, cookie) }

	rec := send(`{"title":"Love it","description":"More languages please","workspace":"acme"}`)
	var got gen.Feedback
	if rec.Code != http.StatusCreated || json.Unmarshal(rec.Body.Bytes(), &got) != nil || got.Status != gen.FeedbackStatusNew || got.Workspace == nil || got.Sender != "rustam" {
		t.Fatalf("send: %d %s", rec.Code, rec.Body)
	}
	// Another's workspace is not recorded as context.
	if rec := send(`{"title":"Hm","description":"x","workspace":"other"}`); rec.Code != http.StatusCreated || strings.Contains(rec.Body.String(), `"workspace"`) {
		t.Fatalf("someone else's workspace: %d %s", rec.Code, rec.Body)
	}
	for _, bad := range []string{`{"title":" ","description":"x"}`, `{"title":"x","description":""}`, `{"title":"` + strings.Repeat("a", 121) + `","description":"x"}`} {
		if rec := send(bad); rec.Code != http.StatusBadRequest {
			t.Errorf("%s: %d", bad[:20], rec.Code)
		}
	}
	// Signed out: no.
	if rec := h.do("POST", "/api/feedback", `{"title":"x","description":"y"}`, nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("signed out: %d", rec.Code)
	}

	// The Admin reads it and marks it done.
	rec = h.do("GET", "/api/platform/feedback", "", cookie)
	var list []gen.Feedback
	if rec.Code != http.StatusOK || json.Unmarshal(rec.Body.Bytes(), &list) != nil || len(list) != 2 {
		t.Fatalf("list: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("PUT", "/api/platform/feedback/1", `{"status":"done"}`, cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"status":"done"`) {
		t.Fatalf("done: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("PUT", "/api/platform/feedback/1", `{"status":"maybe"}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad status: %d", rec.Code)
	}
	if rec := h.do("PUT", "/api/platform/feedback/99", `{"status":"done"}`, cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown: %d", rec.Code)
	}
}

func TestConnectorRequest(t *testing.T) {
	h := newHarness(t, pinger{})
	const site = "https://agnts.example.org"
	// Each send comes from its own address, under the rate limit.
	n := 0
	send := func(origin, body string) *httptest.ResponseRecorder {
		n++
		return h.do("POST", "/site/connector-request", body, map[string]string{"Origin": origin, "X-Forwarded-For": fmt.Sprintf("198.51.100.%d", n)})
	}

	// The browser asks first; only the website's origin is answered.
	rec := h.do("OPTIONS", "/site/connector-request", "", map[string]string{"Origin": site, "Access-Control-Request-Method": "POST"})
	if rec.Code != http.StatusNoContent || rec.Header().Get("Access-Control-Allow-Origin") != site || rec.Header().Get("Access-Control-Allow-Headers") != "Content-Type" {
		t.Fatalf("preflight: %d %v", rec.Code, rec.Header())
	}
	if rec := h.do("OPTIONS", "/site/connector-request", "", map[string]string{"Origin": "https://evil.example"}); rec.Code != http.StatusForbidden || rec.Header().Get("Access-Control-Allow-Origin") != "" {
		t.Fatalf("preflight from elsewhere: %d", rec.Code)
	}

	ok := `{"tool":"Linear","link":"https://linear.app","hosting":"cloud","usage":"Issues for 3 teams","name":"Dilnoza","email":"dilnoza@example.com"}`
	if rec := send(site, ok); rec.Code != http.StatusCreated || rec.Header().Get("Access-Control-Allow-Origin") != site {
		t.Fatalf("send: %d %s", rec.Code, rec.Body)
	}
	if rec := send("https://evil.example", ok); rec.Code != http.StatusForbidden {
		t.Fatalf("from another site: %d", rec.Code)
	}
	if rec := send("", ok); rec.Code != http.StatusForbidden {
		t.Fatalf("without an origin: %d", rec.Code)
	}
	for _, bad := range []string{
		`{"tool":" ","email":"a@example.com"}`,
		`{"tool":"` + strings.Repeat("a", 81) + `","email":"a@example.com"}`,
		`{"tool":"Trello","email":"not an email"}`,
		`{"tool":"Trello","email":"Bob <bob@example.com>"}`,
		`{"tool":"Trello","email":"a@example.com","hosting":"moon"}`,
		`not json`,
	} {
		if rec := send(site, bad); rec.Code != http.StatusBadRequest {
			t.Errorf("%s: %d", bad, rec.Code)
		}
	}

	// One address may send only a few.
	limited := 0
	for range 7 {
		if h.do("POST", "/site/connector-request", ok, map[string]string{"Origin": site, "X-Forwarded-For": "192.0.2.9"}).Code == http.StatusTooManyRequests {
			limited++
		}
	}
	if limited == 0 {
		t.Fatal("no rate limit")
	}

	// A bot that fills in the hidden field hears "ok", and nothing is kept.
	if rec := send(site, `{"tool":"Spam","email":"bot@example.com","website":"http://spam"}`); rec.Code != http.StatusCreated {
		t.Fatalf("honeypot: %d", rec.Code)
	}

	rec = h.do("GET", "/api/platform/feedback", "", h.signIn(t))
	var list []gen.Feedback
	if rec.Code != http.StatusOK || json.Unmarshal(rec.Body.Bytes(), &list) != nil || len(list) != 1+(7-limited) {
		t.Fatalf("list: %d %s", rec.Code, rec.Body)
	}
	for _, f := range list {
		if f.Title == "Connector: Spam" {
			t.Fatal("the honeypot was kept")
		}
	}
	got := list[0]
	if got.Kind != gen.FeedbackKindConnector || got.Title != "Connector: Linear" || got.Sender != "Dilnoza" || got.UserId != nil ||
		got.Email == nil || *got.Email != "dilnoza@example.com" ||
		got.Description != "Link: https://linear.app\nHosting: cloud\nHow they use it: Issues for 3 teams" {
		t.Fatalf("kept: %+v", got)
	}
}
