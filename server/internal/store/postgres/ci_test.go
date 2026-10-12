package postgres

import (
	"errors"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestCIStore(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	box, _ := secret.NewBox(make([]byte, 32))
	ci := NewCI(users.db, box)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}

	// Watches: the default until saved.
	w, err := ci.CIWatch(ctx, repo.ID)
	if err != nil || w.Enabled || len(w.Ignore) == 0 {
		t.Fatalf("default watch %+v %v", w, err)
	}
	w.Enabled, w.Branches = true, []string{"release/*"}
	if _, err := ci.SaveCIWatch(ctx, w); err != nil {
		t.Fatal(err)
	}
	if got, _ := ci.EnabledCIWatches(ctx); len(got) != 1 || got[0].RepoID != repo.ID || got[0].Branches[0] != "release/*" {
		t.Fatalf("enabled watches %+v", got)
	}
	if _, err := ci.SaveCIWatch(ctx, domain.CIWatch{RepoID: 999999}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("watch of a missing repository: %v", err)
	}

	// Concurrent upserts of one fingerprint (matrix jobs) end in one group.
	key := domain.CIFailure{RepoID: repo.ID, Branch: "main", Workflow: "ci.yml", Fingerprint: "fp1", Job: "test", Title: "boom"}
	var wg sync.WaitGroup
	for i := range 8 {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			_, err := ci.UpsertCIFailure(ctx, key, "log sample", func(f *domain.CIFailure, isNew bool) error {
				if !isNew {
					f.Count++
				}
				f.Occurrences = append(f.Occurrences, domain.CIOccurrence{RunID: int64(i), At: time.Now()})
				return nil
			})
			if err != nil {
				t.Error(err)
			}
		}(i)
	}
	wg.Wait()
	list, err := ci.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID})
	if err != nil || len(list) != 1 || list[0].Count != 8 || len(list[0].Occurrences) != 8 || list[0].RepoName != "api" {
		t.Fatalf("groups %+v %v", list, err)
	}
	if list[0].Sample != "" {
		t.Fatal("lists carry no sample")
	}
	g, err := ci.CIFailure(ctx, list[0].ID)
	if err != nil || g.Sample != "log sample" {
		t.Fatalf("sample %q %v", g.Sample, err)
	}
	var raw []byte
	_ = users.db.QueryRow(ctx, `SELECT sample FROM ci_failures WHERE id = $1`, g.ID).Scan(&raw)
	if string(raw) == "log sample" {
		t.Fatal("sample stored in the clear")
	}

	// Occurrences are capped; status and ticket stick.
	now := time.Now()
	g, err = ci.UpdateCIFailure(ctx, g.ID, func(f *domain.CIFailure) error {
		for i := range 30 {
			f.Occurrences = append(f.Occurrences, domain.CIOccurrence{RunID: int64(100 + i), At: now})
		}
		f.Status, f.TicketKey, f.FixedAt = domain.CIFixing, "CI-1", &now
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	g, _ = ci.CIFailure(ctx, g.ID)
	if len(g.Occurrences) != domain.MaxCIOccurrences || g.Status != domain.CIFixing || g.FixedAt == nil {
		t.Fatalf("after update %+v", g)
	}
	if byTicket, err := ci.CIFailureByTicket(ctx, "CI-1"); err != nil || byTicket.ID != g.ID {
		t.Fatalf("by ticket %v", err)
	}
	if got, _ := ci.ListCIFailures(ctx, domain.CIFilter{Statuses: []domain.CIStatus{domain.CIOpen}}); len(got) != 0 {
		t.Fatalf("status filter %+v", got)
	}
	if n, err := ci.AutoCITickets(ctx, now.Add(-time.Hour)); err != nil || n != 0 {
		t.Fatalf("auto tickets %d %v", n, err)
	}
}

func TestReopenForCI(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	pr := 7
	tk, err := s.CreateTicket(ctx, domain.Ticket{Key: "API-1", Source: domain.SourceLocal, RepoID: &repo.ID, Title: "x", Priority: "high",
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr", Kind: domain.KindCode, Branch: "agnts/API-1", PRNumber: &pr},
		domain.Event{Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	ev := domain.Event{TicketKey: tk.Key, Type: domain.EventFeedback, Message: "CI failed"}
	if _, err := s.ReopenForCI(ctx, tk.Key, ev, nil); err == nil {
		t.Fatal("reopened a ticket that is not done")
	}
	if _, err := users.db.Exec(ctx, `UPDATE tickets SET state = 'done' WHERE key = 'API-1'`); err != nil {
		t.Fatal(err)
	}
	out, err := s.ReopenForCI(ctx, tk.Key, ev, func(x *domain.Ticket) { x.CIFixes++; x.Feedback = "fix it" })
	if err != nil || out.State != domain.StateCoding || out.CIFixes != 1 || out.Feedback != "fix it" {
		t.Fatalf("reopen: %+v %v", out, err)
	}
	if _, err := users.db.Exec(ctx, `UPDATE tickets SET state = 'done', merged_at = now() WHERE key = 'API-1'`); err != nil {
		t.Fatal(err)
	}
	if _, err := s.ReopenForCI(ctx, tk.Key, ev, nil); err == nil {
		t.Fatal("reopened a merged ticket")
	}
}
