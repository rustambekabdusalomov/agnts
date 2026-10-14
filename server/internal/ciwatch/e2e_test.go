package ciwatch

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
	"agnts/internal/vcs"
	"agnts/internal/vcs/github"
)

// fakeGitHub serves the Actions endpoints CI watching reads: one run whose
// "test" job fails with testFail, and the re-run endpoint.
type fakeGitHub struct {
	mu     sync.Mutex
	reruns int
}

func (g *fakeGitHub) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	g.mu.Lock()
	defer g.mu.Unlock()
	switch {
	case r.Method == http.MethodGet && strings.HasSuffix(r.URL.Path, "/actions/runs/5/jobs"):
		_, _ = io.WriteString(w, `{"jobs":[
			{"id":51,"name":"test","conclusion":"failure","html_url":"https://github.com/acme/api/actions/runs/5/job/51",
			 "steps":[{"name":"Checkout","conclusion":"success"},{"name":"go test","conclusion":"failure"}]},
			{"id":52,"name":"lint","conclusion":"success"}]}`)
	case r.Method == http.MethodGet && strings.HasSuffix(r.URL.Path, "/check-runs/51/annotations"):
		_, _ = io.WriteString(w, `[{"path":"billing/billing_test.go","start_line":42,"annotation_level":"failure","message":"expected 90, got 100"}]`)
	case r.Method == http.MethodGet && strings.HasSuffix(r.URL.Path, "/actions/jobs/51/logs"):
		_, _ = io.WriteString(w, "2026-10-12T09:14:02.1Z ##[group]Run go test ./...\n2026-10-12T09:14:03.1Z token ghp_abcdefghijklmnopqrstuvwxyz0123456789\n"+testFail+"\n")
	case r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/actions/runs/5/rerun-failed-jobs"):
		g.reruns++
		w.WriteHeader(http.StatusCreated)
	default:
		http.NotFound(w, r)
	}
}

type e2eSink struct{ svc *Service }

func (e2eSink) MarkMerged(context.Context, domain.PRRef, domain.Origin) (bool, error) {
	return false, nil
}
func (s e2eSink) CIRunFinished(ctx context.Context, r domain.CIRun) error {
	return s.svc.CIRunFinished(ctx, r)
}

const runPayload = `{"action":"completed","workflow_run":{"id":5,"name":"CI","path":".github/workflows/ci.yml","head_branch":"main",
	"head_sha":"aaaaaaa1","event":"push","status":"completed","conclusion":"%s","run_attempt":%d,
	"html_url":"https://github.com/acme/api/actions/runs/5","updated_at":"2026-10-12T09:%02d:00Z",
	"head_commit":{"message":"Change coupons","author":{"name":"Ann"}},"head_repository":{"full_name":"acme/api"}},
	"repository":{"full_name":"acme/api"}}`

// TestEndToEnd sends signed workflow_run webhooks through the real
// handler, GitHub adapter and Postgres store: a failure is triaged,
// re-run, confirmed by the failing re-run and handed to the ticket maker.
func TestEndToEnd(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `TRUNCATE ci_failures, ci_watches`)
	ctx, _ := pgtest.Workspace(t, pool, "ci-e2e")
	store := postgres.NewAgent(pool)
	repo, err := store.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github",
		CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	box, _ := secret.NewBox(make([]byte, 32))
	ci := postgres.NewCI(pool, box)
	if _, err := ci.SaveCIWatch(ctx, domain.CIWatch{RepoID: repo.ID, Enabled: true, Ignore: domain.DefaultCIIgnore, PRs: domain.CIPROff}); err != nil {
		t.Fatal(err)
	}

	gh := &fakeGitHub{}
	api := httptest.NewServer(gh)
	defer api.Close()
	host := github.New(api.URL, func(context.Context) (string, error) { return "tok", nil })
	work := &fakeWork{}
	st := domain.DefaultSettings()
	st.CI.AutoFix = true
	svc := New(ci, store, work, vcs.NewMulti(map[string]vcs.Provider{"github": host}), nil, fakeSettings{st},
		slog.New(slog.NewTextHandler(io.Discard, nil)))
	svc.async = func(f func()) { f() }
	hook := vcs.GitHubWebhook(func(context.Context) string { return "s3cret" }, e2eSink{svc}, store, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))

	deliveries := 0
	post := func(body string) {
		deliveries++
		m := hmac.New(sha256.New, []byte("s3cret"))
		m.Write([]byte(body))
		req := httptest.NewRequest(http.MethodPost, "/webhooks/github", strings.NewReader(body)).WithContext(ctx)
		req.Header.Set("X-Hub-Signature-256", "sha256="+hex.EncodeToString(m.Sum(nil)))
		req.Header.Set("X-GitHub-Delivery", fmt.Sprintf("d%d", deliveries))
		req.Header.Set("X-GitHub-Event", "workflow_run")
		rec := httptest.NewRecorder()
		hook.ServeHTTP(rec, req)
		if rec.Code != http.StatusNoContent {
			t.Fatalf("webhook answered %d", rec.Code)
		}
	}

	// 1. The run fails: one group in triage, the failed jobs re-run.
	post(fmt.Sprintf(runPayload, "failure", 1, 15))
	groups, err := ci.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID})
	if err != nil || len(groups) != 1 {
		t.Fatalf("groups %+v %v", groups, err)
	}
	g := groups[0]
	if g.Status != domain.CITriage || g.Job != "test" || g.Workflow != "ci.yml" || g.Title != "TestApplyCoupon: billing_test.go:42: expected 90, got 100" {
		t.Fatalf("group %+v", g)
	}
	if gh.reruns != 1 || len(work.created) != 0 {
		t.Fatalf("reruns %d, tickets %d", gh.reruns, len(work.created))
	}
	full, err := ci.CIFailure(ctx, g.ID)
	if err != nil || !strings.Contains(full.Sample, "billing/billing_test.go:42: expected 90, got 100") || strings.Contains(full.Sample, "ghp_abc") {
		t.Fatalf("sample (annotations, redaction):\n%s", full.Sample)
	}

	// 2. The re-run fails too: confirmed, a ticket is opened, and the
	// group waits on it.
	post(fmt.Sprintf(runPayload, "failure", 2, 20))
	g, _ = ci.CIFailure(ctx, g.ID)
	if g.Status != domain.CIFixing || g.TicketKey == "" || len(work.created) != 1 || g.Count != 1 {
		t.Fatalf("after the re-run: %+v, tickets %d", g, len(work.created))
	}
	if in := work.created[0]; in.RepoID != repo.ID || !strings.Contains(in.Description, "Failing since commit aaaaaaa") {
		t.Fatalf("ticket input %+v", in)
	}
	var announced int
	_ = pool.QueryRow(ctx, `SELECT count(*) FROM events WHERE type = 'ci_failure'`).Scan(&announced)
	if announced != 1 {
		t.Fatalf("announced %d times", announced)
	}

	// 3. The fix is merged, and the next run is green: resolved.
	svc.TicketMerged(ctx, domain.Ticket{Key: g.TicketKey, Source: domain.SourceCI, HeadSHA: "fffffff9"})
	post(strings.Replace(fmt.Sprintf(runPayload, "success", 1, 40), `"id":5,`, `"id":6,`, 1))
	g, _ = ci.CIFailure(ctx, g.ID)
	if g.Status != domain.CIResolved || g.FixedSHA != "fffffff9" {
		t.Fatalf("after green: %+v", g)
	}
}
