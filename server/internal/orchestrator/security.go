package orchestrator

import (
	"archive/tar"
	"bytes"
	"cmp"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"slices"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/security"
)

// Security testing (plans/Security plan.md): a repository scan runs the
// pinned scanners (agnts-sec) in a run container, then the agent triages
// their hits, audits what they miss and rechecks the findings agnts
// already has. agnts fingerprints and reconciles the result
// (domain.ReconcileSecurity). Fix this turns findings into a SEC ticket;
// when it merges, a verify scan checks them.

// Where a security scan's files are in its run container.
const (
	SecOutDir      = "/agnts/out/sec"
	SecHitsPath    = ContextDir + "/hits.json"
	SecInputPath   = ContextDir + "/security.json"
	SecExcludePath = ContextDir + "/sec-exclude.txt"
	SecurityPath   = "/agnts/out/security.json"
)

// Limits of security runs: the same for every agent.
const (
	securityMaxTurns       = 60
	securityTimeoutMin     = 30
	securityVerifyMaxTurns = 10
	// securityStaticTimeout covers the four scanners (each has its own cap).
	securityStaticTimeout = 25 * time.Minute
	// secDBEvery is how often the vulnerability databases are refreshed.
	secDBEvery = 24 * time.Hour
	// SecDBHost serves the osv databases; only the updater's container may
	// reach it.
	SecDBHost = "osv-vulnerabilities.storage.googleapis.com"
)

// SecurityStore keeps security scans and findings (postgres.Security).
type SecurityStore interface {
	CreateSecurityScan(ctx context.Context, s domain.SecurityScan) (domain.SecurityScan, bool, error)
	SecurityScan(ctx context.Context, id int64) (domain.SecurityScan, error)
	SecurityScans(ctx context.Context, repoID int64, limit int) ([]domain.SecurityScan, error)
	LastFullScan(ctx context.Context, repoID int64) (domain.SecurityScan, error)
	ClaimSecurityScan(ctx context.Context) (domain.SecurityScan, bool, error)
	PendingSecurityWorkspaces(ctx context.Context) ([]int64, error)
	RecoverSecurityScans(ctx context.Context) (int, error)
	RequeueSecurityScan(ctx context.Context, id int64) error
	CancelSecurityScan(ctx context.Context, id int64) (domain.SecurityScan, error)
	FinishSecurityScan(ctx context.Context, s domain.SecurityScan,
		apply func([]domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts),
		ev func(domain.SecurityScan) *domain.Event) (domain.SecurityScan, error)
	SecurityFindings(ctx context.Context, flt domain.SecFindingFilter) ([]domain.SecurityFinding, error)
	SecurityFinding(ctx context.Context, id int64) (domain.SecurityFinding, error)
	FindingsByTicket(ctx context.Context, key string) ([]domain.SecurityFinding, error)
	FixingTickets(ctx context.Context) ([]domain.TicketRef, error)
	UpdateSecurityFindings(ctx context.Context, ids []int64, mut func(*domain.SecurityFinding) error,
		ev func([]domain.SecurityFinding) *domain.Event) ([]domain.SecurityFinding, error)
	SetSecuritySettings(ctx context.Context, repoID int64, set domain.SecuritySettings, next *time.Time) error
	DueSecurityScans(ctx context.Context, now time.Time) ([]DueSecurityScan, error)
	AgentScansSince(ctx context.Context, t time.Time) (int, error)
}

// DueSecurityScan is a repository whose scheduled scan is due.
type DueSecurityScan struct {
	RepoID      int64
	WorkspaceID int64
	Settings    domain.SecuritySettings
}

// errUnchanged ends a scheduled scan of a commit that was already scanned
// with the same vulnerability databases: nothing can have changed.
var errUnchanged = errors.New("unchanged since the last scan")

// SetSecuritySettings saves a repository's security settings and
// schedules its next scan.
func (o *Orchestrator) SetSecuritySettings(ctx context.Context, repoID int64, set domain.SecuritySettings, origin domain.Origin) (domain.SecuritySettings, error) {
	if err := o.securityReady(); err != nil {
		return set, err
	}
	if err := set.Normalize(); err != nil {
		return set, invalid("%s", err)
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return set, err
	}
	if err := o.security.SetSecuritySettings(ctx, repoID, set, set.NextScan(repoID, time.Now())); err != nil {
		return set, err
	}
	sched := cmp.Or(set.Schedule, "off")
	o.event(ctx, securityEvent(origin, domain.LevelInfo, fmt.Sprintf("%s: security settings changed (schedule %s, %d exclusions)", repo.Name, sched, len(set.Exclude)),
		map[string]any{"repo": repoID, "schedule": sched}))
	return set, nil
}

