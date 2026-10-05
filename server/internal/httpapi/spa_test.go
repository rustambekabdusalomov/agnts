package httpapi

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestSPAHandler(t *testing.T) {
	dir := t.TempDir()
	must := func(err error) {
		t.Helper()
		if err != nil {
			t.Fatal(err)
		}
	}
	must(os.WriteFile(filepath.Join(dir, "index.html"), []byte("<html>app</html>"), 0o600))
	must(os.MkdirAll(filepath.Join(dir, "assets"), 0o750))
	must(os.WriteFile(filepath.Join(dir, "assets", "app-123.js"), []byte("js"), 0o600))

	h := spaHandler(dir)
	get := func(path string) *httptest.ResponseRecorder {
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, httptest.NewRequest("GET", path, nil))
		return rec
	}

	if rec := get("/assets/app-123.js"); rec.Code != http.StatusOK || rec.Header().Get("Cache-Control") != "public, max-age=31536000, immutable" {
		t.Fatalf("asset: %d %q", rec.Code, rec.Header().Get("Cache-Control"))
	}
	if rec := get("/tickets/ABC-1"); rec.Code != http.StatusOK || rec.Body.String() != "<html>app</html>" || rec.Header().Get("Cache-Control") != "no-cache" {
		t.Fatalf("client route: %d %q", rec.Code, rec.Body)
	}
	if rec := get("/missing.js"); rec.Code != http.StatusNotFound {
		t.Fatalf("missing file: %d", rec.Code)
	}
	if rec := get("/../../etc/passwd"); rec.Code == http.StatusOK && rec.Body.String() != "<html>app</html>" {
		t.Fatal("path traversal escaped the web dir")
	}
}
