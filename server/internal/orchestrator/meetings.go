package orchestrator

import (
	"agnts/internal/ai"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Meeting notes: a document generation whose source is a meeting session.
// agnts gathers the transcript (heard by Muse), the chat and who was there;
// the generation writes the notes and, beside them, the action items as
// JSON, which the server stores so they can become tickets.

// MeetingNotesSource reads what a session's notes are made from.
type MeetingNotesSource interface {
	NotesInput(ctx context.Context, sessionID int64) (domain.MeetingNotesInput, error)
}

// SetMeetings lets document generations make meeting notes.
func (o *Orchestrator) SetMeetings(m MeetingNotesSource) { o.meetings = m }

// ActionItemsPath is where a notes generation writes the action items.
const ActionItemsPath = "/agnts/out/action-items.json"

// meetingTranscriptBudget is how much transcript one generation reads;
// longer meetings are summarised in parts (see gatherMeeting).
const meetingTranscriptBudget = 90_000

// gatherMeeting writes the transcript, the chat and the attendees of a
// session for its notes. A transcript longer than the budget is split
// into parts the generation reads one after the other.
func (o *Orchestrator) gatherMeeting(ctx context.Context, src domain.DocumentSource, g *gathered) error {
	if o.meetings == nil {
		return errors.New("meetings are not available on this server")
	}
	in, err := o.meetings.NotesInput(ctx, src.SessionID)
	if errors.Is(err, domain.ErrNotFound) {
		return errors.New("the meeting session is gone")
	}
	if err != nil {
		return err
	}
	if len(in.Segments) == 0 {
		return errors.New("the meeting has no transcript: nothing was heard")
	}
	var about strings.Builder
	m, x := in.Meeting, in.Session
	title := m.Title
	if title == "" {
		title = "Meeting " + domain.FormatMeetingCode(m.Code)
	}
	fmt.Fprintf(&about, "# %s\n\n", title)
	loc, _ := time.LoadLocation(m.TimeZone)
	if loc == nil {
		loc = time.UTC
	}
	fmt.Fprintf(&about, "- Date: %s (%s)\n", x.StartedAt.In(loc).Format("Monday, 2 January 2006, 15:04"), m.TimeZone)
	if x.EndedAt != nil {
		fmt.Fprintf(&about, "- Length: %s\n", x.EndedAt.Sub(x.StartedAt).Round(time.Minute))
	}
	if m.HostName != "" {
		fmt.Fprintf(&about, "- Host: %s\n", m.HostName)
	}
	if d := strings.TrimSpace(m.Description); d != "" {
		fmt.Fprintf(&about, "\n## Agenda / description\n\n%s\n", d)
	}
	about.WriteString("\n## Who was there\n\n")
	for _, a := range in.Attendees {
		kind := "member"
		if a.IsGuest {
			kind = "guest"
		}
		fmt.Fprintf(&about, "- %s (%s, %s)\n", a.Name, kind, (time.Duration(a.Seconds) * time.Second).Round(time.Minute))
	}
	if !in.Speakers {
		about.WriteString("\nThe transcript is of everyone's audio together: it does not say who spoke. Name a person only when the words make it clear (\"Rustam, can you…\", \"I'll do it — Aziza\").\n")
	}
	g.files = append(g.files, sourceFile{Name: "meeting.md", What: "the meeting: when, who was there, the agenda", Body: about.String()})

	parts := transcriptParts(in.Segments, meetingTranscriptBudget)
	for i, p := range parts {
		name, what := "transcript.md", "the transcript, as Muse heard it: [m:ss] from the start of the call"
		if len(parts) > 1 {
			name = fmt.Sprintf("transcript-%d.md", i+1)
			what = fmt.Sprintf("part %d of %d of the transcript ([m:ss] from the start of the call)", i+1, len(parts))
		}
		g.files = append(g.files, sourceFile{Name: name, What: what, Body: p})
	}
	if len(in.Messages) > 0 {
		var chat strings.Builder
		for _, msg := range in.Messages {
			at := int(msg.CreatedAt.Sub(x.StartedAt).Milliseconds())
			fmt.Fprintf(&chat, "[%s] %s: %s\n", domain.FormatOffset(max(at, 0)), msg.Name, strings.ReplaceAll(msg.Body, "\n", " "))
		}
		g.files = append(g.files, sourceFile{Name: "chat.md", What: "the call's chat ([m:ss] from the start)", Body: chat.String()})
	}
	return nil
}

// transcriptParts writes segments as "[m:ss] Name: text" lines and cuts
// them into parts of at most budget bytes, at line ends.
func transcriptParts(segs []domain.MeetingSegment, budget int) []string {
	var parts []string
	var b strings.Builder
	for _, s := range segs {
		line := "[" + domain.FormatOffset(s.StartMS) + "] "
		if s.Name != "" {
			line += s.Name + ": "
		}
		line += strings.TrimSpace(s.Text) + "\n"
		if b.Len() > 0 && b.Len()+len(line) > budget {
			parts = append(parts, b.String())
			b.Reset()
		}
		b.WriteString(line)
	}
	if b.Len() > 0 {
		parts = append(parts, b.String())
	}
	return parts
}

// meetingNotesGuide is how notes are written.
const meetingNotesGuide = `Meeting notes for the people who were there and those who were not:

- Start with a summary of three to five lines: what the meeting was for and what came out of it.
- "## Decisions": what was decided, one line each.
- "## Action items": who does what and by when, one line each, as said. Only things someone agreed to do.
- "## Discussion": the main topics, a few lines each, with the arguments that mattered.
- "## Open questions": what was left unanswered.
- After every point, cite when it was said, in brackets: [12:34]. Use the times of the transcript.
- When the transcript is in parts, read every part before writing; the notes cover the whole meeting.
- Leave out small talk, greetings and the meeting's own logistics.`

// meetingActionItemsRule asks for the action items as JSON beside the notes.
const meetingActionItemsRule = `
Also write the action items as JSON to ` + ActionItemsPath + `: an array (empty when there are none) of
{"text": "what is to be done, as a short imperative sentence", "who": "the person, as named in the meeting, or empty",
 "due": "when, as said (\"by Friday\"), or empty", "at": "m:ss when it was agreed", "quote": "the words that show it, at most 300 characters"}.
The same items as in the notes' Action items section, in the same order.
`

// actionItemJSON is one action item as the generation writes it.
type actionItemJSON struct {
	Text  string `json:"text"`
	Who   string `json:"who"`
	Due   string `json:"due"`
	At    string `json:"at"`
	Quote string `json:"quote"`
}

// readActionItems reads and checks the action items a notes generation
// wrote. A file that does not parse fails the generation rather than
// losing the items.
func readActionItems(raw []byte) ([]domain.ActionItem, error) {
	var in []actionItemJSON
	if err := json.Unmarshal(raw, &in); err != nil {
		return nil, fmt.Errorf("the action items are not valid JSON: %w", err)
	}
	out := make([]domain.ActionItem, 0, len(in))
	for _, it := range in {
		a := domain.ActionItem{Text: it.Text, Who: it.Who, Due: it.Due, Quote: it.Quote}
		if ms, ok := parseOffset(it.At); ok {
			a.AtMS = &ms
		}
		out = append(out, a)
	}
	return domain.CleanActionItems(out)
}

// parseOffset reads m:ss or h:mm:ss as milliseconds.
func parseOffset(s string) (int, bool) {
	s = strings.Trim(strings.TrimSpace(s), "[]")
	if s == "" {
		return 0, false
	}
	parts := strings.Split(s, ":")
	if len(parts) < 2 || len(parts) > 3 {
		return 0, false
	}
	total := 0
	for i, p := range parts {
		var n int
		if _, err := fmt.Sscanf(p, "%d", &n); err != nil || n < 0 || (i > 0 && n >= 60) {
			return 0, false
		}
		total = total*60 + n
	}
	return total * 1000, true
}

// CanHearMeetings reports whether meeting audio can be transcribed.
func (o *Orchestrator) CanHearMeetings() bool { return o.ai.CanHear() }

// HearMeeting returns what was said in a meeting's audio (ext: ogg or
// mp4), heard by Muse on the account the workspace's runs use for user,
// who turned the notes on. Unlike the assistant it may use the platform's
// key: hearing is not metered, the notes it leads to are.
func (o *Orchestrator) HearMeeting(ctx context.Context, user int64, audio []byte, ext string) ([]domain.MeetingSegment, error) {
	if !o.ai.CanHear() {
		return nil, invalid("meeting notes are not available on this server")
	}
	// Only Muse hears audio, whatever modules the person codes with.
	segs, err := o.ai.Hear(ctx, ai.Who{Person: user}, audio, ext)
	var h *ai.Hold
	if errors.As(err, &h) {
		return nil, fmt.Errorf("muse cannot hear the meeting: %s", h.Why)
	}
	if err != nil {
		return nil, fmt.Errorf("hear the meeting: %w", err)
	}
	return segs, nil
}
