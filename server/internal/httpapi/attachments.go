package httpapi

import (
	"context"
	"errors"
	"fmt"
	"io"
	"mime"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

// Attachments is the file-upload part of Tickets.
type Attachments interface {
	Upload(ctx context.Context, name string, data []byte) (domain.Attachment, error)
	OpenAttachment(ctx context.Context, id int64) (domain.Attachment, []byte, error)
	DeleteUpload(ctx context.Context, id int64) error
}

// maxUploadBytes is the request size limit for uploads: one file and the
// multipart framing around it.
const maxUploadBytes = domain.MaxAttachmentBytes + 64<<10

// downloadTypes keep their content type on download; the rest go out as
// bytes. None of them run scripts.
var downloadTypes = map[string]bool{
	"application/pdf": true, "text/plain": true, "text/markdown": true, "text/csv": true, "application/json": true,
}

// UploadAttachment implements gen.ServerInterface.
func (s *Server) UploadAttachment(w http.ResponseWriter, r *http.Request) {
	f, hdr, err := r.FormFile("file")
	if err != nil {
		var tooBig *http.MaxBytesError
		if errors.As(err, &tooBig) {
			writeError(w, http.StatusRequestEntityTooLarge, "too_large", fmt.Sprintf("a file can be %d MB at most", domain.MaxAttachmentBytes>>20))
			return
		}
		writeError(w, http.StatusBadRequest, "bad_request", "send the file as multipart/form-data in the field \"file\"")
		return
	}
	defer func() { _ = f.Close() }()
	data, err := io.ReadAll(io.LimitReader(f, domain.MaxAttachmentBytes+1))
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "could not read the file")
		return
	}
	if len(data) > domain.MaxAttachmentBytes {
		writeError(w, http.StatusRequestEntityTooLarge, "too_large", fmt.Sprintf("a file can be %d MB at most", domain.MaxAttachmentBytes>>20))
		return
	}
	a, err := s.opt.Tickets.Upload(r.Context(), hdr.Filename, data)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toAttachment(a))
}

// GetAttachment implements gen.ServerInterface. An attachment never
// changes, so the browser may keep it. Only pictures are shown in place;
// everything else downloads, so an uploaded page cannot run in agnts.
func (s *Server) GetAttachment(w http.ResponseWriter, r *http.Request, id int64) {
	a, data, err := s.opt.Tickets.OpenAttachment(r.Context(), id)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no such file")
			return
		}
		s.writeInternal(w, r, err)
		return
	}
	disposition, ctype := "attachment", "application/octet-stream"
	if a.Image() {
		disposition, ctype = "inline", a.ContentType
	} else if downloadTypes[a.ContentType] {
		ctype = a.ContentType // still downloaded, but opens in the right app
	}
	w.Header().Set("Content-Type", ctype)
	w.Header().Set("Content-Disposition", mime.FormatMediaType(disposition, map[string]string{"filename": a.Name}))
	w.Header().Set("Content-Security-Policy", "default-src 'none'; sandbox")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("Cache-Control", "private, max-age=31536000, immutable")
	if _, err := w.Write(data); err != nil {
		s.opt.Log.Debug("send attachment", "err", err)
	}
}

// DeleteAttachment implements gen.ServerInterface.
func (s *Server) DeleteAttachment(w http.ResponseWriter, r *http.Request, id int64) {
	if err := s.opt.Tickets.DeleteUpload(r.Context(), id); err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no such file")
			return
		}
		s.writeUseCaseError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func toAttachment(a domain.Attachment) gen.Attachment {
	img := a.Image()
	return gen.Attachment{
		Id: a.ID, Name: a.Name, ContentType: a.ContentType, Size: a.Size, Purpose: gen.AttachmentPurpose(a.Purpose),
		QuestionId: a.QuestionID, Image: &img, Url: fmt.Sprintf("/attachments/%d", a.ID), CreatedAt: a.CreatedAt,
	}
}

// ids reads an optional list of attachment ids from a request.
func ids(p *[]int64) []int64 {
	if p == nil {
		return nil
	}
	return *p
}

func toAttachedFiles(fs []domain.FileRef) []gen.AttachedFile {
	out := make([]gen.AttachedFile, len(fs))
	for i, f := range fs {
		out[i] = gen.AttachedFile{Id: f.ID, Name: f.Name, ContentType: f.ContentType, Size: f.Size, Image: f.Image, Url: f.URL}
	}
	return out
}
