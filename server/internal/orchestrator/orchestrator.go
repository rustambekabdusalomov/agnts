package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"sync"
	"time"

	"golang.org/x/sync/singleflight"

	"agnts/internal/domain"
)

// Config holds limits that are not user settings.
type Config struct {
	Image        string        // runner image
	CheckTimeout time.Duration // one check command
	FixAttempts  int           // check failures sent back to Claude before giving up
	PollEvery    time.Duration
}

// DefaultConfig returns the built-in limits.
func DefaultConfig() Config {
	return Config{
		Image:        "agnts-runner:latest",
		CheckTimeout: 15 * time.Minute,
		FixAttempts:  2,
		PollEvery:    5 * time.Second,
	}
}

// SettingsSource returns the current runtime settings.
type SettingsSource interface {
	Get(ctx context.Context) (domain.Settings, error)
}

// UsageGate tracks plan usage: whether new runs may start, and readings
// taken from Claude Code's rate limit events.
type UsageGate interface {
	// Paused reports whether new runs must wait, and until when if known.
	Paused(ctx context.Context, s domain.Settings) (bool, time.Time)
	// Record stores a rate-limit reading (data is the raw stream line).
	Record(ctx context.Context, data map[string]any)
	// RecordLimited notes that a run was refused at the plan limit.
	RecordLimited(ctx context.Context)
}

// Deps are the orchestrator's collaborators.
type Deps struct {
	Store    Store
	Runner   Runner
	Git      Git
	Host     Host
	Tracker  Tracker // nil when no tracker is configured
	Homes    Homes
	Settings SettingsSource
	Usage    UsageGate
	Lessons  Lessons // nil disables the learn stage
	Rules    Rules   // nil disables rules
	// Translations stores translated ticket texts; nil disables translation.
	Translations Translations
}

// Orchestrator runs tickets through their stages.
type Orchestrator struct {
	cfg      Config
	store    Store
	runner   Runner
	git      Git
	host     Host
	tracker  Tracker
	homes    Homes
	settings SettingsSource
	usage    UsageGate
	lessons  Lessons
	rules    Rules
	trans    Translations
	log      *slog.Logger

	wake chan struct{}

	mu      sync.Mutex
	cancels map[string]context.CancelFunc // ticket key -> cancel of its active run
	active  int
	paused  bool

	translating singleflight.Group // ticket key and language -> its translation run
}

// New returns an orchestrator.
func New(cfg Config, d Deps, log *slog.Logger) *Orchestrator {
	return &Orchestrator{
		cfg: cfg, store: d.Store, runner: d.Runner, git: d.Git, host: d.Host, tracker: d.Tracker, homes: d.Homes,
		settings: d.Settings, usage: d.Usage, lessons: d.Lessons, rules: d.Rules, trans: d.Translations, log: log,
		wake:    make(chan struct{}, 1),
		cancels: map[string]context.CancelFunc{},
	}
}

// Wake asks the loop to look for work now instead of at the next poll.
func (o *Orchestrator) Wake() {
	select {
	case o.wake <- struct{}{}:
	default:
	}
}

// Active returns how many stages are running.
func (o *Orchestrator) Active() int {
	o.mu.Lock()
	defer o.mu.Unlock()
	return o.active
}

// Run is the worker loop. It returns when ctx is cancelled, after the
// active stages have stopped. Interrupted runs are recovered on the next start.
func (o *Orchestrator) Run(ctx context.Context) error {
	if n, err := o.store.RecoverInterrupted(ctx); err != nil {
		return fmt.Errorf("recover interrupted runs: %w", err)
	} else if n > 0 {
		o.log.Warn("recovered interrupted runs", "count", n)
	}
	if o.rules != nil {
		if n, err := o.rules.RecoverRules(ctx); err != nil {
			return fmt.Errorf("recover interrupted rule reviews: %w", err)
		} else if n > 0 {
			o.log.Warn("requeued interrupted rule reviews", "count", n)
		}
	}

	var wg sync.WaitGroup
	defer wg.Wait()
	tick := time.NewTicker(o.cfg.PollEvery)
	defer tick.Stop()
	lastResume := time.Time{}

	for {
		s, err := o.settings.Get(ctx)
		if err != nil && ctx.Err() == nil {
			o.log.Error("load settings", "err", err)
		}
		if time.Since(lastResume) > time.Minute {
			lastResume = time.Now()
			o.AutoResume(ctx, s)
		}
		for err == nil && o.mayStart(ctx, s) {
			job, ok, cerr := o.claim(ctx)
			if cerr != nil || !ok {
				if cerr != nil && ctx.Err() == nil {
					o.log.Error("claim", "err", cerr)
				}
				break
			}
			o.mu.Lock()
			o.active++
			o.mu.Unlock()
			wg.Add(1)
			go func() {
				defer wg.Done()
				defer func() {
					o.mu.Lock()
					o.active--
					o.mu.Unlock()
					o.Wake()
				}()
				job(ctx)
			}()
		}
		select {
		case <-ctx.Done():
			return nil
		case <-tick.C:
		case <-o.wake:
		}
	}
}

