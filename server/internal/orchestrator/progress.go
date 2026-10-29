package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/guard"
)

// savedWork is what a coding run left uncommitted when it ended early
// (stopped, rate limited, failed): the change in each repository as a patch
// on the commit the run started from, and Claude's own notes. The next
// coding run of the ticket puts it back instead of starting over.
type savedWork struct {
	// Checking: Claude had finished and the run was stopped in its checks,
	// so the next run goes straight to the checks.
	Checking bool `json:"checking,omitempty"`
	// Reason is the error the run failed with ("" when it was stopped or
	// paused at a limit).
	Reason  string      `json:"reason,omitempty"`
	Repos   []savedRepo `json:"repos"`
	Summary []byte      `json:"summary,omitempty"` // SummaryPath
	Notes   []byte      `json:"notes,omitempty"`   // guard.ProgressPath
}

// savedRepo is one repository's uncommitted change.
type savedRepo struct {
	RepoID int64    `json:"repoId"`
	Base   string   `json:"base"` // the commit the patch applies to
	Patch  []byte   `json:"patch"`
	Files  []string `json:"files"` // as paths from /workspace
}

// files lists the changed files of every repository, as paths from /workspace.
func (w *savedWork) files() []string {
	var out []string
	for _, r := range w.Repos {
		out = append(out, r.Files...)
	}
	return out
}

// wipPatch is where a saved patch passes through the container.
const wipPatch = "/agnts/out/wip.patch"

// maxSavedPatch keeps a patch under what Workspace.ReadFile returns (4 MiB).
const maxSavedPatch = 3 << 20

// saveWork keeps the run's uncommitted changes for the next run, or drops
// what was kept when there are none. checking says Claude had finished;
// reason is the error the run failed with, if it failed.
func (o *Orchestrator) saveWork(ctx context.Context, t domain.Ticket, ws Workspace, rs []runRepo, run *domain.Run, checking bool, reason string) {
	if o.progress == nil {
		return
	}
	ctx = context.WithoutCancel(ctx)
	w := savedWork{Checking: checking, Reason: truncate(reason, 4000)}
	for _, r := range rs {
		if r.Frozen {
			continue
		}
		changed := changedIn(ctx, ws, r)
		if len(changed) == 0 {
			continue
		}
		base := headOf(ctx, ws, r)
		res, err := ws.Exec(ctx, r.Cmd("git add -A && git diff --cached --binary HEAD > "+wipPatch+" && wc -c < "+wipPatch), time.Minute)
		if err != nil || res.ExitCode != 0 || base == "" {
			o.log.Warn("save work: diff", "ticket", t.Key, "repo", r.Name, "err", err, "output", res.Output)
			continue
		}
		out := strings.TrimSpace(res.Output) // git may warn first: the size is the last line
		if size, _ := strconv.Atoi(strings.TrimSpace(out[strings.LastIndex(out, "\n")+1:])); size > maxSavedPatch {
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventTicketUpdated, Level: domain.LevelWarn,
				Message: fmt.Sprintf("%sthe unfinished change is too large to keep (%d MB): the next run starts from the last commit", r.Label(len(rs) > 1), size>>20)})
			continue
		}
		patch, err := ws.ReadFile(ctx, wipPatch)
		if err != nil || len(patch) == 0 {
			o.log.Warn("save work: read patch", "ticket", t.Key, "repo", r.Name, "err", err)
			continue
		}
		sr := savedRepo{RepoID: r.ID, Base: base, Patch: patch}
		for _, f := range changed {
			sr.Files = append(sr.Files, r.Rel(f))
		}
		w.Repos = append(w.Repos, sr)
	}
	if len(w.Repos) == 0 {
		o.dropWork(ctx, t)
		return
	}
	w.Summary, _ = ws.ReadFile(ctx, SummaryPath)
	w.Notes, _ = ws.ReadFile(ctx, guard.ProgressPath)
	b, err := json.Marshal(w)
	if err == nil {
		err = o.progress.Save(t.WorkspaceID, t.Key, b)
	}
	if err != nil {
		o.log.Warn("save work", "ticket", t.Key, "err", err)
		return
	}
	n := len(w.files())
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventTicketUpdated,
		Message: fmt.Sprintf("kept the unfinished change (%d %s): the next run picks it up from here", n, plural(n, "file", "files")),
		Data:    map[string]any{"files": w.files()}})
}

