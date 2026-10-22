// Package documents runs the Documents module: Markdown pages of a
// workspace that people write or agnts generates, shared with members as
// view or edit, optionally public through a link, linked to tickets, and
// downloadable as Markdown or PDF. Every access check goes through
// domain.EffectiveAccess here; handlers only translate errors.
package documents

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Store is where documents live (postgres.Documents).
type Store interface {
	CreateDocument(ctx context.Context, d domain.Document, first *domain.DocumentVersion) (domain.Document, error)
	Document(ctx context.Context, id int64) (domain.Document, error)
	DocumentGrant(ctx context.Context, docID, userID int64) (domain.AccessLevel, error)
	ListDocuments(ctx context.Context, userID int64, role domain.WorkspaceRole, f postgres.DocumentFilter) ([]domain.Document, []domain.AccessLevel, error)
	SaveDocumentVersion(ctx context.Context, docID int64, base int, v domain.DocumentVersion) (domain.Document, error)
	RenameDocument(ctx context.Context, docID int64, title string) (domain.Document, error)
	DocumentVersions(ctx context.Context, docID int64) ([]domain.DocumentVersion, error)
	DocumentVersion(ctx context.Context, docID int64, version int) (domain.DocumentVersion, error)
	SetDocumentSharing(ctx context.Context, docID int64, sh postgres.Sharing, by int64) (domain.Document, error)
	DocumentGrants(ctx context.Context, docID int64) ([]domain.DocumentGrant, error)
	SetDocumentOwner(ctx context.Context, docID, to int64) (domain.Document, error)
	DeleteDocument(ctx context.Context, docID int64) error
	RestoreDocument(ctx context.Context, docID int64) (domain.Document, error)
	PurgeDocuments(ctx context.Context, before time.Time) (int64, error)
	LinkDocumentTicket(ctx context.Context, docID, ticketID int64, by *int64) error
	UnlinkDocumentTicket(ctx context.Context, docID, ticketID int64) error
	DocumentTickets(ctx context.Context, docID int64) ([]domain.DocumentTicket, error)
	CreateDocumentRun(ctx context.Context, docID int64, src domain.DocumentSource, by *int64, promptVersion string) (domain.DocumentRun, error)
	PublicDocument(ctx context.Context, token string) (domain.Document, error)
	DocumentExport(ctx context.Context, docID int64, version int) (domain.DocumentExport, error)
	StartDocumentExport(ctx context.Context, docID int64, version int, retryAfter time.Duration) (bool, error)
	FinishDocumentExport(ctx context.Context, docID int64, version int, data []byte, failure string) error
}

// Workspaces gives members and their roles.
type Workspaces interface {
	Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
	Members(ctx context.Context, ws int64) ([]domain.Member, error)
}

// Tickets reads the tickets and repositories sources name.
type Tickets interface {
	// TicketsByTokens returns the tickets whose number or key is one of
	// the lower-case tokens.
	TicketsByTokens(ctx context.Context, tokens []string) ([]domain.Ticket, error)
	RepositoryByID(ctx context.Context, id int64) (domain.Repository, error)
	LatestResult(ctx context.Context, ticketID int64, stage domain.Stage) (domain.Result, error)
}

// Settings gives the workspace's settings (public documents on or off).
type Settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}

// Generator runs generations; Wake has it look at its queue now.
type Generator interface{ Wake() }

// PDFRenderer prints an HTML page to PDF.
type PDFRenderer interface {
	RenderPDF(ctx context.Context, html []byte) ([]byte, error)
}

// Notifier sends an event to one person's live streams in a workspace.
type Notifier interface {
	PublishTo(ws, user int64, e domain.Event)
}

// Errors the handlers translate.
var (
	// ErrPreparing: the PDF is being made; ask again shortly.
	ErrPreparing = errors.New("the PDF is being prepared")
	// ErrRenderFailed: the PDF could not be made; the Markdown still can.
	ErrRenderFailed = errors.New("the PDF could not be made")
	// ErrBusy: a generation is writing the document.
	ErrBusy = fmt.Errorf("%w: agnts is writing this document; wait for it to finish", domain.ErrConflict)
)

// SecretsError blocks publishing a document that looks like it holds
// secrets.
type SecretsError struct{ Findings []domain.SecretFinding }

func (e *SecretsError) Error() string {
	return fmt.Sprintf("the document looks like it holds %d secret(s); remove them before publishing", len(e.Findings))
}

