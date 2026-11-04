package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/perfreview"
)

// ScorePath is where a score run writes its answer.
const ScorePath = "/agnts/out/score.json"

const (
	scoreMaxTurns   = 8
	scoreTimeoutMin = 5
)

// ScoreRuns is the store of performance review scores. A Store may
// implement it; without it nothing is scored.
type ScoreRuns interface {
	PerfReviewWorkspaces(ctx context.Context) ([]int64, error)
	PendingScoreWorkspaces(ctx context.Context) ([]int64, error)
	EnsurePromptVersion(ctx context.Context, version, model string, anchors []byte) (domain.PromptVersionRow, error)
	PromptVersion(ctx context.Context, version string) (domain.PromptVersionRow, error)
	QueueScores(ctx context.Context, version string, since *time.Time) (int, error)
	ClaimScoreRun(ctx context.Context) (domain.ScoreRun, bool, error)
	RecoverScoreRuns(ctx context.Context) (int, error)
	SetScoreRunAccount(ctx context.Context, runID int64, conn *int64, credits bool) error
	RecordScoreCall(ctx context.Context, runID int64, c domain.ClaudeCall) error
	FinishScoreRun(ctx context.Context, run domain.ScoreRun, res domain.ScoreResult) error
	DeliveryOf(ctx context.Context, ticketID int64, delivery int) (domain.Delivery, error)
	AllCommitLinksOfTicket(ctx context.Context, ticketID int64) ([]domain.CommitLink, error)
	PullCommitsOf(ctx context.Context, repoID int64, number int) ([]domain.PushedCommit, error)
	AgentCommitsAmong(ctx context.Context, repoID int64, shas []string) (map[string]bool, error)
	// IdentityResolver maps git identities to the workspace's members.
	IdentityResolver(ctx context.Context) (perfreview.Resolve, error)
	PerfReviewSince(ctx context.Context) (*time.Time, error)
	UnscoredDeliveries(ctx context.Context, version string, since *time.Time) (int, error)
	AverageScoreCostUSD(ctx context.Context) (float64, int, error)
}

// ScoreHost reads the diffs scores are made of.
type ScoreHost interface {
	PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error)
	CommitFiles(ctx context.Context, repo domain.Repository, sha string) ([]domain.FileChange, error)
}

// ScoreCredits charges a finished score run that ran on credits.
type ScoreCredits interface {
	SettleScore(ctx context.Context, ws, runID int64, key string) error
}

// SetScoreHost sets where score diffs are read (nil: nothing is scored).
// Call it before Run.
func (o *Orchestrator) SetScoreHost(h ScoreHost) { o.scoreHost = h }

// scoreRuns is the store as ScoreRuns, or nil.
func (o *Orchestrator) scoreRuns() ScoreRuns {
	sr, _ := o.store.(ScoreRuns)
	return sr
}

// currentVersion makes sure the workspace has the current scoring
// version, its seed anchors frozen with it.
func (o *Orchestrator) currentVersion(ctx context.Context, sr ScoreRuns) (domain.PromptVersionRow, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return domain.PromptVersionRow{}, err
	}
	anchors, err := json.Marshal(perfreview.SeedAnchors)
	if err != nil {
		return domain.PromptVersionRow{}, err
	}
	return sr.EnsurePromptVersion(ctx, perfreview.PromptVersion, s.Models.Helper, anchors)
}

