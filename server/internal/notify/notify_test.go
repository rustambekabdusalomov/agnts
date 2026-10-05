package notify

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
)

// ---- fakes ----

type memStore struct {
	mu       sync.Mutex
	events   []domain.Event
	cursor   int64
	devices  []postgres.Device
	msgs     map[int64]postgres.TelegramMessage
	pending  map[string]postgres.PendingAction
	used     map[string]bool
	seen     map[string]bool
	appended []domain.Event
}

func newMemStore() *memStore {
	return &memStore{cursor: -1, msgs: map[int64]postgres.TelegramMessage{}, pending: map[string]postgres.PendingAction{},
		used: map[string]bool{}, seen: map[string]bool{}}
}

func (m *memStore) Events(_ context.Context, f orchestrator.EventFilter) ([]domain.Event, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var out []domain.Event
	for _, e := range m.events {
		if e.ID > f.AfterID {
			out = append(out, e)
		}
	}
	return out, nil
}
func (m *memStore) MaxEventID(context.Context) (int64, error) { return int64(len(m.events)), nil }
func (m *memStore) Cursor(context.Context, string) (int64, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.cursor, nil
}
func (m *memStore) SetCursor(_ context.Context, _ string, id int64) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.cursor = id
	return nil
}
func (m *memStore) Devices(context.Context) ([]postgres.Device, error) { return m.devices, nil }
func (m *memStore) DeleteDevice(_ context.Context, token string) error {
	var keep []postgres.Device
	for _, d := range m.devices {
		if d.FCMToken != token {
			keep = append(keep, d)
		}
	}
	m.devices = keep
	return nil
}
func (m *memStore) SaveTelegramMessage(_ context.Context, t postgres.TelegramMessage) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.msgs[t.MessageID] = t
	return nil
}
func (m *memStore) TelegramMessage(_ context.Context, _, id int64) (postgres.TelegramMessage, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	t, ok := m.msgs[id]
	if !ok {
		return t, domain.ErrNotFound
	}
	return t, nil
}
func (m *memStore) CreatePending(_ context.Context, a postgres.PendingAction) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.pending[a.ID] = a
	return nil
}
func (m *memStore) ConfirmPending(_ context.Context, id string, _ domain.Origin) (postgres.PendingAction, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	a, ok := m.pending[id]
	if !ok || m.used[id] || time.Now().After(a.ExpiresAt) {
		return a, postgres.ErrExpired
	}
	m.used[id] = true
	return a, nil
}
func (m *memStore) CancelPending(_ context.Context, id string) error {
	delete(m.pending, id)
	return nil
}
func (m *memStore) SeenDelivery(_ context.Context, p, id string) (bool, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	k := p + id
	s := m.seen[k]
	m.seen[k] = true
	return s, nil
}
func (m *memStore) AppendEvent(_ context.Context, e domain.Event) error {
	m.appended = append(m.appended, e)
	return nil
}

type fakeActions struct {
	mu       sync.Mutex
	view     orchestrator.TicketView
	answered []domain.Answer
	approved []string
	rejected []string
	feedback []string
	retried  []string
}

func (f *fakeActions) View(context.Context, string) (orchestrator.TicketView, error) {
	return f.view, nil
}
func (f *fakeActions) AnswerOne(_ context.Context, _ string, a domain.Answer, _ domain.Origin) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.answered = append(f.answered, a)
	open := 0
	for _, q := range f.view.Questions {
		if q.Answer == nil {
			open++
		}
	}
	return len(f.answered) == open, nil
}
func (f *fakeActions) Approve(_ context.Context, k string, _ []string, _ domain.Origin) (domain.Ticket, error) {
	f.approved = append(f.approved, k)
	return domain.Ticket{}, nil
}
func (f *fakeActions) RequestChanges(_ context.Context, k, fb string, _ domain.Origin) (domain.Ticket, error) {
	f.feedback = append(f.feedback, k+":"+fb)
	return domain.Ticket{}, nil
}
func (f *fakeActions) Reject(_ context.Context, k, _ string, _ domain.Origin) (domain.Ticket, error) {
	f.rejected = append(f.rejected, k)
	return domain.Ticket{}, nil
}
func (f *fakeActions) Retry(_ context.Context, k string, _ domain.Origin) (domain.Ticket, error) {
	f.retried = append(f.retried, k)
	return domain.Ticket{}, nil
}

type fakeSettings struct{ s domain.Settings }

func (f fakeSettings) Get(context.Context) (domain.Settings, error) { return f.s, nil }

