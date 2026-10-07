package orchestrator_test

import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"slices"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// memShots keeps screenshots in memory, keyed ticket/run/id.
type memShots struct {
	mu sync.Mutex
	m  map[string][]byte
}

func shotKey(key string, run int64, id string) string { return fmt.Sprintf("%s/%d/%s", key, run, id) }

func (s *memShots) Save(key string, run int64, id string, png []byte) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m[shotKey(key, run, id)] = png
	return nil
}

func (s *memShots) Open(key string, run int64, id string) (io.ReadCloser, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	b, ok := s.m[shotKey(key, run, id)]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return io.NopCloser(bytes.NewReader(b)), nil
}

func (s *memShots) Prune(key string, keep []int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for k := range s.m {
		var run int64
		var rest string
		if !strings.HasPrefix(k, key+"/") {
			continue
		}
		_, _ = fmt.Sscanf(strings.TrimPrefix(k, key+"/"), "%d/%s", &run, &rest)
		if !slices.Contains(keep, run) {
			delete(s.m, k)
		}
	}
	return nil
}

func (s *memShots) Tickets() ([]string, error) { return nil, nil }

func (s *memShots) count(key string) int {
	s.mu.Lock()
	defer s.mu.Unlock()
	n := 0
	for k := range s.m {
		if strings.HasPrefix(k, key+"/") {
			n++
		}
	}
	return n
}

type fakeEnvs struct{}

func (fakeEnvs) PreviewEnv(context.Context, int64) (string, error) {
	return "VITE_API_URL=https://staging.example.com", nil
}

// png returns a minimal PNG header of the given size.
func png(w, h uint32) string {
	var b bytes.Buffer
	b.WriteString("\x89PNG\r\n\x1a\n")
	_ = binary.Write(&b, binary.BigEndian, uint32(13))
	b.WriteString("IHDR")
	_ = binary.Write(&b, binary.BigEndian, w)
	_ = binary.Write(&b, binary.BigEndian, h)
	b.WriteString("rest")
	return b.String()
}

// withPreview gives the harness repository a preview command.
func (h *harness) withPreview(uiPaths ...string) {
	h.t.Helper()
	repo, err := h.store.RepositoryByID(h.ctx, 1)
	if err != nil {
		h.t.Fatal(err)
	}
	repo.Preview = domain.PreviewConfig{Command: "npm run dev", Port: 5173, ReadyPath: "/", UIPaths: uiPaths,
		Routes: []string{"/tickets"}, Login: "demo / demo"}
	if _, err := h.store.UpdateRepository(h.ctx, repo); err != nil {
		h.t.Fatal(err)
	}
}

func previewJSON(shots []map[string]any, issues []map[string]any) string {
	if issues == nil {
		issues = []map[string]any{}
	}
	b, _ := json.Marshal(map[string]any{"status": "ok", "summary": "The tab bar wraps on phones.", "shots": shots, "issues": issues})
	return string(b)
}

