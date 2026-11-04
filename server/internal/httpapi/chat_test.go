package httpapi

import (
	"bytes"
	"context"
	"fmt"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"net/textproto"
	"strings"
	"testing"

	"agnts/internal/chat"
	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

type fakeChat struct {
	sent map[string]domain.ChatMessage
	acts []chat.ActInput
}

func (f *fakeChat) Channels(context.Context) ([]domain.ChatChannel, error) {
	return []domain.ChatChannel{{ID: 1, Name: "general", Agents: true}}, nil
}

func (f *fakeChat) CreateChannel(_ context.Context, name, _ string, _ bool) (domain.ChatChannel, error) {
	if name == "general" {
		return domain.ChatChannel{}, postgres.ErrChatDuplicate
	}
	return domain.ChatChannel{ID: 2, Name: name}, nil
}

func (f *fakeChat) UpdateChannel(context.Context, int64, *string, *bool, bool) (domain.ChatChannel, error) {
	return domain.ChatChannel{ID: 1}, nil
}

func (f *fakeChat) Messages(_ context.Context, ch, _, _ int64, _ int) ([]domain.ChatMessage, error) {
	if ch != 1 {
		return nil, domain.ErrNotFound
	}
	return []domain.ChatMessage{{ID: 5, ChannelID: 1, Author: "ann", Kind: domain.ChatKindText, Body: "hi", Refs: []domain.ChatRef{}}}, nil
}

func (f *fakeChat) Send(_ context.Context, in domain.ChatSend) (domain.ChatMessage, bool, error) {
	if f.sent == nil {
		f.sent = map[string]domain.ChatMessage{}
	}
	if m, ok := f.sent[in.ClientMsgID]; ok {
		return m, false, nil
	}
	m := domain.ChatMessage{ID: int64(len(f.sent) + 10), ChannelID: in.ChannelID, Body: in.Body, ClientMsgID: in.ClientMsgID, Kind: domain.ChatKindText, Refs: []domain.ChatRef{}}
	for _, id := range in.Files {
		m.Files = append(m.Files, domain.Attachment{ID: id, Name: "shot.png", ContentType: "image/png", Size: 4}.Ref())
	}
	f.sent[in.ClientMsgID] = m
	return m, true, nil
}

func (f *fakeChat) Message(_ context.Context, id int64) (domain.ChatMessage, error) {
	if id != 5 {
		return domain.ChatMessage{}, domain.ErrNotFound
	}
	return domain.ChatMessage{ID: 5, ChannelID: 2, Refs: []domain.ChatRef{}}, nil
}

func (f *fakeChat) SendVoice(_ context.Context, ch int64, in chat.VoiceInput) (domain.ChatMessage, bool, error) {
	if in.ContentType != "audio/webm" || string(in.Data) != "opus" || string(in.WAV) != "RIFFwav" || in.DurationMS != 4200 {
		return domain.ChatMessage{}, false, fmt.Errorf("%w: got %+v", chat.ErrInvalid, in)
	}
	return domain.ChatMessage{ID: 77, ChannelID: ch, Kind: domain.ChatKindText, Audio: &domain.ChatAudio{ContentType: "audio/webm", DurationMS: 4200, Transcript: domain.VoicePending}, Refs: []domain.ChatRef{}}, true, nil
}

func (f *fakeChat) Voice(_ context.Context, id int64) (string, []byte, error) {
	if id != 77 {
		return "", nil, domain.ErrNotFound
	}
	return "audio/webm", []byte("0123456789"), nil
}

func (f *fakeChat) MarkRead(context.Context, int64, int64) error { return nil }

func (f *fakeChat) Act(_ context.Context, msg int64, in chat.ActInput) (domain.ChatMessage, error) {
	f.acts = append(f.acts, in)
	if msg == 9 {
		return domain.ChatMessage{}, fmt.Errorf("%w: already approved by ann", chat.ErrSettled)
	}
	return domain.ChatMessage{ID: msg, Kind: domain.ChatKindCard, Card: &domain.ChatCard{State: domain.CardDone}, Refs: []domain.ChatRef{}}, nil
}

func (f *fakeChat) RemoveRef(context.Context, int64, string, string) (domain.ChatMessage, error) {
	return domain.ChatMessage{ID: 5, Refs: []domain.ChatRef{}}, nil
}

func (f *fakeChat) ToTicket(context.Context, int64) error {
	return fmt.Errorf("%w: 100 ticket drafts a day", chat.ErrLimit)
}

func (f *fakeChat) Stats(context.Context) (postgres.ChatStats, error) {
	return postgres.ChatStats{Links: 41, Answers: 6, MedianMS: 1200}, nil
}

func TestChatAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	send := `{"clientMsgId":"7d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11","body":"hello"}`
	if rec := h.do("POST", "/api/w/acme/chat/channels/1/messages", send, cookie); rec.Code != http.StatusCreated {
		t.Fatalf("send: %d %s", rec.Code, rec.Body)
	}
	// The same client id again: the stored message, 200.
	if rec := h.do("POST", "/api/w/acme/chat/channels/1/messages", send, cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"clientMsgId":"7d9f6a0e`) {
		t.Fatalf("resend: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/channels/1/messages", `{"clientMsgId":"nope","body":"x"}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad uuid: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/chat/channels/1/messages?after=4", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"refs":[]`) {
		t.Fatalf("messages: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/chat/messages/5", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"channelId":2`) {
		t.Fatalf("one message: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/chat/messages/6", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("no such message: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/channels", `{"name":"general"}`, cookie); rec.Code != http.StatusConflict {
		t.Fatalf("duplicate channel: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/messages/9/actions", `{"action":"approve"}`, cookie); rec.Code != http.StatusConflict ||
		!strings.Contains(rec.Body.String(), "already approved by ann") {
		t.Fatalf("second press: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/messages/7/actions", `{"action":"request_changes","feedback":"round half up"}`, cookie); rec.Code != http.StatusOK ||
		h.chat.acts[len(h.chat.acts)-1].Feedback != "round half up" {
		t.Fatalf("request changes: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/messages/7/ticket", ``, cookie); rec.Code != http.StatusTooManyRequests {
		t.Fatalf("draft cap: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/chat/stats", "", cookie); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"links":41`) {
		t.Fatalf("stats: %d %s", rec.Code, rec.Body)
	}

	// A viewer talks and reads, but presses no buttons.
	h.workspaces.roles[[2]int64{1, 1}] = domain.RoleViewer
	if rec := h.do("POST", "/api/w/acme/chat/channels/1/messages", `{"clientMsgId":"8d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11","body":"hi"}`, cookie); rec.Code != http.StatusCreated {
		t.Fatalf("viewer send: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("PUT", "/api/w/acme/chat/channels/1/read", `{"lastReadId":5}`, cookie); rec.Code != http.StatusNoContent {
		t.Fatalf("viewer read: %d %s", rec.Code, rec.Body)
	}
	// It sends files too: uploads, sends them without words, and removes an upload.
	var form bytes.Buffer
	mw := multipart.NewWriter(&form)
	fw, _ := mw.CreateFormFile("file", "shot.png")
	_, _ = fw.Write([]byte("\x89PNG"))
	_ = mw.Close()
	req := httptest.NewRequest("POST", "/api/w/acme/attachments", &form)
	req.Header.Set("Content-Type", mw.FormDataContentType())
	req.Header.Set("Cookie", cookie["Cookie"])
	up := httptest.NewRecorder()
	h.h.ServeHTTP(up, req)
	if up.Code != http.StatusCreated {
		t.Fatalf("viewer upload: %d %s", up.Code, up.Body)
	}
	if rec := h.do("POST", "/api/w/acme/chat/channels/1/messages", `{"clientMsgId":"8d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a12","files":[9]}`, cookie); rec.Code != http.StatusCreated ||
		!strings.Contains(rec.Body.String(), `"files":[{"id":9,"name":"shot.png","contentType":"image/png","size":4,"image":true,"url":"/attachments/9"}]`) {
		t.Fatalf("viewer sends files: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("DELETE", "/api/w/acme/attachments/9", "", cookie); rec.Code != http.StatusNoContent {
		t.Fatalf("viewer removes an upload: %d %s", rec.Code, rec.Body)
	}
	for _, path := range []string{"/api/w/acme/chat/messages/7/actions", "/api/w/acme/chat/messages/7/ticket", "/api/w/acme/chat/channels"} {
		if rec := h.do("POST", path, `{"action":"merge","name":"x"}`, cookie); rec.Code != http.StatusForbidden {
			t.Fatalf("viewer POST %s: %d %s", path, rec.Code, rec.Body)
		}
	}
}

func TestChatVoiceAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	var body bytes.Buffer
	mw := multipart.NewWriter(&body)
	_ = mw.WriteField("clientMsgId", "7d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11")
	_ = mw.WriteField("durationMs", "4200")
	part := func(field, name, ct, data string) {
		hd := textproto.MIMEHeader{}
		hd.Set("Content-Disposition", fmt.Sprintf(`form-data; name="%s"; filename="%s"`, field, name))
		hd.Set("Content-Type", ct)
		w, _ := mw.CreatePart(hd)
		_, _ = w.Write([]byte(data))
	}
	part("audio", "voice.webm", "audio/webm", "opus")
	part("wav", "voice.wav", "audio/wav", "RIFFwav")
	_ = mw.Close()
	req := httptest.NewRequest("POST", "/api/w/acme/chat/channels/1/voice", &body)
	req.RemoteAddr = "203.0.113.7:5555"
	for k, v := range cookie {
		req.Header.Set(k, v)
	}
	req.Header.Set("Content-Type", mw.FormDataContentType())
	rec := httptest.NewRecorder()
	h.h.ServeHTTP(rec, req)
	if rec.Code != http.StatusCreated || !strings.Contains(rec.Body.String(), `"transcript":"pending"`) {
		t.Fatalf("voice: %d %s", rec.Code, rec.Body)
	}
	// Played with a range, as players seek.
	req = httptest.NewRequest("GET", "/api/w/acme/chat/messages/77/audio", nil)
	req.RemoteAddr = "203.0.113.7:5555"
	for k, v := range cookie {
		req.Header.Set(k, v)
	}
	req.Header.Set("Range", "bytes=2-5")
	rec = httptest.NewRecorder()
	h.h.ServeHTTP(rec, req)
	if rec.Code != http.StatusPartialContent || rec.Body.String() != "2345" || rec.Header().Get("Content-Type") != "audio/webm" {
		t.Fatalf("audio: %d %q %v", rec.Code, rec.Body, rec.Header())
	}
}

func (f *fakeChat) Search(_ context.Context, q string, channel int64) ([]domain.ChatSearchHit, error) {
	if strings.TrimSpace(q) == "x" {
		return nil, fmt.Errorf("%w: search for a word of 2 letters or more", chat.ErrInvalid)
	}
	m := domain.ChatMessage{ID: 5, ChannelID: max(channel, 1), Author: "bo", Kind: domain.ChatKindText, Body: "the invoice CSV", Refs: []domain.ChatRef{}}
	return []domain.ChatSearchHit{{Message: m, Channel: "general", Snippet: "the " + domain.SearchMarkStart + "invoice" + domain.SearchMarkEnd + " CSV"}}, nil
}

func TestChatSearchAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	rec := h.do("GET", "/api/w/acme/chat/search?q=invoice&channelId=3", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"channel":"general"`) || !strings.Contains(rec.Body.String(), `"channelId":3`) ||
		!strings.Contains(rec.Body.String(), `\u0002invoice\u0003`) {
		t.Fatalf("search: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/w/acme/chat/search?q=x", "", cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("short search: %d %s", rec.Code, rec.Body)
	}
}
