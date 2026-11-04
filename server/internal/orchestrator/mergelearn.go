package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"sort"
	"strings"

	"agnts/internal/domain"
)

// What people change in agnts's work before they merge it is the plainest
// lesson there is: a helper swapped in, logic moved to another layer, a
// test added. agnts compares its last version with what merged, records
// how much people changed, and has a reflect run learn from it.

// minPeopleEdits is how many meaningful lines people must have added or
// removed before a merge is worth learning from.
const minPeopleEdits = 3

// peopleEdits compares agnts's change with the merged one: per file, the
// meaningful lines people added and the ones of agnts's they removed.
type peopleEdit struct {
	Path           string
	Added, Removed []string
}

func diffPeople(agnts, merged []domain.FileChange) (edits []peopleEdit, added, removed, agntsLines int) {
	byPath := func(fs []domain.FileChange) map[string][]domain.FileChange {
		m := map[string][]domain.FileChange{}
		for _, f := range fs {
			m[f.Path] = append(m[f.Path], f)
		}
		return m
	}
	a, m := byPath(agnts), byPath(merged)
	var paths []string
	for p := range a {
		paths = append(paths, p)
	}
	for p := range m {
		if _, ok := a[p]; !ok {
			paths = append(paths, p)
		}
	}
	sort.Strings(paths)
	for _, p := range paths {
		al, ml := lineCounts(a[p]), lineCounts(m[p])
		for _, n := range al {
			agntsLines += n
		}
		e := peopleEdit{Path: p}
		for l, n := range ml {
			for range n - min(n, al[l]) {
				e.Added = append(e.Added, l)
			}
		}
		for l, n := range al {
			for range n - min(n, ml[l]) {
				e.Removed = append(e.Removed, l)
			}
		}
		if len(e.Added)+len(e.Removed) == 0 {
			continue
		}
		slices.Sort(e.Added)
		slices.Sort(e.Removed)
		added, removed = added+len(e.Added), removed+len(e.Removed)
		edits = append(edits, e)
	}
	return edits, added, removed, agntsLines
}

// peopleEditsText is the edits as a reflect run reads them.
func peopleEditsText(edits []peopleEdit, max int) string {
	var b strings.Builder
	for _, e := range edits {
		fmt.Fprintf(&b, "### %s\n", e.Path)
		for _, l := range e.Added {
			fmt.Fprintf(&b, "+ %s\n", l)
		}
		for _, l := range e.Removed {
			fmt.Fprintf(&b, "- %s\n", l)
		}
		b.WriteString("\n")
		if b.Len() > max {
			break
		}
	}
	return truncate(b.String(), max)
}

// learnFromMerge records how much people changed agnts's work in repo
// before it merged, and queues a reflection when they changed enough.
func (o *Orchestrator) learnFromMerge(ctx context.Context, t domain.Ticket, repoID int64, merged []domain.FileChange) {
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil || len(res.Files) == 0 {
		return
	}
	mine := domain.FilesIn(res.Files, repoID, t.RepoID)
	theirs := domain.FilesIn(merged, repoID, t.RepoID)
	if len(theirs) == 0 {
		theirs = merged // a single repository's files carry no repository
	}
	edits, added, removed, total := diffPeople(mine, theirs)
	share := 0.0
	if total > 0 {
		share = min(1, float64(removed)/float64(total))
	}
	msg := "people merged agnts's change as it was"
	if added+removed > 0 {
		msg = fmt.Sprintf("before merging, people added %d and removed %d of agnts's %d lines", added, removed, total)
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventPeopleEdits, Message: msg,
		Data: map[string]any{"added": added, "removed": removed, "lines": total, "share": share, "repoId": repoID}})
	if added+removed < minPeopleEdits {
		return
	}
	o.queueLesson(ctx, t, domain.ReflectMerged, peopleEditsText(edits, reflectMaxFeedback))
}

// queueLesson queues a reflection on something that happened to agnts's
// work (a merge with edits, a revert), when Settings allow learning.
func (o *Orchestrator) queueLesson(ctx context.Context, t domain.Ticket, source, text string) {
	if o.reflections == nil || o.rules == nil || t.ReplayOf != "" || strings.TrimSpace(text) == "" {
		return
	}
	s, err := o.settings.Get(ctx)
	if err != nil || !s.Reflect {
		return
	}
	if err := o.reflections.QueueReflection(ctx, domain.Reflection{TicketKey: t.Key, RepoID: t.RepoID, RepoIDs: multiIDs(t), Source: source,
		Feedback: truncate(text, reflectMaxFeedback)}); err != nil {
		o.log.Warn("queue reflection", "ticket", t.Key, "err", err)
		return
	}
	o.Wake()
}

// Reverted hears of a commit on a default branch that reverts a ticket's
// work (commitlink.Service.OnRevert). For merged work agnts made, it logs
// the revert once and has a reflect run look for the lesson.
func (o *Orchestrator) Reverted(ctx context.Context, l domain.CommitLink) {
	// Performance reviews: the delivery's reverted share changes, for
	// people's work as well as agnts's.
	o.updateReverts(ctx, l.TicketKey)
	t, err := o.store.TicketByKey(ctx, l.TicketKey)
	if err != nil || t.MergedAt == nil || t.HeadSHA == "" || t.ReplayOf != "" || t.Kind.Report() || t.Kind == domain.KindReview {
		return
	}
	evs, err := o.store.Events(ctx, EventFilter{TicketKey: t.Key, Limit: 1000})
	if err != nil {
		return
	}
	if slices.ContainsFunc(evs, func(e domain.Event) bool { return e.Type == domain.EventReverted && e.Data["sha"] == l.SHA }) {
		return // told already (a webhook delivered twice)
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventReverted, Origin: domain.OriginWebhook, Level: domain.LevelWarn,
		Message: fmt.Sprintf("people reverted this work on %s: %s", l.RepoName, l.Subject),
		Data:    map[string]any{"sha": l.SHA, "url": l.URL, "repoId": l.RepoID, "by": l.Author}})
	o.queueLesson(ctx, t, domain.ReflectReverted, fmt.Sprintf("After this ticket's change merged, %s reverted it on the default branch: %q (%s).\n"+
		"The change is in the diff below. Find out what in it a person would revert, and whether a convention of this code base would have prevented it.",
		orUnknown(l.Author), l.Subject, l.URL))
}
