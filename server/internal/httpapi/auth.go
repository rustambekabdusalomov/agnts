package httpapi

import (
	"context"
	"errors"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"

	"agnts/internal/accounts"
	"agnts/internal/auth"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

var codeRe = regexp.MustCompile(`^[0-9]{6}$`)

// useGoogle answers a password sign-in or sign-up by someone who is not an
// Admin, when only Admins use passwords.
const useGoogle = "sign in with Google: passwords are for Admins only here"

// UserStore reads and changes accounts.
type UserStore interface {
	ByID(ctx context.Context, id int64) (domain.User, error)
	List(ctx context.Context) ([]domain.User, error)
	SetAdmin(ctx context.Context, id int64, admin bool) error
	SetProfile(ctx context.Context, id int64, displayName, email string) (domain.User, error)
	Count(ctx context.Context) (int, error)
	LastSignIns(ctx context.Context) (map[int64]time.Time, error)
}

// Login implements gen.ServerInterface.
func (s *Server) Login(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, r, s.loginLimiter, "too many sign-in attempts, try again later") {
		return
	}
	var req gen.LoginRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	code := ""
	if req.Code != nil {
		code = *req.Code
	}
	if req.Username == "" || req.Password == "" || (code != "" && !codeRe.MatchString(code)) ||
		(req.Client != gen.LoginRequestClientWeb && req.Client != gen.LoginRequestClientMobile) {
		writeError(w, http.StatusBadRequest, "bad_request", "username or email, password and client are required; a code has 6 digits")
		return
	}

	token, sess, u, err := s.opt.Auth.Login(r.Context(), auth.LoginInput{
		Username:   strings.TrimSpace(req.Username),
		Password:   req.Password,
		Code:       code,
		TOTPSecret: deref(req.TotpSecret),
		Client:     domain.Client(req.Client),
		UserAgent:  r.UserAgent(),
		IP:         r.RemoteAddr,
	})
	if errors.Is(err, auth.ErrCodeRequired) {
		writeError(w, http.StatusUnauthorized, "code_required", "enter the 6-digit code from your authenticator app")
		return
	}
	if errors.Is(err, auth.ErrTOTPSetupRequired) {
		writeError(w, http.StatusUnauthorized, "totp_setup_required", "Admins sign in with two-factor codes: set it up to continue")
		return
	}
	if errors.Is(err, auth.ErrUseGoogle) {
		writeError(w, http.StatusForbidden, "use_google", useGoogle)
		return
	}
	if errors.Is(err, domain.ErrUnauthorized) {
		s.opt.Log.Warn("sign-in failed", "username", req.Username, "ip", r.RemoteAddr)
		writeError(w, http.StatusUnauthorized, "unauthorized", "wrong username, password or code")
		return
	}
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.opt.Log.Info("signed in", "user_id", u.ID, "client", sess.Client, "ip", r.RemoteAddr)
	s.writeSession(w, r, token, sess, u)
}

// BeginLoginTotp implements gen.ServerInterface.
func (s *Server) BeginLoginTotp(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, r, s.loginLimiter, "too many sign-in attempts, try again later") {
		return
	}
	var req gen.BeginLoginTotpJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	e, err := s.opt.Auth.BeginAdminSetup(r.Context(), strings.TrimSpace(req.Username), req.Password)
	if errors.Is(err, domain.ErrUnauthorized) {
		writeError(w, http.StatusUnauthorized, "unauthorized", "wrong username or password")
		return
	}
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"secret": e.Secret, "url": e.URL})
}

// limit applies an IP rate limiter, answering 429 when it says no.
func (s *Server) limit(w http.ResponseWriter, r *http.Request, l *ipLimiter, msg string) bool {
	if ok, wait := l.allow(r.RemoteAddr, time.Now()); !ok {
		w.Header().Set("Retry-After", strconv.Itoa(int(wait.Seconds())+1))
		writeError(w, http.StatusTooManyRequests, "rate_limited", msg)
		return false
	}
	return true
}

// writeSession answers a sign-in: the cookie for the web, the token in the
// body for mobile.
func (s *Server) writeSession(w http.ResponseWriter, r *http.Request, token string, sess domain.Session, u domain.User) {
	resp := gen.LoginResponse{User: s.userView(r.Context(), u, true), ExpiresAt: sess.ExpiresAt}
	if sess.Client == domain.ClientMobile {
		resp.Token = &token
	} else {
		http.SetCookie(w, s.sessionCookie(token, sess.ExpiresAt))
	}
	writeJSON(w, http.StatusOK, resp)
}

