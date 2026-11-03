package httpapi

import (
	"errors"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/google"
	"agnts/internal/httpapi/gen"
	"agnts/internal/meetings"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// meetingsReady answers 501 when meetings are off (no LiveKit).
func (s *Server) meetingsReady(w http.ResponseWriter) bool {
	if s.opt.Meetings == nil || !s.opt.Meetings.Ready() {
		writeError(w, http.StatusNotImplemented, "unsupported", "meetings are not set up on this server (AGNTS_LIVEKIT_URL)")
		return false
	}
	return true
}

// meetingCaller is the signed-in member acting in their workspace.
func meetingCaller(r *http.Request) meetings.Caller {
	c := caller(r)
	return meetings.Caller{WorkspaceID: c.WorkspaceID, UserID: c.UserID, Role: c.Role}
}

// meetingError translates the module's errors.
func (s *Server) meetingError(w http.ResponseWriter, r *http.Request, err error) {
	var refused *meetings.RefusedError
	switch {
	case errors.As(err, &refused):
		writeError(w, http.StatusForbidden, refused.Reason, refused.Error())
	case errors.Is(err, meetings.ErrSeat):
		writeError(w, http.StatusUnauthorized, "not_in_call", err.Error())
	case errors.Is(err, meetings.ErrUnavailable):
		writeError(w, http.StatusNotImplemented, "unsupported", err.Error())
	case errors.Is(err, meetings.ErrTooMany), errors.Is(err, orchestrator.ErrPlanLimit):
		w.Header().Set("Retry-After", "30")
		writeError(w, http.StatusTooManyRequests, "rate_limited", err.Error())
	case errors.Is(err, domain.ErrMeetingInvalid), errors.Is(err, orchestrator.ErrInvalid), errors.Is(err, domain.ErrDocInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such meeting")
	case errors.Is(err, domain.ErrForbidden):
		writeError(w, http.StatusForbidden, "forbidden", err.Error())
	case errors.Is(err, domain.ErrConflict), errors.Is(err, documents.ErrBusy):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

func (s *Server) toMeeting(m domain.Meeting) gen.Meeting {
	out := gen.Meeting{Id: m.ID, Code: domain.FormatMeetingCode(m.Code), Link: s.opt.Meetings.Link(m.Code), Title: m.Title, Description: m.Description,
		HostId: m.HostID, HostName: m.HostName, Kind: gen.MeetingKind(m.Kind), StartsAt: m.StartsAt, EndsAt: m.EndsAt(), DurationMin: m.DurationMin,
		TimeZone: m.TimeZone, Access: gen.MeetingAccess(m.Access), Guests: gen.MeetingGuests(m.Guests), Locked: m.Locked, AutoRecord: m.AutoRecord,
		AutoNotes: m.AutoNotes, Language: gen.MeetingLanguage(m.Language), CohostIds: m.CohostIDs, CancelledAt: m.CancelledAt, CreatedAt: m.CreatedAt}
	if out.CohostIds == nil {
		out.CohostIds = []int64{}
	}
	if x := m.Live; x != nil {
		out.Live = &gen.MeetingLive{SessionId: x.ID, StartedAt: x.StartedAt, InCall: m.InCall, Recording: x.Recording, Notes: x.NotesOn}
	}
	return out
}

// meetingDetail is gen.MeetingDetail: the meeting and, beside it, its
// invitees and what the caller may do (the spec's allOf).
type meetingDetail struct {
	gen.Meeting
	Invitees  []gen.MeetingInvitee `json:"invitees"`
	MyRsvp    *string              `json:"myRsvp,omitempty"`
	CanManage bool                 `json:"canManage"`
}

func (s *Server) writeMeetingDetail(w http.ResponseWriter, r *http.Request, status int, d meetings.Detail, err error) {
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := meetingDetail{Meeting: s.toMeeting(d.Meeting), Invitees: make([]gen.MeetingInvitee, len(d.Invitees)), CanManage: d.CanManage}
	for i, inv := range d.Invitees {
		out.Invitees[i] = gen.MeetingInvitee{Id: inv.ID, UserId: inv.UserID, Email: inv.Email, Name: inv.Name, Rsvp: gen.MeetingInviteeRsvp(inv.RSVP)}
	}
	if d.MyRSVP != "" {
		out.MyRsvp = &d.MyRSVP
	}
	writeJSON(w, status, out)
}

func fromMeetingInput(in gen.MeetingInput) (domain.MeetingInput, meetings.Invites) {
	out := domain.MeetingInput{StartsAt: in.StartsAt}
	if in.Title != nil {
		out.Title = *in.Title
	}
	if in.Description != nil {
		out.Description = *in.Description
	}
	if in.Kind != nil {
		out.Kind = domain.MeetingKind(*in.Kind)
	}
	if in.DurationMin != nil {
		out.DurationMin = *in.DurationMin
	}
	if in.TimeZone != nil {
		out.TimeZone = *in.TimeZone
	}
	if in.Access != nil {
		out.Access = domain.MeetingAccess(*in.Access)
	}
	if in.Guests != nil {
		out.Guests = domain.GuestMode(*in.Guests)
	}
	if in.AutoRecord != nil {
		out.AutoRecord = *in.AutoRecord
	}
	if in.AutoNotes != nil {
		out.AutoNotes = *in.AutoNotes
	}
	if in.Language != nil {
		out.Language = string(*in.Language)
	}
	return out, fromInvites(in.Invite)
}

func fromInvites(in *gen.MeetingInvites) meetings.Invites {
	var out meetings.Invites
	if in == nil {
		return out
	}
	if in.Users != nil {
		out.Users = *in.Users
	}
	if in.Emails != nil {
		out.Emails = *in.Emails
	}
	return out
}

// ListMeetings implements gen.ServerInterface.
func (s *Server) ListMeetings(w http.ResponseWriter, r *http.Request, params gen.ListMeetingsParams) {
	if !s.meetingsReady(w) {
		return
	}
	view := postgres.ViewUpcoming
	if params.View != nil {
		view = postgres.MeetingView(*params.View)
	}
	ms, err := s.opt.Meetings.List(r.Context(), meetingCaller(r), view)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.Meeting, len(ms))
	for i, m := range ms {
		out[i] = s.toMeeting(m)
	}
	writeJSON(w, http.StatusOK, out)
}

// CreateMeeting implements gen.ServerInterface.
func (s *Server) CreateMeeting(w http.ResponseWriter, r *http.Request) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.MeetingInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in, inv := fromMeetingInput(req)
	d, err := s.opt.Meetings.Create(r.Context(), meetingCaller(r), in, inv)
	s.writeMeetingDetail(w, r, http.StatusCreated, d, err)
}

// GetMeeting implements gen.ServerInterface.
func (s *Server) GetMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	d, err := s.opt.Meetings.Get(r.Context(), meetingCaller(r), id)
	s.writeMeetingDetail(w, r, http.StatusOK, d, err)
}

// UpdateMeeting implements gen.ServerInterface.
func (s *Server) UpdateMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.MeetingInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	cur, err := s.opt.Meetings.Get(r.Context(), meetingCaller(r), id)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	// A patch: what the request leaves out stays as it is.
	m := cur.Meeting
	in := domain.MeetingInput{Title: m.Title, Description: m.Description, Kind: m.Kind, StartsAt: m.StartsAt, DurationMin: m.DurationMin,
		TimeZone: m.TimeZone, Access: m.Access, Guests: m.Guests, AutoRecord: m.AutoRecord, AutoNotes: m.AutoNotes, Language: m.Language}
	patch, _ := fromMeetingInput(req)
	if req.Title != nil {
		in.Title = patch.Title
	}
	if req.Description != nil {
		in.Description = patch.Description
	}
	if req.Kind != nil {
		in.Kind = patch.Kind
	}
	if req.StartsAt != nil {
		in.StartsAt = patch.StartsAt
	}
	if req.DurationMin != nil {
		in.DurationMin = patch.DurationMin
	}
	if req.TimeZone != nil {
		in.TimeZone = patch.TimeZone
	}
	if req.Access != nil {
		in.Access = patch.Access
	}
	if req.Guests != nil {
		in.Guests = patch.Guests
	}
	if req.AutoRecord != nil {
		in.AutoRecord = patch.AutoRecord
	}
	if req.AutoNotes != nil {
		in.AutoNotes = patch.AutoNotes
	}
	if req.Language != nil {
		in.Language = patch.Language
	}
	d, err := s.opt.Meetings.Update(r.Context(), meetingCaller(r), id, in)
	s.writeMeetingDetail(w, r, http.StatusOK, d, err)
}

