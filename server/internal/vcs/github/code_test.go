package github

import (
	"context"
	"encoding/base64"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

func TestCode(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("ref") != "feature/x" {
			t.Errorf("ref: %s", r.URL.RawQuery)
		}
		switch r.URL.EscapedPath() {
		case "/repos/acme/api/contents":
			_, _ = io.WriteString(w, `[{"name":"main.go","path":"main.go","type":"file","size":12,"download_url":"d"},
				{"name":"vendor","path":"vendor","type":"file","size":0,"download_url":null},
				{"name":"cmd","path":"cmd","type":"dir","size":0},
				{"name":"Api","path":"Api","type":"dir","size":0}]`)
		case "/repos/acme/api/contents/cmd/my%20app.go":
			_, _ = io.WriteString(w, `{"type":"file","path":"cmd/my app.go","size":12,"encoding":"base64","html_url":"h",
				"content":"`+base64.StdEncoding.EncodeToString([]byte("package main"))+`"}`)
		case "/repos/acme/api/contents/logo.png":
			_, _ = io.WriteString(w, `{"type":"file","path":"logo.png","size":4,"encoding":"base64","content":"`+base64.StdEncoding.EncodeToString([]byte{0x89, 'P', 0, 1})+`"}`)
		case "/repos/acme/api/contents/big.sql":
			_, _ = io.WriteString(w, `{"type":"file","path":"big.sql","size":5000000,"encoding":"none","content":""}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git"}
	ctx := context.Background()

	es, err := h.Tree(ctx, repo, "feature/x", "")
	if err != nil {
		t.Fatal(err)
	}
	if len(es) != 4 || es[0].Name != "Api" || es[1].Name != "cmd" || es[2].Name != "main.go" || es[2].Size != 12 || es[3].Type != vcs.EntrySubmodule {
		t.Fatalf("tree: %+v", es)
	}
	if _, err := h.Tree(ctx, repo, "feature/x", "cmd/my app.go"); err == nil {
		t.Fatal("a file listed as a directory")
	}

	f, err := h.File(ctx, repo, "feature/x", "cmd/my app.go")
	if err != nil || f.Content != "package main" || f.Binary || f.TooLarge || f.URL != "h" {
		t.Fatalf("file: %+v %v", f, err)
	}
	if f, err := h.File(ctx, repo, "feature/x", "logo.png"); err != nil || !f.Binary || f.Content != "" {
		t.Fatalf("binary: %+v %v", f, err)
	}
	if f, err := h.File(ctx, repo, "feature/x", "big.sql"); err != nil || !f.TooLarge || f.Size != 5000000 {
		t.Fatalf("large: %+v %v", f, err)
	}
	if _, err := h.File(ctx, repo, "feature/x", ""); err == nil {
		t.Fatal("the root read as a file")
	}
}
