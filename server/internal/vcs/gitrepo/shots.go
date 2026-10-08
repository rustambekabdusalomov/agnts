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

// Shots keeps preview screenshots on disk as
// <dir>/<workspace>/<ticket>/<run>/<id>.png.
// They are not backed up: a new preview run makes them again. Implements
// orchestrator.Shots.
type Shots struct{ dir string }

// NewShots stores screenshots under dir.
func NewShots(dir string) *Shots { return &Shots{dir: dir} }

func (s *Shots) ticketDir(ws int64, key string) (string, error) {
	if !safeKey.MatchString(key) || ws <= 0 {
		return "", fmt.Errorf("unsafe ticket key %q", key)
	}
	return filepath.Join(s.dir, strconv.FormatInt(ws, 10), key), nil
}

func (s *Shots) path(ws int64, key string, runID int64, id string) (string, error) {
	dir, err := s.ticketDir(ws, key)
	if err != nil {
		return "", err
	}
	if !domain.ShotIDPattern.MatchString(id) || runID <= 0 {
		return "", fmt.Errorf("unsafe screenshot id %q", id)
	}
	return filepath.Join(dir, strconv.FormatInt(runID, 10), id+".png"), nil
}

// Save writes one screenshot atomically.
func (s *Shots) Save(ws int64, key string, runID int64, id string, png []byte) error {
	p, err := s.path(ws, key, runID, id)
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
func (s *Shots) Open(ws int64, key string, runID int64, id string) (io.ReadCloser, error) {
	p, err := s.path(ws, key, runID, id)
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
func (s *Shots) Prune(ws int64, key string, keep []int64) error {
	dir, err := s.ticketDir(ws, key)
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

// Tickets lists the tickets that have screenshots.
func (s *Shots) Tickets() ([]domain.TicketRef, error) {
	wss, err := os.ReadDir(s.dir)
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var out []domain.TicketRef
	for _, w := range wss {
		ws, err := strconv.ParseInt(w.Name(), 10, 64)
		if !w.IsDir() || err != nil || ws <= 0 {
			continue
		}
		entries, err := os.ReadDir(filepath.Join(s.dir, w.Name()))
		if err != nil {
			return out, err
		}
		for _, e := range entries {
			if e.IsDir() && safeKey.MatchString(e.Name()) {
				out = append(out, domain.TicketRef{WorkspaceID: ws, Key: e.Name()})
			}
		}
	}
	return out, nil
}

// Delete removes every screenshot of a workspace (it was deleted).
func (s *Shots) Delete(ws int64) error {
	if ws <= 0 {
		return nil
	}
	return os.RemoveAll(filepath.Join(s.dir, strconv.FormatInt(ws, 10)))
}

// AdoptLegacy moves screenshots kept before workspaces (<dir>/<key>) into
// workspace ws, the one the install migrated into.
func (s *Shots) AdoptLegacy(ws int64) error {
	entries, err := os.ReadDir(s.dir)
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	var errs []error
	for _, e := range entries {
		if !e.IsDir() || !safeKey.MatchString(e.Name()) {
			continue
		}
		if _, err := strconv.ParseInt(e.Name(), 10, 64); err == nil {
			continue // a workspace's directory
		}
		dir, err := s.ticketDir(ws, e.Name())
		if err != nil {
			continue
		}
		if err := os.MkdirAll(filepath.Dir(dir), 0o700); err != nil {
			return err
		}
		errs = append(errs, os.Rename(filepath.Join(s.dir, e.Name()), dir))
	}
	return errors.Join(errs...)
}
