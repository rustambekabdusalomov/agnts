package meetings

import (
	"context"
	"fmt"
	"net/url"
	"strings"
	"time"
	"unicode/utf8"

	"agnts/internal/domain"
	"agnts/internal/mail"
)

// ICSEvent is one meeting as a calendar event (RFC 5545).
type ICSEvent struct {
	UID         string
	Sequence    int
	Method      string // REQUEST or CANCEL
	Start       time.Time
	End         time.Time
	Summary     string
	Description string
	Location    string // the meeting's link
	Organizer   string // name
	OrganizerAt string // email, may be empty
	Attendee    string // email of the invitee
	Stamp       time.Time
}

// ICS writes the event as a calendar file: one VEVENT in UTC, lines
// folded at 75 octets and text escaped as the RFC says.
func ICS(e ICSEvent) []byte {
	var b strings.Builder
	line := func(s string) { b.WriteString(foldICS(s) + "\r\n") }
	utc := func(t time.Time) string { return t.UTC().Format("20060102T150405Z") }
	line("BEGIN:VCALENDAR")
	line("PRODID:-//agnts//Meetings//EN")
	line("VERSION:2.0")
	line("CALSCALE:GREGORIAN")
	line("METHOD:" + e.Method)
	line("BEGIN:VEVENT")
	line("UID:" + e.UID)
	line("SEQUENCE:" + fmt.Sprint(e.Sequence))
	line("DTSTAMP:" + utc(e.Stamp))
	line("DTSTART:" + utc(e.Start))
	line("DTEND:" + utc(e.End))
	line("SUMMARY:" + escapeICS(e.Summary))
	if e.Description != "" {
		line("DESCRIPTION:" + escapeICS(e.Description))
	}
	if e.Location != "" {
		line("LOCATION:" + escapeICS(e.Location))
		line("URL:" + e.Location)
	}
	if e.OrganizerAt != "" {
		line("ORGANIZER;CN=" + quoteParam(e.Organizer) + ":mailto:" + e.OrganizerAt)
	}
	if e.Attendee != "" {
		line("ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:mailto:" + e.Attendee)
	}
	if e.Method == "CANCEL" {
		line("STATUS:CANCELLED")
	} else {
		line("STATUS:CONFIRMED")
		line("BEGIN:VALARM")
		line("TRIGGER:-PT10M")
		line("ACTION:DISPLAY")
		line("DESCRIPTION:" + escapeICS(e.Summary))
		line("END:VALARM")
	}
	line("END:VEVENT")
	line("END:VCALENDAR")
	return []byte(b.String())
}

