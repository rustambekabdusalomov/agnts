package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Documents stores the documents of workspaces: their versions, who may
// open them, the tickets they are linked to, their generations and their
// PDFs.
type Documents struct{ db *pgxpool.Pool }

// NewDocuments returns the document store.
func NewDocuments(db *pgxpool.Pool) *Documents { return &Documents{db: db} }

const docCols = `d.id, d.workspace_id, d.title, d.body, d.version, d.type, COALESCE(d.public_token, ''), d.workspace_access,
	d.owner_id, COALESCE(NULLIF(u.display_name, ''), u.username), d.language, d.source, d.data_as_of, d.deleted_at,
	d.created_at, d.updated_at, d.kind, d.derived_from_id, d.derived_from_version,
	(SELECT count(*) FROM document_tickets dt WHERE dt.document_id = d.id),
	r.id, r.status, r.source, r.prompt_version, r.error, r.requested_by, r.started_at, r.finished_at, r.created_at`

// docFrom joins the owner and the latest generation.
const docFrom = ` FROM documents d JOIN users u ON u.id = d.owner_id
	LEFT JOIN LATERAL (SELECT * FROM document_runs x WHERE x.document_id = d.id ORDER BY x.created_at DESC, x.id DESC LIMIT 1) r ON true`

func scanDocument(row pgx.Row, extra ...any) (domain.Document, error) {
	var d domain.Document
	var typ, access, kind string
	var source []byte
	var runID *int64
	var runStatus, runPrompt, runError *string
	var runSource []byte
	var runBy *int64
	var runStarted, runFinished, runCreated *time.Time
	dest := []any{&d.ID, &d.WorkspaceID, &d.Title, &d.Body, &d.Version, &typ, &d.PublicToken, &access,
		&d.OwnerID, &d.OwnerName, &d.Language, &source, &d.DataAsOf, &d.DeletedAt, &d.CreatedAt, &d.UpdatedAt,
		&kind, &d.DerivedFromID, &d.DerivedFromVersion, &d.TicketCount,
		&runID, &runStatus, &runSource, &runPrompt, &runError, &runBy, &runStarted, &runFinished, &runCreated}
	if err := row.Scan(append(dest, extra...)...); err != nil {
		return d, notFound(err)
	}
	d.Type, d.Kind = domain.DocumentType(typ), domain.DocumentKind(kind)
	d.WorkspaceAccess, _ = domain.ParseAccessLevel(access)
	if len(source) > 0 {
		var s domain.DocumentSource
		if json.Unmarshal(source, &s) == nil {
			d.Source = &s
		}
	}
	if runID != nil {
		r := &domain.DocumentRun{ID: *runID, WorkspaceID: d.WorkspaceID, DocumentID: d.ID, Status: domain.DocRunStatus(*runStatus),
			PromptVersion: *runPrompt, Error: *runError, RequestedBy: runBy, StartedAt: runStarted, FinishedAt: runFinished, CreatedAt: *runCreated}
		_ = json.Unmarshal(runSource, &r.Source)
		d.Run = r
	}
	return d, nil
}

func sourceJSON(s *domain.DocumentSource) []byte {
	if s == nil {
		return nil
	}
	b, _ := json.Marshal(s)
	return b
}

// CreateDocument inserts a document and, when first is not nil, its
// first version (the document's version is then 1). A document made by
// a generation starts at version 0 and gets version 1 from it.
func (s *Documents) CreateDocument(ctx context.Context, d domain.Document, first *domain.DocumentVersion) (domain.Document, error) {
	var id int64
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		version, body := 0, ""
		if first != nil {
			version, body = 1, first.Body
		}
		kind := d.Kind
		if !kind.Valid() {
			kind = domain.DocKindPage
		}
		if err := tx.QueryRow(ctx, `INSERT INTO documents (kind, title, body, version, type, workspace_access, owner_id, language, source, derived_from_id)
			VALUES ($1, $2, $3, $4, 'private', $5, $6, $7, $8, $9) RETURNING id`,
			string(kind), d.Title, body, version, d.WorkspaceAccess.String(), d.OwnerID, d.Language, sourceJSON(d.Source), d.DerivedFromID).Scan(&id); err != nil {
			return err
		}
		if first == nil {
			return nil
		}
		_, err := tx.Exec(ctx, `INSERT INTO document_versions (document_id, version, title, body, source, note, author_id)
			VALUES ($1, 1, $2, $3, $4, $5, $6)`, id, d.Title, first.Body, string(first.Source), first.Note, first.AuthorID)
		return err
	})
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, id)
}