// DeleteMeeting implements gen.ServerInterface.
func (s *Server) DeleteMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	if err := s.opt.Meetings.Delete(r.Context(), meetingCaller(r), id); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// CancelMeeting implements gen.ServerInterface.
func (s *Server) CancelMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	if err := s.opt.Meetings.Cancel(r.Context(), meetingCaller(r), id); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AnswerMeeting implements gen.ServerInterface.
func (s *Server) AnswerMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.AnswerMeetingJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Meetings.RSVP(r.Context(), meetingCaller(r), id, string(req.Answer)); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ChangeMeetingInvitees implements gen.ServerInterface.
func (s *Server) ChangeMeetingInvitees(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.MeetingInviteesInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var remove []int64
	if req.Remove != nil {
		remove = *req.Remove
	}
	d, err := s.opt.Meetings.SetInvitees(r.Context(), meetingCaller(r), id, fromInvites(req.Add), remove)
	s.writeMeetingDetail(w, r, http.StatusOK, d, err)
}

// SetMeetingHost implements gen.ServerInterface.
func (s *Server) SetMeetingHost(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.SetMeetingHostJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	d, err := s.opt.Meetings.SetHost(r.Context(), meetingCaller(r), id, req.UserId)
	s.writeMeetingDetail(w, r, http.StatusOK, d, err)
}

