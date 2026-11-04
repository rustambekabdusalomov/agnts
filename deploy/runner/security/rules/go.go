package rules

import (
	"context"
	"crypto/md5"
	"crypto/tls"
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

func sqli(db *sql.DB, r *http.Request) {
	q := r.URL.Query().Get("q")
	// ruleid: agnts.go.sqli.request-into-query
	db.Query("SELECT * FROM t WHERE a = '" + q + "'")
	// ok: agnts.go.sqli.request-into-query
	db.Query("SELECT * FROM t WHERE a = $1", q)
	// ok: agnts.go.sqli.formatted-query
	db.Exec(fmt.Sprintf("DELETE FROM t WHERE id = %d", 3))
	// ok: agnts.go.sqli.formatted-query
	db.Exec("DELETE FROM t WHERE id = $1", 3)
}

const columns = "id, name"

var tableCols = "id, name" // a column list: not a parameter

type store struct{ db *sql.DB }

// The query is built in a variable from a parameter and run pgx-style,
// context first: what a request handler one call up passes in.
func (s *store) search(ctx context.Context, q string, after int64) {
	// ruleid: agnts.go.sqli.formatted-query
	query := `SELECT ` + columns + ` FROM products
	  WHERE name ILIKE '%` + q + `%' AND id > $1`
	s.db.Query(ctx, query, after)
}

func (s *store) built(ctx context.Context, q, sort string) {
	// ruleid: agnts.go.sqli.formatted-query
	s.db.QueryRow(ctx, "SELECT * FROM t WHERE a = '"+q+"'")
	// ruleid: agnts.go.sqli.formatted-query
	s.db.Exec("UPDATE t SET a = 1 WHERE b = '" + q + "'")
	// ruleid: agnts.go.sqli.formatted-query
	query := fmt.Sprintf("SELECT * FROM t WHERE a = '%s'", q)
	s.db.QueryRowContext(ctx, query)
	where := "SELECT * FROM t WHERE 1 = 1"
	// ruleid: agnts.go.sqli.formatted-query
	where += " ORDER BY " + sort
	s.db.Query(ctx, where)
}

func (s *store) safe(ctx context.Context, q, schema string, id int64) {
	// ok: agnts.go.sqli.formatted-query
	s.db.Query(ctx, `SELECT `+columns+` FROM products WHERE id > $1`, id)
	// ok: agnts.go.sqli.formatted-query
	s.db.Query(ctx, `SELECT `+tableCols+` FROM products WHERE id > $1`, id)
	// ok: agnts.go.sqli.formatted-query
	query := `SELECT ` + columns + ` FROM products WHERE id = $1`
	s.db.QueryRow(ctx, query, id)
	// ok: agnts.go.sqli.formatted-query
	s.db.Query("SELECT * FROM t WHERE name ILIKE $1", "%"+q+"%")
	// ok: agnts.go.sqli.formatted-query
	s.db.Query(ctx, "SELECT * FROM t WHERE name ILIKE $1", "%"+q+"%")
	// ok: agnts.go.sqli.formatted-query
	like := "%" + q + "%"
	s.db.Query("SELECT * FROM t WHERE name ILIKE $1", like)
	// ok: agnts.go.sqli.formatted-query
	s.db.Exec(ctx, "CREATE SCHEMA "+pgx.Identifier{schema}.Sanitize())
	// ok: agnts.go.sqli.formatted-query
	s.db.Exec(fmt.Sprintf("DELETE FROM t WHERE id = %d", id))
}

type runner interface{ Exec(ctx context.Context, cmd string) error }

func shell(ctx context.Context, ws runner, dir string) {
	// ok: agnts.go.sqli.formatted-query
	ws.Exec(ctx, "cd "+dir+" && make")
}

func ginHandler(c *gin.Context, db *sql.DB) {
	ctx := c.Request.Context()
	// ok: agnts.go.sqli.request-into-query
	name := c.Query("name")
	// ruleid: agnts.go.sqli.request-into-query
	db.Query(ctx, "SELECT * FROM t WHERE name = '"+name+"'")
	// ok: agnts.go.sqli.request-into-query
	db.Query(ctx, "SELECT * FROM t WHERE name = $1", name)
	rows, _ := db.Query("SELECT name FROM t")
	var stored string
	rows.Scan(&stored)
	// ok: agnts.go.sqli.request-into-query
	db.Exec("UPDATE t SET seen = true WHERE name = $1", stored)
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
