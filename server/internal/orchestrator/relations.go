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

// How many other tickets an analysis compares itself with, and how much of
// each it is shown.
const (
	relationMaxCandidates = 40
	relationMaxFiles      = 25
)

// RelationClaim is how the analysis reads this ticket's relation to one of
// the other open tickets it was shown.
type RelationClaim struct {
	Key string `json:"key"`
	// Type is depends_on (this needs that one first), blocks (that one
	// needs this first) or conflicts (both change the same code).
	Type       string  `json:"type"`
	Confidence float64 `json:"confidence"`
	Reason     string  `json:"reason"`
}

// RelatedTicket is another open ticket, as the analysis prompt shows it.
type RelatedTicket struct {
	Key       string
	Title     string
	State     string // a short phrase: queued, in progress, waiting for review, done (not merged)
	Summary   string
	Files     []string
	MoreFiles int
	Provides  []string
	Consumes  []string
}

// relationCandidates loads the tickets an analysis of t compares itself
// with: open tickets in its repository and unmerged done ones.
// A ticket in several repositories compares itself with the tickets of
// each of them.
func (o *Orchestrator) relationCandidates(ctx context.Context, t domain.Ticket) ([]Candidate, error) {
	if t.RepoID == nil || t.ReplayOf != "" {
		return nil, nil // a replay is cut from the past: today's tickets are not its neighbours
	}
	if !t.Multi() {
		return o.store.RelationCandidates(ctx, *t.RepoID, t.Key, relationMaxCandidates)
	}
	var out []Candidate
	seen := map[string]bool{}
	for _, id := range t.RepoIDs() {
		cs, err := o.store.RelationCandidates(ctx, id, t.Key, relationMaxCandidates)
		if err != nil {
			return nil, err
		}
		for _, c := range cs {
			if !seen[c.Ticket.Key] && len(out) < relationMaxCandidates {
				seen[c.Ticket.Key] = true
				out = append(out, c)
			}
		}
	}
	return out, nil
}

// relatedTickets turns candidates into what the prompt lists.
func relatedTickets(cs []Candidate) []RelatedTicket {
	out := make([]RelatedTicket, 0, len(cs))
	for _, c := range cs {
		r := RelatedTicket{Key: c.Ticket.Key, Title: truncate(c.Ticket.Title, 200), State: statePhrase(c.Ticket)}
		if a, err := parseAnalysis(c.Analysis); err == nil {
			r.Summary = truncate(oneLine(a.Summary), 400)
			if a.Footprint != nil {
				f := a.Footprint.Clean()
				r.Files = f.Files
				if len(r.Files) > relationMaxFiles {
					r.Files, r.MoreFiles = r.Files[:relationMaxFiles], len(f.Files)-relationMaxFiles
				}
				r.Provides, r.Consumes = f.Provides, f.Consumes
			}
		}
		out = append(out, r)
	}
	return out
}

func statePhrase(t domain.Ticket) string {
	switch {
	case t.State == domain.StateDone:
		return "done, not merged yet"
	case t.HeadSHA != "" || t.State == domain.StateTesting || t.State == domain.StateWaitingForReview || t.State == domain.StatePushing:
		return "coded, in review"
	case t.State == domain.StateCoding:
		return "about to be coded"
	case t.State == domain.StateNew && t.Held:
		return "queued, not started"
	default:
		return "being analysed"
	}
}

func oneLine(s string) string { return strings.Join(strings.Fields(s), " ") }

// withRelations appends the relations block to an analysis prompt when
// there are other tickets to compare with.
func withRelations(d promptData, cs []Candidate, prompt string) (string, error) {
	if len(cs) == 0 {
		return prompt, nil
	}
	d.Related = relatedTickets(cs)
	block, err := render("relations", d)
	if err != nil {
		return "", err
	}
	return prompt + "\n" + block, nil
}

