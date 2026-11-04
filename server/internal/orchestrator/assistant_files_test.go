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

func TestAssistantFollowUpSeesEarlierFiles(t *testing.T) {
	a := newAssistantHarness(t)
	plan, err := a.o.Upload(a.ask, "Implementation plan.md", []byte("# auth-gateway plan"))
	if err != nil {
		t.Fatal(err)
	}
	a.answers(2, `{"answer":"It is the auth-gateway plan.","speech":"","links":[]}`)
	c, err := a.o.Ask(a.ask, 0, "review the implementation plan", "en", []int64{plan.ID})
	if err != nil {
		t.Fatal(err)
	}
	a.conversation(c.ID)

	// Another conversation's file never comes along.
	other, err := a.o.Upload(a.ask, "other.txt", []byte("elsewhere"))
	if err != nil {
		t.Fatal(err)
	}
	a.answers(4, `{"answer":"ok","speech":"","links":[]}`)
	c2, err := a.o.Ask(a.ask, 0, "what is this?", "en", []int64{other.ID})
	if err != nil {
		t.Fatal(err)
	}
	a.conversation(c2.ID)

	// The follow-up brings no files of its own, and still has the plan.
	a.answers(6, `{"answer":"It needs a rollout section.","speech":"","links":[]}`)
	if _, err := a.o.Ask(a.ask, c.ID, "What improvements does it need?", "en", nil); err != nil {
		t.Fatal(err)
	}
	a.conversation(c.ID)
	dir := orchestrator.AssistantDir(6)
	if got := a.runner.written[dir+"/"+orchestrator.AssistantUploadName(plan)]; got != "# auth-gateway plan" {
		t.Fatalf("the earlier plan in the box = %q", got)
	}
	if _, ok := a.runner.written[dir+"/"+orchestrator.AssistantUploadName(other)]; ok {
		t.Fatal("another conversation's file is in the box")
	}
	var list []struct {
		File, Name, Question string
		This                 bool `json:"this_question"`
	}
	if err := json.Unmarshal([]byte(a.runner.written[dir+"/files.json"]), &list); err != nil || len(list) != 1 ||
		list[0].Name != "Implementation plan.md" || list[0].This || list[0].Question != "review the implementation plan" {
		t.Fatalf("files.json = %v %+v", err, list)
	}
	if conv := a.runner.written[dir+"/conversation.json"]; !strings.Contains(conv, "Implementation plan.md ("+orchestrator.AssistantUploadName(plan)+")") {
		t.Fatalf("conversation.json does not say where the plan is: %s", conv)
	}
}

func TestAssistantKeepsTheNewestFiles(t *testing.T) {
	a := newAssistantHarness(t)
	var ids []int64
	for i := range 11 {
		f, err := a.o.Upload(a.ask, "f"+itoa(int64(i))+".txt", []byte("x"))
		if err != nil {
			t.Fatal(err)
		}
		ids = append(ids, f.ID)
	}
	a.answers(2, `{"answer":"ok","speech":"","links":[]}`)
	c, err := a.o.Ask(a.ask, 0, "first", "en", ids[:1])
	if err != nil {
		t.Fatal(err)
	}
	a.conversation(c.ID)
	a.answers(4, `{"answer":"ok","speech":"","links":[]}`)
	if _, err := a.o.Ask(a.ask, c.ID, "these", "en", ids[1:]); err != nil {
		t.Fatal(err)
	}
	a.conversation(c.ID)
	dir := orchestrator.AssistantDir(4)
	n := 0
	for p := range a.runner.written {
		if strings.HasPrefix(p, dir+"/upload-") {
			n++
		}
	}
	if n != 10 {
		t.Fatalf("%d files in the box, want the newest 10", n)
	}
	if fj := a.runner.written[dir+"/files.json"]; !strings.Contains(fj, `"name": "f0.txt"`) || !strings.Contains(fj, "only the newest 10 files are here") {
		t.Fatalf("files.json does not say the oldest is left out: %s", fj)
	}
}

func TestSearchAssistant(t *testing.T) {
	a := newAssistantHarness(t)
	plan, err := a.o.Upload(a.ask, "Implementation plan.md", []byte("# plan"))
	if err != nil {
		t.Fatal(err)
	}
	a.answers(2, `{"answer":"It covers the rollout of the gateway.","speech":"","links":[]}`)
	c, err := a.o.Ask(a.ask, 0, "review this", "en", []int64{plan.ID})
	if err != nil {
		t.Fatal(err)
	}
	a.conversation(c.ID)
	// Someone else's conversation is never searched.
	a.answers(4, `{"answer":"ok","speech":"","links":[]}`)
	theirs, err := a.o.Ask(a.other, 0, "my rollout plan", "en", nil)
	if err != nil {
		t.Fatal(err)
	}
	a.o.WaitAnswers()

	hits, err := a.o.SearchAssistant(a.ask, "rollout")
	if err != nil || len(hits) != 1 || hits[0].MessageID != 2 || hits[0].Role != domain.AssistantReply || hits[0].ConversationID != c.ID ||
		!strings.Contains(hits[0].Snippet, domain.SearchMarkStart+"rollout"+domain.SearchMarkEnd) {
		t.Fatalf("rollout: %v %+v (theirs is %d)", err, hits, theirs.ID)
	}
	// A file's name counts; every word must match.
	if hits, _ := a.o.SearchAssistant(a.ask, "implementation plan"); len(hits) != 1 || hits[0].MessageID != 1 || !strings.Contains(hits[0].Snippet, "📎") {
		t.Fatalf("by a file's name: %+v", hits)
	}
	if hits, _ := a.o.SearchAssistant(a.ask, "rollout nothing"); len(hits) != 0 {
		t.Fatalf("every word: %+v", hits)
	}
}
