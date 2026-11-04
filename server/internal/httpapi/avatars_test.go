package httpapi

import (
	"bytes"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestAvatarAPI(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	put := func(name string, data []byte) *httptest.ResponseRecorder {
		var body bytes.Buffer
		mw := multipart.NewWriter(&body)
		fw, _ := mw.CreateFormFile("file", name)
		_, _ = fw.Write(data)
		_ = mw.Close()
		req := httptest.NewRequest("PUT", "/api/account/avatar", &body)
		req.Header.Set("Content-Type", mw.FormDataContentType())
		req.Header.Set("Cookie", cookie["Cookie"])
		rec := httptest.NewRecorder()
		h.h.ServeHTTP(rec, req)
		return rec
	}
	png := append([]byte("\x89PNG\r\n\x1a\n"), bytes.Repeat([]byte{0}, 64)...)

	rec := put("me.png", png)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"avatarUrl":"/users/1/avatar?v=1"`) {
		t.Fatalf("upload: %d %s", rec.Code, rec.Body)
	}
	// The picture loads, cached for good at its version; anything not a picture is refused.
	rec = h.do("GET", "/api/users/1/avatar?v=1", "", cookie)
	if rec.Code != http.StatusOK || rec.Header().Get("Content-Type") != "image/png" || !strings.Contains(rec.Header().Get("Cache-Control"), "immutable") ||
		!strings.Contains(rec.Header().Get("Content-Security-Policy"), "sandbox") {
		t.Fatalf("load: %d %v", rec.Code, rec.Header())
	}
	if rec := put("x.svg", []byte(`<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>`)); rec.Code != http.StatusBadRequest {
		t.Fatalf("svg: %d %s", rec.Code, rec.Body)
	}
	if rec := put("big.png", append(png, bytes.Repeat([]byte{0}, MaxAvatarBytes)...)); rec.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("too large: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/auth/me", "", cookie); !strings.Contains(rec.Body.String(), `"avatarUrl":"/users/1/avatar?v=1"`) {
		t.Fatalf("me: %s", rec.Body)
	}
	// Removed: no URL, and the picture is gone.
	if rec := h.do("DELETE", "/api/account/avatar", "", cookie); rec.Code != http.StatusOK || strings.Contains(rec.Body.String(), "avatarUrl") {
		t.Fatalf("delete: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/users/1/avatar", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("after delete: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/users/1/avatar", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("signed out: %d", rec.Code)
	}
}
