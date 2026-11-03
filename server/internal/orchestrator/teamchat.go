package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// The team chat's model calls. The chat package builds the prompts and
// checks the answers; this file only runs them, through the AI gateway
// like every call, on the Team chat model.

const (
	chatWarm         = 10 * time.Minute
	chatTimeout      = 2 * time.Minute
	chatCodeTimeout  = 4 * time.Minute
	chatCodeMaxTurns = 30
)

// ChatModelCall is one model call of the team chat without a repository:
// the prompt holds everything; the answer is the model's final text.
type ChatModelCall struct {
	Kind   string // link, answer, ticket: the transcript's subject
	User   int64  // whose modules it may use; 0: the workspace's default person
	Prompt string
	// Light runs it on the light model of the Team chat model's provider.
	Light bool
}

// ChatModelResult is a call's final text and what it took.
type ChatModelResult struct {
	Text string
	AI   domain.ChatAI
}

// ChatModel runs a team chat call in the workspace's warm chat box (an
// empty container kept for the next call), opening one when there is none.
func (o *Orchestrator) ChatModel(ctx context.Context, c ChatModelCall) (ChatModelResult, error) {
	start := time.Now()
	s, err := o.settings.Get(ctx)
	if err != nil {
		return ChatModelResult{}, err
	}
	model := s.Models.For(domain.ModelTeamChat)
	if c.Light {
		model = o.lightModelOf(model)
	}
	ws := domain.WorkspaceOf(ctx)
	meta := transcriptMeta{Purpose: domain.PurposeTeamChat, WorkspaceID: ws, Person: c.User, Subject: c.Kind}
	if err := o.hold(ctx, meta, model); err != nil {
		return ChatModelResult{}, err
	}
	key := "team-chat:" + strconv.FormatInt(ws, 10)
	box, err := o.chatBox(ctx, key, ws)
	if err != nil {
		return ChatModelResult{}, fmt.Errorf("start container: %w", err)
	}
	res, err := o.callClaude(ctx, box, meta, ai.Request{
		Prompt:   c.Prompt,
		Model:    model,
		MaxTurns: 2,
		Timeout:  chatTimeout,
		Settings: permissionSettings(s, true),
		ReadOnly: true,
	}, nil)
	if err != nil || res.RateLimited || res.IsError {
		_ = box.Close(context.WithoutCancel(ctx))
	} else {
		o.keepWarmFor(key, box, chatWarm)
	}
	if err != nil {
		return ChatModelResult{}, err
	}
	if res.RateLimited {
		return ChatModelResult{}, ErrPlanLimit
	}
	if res.IsError {
		return ChatModelResult{}, fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 300))
	}
	return ChatModelResult{Text: res.Text, AI: chatAI(res, start)}, nil
}

func chatAI(res ai.Result, start time.Time) domain.ChatAI {
	p := res.Provider
	if p == "" {
		p = domain.ProviderOf(res.Model)
	}
	return domain.ChatAI{Provider: p, Model: res.Model, MS: time.Since(start).Milliseconds(), CostUSD: res.Usage.CostUSD}
}

// lightModelOf is the light model of model's provider, else the light tier.
func (o *Orchestrator) lightModelOf(model string) string {
	if o.ai != nil {
		if p, ok := o.ai.Providers().Get(domain.ProviderOf(model)); ok {
			if m := p.Catalog().Model(ai.Light); m != "" {
				return m
			}
		}
	}
	return domain.TierLight
}

// chatBox takes the workspace's warm chat box, or opens one.
func (o *Orchestrator) chatBox(ctx context.Context, key string, ws int64) (Workspace, error) {
	o.asst.mu.Lock()
	b, ok := o.asst.warm[key]
	if ok {
		delete(o.asst.warm, key)
	}
	o.asst.mu.Unlock()
	if ok && b.timer.Stop() {
		return b.ws, nil
	}
	return o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("team-chat-%d-%d", ws, time.Now().UnixNano()), Image: o.cfg.Image,
		Repo: emptyTree(), MemoryMB: assistantMemoryMB})
}

