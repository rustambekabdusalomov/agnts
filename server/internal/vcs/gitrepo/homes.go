package gitrepo

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

var safeKey = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9_-]*$`)

// Homes keeps each ticket's Claude Code config dir (a tar) on disk so a later
// run can --resume the session, as <dir>/<workspace>/<key>.tar. Implements
// orchestrator.Homes.
type Homes struct{ dir, ext string }

// NewHomes stores tars under dir.
func NewHomes(dir string) *Homes { return &Homes{dir: dir, ext: ".tar"} }

func (h *Homes) path(ws int64, key string) (string, error) {
	if !safeKey.MatchString(key) || ws <= 0 {
		return "", fmt.Errorf("unsafe ticket key %q", key)
	}
	return filepath.Join(h.dir, strconv.FormatInt(ws, 10), key+h.ext), nil
}

// Load returns the saved tar, or nil when there is none.
func (h *Homes) Load(ws int64, key string) ([]byte, error) {
	p, err := h.path(ws, key)
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
func (h *Homes) Save(ws int64, key string, tar []byte) error {
	if len(tar) == 0 {
		return nil
	}
	p, err := h.path(ws, key)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(p), 0o700); err != nil {
		return err
	}
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, tar, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}

// Drop removes a ticket's saved tar, if any.
func (h *Homes) Drop(ws int64, key string) error {
	p, err := h.path(ws, key)
	if err != nil {
		return err
	}
	if err := os.Remove(p); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}

// Delete removes the saved tars of a workspace (it was deleted).
func (h *Homes) Delete(ws int64) error {
	if ws <= 0 {
		return nil
	}
	return os.RemoveAll(filepath.Join(h.dir, strconv.FormatInt(ws, 10)))
}

// AdoptLegacy moves tars saved before workspaces (<dir>/<key>.tar) into
// workspace ws, the one the install migrated into.
func (h *Homes) AdoptLegacy(ws int64) error {
	entries, err := os.ReadDir(h.dir)
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	var errs []error
	for _, e := range entries {
		key, ok := strings.CutSuffix(e.Name(), ".tar")
		if e.IsDir() || !ok || !safeKey.MatchString(key) {
			continue
		}
		p, err := h.path(ws, key)
		if err != nil {
			continue
		}
		if err := os.MkdirAll(filepath.Dir(p), 0o700); err != nil {
			return err
		}
		errs = append(errs, os.Rename(filepath.Join(h.dir, e.Name()), p))
	}
	return errors.Join(errs...)
}
