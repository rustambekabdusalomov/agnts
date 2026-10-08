package gitrepo

import (
	"errors"
	"io"
	"os"
	"path/filepath"
	"slices"
	"testing"

	"agnts/internal/domain"
)

func TestShots(t *testing.T) {
	dir := t.TempDir()
	s := NewShots(dir)
	for _, run := range []int64{1, 2, 3} {
		if err := s.Save(7, "PAY-1", run, "home-phone-after", []byte{byte(run)}); err != nil {
			t.Fatal(err)
		}
	}
	rc, err := s.Open(7, "PAY-1", 2, "home-phone-after")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(rc)
	_ = rc.Close()
	if len(b) != 1 || b[0] != 2 {
		t.Fatalf("read %v", b)
	}
	// Another workspace's ticket with the same key has none.
	if _, err := s.Open(8, "PAY-1", 2, "home-phone-after"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace read the screenshot: %v", err)
	}
	for _, bad := range []struct {
		ws  int64
		key string
		run int64
		id  string
	}{{7, "../x", 1, "a"}, {7, "PAY-1", 1, "../../etc"}, {7, "PAY-1", 0, "a"}, {7, "PAY-1", 1, "missing"}, {0, "PAY-1", 1, "home-phone-after"}} {
		if _, err := s.Open(bad.ws, bad.key, bad.run, bad.id); !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("open %+v: %v", bad, err)
		}
	}
	if err := s.Save(7, "PAY-1", 1, "../x", nil); err == nil {
		t.Fatal("unsafe id saved")
	}
	if err := s.Prune(7, "PAY-1", []int64{2, 3}); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(dir, "7", "PAY-1", "1")); !os.IsNotExist(err) {
		t.Fatal("run 1 kept")
	}
	refs, _ := s.Tickets()
	if !slices.Equal(refs, []domain.TicketRef{{WorkspaceID: 7, Key: "PAY-1"}}) {
		t.Fatalf("tickets: %v", refs)
	}
	if err := s.Prune(7, "PAY-1", nil); err != nil {
		t.Fatal(err)
	}
	if refs, _ := s.Tickets(); len(refs) != 0 {
		t.Fatalf("after prune: %v", refs)
	}
}

func TestShotsAdoptLegacyAndDelete(t *testing.T) {
	dir := t.TempDir()
	if err := os.MkdirAll(filepath.Join(dir, "PAY-1", "3"), 0o700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, "PAY-1", "3", "a.png"), []byte("x"), 0o600); err != nil {
		t.Fatal(err)
	}
	s := NewShots(dir)
	if err := s.AdoptLegacy(4); err != nil {
		t.Fatal(err)
	}
	if rc, err := s.Open(4, "PAY-1", 3, "a"); err != nil {
		t.Fatalf("adopted screenshot: %v", err)
	} else {
		_ = rc.Close()
	}
	if err := s.Delete(4); err != nil {
		t.Fatal(err)
	}
	if refs, _ := s.Tickets(); len(refs) != 0 {
		t.Fatalf("after delete: %v", refs)
	}
}