// SetMeetingCohosts implements gen.ServerInterface.
func (s *Server) SetMeetingCohosts(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.SetMeetingCohostsJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	d, err := s.opt.Meetings.SetCohosts(r.Context(), meetingCaller(r), id, req.UserIds)
	s.writeMeetingDetail(w, r, http.StatusOK, d, err)
}

// RingMeeting implements gen.ServerInterface.
func (s *Server) RingMeeting(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.RingMeetingJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if err := s.opt.Meetings.Ring(r.Context(), meetingCaller(r), id, req.UserIds); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func toSessionBrief(x domain.MeetingSession) gen.MeetingSessionBrief {
	return gen.MeetingSessionBrief{Id: x.ID, StartedAt: x.StartedAt, ConnectedAt: x.ConnectedAt, EndedAt: x.EndedAt,
		NotesStatus: gen.MeetingNotesStatus(x.NotesStatus), NotesError: x.NotesError, DocumentId: x.DocumentID}
}

// ListMeetingSessions implements gen.ServerInterface.
func (s *Server) ListMeetingSessions(w http.ResponseWriter, r *http.Request, id gen.MeetingID) {
	if !s.meetingsReady(w) {
		return
	}
	xs, err := s.opt.Meetings.Sessions(r.Context(), meetingCaller(r), id)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.MeetingSessionBrief, len(xs))
	for i, x := range xs {
		out[i] = toSessionBrief(x)
	}
	writeJSON(w, http.StatusOK, out)
}

// ListPastMeetingSessions implements gen.ServerInterface.
func (s *Server) ListPastMeetingSessions(w http.ResponseWriter, r *http.Request, params gen.ListPastMeetingSessionsParams) {
	if !s.meetingsReady(w) {
		return
	}
	limit := 30
	if params.Limit != nil {
		limit = *params.Limit
	}
	xs, err := s.opt.Meetings.Past(r.Context(), meetingCaller(r), params.Before, limit)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.MeetingSessionSummary, len(xs))
	for i, x := range xs {
		v := x.Session
		out[i] = gen.MeetingSessionSummary{Id: v.ID, MeetingId: x.Meeting.ID, MeetingCode: domain.FormatMeetingCode(x.Meeting.Code),
			MeetingTitle: x.Meeting.Title, StartedAt: v.StartedAt, EndedAt: v.EndedAt, People: x.People, Recordings: x.Recordings,
			ActionItems: x.ActionItems, NotesStatus: gen.MeetingNotesStatus(v.NotesStatus), NotesError: v.NotesError, DocumentId: v.DocumentID,
			DocumentTitle: x.DocumentName}
	}
	writeJSON(w, http.StatusOK, out)
}

func toActionItems(items []domain.ActionItem) []gen.MeetingActionItem {
	out := make([]gen.MeetingActionItem, len(items))
	for i, a := range items {
		out[i] = toActionItem(a)
	}
	return out
}

func toActionItem(a domain.ActionItem) gen.MeetingActionItem {
	out := gen.MeetingActionItem{Id: a.ID, Position: a.Position, Text: a.Text, Who: a.Who, Due: a.Due, AtMs: a.AtMS, Quote: a.Quote,
		Speaker: a.Speaker, MemberId: a.WhoUserID, MemberByHand: a.WhoSetBy != nil, Drafted: a.Drafted}
	if a.WhoUserID != nil && a.WhoName != "" {
		out.MemberName = &a.WhoName
	}
	if a.TicketKey != "" {
		out.TicketKey = &a.TicketKey
	}
	return out
}

