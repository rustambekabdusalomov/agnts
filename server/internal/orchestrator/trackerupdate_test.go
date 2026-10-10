package orchestrator_test

import (
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestTrackerUpdates(t *testing.T) {
	h := newHarness(t)
	in := func(title, desc string) orchestrator.Incoming {
		return orchestrator.Incoming{Key: "PAY-1", Project: "PAY", Title: title, Description: desc, Priority: "Medium"}
	}
	ingest := func(i orchestrator.Incoming) orchestrator.IngestOutcome {
		t.Helper()
		out, err := h.o.IngestDetail(h.ctx, i, domain.OriginWeb)
		if err != nil {
			t.Fatal(err)
		}
		return out
	}
	if out := ingest(in("Fix refunds", "Round half up.")); out != orchestrator.IngestCreated {
		t.Fatalf("first: %s", out)
	}
	if out := ingest(in("Fix refunds", "Round half up.")); out != orchestrator.IngestUnchanged {
		t.Fatalf("same again: %s", out)
	}

	// Not started: the ticket takes the new text.
	if out := ingest(in("Fix refunds", "Round half even.")); out != orchestrator.IngestUpdated {
		t.Fatalf("before start: %s", out)
	}
	if tk := h.state("PAY-1"); tk.Description != "Round half even." || tk.Update != nil {
		t.Fatalf("not started: %+v", tk)
	}
	// Priority alone is taken at any time and never asks.
	hi := in("Fix refunds", "Round half even.")
	hi.Priority = "High"
	ingest(hi)

	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	h.step()
	h.expect("PAY-1", domain.StateWaitingForAnswers)
	if out := ingest(hi); out != orchestrator.IngestUnchanged {
		t.Fatalf("priority after start: %s", out)
	}

	// Started: the text stays, the new version waits for a choice.
	if tk := h.state("PAY-1"); tk.Priority != "high" {
		t.Fatalf("priority: %q", tk.Priority)
	}
	v2 := in("Fix refunds", "Round half up, and log it.")
	v2.Priority = "High"
	if out := ingest(v2); out != orchestrator.IngestAsked {
		t.Fatalf("after start: %s", out)
	}
	tk := h.state("PAY-1")
	if tk.Description != "Round half even." || tk.Update == nil || tk.Update.Description != "Round half up, and log it." || tk.Priority != "high" {
		t.Fatalf("started: %+v update %+v", tk, tk.Update)
	}
	if out := ingest(v2); out != orchestrator.IngestPending {
		t.Fatalf("asked again: %s", out)
	}

	// Keep: the same version is not asked about again; a newer one is.
	if _, err := h.o.KeepCurrentVersion(h.ctx, "PAY-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if out := ingest(v2); out != orchestrator.IngestUnchanged || h.state("PAY-1").Update != nil {
		t.Fatalf("kept version asked again: %s", out)
	}
	if _, err := h.o.KeepCurrentVersion(h.ctx, "PAY-1", domain.OriginWeb); err == nil {
		t.Fatal("kept with nothing to keep")
	}
	v3 := in("Fix refunds and credits", "Round half up everywhere.")
	if out := ingest(v3); out != orchestrator.IngestAsked {
		t.Fatalf("newer after keep: %s", out)
	}

	// Restart: back to new with the latest text, the old work dropped.
	if _, err := h.o.RestartWithUpdate(h.ctx, "PAY-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	tk = h.expect("PAY-1", domain.StateNew)
	if tk.Title != "Fix refunds and credits" || tk.Description != "Round half up everywhere." || tk.Update != nil || tk.Kept != "" {
		t.Fatalf("restarted: %+v", tk)
	}
	if qs, _ := h.store.Questions(h.ctx, tk.ID); len(qs) != 0 {
		t.Fatalf("old questions kept: %+v", qs)
	}
	if _, err := h.o.RestartWithUpdate(h.ctx, "PAY-1", domain.OriginWeb); err == nil {
		t.Fatal("restarted without a newer version")
	}

	// NoCreate: an unknown issue makes no ticket, a known one still refreshes.
	other := in("Someone else's", "x")
	other.Key, other.NoCreate = "PAY-2", true
	if out := ingest(other); out != orchestrator.IngestUnchanged {
		t.Fatalf("no create: %s", out)
	}
	if _, err := h.store.TicketByKey(h.ctx, "PAY-2"); err == nil {
		t.Fatal("NoCreate created a ticket")
	}
	mine := in("Fix refunds and credits", "Round half up everywhere, please.")
	mine.NoCreate = true
	if out := ingest(mine); out != orchestrator.IngestUpdated {
		t.Fatalf("known ticket with NoCreate: %s", out)
	}
}
