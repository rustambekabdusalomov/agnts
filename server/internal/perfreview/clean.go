package perfreview

import (
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Earner is a commit that earns a share of a delivery's points: a
// delivery's own ordinary commit, or a commit of a pull request it
// squashed.
type Earner struct {
	RepoID  int64     `json:"repoId"`
	SHA     string    `json:"sha"`
	Name    string    `json:"name,omitempty"`
	Login   string    `json:"login,omitempty"`
	Email   string    `json:"email,omitempty"`
	At      time.Time `json:"at"` // authored
	Subject string    `json:"subject,omitempty"`
	Agent   bool      `json:"agent,omitempty"` // agnts made it
}

// RepoPlan is where a repository's diff comes from: its pull requests,
// else its squash commits, else its ordinary commits (combined).
type RepoPlan struct {
	Pulls    []int
	Squashes []string
	Commits  []string
}

// Diff sources, as a score records them.
const (
	SourcePullRequest = "pull_request"
	SourceSquash      = "squash"
	SourceCommits     = "commits"
)

// Source names the plan's diff source.
func (p RepoPlan) Source() string {
	switch {
	case len(p.Pulls) > 0:
		return SourcePullRequest
	case len(p.Squashes) > 0:
		return SourceSquash
	}
	return SourceCommits
}

// Cleaned is a delivery's commits after cleaning.
type Cleaned struct {
	// Commits are the delivery's commits on the default branch that stay:
	// ordinary, merge and squash commits.
	Commits []domain.CommitLink
	// Reverts are the revert commits left out.
	Reverts []domain.CommitLink
	Earners []Earner
	Repos   map[int64]RepoPlan
}

// PullKey names a pull request of a repository.
type PullKey struct {
	RepoID int64
	Number int
}

// InDelivery picks a delivery's commits: those that reached the default
// branch after the previous delivery (since; nil for the first). When
// they were linked does not matter.
func InDelivery(links []domain.CommitLink, since *time.Time) []domain.CommitLink {
	var out []domain.CommitLink
	for _, l := range links {
		if l.OnDefaultAt == nil || (since != nil && !l.OnDefaultAt.After(*since)) {
			continue
		}
		out = append(out, l)
	}
	return out
}

// isRevertLink reports whether a link reverts something.
func isRevertLink(l domain.CommitLink) bool {
	s := l.Subject
	return l.Reverts != "" || strings.HasPrefix(s, `Revert "`) || strings.HasPrefix(s, "Revert '") || strings.HasPrefix(s, "revert: ")
}

// Clean drops reverts, keeps merge commits for the range only, swaps each
// squash for its pull request's own commits as earners, and collapses the
// copies a rebase merge makes (same author email, date and subject).
// prCommits are the stored commits of squashed pull requests; agent says
// which shas agnts made.
func Clean(commits []domain.CommitLink, prCommits map[PullKey][]domain.PushedCommit, agent func(repoID int64, sha string) bool) Cleaned {
	out := Cleaned{Repos: map[int64]RepoPlan{}}
	seenSHA := map[string]bool{}
	seen := map[string]bool{} // email|date|subject
	addEarner := func(e Earner) {
		key := strings.ToLower(e.Email) + "|" + e.At.UTC().Truncate(time.Second).Format(time.RFC3339) + "|" + e.Subject
		if seenSHA[e.SHA] || (e.Email != "" && seen[key]) {
			return
		}
		seenSHA[e.SHA], seen[key] = true, true
		e.Agent = agent != nil && agent(e.RepoID, e.SHA)
		out.Earners = append(out.Earners, e)
	}
	sorted := slices.Clone(commits)
	slices.SortStableFunc(sorted, func(a, b domain.CommitLink) int { return a.CommittedAt.Compare(b.CommittedAt) })
	shas := map[string]bool{}
	for _, l := range sorted {
		if shas[l.SHA] {
			continue // linked to the ticket more than once
		}
		shas[l.SHA] = true
		if isRevertLink(l) {
			out.Reverts = append(out.Reverts, l)
			continue
		}
		out.Commits = append(out.Commits, l)
		plan := out.Repos[l.RepoID]
		if l.PRNumber != nil && !slices.Contains(plan.Pulls, *l.PRNumber) {
			plan.Pulls = append(plan.Pulls, *l.PRNumber)
		}
		switch {
		case l.MergeKind == domain.MergeKindMerge || len(l.Parents) > 1:
		case l.MergeKind == domain.MergeKindSquash:
			plan.Squashes = append(plan.Squashes, l.SHA)
			own := prCommits[PullKey{l.RepoID, deref(l.PRNumber)}]
			if len(own) == 0 { // not read: the squash's author stands in
				addEarner(Earner{RepoID: l.RepoID, SHA: l.SHA, Name: l.Author, Login: l.AuthorLogin, Email: l.AuthorEmail, At: l.CommittedAt, Subject: l.Subject})
			}
			for _, c := range own {
				if len(c.Parents) > 1 {
					continue
				}
				addEarner(Earner{RepoID: l.RepoID, SHA: strings.ToLower(c.SHA), Name: c.Author, Login: c.AuthorLogin, Email: c.AuthorEmail,
					At: c.Date, Subject: domain.Subject(c.Message)})
			}
		default:
			plan.Commits = append(plan.Commits, l.SHA)
			addEarner(Earner{RepoID: l.RepoID, SHA: l.SHA, Name: l.Author, Login: l.AuthorLogin, Email: l.AuthorEmail, At: l.CommittedAt, Subject: l.Subject})
		}
		out.Repos[l.RepoID] = plan
	}
	return out
}

func deref(p *int) int {
	if p == nil {
		return 0
	}
	return *p
}
