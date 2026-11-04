package meetings

import (
	"context"
	"fmt"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Draft tickets: when a session's notes are written, each action item
// finds the member who took it (domain.MatchMember on the name as said,
// or on who said it when they took it themself) and becomes a held ticket
// of theirs, so nothing runs until someone starts it. See
// plans/Meeting tasks plan.md.

// settleActionItems matches a session's action items to members and
// makes the draft tickets of the ones that have none yet.
func (s *Service) settleActionItems(ctx context.Context, x domain.MeetingSession, m domain.Meeting) {
	log := s.d.Log.With("workspace", x.WorkspaceID, "session", x.ID)
	items, err := s.d.Store.ActionItems(ctx, x.ID)
	if err != nil || len(items) == 0 {
		if err != nil {
			log.Warn("action items", "err", err)
		}
		return
	}
	cands, err := s.d.Store.NameCandidates(ctx, x.ID)
	if err != nil {
		log.Warn("action items: who may take them", "err", err)
		return
	}
	matched := false
	for _, it := range items {
		if it.WhoUserID != nil || it.WhoSetBy != nil {
			continue
		}
		said := it.Who
		if domain.IsSelf(said) {
			said = it.Speaker
		}
		uid, ok := domain.MatchMember(said, cands)
		if !ok {
			continue
		}
		if err := s.d.Store.SetActionItemMember(ctx, it.ID, &uid, 0); err != nil {
			log.Warn("action item member", "item", it.ID, "err", err)
			continue
		}
		matched = true
	}
	if s.d.Tickets == nil || !s.settings(ctx).DraftTickets {
		return
	}
	if matched { // read the members' names for the tickets
		if items, err = s.d.Store.ActionItems(ctx, x.ID); err != nil {
			log.Warn("action items", "err", err)
			return
		}
	}
	by := x.NotesBy
	if by == nil {
		by = m.HostID
	}
	// Nobody acts: the ticket's member is the one matched, or none.
	ctx = domain.WithActor(ctx, domain.Actor{})
	for _, it := range items {
		if it.TicketID != nil || it.Drafted {
			continue
		}
		t, err := s.itemTicket(ctx, m, x, it, "queue", by, domain.OriginSystem, 0)
		if err != nil {
			log.Warn("draft ticket of an action item", "item", it.ID, "err", err)
			continue
		}
		var byID int64
		if by != nil {
			byID = *by
		}
		if ok, err := s.d.Store.SetActionItemTicket(ctx, it.ID, t.ID, byID); err != nil || !ok {
			log.Warn("an action item's draft ticket was not linked", "item", it.ID, "ticket", t.Key, "err", err)
		}
		if err := s.d.Store.SetActionItemsDrafted(ctx, []int64{it.ID}, true); err != nil {
			log.Warn("mark action item drafted", "item", it.ID, "err", err)
		}
	}
}

// itemTicket makes a ticket of an action item, on the member who takes it.
func (s *Service) itemTicket(ctx context.Context, m domain.Meeting, x domain.MeetingSession, it domain.ActionItem, start string,
	by *int64, origin domain.Origin, repoID int64) (domain.Ticket, error) {
	return s.d.Tickets.CreateTask(ctx, orchestrator.TaskInput{RepoID: repoID, Kind: "auto", Title: it.Text,
		Description: s.itemDescription(ctx, m, x, it), Priority: "medium", AfterApprove: "pr", Start: start,
		MemberID: it.WhoUserID, CreatedBy: by}, origin)
}

// dropUntouchedDrafts deletes the draft tickets of a session nobody has
// worked on (still held and new, its title as made, its member as
// matched), before the notes are written again: the new notes bring their
// own. Their items forget they were drafted, so they are drafted again if
// the new notes fail and keep them.
func (s *Service) dropUntouchedDrafts(ctx context.Context, sessionID int64) error {
	if s.d.Tickets == nil {
		return nil
	}
	items, err := s.d.Store.ActionItems(ctx, sessionID)
	if err != nil {
		return err
	}
	var dropped []int64
	for _, it := range items {
		if !it.Drafted || it.TicketID == nil || it.WhoSetBy != nil {
			continue
		}
		t, err := s.d.Tickets.TicketByKey(ctx, it.TicketKey)
		if err != nil || !t.Held || t.State != domain.StateNew || t.Title != it.Text {
			continue
		}
		if err := s.d.Tickets.DeleteTask(ctx, t.Key, domain.OriginSystem); err != nil {
			s.d.Log.Warn("drop a draft ticket before the notes are written again", "ticket", t.Key, "err", err)
			continue
		}
		dropped = append(dropped, it.ID)
	}
	if len(dropped) == 0 {
		return nil
	}
	return s.d.Store.SetActionItemsDrafted(ctx, dropped, false)
}

// SetActionItemMember picks the member who takes an action item by hand;
// its ticket, if it has one, becomes theirs too.
func (s *Service) SetActionItemMember(ctx context.Context, c Caller, meetingID, sessionID, itemID, userID int64, origin domain.Origin) (domain.ActionItem, error) {
	if !c.Role.CanEdit() {
		return domain.ActionItem{}, forbidden("viewers can't change action items")
	}
	_, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return domain.ActionItem{}, err
	}
	it, err := s.d.Store.ActionItem(ctx, itemID)
	if err != nil || it.SessionID != x.ID {
		return domain.ActionItem{}, domain.ErrNotFound
	}
	if role, err := s.d.Workspaces.Role(ctx, c.WorkspaceID, userID); err != nil || role == "" {
		return domain.ActionItem{}, invalid("that person is not a member of this workspace")
	}
	if err := s.d.Store.SetActionItemMember(ctx, it.ID, &userID, c.UserID); err != nil {
		return domain.ActionItem{}, err
	}
	if it.TicketKey != "" && s.d.Tickets != nil {
		u, err := s.d.Users.ByID(ctx, userID)
		if err != nil {
			return domain.ActionItem{}, err
		}
		name := u.DisplayName
		if name == "" {
			name = u.Username
		}
		if _, err := s.d.Tickets.SetMember(ctx, it.TicketKey, userID, name, origin); err != nil {
			return domain.ActionItem{}, fmt.Errorf("the ticket %s: %w", it.TicketKey, err)
		}
	}
	return s.d.Store.ActionItem(ctx, it.ID)
}