// Logout implements gen.ServerInterface.
func (s *Server) Logout(w http.ResponseWriter, r *http.Request) {
	if err := s.opt.Auth.Logout(r.Context(), sessionToken(r)); err != nil {
		s.writeInternal(w, r, err)
		return
	}
	http.SetCookie(w, s.sessionCookie("", time.Unix(0, 0)))
	w.WriteHeader(http.StatusNoContent)
}

// GetMe implements gen.ServerInterface: the user with their workspaces.
func (s *Server) GetMe(w http.ResponseWriter, r *http.Request) {
	u, ok := userFrom(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized", "sign in required")
		return
	}
	writeJSON(w, http.StatusOK, s.userView(r.Context(), u, true))
}

func (s *Server) sessionCookie(value string, expires time.Time) *http.Cookie {
	//nolint:gosec // G124: Secure comes from AGNTS_COOKIE_SECURE, false only for local http dev
	c := &http.Cookie{
		Name:     SessionCookie,
		Value:    value,
		Path:     "/",
		Expires:  expires,
		HttpOnly: true,
		Secure:   s.opt.CookieSecure,
		SameSite: http.SameSiteStrictMode,
	}
	if value == "" {
		c.MaxAge = -1
	}
	return c
}

func toUser(u domain.User) gen.User {
	out := gen.User{Id: u.ID, Username: u.Username}
	verified, admin, totp := u.EmailVerifiedAt != nil, u.IsAdmin, u.HasTOTP()
	out.EmailVerified, out.IsAdmin, out.HasTotp = &verified, &admin, &totp
	if u.Email != "" {
		e := u.Email
		out.Email = &e
	}
	if u.DisplayName != "" {
		n := u.DisplayName
		out.DisplayName = &n
	}
	if !u.CreatedAt.IsZero() {
		t := u.CreatedAt
		out.CreatedAt = &t
	}
	return out
}

// userView is a user with, when withWorkspaces, the workspaces they are in
// and the one they opened last.
func (s *Server) userView(ctx context.Context, u domain.User, withWorkspaces bool) gen.User {
	out := toUser(u)
	if !withWorkspaces || s.opt.Workspaces == nil {
		return out
	}
	ws, err := s.opt.Workspaces.Of(ctx, u.ID)
	if err != nil {
		return out
	}
	list := make([]gen.WorkspaceSummary, 0, len(ws))
	for _, m := range ws {
		list = append(list, toWorkspaceSummary(m))
		if u.LastWorkspaceID != nil && m.ID == *u.LastWorkspaceID {
			slug := m.Slug
			out.LastWorkspace = &slug
		}
	}
	if out.LastWorkspace == nil && len(ws) > 0 {
		slug := ws[0].Slug
		out.LastWorkspace = &slug
	}
	out.Workspaces = &list
	return out
}

// authError maps account errors to statuses.
func (s *Server) authError(w http.ResponseWriter, r *http.Request, err error) {
	var inv *auth.InvalidError
	switch {
	case errors.As(err, &inv):
		writeError(w, http.StatusBadRequest, "bad_request", inv.Msg)
	case errors.Is(err, auth.ErrUseGoogle):
		writeError(w, http.StatusForbidden, "use_google", useGoogle)
	case errors.Is(err, domain.ErrForbidden):
		writeError(w, http.StatusForbidden, "forbidden", "sign-up is by invitation on this server: ask a workspace owner for an invite link")
	case errors.Is(err, domain.ErrMemberLimit):
		writeError(w, http.StatusConflict, "member_limit", err.Error())
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", strings.TrimPrefix(err.Error(), "conflict: "))
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "not found")
	case errors.Is(err, domain.ErrLastOwner):
		writeError(w, http.StatusConflict, "owner", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func (s *Server) accountsOff(w http.ResponseWriter) bool {
	if s.opt.Accounts == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return true
	}
	return false
}

// GetSignupInfo implements gen.ServerInterface.
func (s *Server) GetSignupInfo(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) {
		return
	}
	info, err := s.opt.Accounts.Signup(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.SignupInfo{Open: info.Open, FirstUser: info.FirstUser, EmailEnabled: info.EmailEnabled, PasswordSignup: &info.PasswordSignup}
	if g := s.opt.Google; g != nil && g.ClientID != "" {
		out.GoogleClientId = &g.ClientID
	}
	writeJSON(w, http.StatusOK, out)
}

// Register implements gen.ServerInterface.
func (s *Server) Register(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) || !s.limit(w, r, s.mailLimiter, "too many sign-ups from here, try again later") {
		return
	}
	var req gen.RegisterRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := accounts.RegisterInput{RegisterInput: auth.RegisterInput{Email: req.Email, Password: req.Password,
		Client: domain.Client(req.Client), UserAgent: r.UserAgent(), IP: r.RemoteAddr}}
	in.Username, in.DisplayName = deref(req.Username), deref(req.DisplayName)
	in.WorkspaceName, in.Invite = deref(req.WorkspaceName), deref(req.Invite)
	token, sess, u, err := s.opt.Accounts.Register(r.Context(), in)
	if err != nil {
		s.authError(w, r, err)
		return
	}
	s.opt.Log.Info("registered", "user_id", u.ID, "ip", r.RemoteAddr)
	s.writeSession(w, r, token, sess, u)
}

