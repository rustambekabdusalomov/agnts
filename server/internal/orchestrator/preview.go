package orchestrator

import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"path"
	"slices"
	"time"

	"agnts/internal/domain"
)

// Limits of the preview stage: like the review, it runs beside the human
// review, so it gets a smaller budget than coding.
const (
	previewMaxTurns     = 40
	previewTimeoutMin   = 20
	previewStartTimeout = 7 * time.Minute // install, build and start
	previewMaxShotBytes = 3 << 20
	// previewKeepDays is how long screenshots outlive a finished ticket.
	previewKeepDays = 30
)

// Files of the preview stage. The runner image's agnts-preview script reads
// the config and the env; Claude writes the manifest and the screenshots.
const (
	PreviewConfigPath = "/agnts/out/preview-config.json"
	PreviewEnvPath    = "/agnts/out/preview.env"
	PreviewPath       = "/agnts/out/preview.json"
	previewOutDir     = "/agnts/out"
)

// previewConfig is what agnts-preview reads from PreviewConfigPath.
type previewConfig struct {
	Command       string `json:"command"`
	Port          int    `json:"port"`
	ReadyPath     string `json:"readyPath"`
	DefaultBranch string `json:"defaultBranch"`
	// Dir is the repository's folder in a run of several (agnts-preview
	// starts the app there); empty for /workspace.
	Dir string `json:"dir,omitempty"`
}

// previewState is the preview state a code change gets as it reaches
// review: pending when the repository can be previewed, previews are on
// and the change touches its UI paths.
// In a ticket of several repositories, any repository whose UI paths the
// change touches gets one.
func (o *Orchestrator) previewState(s domain.Settings, rs []runRepo, primary *int64, files []domain.FileChange) string {
	if o.shots == nil || !s.AutoPreview {
		return domain.PreviewNone
	}
	for _, r := range rs {
		if !r.Preview.Enabled() || r.Frozen {
			continue
		}
		var paths []string
		for _, f := range domain.FilesIn(files, r.ID, primary) {
			paths = append(paths, f.Path)
		}
		if len(paths) > 0 && domain.MatchUIPaths(paths, r.Preview.UIPaths) {
			return domain.PreviewPending
		}
	}
	return domain.PreviewNone
}

// dropPreview forgets a queued or running preview of a ticket leaving
// review; it reports whether a preview run may be running.
func dropPreview(x *domain.Ticket) bool {
	running := x.PreviewState == domain.PreviewRunning
	if running || x.PreviewState == domain.PreviewPending {
		x.PreviewState = domain.PreviewNone
	}
	return running
}

// Preview queues a preview of a ticket waiting for review (again, if one
// already ran). compare, when set, changes whether this and later previews
// of the ticket capture the default branch too.
func (o *Orchestrator) Preview(ctx context.Context, key string, compare *bool, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if o.shots == nil {
		return t, invalid("previews are not available on this server")
	}
	if t.State != domain.StateWaitingForReview {
		return t, invalid("agnts takes screenshots while a ticket waits for your review")
	}
	if t.Kind.Report() {
		return t, invalid("a report has no app to preview")
	}
	rs, err := o.reposFor(ctx, t)
	if err != nil {
		return t, err
	}
	if len(previewable(rs)) == 0 {
		if len(rs) > 1 {
			return t, invalid("none of %s has a preview command: set one on the Repositories page", repoNames(rs))
		}
		return t, invalid("%s has no preview command: set one on the Repositories page", rs[0].Name)
	}
	msg := "queued for preview"
	if compare != nil && *compare {
		msg += ", with the default branch for comparison"
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Step: string(domain.StagePreview), Message: msg,
	}, func(x *domain.Ticket) {
		if compare != nil {
			x.PreviewCompare = *compare
		}
		if x.State == domain.StateWaitingForReview && x.PreviewState != domain.PreviewRunning {
			x.PreviewState = domain.PreviewPending
		}
	})
	if err == nil {
		o.Wake()
	}
	return t, err
}

