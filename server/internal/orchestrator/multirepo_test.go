package orchestrator_test

import (
	"errors"
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// shop makes a second repository (web) next to the harness's api and a
// group of both, and returns the repositories' ids and the group's.
func (h *harness) shop() (api, web, group int64) {
	h.t.Helper()
	api = h.apiRepo()
	r, err := h.store.SaveRepository(h.ctx, domain.Repository{
		Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/acme/web.git",
		DefaultBranch: "main", TestCmd: "npm test",
	})
	if err != nil {
		h.t.Fatal(err)
	}
	g, err := h.o.SaveGroup(h.ctx, 0, orchestrator.GroupInput{Name: "Shop", TaskPrefix: "SHOP",
		Instructions: "Change the API first; the web client's types come from api/openapi.yaml.",
		Members:      []orchestrator.GroupMemberInput{{RepoID: api, Role: "backend"}, {RepoID: r.ID, Role: "web"}}}, domain.OriginWeb)
	if err != nil {
		h.t.Fatal(err)
	}
	return api, r.ID, g.ID
}

func (h *harness) apiRepo() int64 {
	h.t.Helper()
	r, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		h.t.Fatal(err)
	}
	return r.ID
}

// A ticket in two repositories gets half as many turns again, and the
// drift checkpoint keeps that budget: a third of it, then the rest.
func TestMultiRepoCheckpointKeepsTheBudget(t *testing.T) {
	h := newHarness(t)
	_, _, group := h.shop()
	var budgets []int
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { budgets = append(budgets, r.MaxTurns) }
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Show refunds", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: `{"summary":"s","plan":["p"],"complexity":"simple",` +
			`"approaches":[{"title":"Both","sketch":"API then page."}],"footprint":{"files":["api/main.go"]}}`}},
		{result: orchestrator.ClaudeResult{SessionID: "s1", Turns: 75, Subtype: "error_max_turns", IsError: true}, edit: "api:half"},
		{result: ok("s1"), edit: "api:v1\nweb:v1"},
	}
	for _, f := range []string{"api", "web"} {
		h.runner.execs["cd '"+f+"' && {\ngit status --porcelain --untracked-files=all\n}"] = []orchestrator.ExecResult{
			{Output: " M main.go"}, {Output: " M main.go"}, {Output: " M main.go"}, {Output: " M main.go"}}
	}
	h.step() // analyze
	h.step() // code, with the checkpoint
	if len(budgets) != 3 || budgets[1] != 75 || budgets[2] != 150 {
		t.Fatalf("turn budgets (150 turns × 1.5): %v", budgets)
	}
}

func repoRow(t *testing.T, tk domain.Ticket, id int64) domain.TicketRepo {
	t.Helper()
	r, ok := tk.RepoState(id)
	if !ok {
		t.Fatalf("%s has no repository %d: %+v", tk.Key, id, tk.Repos)
	}
	return r
}