// mayStart applies the parallel limit and the plan-usage pause.
func (o *Orchestrator) mayStart(ctx context.Context, s domain.Settings) bool {
	if ctx.Err() != nil {
		return false
	}
	o.mu.Lock()
	full := o.active >= max(1, s.Parallel)
	o.mu.Unlock()
	if full {
		return false
	}
	paused, until := o.usage.Paused(ctx, s)
	o.mu.Lock()
	changed := paused != o.paused
	o.paused = paused
	o.mu.Unlock()
	if changed {
		if paused {
			o.log.Warn("plan usage limit: not starting new runs", "until", until)
		} else {
			o.log.Info("plan usage below the limit: starting runs again")
		}
	}
	return !paused
}

// RunOnce claims and works one stage synchronously, without the usage
// pause or parallel limit. It reports false when there was nothing to do.
func (o *Orchestrator) RunOnce(ctx context.Context) (bool, error) {
	job, ok, err := o.claim(ctx)
	if err != nil || !ok {
		return false, err
	}
	job(ctx)
	return true, nil
}

// claim takes the next piece of work. Rule reviews go first: they are short
// and the user is waiting on them, and every later ticket follows the result.
func (o *Orchestrator) claim(ctx context.Context) (func(context.Context), bool, error) {
	if o.rules != nil {
		r, ok, err := o.rules.ClaimRule(ctx)
		if err != nil {
			return nil, false, err
		}
		if ok {
			return func(ctx context.Context) { o.reviewRule(ctx, r) }, true, nil
		}
	}
	t, run, ok, err := o.store.ClaimNext(ctx)
	if err != nil || !ok {
		return nil, false, err
	}
	return func(ctx context.Context) { o.work(ctx, t, run) }, true, nil
}

// work runs one claimed stage and records how it ended.
func (o *Orchestrator) work(parent context.Context, t domain.Ticket, run domain.Run) {
	ctx, cancel := context.WithCancel(parent)
	o.mu.Lock()
	o.cancels[t.Key] = cancel
	o.mu.Unlock()
	defer func() {
		o.mu.Lock()
		delete(o.cancels, t.Key)
		o.mu.Unlock()
		cancel()
	}()

	log := o.log.With("ticket", t.Key, "stage", run.Stage, "run_id", run.ID)
	log.Info("stage started")
	s, err := o.settings.Get(ctx)
	if err == nil {
		switch run.Stage {
		case domain.StageAnalyze:
			err = o.analyze(ctx, s, t, &run)
		case domain.StageCode:
			if t.Kind.Report() {
				err = o.report(ctx, s, t, &run)
			} else {
				err = o.code(ctx, s, t, &run)
			}
		case domain.StagePush:
			if t.Kind.Report() {
				err = o.deliver(ctx, t, &run)
			} else {
				err = o.push(ctx, s, t, &run)
			}
		case domain.StageLearn:
			err = o.learn(ctx, s, t, &run)
		case domain.StageReview:
			err = o.review(ctx, s, t, &run)
		default:
			err = fmt.Errorf("unknown stage %q", run.Stage)
		}
	}

	if parent.Err() != nil {
		// Shutting down: leave the run open so RecoverInterrupted resumes it.
		log.Info("stage interrupted by shutdown")
		return
	}
	// Use a fresh context: ctx may be cancelled by Reject or Stop.
	bg := context.WithoutCancel(parent)
	if run.ExitReason == "" {
		run.ExitReason = "ok"
		if err != nil {
			run.ExitReason = "error"
		}
		if ctx.Err() != nil {
			run.ExitReason = "stopped"
		}
	}
	now := time.Now()
	run.FinishedAt = &now
	if ferr := o.store.FinishRun(bg, run); ferr != nil {
		log.Error("finish run", "err", ferr)
	}
	if err == nil {
		log.Info("stage finished")
		return
	}

	var stop *stopError
	switch {
	case errors.As(err, &stop):
		// The stage already moved the ticket (rate limited, ...).
		log.Info("stage stopped", "reason", stop.reason)
	case ctx.Err() != nil:
		log.Info("stage cancelled")
	case run.Stage == domain.StageLearn:
		// The ticket is done; only the lessons are missing.
		log.Warn("learn run failed", "err", err)
		o.learnFailed(bg, t.Key, run, err)
	case run.Stage == domain.StageReview:
		// The ticket stays in review; only the code review is missing.
		log.Warn("review run failed", "err", err)
		o.reviewFailed(bg, t, run, err)
	default:
		log.Error("stage failed", "err", err)
		o.fail(bg, t.Key, run, err)
	}
	o.Wake()
}

// stopError ends a stage that already put the ticket in its next state.
type stopError struct{ reason string }

func (e *stopError) Error() string { return e.reason }

// resumeStateFor is where Retry sends a ticket that failed in stage s.
func resumeStateFor(s domain.Stage) domain.TicketState {
	switch s {
	case domain.StageCode:
		return domain.StateCoding
	case domain.StagePush:
		return domain.StatePushing
	default:
		return domain.StateNew
	}
}

