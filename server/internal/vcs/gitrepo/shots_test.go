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
		if err := s.Save("PAY-1", run, "home-phone-after", []byte{byte(run)}); err != nil {
			t.Fatal(err)
		}
	}
	rc, err := s.Open("PAY-1", 2, "home-phone-after")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(rc)
	_ = rc.Close()
	if len(b) != 1 || b[0] != 2 {
		t.Fatalf("read %v", b)
	}
	for _, bad := range []struct {
		key string
		run int64
		id  string
	}{{"../x", 1, "a"}, {"PAY-1", 1, "../../etc"}, {"PAY-1", 0, "a"}, {"PAY-1", 1, "missing"}} {
		if _, err := s.Open(bad.key, bad.run, bad.id); !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("open %+v: %v", bad, err)
		}
	}
	if err := s.Save("PAY-1", 1, "../x", nil); err == nil {
		t.Fatal("unsafe id saved")
	}
	if err := s.Prune("PAY-1", []int64{2, 3}); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(dir, "PAY-1", "1")); !os.IsNotExist(err) {
		t.Fatal("run 1 kept")
	}
	keys, _ := s.Tickets()
	if !slices.Equal(keys, []string{"PAY-1"}) {
		t.Fatalf("tickets: %v", keys)
	}
	if err := s.Prune("PAY-1", nil); err != nil {
		t.Fatal(err)
	}
	if keys, _ := s.Tickets(); len(keys) != 0 {
		t.Fatalf("after prune: %v", keys)
	}
}
