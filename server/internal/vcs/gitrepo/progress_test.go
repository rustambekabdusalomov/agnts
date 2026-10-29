package gitrepo

import (
	"os"
	"path/filepath"
	"testing"
)

func TestProgressSaveLoadDrop(t *testing.T) {
	dir := t.TempDir()
	p := NewProgress(dir)
	if b, err := p.Load(1, "PAY-1"); b != nil || err != nil {
		t.Fatalf("nothing saved yet: %q %v", b, err)
	}
	if err := p.Save(1, "PAY-1", []byte(`{"repos":[]}`)); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(dir, "1", "PAY-1.json")); err != nil {
		t.Fatalf("not at <dir>/<workspace>/<key>.json: %v", err)
	}
	if b, _ := p.Load(1, "PAY-1"); string(b) != `{"repos":[]}` {
		t.Fatalf("loaded %q", b)
	}
	if b, _ := p.Load(2, "PAY-1"); b != nil {
		t.Fatal("another workspace sees it")
	}
	if err := p.Drop(1, "PAY-1"); err != nil {
		t.Fatal(err)
	}
	if err := p.Drop(1, "PAY-1"); err != nil {
		t.Fatalf("dropping nothing: %v", err)
	}
	if b, _ := p.Load(1, "PAY-1"); b != nil {
		t.Fatal("still there after Drop")
	}
	if err := p.Save(1, "../x", []byte("x")); err == nil {
		t.Fatal("unsafe key accepted")
	}
	_ = p.Save(1, "PAY-2", []byte("x"))
	if err := p.Delete(1); err != nil {
		t.Fatal(err)
	}
	if b, _ := p.Load(1, "PAY-2"); b != nil {
		t.Fatal("still there after the workspace was deleted")
	}
}