func (o *Orchestrator) fail(ctx context.Context, key string, run domain.Run, cause error) {
	_, err := o.store.Transition(ctx, key, domain.StateFailed, domain.Event{
		TicketKey: key, RunID: &run.ID, Type: domain.EventStateChanged, Level: domain.LevelError,
		Message: cause.Error(), Step: string(run.Stage),
	}, func(t *domain.Ticket) { t.ResumeState = resumeStateFor(run.Stage) })
	if err != nil && !errors.Is(err, domain.ErrConflict) {
		o.log.Error("mark failed", "ticket", key, "err", err)
	}
}

// event appends a ticket event, logging (not returning) store errors.
func (o *Orchestrator) event(ctx context.Context, ev domain.Event) {
	if ev.Level == "" {
		ev.Level = domain.LevelInfo
	}
	if ev.Origin == "" {
		ev.Origin = domain.OriginSystem
	}
	if err := o.store.AppendEvent(ctx, ev); err != nil {
		o.log.Error("append event", "ticket", ev.TicketKey, "type", ev.Type, "err", err)
	}
}

func (o *Orchestrator) transition(ctx context.Context, t *domain.Ticket, run *domain.Run, to domain.TicketState, msg string, mut func(*domain.Ticket)) error {
	nt, err := o.store.Transition(ctx, t.Key, to, domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventStateChanged, Message: msg, Step: string(run.Stage),
	}, mut)
	if err != nil {
		return err
	}
	*t = nt
	return nil
}

// streamTo returns a Claude event handler that logs to the ticket and
// feeds rate-limit readings to the usage tracker.
func (o *Orchestrator) streamTo(ctx context.Context, t domain.Ticket, run *domain.Run) func(ClaudeEvent) {
	return func(e ClaudeEvent) {
		ev := domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Data: e.Data}
		switch e.Kind {
		case ClaudeInit:
			if id, _ := e.Data["session_id"].(string); id != "" {
				run.SessionID = id
			}
			return
		case ClaudeText:
			ev.Type, ev.Message = domain.EventClaudeText, truncate(e.Text, 4000)
		case ClaudeTool:
			ev.Type, ev.Message = domain.EventClaudeTool, e.Tool
		case ClaudeRateLimit:
			o.usage.Record(ctx, e.Data)
			ev.Type, ev.Message = domain.EventRateLimit, "plan usage update"
			if st := rateStatus(e.Data); st != "" && st != "allowed" {
				ev.Level, ev.Message = domain.LevelWarn, "plan usage: "+strings.ReplaceAll(st, "_", " ")
			}
		case ClaudeResultEv:
			ev.Type, ev.Message = domain.EventClaudeResult, truncate(e.Text, 4000)
		default:
			return
		}
		o.event(ctx, ev)
	}
}

func rateStatus(data map[string]any) string {
	if info, ok := data["rate_limit_info"].(map[string]any); ok {
		data = info
	}
	s, _ := data["status"].(string)
	return s
}

// permissionSettings is passed to Claude Code with --settings; the
// managed settings in the runner image still outrank it. readOnly keeps
// Claude's edit tools out of /workspace (report kinds).
func permissionSettings(s domain.Settings, readOnly bool) string {
	allow := make([]string, 0, len(s.Allow))
	for _, c := range s.Allow {
		allow = append(allow, bashRule(c))
	}
	deny := make([]string, 0, len(s.Deny)+3)
	for _, c := range s.Deny {
		deny = append(deny, bashRule(c))
	}
	if readOnly {
		// "//" makes the path absolute in Claude Code permission rules.
		deny = append(deny, "Edit(//workspace/**)", "Write(//workspace/**)", "NotebookEdit(//workspace/**)")
	}
	b, _ := json.Marshal(map[string]any{"permissions": map[string]any{"allow": allow, "deny": deny}})
	return string(b)
}

// bashRule turns "go test" into "Bash(go test *)"; full rules pass through.
func bashRule(c string) string {
	if strings.Contains(c, "(") {
		return c
	}
	return "Bash(" + c + " *)"
}

