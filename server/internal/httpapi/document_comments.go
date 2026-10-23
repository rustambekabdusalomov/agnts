package httpapi

import (
	"errors"
	"net/http"
	"strings"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/google"
	"agnts/internal/httpapi/gen"
)

func toComment(c documents.CommentView) gen.DocumentComment {
	out := gen.DocumentComment{Id: c.ID, ParentId: c.ParentID, AuthorName: c.AuthorName, Body: c.Body, Quote: c.Quote, Prefix: c.Prefix,
		Suffix: c.Suffix, Slide: c.Slide, Version: c.Version, ResolvedAt: c.ResolvedAt, Mine: c.Mine, CanResolve: c.CanResolve,
		CanDelete: c.CanDelete, CreatedAt: c.CreatedAt, UpdatedAt: c.UpdatedAt, AuthorKind: gen.DocumentCommentAuthorKindGone}
	switch {
	case c.AuthorUserID != nil:
		out.AuthorKind = gen.DocumentCommentAuthorKindMember
	case c.AuthorGuestID != nil:
		out.AuthorKind = gen.DocumentCommentAuthorKindGuest
		via := gen.DocumentCommentAuthorVia(c.AuthorVia)
		out.AuthorVia = &via
		if c.AuthorEmail != "" && c.ShowEmail {
			out.AuthorEmail = &c.AuthorEmail
		}
	}
	if c.ResolvedAt != nil {
		out.ResolvedBy = &c.ResolvedBy
	}
	return out
}

func toComments(cs []documents.CommentView) []gen.DocumentComment {
	out := make([]gen.DocumentComment, len(cs))
	for i, c := range cs {
		out[i] = toComment(c)
	}
	return out
}

func toPresence(p documents.Presence) gen.DocumentPresence {
	out := gen.DocumentPresence{CommentsStamp: p.CommentsStamp, Viewers: make([]gen.DocumentViewer, len(p.Viewers))}
	for i, v := range p.Viewers {
		out.Viewers[i] = gen.DocumentViewer{Kind: gen.DocumentViewerKind(v.Kind), Id: v.ID, Name: v.Name, You: v.Key() == p.You}
		if v.Kind == domain.ViewerGuest {
			via := gen.DocumentViewerVia(v.Via)
			out.Viewers[i].Via = &via
		}
	}
	return out
}

func fromCommentInput(in gen.DocumentCommentInput) documents.NewComment {
	out := documents.NewComment{ParentID: in.ParentId, Body: in.Body, Slide: in.Slide}
	if in.Quote != nil {
		out.Quote = *in.Quote
	}
	if in.Prefix != nil {
		out.Prefix = *in.Prefix
	}
	if in.Suffix != nil {
		out.Suffix = *in.Suffix
	}
	return out
}

// writeComment answers one comment, or the error.
func (s *Server) writeComment(w http.ResponseWriter, r *http.Request, status int, c documents.CommentView, err error) {
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, status, toComment(c))
}

// ListDocumentComments implements gen.ServerInterface.
func (s *Server) ListDocumentComments(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	cs, err := s.opt.Documents.Comments(r.Context(), caller(r), id)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toComments(cs))
}

// AddDocumentComment implements gen.ServerInterface.
func (s *Server) AddDocumentComment(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentCommentInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Documents.AddComment(r.Context(), caller(r), id, fromCommentInput(req))
	s.writeComment(w, r, http.StatusCreated, c, err)
}

// UpdateDocumentComment implements gen.ServerInterface.
func (s *Server) UpdateDocumentComment(w http.ResponseWriter, r *http.Request, id gen.DocumentID, commentID gen.CommentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.DocumentCommentPatch
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var c documents.CommentView
	var err error
	switch {
	case req.Body != nil:
		c, err = s.opt.Documents.EditComment(r.Context(), caller(r), id, commentID, *req.Body)
	case req.Resolved != nil:
		c, err = s.opt.Documents.ResolveComment(r.Context(), caller(r), id, commentID, *req.Resolved)
	default:
		writeError(w, http.StatusBadRequest, "bad_request", "change the body or resolved")
		return
	}
	s.writeComment(w, r, http.StatusOK, c, err)
}