// Document returns a document, deleted or not, or domain.ErrNotFound.
func (s *Documents) Document(ctx context.Context, id int64) (domain.Document, error) {
	return scanDocument(s.db.QueryRow(ctx, `SELECT `+docCols+docFrom+` WHERE d.id = $1`, id))
}

// DocumentGrant returns a person's own grant on a document, AccessNone
// without one.
func (s *Documents) DocumentGrant(ctx context.Context, docID, userID int64) (domain.AccessLevel, error) {
	var level string
	err := s.db.QueryRow(ctx, `SELECT level FROM document_access WHERE document_id = $1 AND user_id = $2`, docID, userID).Scan(&level)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.AccessNone, nil
	}
	l, _ := domain.ParseAccessLevel(level)
	return l, err
}

// DocumentFilter narrows a list of documents.
type DocumentFilter struct {
	// Scope: "mine" (owned), "shared" (others' that the person can open),
	// "deleted" (in the trash, owned, or all for the workspace owner), or
	// "" for everything the person can open.
	Scope     string
	Query     string // in the title, ignoring case
	TicketKey string // linked to this ticket
	// Kind keeps only pages or only decks; "" keeps both.
	Kind domain.DocumentKind
	// DerivedFrom keeps the decks made from this page.
	DerivedFrom int64
	Limit       int
}

// visibleTo is the SQL test for the documents a person can open, with
// $1 the person and $2 their workspace role; it matches EffectiveAccess
// returning more than AccessNone.
const visibleTo = `($2 = 'owner' OR d.owner_id = $1 OR d.workspace_access <> 'none' OR g.level IS NOT NULL)`

