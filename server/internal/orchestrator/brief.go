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

// Where a survey writes the brief, and where runs find the approved one.
const (
	BriefOutPath = "/agnts/out/brief.md"
	// ArchOutPath is where a survey writes the architecture, and ArchPath
	// where runs (and the next survey) read the approved one.
	ArchOutPath = "/agnts/out/architecture.json"
	ArchPath    = ContextDir + "/architecture.json"
	ContextDir  = "/agnts/context"
	BriefPath   = ContextDir + "/brief.md"
	// BusinessPath holds the business context notes runs read.
	BusinessPath = ContextDir + "/business.md"
	// PrecedentsPath holds the similar tickets done before.
	PrecedentsPath = ContextDir + "/precedents.md"
)

// Limits of a survey: it reads a whole repository, so it gets more turns
// than a rule review, but it changes nothing.
const (
	surveyMaxTurns   = 80
	surveyTimeoutMin = 30
)

// Briefs stores what agnts knows about each repository, and the queue of
// repositories waiting for a survey.
type Briefs interface {
	// Brief returns a repository's brief, or domain.ErrNotFound.
	Brief(ctx context.Context, repoID int64) (domain.RepoBrief, error)
	// UpdateBrief applies mut to the locked brief of repoID (created empty
	// when missing) and appends the event ev returns (nil for none), in one
	// transaction.
	UpdateBrief(ctx context.Context, repoID int64, mut func(*domain.RepoBrief) error, ev func(domain.RepoBrief) *domain.Event) (domain.RepoBrief, error)
	// ClaimBrief moves the oldest pending brief to surveying; ok is false
	// when none is waiting.
	ClaimBrief(ctx context.Context) (b domain.RepoBrief, ok bool, err error)
	// PendingBriefWorkspaces returns the workspaces with briefs waiting.
	PendingBriefWorkspaces(ctx context.Context) ([]int64, error)
	// RecoverBriefs requeues surveys a crash left running.
	RecoverBriefs(ctx context.Context) (int, error)
}

// ContextFile is a file of knowledge a run gets under ContextDir, named in
// its prompt.
type ContextFile struct {
	Path string
	What string // what it holds, for the prompt
}

func (o *Orchestrator) briefsReady() error {
	if o.briefs == nil {
		return invalid("repository briefs are not available on this server")
	}
	return nil
}

func briefEvent(b domain.RepoBrief, origin domain.Origin, level domain.Level, msg string) *domain.Event {
	return &domain.Event{Type: domain.EventBrief, Step: "brief", Origin: origin, Level: level, Message: msg,
		Data: map[string]any{"repo": b.RepoID, "name": b.RepoName, "status": string(b.Status)}}
}

// RepoBrief returns a repository's brief; one never surveyed comes back
// empty and idle.
func (o *Orchestrator) RepoBrief(ctx context.Context, repoID int64) (domain.RepoBrief, error) {
	if err := o.briefsReady(); err != nil {
		return domain.RepoBrief{}, err
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return domain.RepoBrief{}, err
	}
	b, err := o.briefs.Brief(ctx, repoID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.RepoBrief{RepoID: repoID, WorkspaceID: repo.WorkspaceID, RepoName: repo.Name, Status: domain.BriefIdle}, nil
	}
	return b, err
}

// SurveyBrief queues a survey of a repository (an update when it has a
// brief). A survey already queued or running is left alone.
func (o *Orchestrator) SurveyBrief(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error) {
	if err := o.briefsReady(); err != nil {
		return domain.RepoBrief{}, err
	}
	if _, err := o.store.RepositoryByID(ctx, repoID); err != nil {
		return domain.RepoBrief{}, err
	}
	queued := false
	b, err := o.briefs.UpdateBrief(ctx, repoID, func(b *domain.RepoBrief) error {
		if b.Busy() {
			return nil
		}
		b.Status, b.Error, queued = domain.BriefPending, "", true
		return nil
	}, func(b domain.RepoBrief) *domain.Event {
		if !queued {
			return nil
		}
		return briefEvent(b, origin, domain.LevelInfo, fmt.Sprintf("survey of %s queued", b.RepoName))
	})
	if err == nil && queued {
		o.Wake()
	}
	return b, err
}

