// Package docs serves the "How this page works" Markdown. Built-in texts
// are embedded; files in an override directory (<dir>/<lang>/<page>.md)
// replace them, so the texts can be edited without a deploy.
package docs

import (
	"embed"
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"

	"hiro/internal/domain"
)

//go:embed content
var builtin embed.FS

var pageRe = regexp.MustCompile(`^[a-z][a-z-]{0,31}$`)

// Docs reads page docs.
type Docs struct{ overrideDir string }

// New returns docs with an optional override directory.
func New(overrideDir string) *Docs { return &Docs{overrideDir: overrideDir} }

// Get returns the Markdown for page in lang, falling back to English.
func (d *Docs) Get(page, lang string) ([]byte, error) {
	if !pageRe.MatchString(page) {
		return nil, domain.ErrNotFound
	}
	for _, l := range []string{lang, "en"} {
		if l != "en" && l != "ru" && l != "uz" {
			continue
		}
		if d.overrideDir != "" {
			b, err := os.ReadFile(filepath.Join(d.overrideDir, l, page+".md")) //nolint:gosec // G304: page and lang are validated
			if err == nil {
				return b, nil
			}
			if !errors.Is(err, fs.ErrNotExist) {
				return nil, err
			}
		}
		if b, err := builtin.ReadFile("content/" + l + "/" + page + ".md"); err == nil {
			return b, nil
		}
	}
	return nil, domain.ErrNotFound
}