// ListDocuments returns the documents a person can open, newest change
// first, each with the person's own grant (AccessNone without one).
func (s *Documents) ListDocuments(ctx context.Context, userID int64, role domain.WorkspaceRole, f DocumentFilter) ([]domain.Document, []domain.AccessLevel, error) {
	where := []string{visibleTo}
	args := []any{userID, string(role)}
	switch f.Scope {
	case "mine":
		where = append(where, "d.owner_id = $1")
	case "shared":
		where = append(where, "d.owner_id <> $1")
	case "deleted":
		where = []string{"($2 = 'owner' OR d.owner_id = $1)"}
	}
	if f.Scope == "deleted" {
		where = append(where, "d.deleted_at IS NOT NULL")
	} else {
		where = append(where, "d.deleted_at IS NULL")
	}
	if q := strings.TrimSpace(f.Query); q != "" {
		args = append(args, "%"+strings.NewReplacer(`\`, `\\`, "%", `\%`, "_", `\_`).Replace(q)+"%")
		where = append(where, fmt.Sprintf("d.title ILIKE $%d", len(args)))
	}
	if f.TicketKey != "" {
		args = append(args, f.TicketKey)
		where = append(where, fmt.Sprintf(`EXISTS (SELECT 1 FROM document_tickets dt JOIN tickets t ON t.id = dt.ticket_id
			WHERE dt.document_id = d.id AND t.key = $%d)`, len(args)))
	}
	if f.Kind != "" {
		args = append(args, string(f.Kind))
		where = append(where, fmt.Sprintf("d.kind = $%d", len(args)))
	}
	if f.DerivedFrom > 0 {
		args = append(args, f.DerivedFrom)
		where = append(where, fmt.Sprintf("d.derived_from_id = $%d", len(args)))
	}
	limit := f.Limit
	if limit <= 0 || limit > 500 {
		limit = 500
	}
	rows, err := s.db.Query(ctx, `SELECT `+docCols+`, COALESCE(g.level, 'none')`+docFrom+`
		LEFT JOIN document_access g ON g.document_id = d.id AND g.user_id = $1
		WHERE `+strings.Join(where, " AND ")+fmt.Sprintf(` ORDER BY d.updated_at DESC, d.id DESC LIMIT %d`, limit), args...)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()
	docs := []domain.Document{}
	var grants []domain.AccessLevel
	for rows.Next() {
		var level string
		d, err := scanDocument(rows, &level)
		if err != nil {
			return nil, nil, err
		}
		l, _ := domain.ParseAccessLevel(level)
		docs = append(docs, d)
		grants = append(grants, l)
	}
	return docs, grants, rows.Err()
}

// SaveDocumentVersion adds a version and makes it the current one. base
// is the version the edit started from: when someone saved in between it
// returns domain.ErrConflict and the document as it is now. A negative
// base skips the check (restores and generations build on whatever is
// current).
func (s *Documents) SaveDocumentVersion(ctx context.Context, docID int64, base int, v domain.DocumentVersion) (domain.Document, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var cur int
		var deleted *time.Time
		if err := tx.QueryRow(ctx, `SELECT version, deleted_at FROM documents WHERE id = $1 FOR UPDATE`, docID).Scan(&cur, &deleted); err != nil {
			return notFound(err)
		}
		if deleted != nil {
			return domain.ErrNotFound
		}
		if base >= 0 && base != cur {
			return domain.ErrConflict
		}
		return insertVersion(ctx, tx, docID, cur+1, v)
	})
	d, gerr := s.Document(ctx, docID)
	if err != nil {
		return d, err
	}
	return d, gerr
}

func insertVersion(ctx context.Context, tx pgx.Tx, docID int64, version int, v domain.DocumentVersion) error {
	if _, err := tx.Exec(ctx, `INSERT INTO document_versions (document_id, version, title, body, source, note, author_id, run_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`, docID, version, v.Title, v.Body, string(v.Source), v.Note, v.AuthorID, v.RunID); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `UPDATE documents SET title = $2, body = $3, version = $4, updated_at = now() WHERE id = $1`,
		docID, v.Title, v.Body, version)
	return err
}

// RenameDocument changes the title without a new version (while a
// generation writes the body).
func (s *Documents) RenameDocument(ctx context.Context, docID int64, title string) (domain.Document, error) {
	tag, err := s.db.Exec(ctx, `UPDATE documents SET title = $2, updated_at = now() WHERE id = $1 AND deleted_at IS NULL`, docID, title)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.Document{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, docID)
}

const versionCols = `v.document_id, v.version, v.title, v.body, v.source, v.note, v.author_id,
	COALESCE(NULLIF(u.display_name, ''), u.username, ''), v.run_id, v.created_at`

func scanVersion(row pgx.Row) (domain.DocumentVersion, error) {
	var v domain.DocumentVersion
	var src string
	err := row.Scan(&v.DocumentID, &v.Version, &v.Title, &v.Body, &src, &v.Note, &v.AuthorID, &v.AuthorName, &v.RunID, &v.CreatedAt)
	v.Source = domain.VersionSource(src)
	return v, notFound(err)
}

// DocumentVersions returns a document's versions, newest first, without
// their bodies.
func (s *Documents) DocumentVersions(ctx context.Context, docID int64) ([]domain.DocumentVersion, error) {
	rows, err := s.db.Query(ctx, `SELECT v.document_id, v.version, v.title, '', v.source, v.note, v.author_id,
			COALESCE(NULLIF(u.display_name, ''), u.username, ''), v.run_id, v.created_at
		FROM document_versions v LEFT JOIN users u ON u.id = v.author_id
		WHERE v.document_id = $1 ORDER BY v.version DESC`, docID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.DocumentVersion{}
	for rows.Next() {
		v, err := scanVersion(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, v)
	}
	return out, rows.Err()
}

// DocumentVersion returns one version with its body.
func (s *Documents) DocumentVersion(ctx context.Context, docID int64, version int) (domain.DocumentVersion, error) {
	return scanVersion(s.db.QueryRow(ctx, `SELECT `+versionCols+` FROM document_versions v LEFT JOIN users u ON u.id = v.author_id
		WHERE v.document_id = $1 AND v.version = $2`, docID, version))
}

// Sharing is who can open a document besides its owner.
type Sharing struct {
	Type            domain.DocumentType
	PublicToken     string // the new token when it goes public or is reset; "" keeps the current one
	WorkspaceAccess domain.AccessLevel
	Grants          []domain.DocumentGrant // the full list; members not in it lose their grant
}

// SetDocumentSharing replaces a document's type, workspace default and
// grants. Grants are only kept for members of the workspace.
func (s *Documents) SetDocumentSharing(ctx context.Context, docID int64, sh Sharing, by int64) (domain.Document, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var ws int64
		if err := tx.QueryRow(ctx, `SELECT workspace_id FROM documents WHERE id = $1 AND deleted_at IS NULL FOR UPDATE`, docID).Scan(&ws); err != nil {
			return notFound(err)
		}
		var token *string
		switch {
		case sh.Type == domain.DocPrivate:
		case sh.PublicToken != "":
			token = &sh.PublicToken
		default:
			if err := tx.QueryRow(ctx, `SELECT public_token FROM documents WHERE id = $1`, docID).Scan(&token); err != nil {
				return err
			}
			if token == nil {
				return errors.New("a document going public needs a new token")
			}
		}
		if _, err := tx.Exec(ctx, `UPDATE documents SET type = $2, public_token = $3, workspace_access = $4, updated_at = now() WHERE id = $1`,
			docID, string(sh.Type), token, sh.WorkspaceAccess.String()); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `DELETE FROM document_access WHERE document_id = $1`, docID); err != nil {
			return err
		}
		for _, g := range sh.Grants {
			if _, err := tx.Exec(ctx, `INSERT INTO document_access (document_id, user_id, level, granted_by)
				SELECT $1, $2, $3, $4 WHERE EXISTS (SELECT 1 FROM memberships WHERE workspace_id = $5 AND user_id = $2)
				ON CONFLICT (document_id, user_id) DO UPDATE SET level = EXCLUDED.level`,
				docID, g.UserID, g.Level.String(), by, ws); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, docID)
}

// DocumentGrants returns who a document is shared with.
func (s *Documents) DocumentGrants(ctx context.Context, docID int64) ([]domain.DocumentGrant, error) {
	rows, err := s.db.Query(ctx, `SELECT g.user_id, COALESCE(NULLIF(u.display_name, ''), u.username), g.level, g.granted_by, g.created_at
		FROM document_access g JOIN users u ON u.id = g.user_id WHERE g.document_id = $1 ORDER BY g.created_at, g.user_id`, docID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.DocumentGrant{}
	for rows.Next() {
		var g domain.DocumentGrant
		var level string
		if err := rows.Scan(&g.UserID, &g.Username, &level, &g.GrantedBy, &g.CreatedAt); err != nil {
			return nil, err
		}
		g.Level, _ = domain.ParseAccessLevel(level)
		out = append(out, g)
	}
	return out, rows.Err()
}

// SetDocumentOwner gives a document to another member. The new owner's
// own grant goes (they have more now); the old owner keeps edit access.
func (s *Documents) SetDocumentOwner(ctx context.Context, docID, to int64) (domain.Document, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var ws, from int64
		if err := tx.QueryRow(ctx, `SELECT workspace_id, owner_id FROM documents WHERE id = $1 AND deleted_at IS NULL FOR UPDATE`, docID).Scan(&ws, &from); err != nil {
			return notFound(err)
		}
		if from == to {
			return nil
		}
		var member bool
		if err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM memberships WHERE workspace_id = $1 AND user_id = $2)`, ws, to).Scan(&member); err != nil {
			return err
		}
		if !member {
			return domain.ErrNotFound
		}
		if _, err := tx.Exec(ctx, `UPDATE documents SET owner_id = $2, updated_at = now() WHERE id = $1`, docID, to); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `DELETE FROM document_access WHERE document_id = $1 AND user_id = $2`, docID, to); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `INSERT INTO document_access (document_id, user_id, level, granted_by) VALUES ($1, $2, 'edit', $2)
			ON CONFLICT (document_id, user_id) DO NOTHING`, docID, from)
		return err
	})
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, docID)
}