// GetMeetingSession implements gen.ServerInterface.
func (s *Server) GetMeetingSession(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID) {
	if !s.meetingsReady(w) {
		return
	}
	d, err := s.opt.Meetings.Session(r.Context(), meetingCaller(r), id, sid)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	x := d.Session
	out := gen.MeetingSessionDetail{Id: x.ID, Meeting: s.toMeeting(d.Meeting), StartedAt: x.StartedAt, EndedAt: x.EndedAt,
		NotesStatus: gen.MeetingNotesStatus(x.NotesStatus), NotesError: x.NotesError, DocumentId: x.DocumentID,
		Attendees: make([]gen.MeetingAttendee, len(d.Attendees)), Recordings: make([]gen.MeetingRecording, len(d.Media)),
		ActionItems: toActionItems(d.ActionItems), Messages: d.Messages, CanManage: d.CanManage}
	for i, a := range d.Attendees {
		out.Attendees[i] = gen.MeetingAttendee{Person: a.Person.Key(), Name: a.Name, Guest: a.IsGuest, FirstIn: a.FirstIn, LastOut: a.LastOut, Seconds: a.Seconds}
		if a.GuestMail != "" {
			out.Attendees[i].Email = &a.GuestMail
		}
	}
	for i, md := range d.Media {
		out.Recordings[i] = gen.MeetingRecording{Id: md.ID, StartedAt: md.StartedAt, EndedAt: md.EndedAt, Seconds: md.Seconds(), Bytes: md.Bytes,
			Status: gen.MeetingRecordingStatus(md.Status)}
	}
	writeJSON(w, http.StatusOK, out)
}

func toMessages(ms []domain.MeetingMessage) []gen.MeetingMessage {
	out := make([]gen.MeetingMessage, len(ms))
	for i, m := range ms {
		out[i] = gen.MeetingMessage{Id: m.ID, Person: m.Person.Key(), Name: m.Name, Body: m.Body, At: m.CreatedAt}
	}
	return out
}

// ListMeetingSessionMessages implements gen.ServerInterface.
func (s *Server) ListMeetingSessionMessages(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID) {
	if !s.meetingsReady(w) {
		return
	}
	ms, err := s.opt.Meetings.SessionMessages(r.Context(), meetingCaller(r), id, sid)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toMessages(ms))
}

func toSegments(segs []domain.MeetingSegment) []gen.MeetingSegment {
	out := make([]gen.MeetingSegment, len(segs))
	for i, g := range segs {
		out[i] = gen.MeetingSegment{StartMs: g.StartMS, EndMs: g.EndMS, Name: g.Name, Text: g.Text}
	}
	return out
}

// GetMeetingTranscript implements gen.ServerInterface.
func (s *Server) GetMeetingTranscript(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID, params gen.GetMeetingTranscriptParams) {
	if !s.meetingsReady(w) {
		return
	}
	m, x, segs, err := s.opt.Meetings.Transcript(r.Context(), meetingCaller(r), id, sid)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	format := "json"
	if params.Format != nil {
		format = string(*params.Format)
	}
	title := m.Title
	if title == "" {
		title = "meeting"
	}
	switch format {
	case "txt":
		writeFile(w, documents.File{Name: domain.DownloadName("transcript "+title, m.ID, int(x.ID), "txt"), ContentType: "text/plain; charset=utf-8",
			Data: []byte(meetings.TranscriptText(m, x, segs))})
	case "vtt":
		writeFile(w, documents.File{Name: domain.DownloadName("transcript "+title, m.ID, int(x.ID), "vtt"), ContentType: "text/vtt; charset=utf-8",
			Data: []byte(meetings.TranscriptVTT(segs))})
	default:
		speakers := false
		for _, g := range segs {
			if g.Name != "" {
				speakers = true
			}
		}
		writeJSON(w, http.StatusOK, gen.MeetingTranscript{Segments: toSegments(segs), Speakers: speakers})
	}
}

// GetMeetingRecording implements gen.ServerInterface: the video, with
// ranges so the player can seek.
func (s *Server) GetMeetingRecording(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID, mediaID int64, params gen.GetMeetingRecordingParams) {
	if !s.meetingsReady(w) {
		return
	}
	f, err := s.opt.Meetings.Recording(r.Context(), meetingCaller(r), id, sid, mediaID)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	file, err := os.Open(f.Path)
	if errors.Is(err, os.ErrNotExist) {
		writeError(w, http.StatusNotFound, "not_found", "the recording's file is gone")
		return
	}
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	defer func() { _ = file.Close() }()
	info, err := file.Stat()
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	w.Header().Set("Content-Type", "video/mp4")
	w.Header().Set("Cache-Control", "private, max-age=3600")
	disp := "inline"
	if params.Download != nil && *params.Download {
		disp = "attachment"
	}
	w.Header().Set("Content-Disposition", disp+`; filename="`+f.Name+`"`)
	http.ServeContent(w, r, f.Name, info.ModTime(), file)
}

