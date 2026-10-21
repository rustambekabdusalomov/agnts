package orchestrator

import (
	"context"
	"fmt"
	"maps"
	"slices"
	"strings"
	"unicode"

	"agnts/internal/domain"
)

// The benchmark is a fixed set of merged tickets a person picks. Every
// change to agnts's prompts or models is judged by replaying the whole set
// and scoring each replay against what the original's pull request merged
// as (MergedChange), not against agnts's own first try.

// MergedChangeStore keeps what pull requests merged as. A Store may
// implement it.
type MergedChangeStore interface {
	SaveMergedChange(ctx context.Context, m domain.MergedChange) error
	MergedChanges(ctx context.Context, ticketID int64) ([]domain.MergedChange, error)
}

// BenchmarkStore lists the benchmark. A Store may implement it.
type BenchmarkStore interface {
	BenchmarkTickets(ctx context.Context) ([]domain.Ticket, error)
}

// saveMergedChange records what the ticket's pull request in repo merged
// as, read from the git host. It is best effort: a failure is logged.
func (o *Orchestrator) saveMergedChange(ctx context.Context, t domain.Ticket, repo domain.Repository, r domain.TicketRepo) {
	ms, ok := o.store.(MergedChangeStore)
	if !ok || r.PRNumber == nil || t.ReplayOf != "" || t.Kind.Report() || t.Kind == domain.KindReview {
		return
	}
	conv, err := o.conversation()
	if err != nil {
		return
	}
	files, err := conv.PullFiles(ctx, repo, *r.PRNumber)
	if err != nil {
		o.log.Warn("read the merged pull request's files", "ticket", t.Key, "repo", repo.Name, "err", err)
		return
	}
	if t.Multi() {
		for i := range files {
			files[i].Repo, files[i].RepoID = r.Folder, repo.ID
		}
	}
	if err := ms.SaveMergedChange(ctx, domain.MergedChange{TicketID: t.ID, RepoID: repo.ID, Number: *r.PRNumber, HeadSHA: r.HeadSHA, Files: files}); err != nil {
		o.log.Warn("save the merged change", "ticket", t.Key, "err", err)
	}
	o.suggestMergedPatterns(ctx, t, repo.ID, files)
	o.learnFromMerge(ctx, t, repo.ID, files)
}

// SetBenchmark puts a merged code or test ticket in the benchmark, or takes
// one out.
func (o *Orchestrator) SetBenchmark(ctx context.Context, key string, on bool, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil || t.Benchmark == on {
		return t, err
	}
	if on && (t.ReplayOf != "" || (t.Kind != domain.KindCode && t.Kind != domain.KindTest) || t.MergedAt == nil || t.HeadSHA == "") {
		return t, invalid("only merged code and test tickets can be in the benchmark: replays are scored against what they merged as")
	}
	msg := "taken out of the benchmark"
	if on {
		msg = "added to the benchmark: changes to agnts are replayed against it"
	}
	return o.store.UpdateTicket(ctx, key, &domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: msg,
		Data: map[string]any{"benchmark": on}}, func(x *domain.Ticket) { x.Benchmark = on })
}

// Benchmark returns the tickets in the benchmark.
func (o *Orchestrator) Benchmark(ctx context.Context) ([]domain.Ticket, error) {
	bs, ok := o.store.(BenchmarkStore)
	if !ok {
		return nil, invalid("the benchmark is not available on this server")
	}
	return bs.BenchmarkTickets(ctx)
}

// BenchmarkRun is one ticket of a benchmark run: its replay, or why it
// could not be replayed.
type BenchmarkRun struct {
	Original string
	Replay   *domain.Ticket
	Error    string
}

// RunBenchmark replays every ticket in the benchmark with today's prompts,
// and with models for the stages it names (empty: the originals' models).
func (o *Orchestrator) RunBenchmark(ctx context.Context, models map[string]string, origin domain.Origin) ([]BenchmarkRun, error) {
	if err := checkModels(models); err != nil {
		return nil, err
	}
	ts, err := o.Benchmark(ctx)
	if err != nil {
		return nil, err
	}
	if len(ts) == 0 {
		return nil, invalid("the benchmark is empty: add merged tickets to it first (Add to benchmark on a merged ticket)")
	}
	out := make([]BenchmarkRun, 0, len(ts))
	for _, t := range ts {
		run := BenchmarkRun{Original: t.Key}
		r, err := o.ReplayWith(ctx, t.Key, ReplayOptions{Models: models}, origin)
		if err != nil {
			run.Error = err.Error()
		} else {
			run.Replay = &r
		}
		out = append(out, run)
	}
	o.Wake()
	return out, nil
}

// checkModels checks stage → model overrides for a replay.
func checkModels(models map[string]string) error {
	stages := []string{domain.ModelAnalyze, domain.ModelCoding, domain.ModelRetry, domain.ModelReview}
	for k, v := range models {
		if !slices.Contains(stages, k) {
			return invalid("unknown stage %q: a replay can change the models of %s", k, strings.Join(stages, ", "))
		}
		if !domain.ValidModel(v) {
			return invalid("unknown model %q for %s", v, k)
		}
	}
	return nil
}

// withModels returns base with the stages in over replaced, as a copy.
func withModels(base, over map[string]string) map[string]string {
	if len(over) == 0 {
		return base
	}
	out := maps.Clone(base)
	if out == nil {
		out = map[string]string{}
	}
	for k, v := range over {
		if k, v = strings.TrimSpace(k), strings.TrimSpace(v); k != "" && v != "" {
			out[k] = v
		}
	}
	return out
}

// lineRecall is the share of the lines want's diffs add that got's diffs
// add too, ignoring indentation, blank lines and lines of punctuation
// only (a closing brace matches anything). -1 when want adds none.
func lineRecall(got, want []domain.FileChange) float64 {
	need := lineCounts(want)
	total := 0
	for _, n := range need {
		total += n
	}
	if total == 0 {
		return -1
	}
	have := lineCounts(got)
	hit := 0
	for l, n := range need {
		hit += min(n, have[l])
	}
	return float64(hit) / float64(total)
}

// lineCounts counts the meaningful lines the diffs add.
func lineCounts(fs []domain.FileChange) map[string]int {
	out := map[string]int{}
	for _, f := range fs {
		for _, l := range strings.Split(f.Diff, "\n") {
			if !strings.HasPrefix(l, "+") || strings.HasPrefix(l, "+++") {
				continue
			}
			l = strings.Join(strings.Fields(l[1:]), " ")
			if len(l) < 4 || !strings.ContainsFunc(l, func(r rune) bool { return unicode.IsLetter(r) || unicode.IsDigit(r) }) {
				continue
			}
			out[l]++
		}
	}
	return out
}

// BenchmarkError says which tickets could not be replayed, or nil.
func BenchmarkError(runs []BenchmarkRun) error {
	var bad []string
	for _, r := range runs {
		if r.Error != "" {
			bad = append(bad, r.Original+": "+r.Error)
		}
	}
	if len(bad) == 0 {
		return nil
	}
	return fmt.Errorf("%d of %d not replayed:\n%s", len(bad), len(runs), strings.Join(bad, "\n"))
}