// A ticket made from a group works in both repositories at once: one
// container with a folder each, the checks of each repository in its
// folder, a commit and a pull request per repository, cross-linked, and
// the ticket merged once both pull requests are.
func TestMultiRepoTicket(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()

	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Show refunds", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if tk.Key != "SHOP-1" || len(tk.Repos) != 2 || tk.GroupName != "Shop" || *tk.RepoID != api {
		t.Fatalf("task: %s %+v group %q", tk.Key, tk.Repos, tk.GroupName)
	}
	if tk.Repos[0].Folder != "api" || tk.Repos[1].Folder != "web" || tk.Repos[0].Role != "backend" || tk.Repos[1].Role != "web" {
		t.Fatalf("folders and roles: %+v", tk.Repos)
	}

	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		// Claude changes both repositories.
		{result: ok("s1"), edit: "api:v1\nweb:v1", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Refunds in the API and the page."}`}},
	}
	for _, f := range []string{"api", "web"} { // git status in each folder shows the change
		h.runner.execs["cd '"+f+"' && {\ngit status --porcelain --untracked-files=all\n}"] = []orchestrator.ExecResult{
			{Output: " M main.go"}, {Output: " M main.go"}, {Output: " M main.go"}}
	}
	h.step() // analyze
	h.expect("SHOP-1", domain.StateCoding)
	if p := h.runner.prompts[0]; !strings.Contains(p, "## Repositories") || !strings.Contains(p, "### api/: api (backend)") ||
		!strings.Contains(p, "### web/: web (web)") || !strings.Contains(p, "the 2 repositories in /workspace") {
		t.Fatalf("analysis prompt does not describe the repositories:\n%s", p)
	}
	names := h.runner.trees[0]
	if !slices.Contains(names, "api/") || !slices.Contains(names, "web/") {
		t.Fatalf("the run's tree has no folder per repository: %v", names)
	}
	if !strings.Contains(h.runner.written[orchestrator.GroupPath], "Change the API first") {
		t.Fatalf("group instructions not in the run: %q", h.runner.written[orchestrator.GroupPath])
	}

	h.step() // code
	tk = h.expect("SHOP-1", domain.StateWaitingForReview)
	if !slices.Equal(h.runner.exported, []string{"api", "web"}) {
		t.Fatalf("exported folders: %v", h.runner.exported)
	}
	if !slices.Contains(h.runner.ran, "cd 'api' && {\ngo test ./...\n}") || !slices.Contains(h.runner.ran, "cd 'web' && {\nnpm test\n}") {
		t.Fatalf("checks did not run in each folder: %q", h.runner.ran)
	}
	a, w := repoRow(t, tk, api), repoRow(t, tk, web)
	if a.HeadSHA == "" || w.HeadSHA == "" || a.Branch != "agnts/SHOP-1" || w.Branch != "agnts/SHOP-1" || a.Files != 1 || w.Files != 1 {
		t.Fatalf("rows after coding: %+v %+v", a, w)
	}
	v, err := h.o.View(h.ctx, "SHOP-1")
	if err != nil {
		t.Fatal(err)
	}
	var where []string
	for _, f := range v.Result.Files {
		where = append(where, f.Where())
	}
	if !slices.Equal(where, []string{"api/main.go", "web/main.go"}) {
		t.Fatalf("result files: %v", where)
	}

	h.approve("SHOP-1")
	h.step() // push
	tk = h.expect("SHOP-1", domain.StateDone)
	if h.host.opened != 2 || len(tk.OpenedPRs()) != 2 {
		t.Fatalf("pull requests: opened %d, rows %+v", h.host.opened, tk.Repos)
	}
	if !strings.Contains(h.host.bodies[0], "Part of SHOP-1, with pull requests in web too") {
		t.Fatalf("pull request body does not name the sibling: %q", h.host.bodies[0])
	}
	if len(h.host.comments) != 2 || !strings.Contains(h.host.comments[0], "https://github.com/acme/web/pull/") {
		t.Fatalf("sibling links: %q", h.host.comments)
	}
	if !slices.Equal(h.git.pushed, []string{"agnts/SHOP-1", "web:agnts/SHOP-1"}) {
		t.Fatalf("pushed: %v", h.git.pushed)
	}

	// The web pull request merges first: the ticket is not merged yet.
	wr := repoRow(t, tk, web)
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: wr.PRURL}, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("merge web: %v %v", ok, err)
	}
	tk = h.state("SHOP-1")
	if tk.MergedAt != nil || repoRow(t, tk, web).MergedAt == nil || repoRow(t, tk, web).State != domain.RepoMerged {
		t.Fatalf("after the web merge: merged %v, rows %+v", tk.MergedAt, tk.Repos)
	}
	// The branch name alone is ambiguous; with the repository it is not.
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{Branch: "agnts/SHOP-1", Repo: "acme/api"}, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("merge api by branch: %v %v", ok, err)
	}
	tk = h.state("SHOP-1")
	if tk.MergedAt == nil || !tk.AllMerged() {
		t.Fatalf("both merged, the ticket is not: %+v", tk.Repos)
	}
}