// SecurityTick is security testing's minute work: follow fix tickets and
// queue the scheduled scans that are due.
func (o *Orchestrator) SecurityTick(ctx context.Context) {
	o.SyncSecurityTickets(ctx)
	o.enqueueDueScans(ctx)
}

// enqueueDueScans queues the scheduled scans that are due.
func (o *Orchestrator) enqueueDueScans(ctx context.Context) {
	if o.security == nil {
		return
	}
	due, err := o.security.DueSecurityScans(domain.System(ctx), time.Now())
	if err != nil {
		if ctx.Err() == nil {
			o.log.Warn("read due security scans", "err", err)
		}
		return
	}
	for _, d := range due {
		wctx := domain.WithWorkspace(ctx, d.WorkspaceID)
		_, err := o.security.LastFullScan(wctx, d.RepoID)
		first := errors.Is(err, domain.ErrNotFound)
		if _, _, err := o.security.CreateSecurityScan(wctx, domain.SecurityScan{RepoID: d.RepoID, Trigger: domain.SecSchedule,
			Scope: domain.SecScope{FullHistory: first}}); err != nil {
			o.log.Warn("queue scheduled security scan", "repo", d.RepoID, "err", err)
		}
	}
	if len(due) > 0 {
		o.Wake()
	}
}

func (o *Orchestrator) securityReady() error {
	if o.security == nil {
		return invalid("security testing is not available on this server")
	}
	return nil
}

func securityEvent(origin domain.Origin, level domain.Level, msg string, data map[string]any) domain.Event {
	return domain.Event{Type: domain.EventSecurity, Step: "security", Origin: origin, Level: level, Message: msg, Data: data}
}

// ScanRepository queues a scan of a repository's default branch. One
// already queued or running is returned as it is (queued false). A
// repository's first scan reads its whole git history for secrets.
func (o *Orchestrator) ScanRepository(ctx context.Context, repoID int64, origin domain.Origin, by *int64) (domain.SecurityScan, bool, error) {
	if err := o.securityReady(); err != nil {
		return domain.SecurityScan{}, false, err
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return domain.SecurityScan{}, false, err
	}
	if repo.ArchivedAt != nil {
		return domain.SecurityScan{}, false, invalid("%s is archived", repo.Name)
	}
	_, err = o.security.LastFullScan(ctx, repoID)
	first := errors.Is(err, domain.ErrNotFound)
	if err != nil && !first {
		return domain.SecurityScan{}, false, err
	}
	s, busy, err := o.security.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repoID, Trigger: domain.SecManual,
		Scope: domain.SecScope{FullHistory: first}, CreatedBy: by})
	if err != nil {
		return s, false, err
	}
	if !busy {
		o.event(ctx, securityEvent(origin, domain.LevelInfo, fmt.Sprintf("security scan of %s queued", repo.Name),
			map[string]any{"repo": repoID, "scan": s.ID, "status": "queued"}))
		o.Wake()
	}
	return s, !busy, nil
}

// CancelScan stops a queued or running scan; a running one saves
// nothing.
func (o *Orchestrator) CancelScan(ctx context.Context, id int64) (domain.SecurityScan, error) {
	if err := o.securityReady(); err != nil {
		return domain.SecurityScan{}, err
	}
	s, err := o.security.CancelSecurityScan(ctx, id)
	if err == nil {
		o.cancelRun(ctx, secRunKey(s.ID))
	}
	return s, err
}

func secRunKey(id int64) string { return fmt.Sprintf("sec-%d", id) }

// securityPrompt is what the security prompts get.
type securityPrompt struct {
	Verify     bool
	Hits       int
	Known      int
	HitsPath   string
	InputPath  string
	OutPath    string
	Tools      []string // "opengrep: ok, 2 hits"
	History    int
	FullScan   bool
	AppNote    string
	MaxTurns   int
	MaxFinding int
}

// secInput is /agnts/context/security.json: what the agent rechecks.
type secInput struct {
	Repo   string     `json:"repo"`
	Commit string     `json:"commit"`
	Verify bool       `json:"verify"`
	Known  []secKnown `json:"known"`
}

