package orchestrator

import (
	"cmp"
	"context"
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Replayer is a Git that can cut a branch at a past commit, for replays.
type Replayer interface {
	// BaseOf returns the commit a change at sha started from (its merge
	// base with the default branch).
	BaseOf(ctx context.Context, repo domain.Repository, sha string) (string, error)
	// PrepareAt makes sure branch exists: as it is, else new at base.
	PrepareAt(ctx context.Context, repo domain.Repository, branch, base string) error
}

// ReplayStore reads replays and their originals for the eval report. A
// Store may implement it.
type ReplayStore interface {
	ReplayRows(ctx context.Context, limit int) ([]ReplayRow, error)
}

// ReplayRow is a replay and its original as stored.
type ReplayRow struct {
	Key, Original, Title string
	State                domain.TicketState
	PromptVersion        string // of the replay's first coding run
	Model                string // of the replay's first coding run
	Files, Tests         []byte // the replay's latest code result (nil: none)
	Verdict              string // of its latest code review
	Turns                int
	CostUSD              float64
	OriginalFiles        []byte
	OriginalTurns        int
	OriginalCostUSD      float64
	// MergedFiles is what the original's pull requests merged as (a JSON
	// list of file changes, empty when that was not recorded).
	MergedFiles []byte
	Benchmark   bool // the original is in the benchmark
	CreatedAt   time.Time
}

// ReplayResult is how a replay compares with its original.
type ReplayResult struct {
	Key, Original, Title string
	State                domain.TicketState
	PromptVersion        string
	Model                string
	Benchmark            bool
	HasChange            bool // the replay changed files
	ChecksPassed         bool
	Files, OriginalFiles []string
	// Against is what the replay is scored against: "merged" (what the
	// original's pull request merged as) or "agnts" (the original's own
	// change, when the merge was not recorded).
	Against string
	// Overlap is the Jaccard index of the two changes' files; Recall the
	// share of the target's files the replay changed too.
	Overlap, Recall float64
	// LineRecall is the share of the lines the merged change adds that the
	// replay adds too; OriginalLineRecall the same for the original's own
	// change, to compare with. -1 when there is no merged change.
	LineRecall, OriginalLineRecall float64
	Verdict                        string
	Turns, OriginalTurns           int
	CostUSD, OriginalCostUSD       float64
	CreatedAt                      time.Time
}

// EvalVersion sums the replays of one prompt version and coding model.
type EvalVersion struct {
	PromptVersion string
	Model         string
	Replays       int // with a change to compare
	ChecksPassed  int
	LooksGood     int // reviews that found nothing to block
	Reviewed      int
	AvgOverlap    float64
	AvgRecall     float64
	// Merged is how many were scored against a merged change, and the
	// line recalls their averages (-1 when none was).
	Merged             int
	AvgLineRecall      float64
	OriginalLineRecall float64
	AvgTurns           float64
	AvgCostUSD         float64
	// The same for the originals of these replays, for comparison.
	OriginalTurns   float64
	OriginalCostUSD float64
}

// ReplayReport compares replays with the work they re-ran: all of them,
// and the replays of the benchmark's tickets on their own.
type ReplayReport struct {
	Versions  []EvalVersion
	Benchmark []EvalVersion
	Replays   []ReplayResult
}

// ReplayOptions change how a replay runs.
type ReplayOptions struct {
	// Models replace the original's model for the stages they name.
	Models map[string]string
}

// Replay re-runs a done code or test ticket as a new local task, cut from
// the commit the original started from and given the original's answers,
// with today's prompts. It is for evaluation: agnts never pushes it.
func (o *Orchestrator) Replay(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	return o.ReplayWith(ctx, key, ReplayOptions{}, origin)
}

// ReplayWith is Replay with options.
func (o *Orchestrator) ReplayWith(ctx context.Context, key string, opts ReplayOptions, origin domain.Origin) (domain.Ticket, error) {
	if err := checkModels(opts.Models); err != nil {
		return domain.Ticket{}, err
	}
	rp, ok := o.git.(Replayer)
	if !ok {
		return domain.Ticket{}, invalid("replays are not available on this server")
	}
	orig, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return orig, err
	}
	switch {
	case orig.ReplayOf != "":
		return orig, invalid("%s is itself a replay; replay %s instead", orig.Key, orig.ReplayOf)
	case orig.State != domain.StateDone || orig.Kind.Report():
		return orig, invalid("only done code and test tickets can be replayed")
	case orig.RepoID == nil || orig.HeadSHA == "":
		return orig, invalid("%s has no approved change to compare with", orig.Key)
	}
	// Each repository is cut from where the original's work in it started.
	var rows []domain.TicketRepo
	var repo domain.Repository
	base := ""
	for i, id := range orig.RepoIDs() {
		row, _ := orig.RepoState(id)
		r, err := o.store.RepositoryByID(ctx, id)
		if err != nil {
			return orig, err
		}
		if i == 0 {
			repo = r
		}
		if row.HeadSHA == "" {
			if i == 0 {
				return orig, invalid("%s has no approved change to compare with", orig.Key)
			}
			continue
		}
		if err := o.git.Prepare(ctx, r, r.DefaultBranch); err != nil {
			return orig, fmt.Errorf("prepare repository: %w", err)
		}
		b, err := rp.BaseOf(ctx, r, row.HeadSHA)
		if err != nil {
			return orig, invalid("cannot find where %s started: %v", orig.Key, err)
		}
		if i == 0 {
			base = b
		}
		rows = append(rows, domain.TicketRepo{RepoID: id, RepoName: r.Name, Role: row.Role, BaseSHA: b, State: domain.RepoPending})
	}
	qs, err := o.store.Questions(ctx, orig.ID)
	if err != nil {
		return orig, err
	}
	desc := orig.Description
	var answered []string
	for _, q := range qs {
		if q.Answer != nil && strings.TrimSpace(*q.Answer) != "" {
			a := strings.TrimSpace(*q.Answer)
			if n := strings.TrimSpace(q.Note); n != "" {
				a += " (" + n + ")"
			}
			answered = append(answered, "- "+q.Text+"\n  "+a)
		}
	}
	if len(answered) > 0 {
		desc = strings.TrimSpace(desc + "\n\nThe author already answered these questions:\n" + strings.Join(answered, "\n"))
	}
	domain.AssignFolders(rows)
	t, err := o.createTask(ctx, domain.Ticket{
		Source: domain.SourceLocal, RepoID: &repo.ID, Repos: rows, Title: "Replay of " + orig.Key + ": " + orig.Title, Description: desc,
		Priority: "low", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr",
		AskFirst: false, Kind: orig.Kind, Models: withModels(orig.Models, opts.Models), ReplayOf: orig.Key, BaseSHA: base,
	}, TaskPrefix(repo), nil, origin)
	if err != nil {
		return t, err
	}
	o.event(ctx, domain.Event{TicketKey: orig.Key, Type: domain.EventTicketUpdated, Origin: origin,
		Message: fmt.Sprintf("replayed as %s from commit %s, to compare with today's agnts", t.Key, base[:min(7, len(base))]),
		Data:    map[string]any{"replay": t.Key, "base": base}})
	return t, nil
}

