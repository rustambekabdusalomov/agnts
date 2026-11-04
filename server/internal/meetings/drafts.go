package meetings

import (
	"context"
	"fmt"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Drafts: when a session's notes are written, each action item finds the
// member who took it (domain.MatchMember on the name as said, or on who
// said it when they took it themself). It stays a draft inside the
// meeting, with no ticket, until someone approves it on the session page
// (ActionItemTicket): only then is it a ticket of that member's. See
// plans/Meeting tasks plan.md.

// settleActionItems matches a session's action items to members.
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

// returnHeldDrafts turns the draft tickets made before drafts stayed in the
// meeting back into drafts: each ticket nobody has worked on (still held
// and new, its title as made) is deleted, and its item, which keeps its
// member, waits on the session page to be approved. Tickets someone has
// started or renamed stay tickets (and are looked at again on the next
// start, which leaves them). ctx is system work.
func (s *Service) returnHeldDrafts(ctx context.Context) {
	if s.d.Tickets == nil {
		return
	}
	xs, err := s.d.Store.DraftedSessions(ctx)
	if err != nil {
		s.d.Log.Warn("meeting drafts made as tickets", "err", err)
		return
	}
	for _, x := range xs {
		wctx := domain.WithActor(domain.WithWorkspace(ctx, x.WorkspaceID), domain.Actor{})
		n, err := s.dropDrafts(wctx, x.ID, false)
		if err != nil {
			s.d.Log.Warn("return a session's draft tickets to the meeting", "workspace", x.WorkspaceID, "session", x.ID, "err", err)
		} else if n > 0 {
			s.d.Log.Info("returned draft tickets to the meeting", "workspace", x.WorkspaceID, "session", x.ID, "count", n)
		}
	}
}

// dropUntouchedDrafts deletes the draft tickets made before drafts stayed
// in the meeting (items marked drafted) that nobody has worked on (still
// held and new, its title as made, its member as matched), before the
// notes are written again: the new notes bring their own.
func (s *Service) dropUntouchedDrafts(ctx context.Context, sessionID int64) error {
	_, err := s.dropDrafts(ctx, sessionID, true)
	return err
}

// dropDrafts deletes a session's draft tickets that are still held, new
// and titled as made, and those whose member was picked by hand unless
// keepPicked. Their items forget they were drafted.
func (s *Service) dropDrafts(ctx context.Context, sessionID int64, keepPicked bool) (int, error) {
	if s.d.Tickets == nil {
		return 0, nil
	}
	items, err := s.d.Store.ActionItems(ctx, sessionID)
	if err != nil {
		return 0, err
	}
	var dropped []int64
	for _, it := range items {
		if !it.Drafted || it.TicketID == nil || (keepPicked && it.WhoSetBy != nil) {
			continue
		}
		t, err := s.d.Tickets.TicketByKey(ctx, it.TicketKey)
		if err != nil || !t.Held || t.State != domain.StateNew || t.Title != it.Text {
			continue
		}
		if err := s.d.Tickets.DeleteTask(ctx, t.Key, domain.OriginSystem); err != nil {
			s.d.Log.Warn("drop an untouched draft ticket", "ticket", t.Key, "err", err)
			continue
		}
		dropped = append(dropped, it.ID)
	}
	if len(dropped) == 0 {
		return 0, nil
	}
	return len(dropped), s.d.Store.SetActionItemsDrafted(ctx, dropped, false)
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
