package postgres

import (
	"context"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// CommitPulls implements commitlink.MergeStore.
func (s *Agent) CommitPulls(ctx context.Context, repoID int64, shas []string) (map[string]domain.CommitPull, error) {
	out := map[string]domain.CommitPull{}
	if len(shas) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT sha, coalesce(pr_number, 0), pr_title, head_branch, squash FROM commit_pulls
		WHERE repo_id = $1 AND sha = ANY($2)`, repoID, lowerAll(shas))
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var sha string
		var cp domain.CommitPull
		if err := rows.Scan(&sha, &cp.Number, &cp.Title, &cp.HeadBranch, &cp.Squash); err != nil {
			return nil, err
		}
		out[sha] = cp
	}
	return out, rows.Err()
}

// SaveCommitPull implements commitlink.MergeStore. The workspace is the
// repository's: pushes arrive in a system scope.
func (s *Agent) SaveCommitPull(ctx context.Context, repoID int64, sha string, cp domain.CommitPull) error {
	var pr *int
	if cp.Number > 0 {
		pr = &cp.Number
	}
	_, err := s.db.Exec(ctx, `INSERT INTO commit_pulls (workspace_id, repo_id, sha, pr_number, pr_title, head_branch, squash)
		SELECT workspace_id, id, $2, $3, $4, $5, $6 FROM repositories WHERE id = $1
		ON CONFLICT (repo_id, sha) DO UPDATE SET pr_number = EXCLUDED.pr_number, pr_title = EXCLUDED.pr_title,
			head_branch = EXCLUDED.head_branch, squash = EXCLUDED.squash, looked_up_at = now()`,
		repoID, strings.ToLower(sha), pr, cp.Title, cp.HeadBranch, cp.Squash)
	return err
}

// SavePullCommits implements commitlink.MergeStore.
func (s *Agent) SavePullCommits(ctx context.Context, repoID int64, number int, commits []domain.PushedCommit) error {
	if len(commits) == 0 {
		return nil
	}
	b := &pgx.Batch{}
	for _, c := range commits {
		at := c.Date
		if at.IsZero() {
			at = time.Now()
		}
		parents := lowerAll(c.Parents)
		b.Queue(`INSERT INTO pull_request_commits (workspace_id, repo_id, pr_number, sha, author, author_email, author_login, authored_at, parents, subject)
			SELECT workspace_id, id, $2, $3, $4, $5, $6, $7, $8, $9 FROM repositories WHERE id = $1
			ON CONFLICT (repo_id, pr_number, sha) DO NOTHING`,
			repoID, number, strings.ToLower(c.SHA), c.Author, c.AuthorEmail, c.AuthorLogin, at, parents, domain.Subject(c.Message))
	}
	return s.db.SendBatch(ctx, b).Close()
}

// PullCommitsOf returns the stored commits of a squashed pull request,
// oldest first.
func (s *Agent) PullCommitsOf(ctx context.Context, repoID int64, number int) ([]domain.PushedCommit, error) {
	rows, err := s.db.Query(ctx, `SELECT sha, author, author_email, author_login, authored_at, parents, subject FROM pull_request_commits
		WHERE repo_id = $1 AND pr_number = $2 ORDER BY authored_at, sha`, repoID, number)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.PushedCommit
	for rows.Next() {
		var c domain.PushedCommit
		if err := rows.Scan(&c.SHA, &c.Author, &c.AuthorEmail, &c.AuthorLogin, &c.Date, &c.Parents, &c.Message); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// MarkOnDefault implements commitlink.MergeStore.
func (s *Agent) MarkOnDefault(ctx context.Context, repoID int64, facts []domain.DefaultCommit) error {
	if len(facts) == 0 {
		return nil
	}
	b := &pgx.Batch{}
	for _, f := range facts {
		b.Queue(`UPDATE ticket_commits SET
				on_default_at = LEAST(on_default_at, $3),
				merge_kind = CASE WHEN $4 <> '' THEN $4 ELSE merge_kind END,
				pr_number = coalesce($5, pr_number),
				reverts = CASE WHEN $6 <> '' THEN $6 ELSE reverts END,
				author_email = CASE WHEN $7 <> '' THEN $7 ELSE author_email END,
				parents = CASE WHEN cardinality($8::text[]) > 0 THEN $8 ELSE parents END
			WHERE repo_id = $1 AND sha = $2`,
			repoID, strings.ToLower(f.SHA), f.At, f.MergeKind, f.PRNumber, f.Reverts, f.AuthorEmail, lowerAll(f.Parents))
	}
	return s.db.SendBatch(ctx, b).Close()
}

// RecordAgentCommits stores shas agnts made in a repository for a ticket
// (0: none known); a sha it has already keeps its ticket.
func (s *Agent) RecordAgentCommits(ctx context.Context, repoID, ticketID int64, shas []string) error {
	if len(shas) == 0 {
		return nil
	}
	var tid *int64
	if ticketID > 0 {
		tid = &ticketID
	}
	_, err := s.db.Exec(ctx, `INSERT INTO agent_commits (workspace_id, repo_id, sha, ticket_id)
		SELECT r.workspace_id, r.id, x, $3 FROM repositories r, unnest($2::text[]) x WHERE r.id = $1
		ON CONFLICT (repo_id, sha) DO UPDATE SET ticket_id = coalesce(agent_commits.ticket_id, EXCLUDED.ticket_id)`,
		repoID, lowerAll(shas), tid)
	return err
}

// AgentCommitsAmong returns which of shas (in a repository) agnts made.
func (s *Agent) AgentCommitsAmong(ctx context.Context, repoID int64, shas []string) (map[string]bool, error) {
	out := map[string]bool{}
	if len(shas) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT sha FROM agent_commits WHERE repo_id = $1 AND sha = ANY($2)`, repoID, lowerAll(shas))
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var sha string
		if err := rows.Scan(&sha); err != nil {
			return nil, err
		}
		out[sha] = true
	}
	return out, rows.Err()
}

// SetTrackerResolution records how a ticket's tracker issue is resolved:
// done (at, with the resolution's name) or not done (nil at). The
// delivery trigger does the rest.
func (s *Agent) SetTrackerResolution(ctx context.Context, source domain.TicketSource, key string, doneAt *time.Time, resolution string) error {
	_, err := s.db.Exec(ctx, `UPDATE tickets SET tracker_done_at = CASE WHEN $3::timestamptz IS NULL THEN NULL ELSE coalesce(tracker_done_at, $3) END,
			tracker_resolution = $4
		WHERE key = $1 AND source = $2
		  AND (tracker_done_at IS DISTINCT FROM CASE WHEN $3::timestamptz IS NULL THEN NULL ELSE coalesce(tracker_done_at, $3) END
		       OR tracker_resolution <> $4)`,
		key, string(source), doneAt, resolution)
	return err
}

func lowerAll(xs []string) []string {
	out := make([]string, len(xs))
	for i, x := range xs {
		out[i] = strings.ToLower(x)
	}
	return out
}
