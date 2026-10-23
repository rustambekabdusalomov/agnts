package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"agnts/internal/documents"
	"agnts/internal/domain"
)

// publicStore is a document store with one public document; anything
// else the service asks for panics (it must not be reached).
type publicStore struct {
	documents.Store
	documents.CommentStore
	token  string
	pdf    []byte
	guests map[string]domain.DocumentGuest // by token hash
}

func (s *publicStore) CreateGuest(_ context.Context, g domain.DocumentGuest, hash []byte) (domain.DocumentGuest, error) {
	g.ID = int64(len(s.guests) + 1)
	s.guests[string(hash)] = g
	return g, nil
}

func (s *publicStore) GuestByToken(_ context.Context, docID int64, hash []byte) (domain.DocumentGuest, error) {
	g, ok := s.guests[string(hash)]
	if !ok || g.DocumentID != docID {
		return g, domain.ErrNotFound
	}
	return g, nil
}

func (s *publicStore) PublicDocument(_ context.Context, token string) (domain.Document, error) {
	if token != s.token {
		return domain.Document{}, domain.ErrNotFound
	}
	return domain.Document{ID: 7, WorkspaceID: 1, Kind: domain.DocKindPage, Title: "Release notes", Body: "Everything shipped.", Version: 3, Type: domain.DocPublic,
		UpdatedAt: time.Date(2026, 10, 22, 0, 0, 0, 0, time.UTC)}, nil
}

func (s *publicStore) DocumentExport(_ context.Context, _ int64, version int) (domain.DocumentExport, error) {
	if s.pdf == nil {
		return domain.DocumentExport{}, domain.ErrNotFound
	}
	return domain.DocumentExport{Version: version, Status: domain.ExportDone, Data: s.pdf}, nil
}

type countPDF struct{ n int }

func (c *countPDF) RenderPDF(context.Context, []byte) ([]byte, error) {
	c.n++
	return nil, errors.New("not here")
}

func TestPublicDocumentRoutes(t *testing.T) {
	h := newHarness(t, pinger{})
	token := strings.Repeat("Ab3", 15)
	store := &publicStore{token: token, guests: map[string]domain.DocumentGuest{}}
	pdf := &countPDF{}
	pub, _ := url.Parse("https://agnts.example.com")
	var err error
	h.h, err = NewHandler(Options{Documents: documents.New(documents.Deps{Store: store, PDF: pdf, Log: slog.New(slog.NewTextHandler(io.Discard, nil))}),
		Log: slog.New(slog.NewTextHandler(io.Discard, nil)), DB: pinger{}, PublicURL: pub})
	if err != nil {
		t.Fatal(err)
	}

	// Nothing but the kind and title before the reader says who they are.
	rec := h.do(http.MethodGet, "/api/public/documents/"+token, "", nil)
	if rec.Code != http.StatusUnauthorized || !strings.Contains(rec.Body.String(), "guest_required") {
		t.Fatalf("read without a guest: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do(http.MethodGet, "/api/public/documents/"+token+"/download?format=md", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("download without a guest: %d", rec.Code)
	}
	rec = h.do(http.MethodGet, "/api/public/documents/"+token+"/info", "", nil)
	var info map[string]any
	_ = json.Unmarshal(rec.Body.Bytes(), &info)
	if rec.Code != http.StatusOK || info["title"] != "Release notes" || info["kind"] != "page" || len(info) != 2 {
		t.Fatalf("info: %d %v", rec.Code, info)
	}
	if rec := h.do(http.MethodPost, "/api/public/documents/"+token+"/guest", `{"name":"x"}`, map[string]string{"Content-Type": "application/json"}); rec.Code != http.StatusBadRequest {
		t.Fatalf("one-letter name: %d", rec.Code)
	}
	if rec := h.do(http.MethodPost, "/api/public/documents/"+token+"/guest", `{"googleCredential":"abc"}`, map[string]string{"Content-Type": "application/json"}); rec.Code != http.StatusBadRequest {
		t.Fatalf("Google without a client id: %d", rec.Code)
	}
	if rec := h.do(http.MethodPost, "/api/public/documents/"+token+"/guest", `{}`, map[string]string{"Content-Type": "application/json"}); rec.Code != http.StatusBadRequest {
		t.Fatalf("no name and not signed in: %d", rec.Code)
	}
	rec = h.do(http.MethodPost, "/api/public/documents/"+token+"/guest", `{"name":"  Dilnoza   K. "}`, map[string]string{"Content-Type": "application/json"})
	var sess struct{ Token, Name string }
	_ = json.Unmarshal(rec.Body.Bytes(), &sess)
	if rec.Code != http.StatusCreated || sess.Token == "" || sess.Name != "Dilnoza K." {
		t.Fatalf("join: %d %s", rec.Code, rec.Body)
	}
	as := map[string]string{"X-Guest-Token": sess.Token}
	if rec := h.do(http.MethodGet, "/api/public/documents/"+token, "", map[string]string{"X-Guest-Token": "nope"}); rec.Code != http.StatusUnauthorized {
		t.Fatalf("someone else's token: %d", rec.Code)
	}

	rec = h.do(http.MethodGet, "/api/public/documents/"+token, "", as)
	if rec.Code != http.StatusOK {
		t.Fatalf("public read: %d %s", rec.Code, rec.Body)
	}
	var got map[string]any
	_ = json.Unmarshal(rec.Body.Bytes(), &got)
	if got["title"] != "Release notes" || got["body"] != "Everything shipped." || got["kind"] != "page" || len(got) != 5 {
		t.Fatalf("public body has more than kind, title, body, version and date: %v", got)
	}
	if rec.Header().Get("X-Robots-Tag") == "" || rec.Header().Get("Referrer-Policy") != "no-referrer" {
		t.Fatalf("headers: %v", rec.Header())
	}
	if rec := h.do(http.MethodGet, "/api/public/documents/"+strings.Repeat("Zz9", 15), "", nil); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown token: %d", rec.Code)
	}
	if rec := h.do(http.MethodGet, "/api/public/documents/short", "", nil); rec.Code != http.StatusBadRequest && rec.Code != http.StatusNotFound {
		t.Fatalf("malformed token: %d", rec.Code)
	}

	rec = h.do(http.MethodGet, "/api/public/documents/"+token+"/download?format=md", "", as)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Header().Get("Content-Disposition"), `filename="release-notes-v3.md"`) ||
		rec.Body.String() != "# Release notes\n\nEverything shipped.\n" {
		t.Fatalf("md download: %d %v %q", rec.Code, rec.Header(), rec.Body)
	}
	// No PDF made ahead: 202, and the visitor starts nothing.
	rec = h.do(http.MethodGet, "/api/public/documents/"+token+"/download?format=pdf", "", as)
	if rec.Code != http.StatusAccepted || rec.Header().Get("Retry-After") == "" || pdf.n != 0 {
		t.Fatalf("pdf not ready: %d %v renders=%d", rec.Code, rec.Header(), pdf.n)
	}
	store.pdf = []byte("%PDF-1.7")
	rec = h.do(http.MethodGet, "/api/public/documents/"+token+"/download?format=pdf", "", as)
	if rec.Code != http.StatusOK || rec.Header().Get("Content-Type") != "application/pdf" || rec.Body.String() != "%PDF-1.7" {
		t.Fatalf("pdf: %d %v", rec.Code, rec.Header())
	}
	// Public routes are rate limited per address.
	limited := false
	for range 310 {
		if h.do(http.MethodGet, "/api/public/documents/"+token+"/info", "", nil).Code == http.StatusTooManyRequests {
			limited = true
			break
		}
	}
	if !limited {
		t.Fatal("no rate limit on public documents")
	}
}