// DeleteDocument moves a document to the trash: its public link stops
// working and it is hidden everywhere until restored or purged.
func (s *Documents) DeleteDocument(ctx context.Context, docID int64) error {
	tag, err := s.db.Exec(ctx, `UPDATE documents SET deleted_at = now(), updated_at = now() WHERE id = $1 AND deleted_at IS NULL`, docID)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// RestoreDocument takes a document out of the trash.
func (s *Documents) RestoreDocument(ctx context.Context, docID int64) (domain.Document, error) {
	tag, err := s.db.Exec(ctx, `UPDATE documents SET deleted_at = NULL, updated_at = now() WHERE id = $1 AND deleted_at IS NOT NULL`, docID)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.Document{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, docID)
}

// PurgeDocuments removes for good the documents in the trash since
// before; it returns how many went.
func (s *Documents) PurgeDocuments(ctx context.Context, before time.Time) (int64, error) {
	tag, err := s.db.Exec(ctx, `DELETE FROM documents WHERE deleted_at IS NOT NULL AND deleted_at < $1`, before)
	return tag.RowsAffected(), err
}

// LinkDocumentTicket links a ticket to a document; linking twice is not
// an error. by is nil when agnts links it.
func (s *Documents) LinkDocumentTicket(ctx context.Context, docID, ticketID int64, by *int64) error {
	_, err := s.db.Exec(ctx, `INSERT INTO document_tickets (document_id, ticket_id, linked_by) VALUES ($1, $2, $3)
		ON CONFLICT (document_id, ticket_id) DO NOTHING`, docID, ticketID, by)
	return err
}

// UnlinkDocumentTicket removes a link; a missing link is domain.ErrNotFound.
func (s *Documents) UnlinkDocumentTicket(ctx context.Context, docID, ticketID int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM document_tickets WHERE document_id = $1 AND ticket_id = $2`, docID, ticketID)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// DocumentTickets returns the tickets linked to a document.
func (s *Documents) DocumentTickets(ctx context.Context, docID int64) ([]domain.DocumentTicket, error) {
	rows, err := s.db.Query(ctx, `SELECT dt.document_id, t.id, t.key, t.ticket_number, t.title, t.state, t.kind, dt.linked_by, dt.created_at
		FROM document_tickets dt JOIN tickets t ON t.id = dt.ticket_id WHERE dt.document_id = $1 ORDER BY dt.created_at, t.id`, docID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.DocumentTicket{}
	for rows.Next() {
		var l domain.DocumentTicket
		var state, kind string
		if err := rows.Scan(&l.DocumentID, &l.TicketID, &l.Key, &l.Number, &l.Title, &state, &kind, &l.LinkedBy, &l.CreatedAt); err != nil {
			return nil, err
		}
		l.State, l.Kind = domain.TicketState(state), domain.TicketKind(kind)
		out = append(out, l)
	}
	return out, rows.Err()
}

// HandOverDocuments moves the documents userID owns in workspace ws to
// the workspace's owner and drops userID's grants there, in tx (the
// transaction that takes them out of the workspace). It records an event
// when anything moved.
func handOverDocuments(ctx context.Context, tx pgx.Tx, ws, userID int64) error {
	var owner *int64
	if err := tx.QueryRow(ctx, `SELECT owner_id FROM workspaces WHERE id = $1`, ws).Scan(&owner); err != nil {
		return notFound(err)
	}
	if _, err := tx.Exec(ctx, `DELETE FROM document_access WHERE workspace_id = $1 AND user_id = $2`, ws, userID); err != nil {
		return err
	}
	if owner == nil || *owner == userID {
		return nil // the owner never leaves; a workspace without one keeps its documents as they are
	}
	tag, err := tx.Exec(ctx, `UPDATE documents SET owner_id = $3, updated_at = now() WHERE workspace_id = $1 AND owner_id = $2`, ws, userID, *owner)
	if err != nil {
		return err
	}
	if n := tag.RowsAffected(); n > 0 {
		// The former owner's own grant on what they now own goes too.
		if _, err := tx.Exec(ctx, `DELETE FROM document_access a USING documents d
			WHERE a.document_id = d.id AND d.workspace_id = $1 AND a.user_id = d.owner_id`, ws); err != nil {
			return err
		}
		return insertEvent(ctx, tx, domain.Event{WorkspaceID: ws, Type: domain.EventDocuments, Origin: domain.OriginSystem,
			Message: fmt.Sprintf("%d %s of a member who left moved to the workspace owner", n, plural(n, "document", "documents"))})
	}
	return nil
}

func plural(n int64, one, many string) string {
	if n == 1 {
		return one
	}
	return many
}

// CreateDocumentRun queues a generation and makes its source the
// document's.
func (s *Documents) CreateDocumentRun(ctx context.Context, docID int64, src domain.DocumentSource, by *int64, promptVersion string) (domain.DocumentRun, error) {
	var r domain.DocumentRun
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var busy bool
		if err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM document_runs WHERE document_id = $1 AND status IN ('queued', 'writing'))
			FROM documents WHERE id = $1 AND deleted_at IS NULL FOR UPDATE`, docID).Scan(&busy); err != nil {
			return notFound(err)
		}
		if busy {
			return domain.ErrConflict
		}
		b := sourceJSON(&src)
		if _, err := tx.Exec(ctx, `UPDATE documents SET source = $2, updated_at = now() WHERE id = $1`, docID, b); err != nil {
			return err
		}
		return tx.QueryRow(ctx, `INSERT INTO document_runs (document_id, requested_by, source, prompt_version) VALUES ($1, $2, $3, $4)
			RETURNING id, workspace_id, status, created_at`, docID, by, b, promptVersion).Scan(&r.ID, &r.WorkspaceID, &r.Status, &r.CreatedAt)
	})
	r.DocumentID, r.Source, r.RequestedBy, r.PromptVersion = docID, src, by, promptVersion
	return r, err
}