// EventDocumentUpdated tells the people who can open a document that it
// changed. It is not stored; Data carries only the document's id.
const EventDocumentUpdated = "document_updated"

// pdfRetry is how long a failed PDF waits before it is tried again.
const pdfRetry = 2 * time.Minute

// Deps are the service's collaborators.
type Deps struct {
	Store      Store
	Workspaces Workspaces
	Tickets    Tickets
	Settings   Settings
	Generator  Generator   // nil: generations are refused
	PDF        PDFRenderer // nil: PDFs are refused
	Notifier   Notifier    // nil: nobody hears about changes
	Log        *slog.Logger
}

// Service is the Documents module.
type Service struct {
	d   Deps
	now func() time.Time
}

// New returns the service.
func New(d Deps) *Service {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	return &Service{d: d, now: time.Now}
}

// Caller is the signed-in person acting in their workspace.
type Caller struct {
	WorkspaceID int64
	UserID      int64
	Role        domain.WorkspaceRole
}

// View is a document as one person sees it.
type View struct {
	Doc    domain.Document
	Access domain.AccessLevel
}

func invalid(format string, args ...any) error {
	return fmt.Errorf("%w: %s", domain.ErrDocInvalid, fmt.Sprintf(format, args...))
}

// open returns a live document and the caller's access, or ErrNotFound
// when they cannot open it (never a hint that it exists).
func (s *Service) open(ctx context.Context, c Caller, id int64) (View, error) {
	d, err := s.d.Store.Document(ctx, id)
	if err != nil {
		return View{}, err
	}
	if d.DeletedAt != nil {
		return View{}, domain.ErrNotFound
	}
	grant, err := s.d.Store.DocumentGrant(ctx, id, c.UserID)
	if err != nil {
		return View{}, err
	}
	l := domain.EffectiveAccess(d, c.UserID, c.Role, grant)
	if l == domain.AccessNone {
		return View{}, domain.ErrNotFound
	}
	return View{Doc: d, Access: l}, nil
}

// need opens a document and checks the caller has at least level.
func (s *Service) need(ctx context.Context, c Caller, id int64, level domain.AccessLevel) (View, error) {
	v, err := s.open(ctx, c, id)
	if err != nil {
		return v, err
	}
	if v.Access < level {
		what := map[domain.AccessLevel]string{domain.AccessEdit: "edit access", domain.AccessOwner: "the document's owner"}[level]
		return v, fmt.Errorf("%w: this needs %s", domain.ErrForbidden, what)
	}
	return v, nil
}

// List returns the documents the caller can open.
func (s *Service) List(ctx context.Context, c Caller, f postgres.DocumentFilter) ([]View, error) {
	docs, grants, err := s.d.Store.ListDocuments(ctx, c.UserID, c.Role, f)
	if err != nil {
		return nil, err
	}
	out := make([]View, 0, len(docs))
	for i, d := range docs {
		out = append(out, View{Doc: d, Access: domain.EffectiveAccess(d, c.UserID, c.Role, grants[i])})
	}
	return out, nil
}

// Get returns one document.
func (s *Service) Get(ctx context.Context, c Caller, id int64) (View, error) {
	return s.open(ctx, c, id)
}

// NewDocument is what a person creates a document with.
type NewDocument struct {
	Title    string
	Body     string
	Language string
	// Source, when set, has agnts write the body.
	Source *domain.DocumentSource
	// LinkTickets are linked right away (the caller needs a role that
	// edits tickets).
	LinkTickets []string
}