// escapeICS escapes a TEXT value.
func escapeICS(s string) string {
	return strings.NewReplacer(`\`, `\\`, ";", `\;`, ",", `\,`, "\r\n", `\n`, "\n", `\n`, "\r", `\n`).Replace(s)
}

// quoteParam quotes a parameter value (a name with commas or colons).
func quoteParam(s string) string {
	s = strings.NewReplacer(`"`, "", "\r", "", "\n", "").Replace(s)
	if strings.ContainsAny(s, ",;:") {
		return `"` + s + `"`
	}
	return s
}

// foldICS folds a content line at 75 octets, never inside a character.
func foldICS(s string) string {
	if len(s) <= 75 {
		return s
	}
	var b strings.Builder
	n := 0
	for _, r := range s {
		w := utf8.RuneLen(r)
		if n+w > 75 {
			b.WriteString("\r\n ")
			n = 1
		}
		b.WriteRune(r)
		n += w
	}
	return b.String()
}

// whenText is a meeting's time as people read it, in its time zone.
func (s *Service) whenText(m domain.Meeting) string {
	if m.StartsAt == nil {
		return "Now"
	}
	loc, err := time.LoadLocation(m.TimeZone)
	if err != nil {
		loc = time.UTC
	}
	start := m.StartsAt.In(loc)
	return fmt.Sprintf("%s – %s (%s)", start.Format("Mon 2 Jan, 15:04"), start.Add(time.Duration(m.DurationMin)*time.Minute).Format("15:04"), m.TimeZone)
}

// newInvitee is an invitee just added, with an email invitee's link token.
type newInvitee struct {
	domain.Invitee
	Token string
}

func addedWithTokens(added []domain.Invitee, tokens map[string]string) []newInvitee {
	out := make([]newInvitee, len(added))
	for i, a := range added {
		out[i] = newInvitee{Invitee: a, Token: tokens[a.Email]}
	}
	return out
}

// sendInvitations emails a scheduled meeting's invitation (with its
// calendar event) to invitees: the ones just added (newOnly), or everyone
// after a change or a cancellation. Email invitees get a personal link;
// a change gives them a new one. Without email set up nothing is sent.
func (s *Service) sendInvitations(ctx context.Context, m domain.Meeting, added []newInvitee, newOnly bool) {
	if s.d.Mailer == nil || !s.d.Mailer.Enabled() || m.StartsAt == nil {
		return
	}
	targets := added
	if !newOnly {
		all, err := s.d.Store.Invitees(ctx, m.ID)
		if err != nil {
			s.d.Log.Warn("meeting invitations", "meeting", m.ID, "err", err)
			return
		}
		targets = nil
		for _, i := range all {
			ni := newInvitee{Invitee: i}
			if i.UserID == nil && m.CancelledAt == nil {
				tok, hash, err := domain.NewGuestToken()
				if err != nil {
					continue
				}
				if err := s.d.Store.SetInviteeToken(ctx, i.ID, hash); err != nil {
					continue
				}
				ni.Token = tok
			}
			targets = append(targets, ni)
		}
	}
	host := m.HostName
	if host == "" {
		host = "agnts"
	}
	var hostMail string
	if m.HostID != nil {
		if u, err := s.d.Users.ByID(ctx, *m.HostID); err == nil {
			hostMail = u.Email
		}
	}
	go func() {
		ctx := context.WithoutCancel(ctx)
		for _, t := range targets {
			if t.Email == "" {
				continue
			}
			link := s.Link(m.Code)
			if t.UserID == nil && t.Token != "" {
				link += "?i=" + url.QueryEscape(t.Token)
			}
			method, subject := "REQUEST", "Invitation: "+titleOf(m)+" · "+s.whenText(m)
			switch {
			case m.CancelledAt != nil:
				method, subject = "CANCEL", "Cancelled: "+titleOf(m)+" · "+s.whenText(m)
			case !newOnly:
				subject = "Updated: " + titleOf(m) + " · " + s.whenText(m)
			}
			var body strings.Builder
			if m.CancelledAt != nil {
				fmt.Fprintf(&body, "%s cancelled %s, planned for %s.\n", host, titleOf(m), s.whenText(m))
			} else {
				fmt.Fprintf(&body, "%s invited you to a video call.\n\n%s\n%s\n\nJoin: %s\n", host, titleOf(m), s.whenText(m), link)
				if d := strings.TrimSpace(m.Description); d != "" {
					fmt.Fprintf(&body, "\n%s\n", d)
				}
				body.WriteString("\nJoin from a browser (Chrome, Edge, Firefox or Safari); no app needed.\n")
			}
			ics := ICS(ICSEvent{UID: m.Code + "@agnts", Sequence: m.ICSSequence, Method: method, Start: *m.StartsAt, End: *m.EndsAt(),
				Summary: titleOf(m), Description: strings.TrimSpace(m.Description + "\n\nJoin: " + link), Location: link,
				Organizer: host, OrganizerAt: hostMail, Attendee: t.Email, Stamp: s.now()})
			msg := mail.Message{To: t.Email, Subject: subject, Body: body.String(), Attachments: []mail.Attachment{
				{Name: "invite.ics", ContentType: "text/calendar; method=" + method + "; charset=utf-8", Data: ics}}}
			if err := s.d.Mailer.Send(ctx, msg); err != nil {
				s.d.Log.Warn("send a meeting invitation", "meeting", m.ID, "err", err)
			}
		}
	}()
}

// Remind sends the reminders that are due: a push and a live event a few
// minutes before a scheduled meeting, to the members invited to it. Call
// it every minute in the system scope.
func (s *Service) Remind(ctx context.Context) {
	due, err := s.d.Store.DueReminders(ctx)
	if err != nil {
		s.d.Log.Warn("meeting reminders", "err", err)
		return
	}
	for _, r := range due {
		wctx := domain.WithWorkspace(ctx, r.WorkspaceID)
		ok, err := s.d.Store.MarkReminded(wctx, r.InviteeID)
		if err != nil || !ok {
			continue
		}
		m, err := s.d.Store.Meeting(wctx, r.MeetingID)
		if err != nil {
			continue
		}
		s.publish(r.WorkspaceID, r.UserID, domain.EventMeetingReminder, map[string]any{"meetingId": m.ID, "code": m.Code, "title": titleOf(m),
			"startsAt": m.StartsAt})
		if s.d.Pusher != nil {
			s.d.Pusher.MeetingPush(wctx, []int64{r.UserID}, Push{Title: titleOf(m) + " starts soon", Body: s.whenText(m), Code: m.Code,
				Tag: "meeting-reminder-" + m.Code})
		}
	}
}

// Retention deletes what is past the workspace's retention: recordings,
// notes audio and transcripts. Call it daily in each workspace's scope.
func (s *Service) Retention(ctx context.Context) {
	days := s.settings(ctx).RetentionDays
	if days <= 0 {
		return
	}
	files, err := s.d.Store.ExpiredMedia(ctx, days)
	if err != nil {
		s.d.Log.Warn("meeting retention", "err", err)
		return
	}
	for _, f := range files {
		s.removeFile(f.File)
		_ = s.d.Store.SetMediaStatus(ctx, f.ID, domain.MediaExpired)
	}
	if n, err := s.d.Store.ExpireTranscripts(ctx, days); err != nil {
		s.d.Log.Warn("meeting transcript retention", "err", err)
	} else if n > 0 || len(files) > 0 {
		s.d.Log.Info("meeting retention", "files", len(files), "segments", n)
	}
}