// claude runs one invocation with the model for modelStage, and turns rate
// limits and errors into states.
func (o *Orchestrator) claude(ctx context.Context, s domain.Settings, ws Workspace, t *domain.Ticket, run *domain.Run, modelStage, prompt, resume string) (ClaudeResult, error) {
	model := s.ModelFor(*t, modelStage)
	if run.Model == "" {
		run.Model = model
	}
	turns := s.MaxTurns
	if modelStage == domain.ModelAnalyze {
		turns = min(turns, 60)
	}
	res, err := ws.Claude(ctx, ClaudeRequest{
		Prompt:   prompt,
		Model:    model,
		MaxTurns: turns,
		Resume:   resume,
		Timeout:  time.Duration(s.TimeoutMin) * time.Minute,
		Settings: permissionSettings(s, t.Kind.Report() || run.Stage == domain.StageReview),
	}, o.streamTo(ctx, *t, run))
	run.Turns += res.Turns
	if res.SessionID != "" {
		run.SessionID = res.SessionID
	}
	o.recordSpend(ctx, run, modelStage, model, res)
	if err != nil {
		return res, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		run.ExitReason = "rate_limited"
		if run.Stage.Side() {
			// A side run never moves the ticket; it is queued again and
			// claimed once usage allows.
			return res, &stopError{"rate limited"}
		}
		if err := o.transition(ctx, t, run, domain.StateRateLimited, "Claude plan limit reached; resumes after the limit resets", func(x *domain.Ticket) {
			x.ResumeState = resumeStateFor(run.Stage)
		}); err != nil {
			return res, err
		}
		o.trackerComment(ctx, *t, CommentStatus, "agnts paused at the Claude plan limit and resumes after it resets.")
		return res, &stopError{"rate limited"}
	}
	if res.IsError {
		run.ExitReason = "claude_" + res.Subtype
		if res.Subtype == "error_max_turns" {
			return res, fmt.Errorf("stopped at the turn limit (%d); raise it in Settings or split the ticket", turns)
		}
		return res, fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	return res, nil
}

// recordSpend stores the tokens an invocation used, failed and rate-limited
// ones included: they were spent all the same. An invocation that never
// reached Claude (no turns, no tokens) is not recorded.
func (o *Orchestrator) recordSpend(ctx context.Context, run *domain.Run, modelStage, model string, res ClaudeResult) {
	if res.Usage.IsZero() && res.Turns == 0 {
		return
	}
	if res.Model != "" {
		model = res.Model
	}
	// The run may have been stopped; the spend is recorded regardless.
	if err := o.store.RecordClaudeCall(context.WithoutCancel(ctx), domain.ClaudeCall{
		RunID: run.ID, ModelStage: modelStage, Model: model, Usage: res.Usage,
		Turns: res.Turns, Duration: res.Duration, Partial: res.Partial,
	}); err != nil {
		o.log.Error("record claude spend", "run_id", run.ID, "err", err)
	}
}

var errNoRepo = errors.New("no repository is linked to this ticket; add one on the Repositories page and retry")

func (o *Orchestrator) repoFor(ctx context.Context, t domain.Ticket) (domain.Repository, error) {
	if t.RepoID == nil {
		return domain.Repository{}, errNoRepo
	}
	return o.store.RepositoryByID(ctx, *t.RepoID)
}

// optionalRepo returns the ticket's repository, or nil when it has none
// and its kind can work without one (or agnts has yet to pick the kind).
func (o *Orchestrator) optionalRepo(ctx context.Context, t domain.Ticket) (*domain.Repository, error) {
	if t.RepoID == nil {
		if t.Kind.Spec().NeedsRepo && !t.KindAuto {
			return nil, errNoRepo
		}
		return nil, nil
	}
	repo, err := o.store.RepositoryByID(ctx, *t.RepoID)
	if err != nil {
		return nil, err
	}
	return &repo, nil
}

func branchFor(repo domain.Repository, key string) string {
	prefix := repo.BranchPrefix
	if prefix == "" {
		prefix = "agnts/"
	}
	return prefix + key
}

// openWorkspace starts a container with repo checked out at branch, or an
// empty /workspace when repo is nil.
func (o *Orchestrator) openWorkspace(ctx context.Context, t domain.Ticket, repo *domain.Repository, branch string, run *domain.Run) (Workspace, error) {
	var tree io.Reader
	if repo != nil {
		if err := o.git.Prepare(ctx, *repo, branch); err != nil {
			return nil, fmt.Errorf("prepare repository: %w", err)
		}
		rc, err := o.git.Archive(ctx, *repo, branch)
		if err != nil {
			return nil, fmt.Errorf("archive repository: %w", err)
		}
		defer func() { _ = rc.Close() }()
		tree = rc
	} else {
		var empty bytes.Buffer
		_ = tar.NewWriter(&empty).Close()
		tree = &empty
	}
	home, err := o.homes.Load(t.Key)
	if err != nil {
		return nil, fmt.Errorf("load claude home: %w", err)
	}
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: t.Key, Image: o.cfg.Image, Repo: tree, ClaudeHome: home})
	if err != nil {
		return nil, fmt.Errorf("start container: %w", err)
	}
	run.ContainerID = ws.ID()
	return ws, nil
}

func (o *Orchestrator) closeWorkspace(ctx context.Context, t domain.Ticket, ws Workspace) {
	bg := context.WithoutCancel(ctx)
	if home, err := ws.ExportClaudeHome(bg); err == nil {
		if err := o.homes.Save(t.Key, home); err != nil {
			o.log.Warn("save claude home", "ticket", t.Key, "err", err)
		}
	} else {
		o.log.Warn("export claude home", "ticket", t.Key, "err", err)
	}
	if err := ws.Close(bg); err != nil {
		o.log.Warn("remove container", "ticket", t.Key, "err", err)
	}
}

