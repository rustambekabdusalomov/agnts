package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// CommitChange is one commit message ReapplyCommitFormat changes.
type CommitChange struct {
	RepoID   int64
	RepoName string
	SHA      string
	From, To string
	// Suggested: the change is worth making unasked, since the run that
	// made the commit described it, or the commit still has agnts's own
	// message. Off, it may undo a message a person wrote.
	Suggested bool
}

// ReapplyCommitFormat writes the messages of the commits agnts has not
// pushed yet again from the commit format in effect (the ticket's group's,
// else each repository's), with the type, scope and subject each coding run
// gave for its commit; a run that gave none falls back to the ticket's kind
// and title. For commits made before a format was set. number, when given,
// becomes the ticket's number ({number}) first. With dryRun nothing changes:
// the changes it would make come back. Repositories without a format are
// left as they are. only, when not nil, limits the changes made to those
// commits (by sha), as picked from a preview.
func (o *Orchestrator) ReapplyCommitFormat(ctx context.Context, key string, number *string, dryRun bool, only []string, origin domain.Origin) ([]CommitChange, domain.Ticket, error) {
	cr, ok := o.git.(CommitRewriter)
	if !ok {
		return nil, domain.Ticket{}, invalid("this server cannot change commit messages")
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return nil, t, err
	}
	cur := t
	if number != nil {
		if t.TicketNumber, err = o.ticketNumber(ctx, number, key); err != nil {
			return nil, cur, err
		}
	}
	rs, err := o.reposFor(ctx, t)
	if err != nil {
		return nil, cur, err
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return nil, cur, err
	}
	runs, err := o.store.RunCommits(ctx, t.ID)
	if err != nil {
		return nil, cur, err
	}

	var changes []CommitChange
	var refusal error
	formatted := false
	for _, r := range rs {
		if r.Frozen {
			continue
		}
		if err := cannotRewrite(t, r.Row, "re-apply the commit format"); err != nil {
			refusal = cmpErr(refusal, err)
			continue
		}
		if r.CommitTemplate == "" {
			continue
		}
		formatted = true
		cs, err := cr.BranchCommits(ctx, r.Repository, r.Branch)
		if err != nil {
			return nil, cur, fmt.Errorf("read the commits of %s: %w", r.Name, err)
		}
		for _, c := range cs {
			info := runCommitAt(runs, c.When)
			msg := commitMessage(t, r.CommitTemplate, info, s.Git)
			if msg != c.Message {
				own := strings.HasPrefix(c.Message, t.Key+": "+t.Title)
				changes = append(changes, CommitChange{RepoID: r.ID, RepoName: r.Name, SHA: c.SHA, From: c.Message, To: msg,
					Suggested: info != (domain.CommitInfo{}) || own})
			}
		}
	}
	switch {
	case !formatted && refusal != nil:
		return nil, cur, refusal
	case !formatted:
		return nil, cur, invalid("there is no commit message format to apply: set one under Repositories → the repository (or its group) → Commit message format")
	case dryRun:
		return changes, cur, nil
	}
	if only != nil {
		var picked []CommitChange
		for _, sha := range only {
			i := slices.IndexFunc(changes, func(c CommitChange) bool { return c.SHA == sha })
			if i < 0 {
				return nil, cur, invalid("%s is not among the changes to make: look at the preview again", shortSHA(sha))
			}
			picked = append(picked, changes[i])
		}
		changes = picked
	}
	if len(changes) == 0 && t.TicketNumber == cur.TicketNumber {
		return changes, cur, nil
	}

	heads := map[int64]string{}
	for _, r := range rs {
		msgs := map[string]string{}
		for _, c := range changes {
			if c.RepoID == r.ID {
				msgs[c.SHA] = c.To
			}
		}
		if len(msgs) == 0 {
			continue
		}
		head, err := cr.RewordCommits(ctx, r.Repository, r.Branch, msgs)
		if errors.Is(err, domain.ErrNotFound) {
			return nil, cur, invalid("the commits on %s changed since the preview: look again and retry", r.Branch)
		}
		if err != nil {
			return nil, cur, err
		}
		heads[r.ID] = head
	}
	msg := fmt.Sprintf("commit format re-applied: %d %s", len(changes), plural(len(changes), "message", "messages"))
	if t.TicketNumber != cur.TicketNumber {
		msg += ", ticket number " + t.TicketNumber
	}
	nt, err := o.store.UpdateTicket(ctx, key, &domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: msg,
		Data: map[string]any{"commits": len(changes), "number": t.TicketNumber}}, func(x *domain.Ticket) {
		x.TicketNumber = t.TicketNumber
		for id, head := range heads {
			x.UpdateRepo(id, func(r *domain.TicketRepo) { r.HeadSHA = head })
		}
	})
	return changes, nt, err
}

// runCommitAt is the commit the coding run that made a commit at when
// described: agnts commits just before it saves the run's result, so the
// first result saved from then on. Empty when none is.
func runCommitAt(runs []domain.RunCommit, when time.Time) domain.CommitInfo {
	for _, rc := range runs {
		if !rc.At.Before(when.Add(-5 * time.Second)) {
			return rc.Info
		}
	}
	return domain.CommitInfo{}
}

// cmpErr keeps the first error.
func cmpErr(first, next error) error {
	if first != nil {
		return first
	}
	return next
}