// ApproveBrief makes the draft the brief runs read.
func (o *Orchestrator) ApproveBrief(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error) {
	if err := o.briefsReady(); err != nil {
		return domain.RepoBrief{}, err
	}
	return o.briefs.UpdateBrief(ctx, repoID, func(b *domain.RepoBrief) error {
		if strings.TrimSpace(b.Draft) == "" {
			return invalid("there is no draft to approve")
		}
		now := time.Now()
		b.Body, b.BodySHA, b.Draft, b.DraftSHA = b.Draft, b.DraftSHA, "", ""
		if b.ArchDraft != nil {
			b.Arch, b.ArchDraft = b.ArchDraft, nil
		}
		b.MergesSince, b.ApprovedAt = 0, &now
		b.Revision++
		return nil
	}, func(b domain.RepoBrief) *domain.Event {
		return briefEvent(b, origin, domain.LevelInfo, fmt.Sprintf("brief of %s approved: new tickets read it", b.RepoName))
	})
}

// SaveBrief replaces the approved brief with text a person wrote; empty
// text removes it, so runs get no brief.
// arch, when given, replaces the approved architecture (empty removes it).
func (o *Orchestrator) SaveBrief(ctx context.Context, repoID int64, text string, arch *string, origin domain.Origin) (domain.RepoBrief, error) {
	if err := o.briefsReady(); err != nil {
		return domain.RepoBrief{}, err
	}
	text, err := domain.CleanBriefText(text)
	if err != nil {
		return domain.RepoBrief{}, invalid("%s", err.Error())
	}
	var a *domain.Architecture
	if arch != nil {
		if a, err = domain.ParseArchitecture(*arch); err != nil {
			return domain.RepoBrief{}, invalid("%s", err.Error())
		}
	}
	return o.briefs.UpdateBrief(ctx, repoID, func(b *domain.RepoBrief) error {
		now := time.Now()
		b.Body, b.ApprovedAt = text, &now
		if arch != nil {
			b.Arch = a
		}
		b.Revision++
		return nil
	}, func(b domain.RepoBrief) *domain.Event {
		msg := fmt.Sprintf("brief of %s edited", b.RepoName)
		if text == "" {
			msg = fmt.Sprintf("brief of %s removed", b.RepoName)
		}
		return briefEvent(b, origin, domain.LevelInfo, msg)
	})
}

// DiscardBriefDraft drops the draft a survey wrote.
func (o *Orchestrator) DiscardBriefDraft(ctx context.Context, repoID int64, origin domain.Origin) (domain.RepoBrief, error) {
	if err := o.briefsReady(); err != nil {
		return domain.RepoBrief{}, err
	}
	return o.briefs.UpdateBrief(ctx, repoID, func(b *domain.RepoBrief) error {
		b.Draft, b.DraftSHA, b.ArchDraft = "", "", nil
		b.Revision++
		return nil
	}, func(b domain.RepoBrief) *domain.Event {
		return briefEvent(b, origin, domain.LevelInfo, fmt.Sprintf("draft brief of %s discarded", b.RepoName))
	})
}

// autoSurvey queues the first survey of a repository whose ticket is being
// analysed, when Settings allow it. Analysis does not wait for it.
func (o *Orchestrator) autoSurvey(ctx context.Context, s domain.Settings, repoID int64) {
	if o.briefs == nil || !s.AutoBrief {
		return
	}
	if _, err := o.briefs.Brief(ctx, repoID); !errors.Is(err, domain.ErrNotFound) {
		return // surveyed (or failed, or edited) before: people decide from here
	}
	if _, err := o.SurveyBrief(ctx, repoID, domain.OriginSystem); err != nil {
		o.log.Warn("queue survey", "repo", repoID, "err", err)
	}
}

// countMerge notes a merged ticket in its repository's brief, and queues an
// update of a brief that went stale.
func (o *Orchestrator) countMerge(ctx context.Context, t domain.Ticket) {
	for _, id := range t.RepoIDs() {
		if r, ok := t.RepoState(id); ok && (r.Changed() || !t.Multi()) {
			o.countRepoMerge(ctx, t, id)
		}
	}
}

