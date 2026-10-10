package orchestrator_test

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestIngestRepoLabel(t *testing.T) {
	h := newHarness(t)
	web, err := h.store.SaveRepository(h.ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github",
		CloneURL: "https://github.com/acme/web.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	api, err := h.store.RepositoryByName(h.ctx, "API")
	if err != nil || api.Name != "api" {
		t.Fatalf("by name in another case: %+v %v", api, err)
	}
	in := func(key, repo string) orchestrator.Incoming {
		return orchestrator.Incoming{Key: key, Project: "PAY", Title: "Fix the button", Repo: repo}
	}

	// The label wins over the project's repository.
	if _, err := h.o.Ingest(h.ctx, in("PAY-1", "Web"), domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-1"); tk.RepoID == nil || *tk.RepoID != web.ID {
		t.Fatalf("labelled ticket repo: %v", tk.RepoID)
	}

	// An unknown name falls back to the project's repository, with a warning.
	if _, err := h.o.Ingest(h.ctx, in("PAY-2", "nope"), domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-2"); tk.RepoID == nil || *tk.RepoID != api.ID {
		t.Fatalf("unknown label repo: %v", tk.RepoID)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-2"})
	warned := false
	for _, e := range evs {
		warned = warned || (e.Level == domain.LevelWarn && strings.Contains(e.Message, "repo:nope"))
	}
	if !warned {
		t.Fatal("no warning for an unknown repo: label")
	}

	// A label added before work starts moves the ticket; after, it stays.
	if _, err := h.o.Ingest(h.ctx, in("PAY-2", "web"), domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-2"); *tk.RepoID != web.ID {
		t.Fatalf("label added before work: %v", *tk.RepoID)
	}
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	h.step() // PAY-1 or PAY-2 starts; make sure PAY-2 left new
	for h.state("PAY-2").State == domain.StateNew {
		h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
		h.step()
	}
	if _, err := h.o.Ingest(h.ctx, in("PAY-2", "api"), domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-2"); *tk.RepoID != web.ID {
		t.Fatalf("label changed after work started moved it: %v", *tk.RepoID)
	}
}