// previewable are the run's repositories that can be previewed.
func previewable(rs []runRepo) []runRepo {
	var out []runRepo
	for _, r := range rs {
		if r.Preview.Enabled() && !r.Frozen {
			out = append(out, r)
		}
	}
	return out
}

// preview starts the app at the change under review, has Claude take
// screenshots of what it affects, and stores them for the reviewer. It
// never changes the ticket's state. In a ticket of several repositories
// each one that can be previewed and that the change touches is previewed
// in turn, in the same container; its screenshots carry its name.
func (o *Orchestrator) preview(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	if o.shots == nil {
		return errors.New("previews are not available on this server")
	}
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return fmt.Errorf("load the change to preview: %w", err)
	}
	if len(res.Files) == 0 {
		return errors.New("no change to preview")
	}
	rs, err := o.reposFor(ctx, t)
	if err != nil {
		return err
	}
	multi := len(rs) > 1
	var targets []runRepo
	for _, r := range previewable(rs) {
		if !multi || len(domain.FilesIn(res.Files, r.ID, t.RepoID)) > 0 {
			targets = append(targets, r)
		}
	}
	if len(targets) == 0 && multi {
		targets = previewable(rs) // asked for by hand: show the app as it is
	}
	if len(targets) == 0 {
		return fmt.Errorf("%s has no preview command", rs[0].Name)
	}
	prev, _ := o.latestPreview(ctx, t.ID)

	ws, err := o.openWorkspace(ctx, t, rs, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)

	model := s.ModelFor(t, domain.ModelPreview)
	p := domain.Preview{Revision: t.Revision, Model: model, Compare: t.PreviewCompare}
	accepted := false
	for i, r := range targets {
		if i > 0 {
			_, _ = ws.Exec(ctx, "agnts-preview stop", 30*time.Second)
		}
		part, err := o.previewRepo(ctx, s, ws, t, run, r, multi, res, !accepted)
		if err != nil {
			return err
		}
		if part.Acceptance != nil {
			accepted = true
		}
		p = mergePreview(p, part, r, multi)
	}
	if err := o.savePreview(ctx, t, run, p, prev); err != nil {
		return err
	}
	return o.afterAcceptance(ctx, t, run, p.Acceptance)
}

// mergePreview adds one repository's preview to a ticket's.
func mergePreview(p, part domain.Preview, r runRepo, multi bool) domain.Preview {
	if !multi {
		part.Revision, part.Model, part.Compare = p.Revision, p.Model, p.Compare
		return part
	}
	rank := map[string]int{domain.PreviewOK: 0, domain.PreviewPartial: 1, domain.PreviewBroken: 2}
	if p.Status == "" || rank[part.Status] > rank[p.Status] {
		p.Status = part.Status
	}
	if p.Summary != "" {
		p.Summary += "\n\n"
	}
	p.Summary += "**" + r.Name + "**: " + part.Summary
	p.Shots = append(p.Shots, part.Shots...)
	p.Issues = append(p.Issues, part.Issues...)
	if p.Acceptance == nil {
		p.Acceptance = part.Acceptance
	}
	return p
}