// DeleteMeetingRecording implements gen.ServerInterface.
func (s *Server) DeleteMeetingRecording(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID, mediaID int64) {
	if !s.meetingsReady(w) {
		return
	}
	if err := s.opt.Meetings.DeleteRecording(r.Context(), meetingCaller(r), id, sid, mediaID); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// RegenerateMeetingNotes implements gen.ServerInterface.
func (s *Server) RegenerateMeetingNotes(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID) {
	if !s.meetingsReady(w) {
		return
	}
	if err := s.opt.Meetings.RegenerateNotes(r.Context(), meetingCaller(r), id, sid); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusAccepted)
}

// CreateActionItemTicket implements gen.ServerInterface.
func (s *Server) CreateActionItemTicket(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID, itemID int64) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.ActionItemTicketInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	o := meetings.TicketOptions{Origin: origin(r)}
	if req.RepoId != nil {
		o.RepoID = *req.RepoId
	}
	if req.Start != nil {
		o.Start = string(*req.Start)
	}
	t, err := s.opt.Meetings.ActionItemTicket(r.Context(), meetingCaller(r), id, sid, itemID, o)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// SetActionItemMember implements gen.ServerInterface.
func (s *Server) SetActionItemMember(w http.ResponseWriter, r *http.Request, id gen.MeetingID, sid gen.SessionID, itemID int64) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.ActionItemMemberInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	it, err := s.opt.Meetings.SetActionItemMember(r.Context(), meetingCaller(r), id, sid, itemID, req.UserId, origin(r))
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toActionItem(it))
}

// ListTicketMeetings implements gen.ServerInterface.
func (s *Server) ListTicketMeetings(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if s.opt.Meetings == nil {
		writeJSON(w, http.StatusOK, []gen.MeetingTicketLink{})
		return
	}
	links, err := s.opt.Meetings.TicketMeetings(r.Context(), meetingCaller(r), key)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.MeetingTicketLink, len(links))
	for i, l := range links {
		out[i] = gen.MeetingTicketLink{MeetingId: l.MeetingID, MeetingTitle: l.MeetingTitle, MeetingCode: domain.FormatMeetingCode(l.MeetingCode),
			SessionId: l.SessionID, TicketKey: l.TicketKey, Quote: l.Quote, CreatedAt: l.CreatedAt}
	}
	writeJSON(w, http.StatusOK, out)
}

// SearchMeetingTranscripts implements gen.ServerInterface.
func (s *Server) SearchMeetingTranscripts(w http.ResponseWriter, r *http.Request, params gen.SearchMeetingTranscriptsParams) {
	if !s.meetingsReady(w) {
		return
	}
	hits, err := s.opt.Meetings.Search(r.Context(), meetingCaller(r), params.Q)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.MeetingTranscriptHit, len(hits))
	for i, h := range hits {
		g := h.Segment
		out[i] = gen.MeetingTranscriptHit{MeetingId: h.MeetingID, MeetingTitle: h.MeetingTitle, SessionId: h.SessionID, StartedAt: h.StartedAt,
			Segment: gen.MeetingSegment{StartMs: g.StartMS, EndMs: g.EndMS, Name: g.Name, Text: g.Text}}
	}
	writeJSON(w, http.StatusOK, out)
}

func (s *Server) meetingSettings(w http.ResponseWriter, r *http.Request, ms domain.MeetingSettings) {
	out := gen.MeetingSettings{AllowRecording: ms.AllowRecording, RetentionDays: ms.RetentionDays, KeepAudio: ms.KeepAudio, MaxParticipants: ms.MaxParticipants,
		DraftTickets: ms.DraftTickets}
	if m := s.opt.Meetings; m != nil {
		out.Available.Meetings, out.Available.Recording, out.Available.Notes = m.Ready(), m.RecordingReady(), m.NotesReady()
	}
	writeJSON(w, http.StatusOK, out)
}

