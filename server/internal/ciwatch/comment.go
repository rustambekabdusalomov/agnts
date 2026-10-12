package ciwatch

import (
	"context"
	"fmt"
	"strings"

	"agnts/internal/domain"
)

// commentMarker starts agnts's diagnosis comment, so people can tell it apart.
const commentMarker = "<!-- agnts:ci-diagnosis -->"

// comment posts (or updates) one diagnosis comment on someone's pull
// request for the failed jobs of a run. agnts never pushes to their branch.
func (s *Service) comment(ctx context.Context, repo domain.Repository, run domain.CIRun, pr int, fs []failure, outs []outcome) error {
	changed := false
	for _, o := range outs {
		changed = changed || o.changed
	}
	if !changed {
		return nil // this run is already in the comment
	}
	// The same failure on the default branch is not this PR's fault.
	onDefault := map[string]domain.CIFailure{}
	if gs, err := s.store.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID, Branch: repo.DefaultBranch, Statuses: statusesOpen}); err == nil {
		for _, g := range gs {
			onDefault[g.Fingerprint] = g
		}
	}
	commentID := ""
	for _, o := range outs {
		if o.f.CommentID != "" {
			commentID = o.f.CommentID
		}
	}
	if commentID == "" {
		// Another run of this PR may have posted it already.
		if gs, err := s.store.ListCIFailures(ctx, domain.CIFilter{RepoID: repo.ID, Branch: fmt.Sprintf("pr/%d", pr)}); err == nil {
			for _, g := range gs {
				if g.CommentID != "" {
					commentID = g.CommentID
					break
				}
			}
		}
	}
	id, err := s.host.UpsertComment(ctx, repo, pr, commentID, DiagnosisComment(repo, run, fs, onDefault))
	if err != nil {
		return err
	}
	for _, o := range outs {
		if o.f.CommentID == id {
			continue
		}
		if _, err := s.store.UpdateCIFailure(ctx, o.f.ID, func(f *domain.CIFailure) error { f.CommentID = id; return nil }); err != nil {
			return err
		}
	}
	return nil
}

// DiagnosisComment is the comment on someone's pull request: per failed
// job, what failed, whether it is this PR's doing, and the error.
func DiagnosisComment(repo domain.Repository, run domain.CIRun, fs []failure, onDefault map[string]domain.CIFailure) string {
	var b strings.Builder
	b.WriteString(commentMarker + "\n")
	fmt.Fprintf(&b, "**agnts looked at the failed CI run** ([%s](%s), commit `%s`)\n", run.Name, run.URL, short(run.SHA))
	for _, f := range fs {
		fmt.Fprintf(&b, "\n#### `%s`", f.job.QualifiedName())
		if f.job.FailedStep != "" {
			fmt.Fprintf(&b, ", step *%s*", f.job.FailedStep)
		}
		b.WriteString("\n\n")
		switch g, ok := onDefault[f.fingerprint]; {
		case f.infra != "":
			fmt.Fprintf(&b, "Probably not the code: the runner or the network failed (`%s`). Re-running the job should help.\n", limit(f.infra, 200))
		case ok:
			fmt.Fprintf(&b, "Not caused by this pull request: the same failure is on `%s` since `%s`.\n", repo.DefaultBranch, short(g.FirstSHA))
		default:
			fmt.Fprintf(&b, "New in this pull request: **%s**\n", f.title)
		}
		block := errorBlock(f)
		if lines := strings.Split(block, "\n"); len(lines) > 30 {
			block = strings.Join(lines[:30], "\n") + "\n…"
		}
		b.WriteString("\n<details><summary>Error</summary>\n\n```\n")
		b.WriteString(limit(block, 3000))
		b.WriteString("\n```\n</details>\n")
	}
	b.WriteString("\n<sub>This comment updates itself on later runs. Secrets in the log are redacted.</sub>\n")
	return b.String()
}
