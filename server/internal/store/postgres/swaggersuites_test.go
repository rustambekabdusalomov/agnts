package postgres

import (
	"bytes"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestSwaggerSuites(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	other, _ := testWS(t, users)
	box, _ := secret.NewBox(bytes.Repeat([]byte{8}, 32))
	s := NewSwaggerSuites(users.db, box)

	tok := "suite-token-123456"
	su, err := s.SaveSuite(ctx, domain.SwaggerSuite{Name: "Shop", Spec: json.RawMessage(`{"openapi":"3.0.3"}`), BaseURL: "https://staging.test",
		Operations: []string{"GET /a", "GET /b"}, Auth: domain.APIAuth{Kind: domain.AuthBearer}, Schedule: domain.ScheduleHourly, Enabled: true}, &tok)
	if err != nil || su.ID == 0 || !su.HasSecret || su.NextRunAt == nil || len(su.Operations) != 2 {
		t.Fatalf("%+v %v", su, err)
	}
	if v, _ := s.SuiteAuth(ctx, su.ID); v != tok {
		t.Errorf("auth = %q", v)
	}
	if _, err := s.Suite(other, su.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("another workspace reads the suite: %v", err)
	}
	if list, _ := s.Suites(other); len(list) != 0 {
		t.Error("another workspace lists the suite")
	}

	// Due: across workspaces, once its next run has come.
	due, err := s.DueSuites(ctx, time.Now().Add(2*time.Hour))
	if err != nil || len(due) != 1 || due[0].ID != su.ID || due[0].Workspace != ws {
		t.Fatalf("due: %+v %v", due, err)
	}
	if due, _ := s.DueSuites(ctx, time.Now()); len(due) != 0 {
		t.Errorf("due before its time: %+v", due)
	}
	if err := s.MarkSuiteRun(ctx, su.ID, "TASK-3", time.Now().Add(3*time.Hour)); err != nil {
		t.Fatal(err)
	}
	got, _ := s.Suite(ctx, su.ID)
	if got.LastTicketKey != "TASK-3" || got.LastRunAt == nil || !got.NextRunAt.After(time.Now().Add(3*time.Hour)) {
		t.Errorf("after a run: %+v", got)
	}

	// The deploy hook finds the suite from any workspace's context.
	if err := s.SetSuiteHook(ctx, su.ID, "hash-1"); err != nil {
		t.Fatal(err)
	}
	if h, w, err := s.SuiteByHook(other, "hash-1"); err != nil || h.ID != su.ID || w != ws {
		t.Errorf("by hook: %+v %d %v", h, w, err)
	}
	if _, _, err := s.SuiteByHook(ctx, "nope"); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("an unknown hook: %v", err)
	}

	// Edit without a token keeps it; pausing stops it from being due.
	su.Name, su.Enabled = "Shop API", false
	if su, err = s.SaveSuite(ctx, su, nil); err != nil || su.Name != "Shop API" || !su.HasSecret {
		t.Fatalf("update: %+v %v", su, err)
	}
	if due, _ := s.DueSuites(ctx, time.Now().Add(48*time.Hour)); len(due) != 0 {
		t.Errorf("a paused suite is due: %+v", due)
	}
	if err := s.DeleteSuite(ctx, su.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := s.Suite(ctx, su.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("after delete: %v", err)
	}
}