// Create makes a document owned by the caller: written by them, or queued
// for agnts to write from Source. Workspace viewers may create documents
// too; they own what they create.
func (s *Service) Create(ctx context.Context, c Caller, in NewDocument) (View, error) {
	title, err := domain.CleanDocumentTitle(in.Title)
	if err != nil {
		return View{}, err
	}
	body, err := domain.CleanDocumentBody(in.Body)
	if err != nil {
		return View{}, err
	}
	lang := in.Language
	if lang != "ru" && lang != "uz" {
		lang = "en"
	}
	var links []domain.Ticket
	if len(in.LinkTickets) > 0 {
		if !c.Role.CanEdit() {
			return View{}, fmt.Errorf("%w: viewers cannot link tickets", domain.ErrForbidden)
		}
		for _, k := range in.LinkTickets {
			t, err := s.ticket(ctx, k)
			if err != nil {
				return View{}, invalidTicket(k, err)
			}
			links = append(links, t)
		}
	}
	d := domain.Document{Title: title, OwnerID: c.UserID, Language: lang}
	var first *domain.DocumentVersion
	if in.Source != nil {
		if s.d.Generator == nil {
			return View{}, invalid("generating documents is not available on this server")
		}
		src := *in.Source
		if err := s.checkSource(ctx, &src); err != nil {
			return View{}, err
		}
		d.Source = &src
		if src.Kind == domain.SourceReport {
			t, _ := s.ticket(ctx, src.TicketKeys[0])
			links = append(links, t)
		}
	} else {
		first = &domain.DocumentVersion{Title: title, Body: body, Source: domain.VersionHuman, AuthorID: &c.UserID}
	}
	d, err = s.d.Store.CreateDocument(ctx, d, first)
	if err != nil {
		return View{}, err
	}
	for _, t := range links {
		if err := s.d.Store.LinkDocumentTicket(ctx, d.ID, t.ID, &c.UserID); err != nil {
			return View{}, err
		}
	}
	if d.Source != nil {
		if _, err := s.d.Store.CreateDocumentRun(ctx, d.ID, *d.Source, &c.UserID, DocumentPromptVersion); err != nil {
			return View{}, err
		}
		s.d.Generator.Wake()
	}
	return s.open(ctx, c, d.ID)
}

// DocumentPromptVersion is recorded with each generation (the
// orchestrator's prompt version for documents).
var DocumentPromptVersion = "doc-1"

// ticket finds the ticket a person named by its number (AMANAT-12) or
// its key: an open ticket with that number first, then the key (see
// domain.PickTicket).
func (s *Service) ticket(ctx context.Context, ref string) (domain.Ticket, error) {
	ref = strings.TrimSpace(ref)
	if ref == "" {
		return domain.Ticket{}, domain.ErrNotFound
	}
	ts, err := s.d.Tickets.TicketsByTokens(ctx, []string{strings.ToLower(ref)})
	if err != nil {
		return domain.Ticket{}, err
	}
	if t, ok := domain.PickTicket(ref, ts); ok {
		return t, nil
	}
	return domain.Ticket{}, domain.ErrNotFound
}

func invalidTicket(key string, err error) error {
	if errors.Is(err, domain.ErrNotFound) {
		return invalid("no ticket %s", key)
	}
	return err
}

// checkSource validates a source and that what it names exists.
func (s *Service) checkSource(ctx context.Context, src *domain.DocumentSource) error {
	if err := src.Validate(); err != nil {
		return err
	}
	// People name tickets by number (AMANAT-12) or key; the source keeps
	// the key, which never changes.
	for i, k := range src.TicketKeys {
		t, err := s.ticket(ctx, k)
		if err != nil {
			return invalidTicket(k, err)
		}
		src.TicketKeys[i] = t.Key
		if src.Kind == domain.SourceReport {
			r, err := s.d.Tickets.LatestResult(ctx, t.ID, domain.StageCode)
			if err != nil && !errors.Is(err, domain.ErrNotFound) {
				return err
			}
			if strings.TrimSpace(r.Report) == "" {
				return invalid("%s has no report yet", t.Number())
			}
		}
	}
	ids := src.RepoIDs
	if src.Filter != nil && src.Filter.RepoID != nil {
		ids = append(ids, *src.Filter.RepoID)
	}
	for _, id := range ids {
		if _, err := s.d.Tickets.RepositoryByID(ctx, id); err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				return invalid("no repository %d", id)
			}
			return err
		}
	}
	return nil
}

// CreateFromReport has agnts make a document from a ticket's report,
// linked to the ticket.
func (s *Service) CreateFromReport(ctx context.Context, c Caller, key, instruction, language string) (View, error) {
	t, err := s.ticket(ctx, key)
	if err != nil {
		return View{}, err
	}
	title := t.Number() + ": " + t.Title
	if r := []rune(title); len(r) > domain.DocMaxTitle {
		title = string(r[:domain.DocMaxTitle])
	}
	return s.Create(ctx, c, NewDocument{Title: title, Language: language,
		Source: &domain.DocumentSource{Kind: domain.SourceReport, TicketKeys: []string{t.Key}, Instruction: instruction}})
}