type secKnown struct {
	ID       int64              `json:"findingId"`
	Status   domain.SecStatus   `json:"status"`
	Severity domain.SecSeverity `json:"severity"`
	Title    string             `json:"title"`
	CWE      string             `json:"cwe,omitempty"`
	Location domain.SecLocation `json:"location"`
	Symbol   string             `json:"symbol,omitempty"`
	Source   domain.SecSource   `json:"source"`
	Package  string             `json:"package,omitempty"`
	// Dismissed findings are listed so the agent does not report them as
	// new; it need not recheck them.
	Dismissed string `json:"dismissed,omitempty"`
}

// runSecurityScan runs a claimed scan and saves its result.
func (o *Orchestrator) runSecurityScan(parent context.Context, scan domain.SecurityScan) {
	ctx, cancel := context.WithCancel(domain.WithWorkspace(parent, scan.WorkspaceID))
	rk := runKey(scan.WorkspaceID, secRunKey(scan.ID))
	o.mu.Lock()
	o.cancels[rk] = cancel
	o.mu.Unlock()
	defer func() {
		o.mu.Lock()
		delete(o.cancels, rk)
		o.mu.Unlock()
		cancel()
	}()
	log := o.log.With("repo", scan.RepoName, "scan", scan.ID)
	log.Info("security scan started")
	out, res, err := o.securityScan(ctx, scan)
	out.Ran = res.Ran // what actually ran, even for a failed scan
	if parent.Err() != nil {
		log.Info("security scan interrupted") // RecoverSecurityScans requeues it
		return
	}
	bg := context.WithoutCancel(ctx)
	var stop *stopError
	if errors.As(err, &stop) {
		if rerr := o.security.RequeueSecurityScan(bg, scan.ID); rerr != nil {
			log.Error("requeue security scan", "err", rerr)
		}
		log.Info("security scan waits for usage", "why", stop.reason)
		return
	}
	var apply func([]domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts)
	switch {
	case errors.Is(err, errUnchanged):
		out.Status, out.Summary, err = domain.ScanDone, "Nothing changed since the last scan: the same commit and the same vulnerability databases.", nil
	case err != nil:
		out.Status, out.Error = domain.ScanFailed, err.Error()
	default:
		out.Status = domain.ScanDone
		apply = func(existing []domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts) {
			cands, rejected := domain.SecurityCandidates(scan.RepoID, res)
			for i := range cands {
				cands[i].RepoID, cands[i].WorkspaceID = scan.RepoID, scan.WorkspaceID
			}
			save, counts := domain.ReconcileSecurity(existing, cands, res, scan.ID, time.Now())
			counts.Rejected = len(rejected)
			out.Rejected = rejected
			return save, counts
		}
	}
	ev := func(x domain.SecurityScan) *domain.Event { return scanEvent(x) }
	if out.Status == domain.ScanDone && apply == nil {
		ev = nil // an unchanged scheduled scan says nothing
	}
	saved, serr := o.security.FinishSecurityScan(bg, out, apply, ev)
	switch {
	case errors.Is(serr, domain.ErrScanStale):
		log.Info("security scan was cancelled; result dropped")
	case serr != nil:
		log.Error("save security scan", "err", serr)
	case err != nil:
		log.Warn("security scan failed", "err", err)
	default:
		log.Info("security scan finished", "new", saved.Counts.New, "fixed", saved.Counts.Fixed, "reopened", saved.Counts.Reopened)
	}
}

// scanEvent is the event of a finished scan: it notifies when something
// new and at least high, or something reopened, came up.
func scanEvent(s domain.SecurityScan) *domain.Event {
	data := map[string]any{"repo": s.RepoID, "name": s.RepoName, "scan": s.ID, "status": string(s.Status), "trigger": string(s.Trigger),
		"new": s.Counts.New, "fixed": s.Counts.Fixed, "reopened": s.Counts.Reopened}
	if s.Status == domain.ScanFailed {
		return &domain.Event{Type: domain.EventSecurity, Step: "security", Origin: domain.OriginSystem, Level: domain.LevelWarn,
			Message: fmt.Sprintf("security scan of %s failed: %s", s.RepoName, truncate(s.Error, 300)), Data: data}
	}
	var parts []string
	if n := s.Counts.New; n > 0 {
		parts = append(parts, fmt.Sprintf("%d new", n))
	}
	if n := s.Counts.Reopened; n > 0 {
		parts = append(parts, fmt.Sprintf("%d reopened", n))
	}
	if n := s.Counts.Fixed; n > 0 {
		parts = append(parts, fmt.Sprintf("%d fixed", n))
	}
	what := "nothing changed"
	if len(parts) > 0 {
		what = strings.Join(parts, " · ")
	}
	open := 0
	for _, n := range s.Counts.Open {
		open += n
	}
	verb := "security scan"
	if s.Trigger == domain.SecVerify {
		verb = "verify scan"
	}
	msg := fmt.Sprintf("%s of %s done: %s; %d open", verb, s.RepoName, what, open)
	if s.Counts.Notify > 0 || s.Counts.Reopened > 0 {
		data["notify"] = true
	}
	return &domain.Event{Type: domain.EventSecurity, Step: "security", Origin: domain.OriginSystem, Level: domain.LevelInfo, Message: msg, Data: data}
}