// PerfTick queues scores for new deliveries in every workspace that has
// performance reviews on, and closes the months that are due.
func (o *Orchestrator) PerfTick(sys context.Context) {
	sr := o.scoreRuns()
	if sr == nil {
		return
	}
	ids, err := sr.PerfReviewWorkspaces(sys)
	if err != nil {
		if sys.Err() == nil {
			o.log.Warn("list workspaces with performance reviews", "err", err)
		}
		return
	}
	for _, id := range ids {
		wctx := domain.WithWorkspace(sys, id)
		if s, err := o.settings.Get(wctx); err != nil || !s.PerfReview.Enabled {
			continue
		}
		v, err := o.currentVersion(wctx, sr)
		if err != nil {
			o.log.Warn("scoring version", "workspace", id, "err", err)
			continue
		}
		since, err := sr.PerfReviewSince(wctx)
		if err != nil || since == nil {
			continue
		}
		// Only deliveries since the workspace started scoring: earlier
		// ones cost money and wait for a backfill the owner confirms.
		if n, err := sr.QueueScores(wctx, v.Version, since); err != nil {
			o.log.Warn("queue scores", "workspace", id, "err", err)
		} else if n > 0 {
			o.log.Info("scores queued", "workspace", id, "count", n)
			o.Wake()
		}
		if pc, ok := o.store.(PeriodCloser); ok {
			o.closeMonths(wctx, pc)
		}
	}
}

// scoreDelivery runs a claimed score run and records how it ended.
func (o *Orchestrator) scoreDelivery(ctx context.Context, run domain.ScoreRun) {
	sr := o.scoreRuns()
	ctx = domain.WithWorkspace(ctx, run.WorkspaceID)
	log := o.log.With("workspace", run.WorkspaceID, "ticket", run.TicketKey, "delivery", run.Delivery, "score_run", run.ID)
	sc, err := o.score(ctx, sr, run)
	if ctx.Err() != nil {
		log.Info("score interrupted") // RecoverScoreRuns requeues it
		return
	}
	res := domain.ScoreResult{Status: domain.ScoreDone, Score: sc}
	var stop *stopError
	switch {
	case errors.As(err, &stop) || errors.Is(err, ErrPlanLimit):
		res = domain.ScoreResult{Status: domain.ScoreQueued, Error: err.Error()} // the account allows it later
	case err != nil && run.Attempts < domain.ScoreMaxAttempts:
		res = domain.ScoreResult{Status: domain.ScoreQueued, Error: err.Error()}
	case err != nil:
		res = domain.ScoreResult{Status: domain.ScoreFailed, Error: err.Error(),
			Score: &domain.TicketScore{Status: domain.ScoreUnscored, Error: truncate(err.Error(), 1000)}}
	}
	if ferr := sr.FinishScoreRun(context.WithoutCancel(ctx), run, res); ferr != nil {
		log.Error("save score", "err", ferr)
		return
	}
	switch {
	case err != nil:
		log.Warn("score failed", "attempt", run.Attempts, "err", err)
	default:
		log.Info("ticket scored", "points", sc.Points, "clamped", sc.Clamped, "facts_only", sc.FromFactsOnly)
	}
}

