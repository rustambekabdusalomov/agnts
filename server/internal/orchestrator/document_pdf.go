package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	_ "embed"
	"errors"
	"fmt"
	"io"
	"time"
)

// pdfScript prints an HTML file to PDF with the Chromium the runner image
// carries for previews. It blocks every request, so a page cannot fetch
// anything.
//
//go:embed document_pdf.mjs
var pdfScript []byte

// Where a PDF render puts its files in the container.
const (
	pdfDir    = "/agnts/out"
	pdfIn     = pdfDir + "/document.html"
	pdfOut    = pdfDir + "/document.pdf"
	pdfRunner = pdfDir + "/agnts-pdf.mjs"
	pdfNode   = "/opt/claude/node/bin/node"
	// pdfMemoryMB is the container's memory: a headless Chromium printing
	// one page needs far less than a coding run.
	pdfMemoryMB = 1024
)

// ErrNoRoom means the server has no memory for a PDF render now.
var ErrNoRoom = errors.New("the server is busy; try the PDF again in a minute")

// RenderPDF prints an HTML page to an A4 PDF with page numbers, in a
// short-lived container without a repository. It takes its memory from
// the same budget as runs, and gives up rather than wait when there is
// none.
func (o *Orchestrator) RenderPDF(ctx context.Context, html []byte) ([]byte, error) {
	if o.capacity != nil {
		release, ok, why := o.capacity.Reserve(pdfMemoryMB)
		if !ok {
			return nil, fmt.Errorf("%w (%s)", ErrNoRoom, why)
		}
		defer release()
	}
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("pdf-%d", time.Now().UnixNano()), Image: o.cfg.Image, MemoryMB: pdfMemoryMB, Repo: emptyTree()})
	if err != nil {
		return nil, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove PDF container", "err", err)
		}
	}()
	if err := ws.WriteFile(ctx, pdfIn, html); err != nil {
		return nil, fmt.Errorf("copy the page: %w", err)
	}
	if err := ws.WriteFile(ctx, pdfRunner, pdfScript); err != nil {
		return nil, fmt.Errorf("copy the renderer: %w", err)
	}
	r, err := ws.Exec(ctx, fmt.Sprintf("%s %s %s %s", pdfNode, pdfRunner, pdfIn, pdfOut), 60*time.Second)
	if err != nil {
		return nil, fmt.Errorf("render: %w", err)
	}
	if r.ExitCode != 0 {
		return nil, fmt.Errorf("render failed: %s", truncate(r.Output, 500))
	}
	return ws.ReadFile(ctx, pdfOut)
}

// emptyTree is the /workspace of a container that has no repository: an
// empty tar (the runner copies a tree in either way).
func emptyTree() io.Reader {
	var b bytes.Buffer
	_ = tar.NewWriter(&b).Close()
	return &b
}
