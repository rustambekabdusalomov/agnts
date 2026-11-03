package httpapi

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/httpapi/gen"
	"agnts/internal/meetings"
)

// uploadReadTime is how long an uploaded recording may take to arrive:
// the server's read timeout is for small requests.
const uploadReadTime = 3 * time.Hour

// isMeetingUpload reports whether r uploads a meeting's recording, which
// bodyLimit leaves to the handler (its limit is the service's).
func isMeetingUpload(r *http.Request) bool {
	return r.Method == http.MethodPost && strings.HasSuffix(r.URL.Path, "/uploads") && strings.Contains(r.URL.Path, "/meetings/")
}

// UploadMeetingRecording implements gen.ServerInterface. The multipart
// body is read as it comes: the fields first, then the file, streamed to
// disk.
func (s *Server) UploadMeetingRecording(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	m := s.opt.Meetings
	if !m.UploadsReady() {
		writeError(w, http.StatusNotImplemented, "unsupported", "uploaded recordings are not available on this server")
		return
	}
	_ = http.NewResponseController(w).SetReadDeadline(time.Now().Add(uploadReadTime))
	r.Body = http.MaxBytesReader(w, r.Body, m.MaxUploadBytes()+1<<20)
	tooBig := func() {
		writeError(w, http.StatusRequestEntityTooLarge, "too_large", fmt.Sprintf("a recording can be %d MB at most", m.MaxUploadBytes()>>20))
	}
	mr, err := r.MultipartReader()
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "send the recording as multipart/form-data in the field \"file\"")
		return
	}
	var u meetings.Upload
	for {
		part, err := mr.NextPart()
		if errors.Is(err, io.EOF) {
			break
		}
		var mb *http.MaxBytesError
		if errors.As(err, &mb) {
			tooBig()
			return
		}
		if err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", "the form could not be read")
			return
		}
		switch part.FormName() {
		case "startedAt":
			v, _ := io.ReadAll(io.LimitReader(part, 100))
			if u.StartedAt, err = time.Parse(time.RFC3339, strings.TrimSpace(string(v))); err != nil {
				writeError(w, http.StatusBadRequest, "bad_request", "startedAt is a date and time (RFC 3339)")
				return
			}
		case "people":
			v, _ := io.ReadAll(io.LimitReader(part, 4096))
			for _, f := range strings.Split(string(v), ",") {
				if f = strings.TrimSpace(f); f == "" {
					continue
				}
				n, err := strconv.ParseInt(f, 10, 64)
				if err != nil {
					writeError(w, http.StatusBadRequest, "bad_request", "people are member ids, comma-separated")
					return
				}
				u.People = append(u.People, n)
			}
		case "file":
			u.Name, u.Body = part.FileName(), part
			x, err := m.Upload(r.Context(), meetingCaller(r), id, u)
			if errors.As(err, &mb) || errors.Is(err, meetings.ErrTooBig) {
				tooBig()
				return
			}
			if err != nil {
				s.meetingError(w, r, err)
				return
			}
			writeJSON(w, http.StatusCreated, toSessionBrief(x))
			return
		}
	}
	writeError(w, http.StatusBadRequest, "bad_request", "send the recording in the field \"file\"")
}
