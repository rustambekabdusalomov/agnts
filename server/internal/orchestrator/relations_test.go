package orchestrator_test

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// analysisOf is an analysis.json with a footprint and relation claims.
func analysisOf(files []string, migrations bool, relations ...map[string]any) string {
	a := map[string]any{"summary": "Work in refund.go.", "plan": []string{"Change it"}, "questions": []any{},
		"footprint": map[string]any{"files": files, "migrations": migrations}}
	if relations != nil {
		a["relations"] = relations
	}
	b, _ := json.Marshal(a)
	return string(b)
}

func claim(key, typ string, confidence float64, reason string) map[string]any {
	return map[string]any{"key": key, "type": typ, "confidence": confidence, "reason": reason}
}

func coded(session string) script {
	return script{result: ok(session), edit: "fix", files: map[string]string{orchestrator.SummaryPath: `{"summary":"done","notes":[]}`}}
}

func analyzed(session, analysisJSON string) script {
	return script{result: ok(session), files: map[string]string{orchestrator.AnalysisPath: analysisJSON}}
}

func (h *harness) ingestLinked(key string, dependsOn ...string) {
	h.t.Helper()
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: key, Project: "PAY", Title: "Ticket " + key,
		LinksKnown: true, DependsOn: dependsOn}, domain.OriginWebhook); err != nil {
		h.t.Fatal(err)
	}
}

func (h *harness) relations(key string) orchestrator.Relations {
	h.t.Helper()
	rs, err := h.o.ListRelations(h.ctx, key)
	if err != nil {
		h.t.Fatal(err)
	}
	return rs
}

func (h *harness) approve(key string) {
	h.t.Helper()
	if _, err := h.o.Approve(h.ctx, key, nil, false, domain.OriginWeb); err != nil {
		h.t.Fatal(err)
	}
}

