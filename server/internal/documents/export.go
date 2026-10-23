package documents

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"html"
	"regexp"
	"strings"
	"time"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/extension"

	"agnts/internal/domain"
)

// Formats a document downloads as.
const (
	FormatMarkdown = "md"
	FormatPDF      = "pdf"
)

// File is a download.
type File struct {
	Name        string
	ContentType string
	Data        []byte
}

// pdfTimeout bounds one render.
const pdfTimeout = 90 * time.Second

// Download returns a version (0: the current one) of a document as a
// file. Reading is enough. A PDF not made yet is started and answers
// ErrPreparing; the caller asks again.
func (s *Service) Download(ctx context.Context, c Caller, id int64, format string, version int) (File, error) {
	v, err := s.open(ctx, c, id)
	if err != nil {
		return File{}, err
	}
	d := v.Doc
	if version <= 0 {
		version = d.Version
	}
	if version == 0 {
		return File{}, domain.ErrNotFound // nothing written yet
	}
	ver, err := s.d.Store.DocumentVersion(ctx, id, version)
	if err != nil {
		return File{}, err
	}
	return s.file(ctx, d, ver, format, true)
}

// file makes the download of one version. start lets a missing PDF be
// rendered now; the public page never starts one.
func (s *Service) file(ctx context.Context, d domain.Document, ver domain.DocumentVersion, format string, start bool) (File, error) {
	switch format {
	case FormatMarkdown, "":
		return File{Name: domain.DownloadName(ver.Title, d.ID, ver.Version, "md"), ContentType: "text/markdown; charset=utf-8",
			Data: []byte(domain.DocumentFile(d.Kind, ver.Title, ver.Body))}, nil
	case FormatPDF:
	default:
		return File{}, invalid("format is md or pdf")
	}
	if s.d.PDF == nil {
		return File{}, invalid("PDF downloads are not available on this server")
	}
	e, err := s.d.Store.DocumentExport(ctx, d.ID, ver.Version)
	switch {
	case err == nil && e.Status == domain.ExportDone:
		return File{Name: domain.DownloadName(ver.Title, d.ID, ver.Version, "pdf"), ContentType: "application/pdf", Data: e.Data}, nil
	case err == nil && e.Status == domain.ExportFailed && s.now().Sub(e.UpdatedAt) < pdfRetry:
		return File{}, fmt.Errorf("%w: %s", ErrRenderFailed, e.Error)
	case err != nil && !errors.Is(err, domain.ErrNotFound):
		return File{}, err
	}
	if start {
		s.render(ctx, d, ver)
	}
	return File{}, ErrPreparing
}

// prepare renders a version's PDF ahead, unless it is made or being made.
func (s *Service) prepare(ctx context.Context, d domain.Document, version int) {
	if s.d.PDF == nil {
		return
	}
	ver, err := s.d.Store.DocumentVersion(ctx, d.ID, version)
	if err != nil {
		s.d.Log.Warn("prepare PDF", "document", d.ID, "version", version, "err", err)
		return
	}
	s.render(ctx, d, ver)
}

// render makes a version's PDF in the background, once: the store lets
// one caller start it.
func (s *Service) render(ctx context.Context, d domain.Document, ver domain.DocumentVersion) {
	ok, err := s.d.Store.StartDocumentExport(ctx, d.ID, ver.Version, pdfRetry)
	if err != nil || !ok {
		if err != nil {
			s.d.Log.Warn("start PDF", "document", d.ID, "err", err)
		}
		return
	}
	bg := domain.WithWorkspace(context.WithoutCancel(ctx), d.WorkspaceID)
	go func() {
		rctx, cancel := context.WithTimeout(bg, pdfTimeout)
		defer cancel()
		page := PrintHTML(ver.Title, ver.Body, ver.Version, ver.CreatedAt, d.Language)
		if d.Kind == domain.DocKindSlides {
			page = PrintSlidesHTML(ver.Title, ver.Body, d.Language)
		}
		data, err := s.d.PDF.RenderPDF(rctx, page)
		failure := ""
		if err != nil {
			failure = err.Error()
			s.d.Log.Warn("render PDF", "document", d.ID, "version", ver.Version, "err", err)
		} else if !bytes.HasPrefix(data, []byte("%PDF")) {
			failure = "the renderer did not return a PDF"
		}
		if err := s.d.Store.FinishDocumentExport(bg, d.ID, ver.Version, data, failure); err != nil {
			s.d.Log.Error("save PDF", "document", d.ID, "err", err)
		}
	}()
}

