package documents

import (
	"context"
	"fmt"

	"agnts/internal/domain"
)

// Translator translates texts, keeping each translation so a text is
// sent once per language (the orchestrator).
type Translator interface {
	// TranslateTexts returns texts translated into lang, by source text;
	// a text it could not translate is absent.
	TranslateTexts(ctx context.Context, subject, lang string, texts []string) (map[string]string, error)
}

// Translation is a version of a document in another language.
type Translation struct {
	Lang    string
	Version int
	Title   string
	Body    string
	// Complete is false when some blocks are still as written.
	Complete bool
}

// Translate returns the current version of a document translated into
// lang. Reading is enough. Blocks translated before, for this document or
// any other text, come from the store; the rest are translated now.
func (s *Service) Translate(ctx context.Context, c Caller, id int64, lang string) (Translation, error) {
	v, err := s.open(ctx, c, id)
	if err != nil {
		return Translation{}, err
	}
	d := v.Doc
	if d.Version == 0 {
		if d.Generating() {
			return Translation{}, ErrBusy
		}
		return Translation{}, domain.ErrNotFound // nothing written yet
	}
	ver, err := s.d.Store.DocumentVersion(ctx, id, d.Version)
	if err != nil {
		return Translation{}, err
	}
	return s.translate(ctx, d, ver, lang)
}

// translate translates one version.
func (s *Service) translate(ctx context.Context, d domain.Document, ver domain.DocumentVersion, lang string) (Translation, error) {
	if _, ok := domain.Languages[lang]; !ok {
		return Translation{}, invalid("unknown language %q", lang)
	}
	if s.d.Translator == nil {
		return Translation{}, invalid("translation is not available on this server")
	}
	segs := domain.SegmentDocument(d.Kind, ver.Body)
	texts := domain.SegmentTexts(segs)
	if ver.Title != "" {
		texts = append([]string{ver.Title}, texts...)
	}
	tr, err := s.d.Translator.TranslateTexts(ctx, fmt.Sprintf("document-%d", d.ID), lang, texts)
	if err != nil {
		return Translation{}, err
	}
	body, complete := domain.JoinSegments(segs, tr)
	title, ok := tr[ver.Title]
	if !ok || ver.Title == "" {
		title, complete = ver.Title, complete && ver.Title == ""
	}
	return Translation{Lang: lang, Version: ver.Version, Title: title, Body: body, Complete: complete}, nil
}