// applyRelations stores how the analysis of t relates it to the other open
// tickets: what Claude read from the tickets (active when confident,
// otherwise proposed) and what the predicted footprints show (the same
// files, or a shared hot spot such as migrations). It replaces what an
// earlier analysis of t found; relations someone decided stay. Relations
// are advice for the queue: a failure is logged, never fatal.
func (o *Orchestrator) applyRelations(ctx context.Context, t domain.Ticket, run *domain.Run, a Analysis, cs []Candidate) {
	if t.RepoID == nil {
		return
	}
	rs := foundRelations(t, a, cs)
	graph, err := o.store.DependencyGraph(ctx)
	if err != nil {
		o.log.Error("load dependency graph", "ticket", t.Key, "err", err)
		return
	}
	for i := range rs {
		r := &rs[i]
		if r.Type != domain.RelDependsOn || r.Status != domain.RelActive {
			continue
		}
		if domain.Reachable(graph, r.OtherKey, r.TicketKey) {
			// The other side already waits for this one: asking a person
			// beats two tickets waiting for each other forever.
			r.Status = domain.RelProposed
			r.Reason = strings.TrimSpace(r.Reason + " (not applied: " + r.OtherKey + " already waits for " + r.TicketKey + ")")
			continue
		}
		graph[r.TicketKey] = append(graph[r.TicketKey], r.OtherKey)
	}
	var ev *domain.Event
	if len(rs) > 0 {
		ev = &domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventRelations,
			Message: relationsMessage(t.Key, rs), Data: map[string]any{"count": len(rs)}}
	}
	if _, err := o.store.ReplaceFound(ctx, t.Key, rs, ev); err != nil {
		o.log.Error("save relations", "ticket", t.Key, "err", err)
	}
}

// foundRelations builds the relations an analysis implies, before cycle
// checks. Claude's claims come first, then the footprint rules: the store
// merges a pair found both ways, and a rule outranks a claim.
func foundRelations(t domain.Ticket, a Analysis, cs []Candidate) []domain.Relation {
	known := map[string]Candidate{}
	for _, c := range cs {
		known[c.Ticket.Key] = c
	}
	var rs []domain.Relation
	for _, c := range a.Relations {
		key := strings.TrimSpace(c.Key)
		if _, ok := known[key]; !ok || key == t.Key {
			continue // only tickets it was shown
		}
		conf := min(max(c.Confidence, 0), 1)
		if c.Confidence == 0 {
			conf = 0.5 // no number given: ask
		}
		r := domain.Relation{Source: domain.RelFromAgnts, Confidence: conf, Reason: truncate(strings.TrimSpace(c.Reason), 500),
			Status: domain.RelProposed}
		if conf >= domain.AutoApplyConfidence {
			r.Status = domain.RelActive
		}
		switch strings.ToLower(strings.TrimSpace(c.Type)) {
		case "depends_on", "depends on", "after":
			r.Type, r.TicketKey, r.OtherKey = domain.RelDependsOn, t.Key, key
		case "blocks", "before":
			r.Type, r.TicketKey, r.OtherKey = domain.RelDependsOn, key, t.Key
		case "conflicts", "conflict":
			r.Type, r.TicketKey, r.OtherKey = domain.RelConflicts, t.Key, key
		default:
			continue
		}
		rs = append(rs, r.Normalize())
	}

	// Footprint rules compare changes only: a report changes no code.
	if t.Kind.Report() || a.Footprint == nil {
		return rs
	}
	mine := a.Footprint.Clean()
	spots := domain.HotSpots(mine)
	for _, c := range cs {
		if c.Ticket.Kind.Report() {
			continue
		}
		oa, err := parseAnalysis(c.Analysis)
		if err != nil || oa.Footprint == nil {
			continue
		}
		theirs := oa.Footprint.Clean()
		files := domain.SharedFiles(mine, theirs)
		if t.Multi() || c.Ticket.Multi() {
			// Paths are compared with their repository: the same relative
			// path in two repositories is two files.
			files = domain.SharedFiles(qualified(t, mine), qualified(c.Ticket, theirs))
		}
		var shared []string
		for _, s := range domain.HotSpots(theirs) {
			if slices.Contains(spots, s) {
				shared = append(shared, s)
			}
		}
		if len(files) == 0 && len(shared) == 0 {
			continue
		}
		r := domain.Relation{Type: domain.RelConflicts, TicketKey: t.Key, OtherKey: c.Ticket.Key, Source: domain.RelFromRule,
			Status: domain.RelActive, Confidence: 0.8, Files: files, Basis: domain.BasisFiles}
		if len(shared) > 0 {
			r.Basis = shared[0] // a shared hot spot conflicts even in different files
		}
		rs = append(rs, r.Normalize())
	}
	return rs
}