// Public is a public document as anyone sees it: no owner, no members,
// no tickets, no versions, and a deck without its speaker notes.
type Public struct {
	Kind      domain.DocumentKind
	Title     string
	Body      string
	Version   int
	UpdatedAt time.Time
}

// PublicDocument returns a guest's public document.
func (s *Service) PublicDocument(g Guest) (Public, error) {
	d := g.Doc
	return Public{Kind: d.Kind, Title: d.Title, Body: publicBody(d), Version: d.Version, UpdatedAt: d.UpdatedAt}, nil
}

// publicBody is the text readers outside the workspace get: a deck's
// speaker notes stay inside.
func publicBody(d domain.Document) string {
	if d.Kind == domain.DocKindSlides {
		return domain.SlidesWithoutNotes(d.Body)
	}
	return d.Body
}

// PublicDownload returns the current version of a guest's public
// document as a file. The PDF is only served when it was rendered ahead;
// a visitor never starts a render.
func (s *Service) PublicDownload(g Guest, format string) (File, error) {
	d := g.Doc
	if d.Version == 0 {
		return File{}, domain.ErrNotFound
	}
	ver := domain.DocumentVersion{DocumentID: d.ID, Version: d.Version, Title: d.Title, Body: publicBody(d)}
	return s.file(g.ctx, d, ver, format, false)
}

var md = goldmark.New(goldmark.WithExtensions(extension.GFM))

// imgTag matches the images goldmark renders; printing keeps only their
// alt text, so a PDF never fetches anything.
var imgTag = regexp.MustCompile(`<img src="[^"]*" alt="([^"]*)"[^>]*>`)

// RenderMarkdown turns Markdown into HTML safe to print: raw HTML and
// dangerous links are dropped (goldmark's defaults), images become their
// alt text.
func RenderMarkdown(src string) string {
	var b bytes.Buffer
	if err := md.Convert([]byte(src), &b); err != nil {
		return "<pre>" + html.EscapeString(src) + "</pre>"
	}
	return imgTag.ReplaceAllString(b.String(), `<span class="img">[$1]</span>`)
}

// PrintHTML is the page a version prints as: A4, title, a version line,
// and the body, in fonts that cover Latin, Cyrillic and Uzbek.
func PrintHTML(title, body string, version int, at time.Time, lang string) []byte {
	if lang == "" {
		lang = "en"
	}
	body = strings.TrimLeft(body, "\n")
	if first, rest, _ := strings.Cut(body, "\n"); strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(first), "# ")) == title && strings.HasPrefix(strings.TrimSpace(first), "# ") {
		body = rest // the title is printed once, above
	}
	var b strings.Builder
	fmt.Fprintf(&b, `<!doctype html>
<html lang="%s"><head><meta charset="utf-8"><title>%s</title>
<style>
@page { size: A4; margin: 18mm 16mm 20mm; }
* { box-sizing: border-box; }
html { font-family: "Noto Sans", "DejaVu Sans", "Liberation Sans", "FreeSans", sans-serif; font-size: 10.5pt; color: #1d1d1f; line-height: 1.5; }
h1.doc-title { font-size: 20pt; margin: 0 0 2pt; }
.doc-meta { color: #6b6b70; font-size: 9pt; margin-bottom: 14pt; padding-bottom: 8pt; border-bottom: 1px solid #ddd; }
h1 { font-size: 16pt; } h2 { font-size: 13.5pt; } h3 { font-size: 11.5pt; }
h1, h2, h3, h4 { break-after: avoid; margin: 14pt 0 6pt; line-height: 1.25; }
p, li { orphans: 3; widows: 3; }
a { color: #1a5fb4; text-decoration: none; word-break: break-word; }
code, pre { font-family: "Noto Sans Mono", "DejaVu Sans Mono", "Liberation Mono", monospace; font-size: 9pt; }
code { background: #f3f3f5; padding: 0 3px; border-radius: 3px; }
pre { background: #f6f6f8; border: 1px solid #e3e3e6; border-radius: 4px; padding: 8px 10px; white-space: pre-wrap; word-break: break-word; overflow-wrap: anywhere; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%%; margin: 8pt 0; font-size: 9.5pt; }
thead { display: table-header-group; }
tr { break-inside: avoid; }
th, td { border: 1px solid #d5d5d8; padding: 4px 6px; text-align: left; vertical-align: top; word-break: break-word; }
th { background: #f3f3f5; }
blockquote { margin: 8pt 0; padding: 2pt 10pt; border-left: 3px solid #d5d5d8; color: #4a4a4f; }
hr { border: none; border-top: 1px solid #ddd; margin: 12pt 0; }
.img { color: #6b6b70; font-style: italic; }
</style></head><body>
<h1 class="doc-title">%s</h1>
<div class="doc-meta">Version %d · %s</div>
`, html.EscapeString(lang), html.EscapeString(title), html.EscapeString(title), version, at.Format("Jan 2, 2006"))
	b.WriteString(RenderMarkdown(body))
	b.WriteString("\n</body></html>\n")
	return []byte(b.String())
}

