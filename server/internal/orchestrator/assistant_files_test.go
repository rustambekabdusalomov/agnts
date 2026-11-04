package orchestrator_test

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestAssistantReadsAttachedFiles(t *testing.T) {
	a := newAssistantHarness(t)
	shot, err := a.o.Upload(a.ask, "error shot.png", []byte("\x89PNG\r\n\x1a\nfake picture"))
	if err != nil {
		t.Fatal(err)
	}
	log, err := a.o.Upload(a.ask, "payments.log", []byte("ERROR refund 42: currency mismatch"))
	if err != nil {
		t.Fatal(err)
	}
	if shot.UploadedBy == nil || *shot.UploadedBy != a.user {
		t.Fatalf("uploader not kept: %+v", shot)
	}

	// Someone else's upload is refused, and leaves nothing behind.
	theirs, err := a.o.Upload(a.other, "theirs.txt", []byte("not yours"))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := a.o.Ask(a.ask, 0, "what is this?", "en", []int64{theirs.ID}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("someone else's upload: %v", err)
	}

	// Files without words are a question.
	a.answers(2, `{"answer":"Refund 42 failed on a currency mismatch.","speech":"","links":[]}`)
	c, err := a.o.Ask(a.ask, 0, "  ", "en", []int64{shot.ID, log.ID})
	if err != nil {
		t.Fatal(err)
	}
	c = a.conversation(c.ID)
	q, ans := c.Messages[0], c.Messages[1]
	if q.Text != "See the attached files." || len(q.AttachedFiles) != 2 || q.AttachedFiles[0].Name != "error shot.png" || !q.AttachedFiles[0].Image {
		t.Fatalf("question = %+v", q)
	}
	if ans.Status != domain.AssistantDone {
		t.Fatalf("answer = %+v", ans)
	}
	dir := orchestrator.AssistantDir(2)
	if got := a.runner.written[dir+"/"+orchestrator.AssistantUploadName(log)]; got != "ERROR refund 42: currency mismatch" {
		t.Fatalf("the log in the box = %q (written %d files)", got, len(a.runner.written))
	}
	if got := a.runner.written[dir+"/upload-"+itoa(shot.ID)+"-error_shot.png"]; !strings.HasPrefix(got, "\x89PNG") {
		t.Fatalf("the picture in the box = %q", got)
	}
	if p := a.runner.prompts[0]; !strings.Contains(p, "upload-<id>-<name> are files the person attached") || !strings.Contains(p, "payments.log") {
		t.Fatalf("prompt = %s", p)
	}

	// The files are linked: no second use, and only the asker opens them.
	if _, err := a.o.Ask(a.ask, c.ID, "again", "en", []int64{log.ID}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a used upload: %v", err)
	}
	if got, _, err := a.o.OpenAttachment(a.ask, log.ID); err != nil || got.Purpose != domain.AttachAssistant {
		t.Fatalf("the asker opens it: %v %+v", err, got)
	}
	if _, _, err := a.o.OpenAttachment(a.other, log.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("someone else opens it: %v", err)
	}
	// Viewers and others remove only their own pending uploads; editors
	// (the harness has no roles: everyone edits) any.
	if err := a.o.DeleteUpload(a.ask, log.ID); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("delete a sent file: %v", err)
	}
}

func TestAssistantSnapshotKeepsFilesByID(t *testing.T) {
	f := orchestrator.AssistantFile{Name: "upload-7-a.png", Attachment: 7, Data: []byte("bytes")}
	b, _ := json.Marshal(f)
	if string(b) != `{"name":"upload-7-a.png","content":"","attachment":7}` {
		t.Fatalf("snapshot entry = %s", b)
	}
}