// qualified is a footprint with each path prefixed by its repository's
// name: a ticket in several repositories names paths by folder, one in a
// single repository relative to it.
func qualified(t domain.Ticket, fp domain.Footprint) domain.Footprint {
	out := fp
	out.Files = nil
	for _, p := range fp.Files {
		if !t.Multi() {
			if r, ok := t.Primary(); ok {
				out.Files = append(out.Files, r.RepoName+"/"+p)
			}
			continue
		}
		for _, r := range t.Repos {
			if rest, ok := strings.CutPrefix(p, r.Folder+"/"); ok {
				out.Files = append(out.Files, r.RepoName+"/"+rest)
				break
			}
		}
	}
	return out
}

// relationsMessage describes found relations for the ticket's log.
func relationsMessage(key string, rs []domain.Relation) string {
	var parts []string
	for _, r := range rs {
		var s string
		switch {
		case r.Type == domain.RelDependsOn && r.TicketKey == key:
			s = "waits for " + r.OtherKey
		case r.Type == domain.RelDependsOn:
			s = r.TicketKey + " waits for it"
		default:
			s = "conflicts with " + r.Other(key)
		}
		if r.Status == domain.RelProposed {
			s += " (needs your OK)"
		}
		parts = append(parts, s)
	}
	return fmt.Sprintf("found %d %s: %s", len(rs), plural(len(rs), "relation", "relations"), strings.Join(parts, "; "))
}

// syncTrackerRelations mirrors the issue's blocking links. Links to issues
// agnts does not have are skipped; when that issue arrives, its own links
// add the relation. A link that would close a cycle is skipped with a
// warning.
func (o *Orchestrator) syncTrackerRelations(ctx context.Context, in Incoming, origin domain.Origin) {
	if !in.LinksKnown {
		return
	}
	graph, err := o.store.DependencyGraph(ctx)
	if err != nil {
		o.log.Error("load dependency graph", "ticket", in.Key, "err", err)
		return
	}
	// Edges this sync replaces must not count against it.
	for k, deps := range graph {
		graph[k] = slices.DeleteFunc(slices.Clone(deps), func(d string) bool { return k == in.Key || d == in.Key })
	}
	var rs []domain.Relation
	add := func(waits, on string) {
		if waits == on || waits == "" || on == "" {
			return
		}
		if domain.Reachable(graph, on, waits) {
			o.event(ctx, domain.Event{TicketKey: in.Key, Type: domain.EventRelations, Level: domain.LevelWarn, Origin: origin,
				Message: fmt.Sprintf("%s says %s is blocked by %s, but %s already waits for %s: agnts ignores this link", in.Source.Name(), waits, on, on, waits)})
			return
		}
		graph[waits] = append(graph[waits], on)
		rs = append(rs, domain.Relation{Type: domain.RelDependsOn, TicketKey: waits, OtherKey: on, Source: in.Source.RelationSource(),
			Status: domain.RelActive, Confidence: 1})
	}
	for _, k := range in.DependsOn {
		add(in.Key, k)
	}
	for _, k := range in.Dependents {
		add(k, in.Key)
	}
	added, err := o.store.SyncTrackerRelations(ctx, in.Source.RelationSource(), in.Key, rs)
	if err != nil {
		o.log.Error("sync tracker links", "source", in.Source, "ticket", in.Key, "err", err)
		return
	}
	if len(added) > 0 {
		o.event(ctx, domain.Event{TicketKey: in.Key, Type: domain.EventRelations, Origin: origin,
			Message: "from " + in.Source.Name() + " links: " + relationsMessage(in.Key, added), Data: map[string]any{"count": len(added)}})
	}
	o.Wake() // a removed link may free a ticket
}