// ReplayReport compares the newest replays with their originals, by
// prompt version.
func (o *Orchestrator) ReplayReport(ctx context.Context) (ReplayReport, error) {
	rs, ok := o.store.(ReplayStore)
	if !ok {
		return ReplayReport{}, invalid("replays are not available on this server")
	}
	rows, err := rs.ReplayRows(ctx, 300)
	if err != nil {
		return ReplayReport{}, err
	}
	return buildReplayReport(rows), nil
}

func buildReplayReport(rows []ReplayRow) ReplayReport {
	out := ReplayReport{Versions: []EvalVersion{}, Benchmark: []EvalVersion{}, Replays: []ReplayResult{}}
	all, bench := newEvalSum(), newEvalSum()
	for _, r := range rows {
		x := scoreReplay(r)
		out.Replays = append(out.Replays, x)
		if !x.HasChange {
			continue
		}
		all.add(x)
		if x.Benchmark {
			bench.add(x)
		}
	}
	out.Versions, out.Benchmark = all.versions(), bench.versions()
	return out
}

// scoreReplay compares a replay with what its original merged as, or with
// the original's own change when the merge was not recorded.
func scoreReplay(r ReplayRow) ReplayResult {
	x := ReplayResult{Key: r.Key, Original: r.Original, Title: r.Title, State: r.State, PromptVersion: r.PromptVersion, Model: r.Model,
		Benchmark: r.Benchmark, Verdict: r.Verdict, Turns: r.Turns, CostUSD: r.CostUSD, OriginalTurns: r.OriginalTurns,
		OriginalCostUSD: r.OriginalCostUSD, CreatedAt: r.CreatedAt, Files: filePaths(r.Files), OriginalFiles: filePaths(r.OriginalFiles),
		LineRecall: -1, OriginalLineRecall: -1}
	x.HasChange = len(x.Files) > 0
	var steps []CheckStep
	_ = json.Unmarshal(r.Tests, &steps)
	x.ChecksPassed = x.HasChange && !slices.ContainsFunc(steps, func(c CheckStep) bool { return c.ExitCode != 0 })
	var merged, got, orig []domain.FileChange
	_ = json.Unmarshal(r.MergedFiles, &merged)
	if len(merged) == 0 {
		x.Against = "agnts"
		x.Overlap, x.Recall = fileOverlap(x.Files, x.OriginalFiles)
		return x
	}
	x.Against = "merged"
	_ = json.Unmarshal(r.Files, &got)
	_ = json.Unmarshal(r.OriginalFiles, &orig)
	want := make([]string, 0, len(merged))
	for _, f := range merged {
		want = append(want, f.Where())
	}
	x.Overlap, x.Recall = fileOverlap(x.Files, want)
	x.LineRecall, x.OriginalLineRecall = lineRecall(got, merged), lineRecall(orig, merged)
	return x
}