// GetMeetingSettings implements gen.ServerInterface.
func (s *Server) GetMeetingSettings(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	cur, err := s.opt.Admin.Settings.Get(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	s.meetingSettings(w, r, cur.Meetings)
}

// PutMeetingSettings implements gen.ServerInterface.
func (s *Server) PutMeetingSettings(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	var req gen.MeetingSettingsInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	cur, err := s.opt.Admin.Settings.Get(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	drafts := cur.Meetings.DraftTickets
	if req.DraftTickets != nil {
		drafts = *req.DraftTickets
	}
	cur.Meetings = domain.MeetingSettings{AllowRecording: req.AllowRecording, RetentionDays: req.RetentionDays, KeepAudio: req.KeepAudio,
		MaxParticipants: req.MaxParticipants, DraftTickets: drafts}
	saved, err := s.opt.Admin.Settings.Put(r.Context(), cur, origin(r))
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.meetingSettings(w, r, saved.Meetings)
}

// GetMeetingUsage implements gen.ServerInterface.
func (s *Server) GetMeetingUsage(w http.ResponseWriter, r *http.Request, params gen.GetMeetingUsageParams) {
	if !s.meetingsReady(w) {
		return
	}
	days := 30
	if params.Days != nil {
		days = *params.Days
	}
	to := time.Now().UTC().Truncate(24 * time.Hour).Add(24 * time.Hour)
	us, err := s.opt.Meetings.Usage(r.Context(), meetingCaller(r), to.AddDate(0, 0, -days), to)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := make([]gen.MeetingUsageDay, len(us))
	for i, u := range us {
		out[i] = gen.MeetingUsageDay{Sessions: u.Sessions, ParticipantMinutes: u.ParticipantMinutes, RecordingMinutes: u.RecordingMinutes,
			RecordingBytes: u.RecordingBytes, TranscribedMinutes: u.TranscribedMinutes}
		out[i].Day.Time = u.Day
	}
	writeJSON(w, http.StatusOK, out)
}

// GetMeetingPrefs implements gen.ServerInterface.
func (s *Server) GetMeetingPrefs(w http.ResponseWriter, r *http.Request) {
	if s.opt.Meetings == nil {
		writeJSON(w, http.StatusOK, gen.MeetingPrefs{ReminderMinutes: 10})
		return
	}
	u, _ := userFrom(r.Context())
	n, err := s.opt.Meetings.ReminderMinutes(domain.System(r.Context()), u.ID)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, gen.MeetingPrefs{ReminderMinutes: gen.MeetingPrefsReminderMinutes(n)})
}

// PutMeetingPrefs implements gen.ServerInterface.
func (s *Server) PutMeetingPrefs(w http.ResponseWriter, r *http.Request) {
	if !s.meetingsReady(w) {
		return
	}
	var req gen.MeetingPrefs
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	u, _ := userFrom(r.Context())
	if err := s.opt.Meetings.SetReminderMinutes(domain.System(r.Context()), u.ID, int(req.ReminderMinutes)); err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, req)
}

// --- Public: the lobby and the call ---

// meetingGate starts a public meeting request: meetings are on, the
// address is within its rate, and the answer stays out of search engines.
func (s *Server) meetingGate(w http.ResponseWriter, r *http.Request) bool {
	publicHeaders(w)
	return s.meetingsReady(w) && s.limit(w, r, s.publicLimiter, "too many requests, try again later")
}

// signedIn is the person a public request's session names, if any.
func (s *Server) signedIn(r *http.Request) *domain.User {
	if s.opt.Auth == nil || sessionToken(r) == "" {
		return nil
	}
	u, err := s.opt.Auth.Authenticate(r.Context(), sessionToken(r))
	if err != nil || u.ID == 0 {
		return nil
	}
	return &u
}

// GetPublicMeeting implements gen.ServerInterface.
func (s *Server) GetPublicMeeting(w http.ResponseWriter, r *http.Request, code gen.MeetingCode) {
	if !s.meetingGate(w, r) {
		return
	}
	info, err := s.opt.Meetings.Info(r.Context(), code, s.signedIn(r))
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	m := info.Meeting
	live := m.Live != nil
	out := gen.PublicMeeting{Code: domain.FormatMeetingCode(m.Code), Title: m.Title, HostName: m.HostName, Workspace: info.Workspace,
		Kind: gen.PublicMeetingKind(m.Kind), StartsAt: m.StartsAt, EndsAt: m.EndsAt(), TimeZone: &m.TimeZone, Cancelled: m.CancelledAt != nil,
		Guests: gen.PublicMeetingGuests(m.Guests), Live: &live, InCall: info.InCall, Recording: info.Recording, Notes: info.Notes, Member: info.Member}
	if info.Name != "" {
		out.Name = &info.Name
	}
	if s.opt.Google != nil && s.opt.Google.ClientID != "" {
		out.GoogleClientId = &s.opt.Google.ClientID
	}
	writeJSON(w, http.StatusOK, out)
}

func toGrant(g meetings.Grant) gen.MeetingGrant {
	out := gen.MeetingGrant{Url: g.URL, Token: g.Token, Identity: g.Identity, Role: gen.MeetingGrantRole(g.Role), Rights: toRights(g.Rights),
		SessionId: g.SessionID, Name: g.Name}
	if g.Seat != "" {
		out.Seat = &g.Seat
	}
	return out
}

