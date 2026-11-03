package chat

import (
	"context"
	"fmt"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Memory is what agnts knows about the workspace, read live when asked:
// tickets and their progress, pull requests, repositories (their briefs),
// log findings, and what the team said in the chat, with the links
// between them. It searches Postgres (refs and full-text), not an
// embedding index: questions name things (a ticket, a repo, a service)
// and the facts change by the minute.
type Memory interface {
	ChatCandidates(ctx context.Context) ([]postgres.ChatCandidate, error)
	TicketKeys(ctx context.Context, keys []string) (map[string]bool, error)
	RepoNames(ctx context.Context) (map[string]int64, error)
	SearchMessages(ctx context.Context, question string, limit int) ([]domain.ChatMessage, error)
	MessagesSharingRefs(ctx context.Context, refs []domain.ChatRef, except int64, limit int) ([]domain.ChatMessage, error)
	SearchTickets(ctx context.Context, question string, limit int) ([]string, error)
	Stats(ctx context.Context) (postgres.ChatStats, error)
}

var _ Memory = (*postgres.Chat)(nil)

// Item is one thing memory hands the model, with the id it cites it by.
type Item struct {
	ID    string `json:"id"` // "msg:812", "ticket:PAY-1", "pr:api#14", "repo:api", "finding:3"
	Title string `json:"title,omitempty"`
	Text  string `json:"text"`
	URL   string `json:"url,omitempty"`
}

// RecallFor is memory for a question asked outside the team chat (the
// assistant): what it names, then what the workspace knows about it.
func (s *Service) RecallFor(ctx context.Context, question string) ([]Item, error) {
	if s.Memory == nil {
		return nil, nil
	}
	refs, err := s.explicitRefs(ctx, question)
	if err != nil {
		return nil, err
	}
	return s.Recall(ctx, Query{Text: question, Refs: refs})
}

// Query is what to recall for.
type Query struct {
	Text   string
	Refs   []domain.ChatRef
	Except int64 // the question's own message
}

// Recall limits.
const (
	recallItems = 40
	recallChars = 24000
)

// Recall collects what the workspace knows about a question.
func (s *Service) Recall(ctx context.Context, q Query) ([]Item, error) {
	r := recall{s: s, ctx: ctx, seen: map[string]bool{}}
	cands, err := s.Memory.ChatCandidates(ctx)
	if err != nil {
		return nil, err
	}
	r.cands = cands
	// 1. What the question names, and their facts.
	refs := append([]domain.ChatRef{}, q.Refs...)
	for _, k := range r.searchTickets(q.Text) {
		refs = append(refs, domain.ChatRef{Type: domain.RefTicket, ID: k})
	}
	for _, ref := range refs {
		r.ref(ref)
	}
	// 2. What the team said about them.
	if ms, err := s.Memory.MessagesSharingRefs(ctx, q.Refs, q.Except, 30); err == nil {
		for _, m := range ms {
			r.msg(m)
		}
	}
	// 3. Messages with the question's words.
	if ms, err := s.Memory.SearchMessages(ctx, q.Text, 20); err == nil {
		for _, m := range ms {
			if m.ID != q.Except {
				r.msg(m)
			}
		}
	}
	// 4. The workspace at a glance: open tickets, repositories, open
	// findings, so "what is waiting" and "which repos" have an answer.
	for _, c := range cands {
		switch {
		case c.Type == domain.RefTicket && c.State != "done" && c.State != "rejected":
			r.add(Item{ID: c.Key(), Title: c.Title, Text: fmt.Sprintf("ticket %s %q, state %s, updated %s", c.ID, c.Title, c.State, day(c.At))})
		case c.Type == domain.RefRepo:
			r.add(Item{ID: c.Key(), Title: c.Title, Text: "repository " + c.Title})
		case c.Type == domain.RefFinding:
			r.add(Item{ID: c.Key(), Title: c.Title, Text: fmt.Sprintf("log finding %s: %s (%s), last seen %s", c.ID, c.Title, c.State, day(c.At))})
		}
	}
	return r.items, nil
}

type recall struct {
	s     *Service
	ctx   context.Context
	cands []postgres.ChatCandidate
	items []Item
	seen  map[string]bool
	chars int
}

func (r *recall) add(it Item) {
	if r.seen[it.ID] || len(r.items) >= recallItems {
		return
	}
	if r.chars+len(it.Text) > recallChars {
		if r.chars+400 > recallChars {
			return
		}
		it.Text = clip(it.Text, recallChars-r.chars)
	}
	r.seen[it.ID] = true
	r.chars += len(it.Text)
	r.items = append(r.items, it)
}

func (r *recall) searchTickets(q string) []string {
	ks, err := r.s.Memory.SearchTickets(r.ctx, q, 5)
	if err != nil {
		return nil
	}
	return ks
}

func (r *recall) ref(ref domain.ChatRef) {
	switch ref.Type {
	case domain.RefTicket:
		r.ticket(ref.ID)
	case domain.RefPR:
		for _, c := range r.cands {
			if c.Type == domain.RefPR && c.ID == ref.ID {
				r.add(Item{ID: c.Key(), Title: c.Title, URL: c.URL, Text: fmt.Sprintf("pull request %s (%s), %s, %s", c.ID, c.Title, c.State, day(c.At))})
				if k, _, ok := strings.Cut(c.Title, ": "); ok {
					r.ticket(k)
				}
			}
		}
	case domain.RefRepo:
		r.repo(ref.ID)
	case domain.RefFinding:
		if r.s.Logs == nil {
			return
		}
		id, _ := strconv.ParseInt(ref.ID, 10, 64)
		if f, err := r.s.Logs.Finding(r.ctx, id); err == nil {
			r.add(Item{ID: "finding:" + ref.ID, Title: f.Title, Text: fmt.Sprintf(
				"log finding %d in %s: %s. %s, severity %s, seen %d times, first %s, last %s, status %s%s. %s",
				f.ID, f.Service, f.Title, f.Category, f.Severity, f.Count, day(f.FirstSeenAt), day(f.LastSeenAt), f.Status,
				ifText(f.TicketKey != "", ", ticket "+f.TicketKey), f.Remediation)})
		}
	}
}

func (r *recall) ticket(key string) {
	if r.seen["ticket:"+key] {
		return
	}
	v, err := r.s.Tickets.View(r.ctx, key)
	if err != nil {
		return
	}
	r.add(ticketItem(v))
}

func ticketItem(v orchestrator.TicketView) Item {
	t := v.Ticket
	var b strings.Builder
	fmt.Fprintf(&b, "ticket %s %q (%s, %s), state %s", t.Key, t.Title, t.Kind, t.Priority, t.State)
	if v.RepoName != "" {
		fmt.Fprintf(&b, ", repository %s", v.RepoName)
	}
	if v.Member != "" {
		fmt.Fprintf(&b, ", member %s", v.Member)
	}
	if t.WaitMessage != "" {
		fmt.Fprintf(&b, ", waiting: %s", t.WaitMessage)
	}
	for _, r := range t.OpenedPRs() {
		st := "open"
		if r.MergedAt != nil {
			st = "merged " + day(*r.MergedAt)
		} else if r.ClosedAt != nil {
			st = "closed"
		}
		fmt.Fprintf(&b, ", PR %s#%d %s", r.RepoName, *r.PRNumber, st)
	}
	if v.Spend.CostUSD > 0 {
		fmt.Fprintf(&b, ", cost $%.2f", v.Spend.CostUSD)
	}
	if t.Description != "" {
		fmt.Fprintf(&b, ". Description: %s", clip(t.Description, 600))
	}
	if v.Analysis != nil && v.Analysis.Summary != "" {
		fmt.Fprintf(&b, ". Analysis: %s", clip(v.Analysis.Summary, 500))
	}
	if v.Result != nil {
		if s := resultSummary(v.Result); s != "" {
			fmt.Fprintf(&b, ". What agnts changed: %s", clip(s, 600))
		}
		if len(v.Result.Files) > 0 {
			var ps []string
			for i, f := range v.Result.Files {
				if i == 8 {
					break
				}
				ps = append(ps, f.Path)
			}
			fmt.Fprintf(&b, " (files: %s)", strings.Join(ps, ", "))
		}
	}
	for _, h := range lastHistory(v.History, 4) {
		fmt.Fprintf(&b, ". %s", h)
	}
	return Item{ID: "ticket:" + t.Key, Title: t.Title, Text: b.String()}
}

func lastHistory(hs []orchestrator.HistoryItem, n int) []string {
	var out []string
	for i := len(hs) - 1; i >= 0 && len(out) < n; i-- {
		h := hs[i]
		if h.Message == "" {
			continue
		}
		out = append(out, fmt.Sprintf("%s: %s", day(h.At), clip(h.Message, 160)))
	}
	return out
}

func (r *recall) repo(name string) {
	if r.seen["repo:"+name] || r.s.Brain == nil {
		return
	}
	names, err := r.s.Memory.RepoNames(r.ctx)
	if err != nil {
		return
	}
	id, ok := names[name]
	if !ok {
		return
	}
	text := "repository " + name
	if b, err := r.s.Brain.RepoBrief(r.ctx, id); err == nil && b.Body != "" {
		text += ". Its brief (agnts's survey of the code):\n" + clip(b.Body, 6000)
	} else {
		text += " (no brief yet: agnts has not surveyed its code)"
	}
	r.add(Item{ID: "repo:" + name, Title: name, Text: text})
}

func (r *recall) msg(m domain.ChatMessage) {
	body := m.Body
	if m.Card != nil {
		body = m.Card.Title + ": " + m.Card.Summary
		if m.Card.Result != "" {
			body += " (" + m.Card.Result + ")"
		}
	}
	if strings.TrimSpace(body) == "" {
		return
	}
	r.add(Item{ID: "msg:" + strconv.FormatInt(m.ID, 10), Title: m.Author,
		Text: fmt.Sprintf("%s wrote on %s: %s", m.Author, m.CreatedAt.UTC().Format("2006-01-02 15:04"), clip(body, 700))})
}

func day(t time.Time) string {
	if t.IsZero() {
		return "?"
	}
	return t.UTC().Format("2006-01-02")
}

func ifText(ok bool, s string) string {
	if ok {
		return s
	}
	return ""
}

// clip cuts s to at most n bytes on a rune boundary.
func clip(s string, n int) string {
	s = strings.TrimSpace(s)
	if len(s) <= n {
		return s
	}
	for n > 0 && !utf8.RuneStart(s[n]) {
		n--
	}
	return s[:n] + "…"
}

// render lays items out for a prompt.
func render(items []Item) string {
	var b strings.Builder
	for _, it := range items {
		fmt.Fprintf(&b, "[%s] %s\n\n", it.ID, it.Text)
	}
	return b.String()
}
