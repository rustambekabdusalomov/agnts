package commitlink

import (
	"context"
	"io"
	"log/slog"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
)

type memStore struct {
	repos   []domain.Repository
	tickets []domain.Ticket
	links   map[string]domain.CommitLink // ticket|repo|sha
	events  []domain.Event
}

func (m *memStore) ListRepositories(context.Context) ([]domain.Repository, error) {
	return m.repos, nil
}

func (m *memStore) TicketsByTokens(_ context.Context, tokens []string) ([]domain.Ticket, error) {
	var out []domain.Ticket
	for _, t := range m.tickets {
		if slices.Contains(tokens, strings.ToLower(t.Key)) || (t.TicketNumber != "" && slices.Contains(tokens, strings.ToLower(t.TicketNumber))) {
			out = append(out, t)
		}
	}
	return out, nil
}

func linkID(l domain.CommitLink) string {
	return strconv.FormatInt(l.TicketID, 10) + "|" + strconv.FormatInt(l.RepoID, 10) + "|" + l.SHA
}

func (m *memStore) UpsertCommitLinks(_ context.Context, links []domain.CommitLink) (map[int64]int, error) {
	added := map[int64]int{}
	for _, l := range links {
		id := linkID(l)
		if cur, ok := m.links[id]; ok {
			for _, on := range l.MatchedOn {
				if !slices.Contains(cur.MatchedOn, on) {
					cur.MatchedOn = append(cur.MatchedOn, on)
				}
			}
			slices.Sort(cur.MatchedOn)
			m.links[id] = cur
			continue
		}
		m.links[id] = l
		added[l.TicketID]++
	}
	return added, nil
}

func (m *memStore) DeleteCommitLinksByToken(_ context.Context, ticketID int64, token string) error {
	for id, l := range m.links {
		if l.TicketID == ticketID && l.Token == token {
			delete(m.links, id)
		}
	}
	return nil
}

func (m *memStore) AppendEvent(_ context.Context, ev domain.Event) error {
	m.events = append(m.events, ev)
	return nil
}

func (m *memStore) linksOf(ticketID int64) []domain.CommitLink {
	var out []domain.CommitLink
	for _, l := range m.links {
		if l.TicketID == ticketID {
			out = append(out, l)
		}
	}
	slices.SortFunc(out, func(a, b domain.CommitLink) int { return strings.Compare(a.SHA, b.SHA) })
	return out
}

type fakeHost struct {
	branches []string
	history  []domain.PushedCommit
	ahead    map[string][]domain.PushedCommit // base..head
	calls    []string
}

func (h *fakeHost) BranchNames(context.Context, domain.Repository, int) ([]string, error) {
	h.calls = append(h.calls, "branches")
	return h.branches, nil
}

func (h *fakeHost) History(_ context.Context, _ domain.Repository, ref string, page, perPage int) ([]domain.PushedCommit, error) {
	h.calls = append(h.calls, "history:"+ref)
	from := (page - 1) * perPage
	if from >= len(h.history) {
		return nil, nil
	}
	return h.history[from:min(len(h.history), from+perPage)], nil
}

func (h *fakeHost) Ahead(_ context.Context, _ domain.Repository, base, head string) ([]domain.PushedCommit, error) {
	h.calls = append(h.calls, "ahead:"+base+".."+head)
	return h.ahead[base+".."+head], nil
}

func setup() (*Service, *memStore, *fakeHost) {
	now := time.Now()
	st := &memStore{
		repos: []domain.Repository{{ID: 1, Name: "api", Provider: "github", CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}},
		tickets: []domain.Ticket{
			{ID: 1, Key: "VIS-1", TicketNumber: "AMANAT-2288", State: domain.StateWaitingForReview, UpdatedAt: now},
			{ID: 2, Key: "VIS-2", TicketNumber: "AMANAT-2288", State: domain.StateDone, UpdatedAt: now},
			{ID: 3, Key: "VIS-3", State: domain.StateNew, UpdatedAt: now},
		},
		links: map[string]domain.CommitLink{},
	}
	h := &fakeHost{ahead: map[string][]domain.PushedCommit{}}
	s := New(st, h, slog.New(slog.NewTextHandler(io.Discard, nil)))
	s.async = func(f func()) { f() }
	return s, st, h
}

func commit(sha, msg string) domain.PushedCommit {
	return domain.PushedCommit{SHA: sha, Message: msg, Author: "Alice", AuthorLogin: "alice", Date: time.Now().Add(-time.Hour), URL: "https://x/" + sha}
}

func TestPushLinksBranchAndMessage(t *testing.T) {
	s, st, _ := setup()
	push := domain.Push{Provider: "github", Repo: "acme/api", Branch: "feature/amanat-2288-login", Before: "0000", After: "bbb", Pusher: "alice",
		Commits: []domain.PushedCommit{commit("AAA", "log in"), commit("bbb", "fix VIS-3 too")}}
	push.Total = len(push.Commits)
	if err := s.CommitsPushed(context.Background(), push); err != nil {
		t.Fatal(err)
	}
	// The open ticket with the number gets both commits, not the done one.
	got := st.linksOf(1)
	if len(got) != 2 || got[0].SHA != "aaa" || !slices.Equal(got[0].MatchedOn, []string{"branch"}) || got[0].Branch != "feature/amanat-2288-login" ||
		got[0].Subject != "log in" || got[0].Token != "amanat-2288" {
		t.Fatalf("ticket 1 links: %+v", got)
	}
	if len(st.linksOf(2)) != 0 {
		t.Fatal("the closed ticket with the same number got links")
	}
	if got := st.linksOf(3); len(got) != 1 || got[0].SHA != "bbb" || !slices.Equal(got[0].MatchedOn, []string{"message"}) {
		t.Fatalf("ticket 3 links: %+v", got)
	}
	if len(st.events) != 2 || st.events[0].TicketKey != "VIS-1" || st.events[0].Type != domain.EventCommitsLinked ||
		st.events[0].Message != "alice pushed 2 commits to feature/amanat-2288-login (api)" || st.events[1].Message != "alice pushed 1 commit to feature/amanat-2288-login (api)" {
		t.Fatalf("events: %+v", st.events)
	}
	// A redelivery adds nothing and tells no one.
	if err := s.Push(context.Background(), push); err != nil {
		t.Fatal(err)
	}
	if len(st.links) != 3 || len(st.events) != 2 {
		t.Fatalf("redelivery: %d links, %d events", len(st.links), len(st.events))
	}
}

