package gitrepo

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"slices"
	"strconv"

	"agnts/internal/domain"
)

// Shots keeps preview screenshots on disk as <dir>/<ticket>/<run>/<id>.png.
// They are not backed up: a new preview run makes them again. Implements
// orchestrator.Shots.
type Shots struct{ dir string }

// NewShots stores screenshots under dir.
func NewShots(dir string) *Shots { return &Shots{dir: dir} }

func (s *Shots) ticketDir(key string) (string, error) {
	if !safeKey.MatchString(key) {
		return "", fmt.Errorf("unsafe ticket key %q", key)
	}
	return filepath.Join(s.dir, key), nil
}

func (s *Shots) path(key string, runID int64, id string) (string, error) {
	dir, err := s.ticketDir(key)
	if err != nil {
		return "", err
	}
	if !domain.ShotIDPattern.MatchString(id) || runID <= 0 {
		return "", fmt.Errorf("unsafe screenshot id %q", id)
	}
	return filepath.Join(dir, strconv.FormatInt(runID, 10), id+".png"), nil
}

// Save writes one screenshot atomically.
func (s *Shots) Save(key string, runID int64, id string, png []byte) error {
	p, err := s.path(key, runID, id)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(p), 0o700); err != nil {
		return err
	}
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, png, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}

// Open returns a stored screenshot, or domain.ErrNotFound.
func (s *Shots) Open(key string, runID int64, id string) (io.ReadCloser, error) {
	p, err := s.path(key, runID, id)
	if err != nil {
		return nil, domain.ErrNotFound
	}
	f, err := os.Open(p) //nolint:gosec // G304: path built from validated parts
	if errors.Is(err, os.ErrNotExist) {
		return nil, domain.ErrNotFound
	}
	return f, err
}

// Prune deletes a ticket's screenshots except those of the runs in keep;
// an empty keep deletes them all.
func (s *Shots) Prune(key string, keep []int64) error {
	dir, err := s.ticketDir(key)
	if err != nil {
		return err
	}
	if len(keep) == 0 {
		return os.RemoveAll(dir)
	}
	entries, err := os.ReadDir(dir)
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	var errs []error
	for _, e := range entries {
		id, perr := strconv.ParseInt(e.Name(), 10, 64)
		if perr == nil && slices.Contains(keep, id) {
			continue
		}
		errs = append(errs, os.RemoveAll(filepath.Join(dir, e.Name())))
	}
	return errors.Join(errs...)
}

// Tickets lists the ticket keys that have screenshots.
func (s *Shots) Tickets() ([]string, error) {
	entries, err := os.ReadDir(s.dir)
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	var out []string
	for _, e := range entries {
		if e.IsDir() && safeKey.MatchString(e.Name()) {
			out = append(out, e.Name())
		}
	}
	return out, err
}
