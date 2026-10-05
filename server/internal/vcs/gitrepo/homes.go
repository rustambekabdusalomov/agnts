package gitrepo

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
)

var safeKey = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9_-]*$`)

// Homes keeps each ticket's Claude Code config dir (a tar) on disk so a later
// run can --resume the session. Implements orchestrator.Homes.
type Homes struct{ dir string }

// NewHomes stores tars under dir.
func NewHomes(dir string) *Homes { return &Homes{dir: dir} }

func (h *Homes) path(key string) (string, error) {
	if !safeKey.MatchString(key) {
		return "", fmt.Errorf("unsafe ticket key %q", key)
	}
	return filepath.Join(h.dir, key+".tar"), nil
}

// Load returns the saved tar, or nil when there is none.
func (h *Homes) Load(key string) ([]byte, error) {
	p, err := h.path(key)
	if err != nil {
		return nil, err
	}
	b, err := os.ReadFile(p) //nolint:gosec // G304: path built from a validated key
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	return b, err
}

// Save replaces the saved tar atomically.
func (h *Homes) Save(key string, tar []byte) error {
	if len(tar) == 0 {
		return nil
	}
	p, err := h.path(key)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(h.dir, 0o700); err != nil {
		return err
	}
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, tar, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}
