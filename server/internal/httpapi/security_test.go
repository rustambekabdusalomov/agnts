package httpapi

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

type fakeSecurity struct {
	dismissed []int64
	fixed     []int64
	settings  domain.SecuritySettings
}

var secNow = time.Date(2026, 11, 4, 9, 0, 0, 0, time.UTC)

func secFinding() domain.SecurityFinding {
	return domain.SecurityFinding{ID: 7, RepoID: 1, RepoName: "api", Severity: domain.SecCritical, Category: "secret", Source: domain.SecFromSecret,
		Status: domain.SecOpen, Data: domain.SecFindingData{Title: "Stripe access token committed", Location: domain.SecLocation{File: "config/secrets.env", Line: 1},
			Confidence: domain.SecLikely, SecretMask: "sk_l************", SecretHash: "deadbeef"}, FirstSeen: secNow, LastSeen: secNow, LastChecked: secNow}
}

func (f *fakeSecurity) ScanRepository(_ context.Context, repo int64, _ domain.Origin, _ *int64) (domain.SecurityScan, bool, error) {
	if repo != 1 {
		return domain.SecurityScan{}, false, domain.ErrNotFound
	}
	return domain.SecurityScan{ID: 3, RepoID: 1, RepoName: "api", Trigger: domain.SecManual, Status: domain.ScanPending, CreatedAt: secNow}, true, nil
}

func (f *fakeSecurity) CancelScan(context.Context, int64) (domain.SecurityScan, error) {
	return domain.SecurityScan{}, domain.ErrConflict
}

func (f *fakeSecurity) CreateSecurityTicket(_ context.Context, in orchestrator.SecurityFixInput, _ domain.Origin) (domain.Ticket, error) {
	f.fixed = in.FindingIDs
	return domain.Ticket{Key: "SEC-1", Source: domain.SourceSecurity, Title: "Fix it", State: domain.StateNew, Kind: domain.KindCode}, nil
}

func (f *fakeSecurity) DismissFindings(_ context.Context, ids []int64, reason, _ string, _ *int64, _ domain.Origin) ([]domain.SecurityFinding, error) {
	f.dismissed = ids
	x := secFinding()
	x.Status, x.DismissReason = domain.SecDismissed, reason
	return []domain.SecurityFinding{x}, nil
}

func (f *fakeSecurity) ReopenFinding(context.Context, int64, domain.Origin) (domain.SecurityFinding, error) {
	return secFinding(), nil
}

func (f *fakeSecurity) SecurityScan(_ context.Context, id int64) (domain.SecurityScan, error) {
	return domain.SecurityScan{ID: id, RepoID: 1, RepoName: "api", Status: domain.ScanDone, CreatedAt: secNow,
		Ran:      domain.SecRan{Tools: map[string]domain.SecToolRun{domain.ToolOpengrep: {Status: "ok", Hits: 2}}, Agent: domain.SecAgentDone, History: 200, Commits: 900},
		Counts:   domain.SecCounts{New: 2, Open: map[domain.SecSeverity]int{domain.SecCritical: 1}},
		Rejected: []domain.SecRejected{{Hit: "h3", Tool: "gitleaks", File: "docs/x.md", Reason: "example"}}}, nil
}

func (f *fakeSecurity) SecurityScans(context.Context, int64, int) ([]domain.SecurityScan, error) {
	return nil, nil
}

func (f *fakeSecurity) SecurityFindings(context.Context, domain.SecFindingFilter) ([]domain.SecurityFinding, error) {
	return []domain.SecurityFinding{secFinding()}, nil
}

func (f *fakeSecurity) SecurityFinding(_ context.Context, id int64) (domain.SecurityFinding, error) {
	if id != 7 {
		return domain.SecurityFinding{}, domain.ErrNotFound
	}
	return secFinding(), nil
}

func (f *fakeSecurity) FindingsByTicket(context.Context, string) ([]domain.SecurityFinding, error) {
	return nil, nil
}

