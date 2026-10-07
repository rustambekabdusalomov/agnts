package orchestrator_test

import (
	"bytes"
	"errors"
	"strconv"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var pngBytes = append([]byte("\x89PNG\r\n\x1a\n"), bytes.Repeat([]byte{0}, 32)...)

func TestUploadChecksFiles(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.Upload(h.ctx, "a.txt", nil); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("empty file: %v", err)
	}
	if _, err := h.o.Upload(h.ctx, "a.bin", make([]byte, domain.MaxAttachmentBytes+1)); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("large file: %v", err)
	}
	cases := []struct {
		name string
		data []byte
		want string
	}{
		{"../../etc/shot.png", pngBytes, "image/png"},
		{"fake.png", []byte("<html><script>alert(1)</script>"), "application/octet-stream"}, // not a picture, whatever it is called
		{"notes.md", []byte("# Notes"), "text/markdown"},
		{"spec.pdf", []byte("%PDF-1.7 ..."), "application/pdf"},
	}
	for _, c := range cases {
		a, err := h.o.Upload(h.ctx, c.name, c.data)
		if err != nil || a.ContentType != c.want || a.Purpose != domain.AttachPending || strings.Contains(a.Name, "/") {
			t.Errorf("%s: %+v %v (want %s)", c.name, a, err, c.want)
		}
	}
}

func TestAttachmentsReachClaude(t *testing.T) {
	h := newHarness(t)
	repo := h.sideRepo()
	shot, err := h.o.Upload(h.ctx, "login screen.png", pngBytes)
	if err != nil {
		t.Fatal(err)
	}
	spare, _ := h.o.Upload(h.ctx, "spare.txt", []byte("x"))
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "Fix the login screen", Priority: "high",
		AfterApprove: "pr", Start: "ask", Attachments: &[]int64{shot.ID, shot.ID}}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	// A linked upload cannot be used or deleted again.
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "x", Priority: "low", AfterApprove: "pr", Start: "queue",
		Attachments: &[]int64{shot.ID}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("reused upload: %v", err)
	}
	if err := h.o.DeleteUpload(h.ctx, shot.ID); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("delete attached file: %v", err)
	}

	multi := `{"summary":"s","plan":["p"],"questions":[{"text":"Which screens?","options":["login","signup","reset"],"multiple":true},{"text":"Style?","options":["a","b"]}]}`
	h.runner.scripts = []script{
		{result: ok("t1"), files: map[string]string{orchestrator.AnalysisPath: multi}},
		{result: ok("t1"), edit: "x"},
	}
	h.step()
	h.expect(tk.Key, domain.StateWaitingForAnswers)
	path := "/agnts/out/attachment-" + itoa(shot.ID) + "-login_screen.png"
	if !strings.Contains(h.runner.prompts[0], path) {
		t.Fatalf("analysis prompt lacks the attachment:\n%s", h.runner.prompts[0])
	}

	v, err := h.o.View(h.ctx, tk.Key)
	if err != nil || len(v.Questions) != 2 || !v.Questions[0].Multiple || v.Questions[1].Multiple || len(v.Attachments) != 1 {
		t.Fatalf("view: %+v %v", v.Questions, err)
	}
	mock, _ := h.o.Upload(h.ctx, "mock.png", pngBytes)
	_, err = h.o.Answer(h.ctx, tk.Key, []domain.Answer{
		{QuestionID: v.Questions[0].ID, Answer: domain.JoinChoices([]string{"login", "reset"}), Attachments: []int64{mock.ID}},
		{QuestionID: v.Questions[1].ID, Answer: "a"},
	}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect(tk.Key, domain.StateWaitingForReview)
	code := h.runner.prompts[1]
	if !strings.Contains(code, "A: login; reset") || !strings.Contains(code, "Attached to this answer (read them): /agnts/out/attachment-"+itoa(mock.ID)+"-mock.png") ||
		!strings.Contains(code, path) {
		t.Fatalf("coding prompt lacks answers or files:\n%s", code)
	}
	v, _ = h.o.View(h.ctx, tk.Key)
	if len(v.Attachments) != 2 || v.Attachments[1].Purpose != domain.AttachAnswer || *v.Attachments[1].QuestionID != v.Questions[0].ID {
		t.Fatalf("attachments: %+v", v.Attachments)
	}
	if err := h.o.DeleteUpload(h.ctx, spare.ID); err != nil {
		t.Fatalf("delete pending upload: %v", err)
	}
}