// previewRepo previews one repository's app: it starts it, has Claude take
// the screenshots and stores them, and checks the acceptance criteria
// when accept is set and the repository asks for it.
func (o *Orchestrator) previewRepo(ctx context.Context, s domain.Settings, ws Workspace, t domain.Ticket, run *domain.Run, r runRepo, multi bool,
	res domain.Result, accept bool) (domain.Preview, error) {
	repo := r.Repository
	var p domain.Preview
	files := res.Files
	if multi {
		files = domain.FilesIn(res.Files, r.ID, t.RepoID)
	}
	if err := o.writePreviewFiles(ctx, ws, r); err != nil {
		return p, err
	}
	if err := ws.WriteFile(ctx, ChangePath, changeDiff(files)); err != nil {
		return p, fmt.Errorf("copy the change into the workspace: %w", err)
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StagePreview), Type: domain.EventClaudeText,
		Message: r.Label(multi) + "starting the app: " + repo.Preview.Command})
	start, err := ws.Exec(ctx, "agnts-preview start", previewStartTimeout+30*time.Second)
	if err != nil {
		return p, fmt.Errorf("start the app: %w", err)
	}
	if start.ExitCode != 0 {
		// The app not starting is a result the reviewer should see: the
		// change may have broken it.
		p.Status = domain.PreviewBroken
		p.Summary = "The app did not start (exit " + fmt.Sprint(start.ExitCode) + "). The end of its log:\n\n" + tail(start.Output, 2500)
		if start.TimedOut {
			p.Summary = "The app did not answer within " + previewStartTimeout.String() + ". The end of its log:\n\n" + tail(start.Output, 2500)
		}
		run.ExitReason = "app_failed"
		return p, nil
	}

	d := promptData{T: t, Repo: repo}
	var sum Summary
	_ = json.Unmarshal(res.Summary, &sum)
	d.WorkSummary, d.Notes = sum.Summary, sum.Notes
	d.Files = files
	if len(d.Files) > reviewMaxFiles {
		d.Files = d.Files[:reviewMaxFiles]
	}
	if d.Rules, err = o.teamRules(ctx, t.RepoIDs()); err != nil {
		return p, err
	}
	prompt, err := render("preview", d)
	if err != nil {
		return p, err
	}
	if multi {
		prompt += fmt.Sprintf("\n\nThis ticket changes several repositories; this preview is of %s, checked out at /workspace/%s, where the app runs. The diff in %s is its part of the change.\n",
			r.Name, r.Folder(), ChangePath)
	}
	ps := s
	ps.MaxTurns = min(s.MaxTurns, previewMaxTurns)
	ps.TimeoutMin = min(s.TimeoutMin, previewTimeoutMin)
	if _, err := o.claude(ctx, ps, ws, &t, run, domain.ModelPreview, prompt, ""); err != nil {
		var stop *stopError
		if errors.As(err, &stop) {
			// Rate limited: claimed again once usage allows.
			o.setPreviewState(context.WithoutCancel(ctx), t, domain.PreviewPending)
		}
		return p, err
	}
	raw, err := ws.ReadFile(ctx, PreviewPath)
	if err != nil {
		return p, fmt.Errorf("claude did not write %s: %w", PreviewPath, err)
	}
	if multi {
		_ = ws.WriteFile(ctx, PreviewPath, nil) // the next repository writes its own
	}
	got, err := parsePreview(raw)
	if err != nil {
		return p, err
	}
	p.Status, p.Summary, p.Issues = got.Status, got.Summary, got.Issues

	// Copy the screenshots out; one that is missing or not a PNG is
	// dropped, not fatal.
	rename := map[string]string{}
	for _, sh := range got.Shots {
		if sh.File == "" {
			continue
		}
		b, err := ws.ReadFile(ctx, path.Join(previewOutDir, sh.File))
		if err != nil {
			o.log.Warn("read screenshot", "ticket", t.Key, "file", sh.File, "err", err)
			continue
		}
		w, h, ok := pngSize(b)
		if !ok || len(b) > previewMaxShotBytes {
			o.log.Warn("drop screenshot", "ticket", t.Key, "file", sh.File, "bytes", len(b), "png", ok)
			continue
		}
		if multi {
			id := r.Folder() + "-" + sh.ID
			if len(id) > 64 {
				id = id[:64]
			}
			rename[sh.ID], sh.ID = id, id
			sh.Name = r.Name + ": " + sh.Name
		}
		if err := o.shots.Save(t.WorkspaceID, t.Key, run.ID, sh.ID, b); err != nil {
			return p, fmt.Errorf("save screenshot %s: %w", sh.ID, err)
		}
		sh.File, sh.Width, sh.Height = "", w, h
		p.Shots = append(p.Shots, sh)
	}
	if len(p.Shots) == 0 && p.Status == domain.PreviewOK {
		p.Status = domain.PreviewPartial
	}
	// An issue about a screenshot that was dropped keeps its text only.
	for i, is := range p.Issues {
		if id, ok := rename[is.ShotID]; ok {
			p.Issues[i].ShotID = id
		}
		if multi {
			p.Issues[i].Description = r.Name + ": " + p.Issues[i].Description
		}
		if _, ok := p.Shot(p.Issues[i].ShotID); !ok {
			p.Issues[i].ShotID = ""
		}
	}
	// The acceptance check runs while the app still runs.
	if !accept {
		return p, nil
	}
	if criteria := o.acceptanceCriteria(ctx, t, repo); len(criteria) > 0 {
		acc, shots, err := o.checkAcceptance(ctx, s, ws, t, run, repo, criteria)
		if err != nil {
			var stop *stopError
			if errors.As(err, &stop) {
				return p, err
			}
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StagePreview), Type: domain.EventError, Level: domain.LevelWarn,
				Message: r.Label(multi) + "the acceptance check failed: " + err.Error()})
		} else {
			p.Acceptance = acc
			p.Shots = append(p.Shots, shots...)
			o.event(ctx, acceptanceEvent(t.Key, run, acc))
		}
	}
	return p, nil
}