// Save stores an edit as a new version. base is the version the edit
// started from; when someone saved in between it returns
// domain.ErrConflict with the document as it is now. While agnts writes
// the body, only the title can change.
func (s *Service) Save(ctx context.Context, c Caller, id int64, title, body string, base int) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessEdit)
	if err != nil {
		return v, err
	}
	if title, err = domain.CleanDocumentTitle(title); err != nil {
		return v, err
	}
	if body, err = domain.CleanDocumentBody(body); err != nil {
		return v, err
	}
	d := v.Doc
	switch {
	case title == d.Title && body == d.Body:
		return v, nil
	case d.Generating() && body != d.Body:
		return v, ErrBusy
	case d.Generating() || body == d.Body && d.Version == 0:
		d, err = s.d.Store.RenameDocument(ctx, id, title)
	default:
		d, err = s.d.Store.SaveDocumentVersion(ctx, id, base, domain.DocumentVersion{Title: title, Body: body, Source: domain.VersionHuman, AuthorID: &c.UserID})
	}
	if errors.Is(err, domain.ErrConflict) {
		return View{Doc: d, Access: v.Access}, err
	}
	if err != nil {
		return v, err
	}
	s.changed(ctx, d)
	return View{Doc: d, Access: v.Access}, nil
}

// Regenerate has agnts write the document again, from src or (nil) the
// source it was made from. The result is a new version.
func (s *Service) Regenerate(ctx context.Context, c Caller, id int64, src *domain.DocumentSource) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessEdit)
	if err != nil {
		return v, err
	}
	if s.d.Generator == nil {
		return v, invalid("generating documents is not available on this server")
	}
	if src == nil {
		if v.Doc.Source == nil {
			return v, invalid("this document was written by hand; choose what to make it from")
		}
		cp := *v.Doc.Source
		src = &cp
	}
	if err := s.checkSource(ctx, src); err != nil {
		return v, err
	}
	if _, err := s.d.Store.CreateDocumentRun(ctx, id, *src, &c.UserID, DocumentPromptVersion); err != nil {
		if errors.Is(err, domain.ErrConflict) {
			return v, ErrBusy
		}
		return v, err
	}
	s.d.Generator.Wake()
	v, err = s.open(ctx, c, id)
	if err == nil {
		s.changed(ctx, v.Doc)
	}
	return v, err
}

// Versions lists a document's versions, newest first.
func (s *Service) Versions(ctx context.Context, c Caller, id int64) ([]domain.DocumentVersion, error) {
	if _, err := s.open(ctx, c, id); err != nil {
		return nil, err
	}
	return s.d.Store.DocumentVersions(ctx, id)
}

// Version returns one version with its text.
func (s *Service) Version(ctx context.Context, c Caller, id int64, version int) (domain.DocumentVersion, error) {
	if _, err := s.open(ctx, c, id); err != nil {
		return domain.DocumentVersion{}, err
	}
	return s.d.Store.DocumentVersion(ctx, id, version)
}

// Restore makes an earlier version the current one, as a new version.
func (s *Service) Restore(ctx context.Context, c Caller, id int64, version int) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessEdit)
	if err != nil {
		return v, err
	}
	if v.Doc.Generating() {
		return v, ErrBusy
	}
	old, err := s.d.Store.DocumentVersion(ctx, id, version)
	if err != nil {
		return v, err
	}
	d, err := s.d.Store.SaveDocumentVersion(ctx, id, -1, domain.DocumentVersion{Title: old.Title, Body: old.Body,
		Source: domain.VersionRestore, Note: fmt.Sprintf("restored version %d", version), AuthorID: &c.UserID})
	if err != nil {
		return v, err
	}
	s.changed(ctx, d)
	return View{Doc: d, Access: v.Access}, nil
}

// Sharing is who can open a document besides its owner.
type Sharing struct {
	Type            domain.DocumentType
	WorkspaceAccess domain.AccessLevel
	Grants          []domain.DocumentGrant
}

// Grants returns who a document is shared with.
func (s *Service) Grants(ctx context.Context, c Caller, id int64) ([]domain.DocumentGrant, error) {
	if _, err := s.open(ctx, c, id); err != nil {
		return nil, err
	}
	return s.d.Store.DocumentGrants(ctx, id)
}

