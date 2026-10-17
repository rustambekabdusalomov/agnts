package postgres_test

import (
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"io"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

func gz(s string) []byte {
	var b bytes.Buffer
	w := gzip.NewWriter(&b)
	_, _ = io.WriteString(w, s)
	_ = w.Close()
	return b.Bytes()
}

func TestTranscriptsLifecycle(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	_, wsA := pgtest.Workspace(t, pool, "tr-a")
	ctxB, wsB := pgtest.Workspace(t, pool, "tr-b")
	sys := domain.System(context.Background())
	s := postgres.NewTranscripts(pool)

	// Background loops act with a system scope: the workspace is given.
	id, err := s.StartTranscript(sys, domain.TranscriptStart{WorkspaceID: wsA, Purpose: domain.PurposeBrief, Subject: "api",
		Engine: "claude", Model: "sonnet", Prompt: gz("survey the repo")})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.StartTranscript(sys, domain.TranscriptStart{Purpose: domain.PurposeBrief, Engine: "claude"}); err == nil {
		t.Fatal("a transcript without a workspace was stored")
	}
	if err := s.AppendTranscript(sys, id, gz(`{"k":"text","t":1,"text":"one"}`+"\n"), domain.TranscriptCounts{RawBytes: 30}); err != nil {
		t.Fatal(err)
	}
	if err := s.FinishTranscript(sys, id, gz(`{"k":"result","t":2,"subtype":"success"}`+"\n"), domain.TranscriptEnd{
		Status: domain.TranscriptDone, ExitReason: "success", Turns: 4, Stalls: 1,
		Usage:  domain.TokenUsage{Input: 100, Output: 20, CostUSD: 0.25},
		Counts: domain.TranscriptCounts{RawBytes: 70, ToolCalls: 2, ToolErrors: 1},
	}); err != nil {
		t.Fatal(err)
	}
	got, err := s.Transcript(sys, id)
	if err != nil || got.Status != domain.TranscriptDone || got.Turns != 4 || got.Stalls != 1 || got.Usage.CostUSD != 0.25 ||
		got.WorkspaceSlug != "tr-a" || got.Subject != "api" || got.FinishedAt == nil || got.StoredBytes == 0 {
		t.Fatalf("transcript %+v %v", got, err)
	}
	body, err := s.TranscriptBody(sys, id)
	if err != nil {
		t.Fatal(err)
	}
	zr, err := gzip.NewReader(bytes.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	all, _ := io.ReadAll(zr)
	if string(all) != "{\"k\":\"text\",\"t\":1,\"text\":\"one\"}\n{\"k\":\"result\",\"t\":2,\"subtype\":\"success\"}\n" {
		t.Fatalf("body %q", all)
	}

	// Row-level security: another workspace cannot see it.
	if _, err := s.Transcript(ctxB, id); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("workspace B read A's transcript: %v", err)
	}
	if _, err := s.StartTranscript(ctxB, domain.TranscriptStart{WorkspaceID: wsA, Purpose: "code", Engine: "claude"}); err == nil {
		t.Fatal("workspace B wrote a transcript into A")
	}
	if _, err := s.StartTranscript(ctxB, domain.TranscriptStart{WorkspaceID: wsB, Purpose: "code", Engine: "codex", Model: "codex:gpt-5"}); err != nil {
		t.Fatal(err)
	}

	// A crash leaves these running (B's and the next one): start-up closes
	// them, keeping what was appended.
	run, err := s.StartTranscript(sys, domain.TranscriptStart{WorkspaceID: wsA, Purpose: "code", TicketKey: "PAY-7", Engine: "claude"})
	if err != nil {
		t.Fatal(err)
	}
	_ = s.AppendTranscript(sys, run, gz(`{"k":"text","t":1}`+"\n"), domain.TranscriptCounts{RawBytes: 19})
	if n, err := s.RecoverTranscripts(sys); err != nil || n != 2 {
		t.Fatalf("recover: %d %v", n, err)
	}
	got, _ = s.Transcript(sys, run)
	if got.Status != domain.TranscriptError || got.ExitReason != "server restarted" || got.StoredBytes == 0 {
		t.Fatalf("recovered %+v", got)
	}

	// Filters, paging and the summary.
	list, err := s.ListTranscripts(sys, domain.TranscriptFilter{Limit: 2})
	if err != nil || len(list) != 2 || list[0].ID != run {
		t.Fatalf("page 1: %+v %v", list, err)
	}
	next, err := s.ListTranscripts(sys, domain.TranscriptFilter{Limit: 2, BeforeAt: list[1].StartedAt, BeforeID: list[1].ID})
	if err != nil || len(next) != 1 || next[0].ID != id {
		t.Fatalf("page 2: %+v %v", next, err)
	}
	for _, tc := range []struct {
		f    domain.TranscriptFilter
		want int
	}{
		{domain.TranscriptFilter{WorkspaceID: wsB}, 1},
		{domain.TranscriptFilter{Purpose: "background"}, 1},
		{domain.TranscriptFilter{Purpose: "stages"}, 2},
		{domain.TranscriptFilter{Engine: "codex"}, 1},
		{domain.TranscriptFilter{Model: "GPT"}, 1},
		{domain.TranscriptFilter{TicketKey: "pay-"}, 1},
		{domain.TranscriptFilter{Stalled: true}, 1},
		{domain.TranscriptFilter{MinCost: 0.2}, 1},
		{domain.TranscriptFilter{Status: domain.TranscriptError}, 2},
		{domain.TranscriptFilter{Status: domain.TranscriptRunning}, 0},
		{domain.TranscriptFilter{From: time.Now().Add(time.Hour)}, 0},
	} {
		got, err := s.ListTranscripts(sys, tc.f)
		if err != nil || len(got) != tc.want {
			t.Errorf("filter %+v: %d rows, want %d (%v)", tc.f, len(got), tc.want, err)
		}
	}
	sum, err := s.TranscriptSummary(sys, domain.TranscriptFilter{WorkspaceID: wsA})
	if err != nil || sum.Count != 2 || sum.Errors != 1 || sum.Stalled != 1 || sum.CostUSD != 0.25 || sum.BackgroundCost != 0.25 || sum.InputTokens != 100 {
		t.Fatalf("summary %+v %v", sum, err)
	}

	// Retention keeps running ones and newer ones.
	pgtest.Exec(t, pool, `UPDATE transcripts SET started_at = now() - interval '40 days' WHERE id = $1`, id)
	if n, err := s.PruneTranscripts(sys, time.Now().AddDate(0, 0, -30)); err != nil || n != 1 {
		t.Fatalf("prune: %d %v", n, err)
	}
	if _, err := s.Transcript(sys, id); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("pruned transcript still there: %v", err)
	}
}