// countRepoMerge counts a merge of the ticket's change in one repository
// toward its brief going stale.
func (o *Orchestrator) countRepoMerge(ctx context.Context, t domain.Ticket, repoID int64) {
	if o.briefs == nil {
		return
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return
	}
	queued := false
	_, err = o.briefs.UpdateBrief(ctx, repoID, func(b *domain.RepoBrief) error {
		b.MergesSince++
		if s.AutoBrief && b.Stale() && !b.Busy() && b.Draft == "" {
			b.Status, b.Error, queued = domain.BriefPending, "", true
		}
		return nil
	}, func(b domain.RepoBrief) *domain.Event {
		if !queued {
			return nil
		}
		return briefEvent(b, domain.OriginSystem, domain.LevelInfo,
			fmt.Sprintf("%d tickets merged since the brief of %s was approved: survey queued to update it", b.MergesSince, b.RepoName))
	})
	if err != nil {
		o.log.Warn("count merge for the brief", "ticket", t.Key, "err", err)
	}
	if queued {
		o.Wake()
	}
}

// contextFiles copies the knowledge a ticket's runs get into the
// workspace and returns what it wrote, for the prompt: the repository
// brief, the business context notes and, for a ticket, the most similar
// done tickets. t is zero for runs that are not a ticket's. A run in
// several repositories gets a brief and precedents per repository
// (brief-<folder>.md) and the group's instructions (group.md).
func (o *Orchestrator) contextFiles(ctx context.Context, ws Workspace, t domain.Ticket, rs []runRepo) []ContextFile {
	var out []ContextFile
	write := func(path, body, what string) {
		if err := ws.WriteFile(ctx, path, []byte(body)); err != nil {
			o.log.Warn("copy team knowledge", "path", path, "err", err)
			return
		}
		out = append(out, ContextFile{Path: path, What: what})
	}
	multi := len(rs) > 1
	if g := o.ticketGroup(ctx, t); g != nil && strings.TrimSpace(g.Instructions) != "" && multi {
		write(GroupPath, groupMarkdown(*g, rs), "how the repositories of the group "+g.Name+" fit together, from the team: contracts between them and the order of changes. Follow it across the repositories")
	}
	var files []string // what the work is expected to change, for the precedents
	if _, ok := o.store.(PrecedentStore); ok && len(rs) > 0 && t.ID != 0 {
		if r, err := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); err == nil {
			if a, err := parseAnalysis(r.Summary); err == nil && a.Footprint != nil {
				files = a.Footprint.Clean().Files
			}
		}
	}
	for _, r := range rs {
		if o.briefs == nil {
			break
		}
		b, err := o.briefs.Brief(ctx, r.ID)
		switch {
		case err == nil && b.Ready():
			path, what := BriefPath, "the repository brief the team approved: architecture, layers and allowed dependencies, recipes for common changes, files to copy, conventions and pitfalls"
			if multi {
				path, what = contextPath("brief", r), "the brief of "+r.Name+" ("+r.Folder()+"/) the team approved: its architecture, layers and allowed dependencies, recipes, files to copy, conventions and pitfalls"
			}
			write(path, b.Body+"\n", what)
			if b.Arch != nil {
				path, what := ArchPath, "the team's architecture.json: the layers and the imports each may make, the shared helpers to reuse, the recipes with files to copy. agnts checks changes against its layers"
				if multi {
					path, what = ContextDir+"/architecture-"+r.Folder()+".json", "the architecture.json of "+r.Name+" ("+r.Folder()+"/, paths relative to it): layers and allowed imports, shared helpers, recipes"
				}
				write(path, string(mustJSON(b.Arch))+"\n", what)
			}
		case err != nil && !errors.Is(err, domain.ErrNotFound):
			o.log.Warn("load the brief", "repo", r.Name, "err", err)
		}
	}
	if notes, err := o.businessNotes(ctx, repoIDsOf(rs)); err != nil {
		o.log.Warn("load business context", "err", err)
	} else if len(notes) > 0 {
		write(BusinessPath, businessMarkdown(notes), "business context the team wrote: what the product's terms mean, the invariants the code must keep, who uses what. Check your work against it")
	}
	if ps, ok := o.store.(PrecedentStore); ok && t.ID != 0 {
		except := []string{t.Key}
		if t.ReplayOf != "" {
			except = append(except, t.ReplayOf) // its own answer key
		}
		for _, r := range rs {
			prec, err := ps.Precedents(ctx, r.ID, except, filesIn(r, files, multi), t.Title+" "+t.Description, maxPrecedents)
			if err != nil {
				o.log.Warn("load precedents", "ticket", t.Key, "err", err)
				continue
			}
			if len(prec) == 0 {
				continue
			}
			path, what := PrecedentsPath, "similar tickets this team approved before, with what changed and what reviewers asked for: do similar work the same way, and avoid what reviewers objected to"
			if multi {
				path, what = contextPath("precedents", r), "similar tickets this team approved before in "+r.Name+", with what changed and what reviewers asked for"
			}
			write(path, precedentsMarkdown(r.Name, prec), what)
		}
	}
	if n := o.writeSkills(ctx, ws, repoIDsOf(rs)); n > 0 {
		out = append(out, ContextFile{Path: SkillsDir, What: fmt.Sprintf("%d more team %s as Claude Code skills (named agnts-…): load each one whose description matches what you are doing, and follow it like the rules above",
			n, plural(n, "rule or tip", "rules and tips"))})
	}
	return out
}

