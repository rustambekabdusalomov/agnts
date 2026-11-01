package watch

import (
	"bufio"
	"context"
	"errors"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"agnts/internal/domain"
)

// filePoll is how often files are checked for new lines.
const filePoll = 2 * time.Second

// tailed is one file being followed.
type tailed struct {
	f      *os.File
	info   os.FileInfo
	offset int64
	rest   string // a line without its newline yet
}

// watchFiles follows every file glob matches, from its current end, as
// one service. It notices rotation (the file shrank or was replaced) and
// new files matching the glob.
func (a *Agent) watchFiles(ctx context.Context, svc, glob string) {
	files := map[string]*tailed{}
	defer func() {
		for _, t := range files {
			_ = t.f.Close()
		}
	}()
	first := true
	t := time.NewTicker(filePoll)
	defer t.Stop()
	for {
		paths, _ := filepath.Glob(glob)
		for _, p := range paths {
			if _, ok := files[p]; ok {
				continue
			}
			f, err := os.Open(p) //nolint:gosec // G304: the operator's AGNTS_WATCH_FILES globs
			if err != nil {
				continue
			}
			info, err := f.Stat()
			if err != nil || info.IsDir() {
				_ = f.Close()
				continue
			}
			tf := &tailed{f: f, info: info}
			if first {
				tf.offset = info.Size() // existing files: from now on
			}
			files[p] = tf
			a.log.Info("following file", "service", svc, "path", p)
		}
		first = false
		for p, tf := range files {
			if err := a.readFile(svc, p, tf); err != nil {
				_ = tf.f.Close()
				delete(files, p)
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

// readFile reads what was appended to one file since the last read.
func (a *Agent) readFile(svc, path string, tf *tailed) error {
	now, err := os.Stat(path)
	if err != nil {
		return err // gone; picked up again if it comes back
	}
	if !os.SameFile(now, tf.info) || now.Size() < tf.offset {
		// Rotated: read the new file from the start.
		f, err := os.Open(path) //nolint:gosec // G304: as above
		if err != nil {
			return err
		}
		_ = tf.f.Close()
		tf.f, tf.info, tf.offset, tf.rest = f, now, 0, ""
	}
	if now.Size() == tf.offset {
		return nil
	}
	if _, err := tf.f.Seek(tf.offset, io.SeekStart); err != nil {
		return err
	}
	r := bufio.NewReader(io.LimitReader(tf.f, now.Size()-tf.offset))
	for {
		chunk, err := r.ReadString('\n')
		tf.offset += int64(len(chunk))
		if strings.HasSuffix(chunk, "\n") {
			line := strings.TrimRight(tf.rest+chunk, "\r\n")
			tf.rest = ""
			a.emit(domain.LogEntry{Service: svc, Stream: svc + ":" + filepath.Base(path), Message: line})
		} else {
			tf.rest += chunk
		}
		if errors.Is(err, io.EOF) {
			return nil
		}
		if err != nil {
			return err
		}
	}
}
