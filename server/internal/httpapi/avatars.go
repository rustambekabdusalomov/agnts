package httpapi

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

// MaxAvatarBytes is the largest profile picture (the admin panel uploads a
// 256 px square, a few dozen KB).
const MaxAvatarBytes = 512 << 10

// avatarTypes are the pictures accepted, by their sniffed type: ones
// browsers draw in place and that run no scripts (no SVG).
var avatarTypes = map[string]bool{"image/png": true, "image/jpeg": true, "image/webp": true, "image/gif": true}

// UploadAvatar implements gen.ServerInterface.
func (s *Server) UploadAvatar(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	f, _, err := r.FormFile("file")
	if err != nil {
		var tooBig *http.MaxBytesError
		if errors.As(err, &tooBig) {
			writeError(w, http.StatusRequestEntityTooLarge, "too_large", fmt.Sprintf("a picture can be %d KB at most", MaxAvatarBytes>>10))
			return
		}
		writeError(w, http.StatusBadRequest, "bad_request", "send the picture as multipart/form-data in the field \"file\"")
		return
	}
	defer func() { _ = f.Close() }()
	data, err := io.ReadAll(io.LimitReader(f, MaxAvatarBytes+1))
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "could not read the picture")
		return
	}
	if len(data) > MaxAvatarBytes {
		writeError(w, http.StatusRequestEntityTooLarge, "too_large", fmt.Sprintf("a picture can be %d KB at most", MaxAvatarBytes>>10))
		return
	}
	ct, _, _ := strings.Cut(http.DetectContentType(data), ";")
	if !avatarTypes[ct] {
		writeError(w, http.StatusBadRequest, "bad_request", "a profile picture is a PNG, JPEG, WebP or GIF image")
		return
	}
	out, err := s.opt.Users.SetAvatar(r.Context(), u.ID, ct, data)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.userView(r.Context(), out, true))
}

// DeleteAvatar implements gen.ServerInterface.
func (s *Server) DeleteAvatar(w http.ResponseWriter, r *http.Request) {
	u, _ := userFrom(r.Context())
	out, err := s.opt.Users.DeleteAvatar(r.Context(), u.ID)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.userView(r.Context(), out, true))
}

// GetUserAvatar implements gen.ServerInterface. Any signed-in person may
// load a picture: it shows beside the name wherever the name does. The URL
// carries the version, so a versioned request is cached for good.
func (s *Server) GetUserAvatar(w http.ResponseWriter, r *http.Request, id int64, p gen.GetUserAvatarParams) {
	ct, data, err := s.opt.Users.Avatar(r.Context(), id)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no picture")
			return
		}
		s.writeInternal(w, r, err)
		return
	}
	if !avatarTypes[ct] {
		ct = "application/octet-stream"
	}
	w.Header().Set("Content-Type", ct)
	w.Header().Set("Content-Security-Policy", "default-src 'none'; sandbox")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	if p.V != nil {
		w.Header().Set("Cache-Control", "private, max-age=31536000, immutable")
	} else {
		w.Header().Set("Cache-Control", "private, no-cache")
	}
	if _, err := w.Write(data); err != nil {
		s.opt.Log.Debug("send avatar", "err", err)
	}
}