// Relations is a ticket's ordering constraints, for its page.
type Relations struct {
	All []RelationRow
	// Blockers are what holds its first coding run back right now.
	Blockers []domain.Blocker
}

// ListRelations returns a ticket's relations and what holds it back now.
func (o *Orchestrator) ListRelations(ctx context.Context, key string) (Relations, error) {
	if _, err := o.store.TicketByKey(ctx, key); err != nil {
		return Relations{}, err
	}
	return o.relations(ctx, key)
}

func (o *Orchestrator) relations(ctx context.Context, key string) (Relations, error) {
	var out Relations
	var err error
	if out.All, err = o.store.RelationsOf(ctx, key); err != nil {
		return out, err
	}
	bs, err := o.store.Blockers(ctx, []string{key})
	out.Blockers = bs[key]
	return out, err
}

// AddRelation records a constraint someone set: key waits for other
// (depends_on), or the two must not run side by side (conflicts). It may
// revive one agnts proposed or someone dismissed.
func (o *Orchestrator) AddRelation(ctx context.Context, key, other string, typ domain.RelationType, origin domain.Origin) (domain.Relation, error) {
	other = strings.TrimSpace(other)
	if !typ.Valid() {
		return domain.Relation{}, invalid("type must be depends_on or conflicts")
	}
	if other == key {
		return domain.Relation{}, invalid("a ticket cannot wait for itself")
	}
	if _, err := o.store.TicketByKey(ctx, key); err != nil {
		return domain.Relation{}, err
	}
	ot, err := o.store.TicketByKey(ctx, other)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Relation{}, invalid("no ticket %s", other)
	}
	if err != nil {
		return domain.Relation{}, err
	}
	r := domain.Relation{Type: typ, TicketKey: key, OtherKey: ot.Key, Source: domain.RelFromUser, Status: domain.RelActive, Confidence: 1}
	if err := o.checkCycle(ctx, r); err != nil {
		return domain.Relation{}, err
	}
	msg := key + " now waits for " + other + " to be merged"
	if typ == domain.RelConflicts {
		msg = key + " and " + other + " no longer run side by side"
	}
	out, err := o.store.UpsertRelation(ctx, r, &domain.Event{TicketKey: key, Type: domain.EventRelations, Origin: origin, Message: msg,
		Data: map[string]any{"other": other, "type": string(typ)}})
	if err == nil {
		o.Wake()
	}
	return out, err
}

// checkCycle refuses a dependency that would make two tickets wait for
// each other.
func (o *Orchestrator) checkCycle(ctx context.Context, r domain.Relation) error {
	if r.Type != domain.RelDependsOn {
		return nil
	}
	graph, err := o.store.DependencyGraph(ctx)
	if err != nil {
		return err
	}
	if domain.Reachable(graph, r.OtherKey, r.TicketKey) {
		return invalid("%s already waits for %s (directly or through other tickets): they would wait for each other forever", r.OtherKey, r.TicketKey)
	}
	return nil
}

