package httpapi

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"time"

	"agnts/internal/accounts"
	"agnts/internal/auth"
	"agnts/internal/domain"
	"agnts/internal/google"
)

// GoogleSignIn is "Continue with Google" on the website.
type GoogleSignIn struct {
	Verifier interface {
		Verify(ctx context.Context, credential string) (google.Identity, error)
	}
	Accounts interface {
		SignInWithGoogle(ctx context.Context, in accounts.GoogleInput) (accounts.GoogleResult, error)
	}
	// ClientID is the OAuth web client id, for the admin panel's button.
	ClientID string
	// SiteURL is the website with the button: its form posts from there,
	// and a sign-in that fails there goes back to it.
	SiteURL *url.URL
}

// Reasons a Google sign-in went back to the website (its ?signin= value).
const (
	signinFailed      = "failed"       // Google did not vouch for the person
	signinClosed      = "closed"       // sign-up is by invitation here
	signinRateLimited = "rate_limited" // too many attempts from this address
	signinUnavailable = "unavailable"  // Google or the server had a problem
	signinInvite      = "invite"       // the invite is invalid, used, expired or for another address
	signinAdmin       = "admin"        // an Admin account: it signs in with its password
)

// googleSignIn takes the ID token the website's Google button posts as a
// form (a top-level navigation, so the session cookie is set on this
// origin), signs the person in, registering a new account as a solo
// developer, and opens the admin panel, which shows their workspace.
func (s *Server) googleSignIn(w http.ResponseWriter, r *http.Request) {
	g := s.opt.Google
	// Only the website and the admin panel post here: another site must
	// not sign a visitor into an account of its choosing.
	if o := r.Header.Get("Origin"); o == "" || o != urlOrigin(g.SiteURL) && o != urlOrigin(s.opt.PublicURL) {
		writeError(w, http.StatusForbidden, "forbidden", "cross-origin request rejected")
		return
	}
	if ok, _ := s.loginLimiter.allow(r.RemoteAddr, time.Now()); !ok {
		s.backToSite(w, r, signinRateLimited)
		return
	}
	if err := r.ParseForm(); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "a form with the Google credential is required")
		return
	}
	id, err := g.Verifier.Verify(r.Context(), r.PostForm.Get("credential"))
	if errors.Is(err, google.ErrInvalid) {
		s.opt.Log.Warn("google sign-in rejected", "ip", r.RemoteAddr)
		s.backToSite(w, r, signinFailed)
		return
	}
	if err != nil {
		s.opt.Log.Error("google sign-in", "err", err)
		s.backToSite(w, r, signinUnavailable)
		return
	}
	invite := r.PostForm.Get("invite")
	res, err := g.Accounts.SignInWithGoogle(r.Context(), accounts.GoogleInput{
		Email: id.Email, DisplayName: id.Name, Invite: invite, Client: domain.ClientWeb, UserAgent: r.UserAgent(), IP: r.RemoteAddr,
	})
	var inv *auth.InvalidError
	switch {
	case errors.Is(err, domain.ErrForbidden):
		s.backToSite(w, r, signinClosed)
		return
	case errors.Is(err, auth.ErrAdminUsesPassword):
		s.backToSite(w, r, signinAdmin)
		return
	case invite != "" && (errors.As(err, &inv) || errors.Is(err, domain.ErrNotFound) || errors.Is(err, domain.ErrMemberLimit)):
		s.backToSite(w, r, signinInvite)
		return
	case errors.As(err, &inv):
		s.backToSite(w, r, signinFailed)
		return
	case err != nil:
		s.opt.Log.Error("google sign-in", "err", err)
		s.backToSite(w, r, signinUnavailable)
		return
	}
	s.opt.Log.Info("signed in with Google", "user_id", res.User.ID, "ip", r.RemoteAddr)
	http.SetCookie(w, s.sessionCookie(res.Token, res.Session.ExpiresAt))
	open := s.opt.PublicURL.JoinPath("/")
	if res.Workspace != "" {
		open = s.opt.PublicURL.JoinPath("/w", res.Workspace, "dashboard") // the workspace they were invited to
	}
	http.Redirect(w, r, open.String(), http.StatusSeeOther)
}

// backToSite sends a failed Google sign-in back to the page it started on
// (the website, or the admin panel's sign-in page), which explains reason.
func (s *Server) backToSite(w http.ResponseWriter, r *http.Request, reason string) {
	site := s.opt.PublicURL.JoinPath("/login")
	if s.opt.Google.SiteURL != nil && r.Header.Get("Origin") != urlOrigin(s.opt.PublicURL) {
		site = s.opt.Google.SiteURL.JoinPath("/")
	}
	site.RawQuery = url.Values{"signin": {reason}}.Encode()
	http.Redirect(w, r, site.String(), http.StatusSeeOther)
}

// urlOrigin is u's scheme and host, as browsers send them in Origin.
func urlOrigin(u *url.URL) string {
	if u == nil {
		return ""
	}
	return u.Scheme + "://" + u.Host
}
