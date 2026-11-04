package chat

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// upload stores a pending upload of user's, as POST /attachments does.
func (h *harness) upload(t *testing.T, user int64, name, ctype, data string) int64 {
	t.Helper()
	var id int64
	err := h.pool.QueryRow(domain.System(context.Background()), `INSERT INTO attachments
		(workspace_id, purpose, name, content_type, size, data, uploaded_by) VALUES ($1, 'pending', $2, $3, $4, $5, $6) RETURNING id`,
		h.ws, name, ctype, len(data), []byte(data), user).Scan(&id)
	if err != nil {
		t.Fatal(err)
	}
	return id
}

func (h *harness) sendFiles(ch int64, body string, files ...int64) (domain.ChatMessage, bool, error) {
	return h.s.Send(h.ctx, domain.ChatSend{ChannelID: ch, ClientMsgID: newUUID(), Body: body, Files: files})
}

func TestSendWithFiles(t *testing.T) {
	h := newHarness(t)
	cs, _ := h.s.Channels(h.ctx)
	ch := cs[0].ID

	// Text and files; files alone.
	shot := h.upload(t, h.ann, "error shot.png", "image/png", "\x89PNG")
	log := h.upload(t, h.ann, "payments.log", "text/plain", "timeout after 30s")
	m, created, err := h.sendFiles(ch, "export fails, see these", shot, log, shot)
	if err != nil || !created {
		t.Fatalf("send with files: %v %v", err, created)
	}
	if len(m.Files) != 2 || m.Files[0].ID != shot || !m.Files[0].Image || m.Files[1].Name != "payments.log" || m.Files[1].URL != fmt.Sprintf("/attachments/%d", log) {
		t.Fatalf("files on the message %+v", m.Files)
	}
	csv := h.upload(t, h.ann, "invoice_march.csv", "text/csv", "a,b")
	only, _, err := h.sendFiles(ch, "  ", csv)
	if err != nil || only.Body != "" || len(only.Files) != 1 {
		t.Fatalf("files alone: %v %+v", err, only)
	}

	// Paging the channel brings the files too.
	ms, err := h.s.Messages(h.ctx, ch, 0, 0, 50)
	if err != nil || len(ms) != 2 || len(ms[0].Files) != 2 || len(ms[1].Files) != 1 {
		t.Fatalf("messages %v %+v", err, ms)
	}

	// A used upload, someone else's, too many, and none of them with no text.
	if _, _, err := h.sendFiles(ch, "again", shot); !errors.Is(err, ErrInvalid) {
		t.Fatalf("a used upload: %v", err)
	}
	bob := pgtest.User(t, h.pool, "bob-files")
	bobs := h.upload(t, bob, "bob.txt", "text/plain", "mine")
	if _, _, err := h.sendFiles(ch, "look", bobs); !errors.Is(err, ErrInvalid) {
		t.Fatalf("someone else's upload: %v", err)
	}
	var many []int64
	for i := range domain.MaxAttachments + 1 {
		many = append(many, h.upload(t, h.ann, fmt.Sprintf("f%d.txt", i), "text/plain", "x"))
	}
	if _, _, err := h.sendFiles(ch, "lots", many...); !errors.Is(err, ErrInvalid) {
		t.Fatalf("too many files: %v", err)
	}
	if _, _, err := h.sendFiles(ch, " "); !errors.Is(err, ErrInvalid) {
		t.Fatalf("no text and no files: %v", err)
	}

	// A resend with the same client id links nothing new.
	again := h.upload(t, h.ann, "again.txt", "text/plain", "x")
	cid := newUUID()
	first, _, err := h.s.Send(h.ctx, domain.ChatSend{ChannelID: ch, ClientMsgID: cid, Body: "once", Files: []int64{again}})
	if err != nil {
		t.Fatal(err)
	}
	other := h.upload(t, h.ann, "other.txt", "text/plain", "x")
	resent, created, err := h.s.Send(h.ctx, domain.ChatSend{ChannelID: ch, ClientMsgID: cid, Body: "once", Files: []int64{other}})
	if err != nil || created || resent.ID != first.ID || len(resent.Files) != 1 || resent.Files[0].ID != again {
		t.Fatalf("resend %v %v %+v", err, created, resent.Files)
	}

	// The prune of unused uploads keeps sent files; a file name is searched.
	if _, err := postgres.NewAgent(h.pool).PrunePendingAttachments(domain.System(context.Background()), timeFar()); err != nil {
		t.Fatal(err)
	}
	if got, _ := h.store.Message(h.ctx, m.ID); len(got.Files) != 2 {
		t.Fatalf("files after the prune %+v", got.Files)
	}
	var found int64
	if err := h.pool.QueryRow(domain.System(context.Background()), `SELECT id FROM chat_messages
		WHERE search @@ plainto_tsquery('simple', 'invoice') AND workspace_id = $1`, h.ws).Scan(&found); err != nil || found != only.ID {
		t.Fatalf("search by file name: %v %d", err, found)
	}
}