func TestUpdateTaskFiles(t *testing.T) {
	h := newHarness(t)
	repo := h.sideRepo()
	a, _ := h.o.Upload(h.ctx, "a.png", pngBytes)
	b, _ := h.o.Upload(h.ctx, "b.png", pngBytes)
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "x", Priority: "low", AfterApprove: "pr", Start: "queue",
		Attachments: &[]int64{a.ID}}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.UpdateTask(h.ctx, tk.Key, orchestrator.TaskInput{Attachments: &[]int64{b.ID}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	v, _ := h.o.View(h.ctx, tk.Key)
	if len(v.Attachments) != 1 || v.Attachments[0].ID != b.ID {
		t.Fatalf("after edit: %+v", v.Attachments)
	}
	// Leaving the list out keeps the files.
	if _, err := h.o.UpdateTask(h.ctx, tk.Key, orchestrator.TaskInput{Title: "y"}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if v, _ = h.o.View(h.ctx, tk.Key); len(v.Attachments) != 1 {
		t.Fatalf("files dropped: %+v", v.Attachments)
	}
}

func TestRetryWithFiles(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-8")
	h.runner.scripts = []script{
		{result: ok("s8"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s8"), edit: "v1"},
		{result: ok("s8"), edit: "v2"},
		{result: ok("s8"), edit: "v3"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}
	h.step()
	h.step()
	h.expect("PAY-8", domain.StateFailed)

	log, _ := h.o.Upload(h.ctx, "ci.log", []byte("panic: nil map"))
	tk, err := h.o.RetryWithNote(h.ctx, "PAY-8", "", []int64{log.ID}, domain.OriginWeb)
	if err != nil || tk.State != domain.StateCoding || len(tk.FeedbackFiles) != 1 || !strings.Contains(tk.Feedback, "boom") {
		t.Fatalf("retry: %+v %v", tk, err)
	}
	h.step()
	tk = h.expect("PAY-8", domain.StateWaitingForReview)
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "/agnts/out/attachment-"+itoa(log.ID)+"-ci.log") {
		t.Fatalf("retry prompt lacks the file:\n%s", last)
	}
	if tk.Feedback != "" || len(tk.FeedbackFiles) != 0 {
		t.Fatalf("retry files not cleared: %+v", tk)
	}
}

func itoa(n int64) string { return strconv.FormatInt(n, 10) }

func TestRequestChangesWithFiles(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-9")
	h.runner.scripts = []script{
		{result: ok("s9"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s9"), edit: "v1"},
		{result: ok("s9"), edit: "v2"},
	}
	h.step()
	h.step()
	h.expect("PAY-9", domain.StateWaitingForReview)

	mock, _ := h.o.Upload(h.ctx, "mockup.png", pngBytes)
	tk, err := h.o.RequestChanges(h.ctx, "PAY-9", "Match the mockup.", nil, []int64{mock.ID}, domain.OriginWeb)
	if err != nil || tk.State != domain.StateCoding || len(tk.FeedbackFiles) != 1 {
		t.Fatalf("request changes: %+v %v", tk, err)
	}
	// The upload is used now: sending it again fails, and nothing moves.
	if _, err := h.o.RequestChanges(h.ctx, "PAY-9", "again", nil, []int64{mock.ID}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("reused upload: %v", err)
	}
	h.step()
	tk = h.expect("PAY-9", domain.StateWaitingForReview)
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "Match the mockup.") || !strings.Contains(last, "/agnts/out/attachment-"+itoa(mock.ID)+"-mockup.png") {
		t.Fatalf("feedback prompt lacks the file:\n%s", last)
	}
	if len(tk.FeedbackFiles) != 0 {
		t.Fatalf("feedback files not cleared: %v", tk.FeedbackFiles)
	}
	v, _ := h.o.View(h.ctx, "PAY-9")
	if len(v.Attachments) != 1 || v.Attachments[0].Purpose != domain.AttachFeedback {
		t.Fatalf("attachments: %+v", v.Attachments)
	}

	// Not while the ticket is coding: the upload stays pending.
	late, _ := h.o.Upload(h.ctx, "late.png", pngBytes)
	if _, err := h.o.RequestChanges(h.ctx, "PAY-9", "x", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.RequestChanges(h.ctx, "PAY-9", "y", nil, []int64{late.ID}, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("request changes while coding: %v", err)
	}
	if err := h.o.DeleteUpload(h.ctx, late.ID); err != nil {
		t.Fatalf("upload was linked anyway: %v", err)
	}
}