// A repository the work does not change gets no commit and no pull
// request; the ticket is merged once the one pull request it opened is.
func TestMultiRepoUnchangedRepository(t *testing.T) {
	h := newHarness(t)
	api, web, _ := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoIDs: []int64{web, api}, Kind: "code", Title: "API only", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if *tk.RepoID != web || !strings.HasPrefix(tk.Key, "WEB-") || tk.GroupID != nil {
		t.Fatalf("the first repository picked is the primary: %s %+v", tk.Key, tk.Repos)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "api:v1"},
	}
	h.step()
	h.step()
	tk = h.expect(tk.Key, domain.StateWaitingForReview)
	if r := repoRow(t, tk, web); r.State != domain.RepoUnchanged || r.Files != 0 {
		t.Fatalf("web was not changed: %+v", r)
	}
	if !slices.Equal(h.git.committed, []string{"api"}) {
		t.Fatalf("commits: %v", h.git.committed)
	}
	h.approve(tk.Key)
	h.step()
	tk = h.expect(tk.Key, domain.StateDone)
	if h.host.opened != 1 || repoRow(t, tk, web).PRNumber != nil || repoRow(t, tk, api).PRNumber == nil {
		t.Fatalf("pull requests: %d, rows %+v", h.host.opened, tk.Repos)
	}
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: repoRow(t, tk, api).PRURL}, domain.OriginWebhook); err != nil || !ok {
		t.Fatal(ok, err)
	}
	if tk = h.state(tk.Key); tk.MergedAt == nil {
		t.Fatalf("its only pull request is merged, the ticket is not: %+v", tk.Repos)
	}
}

// Nothing changed in any repository: the run fails, as for one.
func TestMultiRepoNoChanges(t *testing.T) {
	h := newHarness(t)
	_, _, group := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Nothing", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1")},
	}
	h.step()
	h.step()
	h.expect(tk.Key, domain.StateFailed)
}

// A push that fails in one repository leaves the other pushed; Retry
// pushes only the missing one.
func TestMultiRepoPartialPush(t *testing.T) {
	h := newHarness(t)
	_, web, group := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Both", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "api:v1\nweb:v1"},
	}
	h.step()
	h.step()
	h.approve(tk.Key)
	h.git.failPush = map[string]bool{"web": true}
	h.step()
	tk = h.expect(tk.Key, domain.StateFailed)
	if r := repoRow(t, tk, web); r.PushError == "" || r.PRNumber != nil {
		t.Fatalf("web's push error not recorded: %+v", r)
	}
	if h.host.opened != 1 {
		t.Fatalf("api's pull request not opened: %d", h.host.opened)
	}
	if _, err := h.o.Retry(h.ctx, tk.Key, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	tk = h.expect(tk.Key, domain.StateDone)
	if h.host.opened != 2 || !slices.Equal(h.git.pushed, []string{"agnts/" + tk.Key, "web:agnts/" + tk.Key}) {
		t.Fatalf("retry pushed %v, opened %d", h.git.pushed, h.host.opened)
	}
	if r := repoRow(t, tk, web); r.PushError != "" || r.State != domain.RepoPushed {
		t.Fatalf("web after the retry: %+v", r)
	}
}