// Share replaces a document's type, workspace default and grants (owner
// only). Going public needs public documents on in Settings and a body
// the secret scan passes, and makes a new link token.
func (s *Service) Share(ctx context.Context, c Caller, id int64, in Sharing) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessOwner)
	if err != nil {
		return v, err
	}
	if !in.Type.Valid() {
		return v, invalid("type is private or public")
	}
	if in.WorkspaceAccess != domain.AccessNone && !in.WorkspaceAccess.Grantable() {
		return v, invalid("workspace access is none, view or edit")
	}
	members, err := s.d.Workspaces.Members(ctx, c.WorkspaceID)
	if err != nil {
		return v, err
	}
	roles := map[int64]domain.WorkspaceRole{}
	for _, m := range members {
		roles[m.UserID] = m.Role
	}
	var grants []domain.DocumentGrant
	seen := map[int64]bool{}
	for _, g := range in.Grants {
		role, ok := roles[g.UserID]
		switch {
		case !ok:
			return v, invalid("user %d is not a member of this workspace", g.UserID)
		case !g.Level.Grantable():
			return v, invalid("a grant is view or edit")
		case role == domain.RoleViewer && g.Level > domain.AccessView:
			return v, invalid("workspace viewers can only be given view access")
		case g.UserID == v.Doc.OwnerID || seen[g.UserID]:
			continue
		}
		seen[g.UserID] = true
		grants = append(grants, domain.DocumentGrant{UserID: g.UserID, Level: g.Level})
	}
	sh := postgres.Sharing{Type: in.Type, WorkspaceAccess: in.WorkspaceAccess, Grants: grants}
	if in.Type == domain.DocPublic {
		if err := s.checkPublish(ctx, v.Doc); err != nil {
			return v, err
		}
		if v.Doc.Type != domain.DocPublic {
			if sh.PublicToken, err = domain.NewPublicToken(); err != nil {
				return v, err
			}
		}
	}
	d, err := s.d.Store.SetDocumentSharing(ctx, id, sh, c.UserID)
	if err != nil {
		return v, err
	}
	s.changed(ctx, d)
	return View{Doc: d, Access: v.Access}, nil
}

// checkPublish refuses to publish when the workspace turned public
// documents off or the body looks like it holds secrets.
func (s *Service) checkPublish(ctx context.Context, d domain.Document) error {
	st, err := s.d.Settings.Get(ctx)
	if err != nil {
		return err
	}
	if !st.PublicDocuments {
		return invalid("public documents are turned off in this workspace's Settings")
	}
	if f := domain.ScanSecrets(d.Title+"\n"+d.Body, domain.Redactor{}); len(f) > 0 {
		for i := range f {
			f[i].Line-- // the title was line 1
		}
		return &SecretsError{Findings: f}
	}
	return nil
}

// ResetLink gives a public document a new link; the old one stops
// working at once.
func (s *Service) ResetLink(ctx context.Context, c Caller, id int64) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessOwner)
	if err != nil {
		return v, err
	}
	if v.Doc.Type != domain.DocPublic {
		return v, invalid("only a public document has a link")
	}
	grants, err := s.d.Store.DocumentGrants(ctx, id)
	if err != nil {
		return v, err
	}
	tok, err := domain.NewPublicToken()
	if err != nil {
		return v, err
	}
	d, err := s.d.Store.SetDocumentSharing(ctx, id, postgres.Sharing{Type: domain.DocPublic, PublicToken: tok,
		WorkspaceAccess: v.Doc.WorkspaceAccess, Grants: grants}, c.UserID)
	if err != nil {
		return v, err
	}
	s.changed(ctx, d)
	return View{Doc: d, Access: v.Access}, nil
}

// SetOwner gives the document to another member (owner only).
func (s *Service) SetOwner(ctx context.Context, c Caller, id, to int64) (View, error) {
	v, err := s.need(ctx, c, id, domain.AccessOwner)
	if err != nil {
		return v, err
	}
	if _, err := s.d.Workspaces.Role(ctx, c.WorkspaceID, to); err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return v, invalid("user %d is not a member of this workspace", to)
		}
		return v, err
	}
	d, err := s.d.Store.SetDocumentOwner(ctx, id, to)
	if err != nil {
		return v, err
	}
	s.changed(ctx, d)
	return s.open(ctx, c, id)
}

// Delete moves a document to the trash (owner only). It can be restored
// for domain.DocTrashDays days.
func (s *Service) Delete(ctx context.Context, c Caller, id int64) error {
	v, err := s.need(ctx, c, id, domain.AccessOwner)
	if err != nil {
		return err
	}
	if err := s.d.Store.DeleteDocument(ctx, id); err != nil {
		return err
	}
	v.Doc.DeletedAt = new(time.Time)
	s.changed(ctx, v.Doc)
	return nil
}