func TestPreviewBesideHumanReview(t *testing.T) {
	h := newHarness(t)
	h.withPreview("**/*.go")
	h.toReview("PAY-1", analysis(0))
	tk := h.state("PAY-1")
	if tk.PreviewState != domain.PreviewPending || tk.ReviewState != domain.ReviewNone {
		t.Fatalf("after coding: preview %q review %q", tk.PreviewState, tk.ReviewState)
	}
	// The coding prompt explains how to look at the app.
	if p := h.runner.prompts[1]; !strings.Contains(p, "agnts-preview start") || !strings.Contains(p, "http://localhost:5173") {
		t.Fatalf("coding prompt has no visual check:\n%s", p)
	}

	h.runner.scripts = []script{{result: ok("p1"), files: map[string]string{
		orchestrator.PreviewPath: previewJSON([]map[string]any{
			{"id": "tickets-desktop-after", "file": "shots/tickets-desktop-after.png", "name": "Tickets", "route": "/tickets", "viewport": "desktop", "side": "after"},
			{"id": "tickets-phone-after", "file": "shots/tickets-phone-after.png", "name": "Tickets", "route": "/tickets", "viewport": "phone", "side": "after"},
			{"id": "notpng-phone-after", "file": "shots/notpng-phone-after.png", "viewport": "phone"},
			{"id": "escape-phone-after", "file": "../../etc/passwd", "viewport": "phone"},
			{"id": "Bad ID", "file": "shots/x.png", "viewport": "phone"},
		}, []map[string]any{
			{"severity": "medium", "description": "Tabs wrap", "shotId": "tickets-phone-after"},
			{"severity": "HIGH", "description": "Shown on a dropped shot", "shotId": "notpng-phone-after"},
		}),
		"/agnts/out/shots/tickets-desktop-after.png": png(1440, 900),
		"/agnts/out/shots/tickets-phone-after.png":   png(390, 844),
		"/agnts/out/shots/notpng-phone-after.png":    "plain text",
	}}}
	h.step() // preview
	tk = h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.PreviewState != domain.PreviewDone {
		t.Fatalf("preview state: %q", tk.PreviewState)
	}
	h.idle()

	prompt := h.runner.prompts[len(h.runner.prompts)-1]
	for _, want := range []string{"http://localhost:5173", "agnts-shot", orchestrator.PreviewPath, "/tickets", "demo / demo", "main.go (+3 −1)"} {
		if !strings.Contains(prompt, want) {
			t.Fatalf("preview prompt lacks %q:\n%s", want, prompt)
		}
	}
	if strings.Contains(prompt, "agnts-preview base") {
		t.Fatal("before shots asked for without compare")
	}

	v, err := h.o.View(h.ctx, "PAY-1")
	if err != nil || v.Preview == nil || !v.CanPreview {
		t.Fatalf("view: %+v %v", v.Preview, err)
	}
	p := v.Preview
	if p.Status != domain.PreviewOK || len(p.Shots) != 2 || p.Model != "sonnet" || p.RunID == 0 {
		t.Fatalf("preview: %+v", p)
	}
	if s := p.Shots[0]; s.Width != 1440 || s.Height != 900 || s.File != "" {
		t.Fatalf("first shot: %+v", s)
	}
	if len(p.Issues) != 2 || p.Issues[0].Severity != "high" || p.Issues[0].ShotID != "" || p.Issues[1].ShotID != "tickets-phone-after" {
		t.Fatalf("issues: %+v", p.Issues)
	}
	if n := h.shots.count("PAY-1"); n != 2 {
		t.Fatalf("stored %d screenshots", n)
	}
	rc, err := h.o.OpenShot(h.ctx, "PAY-1", p.RunID, "tickets-phone-after")
	if err != nil {
		t.Fatal(err)
	}
	_ = rc.Close()
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-1"})
	found := false
	for _, e := range evs {
		if e.Type == domain.EventPreview && e.Message == "preview: 2 screenshots, 2 issues" {
			found = true
		}
	}
	if !found {
		t.Fatal("no preview_done event")
	}

	// Feedback pointing at a screenshot: the coding run gets it.
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Fix the tabs", []domain.ShotRef{{RunID: p.RunID, ShotID: "nope"}}, nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown screenshot accepted: %v", err)
	}
	ref := domain.ShotRef{RunID: p.RunID, ShotID: "tickets-phone-after"}
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Fix the tabs", []domain.ShotRef{ref, ref}, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-1"); len(tk.FeedbackShots) != 1 || tk.Revision != 1 {
		t.Fatalf("after feedback: %+v revision %d", tk.FeedbackShots, tk.Revision)
	}
	h.runner.scripts = []script{{result: ok("s2"), edit: "v2"}}
	h.step()
	tk = h.expect("PAY-1", domain.StateWaitingForReview)
	fb := h.runner.prompts[len(h.runner.prompts)-1]
	want := fmt.Sprintf("/agnts/out/feedback-%d-tickets-phone-after.png", p.RunID)
	if !strings.Contains(fb, want) || !strings.Contains(fb, "Fix the tabs") {
		t.Fatalf("feedback prompt lacks the screenshot %s:\n%s", want, fb)
	}
	if len(tk.FeedbackShots) != 0 || tk.PreviewState != domain.PreviewPending {
		t.Fatalf("after the feedback run: %+v %q", tk.FeedbackShots, tk.PreviewState)
	}
}

func TestPreviewOnlyForUIChanges(t *testing.T) {
	h := newHarness(t)
	h.withPreview("web/**/*.vue")
	h.toReview("PAY-1", analysis(0))
	if tk := h.state("PAY-1"); tk.PreviewState != domain.PreviewNone {
		t.Fatalf("a change outside the UI paths got a preview: %q", tk.PreviewState)
	}
	h.idle()

	// Asked for by hand, with the default branch for comparison.
	yes := true
	tk, err := h.o.Preview(h.ctx, "PAY-1", &yes, domain.OriginWeb)
	if err != nil || tk.PreviewState != domain.PreviewPending || !tk.PreviewCompare {
		t.Fatalf("manual preview: %+v %v", tk, err)
	}
	h.runner.scripts = []script{{result: ok("p1"), files: map[string]string{orchestrator.PreviewPath: previewJSON(nil, nil)}}}
	h.step()
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "agnts-preview base") {
		t.Fatalf("compare not in prompt:\n%s", p)
	}
	v, _ := h.o.View(h.ctx, "PAY-1")
	if v.Preview == nil || v.Preview.Status != domain.PreviewPartial || !v.Preview.Compare {
		t.Fatalf("a preview with no screenshots: %+v", v.Preview)
	}
}

func TestPreviewAppDoesNotStart(t *testing.T) {
	h := newHarness(t)
	h.withPreview()
	h.toReview("PAY-1", analysis(0))
	h.runner.execs["agnts-preview start"] = []orchestrator.ExecResult{{ExitCode: 1, Output: "npm ERR! Missing script: \"dev\""}}
	calls := len(h.runner.prompts)
	h.step()
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.PreviewState != domain.PreviewDone || len(h.runner.prompts) != calls {
		t.Fatalf("state %q, claude calls %d -> %d", tk.PreviewState, calls, len(h.runner.prompts))
	}
	v, _ := h.o.View(h.ctx, "PAY-1")
	if v.Preview == nil || v.Preview.Status != domain.PreviewBroken || !strings.Contains(v.Preview.Summary, "Missing script") {
		t.Fatalf("preview: %+v", v.Preview)
	}
}

func TestPreviewDroppedOnApproveAndRequeuedOnRateLimit(t *testing.T) {
	h := newHarness(t)
	h.withPreview()
	h.toReview("PAY-1", analysis(0))
	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{RateLimited: true}}}
	h.step()
	if tk := h.state("PAY-1"); tk.PreviewState != domain.PreviewPending {
		t.Fatalf("rate-limited preview: %q", tk.PreviewState)
	}
	h.usage.paused = false
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-1"); tk.PreviewState != domain.PreviewNone {
		t.Fatalf("approved ticket keeps its preview: %q", tk.PreviewState)
	}
	if _, err := h.o.Preview(h.ctx, "PAY-1", nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("preview outside review: %v", err)
	}
}