// restoreWork puts the work a stopped run saved back into the workspace, in
// each repository still at the commit it was saved on, and returns what it
// put back (nil for nothing). Work that no longer applies is dropped.
func (o *Orchestrator) restoreWork(ctx context.Context, t domain.Ticket, ws Workspace, rs []runRepo, run *domain.Run) *savedWork {
	if o.progress == nil {
		return nil
	}
	b, err := o.progress.Load(t.WorkspaceID, t.Key)
	if err != nil {
		o.log.Warn("load saved work", "ticket", t.Key, "err", err)
		return nil
	}
	if b == nil {
		return nil
	}
	var w savedWork
	if err := json.Unmarshal(b, &w); err != nil {
		o.log.Warn("saved work unreadable", "ticket", t.Key, "err", err)
		o.dropWork(ctx, t)
		return nil
	}
	kept := savedWork{Reason: w.Reason, Summary: w.Summary, Notes: w.Notes}
	var lost []string
	for _, sr := range w.Repos {
		r, ok := repoByID(rs, sr.RepoID)
		if !ok || r.Frozen || headOf(ctx, ws, r) != sr.Base || !applyPatch(ctx, ws, r, sr.Patch) {
			lost = append(lost, repoName(r, ok, sr.RepoID))
			continue
		}
		kept.Repos = append(kept.Repos, sr)
	}
	_, _ = ws.Exec(ctx, "rm -f "+wipPatch, time.Minute)
	multi := len(rs) > 1
	if len(lost) > 0 {
		where := ""
		if multi {
			where = " in " + strings.Join(lost, ", ")
		}
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventTicketUpdated, Level: domain.LevelWarn,
			Message: "the unfinished change of the stopped run" + where + " no longer applies (the branch moved): agnts continues from the last commit"})
	}
	if len(kept.Repos) == 0 {
		o.dropWork(ctx, t)
		return nil
	}
	// Part of it lost: Claude has work to redo before the checks.
	kept.Checking = w.Checking && len(lost) == 0
	if len(kept.Summary) > 0 {
		_ = ws.WriteFile(ctx, SummaryPath, kept.Summary)
	}
	if len(kept.Notes) > 0 {
		_ = ws.WriteFile(ctx, guard.ProgressPath, kept.Notes)
	}
	n := len(kept.files())
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventTicketUpdated,
		Message: fmt.Sprintf("picked up the stopped run's unfinished change (%d %s)", n, plural(n, "file", "files")),
		Data:    map[string]any{"files": kept.files()}})
	return &kept
}

// dropWork forgets a ticket's saved work: it was committed, or no longer
// applies.
func (o *Orchestrator) dropWork(ctx context.Context, t domain.Ticket) {
	if o.progress == nil {
		return
	}
	if err := o.progress.Drop(t.WorkspaceID, t.Key); err != nil {
		o.log.Warn("drop saved work", "ticket", t.Key, "err", err)
	}
}

// headOf is the commit a repository of the run is checked out at, or "".
func headOf(ctx context.Context, ws Workspace, r runRepo) string {
	res, err := ws.Exec(ctx, r.Cmd("git rev-parse HEAD"), time.Minute)
	if err != nil || res.ExitCode != 0 {
		return ""
	}
	return strings.TrimSpace(res.Output)
}

// applyPatch applies a saved patch to a repository of the run, all of it or
// nothing.
func applyPatch(ctx context.Context, ws Workspace, r runRepo, patch []byte) bool {
	if err := ws.WriteFile(ctx, wipPatch, patch); err != nil {
		return false
	}
	res, err := ws.Exec(ctx, r.Cmd("git apply --binary "+wipPatch), time.Minute)
	return err == nil && res.ExitCode == 0
}

func repoName(r runRepo, ok bool, id int64) string {
	if ok {
		return r.Name
	}
	return "repository " + strconv.FormatInt(id, 10)
}

// savedFiles lists the files of a stopped ticket's saved work (nil for none).
func (o *Orchestrator) savedFiles(t domain.Ticket) []string {
	if o.progress == nil {
		return nil
	}
	switch t.State {
	case domain.StateFailed, domain.StateRateLimited, domain.StateRejected:
	default:
		return nil
	}
	b, err := o.progress.Load(t.WorkspaceID, t.Key)
	if err != nil || b == nil {
		return nil
	}
	var w savedWork
	if json.Unmarshal(b, &w) != nil {
		return nil
	}
	return w.files()
}

// DiscardWork throws away the unfinished change a stopped ticket's last
// coding run left, so the next run starts from the last commit. It goes
// with Retry or Continue; without saved work it changes nothing.
func (o *Orchestrator) DiscardWork(ctx context.Context, key string, origin domain.Origin) error {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return err
	}
	if o.savedFiles(t) == nil {
		return nil
	}
	o.dropWork(ctx, t)
	o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin,
		Message: "discarded the unfinished change of the stopped run: the next run starts from the last commit"})
	return nil
}
