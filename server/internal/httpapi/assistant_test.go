package httpapi

import (
	"bytes"
	"context"
	"fmt"
	"mime/multipart"
	"net/http"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// fakeAssistant keeps one conversation (id 7) of the signed-in person.
type fakeAssistant struct {
	lastLang, lastQuestion string
	lastConversation       int64
	lastRating             int
	lastShare              bool
	user                   int64
	lastVoice              int
}

func (f *fakeAssistant) AssistantReady() bool { return true }

func (f *fakeAssistant) conv() domain.AssistantConversation {
	at := time.Date(2026, 10, 14, 9, 0, 0, 0, time.UTC)
	return domain.AssistantConversation{ID: 7, Title: "What waits on me?", CreatedAt: at, UpdatedAt: at, Messages: []domain.AssistantMessage{
		{ID: 1, ConversationID: 7, Role: domain.AssistantUser, Text: "What waits on me?", Status: domain.AssistantDone, Lang: "en", CreatedAt: at},
		{ID: 2, ConversationID: 7, Role: domain.AssistantReply, Text: "**PAY-214** needs your review.", Speech: "PAY-214 needs your review.",
			Links: []domain.AssistantLink{{Kind: "ticket", Key: "PAY-214"}, {Kind: "ci", ID: 12}}, Status: domain.AssistantDone, Lang: "en",
			DurationMS: 9000, Files: []string{"inbox.json"}, CreatedAt: at,
			Actions: []domain.AssistantAction{f.action(domain.ActionProposed, "")}, ActionErrors: []string{"start_run: no ticket \"PAY-9\""}},
	}}
}

func (f *fakeAssistant) Ask(ctx context.Context, id int64, q, lang string) (domain.AssistantConversation, error) {
	if a, ok := domain.ActorOf(ctx); ok {
		f.user = a.UserID
	}
	f.lastConversation, f.lastQuestion, f.lastLang = id, q, lang
	switch {
	case strings.TrimSpace(q) == "":
		return domain.AssistantConversation{}, orchestrator.ErrInvalid
	case q == "too many":
		return domain.AssistantConversation{}, &orchestrator.RateLimitedError{RetryAfter: 90 * time.Second}
	case id != 0 && id != 7:
		return domain.AssistantConversation{}, domain.ErrNotFound
	}
	c := f.conv()
	c.Messages[1].Status, c.Messages[1].Text, c.Messages[1].Speech, c.Messages[1].Links = domain.AssistantPending, "", "", nil
	return c, nil
}

func (f *fakeAssistant) AssistantConversations(context.Context) ([]domain.AssistantConversation, error) {
	c := f.conv()
	c.Messages = c.Messages[1:]
	return []domain.AssistantConversation{c}, nil
}

func (f *fakeAssistant) AssistantConversation(_ context.Context, id int64) (domain.AssistantConversation, error) {
	if id != 7 {
		return domain.AssistantConversation{}, domain.ErrNotFound
	}
	return f.conv(), nil
}

func (f *fakeAssistant) DeleteAssistantConversation(_ context.Context, id int64) error {
	if id != 7 {
		return domain.ErrNotFound
	}
	return nil
}

func (f *fakeAssistant) RateAnswer(_ context.Context, id int64, rating int, comment string, share bool) (domain.AssistantMessage, error) {
	f.lastRating, f.lastShare = rating, share
	if id != 2 {
		return domain.AssistantMessage{}, domain.ErrNotFound
	}
	m := f.conv().Messages[1]
	m.Rating, m.RatingComment, m.Shared = rating, comment, share
	return m, nil
}

func (f *fakeAssistant) AssistantStats(_ context.Context, days int) (domain.AssistantStats, error) {
	return domain.AssistantStats{Days: days, Questions: 4, Answered: 3, Failed: 1, MedianMS: 12000, Up: 2,
		Versions: []domain.AssistantVersionStats{{PromptVersion: "v2", Answered: 3}}}, nil
}

func (f *fakeAssistant) AssistantRated(_ context.Context, rating int) ([]domain.AssistantRated, error) {
	return []domain.AssistantRated{{MessageID: 2, Username: "rustam", Question: "Why red?", Answer: "Flaky test.", Rating: -1, Comment: "wrong"}}, nil
}

func (f *fakeAssistant) action(status domain.AssistantActionStatus, result string) domain.AssistantAction {
	return domain.AssistantAction{ID: "a1", MessageID: 2, ConversationID: 7, Tool: "approve_ticket", TicketKey: "PAY-214",
		Summary: "Approve PAY-214 (Fix rounding): agnts will push agnts/PAY-214 and open a pull request.", Destructive: true,
		Status: status, Result: result, ExpiresAt: time.Date(2026, 10, 14, 9, 30, 0, 0, time.UTC)}
}

func (f *fakeAssistant) ConfirmAssistantAction(_ context.Context, id string) (domain.AssistantAction, error) {
	switch id {
	case "a1":
		return f.action(domain.ActionDone, "PAY-214 is now pushing."), nil
	case "gone":
		return domain.AssistantAction{}, postgres.ErrExpired
	case "viewer":
		return domain.AssistantAction{}, domain.ErrForbidden
	}
	return domain.AssistantAction{}, domain.ErrNotFound
}

func (f *fakeAssistant) CancelAssistantAction(_ context.Context, id string) (domain.AssistantAction, error) {
	if id != "a1" {
		return domain.AssistantAction{}, domain.ErrNotFound
	}
	return f.action(domain.ActionCancelled, ""), nil
}

func (f *fakeAssistant) VoiceReady() bool { return true }

func (f *fakeAssistant) Transcribe(_ context.Context, wav []byte) (string, error) {
	f.lastVoice = len(wav)
	if string(wav) == "silence" {
		return "", fmt.Errorf("%w: %w", orchestrator.ErrInvalid, orchestrator.ErrNoSpeech)
	}
	return "What waits on me?", nil
}

// voiceForm is a multipart body with one file field.
func voiceForm(t *testing.T, field string, data []byte) (string, string) {
	t.Helper()
	var b bytes.Buffer
	mw := multipart.NewWriter(&b)
	fw, err := mw.CreateFormFile(field, "question.wav")
	if err != nil {
		t.Fatal(err)
	}
	_, _ = fw.Write(data)
	_ = mw.Close()
	return b.String(), mw.FormDataContentType()
}

func TestAssistantTranscribe(t *testing.T) {
	h := newHarness(t, pinger{})
	body, ctype := voiceForm(t, "file", []byte("RIFF....WAVE"))
	if rec := h.do("POST", "/api/assistant/transcribe", body, map[string]string{"Content-Type": ctype}); rec.Code != http.StatusUnauthorized {
		t.Fatalf("without session: %d", rec.Code)
	}
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := rec.Result().Cookies()[0].String()

	cases := []struct {
		name, field string
		data        []byte
		want        int
		contains    string
	}{
		{"heard", "file", []byte("RIFF....WAVE"), 200, `{"text":"What waits on me?"}`},
		{"no words", "file", []byte("silence"), 400, `no words were heard`},
		{"wrong field", "audio", []byte("RIFF....WAVE"), 400, `in the field \"file\"`},
		{"too big", "file", bytes.Repeat([]byte{1}, domain.AssistantMaxVoiceBytes+1), 413, `too_large`},
	}
	for _, c := range cases {
		body, ctype := voiceForm(t, c.field, c.data)
		rec := h.do("POST", "/api/assistant/transcribe", body, map[string]string{"Cookie": cookie, "Content-Type": ctype})
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s: %d %s (want %d containing %q)", c.name, rec.Code, rec.Body, c.want, c.contains)
		}
	}
	if h.assistant.lastVoice != len("silence") {
		t.Errorf("recording passed on: %d bytes", h.assistant.lastVoice)
	}
}