// analyze reads the ticket (and the code, if it has a repository), settles
// its kind, and either asks questions or moves on to the work.
func (o *Orchestrator) analyze(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	repo, err := o.optionalRepo(ctx, t)
	if err != nil {
		return err
	}
	branch := ""
	d := promptData{T: t, NoRepo: repo == nil, NoQuestions: !t.AskFirst}
	if repo != nil {
		d.Repo, branch = *repo, branchFor(*repo, t.Key)
		if t.Kind.Report() && !t.KindAuto {
			branch = repo.DefaultBranch // a report never commits
		}
	}
	o.trackerMove(ctx, t, TrackerStarted)

	ws, err := o.openWorkspace(ctx, t, repo, branch, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)

	if d.Rules, err = o.teamRules(ctx, t.RepoID); err != nil {
		return err
	}
	if len(d.Rules) > 0 {
		o.event(ctx, rulesEvent(t.Key, run, d.Rules))
	}
	prompt, err := render("analyze", d)
	if err != nil {
		return err
	}
	if prompt, err = o.withFollowUps(ctx, s, t, d, domain.SuggestFromAnalyze, AnalysisPath, prompt); err != nil {
		return err
	}
	candidates, err := o.relationCandidates(ctx, t)
	if err != nil {
		return err
	}
	if prompt, err = withRelations(d, candidates, prompt); err != nil {
		return err
	}
	if _, err := o.claude(ctx, s, ws, &t, run, domain.ModelAnalyze, prompt, ""); err != nil {
		return err
	}
	raw, err := ws.ReadFile(ctx, AnalysisPath)
	if err != nil {
		return fmt.Errorf("claude did not write %s: %w", AnalysisPath, err)
	}
	a, err := parseAnalysis(raw)
	if err != nil {
		return err
	}
	if err := o.store.SaveResult(ctx, domain.Result{RunID: run.ID, Summary: raw}); err != nil {
		return err
	}
	if t, err = o.settleKind(ctx, t, run, a); err != nil {
		return err
	}
	o.saveFollowUps(ctx, s, t, run, domain.SuggestFromAnalyze, a.FollowUps)
	// Before the ticket can be claimed for coding, so the queue sees them.
	o.applyRelations(ctx, t, run, a, candidates)
	if t.Kind.Spec().NeedsRepo && repo == nil {
		return fmt.Errorf("agnts read this ticket as %s work, which needs a repository: link one and retry, or change the kind", t.Kind)
	}
	if t.Kind.Report() {
		branch = "" // nothing is committed for a report
	}

	qs := make([]domain.Question, 0, len(a.Questions))
	if t.AskFirst {
		for i, q := range a.Questions {
			if strings.TrimSpace(q.Text) == "" {
				continue
			}
			qs = append(qs, domain.Question{TicketID: t.ID, Position: i + 1, Text: q.Text, Options: q.Options})
		}
	}
	if err := o.store.ReplaceQuestions(ctx, t.ID, qs); err != nil {
		return err
	}

	setBranch := func(x *domain.Ticket) { x.Branch = branch }
	work := "code"
	if t.Kind.Report() {
		work = "write the report"
	}
	if len(qs) > 0 {
		o.trackerComment(ctx, t, CommentQuestions, analysisComment(a, true))
		return o.transition(ctx, &t, run, domain.StateWaitingForAnswers, fmt.Sprintf("%d questions before starting to %s", len(qs), work), setBranch)
	}
	o.trackerComment(ctx, t, CommentPlan, analysisComment(a, false))
	return o.transition(ctx, &t, run, domain.StateCoding, "no questions, starting to "+work, setBranch)
}

// settleKind applies the kind the analysis read from the ticket. While agnts
// picks the kind it takes that reading; a kind someone chose stays, and a
// disagreement is only a warning on the ticket.
func (o *Orchestrator) settleKind(ctx context.Context, t domain.Ticket, run *domain.Run, a Analysis) (domain.Ticket, error) {
	if !a.Kind.Valid() || a.Kind == t.Kind {
		return t, nil
	}
	data := map[string]any{"from": string(t.Kind), "to": string(a.Kind), "reason": a.KindReason}
	if !t.KindAuto {
		msg := fmt.Sprintf("this reads like %s work, not %s", a.Kind, t.Kind)
		if a.KindReason != "" {
			msg += ": " + a.KindReason
		}
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventKind,
			Level: domain.LevelWarn, Message: msg + ". Kept " + string(t.Kind) + ", as it was chosen.", Data: data})
		return t, nil
	}
	msg := fmt.Sprintf("agnts picked %s", a.Kind)
	if a.KindReason != "" {
		msg += ": " + a.KindReason
	}
	return o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventKind, Message: msg, Data: data,
	}, func(x *domain.Ticket) { x.Kind = a.Kind })
}

