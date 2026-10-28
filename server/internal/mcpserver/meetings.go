package mcpserver

import (
	"context"
	"errors"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
	"agnts/internal/meetings"
)

// Meetings: what was said and decided in the workspace's calls, for the
// assistant and MCP clients. Only the meetings the person sees, and only
// the calls they may read.

// MeetingsInput lists recent calls.
type MeetingsInput struct {
	Limit int `json:"limit,omitempty" jsonschema:"how many calls, newest first (default 20, at most 50)"`
}

// MeetingCall is a past call in lists.
type MeetingCall struct {
	MeetingID   int64  `json:"meeting_id"`
	SessionID   int64  `json:"session_id"`
	Title       string `json:"title"`
	StartedAt   string `json:"started_at"`
	Minutes     int    `json:"minutes"`
	People      int    `json:"people"`
	Notes       string `json:"notes_status"`
	DocumentID  int64  `json:"notes_document_id,omitempty"`
	ActionItems int    `json:"action_items"`
}

// MeetingCalls is list_meetings's output.
type MeetingCalls struct {
	Calls []MeetingCall `json:"calls"`
}

// MeetingSearchInput searches what was said.
type MeetingSearchInput struct {
	Query string `json:"query" jsonschema:"words to find in what was said (two letters or more)"`
}

// MeetingHit is a stretch of a transcript.
type MeetingHit struct {
	MeetingID int64  `json:"meeting_id"`
	SessionID int64  `json:"session_id"`
	Title     string `json:"title"`
	Date      string `json:"date"`
	At        string `json:"at"` // m:ss from the call's start
	Speaker   string `json:"speaker,omitempty"`
	Text      string `json:"text"`
}

// MeetingHits is search_meetings's output.
type MeetingHits struct {
	Hits []MeetingHit `json:"hits"`
}

// MeetingNotesInput names one call.
type MeetingNotesInput struct {
	MeetingID int64 `json:"meeting_id"`
	SessionID int64 `json:"session_id"`
}

// MeetingActionItem is something someone agreed to do.
type MeetingActionItem struct {
	Text   string `json:"text"`
	Who    string `json:"who,omitempty"`
	Due    string `json:"due,omitempty"`
	At     string `json:"at,omitempty"`
	Quote  string `json:"quote,omitempty"`
	Ticket string `json:"ticket,omitempty"`
}

// MeetingNotes is get_meeting's output.
type MeetingNotes struct {
	Title       string              `json:"title"`
	StartedAt   string              `json:"started_at"`
	Attendees   []string            `json:"attendees"`
	Notes       string              `json:"notes_status"`
	DocumentID  int64               `json:"notes_document_id,omitempty"`
	ActionItems []MeetingActionItem `json:"action_items"`
	Transcript  []string            `json:"transcript"` // "[m:ss] Speaker: words"
	Cut         bool                `json:"transcript_cut,omitempty"`
}

// meetingCaller is the person a tool call acts for, as the meetings module
// knows callers.
func (t *tools) meetingCaller(ctx context.Context) (*meetings.Service, meetings.Caller, error) {
	if t.d.Meetings == nil || t.d.Meetings() == nil || !t.d.Meetings().Ready() {
		return nil, meetings.Caller{}, errors.New("meetings are not available on this server")
	}
	a, ok := domain.ActorOf(ctx)
	if !ok || a.UserID == 0 {
		return nil, meetings.Caller{}, errors.New("not signed in")
	}
	c := meetings.Caller{WorkspaceID: domain.WorkspaceOf(ctx), UserID: a.UserID, Role: domain.RoleUser}
	if t.d.Role != nil {
		r, err := t.d.Role(ctx, c.WorkspaceID, c.UserID)
		if err != nil {
			return nil, c, err
		}
		c.Role = r
	}
	return t.d.Meetings(), c, nil
}