func toRights(r domain.Rights) gen.MeetingRights {
	return gen.MeetingRights{Publish: r.Publish, ScreenShare: r.ScreenShare, Chat: r.Chat, Admit: r.Admit, Moderate: r.Moderate, Record: r.Record,
		ManageCohosts: r.ManageCohosts}
}

func (s *Server) writeJoin(w http.ResponseWriter, r *http.Request, res meetings.JoinResult, err error) {
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	out := gen.MeetingJoin{Status: gen.MeetingJoinStatusWaiting}
	if res.Grant != nil {
		g := toGrant(*res.Grant)
		out.Status, out.Grant = gen.MeetingJoinStatusJoined, &g
	} else {
		out.KnockId, out.KnockToken = &res.KnockID, &res.KnockToken
	}
	if res.GuestToken != "" {
		out.GuestToken, out.GuestName = &res.GuestToken, &res.GuestName
	}
	writeJSON(w, http.StatusOK, out)
}

// JoinMeeting implements gen.ServerInterface.
func (s *Server) JoinMeeting(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.JoinMeetingParams) {
	if !s.meetingGate(w, r) {
		return
	}
	var req gen.MeetingJoinInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	j := meetings.Joiner{User: s.signedIn(r)}
	if params.XGuestToken != nil {
		j.GuestToken = *params.XGuestToken
	}
	if req.Name != nil {
		j.Name = *req.Name
	}
	if req.Device != nil {
		j.Device = *req.Device
	}
	if req.Invite != nil {
		j.InviteToken = *req.Invite
	}
	if req.GoogleCredential != nil && *req.GoogleCredential != "" {
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
		j.GoogleName, j.GoogleEmail = id.Name, id.Email
		if strings.TrimSpace(j.GoogleName) == "" {
			j.GoogleName, _, _ = strings.Cut(id.Email, "@")
		}
	}
	res, err := s.opt.Meetings.Join(r.Context(), code, j)
	s.writeJoin(w, r, res, err)
}

// WaitMeetingKnock implements gen.ServerInterface.
func (s *Server) WaitMeetingKnock(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, knockID int64, params gen.WaitMeetingKnockParams) {
	if !s.meetingGate(w, r) {
		return
	}
	tok := ""
	if params.XKnockToken != nil {
		tok = *params.XKnockToken
	}
	res, err := s.opt.Meetings.WaitKnock(r.Context(), code, knockID, tok, 25*time.Second)
	s.writeJoin(w, r, res, err)
}

// inCall finds the seat of an in-call request, or answers why not.
func (s *Server) inCall(w http.ResponseWriter, r *http.Request, code string, seat *gen.SeatToken) (meetings.InCall, bool) {
	if !s.meetingGate(w, r) {
		return meetings.InCall{}, false
	}
	tok := ""
	if seat != nil {
		tok = *seat
	}
	c, err := s.opt.Meetings.Seat(r.Context(), code, tok)
	if err != nil {
		s.meetingError(w, r, err)
		return c, false
	}
	return c, true
}

// GetMeetingCall implements gen.ServerInterface.
func (s *Server) GetMeetingCall(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.GetMeetingCallParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	st, err := s.opt.Meetings.State(c)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	toPerson := func(p meetings.CallPerson) gen.MeetingPerson {
		out := gen.MeetingPerson{Key: p.Key, Name: p.Name, Role: gen.MeetingPersonRole(p.Role), Identities: p.Identities, Knocked: p.Knocked}
		if out.Identities == nil {
			out.Identities = []string{}
		}
		if p.Email != "" {
			out.Email = &p.Email
		}
		return out
	}
	ns := gen.MeetingNotesStatus(st.Session.NotesStatus)
	out := gen.MeetingCall{Meeting: s.toMeeting(st.Meeting), SessionId: st.Session.ID, Me: toPerson(st.Me), Rights: toRights(st.Rights),
		CanAdmit: st.CanAdmit, People: make([]gen.MeetingPerson, len(st.People)), Knocks: make([]gen.MeetingKnock, len(st.Knocks)),
		Recording: st.Recording, Notes: st.Session.NotesOn, NotesStatus: &ns, RecordingAvailable: st.RecordingAvailable, NotesAvailable: st.NotesAvailable,
		GuestsQuiet: st.Session.GuestsQuiet}
	for i, p := range st.People {
		out.People[i] = toPerson(p)
	}
	for i, k := range st.Knocks {
		out.Knocks[i] = gen.MeetingKnock{Id: k.ID, Name: k.Name, Guest: k.Person.IsGuest(), At: k.CreatedAt}
		if k.Email != "" {
			out.Knocks[i].Email = &k.Email
		}
	}
	if st.Workspace != "" {
		out.Workspace = &st.Workspace
	}
	writeJSON(w, http.StatusOK, out)
}