// DecideRelation accepts a proposed relation (the queue then follows it)
// or dismisses one, proposed or active: the tickets no longer wait for
// each other, and agnts does not propose it again.
func (o *Orchestrator) DecideRelation(ctx context.Context, key string, id int64, accept bool, origin domain.Origin) (domain.Relation, error) {
	r, err := o.store.RelationByID(ctx, id)
	if err != nil {
		return r, err
	}
	if !r.Involves(key) {
		return r, fmt.Errorf("relation %d of %s: %w", id, key, domain.ErrNotFound)
	}
	status, msg := domain.RelDismissed, "relation dismissed: "
	if accept {
		if r.Status == domain.RelActive {
			return r, nil
		}
		if err := o.checkCycle(ctx, r); err != nil {
			return r, err
		}
		status, msg = domain.RelActive, "relation accepted: "
	}
	if r.Type == domain.RelDependsOn {
		msg += r.TicketKey + " waits for " + r.OtherKey
	} else {
		msg += r.TicketKey + " and " + r.OtherKey + " do not run side by side"
	}
	out, err := o.store.DecideRelation(ctx, key, id, status, domain.Event{TicketKey: key, Type: domain.EventRelations, Origin: origin,
		Message: msg, Data: map[string]any{"relation": id}})
	if err == nil {
		o.Wake()
	}
	return out, err
}

// MarkMergedByHand records that a done ticket's pull requests were merged,
// for setups without a merge webhook: tickets waiting for it may start.
// A ticket in several repositories has all its open pull requests marked.
func (o *Orchestrator) MarkMergedByHand(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateDone || !t.AnyPR() {
		return t, invalid("only a done ticket with a pull request can be marked merged")
	}
	if t.MergedAt != nil {
		return t, nil
	}
	for _, r := range t.OpenedPRs() {
		if r.MergedAt != nil || r.ClosedAt != nil {
			continue
		}
		if t, err = o.markRepoMerged(ctx, t, r.RepoID, origin, "marked merged by hand"); err != nil {
			return t, err
		}
	}
	return o.store.TicketByKey(ctx, key)
}

// CheckMerges asks the git host about done tickets whose pull requests are
// not known to be merged or closed, and records the merges and closes it
// finds. It covers a webhook that never arrived; with a working webhook it
// finds nothing.
func (o *Orchestrator) CheckMerges(ctx context.Context) {
	mc, ok := o.host.(MergeChecker)
	if !ok || ctx.Err() != nil {
		return
	}
	ts, err := o.store.UnmergedPRs(ctx, 50)
	if err != nil {
		o.log.Warn("check merges", "err", err)
		return
	}
	repos := map[int64]domain.Repository{}
	sys := ctx
	for _, t := range ts {
		// Each ticket is checked with its workspace's git host token.
		ctx := domain.WithWorkspace(sys, t.WorkspaceID)
		for _, r := range t.OpenedPRs() {
			if ctx.Err() != nil {
				return
			}
			if r.MergedAt != nil || r.ClosedAt != nil {
				continue
			}
			repo, seen := repos[r.RepoID]
			if !seen {
				if repo, err = o.store.RepositoryByID(ctx, r.RepoID); err != nil {
					o.log.Warn("check merges", "ticket", t.Key, "err", err)
					continue
				}
				repos[r.RepoID] = repo
			}
			state, err := mc.PRState(ctx, repo, *r.PRNumber)
			if err != nil {
				o.log.Debug("check merges", "ticket", t.Key, "err", err)
				continue
			}
			switch state {
			case domain.PullMerged:
				var nt domain.Ticket
				if nt, err = o.markRepoMerged(ctx, t, r.RepoID, domain.OriginSystem, "pull request merged (found by checking the git host)"); err == nil {
					t = nt
				}
			case domain.PullClosed:
				err = o.setPRClosed(ctx, t, r.RepoID, true, domain.OriginSystem, "pull request closed without merging (found by checking the git host)")
			}
			if err != nil {
				o.log.Warn("check merges", "ticket", t.Key, "err", err)
			}
		}
	}
}

