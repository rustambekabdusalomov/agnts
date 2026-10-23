package httpapi

import (
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strconv"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// documentsReady answers 501 when the module is off.
func (s *Server) documentsReady(w http.ResponseWriter) bool {
	if s.opt.Documents == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "documents are not available")
		return false
	}
	return true
}

// caller is the signed-in person acting in their workspace.
func caller(r *http.Request) documents.Caller {
	m, _ := memberFrom(r.Context())
	u, _ := userFrom(r.Context())
	return documents.Caller{WorkspaceID: m.w.ID, UserID: u.ID, Role: m.role}
}

// documentError translates the module's errors.
func (s *Server) documentError(w http.ResponseWriter, r *http.Request, err error) {
	var secrets *documents.SecretsError
	switch {
	case errors.As(err, &secrets):
		out := gen.SecretFindings{Code: "secrets", Message: err.Error()}
		for _, f := range secrets.Findings {
			out.Findings = append(out.Findings, struct {
				Excerpt string `json:"excerpt"`
				Line    int    `json:"line"`
			}{Excerpt: f.Excerpt, Line: f.Line})
		}
		writeJSON(w, http.StatusUnprocessableEntity, out)
	case errors.Is(err, documents.ErrNoGuest):
		writeError(w, http.StatusUnauthorized, "guest_required", err.Error())
	case errors.Is(err, documents.ErrTooMany):
		w.Header().Set("Retry-After", "60")
		writeError(w, http.StatusTooManyRequests, "rate_limited", err.Error())
	case errors.Is(err, documents.ErrPreparing):
		w.Header().Set("Retry-After", "3")
		writeError(w, http.StatusAccepted, "preparing", err.Error())
	case errors.Is(err, documents.ErrRenderFailed):
		w.Header().Set("Retry-After", "120")
		writeError(w, http.StatusServiceUnavailable, "render_failed", err.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such document")
	case errors.Is(err, domain.ErrForbidden):
		writeError(w, http.StatusForbidden, "forbidden", err.Error())
	case errors.Is(err, domain.ErrDocInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

// publicURL is a public document's link.
func (s *Server) publicURL(token string) *string {
	if token == "" {
		return nil
	}
	base := "/d/"
	if s.opt.PublicURL != nil {
		base = s.opt.PublicURL.Scheme + "://" + s.opt.PublicURL.Host + "/d/"
	}
	u := base + url.PathEscape(token)
	return &u
}

func toDocumentSummary(v documents.View) gen.DocumentSummary {
	d := v.Doc
	return gen.DocumentSummary{Id: d.ID, Kind: gen.DocumentKind(d.Kind), Title: d.Title, Version: d.Version, Type: gen.DocumentSummaryType(d.Type),
		WorkspaceAccess: gen.DocumentSummaryWorkspaceAccess(d.WorkspaceAccess.String()), OwnerId: d.OwnerID, OwnerName: d.OwnerName,
		Language: gen.DocumentSummaryLanguage(d.Language), Access: gen.DocumentAccess(v.Access.String()), TicketCount: d.TicketCount,
		Generation: toDocumentGeneration(d.Run), CreatedAt: d.CreatedAt, UpdatedAt: d.UpdatedAt, DeletedAt: d.DeletedAt}
}

func (s *Server) toDocument(v documents.View) gen.Document {
	d := v.Doc
	sum := toDocumentSummary(v)
	out := gen.Document{Id: sum.Id, Kind: sum.Kind, Title: sum.Title, Version: sum.Version, Type: gen.DocumentType(sum.Type),
		WorkspaceAccess: gen.DocumentWorkspaceAccess(sum.WorkspaceAccess), OwnerId: sum.OwnerId, OwnerName: sum.OwnerName,
		Language: gen.DocumentLanguage(sum.Language), Access: sum.Access, TicketCount: sum.TicketCount, Generation: sum.Generation,
		CreatedAt: sum.CreatedAt, UpdatedAt: sum.UpdatedAt, DeletedAt: sum.DeletedAt,
		Body: d.Body, PublicUrl: s.publicURL(d.PublicToken), DataAsOf: d.DataAsOf}
	if d.Source != nil {
		src := toSourceInput(*d.Source)
		out.Source = &src
	}
	if f := v.From; f != nil {
		out.DerivedFrom = &struct {
			CurrentVersion int    `json:"currentVersion"`
			Id             int64  `json:"id"`
			Title          string `json:"title"`
			Version        int    `json:"version"`
		}{CurrentVersion: f.Current, Id: f.ID, Title: f.Title, Version: f.Version}
	}
	return out
}

func toDocumentGeneration(r *domain.DocumentRun) *gen.DocumentGeneration {
	if r == nil {
		return nil
	}
	src := toSourceInput(r.Source)
	return &gen.DocumentGeneration{Id: r.ID, Status: gen.DocumentGenerationStatus(r.Status), Error: r.Error, Source: &src,
		RequestedBy: r.RequestedBy, StartedAt: r.StartedAt, FinishedAt: r.FinishedAt, CreatedAt: r.CreatedAt}
}

func toSourceInput(s domain.DocumentSource) gen.DocumentSourceInput {
	out := gen.DocumentSourceInput{Kind: gen.DocumentSourceInputKind(s.Kind), From: s.From, To: s.To}
	tmpl := gen.DocumentSourceInputTemplate(s.Template)
	out.Template = &tmpl
	if s.Instruction != "" {
		out.Instruction = &s.Instruction
	}
	if len(s.TicketKeys) > 0 {
		out.Tickets = &s.TicketKeys
	}
	if len(s.RepoIDs) > 0 {
		out.RepoIds = &s.RepoIDs
	}
	if s.Branch != "" {
		out.Branch = &s.Branch
	}
	if s.Author != "" {
		out.Author = &s.Author
	}
	if s.PRState != "" {
		st := gen.DocumentSourceInputPrState(s.PRState)
		out.PrState = &st
	}
	if len(s.PRNumbers) > 0 {
		out.PrNumbers = &s.PRNumbers
	}
	if s.DocumentID != 0 {
		out.DocumentId = &s.DocumentID
		out.DocumentVersion = &s.DocumentVersion
	}
	if f := s.Filter; f != nil {
		out.Filter = &struct {
			Kinds  *[]string `json:"kinds,omitempty"`
			RepoId *int64    `json:"repoId,omitempty"`
			States *[]string `json:"states,omitempty"`
		}{RepoId: f.RepoID}
		if len(f.Kinds) > 0 {
			k := make([]string, len(f.Kinds))
			for i, x := range f.Kinds {
				k[i] = string(x)
			}
			out.Filter.Kinds = &k
		}
		if len(f.States) > 0 {
			st := make([]string, len(f.States))
			for i, x := range f.States {
				st[i] = string(x)
			}
			out.Filter.States = &st
		}
	}
	return out
}

func fromSourceInput(in *gen.DocumentSourceInput) *domain.DocumentSource {
	if in == nil {
		return nil
	}
	s := &domain.DocumentSource{Kind: domain.SourceKind(in.Kind), From: in.From, To: in.To}
	if in.Template != nil {
		s.Template = domain.DocTemplate(*in.Template)
	}
	if in.Instruction != nil {
		s.Instruction = *in.Instruction
	}
	if in.Tickets != nil {
		s.TicketKeys = *in.Tickets
	}
	if in.RepoIds != nil {
		s.RepoIDs = *in.RepoIds
	}
	if in.Branch != nil {
		s.Branch = *in.Branch
	}
	if in.Author != nil {
		s.Author = *in.Author
	}
	if in.PrState != nil {
		s.PRState = string(*in.PrState)
	}
	if in.PrNumbers != nil {
		s.PRNumbers = *in.PrNumbers
	}
	if in.DocumentId != nil {
		s.DocumentID = *in.DocumentId
	}
	if in.DocumentVersion != nil {
		s.DocumentVersion = *in.DocumentVersion
	}
	if f := in.Filter; f != nil {
		s.Filter = &domain.TicketFilter{RepoID: f.RepoId}
		if f.Kinds != nil {
			for _, k := range *f.Kinds {
				s.Filter.Kinds = append(s.Filter.Kinds, domain.TicketKind(k))
			}
		}
		if f.States != nil {
			for _, st := range *f.States {
				s.Filter.States = append(s.Filter.States, domain.TicketState(st))
			}
		}
	}
	return s
}

func (s *Server) writeDocument(w http.ResponseWriter, r *http.Request, status int, v documents.View, err error) {
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, status, s.toDocument(v))
}

// ListDocuments implements gen.ServerInterface.
func (s *Server) ListDocuments(w http.ResponseWriter, r *http.Request, params gen.ListDocumentsParams) {
	if !s.documentsReady(w) {
		return
	}
	f := postgres.DocumentFilter{}
	if params.Scope != nil && *params.Scope != "all" {
		f.Scope = string(*params.Scope)
	}
	if params.Q != nil {
		f.Query = *params.Q
	}
	if params.Ticket != nil {
		f.TicketKey = *params.Ticket
	}
	if params.Kind != nil {
		f.Kind = domain.DocumentKind(*params.Kind)
	}
	if params.DerivedFrom != nil {
		f.DerivedFrom = *params.DerivedFrom
	}
	vs, err := s.opt.Documents.List(r.Context(), caller(r), f)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	out := make([]gen.DocumentSummary, len(vs))
	for i, v := range vs {
		out[i] = toDocumentSummary(v)
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateDocument implements gen.ServerInterface.
func (s *Server) CreateDocument(w http.ResponseWriter, r *http.Request) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := documents.NewDocument{Title: req.Title, Source: fromSourceInput(req.Source)}
	if req.Kind != nil {
		in.Kind = domain.DocumentKind(*req.Kind)
	}
	if req.Body != nil {
		in.Body = *req.Body
	}
	if req.Language != nil {
		in.Language = string(*req.Language)
	}
	if req.LinkTickets != nil {
		in.LinkTickets = *req.LinkTickets
	}
	v, err := s.opt.Documents.Create(r.Context(), caller(r), in)
	s.writeDocument(w, r, http.StatusCreated, v, err)
}

// GetDocument implements gen.ServerInterface.
func (s *Server) GetDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.Get(r.Context(), caller(r), id)
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// SaveDocument implements gen.ServerInterface.
func (s *Server) SaveDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentSave
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Documents.Save(r.Context(), caller(r), id, req.Title, req.Body, req.BaseVersion)
	if errors.Is(err, domain.ErrConflict) {
		out := gen.DocumentConflict{Code: "conflict", Message: "someone saved this document after you started editing"}
		if errors.Is(err, documents.ErrBusy) {
			out.Message = err.Error()
		}
		if v.Doc.ID != 0 {
			cur := s.toDocument(v)
			out.Current = &cur
		}
		writeJSON(w, http.StatusConflict, out)
		return
	}
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// DeleteDocument implements gen.ServerInterface.
func (s *Server) DeleteDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	if err := s.opt.Documents.Delete(r.Context(), caller(r), id); err != nil {
		s.documentError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// UndeleteDocument implements gen.ServerInterface.
func (s *Server) UndeleteDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.Undelete(r.Context(), caller(r), id)
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// RegenerateDocument implements gen.ServerInterface.
func (s *Server) RegenerateDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentRegenerate
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Documents.Regenerate(r.Context(), caller(r), id, fromSourceInput(req.Source))
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// ListDocumentVersions implements gen.ServerInterface.
func (s *Server) ListDocumentVersions(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	vs, err := s.opt.Documents.Versions(r.Context(), caller(r), id)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	out := make([]gen.DocumentVersion, len(vs))
	for i, v := range vs {
		out[i] = toDocumentVersion(v, false)
	}
	writeJSON(w, http.StatusOK, out)
}

func toDocumentVersion(v domain.DocumentVersion, body bool) gen.DocumentVersion {
	out := gen.DocumentVersion{Version: v.Version, Title: v.Title, Source: gen.DocumentVersionSource(v.Source), Note: v.Note,
		AuthorId: v.AuthorID, CreatedAt: v.CreatedAt}
	if v.AuthorName != "" {
		out.AuthorName = &v.AuthorName
	}
	if body {
		out.Body = &v.Body
	}
	return out
}

// GetDocumentVersion implements gen.ServerInterface.
func (s *Server) GetDocumentVersion(w http.ResponseWriter, r *http.Request, id gen.DocumentID, version gen.DocumentVersionNo) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.Version(r.Context(), caller(r), id, version)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toDocumentVersion(v, true))
}

// RestoreDocumentVersion implements gen.ServerInterface.
func (s *Server) RestoreDocumentVersion(w http.ResponseWriter, r *http.Request, id gen.DocumentID, version gen.DocumentVersionNo) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.Restore(r.Context(), caller(r), id, version)
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// sharing answers a document's sharing as its viewer sees it.
func (s *Server) sharing(w http.ResponseWriter, r *http.Request, v documents.View) {
	c := caller(r)
	grants, err := s.opt.Documents.Grants(r.Context(), c, v.Doc.ID)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	allowed := true
	if s.opt.Admin != nil && s.opt.Admin.Settings != nil {
		if st, err := s.opt.Admin.Settings.Get(r.Context()); err == nil {
			allowed = st.PublicDocuments
		}
	}
	out := gen.DocumentSharing{Type: gen.DocumentSharingType(v.Doc.Type), PublicUrl: s.publicURL(v.Doc.PublicToken),
		WorkspaceAccess: gen.DocumentSharingWorkspaceAccess(v.Doc.WorkspaceAccess.String()), OwnerId: v.Doc.OwnerID,
		Grants: make([]gen.DocumentGrant, len(grants)), PublicAllowed: allowed}
	for i, g := range grants {
		out.Grants[i] = gen.DocumentGrant{UserId: g.UserID, Username: &g.Username, Level: gen.DocumentGrantLevel(g.Level.String()), CreatedAt: &g.CreatedAt}
	}
	writeJSON(w, http.StatusOK, out)
}

// GetDocumentSharing implements gen.ServerInterface.
func (s *Server) GetDocumentSharing(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.Get(r.Context(), caller(r), id)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	s.sharing(w, r, v)
}

// ShareDocument implements gen.ServerInterface.
func (s *Server) ShareDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentShareInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := documents.Sharing{Type: domain.DocumentType(req.Type)}
	in.WorkspaceAccess, _ = domain.ParseAccessLevel(string(req.WorkspaceAccess))
	for _, g := range req.Grants {
		l, _ := domain.ParseAccessLevel(string(g.Level))
		in.Grants = append(in.Grants, domain.DocumentGrant{UserID: g.UserId, Level: l})
	}
	v, err := s.opt.Documents.Share(r.Context(), caller(r), id, in)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	s.sharing(w, r, v)
}

// ResetDocumentLink implements gen.ServerInterface.
func (s *Server) ResetDocumentLink(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	v, err := s.opt.Documents.ResetLink(r.Context(), caller(r), id)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	s.sharing(w, r, v)
}

// SetDocumentOwner implements gen.ServerInterface.
func (s *Server) SetDocumentOwner(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.SetDocumentOwnerJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Documents.SetOwner(r.Context(), caller(r), id, req.UserId)
	s.writeDocument(w, r, http.StatusOK, v, err)
}

// ListDocumentTickets implements gen.ServerInterface.
func (s *Server) ListDocumentTickets(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	ts, err := s.opt.Documents.Tickets(r.Context(), caller(r), id)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	out := make([]gen.DocumentTicket, len(ts))
	for i, t := range ts {
		out[i] = gen.DocumentTicket{Key: t.Key, Number: t.Number, Title: t.Title, State: string(t.State), Kind: string(t.Kind),
			LinkedBy: t.LinkedBy, LinkedAt: t.CreatedAt}
		if out[i].Number == "" {
			out[i].Number = t.Key
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// LinkDocumentTicket implements gen.ServerInterface.
func (s *Server) LinkDocumentTicket(w http.ResponseWriter, r *http.Request, id gen.DocumentID, key gen.TicketKey) {
	if !s.documentsReady(w) {
		return
	}
	if err := s.opt.Documents.Link(r.Context(), caller(r), id, key); err != nil {
		s.documentError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// UnlinkDocumentTicket implements gen.ServerInterface.
func (s *Server) UnlinkDocumentTicket(w http.ResponseWriter, r *http.Request, id gen.DocumentID, key gen.TicketKey) {
	if !s.documentsReady(w) {
		return
	}
	if err := s.opt.Documents.Unlink(r.Context(), caller(r), id, key); err != nil {
		s.documentError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// writeFile sends a download as an attachment.
func writeFile(w http.ResponseWriter, f documents.File) {
	w.Header().Set("Content-Type", f.ContentType)
	w.Header().Set("Content-Disposition", fmt.Sprintf(`attachment; filename="%s"; filename*=UTF-8''%s`, f.Name, url.PathEscape(f.Name)))
	w.Header().Set("Content-Length", strconv.Itoa(len(f.Data)))
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(f.Data)
}

// DownloadDocument implements gen.ServerInterface.
func (s *Server) DownloadDocument(w http.ResponseWriter, r *http.Request, id gen.DocumentID, params gen.DownloadDocumentParams) {
	if !s.documentsReady(w) {
		return
	}
	format, version := documents.FormatMarkdown, 0
	if params.Format != nil {
		format = string(*params.Format)
	}
	if params.Version != nil {
		version = *params.Version
	}
	f, err := s.opt.Documents.Download(r.Context(), caller(r), id, format, version)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeFile(w, f)
}

// ListTicketDocuments implements gen.ServerInterface.
func (s *Server) ListTicketDocuments(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.documentsReady(w) {
		return
	}
	vs, err := s.opt.Documents.TicketDocuments(r.Context(), caller(r), key)
	if errors.Is(err, domain.ErrNotFound) {
		writeError(w, http.StatusNotFound, "not_found", "no such ticket")
		return
	}
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	out := make([]gen.DocumentSummary, len(vs))
	for i, v := range vs {
		out[i] = toDocumentSummary(v)
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateTicketDocument implements gen.ServerInterface.
func (s *Server) CreateTicketDocument(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.CreateTicketDocumentJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	instruction, lang := "", ""
	if req.Instruction != nil {
		instruction = *req.Instruction
	}
	if req.Language != nil {
		lang = string(*req.Language)
	}
	v, err := s.opt.Documents.CreateFromReport(r.Context(), caller(r), key, instruction, lang)
	if errors.Is(err, domain.ErrNotFound) && v.Doc.ID == 0 {
		writeError(w, http.StatusNotFound, "not_found", "no such ticket")
		return
	}
	s.writeDocument(w, r, http.StatusCreated, v, err)
}

// publicHeaders keeps a public page out of search engines and its token
// out of the Referer of the sites it links to.
func publicHeaders(w http.ResponseWriter) {
	w.Header().Set("X-Robots-Tag", "noindex, nofollow")
	w.Header().Set("Referrer-Policy", "no-referrer")
}

// GetPublicDocument implements gen.ServerInterface.
func (s *Server) GetPublicDocument(w http.ResponseWriter, r *http.Request, token gen.PublicToken, params gen.GetPublicDocumentParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	p, err := s.opt.Documents.PublicDocument(g)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.PublicDocument{Kind: gen.DocumentKind(p.Kind), Title: p.Title, Body: p.Body, Version: p.Version, UpdatedAt: p.UpdatedAt})
}

// DownloadPublicDocument implements gen.ServerInterface.
func (s *Server) DownloadPublicDocument(w http.ResponseWriter, r *http.Request, token gen.PublicToken, params gen.DownloadPublicDocumentParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	format := documents.FormatMarkdown
	if params.Format != nil {
		format = string(*params.Format)
	}
	f, err := s.opt.Documents.PublicDownload(g, format)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeFile(w, f)
}