// RefreshMeetingToken implements gen.ServerInterface.
func (s *Server) RefreshMeetingToken(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.RefreshMeetingTokenParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	g, err := s.opt.Meetings.Refresh(c)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toGrant(g))
}

// ListMeetingCallMessages implements gen.ServerInterface.
func (s *Server) ListMeetingCallMessages(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.ListMeetingCallMessagesParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	var after int64
	if params.After != nil {
		after = *params.After
	}
	ms, err := s.opt.Meetings.Messages(c, after)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toMessages(ms))
}

// SendMeetingMessage implements gen.ServerInterface.
func (s *Server) SendMeetingMessage(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.SendMeetingMessageParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	var req gen.SendMeetingMessageJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	m, err := s.opt.Meetings.Send(c, req.Body)
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, toMessages([]domain.MeetingMessage{m})[0])
}

// DecideMeetingKnock implements gen.ServerInterface.
func (s *Server) DecideMeetingKnock(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, knockID int64, decision string, params gen.DecideMeetingKnockParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	var err error
	switch decision {
	case "admit":
		err = s.opt.Meetings.Admit(c, knockID)
	case "deny":
		err = s.opt.Meetings.Deny(c, knockID)
	default:
		writeError(w, http.StatusBadRequest, "bad_request", "admit or deny")
		return
	}
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AdmitAllMeetingKnocks implements gen.ServerInterface.
func (s *Server) AdmitAllMeetingKnocks(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.AdmitAllMeetingKnocksParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	if err := s.opt.Meetings.AdmitAll(c); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ActOnMeetingPerson implements gen.ServerInterface.
func (s *Server) ActOnMeetingPerson(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, person, action string, params gen.ActOnMeetingPersonParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	var req gen.ActOnMeetingPersonJSONBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var err error
	switch action {
	case "mute":
		source := "microphone"
		if req.Source != nil {
			source = string(*req.Source)
		}
		err = s.opt.Meetings.Mute(c, person, source)
	case "ask-unmute":
		err = s.opt.Meetings.AskUnmute(c, person)
	case "remove":
		err = s.opt.Meetings.Remove(c, person)
	case "lower-hand":
		err = s.opt.Meetings.LowerHand(c, person)
	case "cohost", "uncohost":
		err = s.opt.Meetings.SetCohost(c, person, action == "cohost")
	default:
		writeError(w, http.StatusBadRequest, "bad_request", "unknown action")
		return
	}
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// MuteAllInMeeting implements gen.ServerInterface.
func (s *Server) MuteAllInMeeting(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.MuteAllInMeetingParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	if err := s.opt.Meetings.MuteAll(c); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// SetMeetingCallSettings implements gen.ServerInterface.
func (s *Server) SetMeetingCallSettings(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.SetMeetingCallSettingsParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	var req gen.MeetingCallSettings
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	m := s.opt.Meetings
	var err error
	if req.Locked != nil {
		err = m.Lock(c, *req.Locked)
	}
	if err == nil && (req.Guests != nil || req.GuestsQuiet != nil) {
		var mode domain.GuestMode
		if req.Guests != nil {
			mode = domain.GuestMode(*req.Guests)
		}
		err = m.SetGuests(c, mode, req.GuestsQuiet)
	}
	if err == nil && req.Recording != nil {
		if *req.Recording {
			err = m.StartRecording(c)
		} else {
			err = m.StopRecording(c)
		}
	}
	if err == nil && req.Notes != nil {
		if *req.Notes {
			err = m.StartNotes(c)
		} else {
			err = m.StopNotes(c)
		}
	}
	if err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// EndMeetingCall implements gen.ServerInterface.
func (s *Server) EndMeetingCall(w http.ResponseWriter, r *http.Request, code gen.MeetingCode, params gen.EndMeetingCallParams) {
	c, ok := s.inCall(w, r, code, params.XMeetingSeat)
	if !ok {
		return
	}
	if err := s.opt.Meetings.End(c); err != nil {
		s.meetingError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// livekitWebhook receives LiveKit's events at /webhooks/livekit; they are
// signed with the API secret.
func (s *Server) livekitWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", "unreadable body")
		return
	}
	if err := s.opt.Meetings.HandleWebhook(r.Context(), r.Header.Get("Authorization"), body); err != nil {
		if errors.Is(err, meetings.ErrBadWebhook) {
			writeError(w, http.StatusUnauthorized, "unauthorized", err.Error())
			return
		}
		s.writeInternal(w, r, err)
		return
	}
	w.WriteHeader(http.StatusOK)
}
