package admin

import (
	"context"
	"math"
	"sort"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/vcs"
)

// Insight is one observation; the client words it in the user's language.
type Insight struct {
	Kind   string            // claudeMd, waiting, stopsTests, stopsLimit, night, mergeRate, slowAnswers, followUpsNoise, flakyJob
	Values map[string]string // placeholders for the message
}

// AnalyticsView is the Analytics page.
type AnalyticsView struct {
	postgres.Analytics
	Insights []Insight
}

// Analytics builds the Analytics page for 7, 30 or 90 days.
func (d *Dashboard) Analytics(ctx context.Context, days int) (AnalyticsView, error) {
	a, err := d.store.Analytics(ctx, periodDays(days), d.tz)
	if err != nil {
		return AnalyticsView{}, err
	}
	return AnalyticsView{Analytics: a, Insights: insights(a)}, nil
}

func periodDays(days int) int {
	if days != 7 && days != 30 && days != 90 {
		return 30
	}
	return days
}

// Delivery builds the Analytics page's Delivery tab.
func (d *Dashboard) Delivery(ctx context.Context, days int) (postgres.Delivery, error) {
	return d.store.Delivery(ctx, periodDays(days), d.tz)
}

// CIHealth builds the CI card of the Analytics page's Quality tab.
func (d *Dashboard) CIHealth(ctx context.Context, days int) (postgres.CIHealth, error) {
	return d.store.CIHealth(ctx, periodDays(days), d.tz)
}

// Learning builds the Analytics page's Learning tab.
func (d *Dashboard) Learning(ctx context.Context, days int) (postgres.Learning, error) {
	return d.store.Learning(ctx, periodDays(days), d.tz)
}

func insights(a postgres.Analytics) []Insight {
	var out []Insight
	itoa := func(v float64) string { return formatInt(int(math.Round(v))) }

	// CLAUDE.md: compare average turns of repositories with and without one.
	var with, without, wn, won float64
	var missing []string
	for _, r := range a.Repos {
		if r.AvgTurns == 0 || r.Tickets == 0 {
			continue
		}
		switch r.ClaudeMD {
		case "found":
			with += r.AvgTurns * float64(r.Tickets)
			wn += float64(r.Tickets)
		case "missing":
			without += r.AvgTurns * float64(r.Tickets)
			won += float64(r.Tickets)
			missing = append(missing, r.Name)
		}
	}
	if wn > 0 && won > 0 {
		if gain := (1 - (with/wn)/(without/won)) * 100; gain > 5 {
			names := ""
			for i, n := range missing {
				if i > 0 {
					names += ", "
				}
				names += n
			}
			out = append(out, Insight{Kind: "claudeMd", Values: map[string]string{"gain": itoa(gain), "repos": names}})
		}
	}

	c := a.Current
	if total := c.WaitMin + c.AgntsMin; total > 0 && c.WaitMin > 0 {
		out = append(out, Insight{Kind: "waiting", Values: map[string]string{
			"share": itoa(c.WaitMin / total * 100), "review": itoa(c.ReviewMin)}})
	}

	if a.Stops["tests"] > 0 || a.Stops["limit"] > 0 {
		if a.Stops["tests"] >= a.Stops["limit"] {
			out = append(out, Insight{Kind: "stopsTests", Values: map[string]string{"n": formatInt(a.Stops["tests"])}})
		} else {
			out = append(out, Insight{Kind: "stopsLimit", Values: map[string]string{"n": formatInt(a.Stops["limit"])}})
		}
	}

	// Pull requests: a low merge rate means agnts's work is thrown away.
	if decided := c.Merged + c.Closed; decided >= 4 {
		if pct := float64(c.Merged) / float64(decided) * 100; pct < 60 {
			out = append(out, Insight{Kind: "mergeRate", Values: map[string]string{"pct": itoa(pct), "closed": formatInt(c.Closed)}})
		}
	}

	// Questions: tickets wait on a person's answer for hours.
	if c.AnswerMin >= 120 {
		out = append(out, Insight{Kind: "slowAnswers", Values: map[string]string{"hours": itoa(c.AnswerMin / 60)}})
	}

	// Follow-ups: most suggestions get dismissed.
	if decided := a.FollowUpsAccepted + a.FollowUpsDismissed; decided >= 5 {
		if pct := float64(a.FollowUpsAccepted) / float64(decided) * 100; pct < 25 {
			out = append(out, Insight{Kind: "followUpsNoise", Values: map[string]string{"pct": itoa(pct)}})
		}
	}

	// CI: the same job keeps failing and passing on re-run.
	if f := a.Flakiest; f.Flaky >= 3 {
		job := f.Job
		if f.Workflow != "" {
			job = f.Workflow + " / " + f.Job
		}
		out = append(out, Insight{Kind: "flakyJob", Values: map[string]string{"job": job, "repo": f.Repo, "n": formatInt(f.Flaky)}})
	}

	var night, all int
	for h, n := range a.Hours {
		all += n
		if h >= 22 || h < 7 {
			night += n
		}
	}
	if all > 0 && night > 0 {
		out = append(out, Insight{Kind: "night", Values: map[string]string{"pct": itoa(float64(night) / float64(all) * 100)}})
	}
	return out
}

