package orchestrator_test

import (
	"errors"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// newBriefHarness is a harness whose orchestrator has the brief store.
func newBriefHarness(t *testing.T) (*harness, *postgres.Briefs) {
	t.Helper()
	h := newHarness(t)
	pool, err := postgres.Open(h.ctx, os.Getenv("AGNTS_TEST_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	briefs := postgres.NewBriefs(pool)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: h.git, Host: h.host, Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker}, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage, Briefs: briefs,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return h, briefs
}

const surveySHA = "0123456789abcdef0123456789abcdef01234567"

func briefMarkdown() string {
	return "# api\n\n## Purpose\nRefunds for the payments team.\n\n## Architecture\ndomain <- usecases <- adapters; adapters never import each other.\n\n" +
		"## Recipes\nA new endpoint: openapi.yaml, make gen, handler in httpapi, use case in refunds.\n\n## Files to copy\nhttpapi/refunds.go\n"
}

func (h *harness) repoID() int64 {
	h.t.Helper()
	tk := h.state("PAY-1")
	if tk.RepoID == nil {
		h.t.Fatal("PAY-1 has no repository")
	}
	return *tk.RepoID
}

func TestBriefSurveyApproveAndUse(t *testing.T) {
	h, briefs := newBriefHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	h.step() // analyze: the repository has no brief, so a survey is queued
	if strings.Contains(h.runner.prompts[0], "Team knowledge") {
		t.Fatal("a ticket got a brief before any was approved")
	}
	repo := h.repoID()
	b, err := h.o.RepoBrief(h.ctx, repo)
	if err != nil || b.Status != domain.BriefPending || b.RepoName != "api" {
		t.Fatalf("brief after the first analysis: %+v %v", b, err)
	}

	h.runner.execs["git rev-parse HEAD"] = []orchestrator.ExecResult{{Output: surveySHA + "\n"}}
	h.runner.scripts = []script{{result: ok("b1"), files: map[string]string{orchestrator.BriefOutPath: briefMarkdown()}}}
	h.step() // survey
	p := h.runner.prompts[1]
	if !strings.Contains(p, orchestrator.BriefOutPath) || !strings.Contains(p, "## Recipes") || strings.Contains(p, "The current brief") {
		t.Fatalf("first survey prompt:\n%s", p)
	}
	b, _ = h.o.RepoBrief(h.ctx, repo)
	if b.Status != domain.BriefIdle || b.Ready() || b.DraftSHA != surveySHA || !strings.Contains(b.Draft, "adapters never import") || b.SurveyedAt == nil {
		t.Fatalf("brief after the survey: %+v", b)
	}

	// Not approved yet: tickets do not get the draft.
	if _, err := h.o.Answer(h.ctx, "PAY-1", h.answers("PAY-1"), domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s1"), edit: "fix"}}
	h.step() // code
	if strings.Contains(h.runner.prompts[2], orchestrator.BriefPath) {
		t.Fatal("an unapproved draft reached a coding run")
	}

	if b, err = h.o.ApproveBrief(h.ctx, repo, domain.OriginWeb); err != nil || !b.Ready() || b.Draft != "" || b.BodySHA != surveySHA || b.ApprovedAt == nil {
		t.Fatalf("approve: %+v %v", b, err)
	}
	if _, err := h.o.ApproveBrief(h.ctx, repo, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("approving without a draft: %v", err)
	}

	h.ingest("PAY-2")
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step() // analyze PAY-2: gets the brief, queues no survey
	p = h.runner.prompts[3]
	if !strings.Contains(p, "## Team knowledge") || !strings.Contains(p, orchestrator.BriefPath) {
		t.Fatalf("analysis prompt without the brief:\n%s", p)
	}
	if b, _ = h.o.RepoBrief(h.ctx, repo); b.Busy() {
		t.Fatalf("a survey was queued although the repository has a brief: %+v", b)
	}

	// A person's edit wins, and an update survey starts from it.
	if _, err := h.o.SaveBrief(h.ctx, repo, briefMarkdown()+"\n## Pitfalls\nNever edit gen/ by hand.\n", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SurveyBrief(h.ctx, repo, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s2"), edit: "fix"}, // PAY-2's coding goes first
		{result: ok("b2"), files: map[string]string{orchestrator.BriefOutPath: briefMarkdown() + "\n## Pitfalls\nNever edit gen/ by hand. Run make gen.\n"}},
	}
	h.step() // code PAY-2
	h.step() // survey again
	p = h.runner.prompts[5]
	if !strings.Contains(p, "The current brief") || !strings.Contains(p, "git log --stat "+surveySHA+"..HEAD") {
		t.Fatalf("update survey prompt:\n%s", p)
	}
	b, _ = h.o.RepoBrief(h.ctx, repo)
	if !strings.HasSuffix(b.Body, "Never edit gen/ by hand.") || !strings.Contains(b.Draft, "Run make gen.") {
		t.Fatalf("after the update survey: body %q draft %q", b.Body, b.Draft)
	}
	if b, err = h.o.DiscardBriefDraft(h.ctx, repo, domain.OriginWeb); err != nil || b.Draft != "" || !b.Ready() {
		t.Fatalf("discard: %+v %v", b, err)
	}
	_ = briefs
}

func TestBriefSurveyFailsAndRefreshesAfterMerges(t *testing.T) {
	h, briefs := newBriefHarness(t)
	h.settings.s.AskFirst = false
	h.shipped("PAY-1") // analysis queues a survey; push leaves it waiting
	repo := h.repoID()

	h.runner.scripts = []script{{result: ok("b1")}} // writes no brief
	h.step()
	b, _ := h.o.RepoBrief(h.ctx, repo)
	if b.Status != domain.BriefFailed || !strings.Contains(b.Error, orchestrator.BriefOutPath) {
		t.Fatalf("failed survey: %+v", b)
	}
	h.idle() // a failed survey is not retried by itself

	// An approved brief that is one merge away from stale.
	if _, err := briefs.UpdateBrief(h.ctx, repo, func(x *domain.RepoBrief) error {
		x.Body, x.Status, x.Error, x.MergesSince = briefMarkdown(), domain.BriefIdle, "", domain.BriefRefreshMerges-1
		return nil
	}, nil); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.MarkMerged(h.ctx, "https://github.com/acme/api/pull/7", "", domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	b, _ = h.o.RepoBrief(h.ctx, repo)
	if b.MergesSince != domain.BriefRefreshMerges || b.Status != domain.BriefPending {
		t.Fatalf("after the merge that made it stale: %+v", b)
	}
}

// answers answers every open question of a ticket with its first option.
func (h *harness) answers(key string) []domain.Answer {
	h.t.Helper()
	v, err := h.o.View(h.ctx, key)
	if err != nil {
		h.t.Fatal(err)
	}
	var out []domain.Answer
	for _, q := range v.Questions {
		out = append(out, domain.Answer{QuestionID: q.ID, Answer: q.Options[0]})
	}
	return out
}