// Red CI on one repository's pull request reopens the ticket with
// feedback naming it, counted per pull request; a merged one stays out of
// the next run's commits.
func TestMultiRepoCIFeedback(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Both", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "api:v1\nweb:v1"},
		{result: ok("s1"), edit: "api:v1\nweb:v2"},
	}
	h.step()
	h.step()
	h.approve(tk.Key)
	h.step()
	tk = h.expect(tk.Key, domain.StateDone)
	if _, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: repoRow(t, tk, api).PRURL}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	// CI on the merged repository cannot reopen it.
	if _, res, err := h.o.CIFeedback(h.ctx, tk.Key, api, "CI failed", "https://ci/1", 2); err != nil || res != orchestrator.CIFeedbackSkipped {
		t.Fatalf("merged api: %v %v", res, err)
	}
	tk, res, err := h.o.CIFeedback(h.ctx, tk.Key, web, "CI failed: TestPage", "https://ci/2", 1)
	if err != nil || res != orchestrator.CIFeedbackSent {
		t.Fatalf("web: %v %v", res, err)
	}
	if tk.State != domain.StateCoding || !strings.Contains(tk.Feedback, "in the repository web (web/)") || repoRow(t, tk, web).CIFixes != 1 {
		t.Fatalf("after CI feedback: %s %q %+v", tk.State, tk.Feedback, tk.Repos)
	}
	h.git.committed = nil
	h.runner.exported = nil
	h.step()
	h.expect(tk.Key, domain.StateWaitingForReview)
	if !slices.Equal(h.runner.exported, []string{"web"}) {
		t.Fatalf("the merged repository was exported again: %v", h.runner.exported)
	}
	if _, res, _ := h.o.CIFeedback(h.ctx, tk.Key, web, "again", "https://ci/3", 1); res != orchestrator.CIFeedbackSkipped {
		t.Fatalf("not done: CI cannot reopen it again: %v", res)
	}
}

// What may not span several repositories, or cannot share a container,
// is refused when the ticket is made.
func TestMultiRepoChoiceRules(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	cases := []orchestrator.TaskInput{
		{RepoID: api, GroupID: group},   // two ways at once
		{RepoIDs: []int64{api, 999999}}, // an unknown repository
		{GroupID: 999999},               // an unknown group
		{RepoIDs: []int64{api, web}, Kind: "review"},
	}
	for i, in := range cases {
		in.Title, in.Priority, in.AfterApprove, in.Start = "t", "medium", "pr", "queue"
		if _, err := h.o.CreateTask(h.ctx, in, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
			t.Errorf("case %d: %v", i, err)
		}
	}
	// The same repository twice is one.
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoIDs: []int64{api, web, api}, Title: "t", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb)
	if err != nil || len(tk.Repos) != 2 {
		t.Fatalf("duplicates: %+v %v", tk.Repos, err)
	}
	// Different runner images cannot share a container.
	r, _ := h.store.RepositoryByID(h.ctx, web)
	r.RunnerImage = "acme/runner:node"
	if _, err := h.store.UpdateRepository(h.ctx, r); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Title: "t", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) ||
		!strings.Contains(err.Error(), "runner images") {
		t.Fatalf("incompatible images: %v", err)
	}
	if _, err := h.o.SaveGroup(h.ctx, group, orchestrator.GroupInput{Name: "Shop", Members: []orchestrator.GroupMemberInput{{RepoID: api}, {RepoID: web}}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("group with incompatible repositories saved: %v", err)
	}
	// The workspace's limit.
	h.settings.s.MaxTicketRepos = 1
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoIDs: []int64{api, web}, Title: "t", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("over the limit: %v", err)
	}
}