// markRepoMerged records that the ticket's pull request in repoID was
// merged: its branch goes, its brief counts the merge, and once every pull
// request the ticket opened is merged (or closed), the ticket is merged.
func (o *Orchestrator) markRepoMerged(ctx context.Context, t domain.Ticket, repoID int64, origin domain.Origin, msg string) (domain.Ticket, error) {
	now := time.Now()
	r, _ := t.RepoState(repoID)
	if t.Multi() {
		msg = r.RepoName + ": " + msg
	}
	url := r.PRURL
	became := false
	out, err := o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, Type: domain.EventMerged, Origin: origin, Message: msg, Data: map[string]any{"url": url, "repoId": repoID},
	}, func(x *domain.Ticket) {
		x.UpdateRepo(repoID, func(r *domain.TicketRepo) {
			if url != "" {
				r.PRURL = url
			}
			r.MergedAt, r.State, r.ClosedAt = &now, domain.RepoMerged, nil
		})
		// Decided on the locked row, so two reports of the last merge
		// cannot both finish the ticket.
		if x.MergedAt == nil && (!x.Multi() || x.AllMerged()) {
			x.MergedAt, became = &now, true
		}
	})
	if err != nil {
		return out, err
	}
	if repo, err := o.store.RepositoryByID(ctx, repoID); err == nil {
		o.dropRepoBranch(ctx, out, repo, r.Branch)
		o.countRepoMerge(ctx, out, repoID)
	}
	if became {
		o.mergedNote(ctx, out, origin)
		o.mergedEverywhere(ctx, out)
	}
	return out, nil
}

// settleMerged sets or clears a ticket's merge after one of its pull
// requests was closed or reopened: merged once the open ones are all
// merged, not merged again while a reopened one is open. It reports
// whether the ticket just became merged.
func (o *Orchestrator) settleMerged(ctx context.Context, key string) (domain.Ticket, bool, error) {
	now := time.Now()
	became := false
	out, err := o.store.UpdateTicket(ctx, key, nil, func(x *domain.Ticket) {
		switch {
		case !x.Multi():
		case x.MergedAt == nil && x.AllMerged():
			x.MergedAt, became = &now, true
		case x.MergedAt != nil && !x.AllMerged():
			x.MergedAt = nil
		}
	})
	return out, became, err
}

// mergedNote logs that a ticket in several repositories is merged.
func (o *Orchestrator) mergedNote(ctx context.Context, t domain.Ticket, origin domain.Origin) {
	if !t.Multi() {
		return
	}
	msg := "every pull request is merged"
	if t.PartlyMerged() {
		msg = "partly merged: the other pull requests are merged, and a closed one was not"
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventMerged, Origin: origin, Message: msg,
		Data: map[string]any{"all": true, "partly": t.PartlyMerged()}})
}

// mergedEverywhere is what follows the ticket-level merge: the tracker
// hears of it, the CI hooks run and tickets waiting for it may start.
func (o *Orchestrator) mergedEverywhere(ctx context.Context, t domain.Ticket) {
	o.trackerComment(ctx, t, CommentStatus, mergedComment(t))
	o.trackerMove(ctx, t, TrackerMerged)
	if o.ciHook != nil {
		o.ciHook.TicketMerged(ctx, t)
	}
	o.Wake() // tickets waiting for it may start
}

func mergedComment(t domain.Ticket) string {
	if !t.Multi() {
		return "The pull request was merged."
	}
	if t.PartlyMerged() {
		return "The pull requests were partly merged: " + prList(t) + "."
	}
	return "All pull requests were merged: " + prList(t) + "."
}

// prList names a ticket's pull requests with their state.
func prList(t domain.Ticket) string {
	var parts []string
	for _, r := range t.OpenedPRs() {
		s := r.RepoName + " " + r.PRURL
		switch {
		case r.MergedAt != nil:
			s += " (merged)"
		case r.ClosedAt != nil || r.State == domain.RepoDropped:
			s += " (closed)"
		}
		parts = append(parts, s)
	}
	return strings.Join(parts, ", ")
}