// GroupPath holds a group's instructions in a run of its repositories.
const GroupPath = ContextDir + "/group.md"

// contextPath is a context file of one repository in a run of several:
// /agnts/context/brief-api.md.
func contextPath(kind string, r runRepo) string {
	return ContextDir + "/" + kind + "-" + r.Folder() + ".md"
}

// filesIn keeps the paths (seen from /workspace) in r's folder, relative
// to r; in a run of one repository they are r's already.
func filesIn(r runRepo, paths []string, multi bool) []string {
	if !multi {
		return paths
	}
	var out []string
	for _, p := range paths {
		if rest, ok := strings.CutPrefix(p, r.Folder()+"/"); ok {
			out = append(out, rest)
		}
	}
	return out
}

// ticketGroup is the group a ticket's repositories came from, or nil.
func (o *Orchestrator) ticketGroup(ctx context.Context, t domain.Ticket) *domain.RepoGroup {
	if t.GroupID == nil {
		return nil
	}
	g, err := o.store.GroupByID(ctx, *t.GroupID)
	if err != nil {
		return nil
	}
	return &g
}

func groupMarkdown(g domain.RepoGroup, rs []runRepo) string {
	var b strings.Builder
	fmt.Fprintf(&b, "# %s\n\n", g.Name)
	if g.Description != "" {
		b.WriteString(g.Description + "\n\n")
	}
	b.WriteString("Repositories in this run:\n")
	for _, r := range rs {
		fmt.Fprintf(&b, "\n- %s/: %s", r.Folder(), r.Name)
		if r.Row.Role != "" {
			fmt.Fprintf(&b, " (%s)", r.Row.Role)
		}
	}
	fmt.Fprintf(&b, "\n\n## How they fit together\n\n%s\n", strings.TrimSpace(g.Instructions))
	return b.String()
}

// maxPrecedents is how many similar tickets a run gets.
const maxPrecedents = 5

func businessMarkdown(notes []domain.Rule) string {
	var b strings.Builder
	b.WriteString("# Business context\n")
	for _, n := range notes {
		scope := "every repository"
		if n.RepoID != nil {
			scope = n.RepoName
		}
		fmt.Fprintf(&b, "\n## %s (%s)\n\n%s\n", n.Title, scope, n.Text())
	}
	return b.String()
}

