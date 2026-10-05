package httpapi

import (
	"net/http"
	"os"
	"path"
	"path/filepath"
	"strings"
)

// spaHandler serves the built admin panel from dir. Unknown paths get
// index.html so client-side routes work on reload. Hashed assets are cached
// for a year; index.html is never cached so a deploy is picked up at once.
func spaHandler(dir string) http.Handler {
	files := http.FileServer(http.Dir(dir))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			http.NotFound(w, r)
			return
		}
		p := path.Clean("/" + r.URL.Path)
		if p != "/" {
			//nolint:gosec // G703: p is path.Clean("/"+...), so it cannot climb out of dir
			if fi, err := os.Stat(filepath.Join(dir, filepath.FromSlash(p))); err == nil && !fi.IsDir() {
				if strings.HasPrefix(p, "/assets/") {
					w.Header().Set("Cache-Control", "public, max-age=31536000, immutable")
				}
				files.ServeHTTP(w, r)
				return
			}
			if path.Ext(p) != "" {
				http.NotFound(w, r) // a missing file, not a client route
				return
			}
		}
		w.Header().Set("Cache-Control", "no-cache")
		http.ServeFile(w, r, filepath.Join(dir, "index.html"))
	})
}