// landedDependencies returns the tickets t waited for whose changes are
// merged now, so its first coding run checks the plan against them.
func (o *Orchestrator) landedDependencies(ctx context.Context, t domain.Ticket) []TicketRef {
	rows, err := o.store.RelationsOf(ctx, t.Key)
	if err != nil {
		o.log.Warn("load relations", "ticket", t.Key, "err", err)
		return nil
	}
	var out []TicketRef
	for _, r := range rows {
		if r.Type == domain.RelDependsOn && r.Status == domain.RelActive && r.TicketKey == t.Key && r.OtherReleases &&
			r.OtherState == domain.StateDone {
			out = append(out, TicketRef{Key: r.OtherKey, Title: r.OtherTitle})
		}
	}
	return out
}

// checkFootprint compares what the analysis predicted with what the run
// changed, and logs precision and recall: the measure of how well the
// queue's predictions can be trusted.
func (o *Orchestrator) checkFootprint(ctx context.Context, t domain.Ticket, run *domain.Run, files []domain.FileChange) {
	r, err := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze)
	if err != nil {
		return
	}
	a, err := parseAnalysis(r.Summary)
	if err != nil || a.Footprint == nil {
		return
	}
	pred := a.Footprint.Clean().Files
	actual := make([]string, 0, len(files))
	for _, f := range files {
		actual = append(actual, f.Where())
	}
	hit := 0
	for _, p := range pred {
		if slices.Contains(actual, p) {
			hit++
		}
	}
	precision, recall := 0.0, 0.0
	if len(pred) > 0 {
		precision = float64(hit) / float64(len(pred))
	}
	if len(actual) > 0 {
		recall = float64(hit) / float64(len(actual))
	}
	var missed []string
	for _, p := range actual {
		if !slices.Contains(pred, p) && len(missed) < 20 {
			missed = append(missed, p)
		}
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventFootprint, Level: domain.LevelDebug,
		Message: fmt.Sprintf("predicted %d of the %d changed files (%d predicted)", hit, len(actual), len(pred)),
		Data:    map[string]any{"precision": precision, "recall": recall, "predicted": len(pred), "actual": len(actual), "hit": hit, "missed": missed}})
}

// checkCollisions compares a finished change with the other committed,
// unmerged changes in the repository. Where both touch the same or
// adjacent lines, git will not merge the second one on its own: that pair
// gets an active conflict relation (so the reviewer sees it) and a warning
// on both tickets. Whether the relation was predicted is logged for the
// eval.
// In a ticket of several repositories each repository's change is compared
// with the others' changes in that repository: files is the change in repo
// alone, paths relative to it.
func (o *Orchestrator) checkCollisions(ctx context.Context, t domain.Ticket, run *domain.Run, repo domain.Repository, files []domain.FileChange) {
	if t.ReplayOf != "" || len(files) == 0 {
		return // never merged, so it collides with nothing
	}
	others, err := o.store.InFlightResults(ctx, repo.ID, t.Key)
	if err != nil {
		o.log.Warn("load unmerged changes", "ticket", t.Key, "err", err)
		return
	}
	if len(others) == 0 {
		return
	}
	known, err := o.store.RelationsOf(ctx, t.Key)
	if err != nil {
		o.log.Warn("load relations", "ticket", t.Key, "err", err)
		return
	}
	predicted := func(other string) string {
		for _, r := range known {
			if r.Other(t.Key) == other {
				return string(r.Status) // active, proposed or dismissed
			}
		}
		return "none"
	}
	for _, f := range others {
		var lines []string
		for _, c := range domain.DiffConflicts(files, domain.FilesIn(f.Files, repo.ID, f.Ticket.RepoID)) {
			if c.Lines {
				lines = append(lines, c.Path)
			}
		}
		if len(lines) == 0 {
			continue
		}
		was := predicted(f.Ticket.Key)
		where := strings.Join(lines, ", ")
		if t.Multi() || f.Ticket.Multi() {
			where = repo.Name + ": " + where
		}
		msg := fmt.Sprintf("%s changes the same lines as %s in %s: whichever is merged second needs a rebase", t.Key, f.Ticket.Key, where)
		_, err := o.store.UpsertRelation(ctx, domain.Relation{Type: domain.RelConflicts, TicketKey: t.Key, OtherKey: f.Ticket.Key,
			Source: domain.RelFromGit, Status: domain.RelActive, Confidence: 1, Basis: domain.BasisDiff, Files: lines},
			&domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventCollision, Level: domain.LevelWarn,
				Message: msg, Data: map[string]any{"other": f.Ticket.Key, "files": lines, "predicted": was}})
		if err != nil {
			o.log.Warn("save collision", "ticket", t.Key, "err", err)
			continue
		}
		o.event(ctx, domain.Event{TicketKey: f.Ticket.Key, Type: domain.EventCollision, Level: domain.LevelWarn, Message: msg,
			Data: map[string]any{"other": t.Key, "files": lines, "predicted": was}})
	}
}

