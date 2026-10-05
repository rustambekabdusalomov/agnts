package httpapi

import (
	"errors"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"hiro/internal/auth"
	"hiro/internal/domain"
	"hiro/internal/httpapi/gen"
)

var codeRe = regexp.MustCompile(`^[0-9]{6}$`)

// Login implements gen.ServerInterface.
func (s *Server) Login(w http.ResponseWriter, r *http.Request) {
	if ok, wait := s.loginLimiter.allow(r.RemoteAddr, time.Now()); !ok {
		w.Header().Set("Retry-After", strconv.Itoa(int(wait.Seconds())+1))
		writeError(w, http.StatusTooManyRequests, "rate_limited", "too many sign-in attempts, try again later")
		return
	}

	var req gen.LoginRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if req.Username == "" || req.Password == "" || !codeRe.MatchString(req.Code) ||
		(req.Client != gen.LoginRequestClientWeb && req.Client != gen.LoginRequestClientMobile) {
		writeError(w, http.StatusBadRequest, "bad_request", "username, password, a 6-digit code and client are required")
		return
	}

	token, sess, u, err := s.opt.Auth.Login(r.Context(), auth.LoginInput{
		Username:  req.Username,
		Password:  req.Password,
		Code:      req.Code,
		Client:    domain.Client(req.Client),
		UserAgent: r.UserAgent(),
		IP:        r.RemoteAddr,
	})
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

	resp := gen.LoginResponse{User: toUser(u), ExpiresAt: sess.ExpiresAt}
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

// GetMe implements gen.ServerInterface.
func (s *Server) GetMe(w http.ResponseWriter, r *http.Request) {
	u, ok := userFrom(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized", "sign in required")
		return
	}
	writeJSON(w, http.StatusOK, toUser(u))
}

func (s *Server) sessionCookie(value string, expires time.Time) *http.Cookie {
	//nolint:gosec // G124: Secure comes from HIRO_COOKIE_SECURE, false only for local http dev
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
	return gen.User{Id: u.ID, Username: u.Username}
}