func TestDocumentRoutesNeedASession(t *testing.T) {
	h := newHarness(t, pinger{})
	for _, p := range []string{"/api/documents", "/api/documents/1", "/api/documents/1/download", "/api/tickets/A-1/documents"} {
		if rec := h.do(http.MethodGet, p, "", nil); rec.Code != http.StatusUnauthorized {
			t.Errorf("%s without a session: %d", p, rec.Code)
		}
	}
}

func TestDocumentErrors(t *testing.T) {
	s := &Server{opt: Options{Log: slog.New(slog.NewTextHandler(io.Discard, nil))}}
	cases := []struct {
		err  error
		code int
	}{
		{domain.ErrNotFound, http.StatusNotFound},
		{fmt.Errorf("%w: this needs edit access", domain.ErrForbidden), http.StatusForbidden},
		{fmt.Errorf("%w: bad", domain.ErrDocInvalid), http.StatusBadRequest},
		{documents.ErrBusy, http.StatusConflict},
		{documents.ErrPreparing, http.StatusAccepted},
		{documents.ErrNoGuest, http.StatusUnauthorized},
		{documents.ErrTooMany, http.StatusTooManyRequests},
		{fmt.Errorf("%w: crashed", documents.ErrRenderFailed), http.StatusServiceUnavailable},
		{&documents.SecretsError{Findings: []domain.SecretFinding{{Line: 3, Excerpt: "key •••"}}}, http.StatusUnprocessableEntity},
		{errors.New("boom"), http.StatusInternalServerError},
	}
	for _, c := range cases {
		rec := httptest.NewRecorder()
		s.documentError(rec, httptest.NewRequest(http.MethodGet, "/", nil), c.err)
		if rec.Code != c.code {
			t.Errorf("%v: %d, want %d", c.err, rec.Code, c.code)
		}
		if c.code == http.StatusUnprocessableEntity && !strings.Contains(rec.Body.String(), `"line":3`) {
			t.Errorf("findings missing: %s", rec.Body)
		}
	}
}