// code implements the ticket (or the review feedback), runs the checks with
// a fix loop, and stores the diff for review.
func (o *Orchestrator) code(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	repo, err := o.repoFor(ctx, t)
	if err != nil {
		return err
	}
	branch := t.Branch
	if branch == "" {
		branch = branchFor(repo, t.Key)
	}
	ws, err := o.openWorkspace(ctx, t, &repo, branch, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)

	session, err := o.store.LastSessionID(ctx, t.ID)
	if err != nil {
		return err
	}
	var prompt string
	modelStage := domain.ModelCoding
	feedback := t.Feedback
	if feedback != "" && session != "" {
		modelStage = domain.ModelRetry
		prompt, err = render("feedback", promptData{T: t, Feedback: feedback})
	} else {
		d := promptData{T: t, Repo: repo, Checks: checksLine(repo)}
		if d.Rules, err = o.teamRules(ctx, t.RepoID); err != nil {
			return err
		}
		if r, rerr := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); rerr == nil {
			if a, aerr := parseAnalysis(r.Summary); aerr == nil {
				d.Plan = a.Plan
			}
		}
		if d.Answers, err = o.store.Questions(ctx, t.ID); err != nil {
			return err
		}
		if t.HeadSHA == "" {
			d.Landed = o.landedDependencies(ctx, t)
		}
		prompt, err = render("code", d)
		if err == nil && feedback != "" {
			d.Feedback = feedback
			extra, _ := render("feedback", d)
			prompt += "\n" + extra
		}
	}
	if err == nil {
		prompt, err = o.withFollowUps(ctx, s, t, promptData{Repo: repo}, domain.SuggestFromWork, SummaryPath, prompt)
	}
	if err != nil {
		return err
	}

	res, err := o.claude(ctx, s, ws, &t, run, modelStage, prompt, session)
	if err != nil {
		return err
	}
	if feedback != "" {
		if _, err := o.store.UpdateTicket(ctx, t.Key, nil, func(x *domain.Ticket) { x.Feedback = "" }); err != nil {
			return err
		}
	}

	if err := o.transition(ctx, &t, run, domain.StateTesting, "running checks", nil); err != nil {
		return err
	}
	var checks checkReport
	for attempt := 0; ; attempt++ {
		checks = o.runChecks(ctx, ws, t, repo, run)
		if checks.OK || ctx.Err() != nil {
			break
		}
		if attempt >= o.cfg.FixAttempts {
			run.ExitReason = "checks_failed"
			return fmt.Errorf("checks still failing after %d fix attempts:\n%s", attempt, truncate(checks.FailOutput, 2000))
		}
		if err := o.transition(ctx, &t, run, domain.StateCoding, fmt.Sprintf("checks failed, fix attempt %d", attempt+1), nil); err != nil {
			return err
		}
		fix, err := render("fix", promptData{T: t, Output: truncate(checks.FailOutput, 8000)})
		if err != nil {
			return err
		}
		if res, err = o.claude(ctx, s, ws, &t, run, domain.ModelRetry, fix, res.SessionID); err != nil {
			return err
		}
		if err := o.transition(ctx, &t, run, domain.StateTesting, "running checks again", nil); err != nil {
			return err
		}
	}
	if err := ctx.Err(); err != nil {
		return err
	}

	summary, err := ws.ReadFile(ctx, SummaryPath)
	if err != nil {
		summary, _ = json.Marshal(Summary{Summary: res.Text})
	}
	tree, err := ws.ExportRepo(ctx)
	if err != nil {
		return fmt.Errorf("export workspace: %w", err)
	}
	defer func() { _ = tree.Close() }()
	sha, files, err := o.git.Commit(ctx, repo, branch, tree, commitMessage(t, s.Git))
	if err != nil {
		return fmt.Errorf("commit: %w", err)
	}
	if len(files) == 0 {
		run.ExitReason = "no_changes"
		return errors.New("claude finished without changing any files")
	}
	testsJSON, _ := json.Marshal(checks.Steps)
	if err := o.store.SaveResult(ctx, domain.Result{
		RunID: run.ID, Summary: summary, Tests: testsJSON, Lint: checks.LintOutput, Files: files,
	}); err != nil {
		return err
	}
	o.saveFollowUps(ctx, s, t, run, domain.SuggestFromWork, summaryFollowUps(summary))
	if t.HeadSHA == "" {
		o.checkFootprint(ctx, t, run, files) // the first change only: later ones follow feedback, not the plan
	}
	o.checkCollisions(ctx, t, run, repo, files)
	return o.transition(ctx, &t, run, domain.StateWaitingForReview, fmt.Sprintf("%d files changed, ready for review", len(files)), func(x *domain.Ticket) {
		x.Branch, x.HeadSHA = branch, sha
		x.Turns += run.Turns
		x.ReviewState = reviewState(s)
	})
}