// acceptanceEvent logs an acceptance check on the ticket.
func acceptanceEvent(key string, run *domain.Run, a *domain.Acceptance) domain.Event {
	pass, fail := 0, 0
	for _, c := range a.Criteria {
		switch c.Verdict {
		case "pass":
			pass++
		case "fail":
			fail++
		}
	}
	level := domain.LevelInfo
	if fail > 0 {
		level = domain.LevelWarn
	}
	return domain.Event{TicketKey: key, RunID: &run.ID, Step: string(domain.StagePreview), Type: domain.EventAcceptance, Level: level,
		Message: fmt.Sprintf("acceptance: %d of %d criteria met, %d not met", pass, len(a.Criteria), fail),
		Data:    map[string]any{"status": a.Status, "pass": pass, "fail": fail, "total": len(a.Criteria)}}
}

// writePreviewFiles puts the app's config and environment where
// agnts-preview reads them.
func (o *Orchestrator) writePreviewFiles(ctx context.Context, ws Workspace, r runRepo) error {
	repo := r.Repository
	rp := repo.Preview.ReadyPath
	if rp == "" {
		rp = "/"
	}
	cfg, _ := json.Marshal(previewConfig{Command: repo.Preview.Command, Port: repo.Preview.Port, ReadyPath: rp, DefaultBranch: repo.DefaultBranch, Dir: r.Folder()})
	if err := ws.WriteFile(ctx, PreviewConfigPath, cfg); err != nil {
		return fmt.Errorf("write the preview config: %w", err)
	}
	env := ""
	if o.envs != nil && repo.Preview.EnvSet {
		var err error
		if env, err = o.envs.PreviewEnv(ctx, repo.ID); err != nil {
			return fmt.Errorf("load the preview environment: %w", err)
		}
	}
	if err := ws.WriteFile(ctx, PreviewEnvPath, []byte(env)); err != nil {
		return fmt.Errorf("write the preview environment: %w", err)
	}
	return nil
}

// savePreview stores a finished preview, prunes older screenshots and
// marks the ticket's preview done if it is still on that revision.
func (o *Orchestrator) savePreview(ctx context.Context, t domain.Ticket, run *domain.Run, p domain.Preview, prev *domain.Preview) error {
	b, _ := json.Marshal(p)
	if err := o.store.SaveResult(ctx, domain.Result{RunID: run.ID, Summary: b}); err != nil {
		return err
	}
	keep := []int64{run.ID}
	if prev != nil {
		keep = append(keep, prev.RunID)
	}
	if err := o.shots.Prune(t.WorkspaceID, t.Key, keep); err != nil {
		o.log.Warn("prune screenshots", "ticket", t.Key, "err", err)
	}
	ev := previewEvent(t.Key, run, p)
	_, err := o.store.UpdateTicket(ctx, t.Key, &ev, func(x *domain.Ticket) {
		if x.PreviewState == domain.PreviewRunning && x.Revision == t.Revision {
			x.PreviewState = domain.PreviewDone
		}
	})
	return err
}

