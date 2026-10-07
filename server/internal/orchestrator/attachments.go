package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"mime"
	"net/http"
	"path"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// attachmentDir is where runs find the files people attached. It is the
// output folder because it already exists in every run container.
const attachmentDir = "/agnts/out"

// Upload stores a file someone is about to attach. It stays pending until
// creating a task, answering or retrying links it, and is deleted after
// domain.AttachmentPendingTTL otherwise.
func (o *Orchestrator) Upload(ctx context.Context, name string, data []byte) (domain.Attachment, error) {
	if len(data) == 0 {
		return domain.Attachment{}, invalid("the file is empty")
	}
	if len(data) > domain.MaxAttachmentBytes {
		return domain.Attachment{}, invalid("a file can be %d MB at most", domain.MaxAttachmentBytes>>20)
	}
	name = domain.CleanFileName(name)
	return o.store.SaveAttachment(ctx, domain.Attachment{Name: name, ContentType: sniffType(name, data)}, data)
}

// textTypes name common text files the system MIME table may not know.
var textTypes = map[string]string{
	".md": "text/markdown", ".markdown": "text/markdown", ".csv": "text/csv", ".json": "application/json",
	".txt": "text/plain", ".log": "text/plain", ".yaml": "text/plain", ".yml": "text/plain",
}

// sniffType picks the content type of an upload from its bytes, and from
// its extension when the bytes say nothing specific. Only real pictures
// get an image type, since clients show those in place.
func sniffType(name string, data []byte) string {
	sniffed, _, _ := strings.Cut(http.DetectContentType(data), ";")
	if (domain.Attachment{ContentType: sniffed}).Image() || sniffed == "application/pdf" {
		return sniffed
	}
	ext := strings.ToLower(path.Ext(name))
	byExt, ok := textTypes[ext]
	if !ok {
		byExt, _, _ = strings.Cut(mime.TypeByExtension(ext), ";")
	}
	if byExt != "" && !strings.HasPrefix(byExt, "image/") {
		return byExt
	}
	if sniffed == "text/plain" {
		return sniffed
	}
	return "application/octet-stream"
}

// OpenAttachment returns an attachment and its bytes, or domain.ErrNotFound.
func (o *Orchestrator) OpenAttachment(ctx context.Context, id int64) (domain.Attachment, []byte, error) {
	return o.store.AttachmentData(ctx, id)
}

// DeleteUpload deletes an upload that nothing uses yet. Attached files
// stay with the ticket's history.
func (o *Orchestrator) DeleteUpload(ctx context.Context, id int64) error {
	as, err := o.store.Attachments(ctx, []int64{id})
	if err != nil {
		return err
	}
	if len(as) == 0 {
		return domain.ErrNotFound
	}
	if as[0].Purpose != domain.AttachPending {
		return fmt.Errorf("%s is attached to a ticket: %w", as[0].Name, domain.ErrConflict)
	}
	return o.store.DeleteAttachments(ctx, []int64{id})
}

// checkUploads checks that ids are pending uploads, at most
// domain.MaxAttachments, and returns them without repeats.
func (o *Orchestrator) checkUploads(ctx context.Context, ids []int64) ([]int64, error) {
	var out []int64
	for _, id := range ids {
		if !slices.Contains(out, id) {
			out = append(out, id)
		}
	}
	if len(out) == 0 {
		return nil, nil
	}
	if len(out) > domain.MaxAttachments {
		return nil, invalid("attach at most %d files", domain.MaxAttachments)
	}
	as, err := o.store.Attachments(ctx, out)
	if err != nil {
		return nil, err
	}
	for _, id := range out {
		i := slices.IndexFunc(as, func(a domain.Attachment) bool { return a.ID == id })
		if i < 0 || as[i].Purpose != domain.AttachPending {
			return nil, invalid("file %d is not a new upload: upload it again", id)
		}
	}
	return out, nil
}

// setTaskFiles makes ids the files attached to a task's description:
// new uploads are linked, files left out are deleted.
func (o *Orchestrator) setTaskFiles(ctx context.Context, t domain.Ticket, ids []int64) error {
	cur, err := o.store.TicketAttachments(ctx, t.ID)
	if err != nil {
		return err
	}
	var add, drop []int64
	have := map[int64]bool{}
	for _, a := range cur {
		if a.Purpose != domain.AttachTicket {
			continue
		}
		have[a.ID] = true
		if !slices.Contains(ids, a.ID) {
			drop = append(drop, a.ID)
		}
	}
	for _, id := range ids {
		if !have[id] && !slices.Contains(add, id) {
			add = append(add, id)
		}
	}
	if len(have)-len(drop)+len(add) > domain.MaxAttachments {
		return invalid("attach at most %d files", domain.MaxAttachments)
	}
	if add, err = o.checkUploads(ctx, add); err != nil {
		return err
	}
	if err := o.store.LinkAttachments(ctx, add, t.ID, nil, domain.AttachTicket); err != nil {
		return err
	}
	return o.store.DeleteAttachments(ctx, drop)
}

// AttachedFile is an attachment copied into a run's container.
type AttachedFile struct {
	domain.Attachment
	Path string
}

// copyAttachments puts a ticket's attachments into the workspace and
// returns them; one that cannot be copied is skipped with a warning.
func (o *Orchestrator) copyAttachments(ctx context.Context, ws Workspace, t domain.Ticket) []AttachedFile {
	as, err := o.store.TicketAttachments(ctx, t.ID)
	if err != nil {
		o.log.Warn("list attachments", "ticket", t.Key, "err", err)
		return nil
	}
	var out []AttachedFile
	for _, a := range as {
		_, data, err := o.store.AttachmentData(ctx, a.ID)
		if err != nil {
			o.log.Warn("load attachment", "ticket", t.Key, "id", a.ID, "err", err)
			continue
		}
		p := fmt.Sprintf("%s/attachment-%d-%s", attachmentDir, a.ID, strings.ReplaceAll(a.Name, " ", "_"))
		if err := ws.WriteFile(ctx, p, data); err != nil {
			o.log.Warn("copy attachment", "ticket", t.Key, "id", a.ID, "err", err)
			continue
		}
		out = append(out, AttachedFile{Attachment: a, Path: p})
	}
	return out
}

// prunePendingUploads deletes uploads nobody attached.
func (o *Orchestrator) prunePendingUploads(ctx context.Context) {
	n, err := o.store.PrunePendingAttachments(ctx, time.Now().Add(-domain.AttachmentPendingTTL))
	if err != nil && !errors.Is(err, context.Canceled) {
		o.log.Warn("prune uploads", "err", err)
	} else if n > 0 {
		o.log.Info("pruned unused uploads", "count", n)
	}
}