// Phase 1: a Jira "is blocked by" link holds the dependent's coding until
// the blocker's pull request is merged, and the dependent's first coding
// prompt says what landed.
func TestDependencyWaitsForMerge(t *testing.T) {
	h := newHarness(t)
	h.ingestLinked("PAY-1")
	h.ingestLinked("PAY-2", "PAY-1")
	if rs := h.relations("PAY-2").All; len(rs) != 1 || rs[0].Source != domain.RelFromJira || rs[0].TicketKey != "PAY-2" || rs[0].Status != domain.RelActive {
		t.Fatalf("jira relation: %+v", rs)
	}
	h.runner.scripts = []script{
		analyzed("s1", analysisOf([]string{"tasks.go"}, false)),
		coded("s1"),
		analyzed("s2", analysisOf([]string{"list.go"}, false)),
		coded("s2"),
	}

	h.step() // PAY-1 goes first: PAY-2 waits for it
	h.expect("PAY-1", domain.StateCoding)
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	h.step() // PAY-2's analysis is not held back, and sees PAY-1
	h.expect("PAY-2", domain.StateCoding)
	if p := lastPrompt(h); !strings.Contains(p, "## Other open tickets") || !strings.Contains(p, "PAY-1 (coded, in review)") || !strings.Contains(p, "tasks.go") {
		t.Fatalf("analysis prompt does not list PAY-1:\n%s", p)
	}
	h.idle() // PAY-2's coding waits for PAY-1's merge
	if bs := h.relations("PAY-2").Blockers; len(bs) != 1 || bs[0].Key != "PAY-1" {
		t.Fatalf("blockers: %+v", bs)
	}
	rows, err := h.o.Rows(h.ctx, []domain.Ticket{h.state("PAY-2")})
	if err != nil || len(rows[0].Blockers) != 1 {
		t.Fatalf("rows: %+v %v", rows, err)
	}

	h.approve("PAY-1")
	h.step() // push and open the pull request
	h.expect("PAY-1", domain.StateDone)
	h.idle() // pushed is not merged

	if _, err := h.o.MarkMerged(h.ctx, "https://github.com/acme/api/pull/7", "", domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
	if p := lastPrompt(h); !strings.Contains(p, "## Merged since the analysis") || !strings.Contains(p, "- PAY-1: Ticket PAY-1") {
		t.Fatalf("coding prompt does not mention the merged dependency:\n%s", p)
	}

	// Removing the link in Jira removes the relation.
	h.ingestLinked("PAY-2")
	if rs := h.relations("PAY-2").All; len(rs) != 0 {
		t.Fatalf("relation kept after the link was removed: %+v", rs)
	}
}

// Phase 1: someone can make one ticket wait for another, a cycle is
// refused, and marking a pull request merged by hand releases the wait.
func TestManualRelationsAndMergedByHand(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	r, err := h.o.AddRelation(h.ctx, "PAY-2", "PAY-1", domain.RelDependsOn, domain.OriginWeb)
	if err != nil || r.Source != domain.RelFromUser || r.Status != domain.RelActive {
		t.Fatalf("add: %+v %v", r, err)
	}
	if _, err := h.o.AddRelation(h.ctx, "PAY-1", "PAY-2", domain.RelDependsOn, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("cycle accepted: %v", err)
	}
	if _, err := h.o.AddRelation(h.ctx, "PAY-2", "PAY-404", domain.RelDependsOn, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown ticket accepted: %v", err)
	}
	h.runner.scripts = []script{
		analyzed("s1", analysis(0)), coded("s1"), analyzed("s2", analysis(0)), coded("s2"),
	}
	h.step()
	h.step()
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	h.expect("PAY-2", domain.StateCoding)
	h.idle()

	if _, err := h.o.MarkMergedByHand(h.ctx, "PAY-1", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("merged before it was pushed: %v", err)
	}
	h.approve("PAY-1")
	h.step()
	h.idle()
	if tk, err := h.o.MarkMergedByHand(h.ctx, "PAY-1", domain.OriginWeb); err != nil || tk.MergedAt == nil {
		t.Fatalf("mark merged: %+v %v", tk, err)
	}
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
}

// A merge whose webhook never arrived is found by asking the git host, and
// releases the ticket waiting for it.
func TestCheckMergesFindsMergedPR(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	if _, err := h.o.AddRelation(h.ctx, "PAY-2", "PAY-1", domain.RelDependsOn, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		analyzed("s1", analysis(0)), coded("s1"), analyzed("s2", analysis(0)), coded("s2"),
	}
	h.step()
	h.step()
	h.step()
	h.idle()
	h.o.CheckMerges(h.ctx) // nothing pushed yet: nothing to ask about
	if len(h.host.asked) != 0 {
		t.Fatalf("asked before a pull request existed: %v", h.host.asked)
	}
	h.approve("PAY-1")
	h.step()
	h.idle()

	h.o.CheckMerges(h.ctx) // still open
	if tk := h.state("PAY-1"); tk.MergedAt != nil || len(h.host.asked) != 1 || h.host.asked[0] != 7 {
		t.Fatalf("open pull request: merged %v, asked %v", tk.MergedAt, h.host.asked)
	}
	h.expect("PAY-2", domain.StateCoding)

	h.host.merged = map[int]bool{7: true}
	h.o.CheckMerges(h.ctx)
	if tk := h.state("PAY-1"); tk.MergedAt == nil {
		t.Fatal("merge not recorded")
	}
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)

	h.o.CheckMerges(h.ctx) // a recorded merge is not asked about again
	if len(h.host.asked) != 2 {
		t.Fatalf("asked again: %v", h.host.asked)
	}
}

// A pull request closed without a merge is recorded once and then no longer
// polled; a webhook reopen clears it so polling resumes.
func TestCheckMergesRecordsClosedPR(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{analyzed("s1", analysis(0)), coded("s1")}
	h.step()
	h.step()
	h.idle()
	h.approve("PAY-1")
	h.step()
	h.idle()

	h.host.closed = map[int]bool{7: true}
	h.o.CheckMerges(h.ctx)
	h.o.CheckMerges(h.ctx) // closed: not asked again
	if len(h.host.asked) != 1 {
		t.Fatalf("asked %v", h.host.asked)
	}
	tk := h.state("PAY-1")
	if tk.MergedAt != nil || tk.State != domain.StateDone {
		t.Fatalf("closed PR changed the ticket: %+v", tk)
	}

	if ok, err := h.o.MarkPRClosed(h.ctx, tk.PRURL, "", false, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("reopen: %v %v", ok, err)
	}
	h.host.closed = nil
	h.o.CheckMerges(h.ctx) // reopened: polled again
	if len(h.host.asked) != 2 {
		t.Fatalf("not polled after reopen: %v", h.host.asked)
	}
}