func TestPushToDefaultBranchMatchesMessagesOnly(t *testing.T) {
	s, st, _ := setup()
	err := s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "main", Before: "a", After: "b",
		Commits: []domain.PushedCommit{commit("c1", "Merge branch 'feature/AMANAT-2288-login'"), commit("c2", "chore: bump")}, Total: 2})
	if err != nil {
		t.Fatal(err)
	}
	if got := st.linksOf(1); len(got) != 1 || got[0].SHA != "c1" || got[0].Branch != "main" {
		t.Fatalf("links: %+v", st.links)
	}
	// Unknown repositories and deletions are ignored.
	_ = s.Push(context.Background(), domain.Push{Provider: "gitlab", Repo: "acme/api", Branch: "VIS-3", After: "x", Commits: []domain.PushedCommit{commit("d", "x")}, Total: 1})
	_ = s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "VIS-3", Before: "x", After: "0000", Total: 0})
	if len(st.links) != 1 {
		t.Fatalf("links: %+v", st.links)
	}
}

func TestPushReadsCommitsLeftOut(t *testing.T) {
	s, st, h := setup()
	h.ahead["main..tip"] = []domain.PushedCommit{commit("1", "a"), commit("2", "b"), commit("3", "c")}
	h.ahead["old..tip2"] = []domain.PushedCommit{commit("4", "a"), commit("5", "b")}
	_ = s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "VIS-3", Before: "000", After: "tip",
		Commits: []domain.PushedCommit{commit("3", "c")}, Total: 3})
	_ = s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "VIS-3", Before: "old", After: "tip2",
		Commits: []domain.PushedCommit{commit("5", "b")}, Total: 2})
	if !slices.Equal(h.calls, []string{"ahead:main..tip", "ahead:old..tip2"}) || len(st.linksOf(3)) != 5 {
		t.Fatalf("calls %v, links %+v", h.calls, st.linksOf(3))
	}
}

func TestScanTicketAndNumberChange(t *testing.T) {
	s, st, h := setup()
	h.branches = []string{"main", "feature/AMANAT-2288", "feature/VIS-3", "feature/NEW-7"}
	h.history = []domain.PushedCommit{commit("m1", "AMANAT-2288: on main"), commit("m2", "VIS-3 work"), commit("m3", "NEW-7 later")}
	h.ahead["main..feature/AMANAT-2288"] = []domain.PushedCommit{commit("b1", "wip")}
	h.ahead["main..feature/NEW-7"] = []domain.PushedCommit{commit("n1", "wip")}
	ctx := context.Background()

	s.TicketNumberChanged(ctx, st.tickets[0], "")
	got := st.linksOf(1)
	if len(got) != 2 || got[0].SHA != "b1" || got[1].SHA != "m1" {
		t.Fatalf("scan: %+v", got)
	}
	if len(st.linksOf(3)) != 0 {
		t.Fatal("a scan for one ticket linked another's commits")
	}
	if !slices.Contains(h.calls, "ahead:main..feature/AMANAT-2288") || slices.Contains(h.calls, "ahead:main..feature/VIS-3") {
		t.Fatalf("calls: %v", h.calls)
	}
	if len(st.events) != 1 || st.events[0].Message != "Linked 2 earlier commits found in api" || st.events[0].Origin != domain.OriginSystem {
		t.Fatalf("events: %+v", st.events)
	}

	// The number changes to NEW-7: links through the old number go, the
	// new number's commits come; the history is read once.
	st.tickets[0].TicketNumber = "NEW-7"
	s.TicketNumberChanged(ctx, st.tickets[0], "AMANAT-2288")
	got = st.linksOf(1)
	if len(got) != 2 || got[0].SHA != "m3" || got[1].SHA != "n1" || got[1].Token != "new-7" {
		t.Fatalf("after the change: %+v", got)
	}
	if n := slices.Index(h.calls, "branches"); n < 0 || slices.Index(h.calls[n+1:], "branches") >= 0 {
		t.Fatalf("the snapshot was read twice: %v", h.calls)
	}

	// A new repository is scanned for every ticket.
	s.RepositoryAdded(ctx, st.repos[0])
	if len(st.linksOf(3)) != 1 {
		t.Fatalf("repository scan: %+v", st.links)
	}
}

func TestSnapshotStopsAtOldCommits(t *testing.T) {
	s, _, h := setup()
	for i := range 250 {
		c := commit("c", "x")
		c.Date = time.Now().Add(-time.Duration(i) * 24 * time.Hour)
		h.history = append(h.history, c)
	}
	snap, err := s.snapshot(context.Background(), domain.Repository{ID: 9, DefaultBranch: "main"})
	if err != nil || len(snap.history) != 90 {
		t.Fatalf("history: %d %v", len(snap.history), err)
	}
}