func TestRunHistorySettingsAndAudit(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	_, ws := pgtest.Workspace(t, pool, "audit-ws")
	sys := domain.System(context.Background())
	s := postgres.NewTranscripts(pool)

	if v, err := s.RunHistorySettings(sys); err != nil || v != domain.DefaultRunHistory {
		t.Fatalf("defaults %+v %v", v, err)
	}
	if v, err := s.SetRunHistorySettings(sys, domain.RunHistorySettings{RetentionDays: 7, ToolOutputKB: 2000, TextKB: 8, TranscriptMB: 4}); err != nil ||
		v.ToolOutputKB != 1024 || v.RetentionDays != 7 {
		t.Fatalf("set %+v %v", v, err)
	}
	if v, _ := s.RunHistorySettings(sys); v.RetentionDays != 7 || v.TextKB != 8 {
		t.Fatalf("read back %+v", v)
	}

	// The audit log outlives the Admin account.
	admin := pgtest.User(t, pool, "audit-admin")
	if err := s.Audit(sys, domain.AdminAudit{AdminID: &admin, AdminName: "audit-admin", Action: domain.AuditTranscriptView,
		Target: "transcript:1", WorkspaceID: &ws, IP: "203.0.113.9"}); err != nil {
		t.Fatal(err)
	}
	pgtest.Exec(t, pool, `DELETE FROM users WHERE id = $1`, admin)
	rows, err := s.ListAudit(sys, postgres.AuditFilter{})
	if err != nil || len(rows) != 1 || rows[0].AdminID != nil || rows[0].AdminName != "audit-admin" || rows[0].Workspace != "audit-ws" {
		t.Fatalf("audit %+v %v", rows, err)
	}
	if rows, _ := s.ListAudit(sys, postgres.AuditFilter{Action: "transcript.prompt"}); len(rows) != 0 {
		t.Fatalf("action filter: %+v", rows)
	}
}