// Phase 2: predicted footprints that share a hot spot (both add a
// migration) make an active conflict: the second ticket waits until the
// first is merged, or rejected.
func TestFootprintConflict(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	h.runner.scripts = []script{
		analyzed("s1", analysisOf([]string{"server/refund.go", "server/migrations/00018_refunds.sql"}, true)),
		analyzed("s2", analysisOf([]string{"server/report.go", "server/migrations/00018_reports.sql"}, true)),
		coded("s1"),
		coded("s2"),
	}
	h.step() // analyze PAY-1
	h.step() // analyze PAY-2: it shares the migrations hot spot with PAY-1
	rs := h.relations("PAY-2").All
	if len(rs) != 1 || rs[0].Type != domain.RelConflicts || rs[0].Source != domain.RelFromRule || rs[0].Basis != domain.BasisMigrations ||
		rs[0].Status != domain.RelActive || rs[0].FoundBy != "PAY-2" {
		t.Fatalf("relations: %+v", rs)
	}
	h.step() // PAY-1 codes: neither had started, so the older one goes
	h.expect("PAY-1", domain.StateWaitingForReview)
	h.idle() // PAY-2 waits: PAY-1 changes the same code and is not merged
	if bs := h.relations("PAY-2").Blockers; len(bs) != 1 || bs[0].Key != "PAY-1" || bs[0].Type != domain.RelConflicts {
		t.Fatalf("blockers: %+v", bs)
	}
	if _, err := h.o.Reject(h.ctx, "PAY-1", "not needed", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
}

// Phase 3: a relation the analysis is unsure about is only proposed; once
// accepted it holds the queue, and dismissing it releases the ticket.
// Claims about tickets the prompt did not list are ignored, and a confident
// "blocks" points the other way.
func TestProposedRelations(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	h.ingest("PAY-3")
	h.runner.scripts = []script{
		analyzed("s1", analysisOf([]string{"a.go"}, false)),
		analyzed("s2", analysisOf([]string{"b.go"}, false,
			claim("PAY-1", "depends_on", 0.4, "uses the endpoint PAY-1 adds"),
			claim("PAY-3", "blocks", 0.9, "PAY-3 calls the helper this adds"),
			claim("PAY-99", "conflicts", 0.9, "made up"))),
	}
	h.step()
	h.step()
	byOther := map[string]orchestrator.RelationRow{}
	for _, r := range h.relations("PAY-2").All {
		byOther[r.Other("PAY-2")] = r
	}
	p1, p3 := byOther["PAY-1"], byOther["PAY-3"]
	if len(byOther) != 2 || p1.Status != domain.RelProposed || p1.TicketKey != "PAY-2" || p1.Reason != "uses the endpoint PAY-1 adds" ||
		p3.Status != domain.RelActive || p3.TicketKey != "PAY-3" || p3.OtherKey != "PAY-2" || p3.Source != domain.RelFromAgnts {
		t.Fatalf("relations: %+v", byOther)
	}
	if bs := h.relations("PAY-2").Blockers; len(bs) != 0 {
		t.Fatalf("a proposed relation holds the queue: %+v", bs)
	}

	if _, err := h.o.DecideRelation(h.ctx, "PAY-2", p1.ID, true, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if bs := h.relations("PAY-2").Blockers; len(bs) != 1 || bs[0].Key != "PAY-1" {
		t.Fatalf("accepted relation does not hold the queue: %+v", bs)
	}
	if _, err := h.o.DecideRelation(h.ctx, "PAY-3", p1.ID, false, domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("decided through an unrelated ticket: %v", err)
	}
	if _, err := h.o.DecideRelation(h.ctx, "PAY-2", p1.ID, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if bs := h.relations("PAY-2").Blockers; len(bs) != 0 {
		t.Fatalf("dismissed relation holds the queue: %+v", bs)
	}

	// A new analysis of PAY-2 replaces what the old one found (PAY-3's
	// relation is not claimed again) but does not bring back the relation
	// someone dismissed, however confident.
	if _, err := h.store.Transition(h.ctx, "PAY-2", domain.StateFailed, domain.Event{TicketKey: "PAY-2", Type: domain.EventStateChanged},
		func(x *domain.Ticket) { x.ResumeState = domain.StateNew }); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Retry(h.ctx, "PAY-2", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{analyzed("s3", analysisOf([]string{"b.go"}, false, claim("PAY-1", "depends_on", 0.95, "really")))}
	h.step() // PAY-2 goes first: PAY-3 waits for it
	h.expect("PAY-2", domain.StateCoding)
	rs := h.relations("PAY-2").All
	if len(rs) != 1 || rs[0].Other("PAY-2") != "PAY-1" || rs[0].Status != domain.RelDismissed {
		t.Fatalf("after a new analysis: %+v", rs)
	}
}

// Phase 4: finished changes that touch the same lines become a git
// conflict, logged with whether it was predicted, and the predicted
// footprint is scored against the real diff.
func TestCollisionAndFootprintCheck(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	diff := "--- a/main.go\n+++ b/main.go\n@@ -1,3 +1,3 @@\n package main\n-func main() {}\n+func main() { run() }\n"
	h.git.files = []domain.FileChange{{Path: "main.go", Add: 1, Del: 1, Diff: diff}}
	h.runner.scripts = []script{
		analyzed("s1", analysisOf([]string{"main.go", "extra.go"}, false)),
		analyzed("s2", analysisOf([]string{"other.go"}, false)),
		coded("s1"),
		coded("s2"),
	}
	h.step()
	h.step()
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	h.step() // PAY-2 was not predicted to collide, so it codes, and collides
	h.expect("PAY-2", domain.StateWaitingForReview)

	rs := h.relations("PAY-2").All
	if len(rs) != 1 || rs[0].Source != domain.RelFromGit || rs[0].Basis != domain.BasisDiff || rs[0].Files[0] != "main.go" {
		t.Fatalf("collision relation: %+v", rs)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-2"})
	var collision, footprint *domain.Event
	for i, e := range evs {
		switch e.Type {
		case domain.EventCollision:
			collision = &evs[i]
		case domain.EventFootprint:
			footprint = &evs[i]
		}
	}
	if collision == nil || collision.Data["predicted"] != "none" || collision.Data["other"] != "PAY-1" {
		t.Fatalf("collision event: %+v", collision)
	}
	if footprint == nil || footprint.Data["recall"].(float64) != 0 {
		t.Fatalf("footprint event of PAY-2: %+v", footprint)
	}
	evs1, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-1"})
	var p1 *domain.Event
	for i, e := range evs1 {
		if e.Type == domain.EventFootprint {
			p1 = &evs1[i]
		}
	}
	if p1 == nil || p1.Data["precision"].(float64) != 0.5 || p1.Data["recall"].(float64) != 1 {
		t.Fatalf("footprint event of PAY-1: %+v", p1)
	}
}

// Phase 4: when a predicted conflict really collides, the relation keeps
// who predicted it and is marked confirmed, even if someone chose to run
// the two side by side anyway.
func TestPredictedCollisionIsConfirmed(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.ingest("PAY-2")
	diff := "--- a/main.go\n+++ b/main.go\n@@ -1,3 +1,3 @@\n package main\n-func main() {}\n+func main() { run() }\n"
	h.git.files = []domain.FileChange{{Path: "main.go", Add: 1, Del: 1, Diff: diff}}
	h.runner.scripts = []script{
		analyzed("s1", analysisOf([]string{"main.go"}, false)),
		analyzed("s2", analysisOf([]string{"main.go"}, false)),
		coded("s1"),
		coded("s2"),
	}
	h.step()
	h.step()
	rs := h.relations("PAY-2").All
	if len(rs) != 1 || rs[0].Source != domain.RelFromRule || rs[0].Basis != domain.BasisFiles || rs[0].Files[0] != "main.go" {
		t.Fatalf("predicted: %+v", rs)
	}
	if _, err := h.o.DecideRelation(h.ctx, "PAY-2", rs[0].ID, false, domain.OriginWeb); err != nil { // run anyway
		t.Fatal(err)
	}
	h.step()
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
	rs = h.relations("PAY-2").All
	if len(rs) != 1 || rs[0].Source != domain.RelFromRule || rs[0].ConfirmedAt == nil || rs[0].Status != domain.RelDismissed {
		t.Fatalf("after the collision: %+v", rs)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-2"})
	for _, e := range evs {
		if e.Type == domain.EventCollision && e.Data["predicted"] != "dismissed" {
			t.Fatalf("collision event: %+v", e)
		}
	}
}
