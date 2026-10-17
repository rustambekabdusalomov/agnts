package httpapi

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

type fakeRunHistory struct {
	mu        sync.Mutex
	list      []domain.Transcript
	bodies    map[int64][]byte
	prompts   map[int64][]byte
	audit     []domain.AdminAudit
	auditFail bool
	lastF     domain.TranscriptFilter
	set       domain.RunHistorySettings
}

func newFakeRunHistory() *fakeRunHistory {
	return &fakeRunHistory{bodies: map[int64][]byte{}, prompts: map[int64][]byte{}, set: domain.DefaultRunHistory}
}

func (f *fakeRunHistory) ListTranscripts(_ context.Context, fl domain.TranscriptFilter) ([]domain.Transcript, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.lastF = fl
	out := []domain.Transcript{}
	for _, t := range f.list {
		if fl.BeforeID > 0 && t.ID >= fl.BeforeID {
			continue
		}
		out = append(out, t)
		if len(out) == fl.Limit {
			break
		}
	}
	return out, nil
}

func (f *fakeRunHistory) TranscriptSummary(context.Context, domain.TranscriptFilter) (domain.TranscriptSummary, error) {
	return domain.TranscriptSummary{Count: len(f.list), CostUSD: 1.5, BackgroundCost: 0.5, P50: 2 * time.Second}, nil
}

func (f *fakeRunHistory) Transcript(_ context.Context, id int64) (domain.Transcript, error) {
	for _, t := range f.list {
		if t.ID == id {
			return t, nil
		}
	}
	return domain.Transcript{}, domain.ErrNotFound
}

func (f *fakeRunHistory) RunTranscripts(_ context.Context, runID int64) ([]domain.Transcript, error) {
	var out []domain.Transcript
	for _, t := range f.list {
		if t.RunID != nil && *t.RunID == runID {
			out = append(out, t)
		}
	}
	return out, nil
}

func (f *fakeRunHistory) TranscriptBody(_ context.Context, id int64) ([]byte, error) {
	return f.bodies[id], nil
}

func (f *fakeRunHistory) TranscriptPrompt(_ context.Context, id int64) ([]byte, error) {
	return f.prompts[id], nil
}

func (f *fakeRunHistory) Audit(_ context.Context, a domain.AdminAudit) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.auditFail {
		return errors.New("database down")
	}
	f.audit = append(f.audit, a)
	return nil
}

func (f *fakeRunHistory) ListAudit(context.Context, postgres.AuditFilter) ([]domain.AdminAudit, error) {
	return f.audit, nil
}

func (f *fakeRunHistory) RunHistorySettings(context.Context) (domain.RunHistorySettings, error) {
	return f.set, nil
}

func (f *fakeRunHistory) SetRunHistorySettings(_ context.Context, v domain.RunHistorySettings) (domain.RunHistorySettings, error) {
	f.set = v.Normalize()
	return f.set, nil
}

func gzipped(s string) []byte {
	var b bytes.Buffer
	w := gzip.NewWriter(&b)
	_, _ = w.Write([]byte(s))
	_ = w.Close()
	return b.Bytes()
}

// Every run history route is the operator console's: the middleware
// refuses them to anyone without the Admin role.
func TestRunHistoryRoutesAreAdminOnly(t *testing.T) {
	ops, err := operations()
	if err != nil {
		t.Fatal(err)
	}
	for _, op := range []string{"GET /api/platform/runs", "GET /api/platform/runs/summary", "GET /api/platform/runs/{id}",
		"GET /api/platform/runs/{id}/prompt", "GET /api/platform/runs/{id}/download", "GET /api/platform/audit",
		"GET /api/platform/settings/run-history", "PUT /api/platform/settings/run-history"} {
		if o, ok := ops[op]; !ok || o.scope != "admin" {
			t.Errorf("%s: %+v (in spec %v)", op, o, ok)
		}
	}
	h := newHarness(t, pinger{})
	if rec := h.do("GET", "/api/platform/runs", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("signed out: %d", rec.Code)
	}
}

