package orchestrator_test

import (
	"encoding/json"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// The survey writes architecture.json with the brief, without files that
// do not exist; approving the brief approves it; runs get it; an import
// across layers is flagged, and a blocker where the repository says so;
// the reviewer is asked about new names; and a merged new pattern becomes
// a suggested rule.
func TestArchitectureFlow(t *testing.T) {
	h := newHarness(t)
	pool, err := postgres.Open(h.ctx, os.Getenv("AGNTS_TEST_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if _, err := pool.Exec(domain.System(h.ctx), `TRUNCATE rules RESTART IDENTITY CASCADE`); err != nil {
		t.Fatal(err)
	}
	host := newConvHost()
	rules := postgres.NewRules(pool)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.settings.s.AutoReview, h.settings.s.SelfReview = true, true
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: &pullGit{fakeGit: h.git, host: host.reviewHost}, Host: host,
		Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker}, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage, Briefs: postgres.NewBriefs(pool), Rules: rules,
		PullReviews: h.store, PRPosts: h.store, ReviewDrafts: h.store,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))

	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(1)), &a) // asks a question: the survey runs before coding
	a["patterns"] = []any{map[string]any{"file": "jobs/refund_mail.go", "kind": "new", "layer": "background job", "place": "jobs/", "why": "nothing runs in the background"}}
	b, _ := json.Marshal(a)
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: string(b)}}}
	h.step() // analyze: queues the first survey
	repo := h.repoID()

	arch := `{"layers":[{"name":"handler","paths":["httpapi/**"],"mayImport":["service"]},{"name":"service","paths":["service/**"]},
		{"name":"store","paths":["store/**"],"mayImport":[]}],
		"helpers":[{"name":"money.Round","path":"money/round.go","for":"cents"},{"name":"Ghost","path":"ghost/x.go","for":"nothing"}],
		"recipes":[{"kind":"endpoint","copy":["httpapi/payments.go"],"steps":["spec","handler"]}]}`
	h.runner.execs["git rev-parse HEAD"] = []orchestrator.ExecResult{{Output: surveySHA + "\n"}}
	h.runner.execs[`for f in 'money/round.go' 'ghost/x.go' 'httpapi/payments.go'; do [ -e "$f" ] || printf '%s\n' "$f"; done`] =
		[]orchestrator.ExecResult{{Output: "ghost/x.go\n"}}
	h.runner.scripts = []script{{result: ok("b1"), files: map[string]string{orchestrator.BriefOutPath: briefMarkdown(), orchestrator.ArchOutPath: arch}}}
	h.step() // survey
	if p := h.runner.prompts[1]; !strings.Contains(p, orchestrator.ArchOutPath) || !strings.Contains(p, `"mayImport"`) {
		t.Fatalf("survey prompt:\n%s", p)
	}
	br, _ := h.o.RepoBrief(h.ctx, repo)
	if br.ArchDraft == nil || len(br.ArchDraft.Layers) != 3 || len(br.ArchDraft.Helpers) != 1 || br.Arch != nil {
		t.Fatalf("architecture draft: %+v", br.ArchDraft)
	}
	if br, err = h.o.ApproveBrief(h.ctx, repo, domain.OriginWeb); err != nil || br.Arch == nil || br.ArchDraft != nil {
		t.Fatalf("approve: %+v %v", br.Arch, err)
	}
	if _, err := h.store.SetRepoHarness(h.ctx, repo, domain.RepoHarness{LayersBlock: true}); err != nil {
		t.Fatal(err)
	}

	// The coding run reads the architecture, and adds an import from the
	// handler into the store and a new exported helper.
	if _, err := h.o.Answer(h.ctx, "PAY-1", h.answers("PAY-1"), domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.git.files = []domain.FileChange{
		{Path: "httpapi/refunds.go", Add: 2, Diff: "@@ -1,2 +1,4 @@\n import (\n+\t\"acme/store\"\n )\n+func RoundRefund(x int) int { return x }"},
		{Path: "jobs/refund_mail.go", Add: 1, Diff: "@@ -0,0 +1 @@\n+package jobs"},
	}
	h.runner.scripts = []script{{result: ok("s1"), edit: "fix", files: map[string]string{"/workspace/go.mod": "module acme\n\ngo 1.26\n"}}}
	h.step() // code
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	if p := h.runner.prompts[2]; !strings.Contains(p, orchestrator.ArchPath) || !strings.Contains(h.runner.written[orchestrator.ArchPath], `"handler"`) {
		t.Fatalf("coding run without the architecture:\n%s", p)
	}
	res, _ := h.store.LatestResult(h.ctx, tk.ID, domain.StageCode)
	var layer *domain.RedFlag
	for i, f := range res.RedFlags {
		if orchestrator.IsLayerFlag(f) {
			layer = &res.RedFlags[i]
		}
	}
	if layer == nil || layer.Path != "httpapi/refunds.go" || layer.Line != 2 || !strings.Contains(layer.Text, "imports store (store)") {
		t.Fatalf("red flags: %+v", res.RedFlags)
	}

	// agnts's review hears of the new name; the layer break is a blocker
	// that goes back to the coder.
	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("looks_good"))}
	h.step() // review
	rv := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(rv, "## Fit with the code base") || !strings.Contains(rv, "RoundRefund (httpapi/refunds.go)") || !strings.Contains(rv, "helpers in architecture.json") {
		t.Fatalf("review prompt:\n%s", rv)
	}
	if tk = h.expect("PAY-1", domain.StateCoding); !strings.Contains(tk.Feedback, "An import the repository's architecture does not allow") {
		t.Fatalf("self-fix feedback: %q", tk.Feedback)
	}

	// Merged: the new pattern becomes a suggested rule.
	h.git.files = []domain.FileChange{{Path: "jobs/refund_mail.go", Add: 1, Diff: "@@ -0,0 +1 @@\n+package jobs"}}
	h.runner.scripts = []script{{result: ok("s1"), edit: "fix again"}, reviewScript("r2", codeReviewJSON("looks_good"))}
	h.step() // code the fix
	h.step() // review again
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push: pull request #7
	host.files = []domain.FileChange{{Path: "jobs/refund_mail.go", Add: 1, Diff: "@@ -0,0 +1 @@\n+package jobs"}}
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: "https://github.com/acme/api/pull/7"}, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("merge: %v %v", ok, err)
	}
	rs, err := rules.KnownRules(h.ctx, &repo)
	if err != nil {
		t.Fatal(err)
	}
	var sug *domain.Rule
	for i := range rs {
		if rs[i].Source == "pattern" {
			sug = &rs[i]
		}
	}
	if sug == nil || sug.Status != domain.RuleSuggested || !strings.Contains(sug.Title, "jobs/refund_mail.go") || sug.SourceTicket != "PAY-1" {
		t.Fatalf("suggested rules: %+v", rs)
	}
}