// Undelete takes a document out of the trash: its owner or the
// workspace's owner.
func (s *Service) Undelete(ctx context.Context, c Caller, id int64) (View, error) {
	d, err := s.d.Store.Document(ctx, id)
	if err != nil {
		return View{}, err
	}
	if d.DeletedAt == nil || domain.EffectiveAccess(d, c.UserID, c.Role, domain.AccessNone) < domain.AccessOwner {
		return View{}, domain.ErrNotFound
	}
	d, err = s.d.Store.RestoreDocument(ctx, id)
	if err != nil {
		return View{}, err
	}
	s.changed(ctx, d)
	return s.open(ctx, c, id)
}

// Purge removes for good the documents in the trash for longer than
// domain.DocTrashDays. ctx must be system work.
func (s *Service) Purge(ctx context.Context) (int64, error) {
	return s.d.Store.PurgeDocuments(ctx, s.now().AddDate(0, 0, -domain.DocTrashDays))
}

// Tickets returns the tickets linked to a document.
func (s *Service) Tickets(ctx context.Context, c Caller, id int64) ([]domain.DocumentTicket, error) {
	if _, err := s.open(ctx, c, id); err != nil {
		return nil, err
	}
	return s.d.Store.DocumentTickets(ctx, id)
}

// Link links a ticket to a document: edit access on the document and a
// role that edits tickets.
func (s *Service) Link(ctx context.Context, c Caller, id int64, key string) error {
	_, t, err := s.linkable(ctx, c, id, key)
	if err != nil {
		return err
	}
	return s.d.Store.LinkDocumentTicket(ctx, id, t.ID, &c.UserID)
}

// Unlink removes a link.
func (s *Service) Unlink(ctx context.Context, c Caller, id int64, key string) error {
	_, t, err := s.linkable(ctx, c, id, key)
	if err != nil {
		return err
	}
	return s.d.Store.UnlinkDocumentTicket(ctx, id, t.ID)
}

func (s *Service) linkable(ctx context.Context, c Caller, id int64, key string) (View, domain.Ticket, error) {
	v, err := s.need(ctx, c, id, domain.AccessEdit)
	if err != nil {
		return v, domain.Ticket{}, err
	}
	if !c.Role.CanEdit() {
		return v, domain.Ticket{}, fmt.Errorf("%w: viewers cannot link tickets", domain.ErrForbidden)
	}
	t, err := s.ticket(ctx, key)
	if err != nil {
		return v, t, invalidTicket(key, err)
	}
	return v, t, nil
}

// TicketDocuments returns the documents linked to a ticket that the
// caller can open; the others are neither shown nor counted.
func (s *Service) TicketDocuments(ctx context.Context, c Caller, key string) ([]View, error) {
	t, err := s.ticket(ctx, key)
	if err != nil {
		return nil, err
	}
	return s.List(ctx, c, postgres.DocumentFilter{TicketKey: t.Key})
}

// changed tells everyone who can open d that it changed, and renders the
// PDF of a public document's current version ahead of its first
// download.
func (s *Service) changed(ctx context.Context, d domain.Document) {
	if d.Type == domain.DocPublic && d.DeletedAt == nil && d.Version > 0 {
		s.prepare(ctx, d, d.Version)
	}
	if s.d.Notifier == nil {
		return
	}
	members, err := s.d.Workspaces.Members(ctx, d.WorkspaceID)
	if err != nil {
		s.d.Log.Warn("document event: members", "document", d.ID, "err", err)
		return
	}
	grants, err := s.d.Store.DocumentGrants(ctx, d.ID)
	if err != nil {
		s.d.Log.Warn("document event: grants", "document", d.ID, "err", err)
		return
	}
	byUser := map[int64]domain.AccessLevel{}
	for _, g := range grants {
		byUser[g.UserID] = g.Level
	}
	for _, m := range members {
		if domain.EffectiveAccess(d, m.UserID, m.Role, byUser[m.UserID]) == domain.AccessNone {
			continue
		}
		s.d.Notifier.PublishTo(d.WorkspaceID, m.UserID, domain.Event{WorkspaceID: d.WorkspaceID, Type: EventDocumentUpdated,
			Origin: domain.OriginSystem, Data: map[string]any{"documentId": d.ID, "version": d.Version}, CreatedAt: s.now()})
	}
}

// DocumentChanged implements orchestrator.DocumentWatcher.
func (s *Service) DocumentChanged(ctx context.Context, d domain.Document) { s.changed(ctx, d) }