func precedentsMarkdown(repo string, ps []Precedent) string {
	var b strings.Builder
	fmt.Fprintf(&b, "# Similar tickets done before in %s\n\nThe team merged these changes; do similar work the same way.\n", repo)
	rejected := false
	for _, p := range ps {
		if p.Rejected && !rejected {
			rejected = true
			b.WriteString("\n# Rejected: what not to do\n\nA person rejected these. Do not repeat what they objected to.\n")
		}
		fmt.Fprintf(&b, "\n## %s: %s\n", p.Key, p.Title)
		if p.Rejected && p.Reason != "" {
			fmt.Fprintf(&b, "\nWhy it was rejected: %s\n", truncate(p.Reason, 800))
		}
		if p.Summary != "" {
			fmt.Fprintf(&b, "\nWhat changed: %s\n", truncate(p.Summary, 1500))
		}
		if len(p.Files) > 0 {
			files := p.Files
			more := ""
			if len(files) > 15 {
				files, more = files[:15], fmt.Sprintf(" and %d more", len(p.Files)-15)
			}
			fmt.Fprintf(&b, "\nFiles: %s%s\n", strings.Join(files, ", "), more)
		}
		for _, f := range p.Feedback {
			fmt.Fprintf(&b, "\nA reviewer asked: %s\n", truncate(strings.ReplaceAll(f, "\n", " "), 800))
		}
		if p.Excerpt != "" && !p.Rejected {
			what := "From agnts's change"
			if p.Merged {
				what = "From what merged"
			}
			fmt.Fprintf(&b, "\n%s:\n\n```diff\n%s\n```\n", what, p.Excerpt)
		}
	}
	return b.String()
}

// DiffExcerpt is the key part of a change for a precedent: the files the
// work at hand also touches first, then the largest, at most maxLines
// lines of diff in all.
func DiffExcerpt(files []domain.FileChange, prefer []string, maxLines int) string {
	fs := slices.Clone(files)
	slices.SortStableFunc(fs, func(a, b domain.FileChange) int {
		pa, pb := slices.Contains(prefer, a.Path), slices.Contains(prefer, b.Path)
		if pa != pb {
			if pa {
				return -1
			}
			return 1
		}
		return (b.Add + b.Del) - (a.Add + a.Del)
	})
	var b strings.Builder
	left := maxLines
	for _, f := range fs {
		if left <= 0 || strings.TrimSpace(f.Diff) == "" {
			continue
		}
		lines := strings.Split(strings.TrimRight(f.Diff, "\n"), "\n")
		take := min(len(lines), left, 40)
		fmt.Fprintf(&b, "--- %s\n%s\n", f.Where(), strings.Join(lines[:take], "\n"))
		if take < len(lines) {
			b.WriteString("…\n")
		}
		left -= take
	}
	return strings.TrimRight(b.String(), "\n")
}

// surveyBrief has Claude survey a claimed repository and stores the draft
// for a person to approve.
func (o *Orchestrator) surveyBrief(ctx context.Context, b domain.RepoBrief) {
	log := o.log.With("repo", b.RepoID)
	log.Info("survey started")
	draft, sha, arch, err := o.runSurvey(ctx, b)
	if ctx.Err() != nil {
		log.Info("survey interrupted") // RecoverBriefs requeues it
		return
	}
	var stop *stopError
	limited := errors.As(err, &stop)
	var msg string
	level := domain.LevelInfo
	_, uerr := o.briefs.UpdateBrief(ctx, b.RepoID, func(x *domain.RepoBrief) error {
		if x.Status != domain.BriefSurveying {
			return errStale
		}
		switch {
		case limited:
			x.Status = domain.BriefPending // claimed again once usage allows
		case x.Revision != b.Revision:
			// A person changed the brief meanwhile: survey again from theirs.
			x.Status = domain.BriefPending
			msg = fmt.Sprintf("the brief of %s changed during its survey; surveying again", x.RepoName)
		case err != nil:
			x.Status, x.Error = domain.BriefFailed, err.Error()
			level, msg = domain.LevelWarn, fmt.Sprintf("could not survey %s: %v", x.RepoName, err)
		default:
			now := time.Now()
			x.Status, x.Error, x.Draft, x.DraftSHA, x.ArchDraft, x.SurveyedAt = domain.BriefIdle, "", draft, sha, arch, &now
			msg = fmt.Sprintf("survey of %s finished: a draft brief waits for your approval", x.RepoName)
		}
		return nil
	}, func(x domain.RepoBrief) *domain.Event {
		if msg == "" {
			return nil
		}
		return briefEvent(x, domain.OriginSystem, level, msg)
	})
	switch {
	case errors.Is(uerr, errStale), errors.Is(uerr, domain.ErrNotFound):
		log.Info("brief changed or its repository was deleted during the survey; result dropped")
	case uerr != nil:
		log.Error("save survey", "err", uerr)
	case err != nil:
		log.Warn("survey failed", "err", err)
	default:
		log.Info("survey finished")
	}
}