// DriftChecker is a Git that can tell what landed on the default branch
// since a ticket's branch was cut. Git adapters that cannot simply do not
// implement it.
type DriftChecker interface {
	// Drift fetches and returns the default branch's changes since its
	// merge base with branch.
	Drift(ctx context.Context, repo domain.Repository, branch string) ([]domain.FileChange, error)
}

// checkDrift warns before a push when the default branch moved on under
// the same lines the change touches: the pull request will need a rebase.
// It returns the files, for the pull request body.
func (o *Orchestrator) checkDrift(ctx context.Context, t domain.Ticket, run *domain.Run, r runRepo) []string {
	dc, ok := o.git.(DriftChecker)
	if !ok {
		return nil
	}
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return nil
	}
	drift, err := dc.Drift(ctx, r.Repository, r.Branch)
	if err != nil {
		o.log.Warn("check default branch drift", "ticket", t.Key, "repo", r.Name, "err", err)
		return nil
	}
	var lines []string
	for _, c := range domain.DiffConflicts(domain.FilesIn(res.Files, r.ID, t.RepoID), drift) {
		if c.Lines {
			lines = append(lines, c.Path)
		}
	}
	if len(lines) > 0 {
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventCollision, Level: domain.LevelWarn,
			Message: fmt.Sprintf("%s%s changed under this branch in %s since it was cut: the pull request will need a rebase", r.Label(t.Multi()), r.DefaultBranch, strings.Join(lines, ", ")),
			Data:    map[string]any{"files": lines, "drift": true, "repoId": r.ID}})
	}
	return lines
}

// dropBranch deletes a finished ticket's local branches (merged or
// rejected), in every repository: the git host keeps its copy, and the
// mirror stops growing with refs.
func (o *Orchestrator) dropBranch(ctx context.Context, t domain.Ticket) {
	for _, id := range t.RepoIDs() {
		r, ok := t.RepoState(id)
		if !ok || r.Branch == "" {
			continue
		}
		repo, err := o.store.RepositoryByID(ctx, id)
		if err != nil {
			continue
		}
		o.dropRepoBranch(ctx, t, repo, r.Branch)
	}
}

func (o *Orchestrator) dropRepoBranch(ctx context.Context, t domain.Ticket, repo domain.Repository, branch string) {
	bc, ok := o.git.(BranchCleaner)
	if !ok || branch == "" {
		return
	}
	if err := bc.DeleteBranch(context.WithoutCancel(ctx), repo, branch); err != nil {
		o.log.Warn("delete finished branch", "ticket", t.Key, "repo", repo.Name, "branch", branch, "err", err)
	}
}