// PrintSlidesHTML is the page a deck prints as: one 16:9 landscape page
// per slide, the slide's number in its corner, no speaker notes. The meta
// tag tells the print script the page size.
func PrintSlidesHTML(title, body, lang string) []byte {
	if lang == "" {
		lang = "en"
	}
	var b strings.Builder
	fmt.Fprintf(&b, `<!doctype html>
<html lang="%s"><head><meta charset="utf-8"><meta name="agnts-layout" content="slides"><title>%s</title>
<style>
@page { size: 254mm 142.875mm; margin: 0; }
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
html { font-family: "Noto Sans", "DejaVu Sans", "Liberation Sans", "FreeSans", sans-serif; color: #1d1d1f; }
.slide { width: 254mm; height: 142.875mm; padding: 13mm 18mm 14mm; position: relative; overflow: hidden; break-after: page;
  display: flex; flex-direction: column; justify-content: flex-start; font-size: 17pt; line-height: 1.4; background: #fff; }
.slide:last-child { break-after: auto; }
.slide.lead { justify-content: center; text-align: center; }
.slide.dense { font-size: 14pt; }
.slide.denser { font-size: 11.5pt; line-height: 1.32; }
.slide h1 { font-size: 2em; margin: 0 0 .35em; line-height: 1.15; }
.slide h2 { font-size: 1.55em; margin: 0 0 .45em; line-height: 1.2; }
.slide h3 { font-size: 1.2em; margin: .3em 0 .3em; }
.slide.lead h1 { font-size: 2.5em; }
.slide.lead p { color: #4a4a4f; font-size: 1.15em; }
.slide p { margin: 0 0 .5em; }
.slide ul, .slide ol { margin: 0 0 .5em; padding-left: 1.2em; }
.slide li { margin: .15em 0; }
.slide a { color: #1a5fb4; text-decoration: none; }
.slide code, .slide pre { font-family: "Noto Sans Mono", "DejaVu Sans Mono", "Liberation Mono", monospace; font-size: .8em; }
.slide code { background: #f3f3f5; padding: 0 3px; border-radius: 3px; }
.slide pre { background: #f6f6f8; border: 1px solid #e3e3e6; border-radius: 4px; padding: 6px 9px; white-space: pre-wrap; word-break: break-word; }
.slide pre code { background: none; padding: 0; }
.slide table { border-collapse: collapse; font-size: .8em; margin: .3em 0; }
.slide th, .slide td { border: 1px solid #d5d5d8; padding: 3px 7px; text-align: left; vertical-align: top; }
.slide th { background: #f3f3f5; }
.slide blockquote { margin: .3em 0; padding: 0 .8em; border-left: 3px solid #d5d5d8; color: #4a4a4f; }
.slide .img { color: #6b6b70; font-style: italic; }
.slide .no { position: absolute; right: 9mm; bottom: 6mm; font-size: 9pt; color: #8a8a90; }
</style></head><body>
`, html.EscapeString(lang), html.EscapeString(title))
	slides := domain.SplitSlides(body)
	if len(slides) == 0 {
		slides = []domain.Slide{{Body: "# " + title, Layout: domain.SlideLead}}
	}
	for i, sl := range slides {
		fmt.Fprintf(&b, "<section class=\"slide %s\">\n%s<span class=\"no\">%d / %d</span>\n</section>\n", sl.Layout, RenderMarkdown(sl.Body), i+1, len(slides))
	}
	b.WriteString("</body></html>\n")
	return []byte(b.String())
}