// parsePreview reads preview.json and cleans it.
func parsePreview(b []byte) (domain.Preview, error) {
	var p domain.Preview
	if err := json.Unmarshal(b, &p); err != nil {
		return p, fmt.Errorf("preview.json is not valid JSON: %w", err)
	}
	if !p.Normalize() {
		return p, errors.New("preview.json has no summary")
	}
	return p, nil
}

var pngMagic = []byte("\x89PNG\r\n\x1a\n")

// pngSize returns a PNG's width and height from its header, and false when
// b is not a PNG.
func pngSize(b []byte) (int, int, bool) {
	if len(b) < 24 || !bytes.HasPrefix(b, pngMagic) || string(b[12:16]) != "IHDR" {
		return 0, 0, false
	}
	return int(binary.BigEndian.Uint32(b[16:20])), int(binary.BigEndian.Uint32(b[20:24])), true
}

// previewEvent is the log line for a finished preview; the notifier
// announces it.
func previewEvent(key string, run *domain.Run, p domain.Preview) domain.Event {
	msg := fmt.Sprintf("preview: %d %s", len(p.Shots), plural(len(p.Shots), "screenshot", "screenshots"))
	switch {
	case p.Status == domain.PreviewBroken:
		msg = "preview: the app did not start"
	case len(p.Issues) > 0:
		msg += fmt.Sprintf(", %d %s", len(p.Issues), plural(len(p.Issues), "issue", "issues"))
	}
	worst := ""
	if len(p.Issues) > 0 {
		worst = p.Issues[0].Severity
	}
	phone := []string{}
	for _, s := range p.Shots {
		if s.Viewport == "phone" && s.Side == "after" {
			phone = append(phone, s.ID)
		}
	}
	return domain.Event{
		TicketKey: key, RunID: &run.ID, Step: string(domain.StagePreview), Type: domain.EventPreview, Message: msg,
		Data: map[string]any{"status": p.Status, "shots": len(p.Shots), "issues": len(p.Issues), "worst": worst,
			"revision": p.Revision, "model": p.Model, "runId": run.ID, "phoneShots": phone},
	}
}

// setPreviewState moves a running preview of t's revision to state.
func (o *Orchestrator) setPreviewState(ctx context.Context, t domain.Ticket, state string) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, nil, func(x *domain.Ticket) {
		if x.PreviewState == domain.PreviewRunning && x.Revision == t.Revision {
			x.PreviewState = state
		}
	}); err != nil {
		o.log.Error("set preview state", "ticket", t.Key, "err", err)
	}
}

// previewFailed records a failed preview run. The ticket stays in review.
func (o *Orchestrator) previewFailed(ctx context.Context, t domain.Ticket, run domain.Run, cause error) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventError, Level: domain.LevelWarn, Step: string(domain.StagePreview),
		Message: "the preview failed: " + cause.Error(),
	}, func(x *domain.Ticket) {
		if x.PreviewState == domain.PreviewRunning && x.Revision == t.Revision {
			x.PreviewState = domain.PreviewFailed
		}
	}); err != nil {
		o.log.Error("mark preview failed", "ticket", t.Key, "err", err)
	}
}

// LatestPreview returns the newest preview of a ticket, or nil.
func (o *Orchestrator) LatestPreview(ctx context.Context, ticketID int64) (*domain.Preview, error) {
	return o.latestPreview(ctx, ticketID)
}