// report has Claude write the ticket's report (or rewrite it with the
// reviewer's feedback) and stores it for review. Nothing in /workspace is
// kept: the container's tree is never exported.
func (o *Orchestrator) report(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	repo, err := o.optionalRepo(ctx, t)
	if err != nil {
		return err
	}
	d := promptData{T: t, NoRepo: repo == nil}
	branch := ""
	if repo != nil {
		d.Repo, branch = *repo, repo.DefaultBranch
	}
	ws, err := o.openWorkspace(ctx, t, repo, branch, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)

	session, err := o.store.LastSessionID(ctx, t.ID)
	if err != nil {
		return err
	}
	feedback := t.Feedback
	modelStage := domain.ModelCoding
	var prompt string
	if feedback != "" {
		modelStage = domain.ModelRetry
		// The container is new: put the report under review back for Claude.
		if r, rerr := o.store.LatestResult(ctx, t.ID, domain.StageCode); rerr == nil && r.Report != "" {
			if err := ws.WriteFile(ctx, ReportPath, []byte(r.Report)); err != nil {
				return fmt.Errorf("restore report: %w", err)
			}
		}
	}
	if feedback != "" && session != "" {
		prompt, err = render("report-feedback", promptData{T: t, Feedback: feedback})
	} else {
		if d.Rules, err = o.teamRules(ctx, t.RepoID); err != nil {
			return err
		}
		if r, rerr := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); rerr == nil {
			if a, aerr := parseAnalysis(r.Summary); aerr == nil {
				d.Plan = a.Plan
			}
		}
		if d.Answers, err = o.store.Questions(ctx, t.ID); err != nil {
			return err
		}
		prompt, err = render("report", d)
		if err == nil && feedback != "" {
			d.Feedback = feedback
			extra, _ := render("report-feedback", d)
			prompt += "\n" + extra
		}
	}
	if err == nil {
		prompt, err = o.withFollowUps(ctx, s, t, d, "report", SummaryPath, prompt)
	}
	if err != nil {
		return err
	}

	res, err := o.claude(ctx, s, ws, &t, run, modelStage, prompt, session)
	if err != nil {
		return err
	}
	if feedback != "" {
		if _, err := o.store.UpdateTicket(ctx, t.Key, nil, func(x *domain.Ticket) { x.Feedback = "" }); err != nil {
			return err
		}
	}
	md, err := ws.ReadFile(ctx, ReportPath)
	if err != nil {
		return fmt.Errorf("claude did not write %s: %w", ReportPath, err)
	}
	if strings.TrimSpace(string(md)) == "" {
		run.ExitReason = "no_report"
		return errors.New("claude wrote an empty report")
	}
	summary, err := ws.ReadFile(ctx, SummaryPath)
	if err != nil {
		summary, _ = json.Marshal(Summary{Summary: res.Text})
	}
	if err := o.store.SaveResult(ctx, domain.Result{RunID: run.ID, Summary: summary, Report: string(md)}); err != nil {
		return err
	}
	o.saveFollowUps(ctx, s, t, run, domain.SuggestFromWork, summaryFollowUps(summary))
	return o.transition(ctx, &t, run, domain.StateWaitingForReview, "report ready for review", func(x *domain.Ticket) {
		x.Turns += run.Turns
		x.ReviewState = reviewState(s)
	})
}

// maxReportComment keeps a posted report under Jira's comment limit.
const maxReportComment = 30000

// deliver finishes an approved report: it stays in agnts, and goes to the
// tracker issue when the reviewer asked for that.
func (o *Orchestrator) deliver(ctx context.Context, t domain.Ticket, run *domain.Run) error {
	r, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if errors.Is(err, domain.ErrNotFound) || (err == nil && r.Report == "") {
		return errors.New("nothing to deliver: this ticket has no report")
	}
	if err != nil {
		return err
	}
	msg := "report approved"
	if t.PostReport {
		if t.Source != domain.SourceJira || o.tracker == nil {
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventTrackerComment, Level: domain.LevelWarn,
				Message: "the report was not posted: this ticket has no tracker issue"})
		} else {
			text := r.Report
			if len(text) > maxReportComment {
				text = truncate(text, maxReportComment) + "\n\n(The full report is in agnts.)"
			}
			posted, err := o.tracker.Comment(ctx, t.Key, CommentReport, text)
			if err != nil {
				return fmt.Errorf("post the report to %s: %w", t.Key, err)
			}
			if !posted {
				return fmt.Errorf("post the report to %s: the tracker is not connected", t.Key)
			}
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventTrackerComment, Message: "report posted to the issue"})
			msg = "report approved and posted to the issue"
		}
	}
	return o.transition(ctx, &t, run, domain.StateDone, msg, nil)
}

