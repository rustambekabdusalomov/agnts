package mcpserver

import (
	"context"
	"encoding/json"
	"errors"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Snapshot caps: the assistant reads a few small files, not the database.
const (
	snapTickets    = 60
	snapCI         = 20
	snapLessons    = 20
	snapKeys       = 3
	snapCIDetails  = 3
	snapLogBytes   = 6000
	snapTextBytes  = 4000
	snapTicketDays = 14
)

// Snapshotter writes the assistant's view of a workspace: the MCP read
// tools' outputs, as files. Both answer from the same reads.
type Snapshotter struct{ t *tools }

var _ orchestrator.AssistantSnapshotter = (*Snapshotter)(nil)

// NewSnapshotter returns the assistant's snapshot reads over d.
func NewSnapshotter(d Deps) *Snapshotter { return &Snapshotter{t: &tools{d: d}} }

// Snapshot returns the files for a question: always the inbox, the tickets
// and the tickets it names; CI, spend, lessons and repositories when the
// question is about them (or about nothing in particular). A read that
// fails is left out with a note, not fatal: the assistant says what is
// missing.
func (s *Snapshotter) Snapshot(ctx context.Context, q orchestrator.AssistantQuestion) ([]orchestrator.AssistantFile, error) {
	want := func(t orchestrator.AssistantTopic) bool { return q.Topics == nil || q.Topics[t] }
	var files []orchestrator.AssistantFile
	var missing []string
	add := func(name string, v any, err error) {
		if err != nil {
			missing = append(missing, name+": "+err.Error())
			return
		}
		b, err := json.MarshalIndent(v, "", " ")
		if err != nil {
			missing = append(missing, name+": "+err.Error())
			return
		}
		files = append(files, orchestrator.AssistantFile{Name: name, Content: string(b)})
	}

	_, inbox, err := s.t.getInbox(ctx, nil, noInput{})
	add("inbox.json", inbox, err)
	tickets, err := s.tickets(ctx)
	add("tickets.json", tickets, err)

	keys := q.Keys
	if len(keys) > snapKeys {
		keys = keys[:snapKeys]
	}
	for _, k := range keys {
		_, t, err := s.t.getTicket(ctx, nil, KeyInput{Key: k})
		if errors.Is(err, domain.ErrNotFound) || err != nil && strings.Contains(err.Error(), "no ticket") {
			missing = append(missing, "ticket-"+k+".json: no ticket "+k+" in this workspace")
			continue
		}
		add("ticket-"+k+".json", trimTicket(t), err)
	}

	if want(orchestrator.TopicCI) && s.t.d.CI != nil {
		_, ci, err := s.t.listCIFailures(ctx, nil, CIInput{})
		if err == nil && len(ci.Failures) > snapCI {
			ci.Failures = ci.Failures[:snapCI]
		}
		add("ci.json", ci, err)
		// The logs of a few red groups, when there are few enough to matter.
		if err == nil && len(ci.Failures) > 0 && len(ci.Failures) <= snapCIDetails {
			for _, f := range ci.Failures {
				_, d, err := s.t.getCIFailure(ctx, nil, CIFailureInput{ID: f.ID})
				if err == nil {
					d.Log = truncateBytes(d.Log, snapLogBytes)
				}
				add("ci-"+strconv.FormatInt(f.ID, 10)+".json", d, err)
			}
		}
	}
	if want(orchestrator.TopicSpend) {
		_, u, err := s.t.getUsage(ctx, nil, noInput{})
		add("usage.json", u, err)
		_, a, err := s.t.getAnalytics(ctx, nil, DaysInput{Days: 7})
		add("analytics.json", a, err)
	}
	if want(orchestrator.TopicRepos) {
		_, r, err := s.t.listRepos(ctx, nil, noInput{})
		for i := range r.Repositories {
			r.Repositories[i].CloneURL = ""
		}
		add("repositories.json", r, err)
	}
	if want(orchestrator.TopicLessons) && s.t.d.Lessons != nil {
		_, l, err := s.t.listLessons(ctx, nil, LessonsInput{Status: "new", Limit: snapLessons})
		add("lessons.json", l, err)
	}
	if len(missing) > 0 {
		add("missing.json", map[string][]string{"not_available": missing}, nil)
	}
	return files, nil
}

// snapshotTickets is tickets.json: what needs the person, what runs and
// waits, and what finished lately.
type snapshotTickets struct {
	Needs   []TicketBrief `json:"needs_you"`
	Running []TicketBrief `json:"running"`
	Queue   []TicketBrief `json:"queue"`
	Done    []TicketBrief `json:"done_last_14_days"`
	Note    string        `json:"note,omitempty"`
}

func (s *Snapshotter) tickets(ctx context.Context) (snapshotTickets, error) {
	out := snapshotTickets{}
	left := snapTickets
	take := func(filter string, keep func(TicketBrief) bool) ([]TicketBrief, error) {
		_, l, err := s.t.listTickets(ctx, nil, ListInput{Filter: filter, Limit: min(100, snapTickets)})
		if err != nil {
			return nil, err
		}
		var got []TicketBrief
		for _, b := range l.Tickets {
			if left == 0 {
				out.Note = "lists are cut at 60 tickets"
				break
			}
			if keep == nil || keep(b) {
				got = append(got, b)
				left--
			}
		}
		return got, nil
	}
	var err error
	if out.Needs, err = take("needs", nil); err != nil {
		return out, err
	}
	if out.Running, err = take("running", nil); err != nil {
		return out, err
	}
	if out.Queue, err = take("queue", nil); err != nil {
		return out, err
	}
	since := time.Now().AddDate(0, 0, -snapTicketDays)
	out.Done, err = take("done", func(b TicketBrief) bool {
		at, err := time.Parse(time.RFC3339, b.InStateSince)
		return err != nil || at.After(since)
	})
	return out, err
}

// trimTicket keeps a ticket's long texts short enough for a phone answer.
func trimTicket(t TicketOut) TicketOut {
	t.Description = truncateBytes(t.Description, snapTextBytes)
	t.Analysis = truncateBytes(t.Analysis, snapTextBytes)
	t.Report = truncateBytes(t.Report, snapTextBytes)
	t.Summary = truncateBytes(t.Summary, snapTextBytes)
	if len(t.History) > 30 {
		t.History = t.History[len(t.History)-30:]
	}
	return t
}

// truncateBytes cuts s to at most n bytes on a rune boundary.
func truncateBytes(s string, n int) string {
	if len(s) <= n {
		return s
	}
	cut := n
	for cut > 0 && !utf8RuneStart(s[cut]) {
		cut--
	}
	return s[:cut] + "\n…(cut)"
}

func utf8RuneStart(b byte) bool { return b&0xC0 != 0x80 }
