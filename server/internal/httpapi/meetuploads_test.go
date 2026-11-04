package httpapi

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

// TestBodyLimitLeavesMeetingUploads checks a meeting's recording upload is
// not cut at the small JSON limit (its handler limits it), and other
// requests still are.
func TestBodyLimitLeavesMeetingUploads(t *testing.T) {
	var read int
	h := bodyLimit(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n, err := io.Copy(io.Discard, r.Body)
		read = int(n)
		if err != nil {
			w.WriteHeader(http.StatusRequestEntityTooLarge)
		}
	}))
	big := bytes.Repeat([]byte("x"), 3*maxBodyBytes)
	for _, c := range []struct {
		method, path string
		want         int
	}{
		{http.MethodPost, "/api/w/acme/meetings/12/uploads", http.StatusOK},
		{http.MethodPost, "/api/meetings/12/uploads", http.StatusOK},
		{http.MethodPost, "/api/w/acme/meetings/12/invitees", http.StatusRequestEntityTooLarge},
		{http.MethodPost, "/api/w/acme/uploads", http.StatusRequestEntityTooLarge},
		{http.MethodPut, "/api/w/acme/meetings/12/uploads", http.StatusRequestEntityTooLarge},
	} {
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, httptest.NewRequest(c.method, c.path, bytes.NewReader(big)))
		if rec.Code != c.want {
			t.Errorf("%s %s: %d (read %d), want %d", c.method, c.path, rec.Code, read, c.want)
		}
	}
}
