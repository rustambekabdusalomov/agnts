package rules

import (
	"crypto/md5"
	"crypto/tls"
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
)

func sqli(db *sql.DB, r *http.Request) {
	q := r.URL.Query().Get("q")
	// ruleid: agnts.go.sqli.request-into-query
	db.Query("SELECT * FROM t WHERE a = '" + q + "'")
	// ok: agnts.go.sqli.request-into-query
	db.Query("SELECT * FROM t WHERE a = $1", q)
	// ruleid: agnts.go.sqli.formatted-query
	db.Exec(fmt.Sprintf("DELETE FROM t WHERE id = %d", 3))
	// ok: agnts.go.sqli.formatted-query
	db.Exec("DELETE FROM t WHERE id = $1", 3)
}

func cmd(name string) {
	// ruleid: agnts.go.cmdi.shell-with-input
	exec.Command("sh", "-c", "ls "+name).Run()
	// ok: agnts.go.cmdi.shell-with-input
	exec.Command("sh", "-c", "ls -la").Run()
}

func files(r *http.Request) {
	// ruleid: agnts.go.path.request-into-file
	os.Open(filepath.Join("/srv", r.URL.Query().Get("f")))
	// ok: agnts.go.path.request-into-file
	os.Open(filepath.Join("/srv", filepath.Base(r.URL.Query().Get("f"))))
}

func ssrf(r *http.Request) {
	// ruleid: agnts.go.ssrf.request-into-url
	http.Get(r.FormValue("url"))
	// ok: agnts.go.ssrf.request-into-url
	http.Get("https://example.com")
}

func crypto() {
	// ruleid: agnts.go.tls.insecure-skip-verify
	_ = &tls.Config{MinVersion: tls.VersionTLS12, InsecureSkipVerify: true}
	// ok: agnts.go.tls.insecure-skip-verify
	_ = &tls.Config{MinVersion: tls.VersionTLS12}
	// ruleid: agnts.go.crypto.weak-hash
	_ = md5.Sum([]byte("x"))
}