// score works out a delivery's score: its commits, their diff and facts,
// the model's answer within the facts' ceiling, and who gets the points.
func (o *Orchestrator) score(ctx context.Context, sr ScoreRuns, run domain.ScoreRun) (*domain.TicketScore, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	v, err := sr.PromptVersion(ctx, run.PromptVersion)
	if err != nil {
		return nil, fmt.Errorf("scoring version %s: %w", run.PromptVersion, err)
	}
	t, err := o.store.TicketByKey(ctx, run.TicketKey)
	if err != nil {
		return nil, err
	}
	d, err := sr.DeliveryOf(ctx, run.TicketID, run.Delivery)
	if err != nil {
		return nil, err
	}
	links, err := sr.AllCommitLinksOfTicket(ctx, run.TicketID)
	if err != nil {
		return nil, err
	}
	cleaned, err := o.cleanDelivery(ctx, sr, perfreview.InDelivery(links, d.PreviousAt))
	if err != nil {
		return nil, err
	}
	sc := &domain.TicketScore{Status: domain.ScoreScored, Factors: map[string]any{}}
	if len(cleaned.Commits) == 0 {
		// A redelivery with no new commits: the work earned before.
		sc.Points, sc.FromFactsOnly, sc.Rationale = 0, true, "No new commits reached a default branch since the previous delivery."
		return sc, nil
	}
	diffs, byRepo, sources, err := o.deliveryDiffs(ctx, cleaned)
	if err != nil {
		return nil, err
	}
	facts := perfreview.ComputeFacts(byRepo)
	sc.DiffSource = strings.Join(sources, ",")
	sc.Factors["facts"] = facts
	sc.Factors["factsScore"] = perfreview.FactsScore(facts)
	sc.Factors["ceiling"] = perfreview.Ceiling(facts)
	sc.Factors["earners"] = cleaned.Earners
	sc.Factors["commits"] = len(cleaned.Commits)
	sc.Factors["reverts"] = len(cleaned.Reverts)
	if perfreview.TooLarge(diffs) {
		sc.Points, sc.FromFactsOnly = perfreview.FactsScore(facts), true
		sc.Rationale = "The diff is past the size the model reads; the score comes from the computed facts."
	} else {
		var anchors []perfreview.Anchor
		if err := json.Unmarshal(v.Anchors, &anchors); err != nil || len(anchors) == 0 {
			anchors = perfreview.SeedAnchors
		}
		ans, model, err := o.askScore(ctx, s, run, perfreview.BuildInput(t, facts, diffs, anchors), v.Model)
		if err != nil {
			return nil, err
		}
		sc.Points, sc.Clamped = perfreview.Clamp(ans.Points, facts)
		sc.Rationale, sc.Model = ans.Rationale, model
		sc.Factors["model"] = map[string]any{"points": ans.Points, "factors": ans.Factors}
	}
	if q, err := o.quality(); err == nil {
		if sc.RevertedShare, err = o.revertedShare(ctx, q, cleaned); err != nil {
			return nil, err
		}
	}
	resolve, err := sr.IdentityResolver(ctx)
	if err != nil {
		return nil, err
	}
	for _, sh := range perfreview.Shares(cleaned.Earners, resolve, s.PerfReview.Location()) {
		sc.Authors = append(sc.Authors, domain.ScoreAuthor{Key: sh.Key, Share: sh.Share, Days: sh.Days})
	}
	return sc, nil
}

// cleanDelivery cleans a delivery's commits with the stored commits of
// the pull requests it squashed and the shas agnts made.
func (o *Orchestrator) cleanDelivery(ctx context.Context, sr ScoreRuns, commits []domain.CommitLink) (perfreview.Cleaned, error) {
	prCommits := map[perfreview.PullKey][]domain.PushedCommit{}
	shas := map[int64][]string{}
	for _, l := range commits {
		shas[l.RepoID] = append(shas[l.RepoID], l.SHA)
		if l.MergeKind != domain.MergeKindSquash || l.PRNumber == nil {
			continue
		}
		k := perfreview.PullKey{RepoID: l.RepoID, Number: *l.PRNumber}
		if _, ok := prCommits[k]; ok {
			continue
		}
		own, err := sr.PullCommitsOf(ctx, l.RepoID, *l.PRNumber)
		if err != nil {
			return perfreview.Cleaned{}, err
		}
		prCommits[k] = own
		for _, c := range own {
			shas[l.RepoID] = append(shas[l.RepoID], c.SHA)
		}
	}
	agent := map[int64]map[string]bool{}
	for repo, list := range shas {
		m, err := sr.AgentCommitsAmong(ctx, repo, list)
		if err != nil {
			return perfreview.Cleaned{}, err
		}
		agent[repo] = m
	}
	return perfreview.Clean(commits, prCommits, func(repo int64, sha string) bool { return agent[repo][strings.ToLower(sha)] }), nil
}