// fakeTelegram records Bot API calls and hands out message ids.
type fakeTelegram struct {
	mu    sync.Mutex
	calls []map[string]any
	next  int64
}

func (f *fakeTelegram) server(t *testing.T) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var body map[string]any
		_ = json.NewDecoder(r.Body).Decode(&body)
		method := r.URL.Path[strings.LastIndex(r.URL.Path, "/")+1:]
		if !strings.HasPrefix(r.URL.Path, "/botBOT/") {
			t.Errorf("bad token path %s", r.URL.Path)
		}
		body["_method"] = method
		f.mu.Lock()
		f.next++
		id := f.next
		body["_id"] = id
		f.calls = append(f.calls, body)
		f.mu.Unlock()
		_, _ = io.WriteString(w, `{"ok":true,"result":{"message_id":`+strconv.FormatInt(id, 10)+`,"username":"hiro_bot"}}`)
	}))
}

func (f *fakeTelegram) sent(method string) []map[string]any {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []map[string]any
	for _, c := range f.calls {
		if c["_method"] == method {
			out = append(out, c)
		}
	}
	return out
}

const chat = int64(4242)

func setup(t *testing.T) (*Notifier, *memStore, *fakeActions, *fakeTelegram) {
	t.Helper()
	tg := &fakeTelegram{}
	srv := tg.server(t)
	t.Cleanup(srv.Close)
	st := newMemStore()
	ans := "x"
	acts := &fakeActions{view: orchestrator.TicketView{
		Ticket: domain.Ticket{Key: "PAY-1", Title: "Fix rounding", State: domain.StateWaitingForAnswers, Source: domain.SourceJira},
		Questions: []domain.Question{
			{ID: 7, Position: 1, Text: "Rounding mode?", Options: []string{"half up", "banker's"}},
			{ID: 8, Position: 2, Text: "Anything else?"},
			{ID: 9, Position: 3, Text: "Already answered", Answer: &ans},
		},
	}}
	settings := fakeSettings{s: domain.DefaultSettings()}
	n := New(st, acts, settings, nil, func(context.Context) (TelegramConfig, bool, error) {
		return TelegramConfig{BotToken: "BOT", WebhookSecret: "sekret", ChatID: chat}, true, nil
	}, srv.URL, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return n, st, acts, tg
}

func post(n *Notifier, secret string, u any) int {
	b, _ := json.Marshal(u)
	req := httptest.NewRequest("POST", "/webhooks/telegram", strings.NewReader(string(b)))
	req.Header.Set("X-Telegram-Bot-Api-Secret-Token", secret)
	rec := httptest.NewRecorder()
	n.WebhookHandler().ServeHTTP(rec, req)
	return rec.Code
}

var updateID int64

func callback(msgID int64, data string) map[string]any {
	updateID++
	return map[string]any{"update_id": updateID, "callback_query": map[string]any{
		"id": "cb", "data": data, "message": map[string]any{"message_id": msgID, "chat": map[string]any{"id": chat}}}}
}

func reply(to int64, text string, from int64) map[string]any {
	updateID++
	return map[string]any{"update_id": updateID, "message": map[string]any{"message_id": 999, "text": text,
		"chat": map[string]any{"id": from}, "reply_to_message": map[string]any{"message_id": to, "chat": map[string]any{"id": from}}}}
}

// ---- tests ----

func TestQuestionsFlow(t *testing.T) {
	n, st, acts, tg := setup(t)
	ctx := context.Background()
	st.events = []domain.Event{{ID: 1, TicketKey: "PAY-1", Type: "state_changed", Data: map[string]any{"to": "waiting_for_answers"}}}
	st.cursor = 0
	n.handle(ctx, st.events[0])

	msgs := tg.sent("sendMessage")
	if len(msgs) != 3 { // intro + 2 open questions (the answered one is skipped)
		t.Fatalf("sent %d messages", len(msgs))
	}
	if kb, _ := json.Marshal(msgs[1]["reply_markup"]); !strings.Contains(string(kb), `"ans:7:0"`) {
		t.Fatalf("option buttons: %s", kb)
	}
	if fr, _ := json.Marshal(msgs[2]["reply_markup"]); !strings.Contains(string(fr), "force_reply") {
		t.Fatalf("free-text question should force a reply: %s", fr)
	}

	// Tap an option on question 7 (message id 2), then reply to question 8 (id 3).
	if c := post(n, "sekret", callback(2, "ans:7:1")); c != 200 {
		t.Fatal(c)
	}
	post(n, "sekret", reply(3, "No, that's all", chat))
	if len(acts.answered) != 2 || acts.answered[0].Answer != "banker's" || acts.answered[1].QuestionID != 8 {
		t.Fatalf("answers: %+v", acts.answered)
	}
	last := tg.sent("sendMessage")
	if !strings.Contains(last[len(last)-1]["text"].(string), "starts coding") {
		t.Fatalf("no 'starts coding' message: %v", last[len(last)-1]["text"])
	}
}

func TestApproveNeedsConfirmation(t *testing.T) {
	n, st, acts, tg := setup(t)
	acts.view.Ticket.State = domain.StateWaitingForReview
	post(n, "sekret", callback(50, "apr:PAY-1"))
	if len(acts.approved) != 0 {
		t.Fatal("approved without confirmation")
	}
	var id string
	for k := range st.pending {
		id = k
	}
	if id == "" || st.pending[id].Tool != "approve" {
		t.Fatalf("pending: %+v", st.pending)
	}
	confirm := tg.sent("sendMessage")
	if kb, _ := json.Marshal(confirm[len(confirm)-1]["reply_markup"]); !strings.Contains(string(kb), "ok:"+id) {
		t.Fatalf("confirm buttons: %s", kb)
	}
	post(n, "sekret", callback(51, "ok:"+id))
	if len(acts.approved) != 1 {
		t.Fatal("not approved after confirm")
	}
	post(n, "sekret", callback(51, "ok:"+id)) // second tap: already used
	if len(acts.approved) != 1 {
		t.Fatal("confirmation reused")
	}

	// Expired confirmation does nothing.
	post(n, "sekret", callback(50, "rej:PAY-1"))
	for k, a := range st.pending {
		if a.Tool == "reject" {
			a.ExpiresAt = time.Now().Add(-time.Second)
			st.pending[k] = a
			post(n, "sekret", callback(52, "ok:"+k))
		}
	}
	if len(acts.rejected) != 0 {
		t.Fatal("expired confirmation executed")
	}
}

func TestFeedbackRetryAndSecurity(t *testing.T) {
	n, st, acts, tg := setup(t)
	post(n, "sekret", callback(60, "chg:PAY-1"))
	prompts := tg.sent("sendMessage")
	prompt := prompts[len(prompts)-1]
	promptID := prompt["_id"].(int64)
	if !strings.Contains(prompt["text"].(string), "Reply to this message") {
		t.Fatal("no feedback prompt")
	}
	post(n, "sekret", reply(promptID, "Also handle refunds", chat))
	if len(acts.feedback) != 1 || acts.feedback[0] != "PAY-1:Also handle refunds" {
		t.Fatalf("feedback: %v", acts.feedback)
	}
	post(n, "sekret", callback(61, "rty:PAY-1"))
	if len(acts.retried) != 1 {
		t.Fatal("retry")
	}

	if c := post(n, "wrong", callback(62, "rty:PAY-1")); c != http.StatusUnauthorized {
		t.Fatalf("bad secret: %d", c)
	}
	before := len(acts.retried)
	post(n, "sekret", reply(1, "/start", 777)) // a stranger
	post(n, "sekret", map[string]any{"update_id": 9999, "callback_query": map[string]any{"id": "x", "data": "rty:PAY-1",
		"message": map[string]any{"message_id": 1, "chat": map[string]any{"id": 777}}}})
	if len(acts.retried) != before {
		t.Fatal("a stranger triggered an action")
	}
	// The same update delivered twice is handled once.
	u := callback(63, "rty:PAY-1")
	post(n, "sekret", u)
	post(n, "sekret", u)
	if len(acts.retried) != before+1 {
		t.Fatalf("duplicate update handled twice: %d", len(acts.retried)-before)
	}
	_ = st
}

func TestNotifierCursorAndToggles(t *testing.T) {
	n, st, acts, tg := setup(t)
	acts.view.Ticket.State = domain.StateDone
	acts.view.Ticket.PRURL = "https://github.com/a/b/pull/1"
	st.events = []domain.Event{
		{ID: 1, TicketKey: "PAY-1", Type: "state_changed", Data: map[string]any{"to": "coding"}},
		{ID: 2, TicketKey: "PAY-1", Type: "state_changed", Data: map[string]any{"to": "done"}},
	}
	ctx, cancel := context.WithCancel(context.Background())
	st.cursor = 0
	go n.Run(ctx)
	deadline := time.Now().Add(3 * time.Second)
	for len(tg.sent("sendMessage")) == 0 && time.Now().Before(deadline) {
		time.Sleep(20 * time.Millisecond)
	}
	cancel()
	msgs := tg.sent("sendMessage")
	if len(msgs) != 1 || !strings.Contains(msgs[0]["text"].(string), "pull/1") {
		t.Fatalf("done message: %v", msgs)
	}
	if c, _ := st.Cursor(context.Background(), ""); c != 2 {
		t.Fatalf("cursor %d", c)
	}

	// Turned off: nothing sent.
	n2, st2, acts2, tg2 := setup(t)
	acts2.view.Ticket.State = domain.StateDone
	n2.settings = fakeSettings{s: func() domain.Settings { s := domain.DefaultSettings(); s.Notify.Done = false; return s }()}
	n2.handle(context.Background(), domain.Event{ID: 1, TicketKey: "PAY-1", Data: map[string]any{"to": "done"}})
	if len(tg2.sent("sendMessage")) != 0 {
		t.Fatal("sent although turned off")
	}
	_ = st2
}

func TestFCM(t *testing.T) {
	key, _ := rsa.GenerateKey(rand.Reader, 2048)
	der, _ := x509.MarshalPKCS8PrivateKey(key)
	var tokenCalls, sends int
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/token":
			tokenCalls++
			_ = r.ParseForm()
			if parts := strings.Split(r.Form.Get("assertion"), "."); len(parts) != 3 {
				w.WriteHeader(400)
				return
			}
			_, _ = io.WriteString(w, `{"access_token":"AT","expires_in":3600}`)
		case strings.HasSuffix(r.URL.Path, "/messages:send"):
			sends++
			if r.Header.Get("Authorization") != "Bearer AT" {
				w.WriteHeader(401)
				return
			}
			var m map[string]map[string]any
			_ = json.NewDecoder(r.Body).Decode(&m)
			if m["message"]["token"] == "dead" {
				w.WriteHeader(404)
				_, _ = io.WriteString(w, `{"error":{"status":"NOT_FOUND","details":[{"errorCode":"UNREGISTERED"}]}}`)
				return
			}
			_, _ = io.WriteString(w, `{"name":"x"}`)
		}
	}))
	defer srv.Close()
	sa, _ := json.Marshal(map[string]string{"project_id": "p", "client_email": "x@p.iam", "token_uri": srv.URL + "/token",
		"private_key": string(pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: der}))})
	path := filepath.Join(t.TempDir(), "sa.json")
	_ = os.WriteFile(path, sa, 0o600)
	f, err := LoadFCM(path)
	if err != nil {
		t.Fatal(err)
	}
	f.api = srv.URL

	n, st, acts, _ := setup(t)
	n.fcm = f
	acts.view.Ticket.State = domain.StateWaitingForReview
	st.devices = []postgres.Device{{ID: 1, FCMToken: "good"}, {ID: 2, FCMToken: "dead"}}
	n.handle(context.Background(), domain.Event{ID: 1, TicketKey: "PAY-1", Data: map[string]any{"to": "waiting_for_review"}})
	if sends != 2 || tokenCalls != 1 {
		t.Fatalf("sends %d token calls %d", sends, tokenCalls)
	}
	if len(st.devices) != 1 || st.devices[0].FCMToken != "good" {
		t.Fatalf("dead token not removed: %+v", st.devices)
	}
}

func TestLessonsNotification(t *testing.T) {
	// Data as it comes back from the events table: JSON numbers are float64.
	ev := func(count float64, titles ...any) domain.Event {
		return domain.Event{ID: 1, TicketKey: "PAY-1", Type: domain.EventLessons,
			Data: map[string]any{"count": count, "ids": []any{float64(5), float64(6)}, "titles": titles}}
	}
	n, _, _, tg := setup(t)
	n.handle(context.Background(), ev(2, "Transactional outbox", "Ring buffer"))
	msgs := tg.sent("sendMessage")
	if len(msgs) != 1 {
		t.Fatalf("messages: %v", msgs)
	}
	if text := msgs[0]["text"].(string); !strings.Contains(text, "PAY-1") || !strings.Contains(text, "• Ring buffer") {
		t.Fatalf("lessons message: %q", text)
	}

	n.handle(context.Background(), ev(0))
	n.settings = fakeSettings{s: func() domain.Settings { s := domain.DefaultSettings(); s.Notify.Lessons = false; return s }()}
	n.handle(context.Background(), ev(1, "Outbox"))
	if len(tg.sent("sendMessage")) != 1 {
		t.Fatal("sent for an empty learn run or with lessons notifications off")
	}
}
