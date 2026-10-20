package postgres

import (
	"slices"
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestCommitLinks(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	s := NewAgent(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	newTicket := func(key, number string) domain.Ticket {
		tk, err := s.CreateTicket(ctx, domain.Ticket{Key: key, TicketNumber: number, Source: domain.SourceLocal, Kind: domain.KindCode, RepoID: &repo.ID,
			Title: "t " + key, Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"},
			domain.Event{TicketKey: key, Type: domain.EventTicketCreated})
		if err != nil {
			t.Fatal(err)
		}
		return tk
	}
	a := newTicket("CL-1", "AMANAT-2288")
	b := newTicket("CL-2", "")

	found, err := s.TicketsByTokens(ctx, []string{"amanat-2288", "cl-2", "nope-1"})
	if err != nil || len(found) != 2 {
		t.Fatalf("by tokens: %+v %v", found, err)
	}
	if found, _ := s.TicketsByTokens(other, []string{"amanat-2288"}); len(found) != 0 {
		t.Fatalf("another workspace finds the ticket: %+v", found)
	}

	at := time.Date(2026, 10, 1, 12, 0, 0, 0, time.UTC)
	link := func(tk domain.Ticket, sha, token string, on ...string) domain.CommitLink {
		return domain.CommitLink{TicketID: tk.ID, RepoID: repo.ID, SHA: sha, Branch: "feature/AMANAT-2288", Subject: "fix " + sha,
			Author: "Alice", AuthorLogin: "alice", URL: "https://github.com/a/api/commit/" + sha, CommittedAt: at, MatchedOn: on, Token: token}
	}
	added, err := s.UpsertCommitLinks(ctx, []domain.CommitLink{
		link(a, "aaa", "amanat-2288", domain.MatchBranch),
		link(a, "bbb", "amanat-2288", domain.MatchBranch),
		link(b, "bbb", "cl-2", domain.MatchMessage),
	})
	if err != nil || added[a.ID] != 2 || added[b.ID] != 1 {
		t.Fatalf("upsert: %v %v", added, err)
	}
	// The same commit again, now matched on its message too: no new link,
	// matched_on gains message.
	added, err = s.UpsertCommitLinks(ctx, []domain.CommitLink{link(a, "aaa", "amanat-2288", domain.MatchMessage)})
	if err != nil || added[a.ID] != 0 {
		t.Fatalf("upsert again: %v %v", added, err)
	}
	links, total, err := s.CommitLinksOfTicket(ctx, a.ID, 10, 0)
	if err != nil || total != 2 || len(links) != 2 {
		t.Fatalf("links: %+v %d %v", links, total, err)
	}
	var aaa domain.CommitLink
	for _, l := range links {
		if l.SHA == "aaa" {
			aaa = l
		}
	}
	if !slices.Equal(aaa.MatchedOn, []string{"branch", "message"}) || aaa.TicketKey != "CL-1" || aaa.RepoName != "api" {
		t.Fatalf("merged link: %+v", aaa)
	}
	if links, total, _ := s.CommitLinksOfTicket(ctx, a.ID, 1, 1); total != 2 || len(links) != 1 {
		t.Fatalf("page: %+v %d", links, total)
	}

	byCommit, err := s.TicketsOfCommits(ctx, repo.ID, []string{"BBB", "aaa", "ccc"})
	if err != nil || len(byCommit["bbb"]) != 2 || len(byCommit["aaa"]) != 1 || byCommit["aaa"][0].Number != "AMANAT-2288" {
		t.Fatalf("tickets of commits: %+v %v", byCommit, err)
	}
	if byCommit, _ := s.TicketsOfCommits(other, repo.ID, []string{"aaa"}); len(byCommit) != 0 {
		t.Fatalf("another workspace sees the links: %+v", byCommit)
	}

	if err := s.DeleteCommitLinksByToken(ctx, a.ID, "AMANAT-2288"); err != nil {
		t.Fatal(err)
	}
	if _, total, _ := s.CommitLinksOfTicket(ctx, a.ID, 10, 0); total != 0 {
		t.Fatalf("after delete: %d", total)
	}
	if _, total, _ := s.CommitLinksOfTicket(ctx, b.ID, 10, 0); total != 1 {
		t.Fatalf("the other ticket's link went too: %d", total)
	}
}