func formatInt(n int) string {
	neg := n < 0
	if neg {
		n = -n
	}
	s := ""
	for {
		s = string(rune('0'+n%10)) + s
		n /= 10
		if n == 0 {
			break
		}
	}
	if neg {
		return "-" + s
	}
	return s
}

// RepoActivityView is the repository page's data.
type RepoActivityView struct {
	Repo         RepoView
	Branches     []vcs.Branch
	Commits      []vcs.Commit
	Pipelines    []vcs.Pipeline
	Environments []vcs.Environment
	Members      []vcs.Member
	Local        []LocalBranchView
	Tickets      map[string]string // branch -> ticket key, for agnts's branches
}

// Page sizes on the repository page.
const (
	CommitsPerPage   = 50
	PipelinesPerPage = 20
)

// Browse loads one part of the repository page; page (from 1) applies to
// commits and pipelines.
func (r *Repos) Browse(ctx context.Context, id int64, part string, page int) (RepoActivityView, error) {
	v, err := r.Get(ctx, id)
	if err != nil {
		return RepoActivityView{}, err
	}
	out := RepoActivityView{Repo: v, Tickets: map[string]string{}}
	switch part {
	case "branches":
		out.Branches, err = r.browser.Branches(ctx, v.Repository)
		sort.SliceStable(out.Branches, func(i, j int) bool {
			if out.Branches[i].Default != out.Branches[j].Default {
				return out.Branches[i].Default
			}
			return out.Branches[i].Date.After(out.Branches[j].Date)
		})
	case "commits":
		out.Commits, err = r.browser.Commits(ctx, v.Repository, max(page, 1), CommitsPerPage)
	case "pipelines":
		out.Pipelines, err = r.browser.Pipelines(ctx, v.Repository, max(page, 1), PipelinesPerPage)
	case "environments":
		out.Environments, err = r.browser.Environments(ctx, v.Repository)
	case "local":
		out.Local, err = r.localBranches(ctx, v.Repository)
	case "members":
		out.Members, err = r.browser.Members(ctx, v.Repository)
		sort.SliceStable(out.Members, func(i, j int) bool {
			return strings.ToLower(out.Members[i].Username) < strings.ToLower(out.Members[j].Username)
		})
	}
	return out, err
}

// Commit reads one commit of a repository from its git host.
func (r *Repos) Commit(ctx context.Context, id int64, sha string) (RepoView, vcs.CommitDetail, error) {
	v, err := r.Get(ctx, id)
	if err != nil {
		return RepoView{}, vcs.CommitDetail{}, err
	}
	c, err := r.browser.CommitDetail(ctx, v.Repository, strings.ToLower(sha))
	return v, c, err
}

// Push states of a local branch.
const (
	LocalOnly     = "local"    // origin does not have the branch
	LocalPushed   = "pushed"   // origin has the same commit
	LocalUnpushed = "unpushed" // origin has the branch, behind the local one
	LocalDiffers  = "differs"  // origin's branch has commits the local one lacks
)

// LocalBranchView is a local branch and how it stands against origin.
type LocalBranchView struct {
	vcs.LocalBranch
	Status   string
	Unpushed int // commits origin lacks (for LocalUnpushed)
}

// localBranches reads agnts's clones and compares each branch with the git
// host's live branch list, or with the clone's last fetch when the host
// cannot be reached.
func (r *Repos) localBranches(ctx context.Context, repo domain.Repository) ([]LocalBranchView, error) {
	if r.local == nil {
		return nil, nil
	}
	list, err := r.local.LocalBranches(repo)
	if err != nil {
		return nil, err
	}
	remote := map[string]string{} // name -> sha
	live := false
	if bs, err := r.browser.Branches(ctx, repo); err == nil {
		live = true
		for _, b := range bs {
			remote[b.Name] = b.SHA
		}
	}
	out := make([]LocalBranchView, len(list))
	for i, b := range list {
		v := LocalBranchView{LocalBranch: b}
		sha, onOrigin := remote[b.Name]
		if !live {
			sha, onOrigin = b.SHA, b.Unpushed >= 0
			if b.Unpushed > 0 {
				sha = ""
			}
		}
		switch {
		case !onOrigin:
			v.Status = LocalOnly
		case sha == b.SHA:
			v.Status = LocalPushed
		case b.Unpushed > 0:
			v.Status, v.Unpushed = LocalUnpushed, b.Unpushed
		default:
			v.Status = LocalDiffers
		}
		out[i] = v
	}
	return out, nil
}

// Deploy starts a deployment and records who started it.
func (r *Repos) Deploy(ctx context.Context, id int64, d vcs.Deploy, origin domain.Origin) error {
	v, err := r.Get(ctx, id)
	if err != nil {
		return err
	}
	if err := r.browser.Deploy(ctx, v.Repository, d); err != nil {
		return invalid("%v", err)
	}
	return r.store.AppendEvent(ctx, domain.Event{Type: domain.EventDeploy, Origin: origin, Level: domain.LevelWarn,
		Message: "deploy started on " + v.Name, Data: map[string]any{"repo": v.Name, "job": d.JobID, "ref": d.Ref, "at": time.Now().UTC()}})
}