const docRunCols = `id, workspace_id, document_id, requested_by, status, source, prompt_version, error, started_at, finished_at, created_at`

func scanDocRun(row pgx.Row) (domain.DocumentRun, error) {
	var r domain.DocumentRun
	var status string
	var src []byte
	err := row.Scan(&r.ID, &r.WorkspaceID, &r.DocumentID, &r.RequestedBy, &status, &src, &r.PromptVersion, &r.Error, &r.StartedAt, &r.FinishedAt, &r.CreatedAt)
	if err != nil {
		return r, notFound(err)
	}
	r.Status = domain.DocRunStatus(status)
	_ = json.Unmarshal(src, &r.Source)
	return r, nil
}

// DocumentRun returns one generation.
func (s *Documents) DocumentRun(ctx context.Context, id int64) (domain.DocumentRun, error) {
	return scanDocRun(s.db.QueryRow(ctx, `SELECT `+docRunCols+` FROM document_runs WHERE id = $1`, id))
}

// PendingDocumentWorkspaces returns the workspaces with generations
// waiting, with the person who asked for the oldest one (whose Claude
// account it may use).
func (s *Documents) PendingDocumentWorkspaces(ctx context.Context) ([]domain.PendingDocument, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT ON (workspace_id) workspace_id, requested_by, created_at FROM document_runs
		WHERE status = 'queued' ORDER BY workspace_id, created_at, id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.PendingDocument
	for rows.Next() {
		var p domain.PendingDocument
		if err := rows.Scan(&p.WorkspaceID, &p.RequestedBy, &p.Since); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// ClaimDocumentRun moves the oldest queued generation of the workspace
// ctx acts in to writing; ok is false when none is waiting.
func (s *Documents) ClaimDocumentRun(ctx context.Context) (domain.DocumentRun, bool, error) {
	r, err := scanDocRun(s.db.QueryRow(ctx, `UPDATE document_runs SET status = 'writing', started_at = now()
		WHERE id = (SELECT id FROM document_runs WHERE status = 'queued' ORDER BY created_at, id LIMIT 1 FOR UPDATE SKIP LOCKED)
		RETURNING `+docRunCols))
	if errors.Is(err, domain.ErrNotFound) {
		return r, false, nil
	}
	return r, err == nil, err
}

// RecoverDocumentRuns requeues generations a crash left writing.
func (s *Documents) RecoverDocumentRuns(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE document_runs SET status = 'queued', started_at = NULL WHERE status = 'writing'`)
	return int(tag.RowsAffected()), err
}

// SetDocumentRunAccount records the Claude account a generation runs on.
func (s *Documents) SetDocumentRunAccount(ctx context.Context, runID int64, conn *int64, credits bool) error {
	_, err := s.db.Exec(ctx, `UPDATE document_runs SET claude_connection_id = $2, on_credits = $3 WHERE id = $1`, runID, conn, credits)
	return err
}

// FinishDocumentRun records how a generation ended and, when it wrote a
// version, saves it and links the tickets it was about, in one
// transaction.
func (s *Documents) FinishDocumentRun(ctx context.Context, runID int64, res domain.DocRunResult) (domain.Document, error) {
	var docID int64
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := tx.QueryRow(ctx, `SELECT document_id FROM document_runs WHERE id = $1 FOR UPDATE`, runID).Scan(&docID); err != nil {
			return notFound(err)
		}
		finished := "now()"
		if res.Status == domain.DocRunQueued {
			finished = "NULL"
		}
		if _, err := tx.Exec(ctx, `UPDATE document_runs SET status = $2, error = $3, finished_at = `+finished+`,
			started_at = CASE WHEN $2 = 'queued' THEN NULL ELSE started_at END WHERE id = $1`,
			runID, string(res.Status), res.Error); err != nil {
			return err
		}
		if err := finishMeetingNotes(ctx, tx, runID, docID, res); err != nil {
			return err
		}
		if res.Version == nil {
			return nil
		}
		var cur int
		var deleted *time.Time
		if err := tx.QueryRow(ctx, `SELECT version, deleted_at FROM documents WHERE id = $1 FOR UPDATE`, docID).Scan(&cur, &deleted); err != nil {
			return notFound(err)
		}
		v := *res.Version
		v.RunID = &runID
		if err := insertVersion(ctx, tx, docID, cur+1, v); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `UPDATE documents SET data_as_of = $2 WHERE id = $1`, docID, res.DataAsOf); err != nil {
			return err
		}
		if res.FromVersion > 0 {
			// A deck made from a page: the page and the version it read.
			if _, err := tx.Exec(ctx, `UPDATE documents d SET derived_from_id = (r.source->>'documentId')::bigint, derived_from_version = $3
				FROM document_runs r WHERE d.id = $1 AND r.id = $2
				  AND EXISTS (SELECT 1 FROM documents p WHERE p.id = (r.source->>'documentId')::bigint)`, docID, runID, res.FromVersion); err != nil {
				return err
			}
		}
		for _, t := range res.Tickets {
			if _, err := tx.Exec(ctx, `INSERT INTO document_tickets (document_id, ticket_id) VALUES ($1, $2)
				ON CONFLICT (document_id, ticket_id) DO NOTHING`, docID, t); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return domain.Document{}, err
	}
	return s.Document(ctx, docID)
}

// finishMeetingNotes moves a meeting session's notes on when a
// generation of its notes ends: done with the action items it wrote
// (keeping the ones that have tickets), or failed with the reason.
func finishMeetingNotes(ctx context.Context, tx pgx.Tx, runID, docID int64, res domain.DocRunResult) error {
	var kind string
	var sessionID int64
	err := tx.QueryRow(ctx, `SELECT COALESCE(source->>'kind', ''), COALESCE((source->>'sessionId')::bigint, 0) FROM document_runs WHERE id = $1`, runID).
		Scan(&kind, &sessionID)
	if err != nil || kind != string(domain.SourceMeeting) || sessionID == 0 {
		return err
	}
	switch res.Status {
	case domain.DocRunFailed:
		_, err = tx.Exec(ctx, `UPDATE meeting_sessions SET notes_status = 'failed', notes_error = $2 WHERE id = $1`, sessionID, res.Error)
		return err
	case domain.DocRunDone:
	default:
		return nil
	}
	if _, err := tx.Exec(ctx, `UPDATE meeting_sessions SET notes_status = 'done', notes_error = '', document_id = $2 WHERE id = $1`, sessionID, docID); err != nil {
		return err
	}
	if res.ActionItems == nil {
		return nil
	}
	rows, err := tx.Query(ctx, `SELECT text, who, quote, at_ms FROM meeting_action_items WHERE session_id = $1 AND ticket_id IS NOT NULL`, sessionID)
	if err != nil {
		return err
	}
	kept, err := pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.ActionItem, error) {
		var a domain.ActionItem
		err := r.Scan(&a.Text, &a.Who, &a.Quote, &a.AtMS)
		return a, err
	})
	if err != nil {
		return err
	}
	if _, err := tx.Exec(ctx, `DELETE FROM meeting_action_items WHERE session_id = $1 AND ticket_id IS NULL`, sessionID); err != nil {
		return err
	}
	pos := len(kept)
	for _, it := range res.ActionItems {
		if slices.ContainsFunc(kept, func(k domain.ActionItem) bool { return domain.SameActionItem(k, it) }) {
			continue
		}
		if _, err := tx.Exec(ctx, `INSERT INTO meeting_action_items (workspace_id, session_id, position, text, who, due, at_ms, quote, speaker)
			SELECT workspace_id, id, $2, $3, $4, $5, $6, $7, $8 FROM meeting_sessions WHERE id = $1`,
			sessionID, pos, it.Text, it.Who, it.Due, it.AtMS, it.Quote, it.Speaker); err != nil {
			return err
		}
		pos++
	}
	return nil
}

// DocumentRunCostUSD is the API cost of a generation's calls on credits.
func (s *Documents) DocumentRunCostUSD(ctx context.Context, runID int64) (float64, error) {
	var usd float64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(cost_usd), 0)::float8 FROM claude_calls WHERE document_run_id = $1 AND on_credits`, runID).Scan(&usd)
	return usd, err
}

// RecordDocumentCall stores the token spend of a generation's Claude
// invocation. It has no ticket.
func (s *Documents) RecordDocumentCall(ctx context.Context, runID int64, c domain.ClaudeCall) error {
	u := c.Usage
	var transcript *int64
	if c.TranscriptID > 0 {
		transcript = &c.TranscriptID
	}
	_, err := s.db.Exec(ctx, `INSERT INTO claude_calls (document_run_id, model_stage, model,
			input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, cost_usd, turns, duration_ms, partial, transcript_id,
			provider, connection_id, on_credits)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
		runID, c.ModelStage, c.Model, u.Input, u.Output, u.CacheRead, u.CacheWrite, u.CostUSD,
		c.Turns, c.Duration.Milliseconds(), c.Partial, transcript, callProvider(c), nullID(c.ConnectionID), c.OnCredits)
	return err
}

// PublicDocument returns the current version of the public document with
// token, for anyone: only its kind, title, body, version and last update. It is
// domain.ErrNotFound when the token is unknown, the document is private
// or deleted, or its workspace turned public documents off. ctx must be
// system work.
func (s *Documents) PublicDocument(ctx context.Context, token string) (domain.Document, error) {
	var d domain.Document
	var kind string
	err := s.db.QueryRow(ctx, `SELECT d.id, d.workspace_id, d.kind, d.title, d.body, d.version, d.updated_at
		FROM documents d JOIN workspaces w ON w.id = d.workspace_id
		WHERE d.public_token = $1 AND d.type = 'public' AND d.deleted_at IS NULL
		  AND w.deleted_at IS NULL AND w.suspended_at IS NULL
		  AND COALESCE((SELECT (s.value->>'publicDocuments')::boolean FROM settings s
		                WHERE s.workspace_id = d.workspace_id AND s.key = $2), true)`, token, settingsKey).
		Scan(&d.ID, &d.WorkspaceID, &kind, &d.Title, &d.Body, &d.Version, &d.UpdatedAt)
	d.Type, d.PublicToken, d.Kind = domain.DocPublic, token, domain.DocumentKind(kind)
	return d, notFound(err)
}

// DocumentExport returns the PDF of a version in lang ("": as written), or
// domain.ErrNotFound when none was asked for.
func (s *Documents) DocumentExport(ctx context.Context, docID int64, version int, lang string) (domain.DocumentExport, error) {
	var e domain.DocumentExport
	var status string
	err := s.db.QueryRow(ctx, `SELECT document_id, version, status, COALESCE(data, ''::bytea), error, updated_at FROM document_exports
		WHERE document_id = $1 AND version = $2 AND format = 'pdf' AND lang = $3`, docID, version, lang).Scan(&e.DocumentID, &e.Version, &status, &e.Data, &e.Error, &e.UpdatedAt)
	e.Status = domain.ExportStatus(status)
	return e, notFound(err)
}

// StartDocumentExport marks the PDF of a version pending. It reports
// false when it is pending or done already (someone else renders it), or
// failed less than retryAfter ago.
func (s *Documents) StartDocumentExport(ctx context.Context, docID int64, version int, lang string, retryAfter time.Duration) (bool, error) {
	tag, err := s.db.Exec(ctx, `INSERT INTO document_exports (document_id, version, format, lang) VALUES ($1, $2, 'pdf', $4)
		ON CONFLICT (document_id, version, format, lang) DO UPDATE SET status = 'pending', error = '', updated_at = now()
		WHERE document_exports.status = 'failed' AND document_exports.updated_at < now() - $3::interval
		   OR document_exports.status = 'pending' AND document_exports.updated_at < now() - interval '5 minutes'`,
		docID, version, fmt.Sprintf("%d seconds", int(retryAfter.Seconds())), lang)
	return tag.RowsAffected() > 0, err
}

// FinishDocumentExport stores a rendered PDF, or why it failed.
func (s *Documents) FinishDocumentExport(ctx context.Context, docID int64, version int, lang string, data []byte, failure string) error {
	status := domain.ExportDone
	if failure != "" {
		status, data = domain.ExportFailed, nil
	}
	_, err := s.db.Exec(ctx, `UPDATE document_exports SET status = $3, data = $4, size = $5, error = $6, updated_at = now()
		WHERE document_id = $1 AND version = $2 AND format = 'pdf' AND lang = $7`, docID, version, string(status), data, len(data), failure, lang)
	return err
}