func (o *Orchestrator) latestPreview(ctx context.Context, ticketID int64) (*domain.Preview, error) {
	r, err := o.store.LatestResult(ctx, ticketID, domain.StagePreview)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var p domain.Preview
	if json.Unmarshal(r.Summary, &p) != nil || p.Summary == "" {
		return nil, nil
	}
	p.RunID, p.CreatedAt = r.RunID, r.CreatedAt
	return &p, nil
}

// pruneShots deletes the screenshots of tickets finished more than
// previewKeepDays ago, and of tickets that no longer exist.
func (o *Orchestrator) pruneShots(ctx context.Context) {
	if o.shots == nil {
		return
	}
	refs, err := o.shots.Tickets()
	if err != nil {
		o.log.Warn("list screenshots", "err", err)
		return
	}
	cutoff := time.Now().AddDate(0, 0, -previewKeepDays)
	for _, r := range refs {
		t, err := o.store.TicketByKey(domain.WithWorkspace(ctx, r.WorkspaceID), r.Key)
		gone := errors.Is(err, domain.ErrNotFound)
		if err != nil && !gone {
			continue
		}
		if gone || (t.State.Terminal() && t.UpdatedAt.Before(cutoff)) {
			if err := o.shots.Prune(r.WorkspaceID, r.Key, nil); err != nil {
				o.log.Warn("prune screenshots", "workspace", r.WorkspaceID, "ticket", r.Key, "err", err)
			}
		}
	}
}

// checkShotRefs keeps the screenshot references feedback may carry: ones
// stored for this ticket, each once, at most domain.MaxFeedbackShots.
func (o *Orchestrator) checkShotRefs(ws int64, key string, refs []domain.ShotRef) ([]domain.ShotRef, error) {
	if len(refs) == 0 {
		return nil, nil
	}
	if o.shots == nil {
		return nil, invalid("previews are not available on this server")
	}
	out := []domain.ShotRef{}
	for _, r := range refs {
		if slices.Contains(out, r) {
			continue
		}
		if len(out) >= domain.MaxFeedbackShots {
			return nil, invalid("feedback can point at %d screenshots at most", domain.MaxFeedbackShots)
		}
		rc, err := o.shots.Open(ws, key, r.RunID, r.ShotID)
		if err != nil {
			return nil, invalid("screenshot %s of run %d is not one of %s's", r.ShotID, r.RunID, key)
		}
		_ = rc.Close()
		out = append(out, r)
	}
	return out, nil
}

// feedbackShotPath is where a coding run finds a screenshot the reviewer
// pointed at.
func feedbackShotPath(r domain.ShotRef) string {
	return fmt.Sprintf("%s/feedback-%d-%s.png", previewOutDir, r.RunID, r.ShotID)
}

// copyFeedbackShots puts the screenshots the feedback points at into the
// workspace and returns their paths; one that is gone is skipped.
func (o *Orchestrator) copyFeedbackShots(ctx context.Context, ws Workspace, t domain.Ticket) []string {
	if o.shots == nil {
		return nil
	}
	var out []string
	for _, r := range t.FeedbackShots {
		rc, err := o.shots.Open(t.WorkspaceID, t.Key, r.RunID, r.ShotID)
		if err != nil {
			continue
		}
		b, err := io.ReadAll(io.LimitReader(rc, previewMaxShotBytes+1))
		_ = rc.Close()
		if err != nil {
			continue
		}
		p := feedbackShotPath(r)
		if err := ws.WriteFile(ctx, p, b); err != nil {
			o.log.Warn("copy feedback screenshot", "ticket", t.Key, "err", err)
			continue
		}
		out = append(out, p)
	}
	return out
}

// OpenShot returns one of a ticket's stored screenshots, or domain.ErrNotFound.
func (o *Orchestrator) OpenShot(ctx context.Context, key string, runID int64, shotID string) (io.ReadCloser, error) {
	if o.shots == nil {
		return nil, domain.ErrNotFound
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return nil, err
	}
	return o.shots.Open(t.WorkspaceID, key, runID, shotID)
}