// Groups: a prefix may not clash with a repository's, an archived
// repository cannot be added, and deleting a group keeps its tickets'
// repositories.
func TestRepoGroups(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	if _, err := h.o.SaveGroup(h.ctx, 0, orchestrator.GroupInput{Name: "Other", TaskPrefix: "PAY", Members: []orchestrator.GroupMemberInput{{RepoID: api}}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a group took the Jira project's prefix: %v", err)
	}
	if _, err := h.o.SaveGroup(h.ctx, 0, orchestrator.GroupInput{Name: "shop", Members: []orchestrator.GroupMemberInput{{RepoID: api}}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a second group named Shop: %v", err)
	}
	if _, err := h.store.SetRepositoryArchived(h.ctx, web, true); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SaveGroup(h.ctx, 0, orchestrator.GroupInput{Name: "Web", Members: []orchestrator.GroupMemberInput{{RepoID: web}}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("an archived repository was added: %v", err)
	}
	// A ticket from the group skips its archived member, with a notice.
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Title: "t", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb)
	if err != nil || len(tk.Repos) != 1 || *tk.RepoID != api {
		t.Fatalf("archived member not skipped: %+v %v", tk.Repos, err)
	}
	if len(h.events(tk.Key, domain.EventTicketUpdated)) == 0 {
		t.Fatal("no notice about the skipped repository")
	}
	if err := h.o.DeleteGroup(h.ctx, group, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	tk = h.state(tk.Key)
	if tk.GroupID != nil || len(tk.Repos) != 1 {
		t.Fatalf("after deleting the group: %+v %v", tk.Repos, tk.GroupID)
	}
}

// Repositories change before work starts, and not after a push.
func TestSetRepos(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: api, Title: "t", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	tk, err = h.o.SetRepos(h.ctx, tk.Key, domain.RepoChoice{GroupID: group}, domain.OriginWeb)
	if err != nil || len(tk.Repos) != 2 || tk.GroupName != "Shop" || tk.Repos[1].Folder != "web" {
		t.Fatalf("set the group: %+v %v", tk.Repos, err)
	}
	tk, err = h.o.SetRepos(h.ctx, tk.Key, domain.RepoChoice{RepoIDs: []int64{web}}, domain.OriginWeb)
	if err != nil || len(tk.Repos) != 1 || *tk.RepoID != web || tk.Repos[0].Folder != "" || tk.GroupID != nil {
		t.Fatalf("back to one: %+v %v", tk.Repos, err)
	}
}

// Tracker labels: every repo: label, or a group: label.
func TestIngestRepoLabels(t *testing.T) {
	h := newHarness(t)
	api, web, _ := h.shop()
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-70", Project: "PAY", Title: "both", Repos: []string{"api", "web"}}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	tk := h.state("PAY-70")
	if !slices.Equal(tk.RepoIDs(), []int64{api, web}) {
		t.Fatalf("repo labels: %v", tk.RepoIDs())
	}
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-71", Project: "PAY", Title: "group", Repo: "api", Group: "shop"}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	tk = h.state("PAY-71")
	if len(tk.Repos) != 2 || tk.GroupName != "Shop" {
		t.Fatalf("group label: %+v", tk.Repos)
	}
	// A label moved before work starts moves the ticket.
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-71", Project: "PAY", Title: "group", Repo: "web"}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk = h.state("PAY-71"); !slices.Equal(tk.RepoIDs(), []int64{web}) {
		t.Fatalf("relabelled: %v", tk.RepoIDs())
	}
}

// Partly merged, then the closed pull request is reopened: the ticket is
// not merged any more, may take CI feedback again, and is merged (once)
// when that pull request merges.
func TestMultiRepoReopenAfterPartlyMerged(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Both", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "api:v1\nweb:v1"},
	}
	h.step()
	h.step()
	h.approve(tk.Key)
	h.step()
	tk = h.expect(tk.Key, domain.StateDone)
	apiPR, webPR := repoRow(t, tk, api).PRURL, repoRow(t, tk, web).PRURL
	if _, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: apiPR}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.MarkPRClosed(h.ctx, domain.PRRef{URL: webPR}, true, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk = h.state(tk.Key); tk.MergedAt == nil || !tk.PartlyMerged() {
		t.Fatalf("partly merged: %v %+v", tk.MergedAt, tk.Repos)
	}
	if _, err := h.o.MarkPRClosed(h.ctx, domain.PRRef{URL: webPR}, false, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk = h.state(tk.Key); tk.MergedAt != nil || !domain.CanReopenForCIIn(tk, web) {
		t.Fatalf("reopened: merged %v, CI may reopen %v", tk.MergedAt, domain.CanReopenForCIIn(tk, web))
	}
	if _, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: webPR}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: webPR}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk = h.state(tk.Key); tk.MergedAt == nil {
		t.Fatal("not merged after both")
	}
	all := 0
	for _, e := range h.events(tk.Key, domain.EventMerged) {
		if e.Data["all"] == true {
			all++
		}
	}
	if all != 2 { // once partly, once fully
		t.Fatalf("ticket-level merges logged %d times", all)
	}
}