func TestAssistantEndpoints(t *testing.T) {
	h := newHarness(t, pinger{})
	if rec := h.do("GET", "/api/assistant/conversations", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("without session: %d", rec.Code)
	}
	rec := h.do("POST", "/api/auth/login", loginBody("rustam", password, h.code(t, 1), "web"), nil)
	cookie := map[string]string{"Cookie": rec.Result().Cookies()[0].String()}

	cases := []struct {
		method, path, body string
		want               int
		contains           string
	}{
		{"POST", "/api/assistant/conversations", `{"question":"What waits on me?","lang":"ru"}`, 202, `"status":"pending"`},
		{"POST", "/api/assistant/conversations", `{"question":"x","lang":"de"}`, 400, `bad_request`},
		{"POST", "/api/assistant/conversations", `{"question":"  "}`, 400, `bad_request`},
		{"POST", "/api/assistant/conversations", `{"question":"too many"}`, 429, `rate_limited`},
		{"POST", "/api/assistant/conversations/7/messages", `{"question":"And CI?"}`, 202, `"id":7`},
		{"POST", "/api/assistant/conversations/8/messages", `{"question":"And CI?"}`, 404, `no such conversation`},
		{"GET", "/api/assistant/conversations", "", 200, `"title":"What waits on me?"`},
		{"GET", "/api/assistant/conversations/7", "", 200, `"links":[{"key":"PAY-214","kind":"ticket"},{"id":12,"kind":"ci"}]`},
		{"GET", "/api/assistant/conversations/7", "", 200, `"speech":"PAY-214 needs your review."`},
		{"GET", "/api/assistant/conversations/8", "", 404, `not_found`},
		{"GET", "/api/assistant/conversations/7", "", 200, `"actions":[{"conversationId":7,"destructive":true,`},
		{"GET", "/api/assistant/conversations/7", "", 200, `"actionErrors":["start_run: no ticket \"PAY-9\""]`},
		{"POST", "/api/assistant/actions/a1/confirm", "", 200, `"result":"PAY-214 is now pushing.","status":"done"`},
		{"POST", "/api/assistant/actions/gone/confirm", "", 409, `conflict`},
		{"POST", "/api/assistant/actions/viewer/confirm", "", 403, `forbidden`},
		{"POST", "/api/assistant/actions/nope/confirm", "", 404, `no such action`},
		{"POST", "/api/assistant/actions/a1/cancel", "", 200, `"status":"cancelled"`},
		{"POST", "/api/assistant/actions/nope/cancel", "", 404, `no such action`},
		{"PUT", "/api/assistant/messages/2/rating", `{"rating":5}`, 400, `bad_request`},
		{"PUT", "/api/assistant/messages/3/rating", `{"rating":1}`, 404, `no such answer`},
		{"PUT", "/api/assistant/messages/2/rating", `{"rating":-1,"comment":"wrong ticket","share":true}`, 200, `"rating":-1`},
		{"DELETE", "/api/assistant/conversations/7", "", 204, ``},
		{"DELETE", "/api/assistant/conversations/8", "", 404, `not_found`},
		{"GET", "/api/assistant/stats?days=30", "", 200, `"days":30`},
		{"GET", "/api/assistant/stats", "", 200, `"versions":[{"answered":3`},
		{"GET", "/api/assistant/rated?rating=down", "", 200, `"comment":"wrong"`},
	}
	for _, c := range cases {
		rec := h.do(c.method, c.path, c.body, cookie)
		if rec.Code != c.want || !strings.Contains(rec.Body.String(), c.contains) {
			t.Errorf("%s %s: %d %s (want %d containing %q)", c.method, c.path, rec.Code, rec.Body, c.want, c.contains)
		}
		if c.want == 429 && rec.Header().Get("Retry-After") != "91" {
			t.Errorf("Retry-After = %q", rec.Header().Get("Retry-After"))
		}
	}
	if h.assistant.lastConversation != 8 || h.assistant.lastQuestion != "And CI?" || h.assistant.user == 0 {
		t.Errorf("ask input: %+v", h.assistant)
	}
	if h.assistant.lastRating != -1 || !h.assistant.lastShare {
		t.Errorf("rating input: %+v", h.assistant)
	}
}