// push sends the approved work: a branch and pull request, or (for side
// projects that chose it) a fast-forward push to the default branch.
func (o *Orchestrator) push(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	repo, err := o.repoFor(ctx, t)
	if err != nil {
		return err
	}
	if t.Branch == "" || t.HeadSHA == "" {
		return errors.New("nothing to push: no reviewed commit on this ticket")
	}

	if t.AfterApprove == "main" && t.Source == domain.SourceLocal {
		if err := o.git.PushTo(ctx, repo, t.Branch, repo.DefaultBranch); err != nil {
			return fmt.Errorf("push to %s: %w", repo.DefaultBranch, err)
		}
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventPushed,
			Message: "pushed to " + repo.DefaultBranch, Data: map[string]any{"branch": repo.DefaultBranch, "sha": t.HeadSHA}})
		return o.transition(ctx, &t, run, domain.StateDone, "pushed to "+repo.DefaultBranch, func(x *domain.Ticket) {
			if o.learnQueued(s, *x) {
				x.LearnState = domain.LearnPending
			}
		})
	}

	drift := o.checkDrift(ctx, t, run, repo)
	if err := o.git.Push(ctx, repo, t.Branch); err != nil {
		return fmt.Errorf("push %s: %w", t.Branch, err)
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventPushed,
		Message: "pushed " + t.Branch, Data: map[string]any{"branch": t.Branch, "sha": t.HeadSHA}})

	number, url := 0, t.PRURL
	if t.PRNumber != nil {
		number = *t.PRNumber
	} else {
		title := strings.NewReplacer("{key}", t.Key, "{title}", t.Title).Replace(s.Git.PRTitle)
		body := prBody(ctx, o.store, t)
		if len(drift) > 0 {
			body += fmt.Sprintf("\n\n> **Needs a rebase:** %s changed the same lines since this branch was cut: %s.", repo.DefaultBranch, strings.Join(drift, ", "))
		}
		if number, url, err = o.host.OpenPR(ctx, repo, PR{Branch: t.Branch, Title: title, Body: body, Draft: s.Git.Draft}); err != nil {
			return fmt.Errorf("open pull request: %w", err)
		}
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventPROpened,
			Message: url, Data: map[string]any{"number": number, "url": url}})
		o.assign(ctx, repo, t, run, number)
	}
	o.trackerComment(ctx, t, CommentPR, "agnts opened a pull request: "+url)
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageCode); err == nil {
		var sum Summary
		if json.Unmarshal(r.Summary, &sum) == nil && sum.Summary != "" {
			o.trackerComment(ctx, t, CommentSummary, "What changed: "+sum.Summary)
		}
	}
	o.trackerMove(ctx, t, TrackerInReview)
	return o.transition(ctx, &t, run, domain.StateDone, "pull request "+url, func(x *domain.Ticket) {
		x.PRNumber, x.PRURL = &number, url
		if o.learnQueued(s, *x) {
			x.LearnState = domain.LearnPending
		}
	})
}

// assign gives the new pull request its assignees. The pull request already
// exists, so a failure is a warning, not a failed push.
func (o *Orchestrator) assign(ctx context.Context, repo domain.Repository, t domain.Ticket, run *domain.Run, number int) {
	a, ok := o.host.(Assigner)
	if !ok || len(t.Assignees) == 0 {
		return
	}
	who := strings.Join(t.Assignees, ", ")
	if err := a.Assign(ctx, repo, number, t.Assignees); err != nil {
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventPROpened, Level: domain.LevelWarn,
			Message: "could not assign the pull request to " + who + ": " + err.Error()})
		return
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "push", Type: domain.EventPROpened,
		Message: "assigned to " + who, Data: map[string]any{"assignees": t.Assignees}})
}

// The tracker only hears about tickets that came from it.
func (o *Orchestrator) trackerComment(ctx context.Context, t domain.Ticket, kind CommentKind, text string) {
	if o.tracker == nil || t.Source != domain.SourceJira {
		return
	}
	posted, err := o.tracker.Comment(ctx, t.Key, kind, text)
	if err != nil {
		o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventTrackerComment, Level: domain.LevelWarn, Message: "could not comment on the issue: " + err.Error()})
		return
	}
	if posted {
		o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventTrackerComment, Message: truncate(text, 500)})
	}
}

func (o *Orchestrator) trackerMove(ctx context.Context, t domain.Ticket, s TrackerStatus) {
	if o.tracker == nil || t.Source != domain.SourceJira {
		return
	}
	if err := o.tracker.MoveTo(ctx, t.Key, s); err != nil {
		o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventTrackerComment, Level: domain.LevelWarn, Message: fmt.Sprintf("could not move issue to %s: %v", s, err)})
	}
}

func analysisComment(a Analysis, withQuestions bool) string {
	var b strings.Builder
	b.WriteString("agnts analysed this ticket.\n\n")
	b.WriteString(a.Summary)
	if len(a.Plan) > 0 {
		b.WriteString("\n\nPlan:\n")
		for i, p := range a.Plan {
			fmt.Fprintf(&b, "%d. %s\n", i+1, p)
		}
	}
	if withQuestions {
		b.WriteString("\nQuestions (answer them in agnts):\n")
		for i, q := range a.Questions {
			fmt.Fprintf(&b, "%d. %s", i+1, q.Text)
			if len(q.Options) > 0 {
				fmt.Fprintf(&b, " [%s]", strings.Join(q.Options, " / "))
			}
			b.WriteString("\n")
		}
	}
	return b.String()
}

func commitMessage(t domain.Ticket, g domain.GitSettings) string {
	msg := fmt.Sprintf("%s: %s", t.Key, t.Title)
	if t.Revision > 0 {
		msg += fmt.Sprintf(" (revision %d)", t.Revision)
	}
	if g.CoAuthor {
		msg += "\n\nCo-authored-by: agnts <agnts@users.noreply.github.com>"
	}
	return msg
}

func prBody(ctx context.Context, store Store, t domain.Ticket) string {
	var b strings.Builder
	if r, err := store.LatestResult(ctx, t.ID, domain.StageCode); err == nil {
		var s Summary
		if json.Unmarshal(r.Summary, &s) == nil && s.Summary != "" {
			b.WriteString(s.Summary + "\n")
			for _, n := range s.Notes {
				b.WriteString("\n- " + n)
			}
			b.WriteString("\n\n")
		}
	}
	fmt.Fprintf(&b, "Ticket: %s\n\nWritten by agnts with Claude Code and reviewed before push.", t.Key)
	return b.String()
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}
