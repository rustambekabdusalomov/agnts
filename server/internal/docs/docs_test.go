package docs

import (
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"hiro/internal/domain"
)

func TestDocs(t *testing.T) {
	dir := t.TempDir()
	d := New(dir)
	b, err := d.Get("logs", "ru")
	if err != nil || !strings.HasPrefix(string(b), "# ") {
		t.Fatalf("builtin ru: %q %v", b, err)
	}
	if _, err := d.Get("../etc", "en"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatal("traversal accepted")
	}
	if _, err := d.Get("nope", "en"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatal("missing page")
	}
	_ = os.MkdirAll(filepath.Join(dir, "en"), 0o750)
	_ = os.WriteFile(filepath.Join(dir, "en", "logs.md"), []byte("# Custom"), 0o600)
	if b, _ := d.Get("logs", "en"); string(b) != "# Custom" {
		t.Fatal("override not used")
	}
	if b, _ := d.Get("logs", "xx"); string(b) != "# Custom" {
		t.Fatal("unknown language should fall back to English")
	}
}