func deref(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

// VerifyEmail implements gen.ServerInterface.
func (s *Server) VerifyEmail(w http.ResponseWriter, r *http.Request) {
	var req gen.TokenRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if _, err := s.opt.Auth.VerifyEmail(r.Context(), req.Token); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ForgotPassword implements gen.ServerInterface.
func (s *Server) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) || !s.limit(w, r, s.mailLimiter, "too many requests from here, try again later") {
		return
	}
	var req gen.ForgotPasswordJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Accounts.ForgotPassword(r.Context(), req.Email); err != nil {
		s.opt.Log.Warn("password reset email", "err", err)
	}
	w.WriteHeader(http.StatusNoContent)
}

// ResetPassword implements gen.ServerInterface.
func (s *Server) ResetPassword(w http.ResponseWriter, r *http.Request) {
	var req gen.ResetPasswordJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Auth.ResetPassword(r.Context(), req.Token, req.Password); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// UpdateProfile implements gen.ServerInterface.
func (s *Server) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	var req gen.UpdateProfileJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	name, email := u.DisplayName, u.Email
	if req.DisplayName != nil {
		name = strings.TrimSpace(*req.DisplayName)
	}
	if req.Email != nil {
		email = strings.TrimSpace(*req.Email)
		if email != "" && !auth.ValidEmail(email) {
			writeError(w, http.StatusBadRequest, "bad_request", "enter a valid email address")
			return
		}
	}
	out, err := s.opt.Users.SetProfile(r.Context(), u.ID, name, email)
	if errors.Is(err, domain.ErrConflict) {
		writeError(w, http.StatusConflict, "conflict", "another account uses this email")
		return
	}
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	if !strings.EqualFold(email, u.Email) && email != "" && s.opt.Accounts != nil {
		if err := s.opt.Accounts.SendVerification(r.Context(), out); err != nil {
			s.opt.Log.Warn("send verification email", "user", u.ID, "err", err)
		}
	}
	writeJSON(w, http.StatusOK, s.userView(r.Context(), out, true))
}

// ChangePassword implements gen.ServerInterface.
func (s *Server) ChangePassword(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	var req gen.ChangePasswordJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Auth.ChangePassword(r.Context(), u, req.Current, req.Password, sessionToken(r)); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ResendVerification implements gen.ServerInterface.
func (s *Server) ResendVerification(w http.ResponseWriter, r *http.Request) {
	if s.accountsOff(w) || !s.limit(w, r, s.mailLimiter, "too many emails, try again later") {
		return
	}
	u, _ := userFrom(r.Context())
	if err := s.opt.Accounts.SendVerification(r.Context(), u); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// BeginTotp implements gen.ServerInterface.
func (s *Server) BeginTotp(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	e, err := s.opt.Auth.BeginEnrollment(u.Username)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"secret": e.Secret, "url": e.URL})
}

// ConfirmTotp implements gen.ServerInterface.
func (s *Server) ConfirmTotp(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	var req gen.ConfirmTotpJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Auth.ConfirmTOTP(r.Context(), u, req.Secret, req.Code); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// DisableTotp implements gen.ServerInterface.
func (s *Server) DisableTotp(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	var req gen.DisableTotpJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Auth.DisableTOTP(r.Context(), u, req.Password, deref(req.Code)); err != nil {
		s.authError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
