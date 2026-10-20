package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
)

type fakeLinks struct{ limit, offset int }

func (f *fakeLinks) TicketByKey(_ context.Context, key string) (domain.Ticket, error) {
	if key != "PAY-1" {
		return domain.Ticket{}, domain.ErrNotFound
	}
	return domain.Ticket{ID: 7, Key: key}, nil
}

func (f *fakeLinks) CommitLinksOfTicket(_ context.Context, ticketID int64, limit, offset int) ([]domain.CommitLink, int, error) {
	f.limit, f.offset = limit, offset
	return []domain.CommitLink{{TicketID: ticketID, TicketKey: "PAY-1", RepoID: 3, RepoName: "api", SHA: "0123456789abcdef", Branch: "feature/AMANAT-1",
		Subject: "AMANAT-1: fix", Author: "Alice", AuthorLogin: "alice", URL: "https://github.com/a/api/commit/0123456789abcdef",
		CommittedAt: time.Date(2026, 10, 20, 9, 0, 0, 0, time.UTC), MatchedOn: []string{"branch", "message"}, Token: "amanat-1"}}, 41, nil
}

func (f *fakeLinks) TicketsOfCommits(context.Context, int64, []string) (map[string][]domain.LinkedTicket, error) {
	return nil, nil
}

func TestListTicketLinkedCommits(t *testing.T) {
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)

	rec := h.do("GET", "/api/tickets/PAY-1/linked-commits?limit=5&offset=10", "", cookie)
	if rec.Code != http.StatusOK || h.links.limit != 5 || h.links.offset != 10 {
		t.Fatalf("list: %d %s (limit %d offset %d)", rec.Code, rec.Body, h.links.limit, h.links.offset)
	}
	var out gen.LinkedCommits
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	if out.Total != 41 || len(out.Commits) != 1 {
		t.Fatalf("out: %+v", out)
	}
	c := out.Commits[0]
	if c.ShortSha != "01234567" || c.Repo != "api" || c.RepoId != 3 || c.AuthorLogin == nil || *c.AuthorLogin != "alice" || len(c.MatchedOn) != 2 ||
		c.MatchedOn[1] != gen.LinkedCommitMatchedOnMessage || c.Branch != "feature/AMANAT-1" {
		t.Fatalf("commit: %+v", c)
	}
	if rec := h.do("GET", "/api/tickets/PAY-1/linked-commits", "", cookie); rec.Code != http.StatusOK || h.links.limit != 20 || h.links.offset != 0 {
		t.Fatalf("defaults: %d limit %d offset %d", rec.Code, h.links.limit, h.links.offset)
	}
	if rec := h.do("GET", "/api/tickets/NOPE-1/linked-commits", "", cookie); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown ticket: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/tickets/PAY-1/linked-commits?limit=500", "", cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("limit over 100: %d", rec.Code)
	}
	if rec := h.do("GET", "/api/tickets/PAY-1/linked-commits", "", nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("signed out: %d", rec.Code)
	}
}

func TestToCommitTickets(t *testing.T) {
	msg := "OLD-1"
	if tickets, key := toCommitTickets(nil, &msg); tickets != nil || key != &msg {
		t.Fatal("no links keeps the key from the message")
	}
	tickets, key := toCommitTickets([]domain.LinkedTicket{{Key: "PAY-1", Number: "AMANAT-1", Title: "Fix", State: domain.StateDone}, {Key: "PAY-2"}}, &msg)
	if tickets == nil || len(*tickets) != 2 || *key != "PAY-1" || *(*tickets)[0].Number != "AMANAT-1" || (*tickets)[1].Number != nil {
		t.Fatalf("tickets: %+v %v", tickets, *key)
	}
}