// DeleteDocumentComment implements gen.ServerInterface.
func (s *Server) DeleteDocumentComment(w http.ResponseWriter, r *http.Request, id gen.DocumentID, commentID gen.CommentID) {
	if !s.documentsReady(w) {
		return
	}
	if err := s.opt.Documents.DeleteComment(r.Context(), caller(r), id, commentID); err != nil {
		s.documentError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// DocumentPresence implements gen.ServerInterface.
func (s *Server) DocumentPresence(w http.ResponseWriter, r *http.Request, id gen.DocumentID) {
	if !s.documentsReady(w) {
		return
	}
	var req gen.PresenceInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	p, err := s.opt.Documents.Here(r.Context(), caller(r), id, req.Leaving != nil && *req.Leaving)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toPresence(p))
}

// publicGate starts a public request: the module is on, the address is
// within its rate, and the answer stays out of search engines.
func (s *Server) publicGate(w http.ResponseWriter, r *http.Request) bool {
	publicHeaders(w)
	return s.documentsReady(w) && s.limit(w, r, s.publicLimiter, "too many requests, try again later")
}

// guest returns the guest a public request comes from, or answers why not.
func (s *Server) guest(w http.ResponseWriter, r *http.Request, token string, guestToken *gen.GuestToken) (documents.Guest, bool) {
	tok := ""
	if guestToken != nil {
		tok = *guestToken
	}
	g, err := s.opt.Documents.Guest(domain.System(r.Context()), token, tok)
	if err != nil {
		s.documentError(w, r, err)
		return g, false
	}
	return g, true
}

// GetPublicDocumentInfo implements gen.ServerInterface.
func (s *Server) GetPublicDocumentInfo(w http.ResponseWriter, r *http.Request, token gen.PublicToken) {
	if !s.publicGate(w, r) {
		return
	}
	info, err := s.opt.Documents.Info(domain.System(r.Context()), token)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	out := gen.PublicDocumentInfo{Kind: gen.DocumentKind(info.Kind), Title: info.Title}
	if s.opt.Google != nil && s.opt.Google.ClientID != "" {
		out.GoogleClientId = &s.opt.Google.ClientID
	}
	writeJSON(w, http.StatusOK, out)
}

// JoinPublicDocument implements gen.ServerInterface.
func (s *Server) JoinPublicDocument(w http.ResponseWriter, r *http.Request, token gen.PublicToken) {
	if !s.publicGate(w, r) {
		return
	}
	var req gen.GuestJoin
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	g := domain.DocumentGuest{Via: domain.GuestByName}
	switch {
	case req.GoogleCredential != nil && *req.GoogleCredential != "":
		if s.opt.Google == nil {
			writeError(w, http.StatusBadRequest, "bad_request", "Google sign-in is off on this server; type your name")
			return
		}
		id, err := s.opt.Google.Verifier.Verify(r.Context(), *req.GoogleCredential)
		if errors.Is(err, google.ErrInvalid) {
			writeError(w, http.StatusBadRequest, "bad_request", "Google did not confirm who you are; try again or type your name")
			return
		}
		if err != nil {
			s.writeInternal(w, r, err)
			return
		}
		g.Name, g.Email, g.Via = id.Name, id.Email, domain.GuestByGoogle
		if strings.TrimSpace(g.Name) == "" {
			g.Name, _, _ = strings.Cut(g.Email, "@")
		}
	case req.Name != nil && strings.TrimSpace(*req.Name) != "":
		g.Name = *req.Name
	default:
		// Signed in to agnts: their account says who they are.
		var u domain.User
		err := domain.ErrNotFound
		if s.opt.Auth != nil {
			u, err = s.opt.Auth.Authenticate(r.Context(), sessionToken(r))
		}
		if err != nil || u.ID == 0 {
			writeError(w, http.StatusBadRequest, "bad_request", "type your name or continue with Google")
			return
		}
		g.Name, g.Email, g.Via, g.UserID = u.DisplayName, u.Email, domain.GuestByAccount, &u.ID
		if strings.TrimSpace(g.Name) == "" {
			g.Name = u.Username
		}
	}
	g, tok, err := s.opt.Documents.Join(domain.System(r.Context()), token, g)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, gen.GuestSession{Token: tok, Name: g.Name, Via: gen.GuestSessionVia(g.Via)})
}

// ListPublicDocumentComments implements gen.ServerInterface.
func (s *Server) ListPublicDocumentComments(w http.ResponseWriter, r *http.Request, token gen.PublicToken, params gen.ListPublicDocumentCommentsParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	cs, err := s.opt.Documents.GuestComments(g)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toComments(cs))
}

// AddPublicDocumentComment implements gen.ServerInterface.
func (s *Server) AddPublicDocumentComment(w http.ResponseWriter, r *http.Request, token gen.PublicToken, params gen.AddPublicDocumentCommentParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	var req gen.DocumentCommentInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	c, err := s.opt.Documents.GuestAddComment(g, fromCommentInput(req))
	s.writeComment(w, r, http.StatusCreated, c, err)
}

// UpdatePublicDocumentComment implements gen.ServerInterface.
func (s *Server) UpdatePublicDocumentComment(w http.ResponseWriter, r *http.Request, token gen.PublicToken, commentID gen.CommentID, params gen.UpdatePublicDocumentCommentParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	var req gen.DocumentCommentPatch
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var c documents.CommentView
	var err error
	switch {
	case req.Body != nil:
		c, err = s.opt.Documents.GuestEditComment(g, commentID, *req.Body)
	case req.Resolved != nil:
		c, err = s.opt.Documents.GuestResolveComment(g, commentID, *req.Resolved)
	default:
		writeError(w, http.StatusBadRequest, "bad_request", "change the body or resolved")
		return
	}
	s.writeComment(w, r, http.StatusOK, c, err)
}

// DeletePublicDocumentComment implements gen.ServerInterface.
func (s *Server) DeletePublicDocumentComment(w http.ResponseWriter, r *http.Request, token gen.PublicToken, commentID gen.CommentID, params gen.DeletePublicDocumentCommentParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	if err := s.opt.Documents.GuestDeleteComment(g, commentID); err != nil {
		s.documentError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// PublicDocumentPresence implements gen.ServerInterface.
func (s *Server) PublicDocumentPresence(w http.ResponseWriter, r *http.Request, token gen.PublicToken, params gen.PublicDocumentPresenceParams) {
	if !s.publicGate(w, r) {
		return
	}
	g, ok := s.guest(w, r, token, params.XGuestToken)
	if !ok {
		return
	}
	var req gen.PresenceInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	p, err := s.opt.Documents.GuestHere(g, req.Leaving != nil && *req.Leaving)
	if err != nil {
		s.documentError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toPresence(p))
}