// deliveryDiffs reads each repository's diff: its pull requests', else
// its squash commits', else its own commits' combined.
func (o *Orchestrator) deliveryDiffs(ctx context.Context, c perfreview.Cleaned) ([]perfreview.RepoDiff, map[int64][]domain.FileChange, []string, error) {
	if o.scoreHost == nil {
		return nil, nil, nil, errors.New("no git host to read diffs from")
	}
	var diffs []perfreview.RepoDiff
	byRepo := map[int64][]domain.FileChange{}
	var sources []string
	for repoID, plan := range c.Repos {
		repo, err := o.store.RepositoryByID(ctx, repoID)
		if err != nil {
			return nil, nil, nil, err
		}
		var files []domain.FileChange
		source := plan.Source()
		switch source {
		case perfreview.SourcePullRequest:
			for _, n := range plan.Pulls {
				fs, err := o.scoreHost.PullFiles(ctx, repo, n)
				if err != nil {
					return nil, nil, nil, fmt.Errorf("read pull request #%d of %s: %w", n, repo.Name, err)
				}
				files = append(files, fs...)
			}
			// Commits that came without a pull request add their own.
			for _, sha := range plan.Commits {
				if pr := prOf(c.Commits, repoID, sha); pr == 0 {
					fs, err := o.scoreHost.CommitFiles(ctx, repo, sha)
					if err != nil {
						return nil, nil, nil, fmt.Errorf("read commit %s of %s: %w", shortSHA(sha), repo.Name, err)
					}
					files = append(files, fs...)
				}
			}
		default:
			list := plan.Commits
			if source == perfreview.SourceSquash {
				list = plan.Squashes
			}
			for _, sha := range list {
				fs, err := o.scoreHost.CommitFiles(ctx, repo, sha)
				if err != nil {
					return nil, nil, nil, fmt.Errorf("read commit %s of %s: %w", shortSHA(sha), repo.Name, err)
				}
				files = append(files, fs...)
			}
		}
		kept, _ := perfreview.Filter(files)
		byRepo[repoID] = files
		diffs = append(diffs, perfreview.RepoDiff{Name: repo.Name, Source: source, Files: kept})
		sources = append(sources, repo.Name+":"+source)
	}
	return diffs, byRepo, sources, nil
}

func prOf(commits []domain.CommitLink, repoID int64, sha string) int {
	for _, l := range commits {
		if l.RepoID == repoID && l.SHA == sha && l.PRNumber != nil {
			return *l.PRNumber
		}
	}
	return 0
}

// askScore has the helper model score the input in an empty, read-only
// sandbox. Its spend goes to the score run.
func (o *Orchestrator) askScore(ctx context.Context, s domain.Settings, run domain.ScoreRun, in perfreview.Input, model string) (perfreview.Answer, string, error) {
	if model == "" {
		model = s.Models.Helper
	}
	meta := transcriptMeta{Purpose: domain.PurposeScore, WorkspaceID: run.WorkspaceID, TicketKey: run.TicketKey,
		Subject: fmt.Sprintf("delivery %d", run.Delivery), ModelStage: "score", ScoreRunID: run.ID}
	src, err := json.Marshal(in)
	if err != nil {
		return perfreview.Answer{}, "", err
	}
	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("score-%d", run.ID), Image: o.cfg.Image, Repo: &empty})
	if err != nil {
		return perfreview.Answer{}, "", fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "score_run", run.ID, "err", err)
		}
	}()
	if err := ws.WriteFile(ctx, SourcePath, src); err != nil {
		return perfreview.Answer{}, "", fmt.Errorf("write the delivery: %w", err)
	}
	res, err := o.callClaude(ctx, ws, meta, ai.Request{
		Prompt:   perfreview.Prompt(SourcePath, ScorePath),
		Model:    model,
		MaxTurns: min(s.MaxTurns, scoreMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, scoreTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
		ReadOnly: true,
	}, nil)
	if err != nil {
		return perfreview.Answer{}, "", err
	}
	if res.RateLimited {
		return perfreview.Answer{}, "", ErrPlanLimit
	}
	if res.IsError {
		return perfreview.Answer{}, "", fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, ScorePath)
	if err != nil {
		return perfreview.Answer{}, "", fmt.Errorf("%s did not write %s: %w", domain.AgentName(res.Model), ScorePath, err)
	}
	ans, err := perfreview.ParseAnswer(raw)
	if err != nil {
		return perfreview.Answer{}, "", err
	}
	used := res.Model
	if used == "" {
		used = model
	}
	return ans, used, nil
}

