package postgres

import (
	"bytes"
	"errors"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestLogStore(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	box, _ := secret.NewBox(make([]byte, 32))
	logs := NewLogs(users.db, box)

	api, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	web, err := s.SaveRepository(ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/web.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}

	// Sources: credentials are sealed, returned only when asked for.
	src := domain.LogSource{Name: "prod-loki", Kind: domain.LogLoki, Address: "https://loki.acme.com", Enabled: true,
		Auth: domain.LogAuth{Kind: "bearer", Token: "tok-123", Tenant: "acme"}, Scope: domain.LogScope{Selector: `{env="prod"}`}}
	if err := src.Normalize(); err != nil {
		t.Fatal(err)
	}
	src, err = logs.SaveLogSource(ctx, src, false)
	if err != nil {
		t.Fatal(err)
	}
	if src.Auth.Token != "" || !src.HasAuth || src.Auth.Tenant != "acme" || src.PollSeconds != 15 {
		t.Fatalf("saved source %+v", src)
	}
	if full, _ := logs.LogSource(ctx, src.ID, true); full.Auth.Token != "tok-123" {
		t.Fatalf("credentials not kept: %+v", full.Auth)
	}
	src.PollSeconds = 60
	if src, err = logs.SaveLogSource(ctx, src, true); err != nil || src.PollSeconds != 60 {
		t.Fatalf("update %v %+v", err, src)
	}
	if full, _ := logs.LogSource(ctx, src.ID, true); full.Auth.Token != "tok-123" {
		t.Fatal("keepAuth must keep the credentials")
	}
	if _, err := logs.SaveLogSource(ctx, domain.LogSource{Name: "prod-loki", Kind: domain.LogLoki, Address: "https://x", PollSeconds: 15, Environment: "production"}, false); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("duplicate name: %v", err)
	}

	// Services: a gateway runs on two repositories.
	svcs, err := logs.SetLogServices(ctx, src.ID, []domain.LogService{
		{Name: "gateway", Selector: `{service_name="gateway"}`, RepoIDs: []int64{web.ID, api.ID}, Enabled: true},
		{Name: "worker", Selector: `{service_name="worker"}`, Enabled: true},
	})
	if err != nil || len(svcs) != 2 || len(svcs[0].RepoIDs) != 2 || svcs[0].RepoIDs[0] != web.ID {
		t.Fatalf("services %+v %v", svcs, err)
	}
	gwID := svcs[0].ID
	svcs, _ = logs.SetLogServices(ctx, src.ID, []domain.LogService{{Name: "gateway", Selector: `{app="gw"}`, RepoIDs: []int64{api.ID}, Enabled: true}})
	if len(svcs) != 1 || svcs[0].ID != gwID || svcs[0].Selector != `{app="gw"}` {
		t.Fatalf("services kept by name %+v", svcs)
	}

	// Push tokens.
	push := domain.LogSource{Name: "shipper", Kind: domain.LogPush, Enabled: true}
	_ = push.Normalize()
	push, err = logs.SaveLogSource(ctx, push, false)
	if err != nil {
		t.Fatal(err)
	}
	if err := logs.SetLogPushToken(ctx, push.ID, []byte("hash1")); err != nil {
		t.Fatal(err)
	}
	if got, err := logs.LogSourceByPushToken(domain.System(ctx), []byte("hash1")); err != nil || got.ID != push.ID || got.WorkspaceID == 0 {
		t.Fatalf("by token %+v %v", got, err)
	}
	if _, err := logs.LogSourceByPushToken(domain.System(ctx), []byte("nope")); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unknown token: %v", err)
	}
	if pulls, _ := logs.PullSources(domain.System(ctx)); len(pulls) != 1 || pulls[0].ID != src.ID || pulls[0].Auth.Token != "tok-123" {
		t.Fatalf("pull sources %+v", pulls)
	}

	// Read state.
	now := time.Now().UTC().Truncate(time.Second)
	if err := logs.SaveLogRead(ctx, src.ID, LogReadState{Cursor: domain.LogCursor{Time: now, Seen: []string{"a"}}, Status: domain.LogSourceOK, ReadAt: &now, Dropped: 5}); err != nil {
		t.Fatal(err)
	}
	if got, _ := logs.LogSource(ctx, src.ID, false); !got.Cursor.Time.Equal(now) || got.Status != domain.LogSourceOK || got.Dropped != 5 {
		t.Fatalf("read state %+v", got)
	}

	// The key is made once and kept.
	k1, err := logs.LogKey(ctx)
	if err != nil || len(k1) != 32 {
		t.Fatalf("key %v %d", err, len(k1))
	}
	if k2, _ := logs.LogKey(ctx); !bytes.Equal(k1, k2) {
		t.Fatal("the key must be stable")
	}

	// Concurrent upserts of one fingerprint end in one finding.
	key := domain.LogFinding{Scope: domain.LogScopeKey(src.ID, "gateway", []int64{api.ID}), Service: "gateway", RepoIDs: []int64{api.ID},
		Category: domain.LogErrors, Detector: "panic", Class: domain.LogClassCode, Severity: domain.LogHigh, Fingerprint: "fp1", Title: "panic: x"}
	var wg sync.WaitGroup
	for range 8 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			_, err := logs.UpsertLogFinding(ctx, key, "sample", func(f *domain.LogFinding, isNew bool) error {
				f.Count++
				return nil
			})
			if err != nil {
				t.Error(err)
			}
		}()
	}
	wg.Wait()
	list, err := logs.ListLogFindings(ctx, domain.LogFindingFilter{RepoID: api.ID})
	if err != nil || len(list) != 1 || list[0].Count != 8 || list[0].RepoNames[0] != "api" {
		t.Fatalf("findings %+v %v", list, err)
	}
	f, _ := logs.LogFinding(ctx, list[0].ID)
	if f.Sample != "sample" || f.SampleAt == nil {
		t.Fatalf("sample %q", f.Sample)
	}
	// A hot finding keeps its sample for ten minutes.
	_, _ = logs.UpsertLogFinding(ctx, key, "newer", func(f *domain.LogFinding, isNew bool) error { f.Count++; return nil })
	if f, _ = logs.LogFinding(ctx, f.ID); f.Sample != "sample" {
		t.Fatalf("sample replaced too soon: %q", f.Sample)
	}
	// A status change replaces it.
	_, _ = logs.UpsertLogFinding(ctx, key, "newest", func(f *domain.LogFinding, isNew bool) error { f.Status = domain.LogReported; return nil })
	if f, _ = logs.LogFinding(ctx, f.ID); f.Sample != "newest" {
		t.Fatalf("sample not replaced on a status change: %q", f.Sample)
	}

	// Merging scopes: an unmapped finding moves into the repositories'.
	unmapped := domain.LogScopeKey(src.ID, "worker", nil)
	_, _ = logs.UpsertLogFinding(ctx, domain.LogFinding{Scope: unmapped, Service: "worker", Category: domain.LogErrors, Detector: "error",
		Severity: domain.LogMedium, Fingerprint: "fp1", Title: "panic: x"}, "", func(f *domain.LogFinding, isNew bool) error { f.Count = 3; return nil })
	_, _ = logs.UpsertLogFinding(ctx, domain.LogFinding{Scope: unmapped, Service: "worker", Category: domain.LogErrors, Detector: "error",
		Severity: domain.LogMedium, Fingerprint: "fp2", Title: "other"}, "", func(f *domain.LogFinding, isNew bool) error { f.Count = 1; return nil })
	if err := logs.MergeLogScope(ctx, unmapped, key.Scope, []int64{api.ID}); err != nil {
		t.Fatal(err)
	}
	list, _ = logs.ListLogFindings(ctx, domain.LogFindingFilter{})
	if len(list) != 2 {
		t.Fatalf("after merge %+v", list)
	}
	for _, x := range list {
		if x.Scope != key.Scope {
			t.Errorf("scope %q", x.Scope)
		}
		if x.Fingerprint == "fp1" && x.Count != 12 { // 9 sightings + the unmapped 3
			t.Errorf("merged count %d, want 12", x.Count)
		}
	}

	// Updates and tickets.
	u, err := logs.UpdateLogFinding(ctx, f.ID, func(f *domain.LogFinding) error { f.TicketKey = "LOG-1"; f.Status = domain.LogFixing; return nil })
	if err != nil || u.Status != domain.LogFixing {
		t.Fatal(err)
	}
	if got, err := logs.LogFindingByTicket(ctx, "LOG-1"); err != nil || got.ID != f.ID {
		t.Fatalf("by ticket %+v %v", got, err)
	}
	if active, _ := logs.ListLogFindings(ctx, domain.LogFindingFilter{Active: true}); len(active) != 2 {
		t.Fatalf("active %d", len(active))
	}

	// Another workspace sees none of it.
	other, _ := testWS(t, users)
	if got, _ := logs.LogSources(other); len(got) != 0 {
		t.Fatalf("other workspace sees %d sources", len(got))
	}
	if got, _ := logs.ListLogFindings(other, domain.LogFindingFilter{}); len(got) != 0 {
		t.Fatalf("other workspace sees %d findings", len(got))
	}

	if err := logs.DeleteLogSource(ctx, src.ID); err != nil {
		t.Fatal(err)
	}
	if list, _ = logs.ListLogFindings(ctx, domain.LogFindingFilter{}); len(list) != 2 {
		t.Fatal("findings are kept when their source goes")
	}
}