func TestAnswerReadsTheFiles(t *testing.T) {
	h := newHarness(t)
	cs, _ := h.s.Channels(h.ctx)
	ch := cs[0].ID
	log := h.upload(t, h.ann, "payments.log", "text/plain", "ERROR refund 42: currency mismatch EUR/USD")
	shot := h.upload(t, h.ann, "shot.png", "image/png", "\x89PNG")
	q, _, err := h.sendFiles(ch, "@agnts what is wrong here?", log, shot)
	if err != nil {
		t.Fatal(err)
	}
	h.brain.replies["answer"] = fmt.Sprintf(`{"answer_md": "Refund 42 failed on a currency mismatch [msg:%d].", "citations": ["msg:%d"], "insufficient": false, "needs_code": null}`, q.ID, q.ID)
	h.runJobs(t)
	p := h.brain.prompts["answer"]
	for _, want := range []string{"currency mismatch EUR/USD", "shot.png (image/png", "not text, only its name is known", fmt.Sprintf("[msg:%d]", q.ID)} {
		if !strings.Contains(p, want) {
			t.Fatalf("the answer prompt lacks %q:\n%s", want, p)
		}
	}
	ms, _ := h.s.Messages(h.ctx, ch, 0, 0, 50)
	last := ms[len(ms)-1]
	if last.Kind != domain.ChatKindAgent || !strings.Contains(last.Body, fmt.Sprintf("[msg:%d]", q.ID)) {
		t.Fatalf("the answer keeps its citation of the files' message: %+v", last)
	}
}

func TestTicketFromAMessageGetsItsFiles(t *testing.T) {
	h := newHarness(t)
	cs, _ := h.s.Channels(h.ctx)
	shot := h.upload(t, h.ann, "shot.png", "image/png", "\x89PNG")
	m, _, err := h.sendFiles(cs[0].ID, "the refund button does nothing", shot)
	if err != nil {
		t.Fatal(err)
	}
	var ticket int64
	err = h.pool.QueryRow(domain.System(context.Background()), `INSERT INTO tickets (workspace_id, key, source, title, state)
		VALUES ($1, 'CHF-1', 'local', 'Fix the refund button', 'new') RETURNING id`, h.ws).Scan(&ticket)
	if err != nil {
		t.Fatal(err)
	}
	if n, err := h.store.CopyFilesToTicket(h.ctx, m.ID, "CHF-1"); err != nil || n != 1 {
		t.Fatalf("copy %v %d", err, n)
	}
	as, err := postgres.NewAgent(h.pool).TicketAttachments(h.ctx, ticket)
	if err != nil || len(as) != 1 || as[0].Name != "shot.png" || as[0].Purpose != domain.AttachTicket {
		t.Fatalf("ticket files %v %+v", err, as)
	}
}

// timeFar is a moment after every upload of the test: the prune then
// takes every pending one.
func timeFar() time.Time { return time.Now().Add(time.Hour) }