// scoreCostGuessUSD is a score's cost before the workspace has any.
const scoreCostGuessUSD = 0.05

// ScoreAfford tells a cost estimate's credits against the balance;
// billing implements it.
type ScoreAfford interface {
	Afford(ctx context.Context, ws int64, usd float64) (need, balance int64, err error)
}

// BackfillEstimate is what scoring the earlier deliveries would take.
type BackfillEstimate struct {
	Deliveries int
	CostUSD    float64
	// Credits is what it takes from the workspace's credits, when scores
	// run on them (0 on the workspace's own account).
	Credits   int64
	Balance   int64
	OnCredits bool
	// Refused says why it cannot run, "" when it can.
	Refused string
	// Queued is how many scores were queued (confirmed only).
	Queued int
	// ReachDays is how far back commits are linked.
	ReachDays int
}

// BackfillScores estimates, and with confirm queues, the scores of the
// workspace's deliveries from since on that have none. Repositories'
// recent history is scanned first, so commit facts of earlier work are
// filled in; the scores follow as deliveries are found.
func (o *Orchestrator) BackfillScores(ctx context.Context, since *time.Time, confirm bool) (BackfillEstimate, error) {
	est := BackfillEstimate{ReachDays: 90}
	sr := o.scoreRuns()
	if sr == nil || o.scoreHost == nil {
		return est, invalid("performance reviews are not available on this server")
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return est, err
	}
	if !s.PerfReview.Enabled {
		return est, invalid("turn performance reviews on first")
	}
	v, err := o.currentVersion(ctx, sr)
	if err != nil {
		return est, err
	}
	if est.Deliveries, err = sr.UnscoredDeliveries(ctx, v.Version, since); err != nil {
		return est, err
	}
	avg, n, err := sr.AverageScoreCostUSD(ctx)
	if err != nil {
		return est, err
	}
	if n == 0 || avg <= 0 {
		avg = scoreCostGuessUSD
	}
	est.CostUSD = avg * float64(est.Deliveries)
	if route, hold := o.ai.RouteCall(ctx, ai.Call{Who: ai.Who{Workspace: domain.WorkspaceOf(ctx)}, Purpose: domain.PurposeScore,
		Req: ai.Request{Model: s.Models.Helper}}); hold == nil && route.Account.Credits {
		est.OnCredits = true
		if af, ok := o.credits.(ScoreAfford); ok {
			if est.Credits, est.Balance, err = af.Afford(ctx, domain.WorkspaceOf(ctx), est.CostUSD); err != nil {
				return est, err
			}
			if est.Credits > est.Balance {
				est.Refused = fmt.Sprintf("the workspace has %d credits and the backfill takes about %d", est.Balance, est.Credits)
			}
		}
	} else if hold != nil {
		est.Refused = hold.Error()
	}
	if !confirm || est.Refused != "" {
		return est, nil
	}
	if rs, ok := o.links.(interface {
		RepositoryAdded(ctx context.Context, repo domain.Repository)
	}); ok {
		if repos, err := o.listRepos(ctx); err == nil {
			for _, r := range repos {
				if r.ArchivedAt == nil && r.CloneURL != "" {
					rs.RepositoryAdded(ctx, r) // in the background
				}
			}
		}
	}
	if est.Queued, err = sr.QueueScores(ctx, v.Version, since); err != nil {
		return est, err
	}
	o.Wake()
	return est, nil
}