func (f *fakeSecurity) SecuritySummaries(context.Context) ([]postgres.SecuritySummary, error) {
	id := int64(3)
	return []postgres.SecuritySummary{{RepoID: 1, RepoName: "api", Open: map[domain.SecSeverity]int{domain.SecCritical: 1}, LastScanID: &id}}, nil
}

func TestSecurityAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)

	rec := h.do("GET", "/api/w/acme/security/findings?active=true", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"secretMask":"sk_l************"`) {
		t.Fatalf("findings: %d %s", rec.Code, rec.Body)
	}
	if strings.Contains(rec.Body.String(), "deadbeef") {
		t.Fatal("the secret's hash left the server")
	}
	if rec := h.do("GET", "/api/w/acme/security/findings/8", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("missing finding: %d", rec.Code)
	}
	rec = h.do("GET", "/api/w/acme/security/summary", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"critical":1`) || !strings.Contains(rec.Body.String(), `"lastScan":{`) {
		t.Fatalf("summary: %d %s", rec.Code, rec.Body)
	}
	rec = h.do("GET", "/api/w/acme/security/scans/3", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"rejected":[{`) || !strings.Contains(rec.Body.String(), `"tools":[{`) {
		t.Fatalf("scan: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/repos/1/security/scans", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"queued":true`) {
		t.Fatalf("start: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("DELETE", "/api/w/acme/security/scans/3", "", cookie); rec.Code != http.StatusConflict {
		t.Fatalf("cancel a finished scan: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/w/acme/security/fix", `{"findingIds":[7]}`, cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"key":"SEC-1"`) {
		t.Fatalf("fix: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/security/dismiss", `{"findingIds":[7],"reason":"maybe"}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("dismiss with a bad reason: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/w/acme/security/dismiss", `{"findingIds":[7],"reason":"accepted_risk"}`, cookie); rec.Code != http.StatusOK || len(h.security.dismissed) != 1 {
		t.Fatalf("dismiss: %d %s", rec.Code, rec.Body)
	}

	// A member may fix but not dismiss; a viewer may only read.
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleUser
	if rec := h.do("POST", "/api/w/acme/security/dismiss", `{"findingIds":[7],"reason":"accepted_risk"}`, cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("a member dismissed: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/w/acme/security/findings/7/reopen", "", cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("a member reopened: %d", rec.Code)
	}
	if rec := h.do("POST", "/api/w/acme/security/fix", `{"findingIds":[7]}`, cookie); rec.Code != http.StatusOK {
		t.Fatalf("a member could not fix: %d", rec.Code)
	}
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleViewer
	if rec := h.do("POST", "/api/w/acme/repos/1/security/scans", "", cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("a viewer started a scan: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/w/acme/security/findings", "", cookie); rec.Code != http.StatusOK {
		t.Fatalf("a viewer could not read: %d", rec.Code)
	}
}

func (f *fakeSecurity) SetSecuritySettings(_ context.Context, _ int64, set domain.SecuritySettings, _ domain.Origin) (domain.SecuritySettings, error) {
	if err := set.Normalize(); err != nil {
		return set, fmt.Errorf("%w: %v", orchestrator.ErrInvalid, err)
	}
	f.settings = set
	return set, nil
}

func (f *fakeSecurity) SecuritySettings(context.Context, int64) (domain.SecuritySettings, error) {
	return f.settings, nil
}

func TestSecuritySettingsAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	rec := h.do("PUT", "/api/w/acme/repos/1/security/settings", `{"schedule":"weekly","exclude":["testdata/**"],"minNotify":"medium"}`, cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"nextAt":"`) || h.security.settings.Schedule != "weekly" {
		t.Fatalf("save: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/repos/1/security/settings", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"minNotify":"medium"`) {
		t.Fatalf("get: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("PUT", "/api/w/acme/repos/1/security/settings", `{"schedule":"daily","exclude":["../x"],"minNotify":"high"}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad exclusion: %d", rec.Code)
	}
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleUser
	if rec := h.do("PUT", "/api/w/acme/repos/1/security/settings", `{"schedule":"off","exclude":[],"minNotify":"high"}`, cookie); rec.Code != http.StatusForbidden {
		t.Fatalf("a member changed settings: %d", rec.Code)
	}
}