// securityScan does a scan's work. It returns the scan as it should be
// saved and what it saw.
func (o *Orchestrator) securityScan(ctx context.Context, scan domain.SecurityScan) (domain.SecurityScan, domain.SecScanResult, error) {
	var res domain.SecScanResult
	res.Scope = scan.Scope
	s, err := o.settings.Get(ctx)
	if err != nil {
		return scan, res, err
	}
	repo, err := o.store.RepositoryByID(ctx, scan.RepoID)
	if err != nil {
		return scan, res, err
	}
	if err := o.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
		return scan, res, fmt.Errorf("prepare repository: %w", err)
	}
	rc, err := o.git.Archive(ctx, repo, repo.DefaultBranch)
	if err != nil {
		return scan, res, fmt.Errorf("archive repository: %w", err)
	}
	defer func() { _ = rc.Close() }()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: secRunKey(scan.ID), Image: o.cfg.Image, Repo: rc, SecDB: SecDBRead})
	if err != nil {
		return scan, res, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "scan", scan.ID, "err", err)
		}
	}()
	if r, err := ws.Exec(ctx, "git rev-parse HEAD", time.Minute); err == nil && r.ExitCode == 0 {
		if sha := strings.TrimSpace(r.Output); len(sha) == 40 {
			scan.Commit = sha
		}
	}
	if r, err := ws.Exec(ctx, "cat /opt/secdb/versions.json 2>/dev/null", time.Minute); err == nil && r.ExitCode == 0 {
		var v map[string]any
		if json.Unmarshal([]byte(strings.TrimSpace(r.Output)), &v) == nil {
			scan.DBVersions = map[string]string{}
			for k, x := range v {
				scan.DBVersions[k] = fmt.Sprint(x)
			}
		}
	}

	// A scheduled scan of what was already scanned changes nothing.
	if scan.Trigger == domain.SecSchedule && scan.Commit != "" {
		if last, err := o.security.LastFullScan(ctx, scan.RepoID); err == nil && last.Commit == scan.Commit && maps.Equal(last.DBVersions, scan.DBVersions) {
			return scan, res, errUnchanged
		}
	}
	res.MinNotify = repo.Harness.Security.MinNotify

	// The static sweep, before the agent.
	exclude := slices.Concat(domain.SecDefaultExclude, repo.Harness.Security.Exclude)
	if err := ws.WriteFile(ctx, SecExcludePath, []byte(strings.Join(exclude, "\n")+"\n")); err != nil {
		return scan, res, fmt.Errorf("write exclusions: %w", err)
	}
	history := domain.SecHistoryCommits
	if scan.Scope.FullHistory {
		history = 0
	}
	sweep, err := ws.Exec(ctx, fmt.Sprintf("AGNTS_SEC_QUIET=1 agnts-sec static --history %d", history), securityStaticTimeout)
	if err != nil {
		return scan, res, fmt.Errorf("run the scanners: %w", err)
	}
	ranRaw, err := ws.ReadFile(ctx, SecOutDir+"/ran.json")
	if err != nil {
		return scan, res, fmt.Errorf("the scanners did not finish (exit %d): %s", sweep.ExitCode, truncate(sweep.Output, 800))
	}
	ran, err := parseRan(ranRaw)
	if err != nil {
		return scan, res, err
	}
	ran.Excluded = exclude
	raw := security.Raw{}
	for _, f := range security.Files {
		if b, err := ws.ReadFile(ctx, SecOutDir+"/raw/"+f); err == nil {
			raw[f] = b
		}
	}
	// gitleaks's raw report holds the secrets themselves: nothing after
	// this point (the agent included) needs it.
	_, _ = ws.Exec(ctx, "rm -f "+SecOutDir+"/raw/gitleaks.json "+SecOutDir+"/raw/gitleaks-history.json", time.Minute)
	hits, perrs := security.Hits(raw, exclude)
	for tool, perr := range perrs {
		t := ran.Tools[tool]
		t.Status, t.Error = "failed", perr.Error()
		ran.Tools[tool] = t
	}
	for _, h := range hits {
		t := ran.Tools[h.Tool]
		t.Hits++
		ran.Tools[h.Tool] = t
	}
	res.Hits, res.Ran = hits, ran

	// Symbols come from the files themselves, read once each.
	files := map[string][]byte{}
	res.Symbol = func(file string, line int) string {
		src, ok := files[file]
		if !ok {
			src, _ = ws.ReadFile(ctx, "/workspace/"+file)
			if len(src) > 2<<20 {
				src = nil
			}
			files[file] = src
		}
		return security.Symbol(file, src, line)
	}

	if cur, err := o.security.SecurityScan(ctx, scan.ID); err == nil && cur.Status != domain.ScanRunning {
		return scan, res, domain.ErrScanStale
	}

	// What the agent rechecks: the active findings (a verify scan: its
	// own), and the dismissed ones so it does not report them again.
	flt := domain.SecFindingFilter{RepoID: scan.RepoID}
	if scan.Scope.Verify() {
		flt = domain.SecFindingFilter{IDs: scan.Scope.FindingIDs}
	}
	stored, err := o.security.SecurityFindings(ctx, flt)
	if err != nil {
		return scan, res, err
	}
	in := secInput{Repo: repo.Name, Commit: scan.Commit, Verify: scan.Scope.Verify(), Known: []secKnown{}}
	needAgent := !scan.Scope.Verify()
	for _, f := range stored {
		if !f.Status.Active() && f.Status != domain.SecDismissed {
			continue
		}
		k := secKnown{ID: f.ID, Status: f.Status, Severity: f.Severity, Title: f.Data.Title, CWE: f.Data.CWE, Location: f.Data.Location,
			Symbol: f.Symbol, Source: f.Source, Package: f.Data.Package}
		if f.Status == domain.SecDismissed {
			if scan.Scope.Verify() {
				continue
			}
			k.Dismissed = cmp.Or(f.DismissReason, "dismissed")
		}
		if f.Source == domain.SecFromAgent {
			needAgent = true // only the agent can recheck its own findings
		}
		in.Known = append(in.Known, k)
	}
	// Scheduled scans share a daily budget of agent runs; past it they
	// run the scanners only.
	if needAgent && scan.Trigger == domain.SecSchedule && s.Security.DailyBudget > 0 {
		if n, err := o.security.AgentScansSince(ctx, time.Now().UTC().Truncate(24*time.Hour)); err == nil && n >= s.Security.DailyBudget {
			needAgent = false
			scan.Summary = fmt.Sprintf("The daily budget of %d scheduled scans with %s is used up: only the scanners ran.", s.Security.DailyBudget, domain.AgentName(""))
		}
	}
	if !needAgent {
		ran.Agent = domain.SecAgentSkipped
		res.Ran = ran
		return scan, res, nil
	}

	hb, _ := json.MarshalIndent(hits, "", "  ")
	if hits == nil {
		hb = []byte("[]")
	}
	if err := ws.WriteFile(ctx, SecHitsPath, hb); err != nil {
		return scan, res, fmt.Errorf("write hits: %w", err)
	}
	ib, _ := json.MarshalIndent(in, "", "  ")
	if err := ws.WriteFile(ctx, SecInputPath, ib); err != nil {
		return scan, res, fmt.Errorf("write known findings: %w", err)
	}

	turns := min(s.MaxTurns, securityMaxTurns)
	if scan.Scope.Verify() {
		turns = min(s.MaxTurns, securityVerifyMaxTurns)
	}
	if turns <= 0 {
		turns = securityMaxTurns
	}
	d := promptData{Repo: repo, Security: &securityPrompt{Verify: scan.Scope.Verify(), Hits: len(hits), Known: len(in.Known),
		HitsPath: SecHitsPath, InputPath: SecInputPath, OutPath: SecurityPath, History: ran.History, FullScan: !scan.Scope.Verify(),
		MaxTurns: turns, MaxFinding: domain.SecMaxFindings}}
	for _, t := range domain.SecTools {
		if r, ok := ran.Tools[t]; ok {
			line := fmt.Sprintf("%s: %s, %d hits", t, r.Status, r.Hits)
			if r.Error != "" && r.Status != "ok" {
				line += " (" + truncate(r.Error, 160) + ")"
			}
			d.Security.Tools = append(d.Security.Tools, line)
		}
	}
	if d.Rules, err = o.teamRules(ctx, []int64{repo.ID}); err != nil {
		return scan, res, err
	}
	prompt, err := render("security", d)
	if err != nil {
		return scan, res, err
	}
	model := s.ModelFor(domain.Ticket{}, domain.ModelSecurity)
	result, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeSecurity, WorkspaceID: repo.WorkspaceID, Subject: repo.Name,
		ModelStage: domain.ModelSecurity}, ai.Request{
		Prompt:   prompt,
		Model:    model,
		MaxTurns: turns,
		Timeout:  time.Duration(min(max(s.TimeoutMin, 1), securityTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, nil)
	scan.Provider = domain.ProviderOf(cmp.Or(result.Model, model))
	var hold *ai.Hold
	switch {
	case errors.As(err, &hold):
		return scan, res, &stopError{hold.Why}
	case err != nil && ctx.Err() != nil:
		return scan, res, ctx.Err()
	case err != nil && strings.Contains(err.Error(), "timed out"):
		ran.Agent = domain.SecAgentLimit
	case err != nil:
		ran.Agent = domain.SecAgentFailed
		scan.Summary = "The agent failed: " + truncate(err.Error(), 300) + ". Tool results are kept."
	case result.RateLimited:
		return scan, res, &stopError{"rate limited"}
	case result.IsError && result.Subtype == "error_max_turns":
		ran.Agent = domain.SecAgentLimit
	case result.IsError:
		ran.Agent = domain.SecAgentFailed
		scan.Summary = fmt.Sprintf("The agent ended with %s. Tool results are kept.", result.Subtype)
	default:
		ran.Agent = domain.SecAgentDone
	}
	// A manifest written before the limit still counts for what it says;
	// only "gone" needs a finished run (domain closes).
	if b, rerr := ws.ReadFile(ctx, SecurityPath); rerr == nil {
		m, perr := domain.ParseSecurityManifest(b)
		if perr != nil {
			if ran.Agent == domain.SecAgentDone {
				ran.Agent = domain.SecAgentFailed
			}
			scan.Summary = "The agent's security.json was not valid: " + truncate(perr.Error(), 200)
		} else {
			ids := map[string]bool{}
			for _, h := range hits {
				ids[h.ID] = true
			}
			known := map[int64]bool{}
			for _, k := range in.Known {
				if k.Dismissed == "" {
					known[k.ID] = true
				}
			}
			m.Normalize(ids, known)
			res.Manifest = &m
			scan.Summary = cmp.Or(m.Summary, scan.Summary)
		}
	} else if ran.Agent == domain.SecAgentDone {
		ran.Agent = domain.SecAgentFailed
		scan.Summary = "The agent did not write security.json. Tool results are kept."
	}
	res.Ran = ran
	return scan, res, nil
}

func parseRan(b []byte) (domain.SecRan, error) {
	var r struct {
		History int                          `json:"history"`
		Commits int                          `json:"commits"`
		Tools   map[string]domain.SecToolRun `json:"tools"`
		Paths   []string                     `json:"paths"`
	}
	if err := json.Unmarshal(b, &r); err != nil {
		return domain.SecRan{}, fmt.Errorf("agnts-sec wrote an unreadable ran.json: %w", err)
	}
	if r.Tools == nil {
		r.Tools = map[string]domain.SecToolRun{}
	}
	return domain.SecRan{Tools: r.Tools, Paths: r.Paths, History: r.History, Commits: r.Commits}, nil
}

// SecurityFixInput is findings to fix in one ticket.
type SecurityFixInput struct {
	FindingIDs []int64
	// Hold creates the ticket without starting it.
	Hold bool
}

// CreateSecurityTicket opens one fix ticket for findings of one
// repository (Fix this, Fix together) and links them to it. The ticket
// goes through the usual flow: nothing is pushed before approval.
func (o *Orchestrator) CreateSecurityTicket(ctx context.Context, in SecurityFixInput, origin domain.Origin) (domain.Ticket, error) {
	if err := o.securityReady(); err != nil {
		return domain.Ticket{}, err
	}
	ids := slices.Compact(slices.Sorted(slices.Values(in.FindingIDs)))
	if len(ids) == 0 {
		return domain.Ticket{}, invalid("pick at least one finding")
	}
	if len(ids) > 20 {
		return domain.Ticket{}, invalid("a fix ticket takes at most 20 findings")
	}
	fs, err := o.security.SecurityFindings(ctx, domain.SecFindingFilter{IDs: ids})
	if err != nil {
		return domain.Ticket{}, err
	}
	if len(fs) != len(ids) {
		return domain.Ticket{}, domain.ErrNotFound
	}
	repoID := fs[0].RepoID
	for _, f := range fs {
		if f.RepoID != repoID {
			return domain.Ticket{}, invalid("findings from several repositories go into separate tickets")
		}
		if f.Status == domain.SecFixed || f.Status == domain.SecDismissed {
			return domain.Ticket{}, invalid("%q is %s", f.Data.Title, f.Status)
		}
		if f.TicketKey != "" && f.Status == domain.SecFixing {
			if t, err := o.store.TicketByKey(ctx, f.TicketKey); err == nil && !t.State.Terminal() {
				return domain.Ticket{}, invalid("%s already works on %q", t.Key, f.Data.Title)
			}
		}
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return domain.Ticket{}, err
	}
	if repo.ArchivedAt != nil {
		return domain.Ticket{}, invalid("%s is archived", repo.Name)
	}
	title, desc := domain.SecurityTicketText(fs)
	t, err := o.createTask(ctx, domain.Ticket{
		Source: domain.SourceSecurity, RepoID: &repo.ID, Title: title, Description: desc,
		Priority: fs[0].Severity.Priority(), State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr",
		AskFirst: false, Kind: domain.KindCode, KindAuto: false, Held: in.Hold,
	}, domain.SecurityPrefix, nil, origin)
	if err != nil {
		return t, err
	}
	_, err = o.security.UpdateSecurityFindings(ctx, ids, func(f *domain.SecurityFinding) error {
		f.Status, f.TicketKey = domain.SecFixing, t.Key
		return nil
	}, func(fs []domain.SecurityFinding) *domain.Event {
		e := securityEvent(origin, domain.LevelInfo, fmt.Sprintf("%s opened to fix %d security finding(s) in %s", t.Key, len(fs), repo.Name),
			map[string]any{"repo": repo.ID, "findings": ids, "ticket": t.Key})
		e.TicketKey = t.Key
		return &e
	})
	return t, err
}

// DismissFindings dismisses findings with a reason (false_positive,
// accepted_risk, wont_fix): they stay dismissed while their fingerprint
// matches, and scans no longer report them.
func (o *Orchestrator) DismissFindings(ctx context.Context, ids []int64, reason, note string, by *int64, origin domain.Origin) ([]domain.SecurityFinding, error) {
	if err := o.securityReady(); err != nil {
		return nil, err
	}
	if !domain.ValidDismissReason(reason) {
		return nil, invalid("say why: false_positive, accepted_risk or wont_fix")
	}
	if len(ids) == 0 {
		return nil, invalid("pick at least one finding")
	}
	note = strings.TrimSpace(note)
	if r := []rune(note); len(r) > 1000 {
		note = string(r[:1000])
	}
	return o.security.UpdateSecurityFindings(ctx, ids, func(f *domain.SecurityFinding) error {
		f.Status, f.DismissReason, f.DismissNote, f.DismissedBy = domain.SecDismissed, reason, note, by
		return nil
	}, func(fs []domain.SecurityFinding) *domain.Event {
		e := securityEvent(origin, domain.LevelInfo, fmt.Sprintf("dismissed %d security finding(s) in %s: %s", len(fs), fs[0].RepoName,
			strings.ReplaceAll(reason, "_", " ")), map[string]any{"findings": ids, "reason": reason})
		return &e
	})
}

// ReopenFinding opens a dismissed or fixed finding again.
func (o *Orchestrator) ReopenFinding(ctx context.Context, id int64, origin domain.Origin) (domain.SecurityFinding, error) {
	if err := o.securityReady(); err != nil {
		return domain.SecurityFinding{}, err
	}
	fs, err := o.security.UpdateSecurityFindings(ctx, []int64{id}, func(f *domain.SecurityFinding) error {
		if f.Status.Active() {
			return invalid("the finding is already %s", f.Status)
		}
		f.Status, f.DismissReason, f.DismissNote, f.DismissedBy = domain.SecOpen, "", "", nil
		return nil
	}, func(fs []domain.SecurityFinding) *domain.Event {
		e := securityEvent(origin, domain.LevelInfo, fmt.Sprintf("reopened security finding %q in %s", fs[0].Data.Title, fs[0].RepoName),
			map[string]any{"findings": []int64{id}})
		return &e
	})
	if err != nil {
		return domain.SecurityFinding{}, err
	}
	return fs[0], nil
}

// SyncSecurityTickets follows the fix tickets of findings: merged →
// verifying, and a verify scan of them; rejected or deleted → open again.
func (o *Orchestrator) SyncSecurityTickets(ctx context.Context) {
	if o.security == nil {
		return
	}
	refs, err := o.security.FixingTickets(domain.System(ctx))
	if err != nil {
		if ctx.Err() == nil {
			o.log.Warn("read security fix tickets", "err", err)
		}
		return
	}
	for _, ref := range refs {
		wctx := domain.WithWorkspace(ctx, ref.WorkspaceID)
		t, err := o.store.TicketByKey(wctx, ref.Key)
		gone := errors.Is(err, domain.ErrNotFound)
		if err != nil && !gone {
			continue
		}
		var to domain.SecStatus
		var note string
		switch {
		case gone || t.State == domain.StateRejected:
			to, note = domain.SecOpen, ref.Key+" was rejected or deleted"
		case t.MergedAt != nil:
			to = domain.SecVerifying
		case t.State == domain.StateDone && t.Kind.Report():
			to, note = domain.SecOpen, "the report is on "+t.Key
		default:
			continue
		}
		fs, err := o.security.FindingsByTicket(wctx, ref.Key)
		if err != nil || len(fs) == 0 {
			continue
		}
		var ids []int64
		for _, f := range fs {
			if f.Status == domain.SecFixing {
				ids = append(ids, f.ID)
			}
		}
		if len(ids) == 0 {
			continue
		}
		if _, err := o.security.UpdateSecurityFindings(wctx, ids, func(f *domain.SecurityFinding) error {
			f.Status = to
			if note != "" {
				f.Data.Note = note
			}
			if gone {
				f.TicketKey = ""
			}
			return nil
		}, nil); err != nil {
			o.log.Warn("follow security fix ticket", "ticket", ref.Key, "err", err)
			continue
		}
		if to != domain.SecVerifying {
			continue
		}
		scan, _, err := o.security.CreateSecurityScan(wctx, domain.SecurityScan{RepoID: fs[0].RepoID, Trigger: domain.SecVerify,
			Scope: domain.SecScope{FindingIDs: ids}})
		if err != nil {
			o.log.Warn("queue verify scan", "ticket", ref.Key, "err", err)
			continue
		}
		o.event(wctx, domain.Event{TicketKey: ref.Key, Type: domain.EventSecurity, Step: "security", Origin: domain.OriginSystem,
			Message: fmt.Sprintf("%s merged: a verify scan checks its %d security finding(s)", ref.Key, len(ids)),
			Data:    map[string]any{"scan": scan.ID, "findings": ids}})
		o.Wake()
	}
}

// RefreshSecDB downloads the vulnerability databases into the shared
// volume, in a container of their own that alone may reach the osv
// host. Scans read the volume read-only.
func (o *Orchestrator) RefreshSecDB(ctx context.Context) error {
	ctx = domain.System(ctx)
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: "secdb", Image: o.cfg.Image, Repo: bytes.NewReader(emptyTar()),
		SecDB: SecDBWrite, Grants: []Grant{{Host: SecDBHost, Port: 443}}})
	if err != nil {
		return fmt.Errorf("start the updater: %w", err)
	}
	defer func() { _ = ws.Close(context.WithoutCancel(ctx)) }()
	r, err := ws.Exec(ctx, "agnts-sec update /opt/secdb", time.Hour)
	if err != nil {
		return err
	}
	if r.ExitCode != 0 {
		return fmt.Errorf("agnts-sec update: exit %d: %s", r.ExitCode, truncate(r.Output, 500))
	}
	o.log.Info("vulnerability databases refreshed", "versions", truncate(strings.TrimSpace(r.Output), 300))
	return nil
}

func emptyTar() []byte {
	var b bytes.Buffer
	_ = tar.NewWriter(&b).Close()
	return b.Bytes()
}
