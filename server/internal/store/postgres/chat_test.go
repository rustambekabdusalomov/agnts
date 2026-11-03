package postgres

import (
	"errors"
	"fmt"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestChatStore(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	c := NewChat(users.db)
	agent := NewAgent(users.db)
	ann, err := users.Create(ctx, domain.User{Username: "ann-chat", PasswordHash: "h"})
	if err != nil {
		t.Fatal(err)
	}
	ctx = domain.WithActor(ctx, domain.Actor{UserID: ann.ID, Username: ann.Username})

	// The first list makes #general, agnts's channel.
	cs, err := c.Channels(ctx, ann.ID)
	if err != nil || len(cs) != 1 || cs[0].Name != "general" || !cs[0].Agents {
		t.Fatalf("channels %v %+v", err, cs)
	}
	general := cs[0]
	pay, err := c.CreateChannel(ctx, "payments", "money", false, ann.ID)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := c.CreateChannel(ctx, "payments", "", false, ann.ID); !errors.Is(err, ErrChatDuplicate) {
		t.Fatalf("duplicate channel: %v", err)
	}

	// A resend with the same client id is the same message, with no new jobs.
	before, _ := agent.MaxEventID(domain.System(ctx))
	in := domain.ChatSend{ChannelID: pay.ID, ClientMsgID: "7d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11", Body: "the CSV export on payments times out again"}
	m1, created, err := c.Send(ctx, ann.ID, in, []string{ChatJobLink, ChatJobAnswer})
	if err != nil || !created || m1.Author != "ann-chat" || m1.Kind != domain.ChatKindText {
		t.Fatalf("send %v %v %+v", err, created, m1)
	}
	m2, created, err := c.Send(ctx, ann.ID, in, []string{ChatJobLink})
	if err != nil || created || m2.ID != m1.ID {
		t.Fatalf("resend %v %v %+v", err, created, m2)
	}
	evs, _ := agent.Events(domain.System(ctx), orchestrator.EventFilter{AfterID: before, Limit: 50})
	n := 0
	for _, e := range evs {
		if e.Type == domain.EventChatMessage {
			n++
			msg, _ := e.Data["message"].(map[string]any)
			if msg["body"] != in.Body || e.WorkspaceID != ws {
				t.Fatalf("event %+v", e)
			}
		}
	}
	if n != 1 {
		t.Fatalf("%d message events, want 1", n)
	}
	if _, _, err := c.Send(ctx, ann.ID, domain.ChatSend{ChannelID: 999999, ClientMsgID: "8d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11", Body: "x"}, nil); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("no such channel: %v", err)
	}

	// Paging: newest, before, after (a reconnect filling its gap).
	for i := range 5 {
		if _, _, err := c.Send(ctx, ann.ID, domain.ChatSend{ChannelID: pay.ID, ClientMsgID: fmt.Sprintf("00000000-0000-4000-8000-%012d", i), Body: fmt.Sprintf("m%d", i)}, nil); err != nil {
			t.Fatal(err)
		}
	}
	page, _ := c.Messages(ctx, pay.ID, 0, 0, 3)
	if len(page) != 3 || page[2].Body != "m4" || page[0].Body != "m2" {
		t.Fatalf("newest page %+v", page)
	}
	older, _ := c.Messages(ctx, pay.ID, page[0].ID, 0, 10)
	if len(older) != 3 || older[0].ID != m1.ID {
		t.Fatalf("older page %+v", older)
	}
	gap, _ := c.Messages(ctx, pay.ID, 0, older[1].ID, 10)
	if len(gap) != 4 || gap[0].Body != "m1" {
		t.Fatalf("gap %+v", gap)
	}

	// Jobs: the outbox, retried with a backoff, then failed.
	j, ok, err := c.TakeJob(domain.System(ctx))
	if err != nil || !ok || j.MessageID != m1.ID || j.Kind != ChatJobLink || j.WorkspaceID != ws || j.UserID != ann.ID {
		t.Fatalf("take %v %v %+v", err, ok, j)
	}
	if err := c.FinishJob(ctx, j, nil, 3); err != nil {
		t.Fatal(err)
	}
	j2, ok, _ := c.TakeJob(domain.System(ctx))
	if !ok || j2.Kind != ChatJobAnswer {
		t.Fatalf("second job %+v", j2)
	}
	if err := c.FinishJob(ctx, j2, errors.New("model down"), 3); err != nil {
		t.Fatal(err)
	}
	if _, ok, _ := c.TakeJob(domain.System(ctx)); ok {
		t.Fatal("a retried job must wait for its backoff")
	}
	if n, _ := c.JobsToday(ctx, ChatJobAnswer); n != 1 {
		t.Fatalf("answers today %d", n)
	}

	// agnts's card, changed under a lock; its ticket's cards.
	card, err := c.Post(ctx, domain.ChatMessage{ChannelID: general.ID, Kind: domain.ChatKindCard, TicketKey: "PAY-1",
		Card: &domain.ChatCard{Type: domain.CardReviewReady, State: domain.CardOpen, Title: "PAY-1 is ready", Actions: []string{domain.CardApprove}, Data: map[string]any{"key": "PAY-1"}},
		Refs: []domain.ChatRef{{Type: domain.RefTicket, ID: "PAY-1", Source: domain.RefCard, Confidence: 1}}})
	if err != nil || card.Author != domain.ChatAgent || len(card.Refs) != 1 {
		t.Fatalf("post %v %+v", err, card)
	}
	upd, err := c.Update(ctx, card.ID, func(m *domain.ChatMessage) error { m.Card.State = domain.CardDone; m.Card.By = "ann-chat"; return nil })
	if err != nil || upd.Card.State != domain.CardDone {
		t.Fatalf("update %v %+v", err, upd)
	}
	if _, err := c.Update(ctx, m1.ID, func(*domain.ChatMessage) error { return nil }); err == nil {
		t.Fatal("agnts must not change a person's message")
	}
	if cards, _ := c.CardsOf(ctx, "PAY-1"); len(cards) != 1 || cards[0].Card.By != "ann-chat" {
		t.Fatalf("cards of PAY-1 %+v", cards)
	}

	// Refs: a removed link stays removed.
	ref := domain.ChatRef{Type: domain.RefTicket, ID: "PAY-1", Source: domain.RefModel, Confidence: 0.9, Reason: "mentions the export",
		AI: &domain.ChatAI{Provider: "muse", Model: "spark", MS: 1200}}
	got, err := c.AddRefs(ctx, m1.ID, []domain.ChatRef{ref})
	if err != nil || len(got.Refs) != 1 || got.Refs[0].AI == nil || got.Refs[0].AI.MS != 1200 {
		t.Fatalf("add refs %v %+v", err, got.Refs)
	}
	if got, _ = c.RemoveRef(ctx, m1.ID, "ticket", "PAY-1"); len(got.Refs) != 0 {
		t.Fatalf("removed ref still shown %+v", got.Refs)
	}
	if got, _ = c.AddRefs(ctx, m1.ID, []domain.ChatRef{ref}); len(got.Refs) != 0 {
		t.Fatalf("a removed ref came back %+v", got.Refs)
	}
	if shared, _ := c.MessagesSharingRefs(ctx, []domain.ChatRef{{Type: "ticket", ID: "PAY-1"}}, 0, 10); len(shared) != 1 || shared[0].ID != card.ID {
		t.Fatalf("sharing refs %+v", shared)
	}

	// Full-text search, in any language.
	if _, _, err := c.Send(ctx, ann.ID, domain.ChatSend{ChannelID: pay.ID, ClientMsgID: "9d9f6a0e-4f6b-4a43-9a4b-1f0f8c6c2a11", Body: "экспорт CSV падает по таймауту"}, nil); err != nil {
		t.Fatal(err)
	}
	if hits, _ := c.SearchMessages(ctx, "why does the CSV export time out?", 10); len(hits) < 2 {
		t.Fatalf("search hits %d", len(hits))
	}
	if hits, _ := c.SearchMessages(ctx, "экспорт", 10); len(hits) != 1 {
		t.Fatalf("russian search hits %d", len(hits))
	}

	// Unread counts skip one's own messages; reads never move back.
	bob, _ := users.Create(ctx, domain.User{Username: "bob-chat", PasswordHash: "h"})
	cs, _ = c.Channels(ctx, bob.ID)
	for _, ch := range cs {
		if ch.ID == pay.ID && ch.Unread != 7 {
			t.Fatalf("bob's unread %d", ch.Unread)
		}
	}
	_ = c.MarkRead(ctx, bob.ID, pay.ID, gap[len(gap)-1].ID)
	_ = c.MarkRead(ctx, bob.ID, pay.ID, 1)
	cs, _ = c.Channels(ctx, bob.ID)
	for _, ch := range cs {
		if ch.ID == pay.ID && ch.Unread != 1 {
			t.Fatalf("bob's unread after reading %d", ch.Unread)
		}
	}

	// Another workspace sees none of it.
	other, _ := testWS(t, users)
	if _, err := c.Channel(other, pay.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("other workspace reads the channel: %v", err)
	}
	if ms, _ := c.Messages(other, pay.ID, 0, 0, 10); len(ms) != 0 {
		t.Fatalf("other workspace reads %d messages", len(ms))
	}
	if ws2, _ := c.OpenPRWorkspaces(domain.System(ctx)); len(ws2) != 0 {
		t.Fatalf("open PR workspaces %v", ws2)
	}
	if st, err := c.Stats(ctx); err != nil || st.Links != 0 || st.MedianMS != 1200 {
		t.Fatalf("stats %v %+v", err, st)
	}
}

func TestChatSearchQuery(t *testing.T) {
	for in, want := range map[string]string{
		"why did the CSV export break last week?":       "csv:* | export:* | break:*",
		"@agnts how is auth implemented on api_gateway": "auth:* | implemented:* | api_gateway:*",
		"a b": "",
	} {
		if got := searchQuery(in); got != want {
			t.Errorf("searchQuery(%q) = %q, want %q", in, got, want)
		}
	}
}
