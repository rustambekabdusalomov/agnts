package httpapi

import (
	"encoding/json"
	"net/http"
	"net/mail"
	"strings"
	"unicode/utf8"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// connectorRequestBody is the website's "Request a connector" form.
type connectorRequestBody struct {
	Tool    string `json:"tool"`
	Link    string `json:"link"`
	Hosting string `json:"hosting"` // "", "cloud" or "self-hosted"
	Usage   string `json:"usage"`
	Name    string `json:"name"`
	Email   string `json:"email"`
	// Website is a field people never see: a bot that fills it in is
	// answered as if it worked, and nothing is kept.
	Website string `json:"website"`
}

// siteCORS answers the website's origin, and only it.
func (s *Server) siteCORS(w http.ResponseWriter, r *http.Request) bool {
	site := urlOrigin(s.opt.SiteURL)
	w.Header().Add("Vary", "Origin")
	if r.Header.Get("Origin") != site {
		writeError(w, http.StatusForbidden, "forbidden", "cross-origin request rejected")
		return false
	}
	w.Header().Set("Access-Control-Allow-Origin", site)
	return true
}

func (s *Server) connectorRequestPreflight(w http.ResponseWriter, r *http.Request) {
	if !s.siteCORS(w, r) {
		return
	}
	w.Header().Set("Access-Control-Allow-Methods", "POST")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Max-Age", "600")
	w.WriteHeader(http.StatusNoContent)
}

// connectorRequest keeps a visitor's request for a connector agnts does not
// have yet. The Admins read it with the feedback.
func (s *Server) connectorRequest(w http.ResponseWriter, r *http.Request) {
	if !s.siteCORS(w, r) || !s.limit(w, r, s.feedbackLimiter, "you sent a lot of requests just now; try again in a few minutes") {
		return
	}
	var req connectorRequestBody
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "a JSON body is required")
		return
	}
	if req.Website != "" {
		writeJSON(w, http.StatusCreated, map[string]bool{"ok": true})
		return
	}
	tool, link, usage := strings.TrimSpace(req.Tool), strings.TrimSpace(req.Link), strings.TrimSpace(req.Usage)
	name, email := strings.TrimSpace(req.Name), strings.TrimSpace(req.Email)
	addr, err := mail.ParseAddress(email)
	switch {
	case tool == "" || utf8.RuneCountInString(tool) > 80:
		writeError(w, http.StatusBadRequest, "bad_request", "name the tool (up to 80 characters)")
		return
	case err != nil || addr.Address != email || len(email) > 254:
		writeError(w, http.StatusBadRequest, "bad_request", "an email address to reply to is required")
		return
	case utf8.RuneCountInString(link) > 300 || utf8.RuneCountInString(usage) > 3000 || utf8.RuneCountInString(name) > 80:
		writeError(w, http.StatusBadRequest, "bad_request", "the link, the description or the name is too long")
		return
	case req.Hosting != "" && req.Hosting != "cloud" && req.Hosting != "self-hosted":
		writeError(w, http.StatusBadRequest, "bad_request", "hosting is cloud or self-hosted")
		return
	}
	var desc strings.Builder
	for _, l := range [][2]string{{"Link", link}, {"Hosting", req.Hosting}, {"How they use it", usage}} {
		if l[1] != "" {
			desc.WriteString(l[0] + ": " + l[1] + "\n")
		}
	}
	if desc.Len() == 0 {
		desc.WriteString("No details given.")
	}
	if name == "" {
		name = "Website visitor"
	}
	f, err := s.opt.Feedback.Create(domain.System(r.Context()), postgres.Feedback{Kind: postgres.ConnectorKind,
		Sender: name, Email: email, Title: "Connector: " + tool, Description: strings.TrimSpace(desc.String())})
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.opt.Log.Info("connector requested", "feedback", f.ID, "tool", tool)
	writeJSON(w, http.StatusCreated, map[string]bool{"ok": true})
}