func (o *Orchestrator) runSurvey(ctx context.Context, b domain.RepoBrief) (string, string, *domain.Architecture, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return "", "", nil, err
	}
	repo, err := o.store.RepositoryByID(ctx, b.RepoID)
	if err != nil {
		return "", "", nil, err
	}
	if err := o.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
		return "", "", nil, fmt.Errorf("prepare repository: %w", err)
	}
	rc, err := o.git.Archive(ctx, repo, repo.DefaultBranch)
	if err != nil {
		return "", "", nil, fmt.Errorf("archive repository: %w", err)
	}
	defer func() { _ = rc.Close() }()

	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("brief-%d", repo.ID), Image: o.cfg.Image, Repo: rc})
	if err != nil {
		return "", "", nil, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "repo", repo.Name, "err", err)
		}
	}()
	sha := ""
	if r, err := ws.Exec(ctx, "git rev-parse HEAD", time.Minute); err == nil && r.ExitCode == 0 {
		sha = strings.TrimSpace(r.Output)
		if len(sha) != 40 {
			sha = ""
		}
	}
	d := promptData{Repo: repo, Brief: b}
	if b.Ready() {
		if err := ws.WriteFile(ctx, BriefPath, []byte(b.Body+"\n")); err != nil {
			return "", "", nil, fmt.Errorf("copy the brief: %w", err)
		}
		if b.Arch != nil {
			_ = ws.WriteFile(ctx, ArchPath, mustJSON(b.Arch))
		}
	}
	if d.Rules, err = o.teamRules(ctx, []int64{repo.ID}); err != nil {
		return "", "", nil, err
	}
	prompt, err := render("survey", d)
	if err != nil {
		return "", "", nil, err
	}
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeBrief, WorkspaceID: repo.WorkspaceID, Subject: repo.Name}, ClaudeRequest{
		Prompt:   prompt,
		Model:    s.Models.Analyze,
		MaxTurns: min(s.MaxTurns, surveyMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, surveyTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, func(e ClaudeEvent) {
		if e.Kind == ClaudeRateLimit {
			o.usage.Record(ctx, e.Data)
		}
	})
	if err != nil {
		return "", "", nil, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return "", "", nil, &stopError{"rate limited"}
	}
	if res.IsError {
		if res.Subtype == "error_max_turns" {
			return "", "", nil, fmt.Errorf("stopped at the turn limit (%d) before writing the brief", min(s.MaxTurns, surveyMaxTurns))
		}
		return "", "", nil, fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, BriefOutPath)
	if err != nil {
		return "", "", nil, fmt.Errorf("claude did not write %s: %w", BriefOutPath, err)
	}
	draft, err := domain.CleanBriefText(string(raw))
	if err != nil {
		return "", "", nil, err
	}
	if len(draft) < 200 {
		return "", "", nil, errors.New("the survey wrote an almost empty brief")
	}
	return draft, sha, o.surveyArchitecture(ctx, ws, repo.Name), nil
}

// surveyArchitecture reads the architecture a survey wrote, without the
// files it names that do not exist; nil when there is none or it is not
// valid (the brief is kept either way).
func (o *Orchestrator) surveyArchitecture(ctx context.Context, ws Workspace, repo string) *domain.Architecture {
	raw, err := ws.ReadFile(ctx, ArchOutPath)
	if err != nil {
		return nil
	}
	a, err := domain.ParseArchitecture(string(raw))
	if err != nil || a == nil {
		if err != nil {
			o.log.Warn("survey architecture", "repo", repo, "err", err)
		}
		return nil
	}
	if missing := missingFiles(ctx, ws, a.Files()); len(missing) > 0 {
		o.log.Info("survey architecture names files that do not exist; dropped", "repo", repo, "files", missing)
		x := a.Without(missing)
		a = &x
	}
	return a
}