func (t *tools) listMeetings(ctx context.Context, _ *mcp.CallToolRequest, in MeetingsInput) (*mcp.CallToolResult, MeetingCalls, error) {
	svc, c, err := t.meetingCaller(ctx)
	if err != nil {
		return nil, MeetingCalls{}, err
	}
	limit := in.Limit
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	xs, err := svc.Past(ctx, c, nil, limit)
	if err != nil {
		return nil, MeetingCalls{}, err
	}
	out := MeetingCalls{Calls: []MeetingCall{}}
	for _, x := range xs {
		v := x.Session
		mc := MeetingCall{MeetingID: x.Meeting.ID, SessionID: v.ID, Title: titleOr(x.Meeting.Title, x.Meeting.Code), StartedAt: v.StartedAt.UTC().Format(time.RFC3339),
			People: x.People, Notes: string(v.NotesStatus), ActionItems: x.ActionItems}
		if v.EndedAt != nil {
			mc.Minutes = int(v.EndedAt.Sub(v.StartedAt).Minutes())
		}
		if v.DocumentID != nil {
			mc.DocumentID = *v.DocumentID
		}
		out.Calls = append(out.Calls, mc)
	}
	return nil, out, nil
}

func (t *tools) searchMeetings(ctx context.Context, _ *mcp.CallToolRequest, in MeetingSearchInput) (*mcp.CallToolResult, MeetingHits, error) {
	svc, c, err := t.meetingCaller(ctx)
	if err != nil {
		return nil, MeetingHits{}, err
	}
	hits, err := svc.Search(ctx, c, in.Query)
	if err != nil {
		return nil, MeetingHits{}, err
	}
	out := MeetingHits{Hits: []MeetingHit{}}
	for _, h := range hits {
		out.Hits = append(out.Hits, MeetingHit{MeetingID: h.MeetingID, SessionID: h.SessionID, Title: h.MeetingTitle,
			Date: h.StartedAt.UTC().Format(time.DateOnly), At: domain.FormatOffset(h.Segment.StartMS), Speaker: h.Segment.Name, Text: h.Segment.Text})
	}
	return nil, out, nil
}

// meetingTranscriptMax caps the transcript lines get_meeting returns.
const meetingTranscriptMax = 600

func (t *tools) getMeeting(ctx context.Context, _ *mcp.CallToolRequest, in MeetingNotesInput) (*mcp.CallToolResult, MeetingNotes, error) {
	svc, c, err := t.meetingCaller(ctx)
	if err != nil {
		return nil, MeetingNotes{}, err
	}
	d, err := svc.Session(ctx, c, in.MeetingID, in.SessionID)
	if err != nil {
		return nil, MeetingNotes{}, err
	}
	_, _, segs, err := svc.Transcript(ctx, c, in.MeetingID, in.SessionID)
	if err != nil {
		return nil, MeetingNotes{}, err
	}
	out := MeetingNotes{Title: titleOr(d.Meeting.Title, d.Meeting.Code), StartedAt: d.Session.StartedAt.UTC().Format(time.RFC3339),
		Attendees: []string{}, Notes: string(d.Session.NotesStatus), ActionItems: []MeetingActionItem{}, Transcript: []string{}}
	if d.Session.DocumentID != nil {
		out.DocumentID = *d.Session.DocumentID
	}
	for _, a := range d.Attendees {
		out.Attendees = append(out.Attendees, a.Name)
	}
	for _, it := range d.ActionItems {
		ai := MeetingActionItem{Text: it.Text, Who: it.Who, Due: it.Due, Quote: it.Quote, Ticket: it.TicketKey}
		if it.AtMS != nil {
			ai.At = domain.FormatOffset(*it.AtMS)
		}
		out.ActionItems = append(out.ActionItems, ai)
	}
	for i, g := range segs {
		if i == meetingTranscriptMax {
			out.Cut = true
			break
		}
		line := "[" + domain.FormatOffset(g.StartMS) + "] "
		if g.Name != "" {
			line += g.Name + ": "
		}
		out.Transcript = append(out.Transcript, line+g.Text)
	}
	return nil, out, nil
}

func titleOr(title, code string) string {
	if title != "" {
		return title
	}
	return "Meeting " + domain.FormatMeetingCode(code)
}