func TestRunHistoryRoutes(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	run := int64(9)
	started := time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC)
	for i := int64(3); i >= 1; i-- {
		h.runs.list = append(h.runs.list, domain.Transcript{ID: i, WorkspaceID: 4, WorkspaceName: "Iman", RunID: &run, TicketKey: "API-70",
			Purpose: "code", Engine: "claude", Model: "opus", StartedAt: started.Add(time.Duration(i) * time.Minute), Status: domain.TranscriptDone})
	}
	h.runs.bodies[3] = append(gzipped(`{"k":"text","t":1,"text":"hi"}`+"\n"), gzipped(`{"k":"result","t":9,"subtype":"success"}`+"\n")...)
	h.runs.prompts[3] = gzipped("Fix API-70")

	// The list: metadata only, paged, filters passed on.
	rec := h.do("GET", "/api/platform/runs?limit=2&purpose=code&stalled=true&minCost=0.5&ticket=API", "", cookie)
	var page struct {
		Items      []map[string]any
		NextCursor string
	}
	if rec.Code != http.StatusOK || json.Unmarshal(rec.Body.Bytes(), &page) != nil || len(page.Items) != 2 || page.NextCursor == "" {
		t.Fatalf("list: %d %s", rec.Code, rec.Body)
	}
	if f := h.runs.lastF; f.Purpose != "code" || !f.Stalled || f.MinCost != 0.5 || f.TicketKey != "API" {
		t.Fatalf("filter %+v", f)
	}
	if strings.Contains(rec.Body.String(), "Fix API-70") || strings.Contains(rec.Body.String(), `"events"`) || len(h.runs.audit) != 0 {
		t.Fatalf("the list served content or was audited: %s", rec.Body)
	}
	rec = h.do("GET", "/api/platform/runs?limit=2&cursor="+page.NextCursor, "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"id":1`) || strings.Contains(rec.Body.String(), "nextCursor") {
		t.Fatalf("page 2: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/platform/runs?cursor=nope", "", cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad cursor: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/platform/runs/summary", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"p50Ms":2000`) {
		t.Fatalf("summary: %d %s", rec.Code, rec.Body)
	}

	// Reading content writes one audit row per read, first.
	rec = h.do("GET", "/api/platform/runs/3", "", cookie)
	var detail struct {
		Events   []map[string]any
		Siblings []map[string]any
	}
	if rec.Code != http.StatusOK || json.Unmarshal(rec.Body.Bytes(), &detail) != nil || len(detail.Events) != 2 || len(detail.Siblings) != 2 {
		t.Fatalf("detail: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/platform/runs/3/prompt", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), "Fix API-70") {
		t.Fatalf("prompt: %d %s", rec.Code, rec.Body)
	}
	rec = h.do("GET", "/api/platform/runs/3/download", "", cookie)
	if rec.Code != http.StatusOK || rec.Header().Get("Content-Type") != "application/x-ndjson" || strings.Count(rec.Body.String(), "\n") != 2 {
		t.Fatalf("download: %d %q", rec.Code, rec.Body)
	}
	if len(h.runs.audit) != 3 {
		t.Fatalf("audit rows %+v", h.runs.audit)
	}
	a := h.runs.audit[0]
	if a.Action != domain.AuditTranscriptView || a.Target != "transcript:3" || *a.WorkspaceID != 4 || a.AdminName != "rustam" || a.IP != "203.0.113.7" {
		t.Fatalf("audit row %+v", a)
	}
	if rec := h.do("GET", "/api/platform/runs/99", "", cookie); rec.Code != http.StatusNotFound || len(h.runs.audit) != 3 {
		t.Fatalf("unknown: %d", rec.Code)
	}

	// No audit row, no content.
	h.runs.auditFail = true
	for _, p := range []string{"/api/platform/runs/3", "/api/platform/runs/3/prompt", "/api/platform/runs/3/download"} {
		if rec := h.do("GET", p, "", cookie); rec.Code != http.StatusInternalServerError || strings.Contains(rec.Body.String(), "hi") ||
			strings.Contains(rec.Body.String(), "Fix API") {
			t.Errorf("%s with the audit log down: %d %s", p, rec.Code, rec.Body)
		}
	}
	h.runs.auditFail = false

	// Settings: validated, and the change is audited.
	if rec := h.do("PUT", "/api/platform/settings/run-history", `{"retentionDays":-1,"toolOutputKB":16,"textKB":32,"transcriptMB":8}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad settings: %d", rec.Code)
	}
	rec = h.do("PUT", "/api/platform/settings/run-history", `{"retentionDays":90,"toolOutputKB":32,"textKB":32,"transcriptMB":16}`, cookie)
	if rec.Code != http.StatusOK || h.runs.set.RetentionDays != 90 || h.runs.audit[len(h.runs.audit)-1].Action != domain.AuditRunHistorySettings {
		t.Fatalf("settings: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/platform/audit", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), "transcript:3") {
		t.Fatalf("audit list: %d %s", rec.Code, rec.Body)
	}
}

func TestTranscriptLinesKeepsWhatItCanRead(t *testing.T) {
	body := append(gzipped(`{"k":"text","t":1}`+"\n"), gzipped(`{"k":"text","t":2}`+"\n")...)
	cut := body[:len(body)-6] // the last member cut off mid-write
	lines, bad := transcriptLines(cut)
	if !bad || len(lines) < 1 {
		t.Fatalf("cut body: %d lines, bad %v", len(lines), bad)
	}
	if lines, bad := transcriptLines(nil); bad || len(lines) != 0 {
		t.Fatal("empty body")
	}
}