// evalSum adds replays up by prompt version and model.
type evalSum struct {
	by    map[[2]string]*EvalVersion
	lines map[[2]string]int // replays with a line recall
	order [][2]string
}

func newEvalSum() *evalSum {
	return &evalSum{by: map[[2]string]*EvalVersion{}, lines: map[[2]string]int{}}
}

func (s *evalSum) add(x ReplayResult) {
	k := [2]string{x.PromptVersion, x.Model}
	v := s.by[k]
	if v == nil {
		v = &EvalVersion{PromptVersion: x.PromptVersion, Model: x.Model}
		s.by[k] = v
		s.order = append(s.order, k)
	}
	v.Replays++
	if x.ChecksPassed {
		v.ChecksPassed++
	}
	if x.Verdict != "" {
		v.Reviewed++
		if x.Verdict == domain.VerdictLooksGood {
			v.LooksGood++
		}
	}
	if x.Against == "merged" {
		v.Merged++
	}
	if x.LineRecall >= 0 && x.OriginalLineRecall >= 0 {
		s.lines[k]++
		v.AvgLineRecall += x.LineRecall
		v.OriginalLineRecall += x.OriginalLineRecall
	}
	v.AvgOverlap += x.Overlap
	v.AvgRecall += x.Recall
	v.AvgTurns += float64(x.Turns)
	v.AvgCostUSD += x.CostUSD
	v.OriginalTurns += float64(x.OriginalTurns)
	v.OriginalCostUSD += x.OriginalCostUSD
}

func (s *evalSum) versions() []EvalVersion {
	out := []EvalVersion{}
	for _, k := range s.order {
		v := s.by[k]
		n := float64(v.Replays)
		v.AvgOverlap, v.AvgRecall, v.AvgTurns, v.AvgCostUSD = v.AvgOverlap/n, v.AvgRecall/n, v.AvgTurns/n, v.AvgCostUSD/n
		v.OriginalTurns, v.OriginalCostUSD = v.OriginalTurns/n, v.OriginalCostUSD/n
		if m := float64(s.lines[k]); m > 0 {
			v.AvgLineRecall, v.OriginalLineRecall = v.AvgLineRecall/m, v.OriginalLineRecall/m
		} else {
			v.AvgLineRecall, v.OriginalLineRecall = -1, -1
		}
		out = append(out, *v)
	}
	slices.SortStableFunc(out, func(a, b EvalVersion) int {
		return cmp.Or(cmp.Compare(a.PromptVersion, b.PromptVersion), cmp.Compare(a.Model, b.Model))
	})
	return out
}

func filePaths(raw []byte) []string {
	var fs []domain.FileChange
	if json.Unmarshal(raw, &fs) != nil {
		return nil
	}
	out := make([]string, 0, len(fs))
	for _, f := range fs {
		out = append(out, f.Where())
	}
	return out
}

// fileOverlap returns the Jaccard index of two file lists, and the share
// of want that got also has.
func fileOverlap(got, want []string) (jaccard, recall float64) {
	if len(got) == 0 && len(want) == 0 {
		return 0, 0
	}
	hit := 0
	for _, f := range want {
		if slices.Contains(got, f) {
			hit++
		}
	}
	union := len(got) + len(want) - hit
	jaccard = float64(hit) / float64(union)
	if len(want) > 0 {
		recall = float64(hit) / float64(len(want))
	}
	return jaccard, recall
}