// keepWarmFor keeps a box for the next call of the same key for d.
func (o *Orchestrator) keepWarmFor(key string, box Workspace, d time.Duration) {
	o.asst.mu.Lock()
	defer o.asst.mu.Unlock()
	if o.asst.warm == nil {
		o.asst.warm = map[string]*warmBox{}
	}
	if old, ok := o.asst.warm[key]; ok && old.timer.Stop() {
		go func() { _ = old.ws.Close(context.Background()) }()
	}
	b := &warmBox{ws: box}
	b.timer = time.AfterFunc(d, func() {
		o.asst.mu.Lock()
		if o.asst.warm[key] == b {
			delete(o.asst.warm, key)
		}
		o.asst.mu.Unlock()
		if err := box.Close(context.Background()); err != nil {
			o.log.Warn("remove idle team chat container", "err", err)
		}
	})
	o.asst.warm[key] = b
}

// ChatCodeCall is a question about a repository's code.
type ChatCodeCall struct {
	User   int64
	RepoID int64
	Prompt string
}

// ChatCodeResult is the answer about the code, the commit it read, and
// the cited files that exist with their line counts.
type ChatCodeResult struct {
	Text  string
	SHA   string
	Repo  domain.Repository
	Lines map[string]int // path → lines, for the files the answer cites
	AI    domain.ChatAI
}

var fileCiteRe = regexp.MustCompile(`\[file:([^\]\s:]+)(?::(\d+))?\]`)

// ChatCode lets the Team chat model read a repository at its default
// branch's head, read-only, and answer from it. The container has no push
// credentials or agnts tokens; the guard's rules apply as on any run.
func (o *Orchestrator) ChatCode(ctx context.Context, c ChatCodeCall) (ChatCodeResult, error) {
	start := time.Now()
	s, err := o.settings.Get(ctx)
	if err != nil {
		return ChatCodeResult{}, err
	}
	repo, err := o.store.RepositoryByID(ctx, c.RepoID)
	if err != nil {
		return ChatCodeResult{}, err
	}
	model := s.Models.For(domain.ModelTeamChat)
	meta := transcriptMeta{Purpose: domain.PurposeTeamChat, WorkspaceID: repo.WorkspaceID, Person: c.User, Subject: "code " + repo.Name}
	if err := o.hold(ctx, meta, model); err != nil {
		return ChatCodeResult{}, err
	}
	if err := o.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
		return ChatCodeResult{}, fmt.Errorf("prepare repository: %w", err)
	}
	rc, err := o.git.Archive(ctx, repo, repo.DefaultBranch)
	if err != nil {
		return ChatCodeResult{}, fmt.Errorf("archive repository: %w", err)
	}
	defer func() { _ = rc.Close() }()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("team-chat-code-%d-%d", repo.ID, time.Now().UnixNano()), Image: o.cfg.Image, Repo: rc})
	if err != nil {
		return ChatCodeResult{}, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "repo", repo.Name, "err", err)
		}
	}()
	out := ChatCodeResult{Repo: repo, Lines: map[string]int{}}
	if r, err := ws.Exec(ctx, "git rev-parse HEAD", time.Minute); err == nil && r.ExitCode == 0 {
		if sha := strings.TrimSpace(r.Output); len(sha) == 40 {
			out.SHA = sha
		}
	}
	res, err := o.callClaude(ctx, ws, meta, ai.Request{
		Prompt:   c.Prompt,
		Model:    model,
		MaxTurns: min(s.MaxTurns, chatCodeMaxTurns),
		Timeout:  chatCodeTimeout,
		Settings: permissionSettings(s, true),
		ReadOnly: true,
	}, nil)
	if err != nil {
		return out, err
	}
	if res.RateLimited {
		return out, ErrPlanLimit
	}
	if res.IsError && res.Text == "" {
		return out, fmt.Errorf("%s ended with %s", domain.AgentName(res.Model), res.Subtype)
	}
	out.Text, out.AI = res.Text, chatAI(res, start)
	for _, m := range fileCiteRe.FindAllStringSubmatch(res.Text, 40) {
		p := strings.TrimPrefix(strings.TrimPrefix(m[1], "/workspace/"), "./")
		if _, done := out.Lines[p]; done || strings.Contains(p, "..") || strings.HasPrefix(p, "/") {
			continue
		}
		r, err := ws.Exec(ctx, "wc -l < "+shellQuote(p), 20*time.Second)
		if err != nil || r.ExitCode != 0 {
			continue
		}
		if n, err := strconv.Atoi(strings.TrimSpace(r.Output)); err == nil {
			out.Lines[p] = n + 1 // a last line without a newline is not counted
		}
	}
	if len(out.Text) == 0 {
		return out, errors.New("no answer")
	}
	return out, nil
}
