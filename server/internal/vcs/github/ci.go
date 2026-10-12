package github

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

var _ vcs.CIHost = (*Host)(nil)

// ghRun is a workflow run as the REST API and the workflow_run webhook
// describe it.
type ghRun struct {
	ID           int64     `json:"id"`
	Name         string    `json:"name"`
	Path         string    `json:"path"`
	DisplayTitle string    `json:"display_title"`
	HeadBranch   string    `json:"head_branch"`
	HeadSHA      string    `json:"head_sha"`
	Event        string    `json:"event"`
	Status       string    `json:"status"`
	Conclusion   string    `json:"conclusion"`
	RunAttempt   int       `json:"run_attempt"`
	HTMLURL      string    `json:"html_url"`
	UpdatedAt    time.Time `json:"updated_at"`
	PullRequests []struct {
		Number int `json:"number"`
	} `json:"pull_requests"`
	HeadCommit struct {
		Message string `json:"message"`
		Author  struct {
			Name string `json:"name"`
		} `json:"author"`
	} `json:"head_commit"`
	Repository struct {
		FullName string `json:"full_name"`
	} `json:"repository"`
	HeadRepository struct {
		FullName string `json:"full_name"`
	} `json:"head_repository"`
}

// RunOf turns a workflow run into a CI run.
func RunOf(r ghRun) domain.CIRun {
	out := domain.CIRun{Provider: "github", Repo: r.Repository.FullName, RunID: r.ID, Attempt: max(r.RunAttempt, 1),
		Workflow: r.Path, Name: r.Name, Branch: r.HeadBranch, SHA: r.HeadSHA, Event: r.Event, Conclusion: r.Conclusion,
		URL: r.HTMLURL, Author: r.HeadCommit.Author.Name, Message: firstLine(r.HeadCommit.Message), Finished: r.UpdatedAt}
	if out.Workflow == "" {
		out.Workflow = r.Name
	}
	if i := strings.LastIndex(out.Workflow, "/"); i >= 0 {
		out.Workflow = out.Workflow[i+1:] // .github/workflows/ci.yml → ci.yml
	}
	if out.Message == "" {
		out.Message = r.DisplayTitle
	}
	out.Fork = r.HeadRepository.FullName != "" && r.Repository.FullName != "" && !strings.EqualFold(r.HeadRepository.FullName, r.Repository.FullName)
	for _, p := range r.PullRequests {
		out.PRNumbers = append(out.PRNumbers, p.Number)
	}
	return out
}

// CIRuns lists the newest completed workflow runs.
func (h *Host) CIRuns(ctx context.Context, repo domain.Repository, perPage int) ([]domain.CIRun, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var runs struct {
		Runs []ghRun `json:"workflow_runs"`
	}
	path := fmt.Sprintf("%s/actions/runs?status=completed&per_page=%d", base, min(max(perPage, 1), 50))
	if status, err := h.call(ctx, http.MethodGet, path, nil, &runs); err != nil {
		return nil, needs(status, err, "Actions: Read")
	}
	out := make([]domain.CIRun, 0, len(runs.Runs))
	for _, r := range runs.Runs {
		out = append(out, RunOf(r))
	}
	return out, nil
}

// FailedJobs lists the failed jobs of a run's latest attempt, with the
// failed step and the check run's annotations.
func (h *Host) FailedJobs(ctx context.Context, repo domain.Repository, runID int64) ([]domain.CIJob, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var jobs struct {
		Jobs []struct {
			ID         int64  `json:"id"`
			Name       string `json:"name"`
			Conclusion string `json:"conclusion"`
			HTMLURL    string `json:"html_url"`
			Steps      []struct {
				Name       string `json:"name"`
				Conclusion string `json:"conclusion"`
			} `json:"steps"`
		} `json:"jobs"`
	}
	path := fmt.Sprintf("%s/actions/runs/%d/jobs?filter=latest&per_page=100", base, runID)
	if status, err := h.call(ctx, http.MethodGet, path, nil, &jobs); err != nil {
		return nil, needs(status, err, "Actions: Read")
	}
	var out []domain.CIJob
	for _, j := range jobs.Jobs {
		if j.Conclusion != "failure" && j.Conclusion != "timed_out" {
			continue
		}
		job := domain.CIJob{ID: j.ID, Name: j.Name, Conclusion: j.Conclusion, URL: j.HTMLURL}
		for _, s := range j.Steps {
			if s.Conclusion == "failure" {
				job.FailedStep = s.Name
				break
			}
		}
		var anns []struct {
			Path      string `json:"path"`
			StartLine int    `json:"start_line"`
			Level     string `json:"annotation_level"`
			Message   string `json:"message"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/check-runs/%d/annotations?per_page=20", base, j.ID), nil, &anns); err == nil {
			for _, a := range anns {
				if a.Level != "failure" || a.Path == ".github" {
					continue
				}
				job.Annotations = append(job.Annotations, a.Path+":"+strconv.Itoa(a.StartLine)+": "+firstLine(a.Message))
			}
		}
		out = append(out, job)
	}
	return out, nil
}

// JobLog downloads the end of a job's log. GitHub answers with a redirect
// to a signed blob URL; the client drops the token on the other host.
func (h *Host) JobLog(ctx context.Context, repo domain.Repository, jobID int64) (string, error) {
	base, err := h.base(repo)
	if err != nil {
		return "", err
	}
	tok, err := h.token(ctx)
	if err != nil {
		return "", err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, fmt.Sprintf("%s%s/actions/jobs/%d/logs", h.api, base, jobID), nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+tok)
	req.Header.Set("Accept", "application/vnd.github+json")
	req.Header.Set("X-GitHub-Api-Version", "2022-11-28")
	resp, err := h.hc.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return "", needs(resp.StatusCode, fmt.Errorf("github job log %d: %s: %s", jobID, resp.Status, strings.TrimSpace(string(b))), "Actions: Read")
	}
	return tailOf(resp.Body, vcs.MaxJobLogBytes)
}

// tailOf reads r and keeps its last n bytes: a failed job's error is at
// the end.
func tailOf(r io.Reader, n int) (string, error) {
	buf := make([]byte, 0, 64<<10)
	chunk := make([]byte, 32<<10)
	for {
		k, err := r.Read(chunk)
		buf = append(buf, chunk[:k]...)
		if len(buf) > 2*n {
			buf = append(buf[:0], buf[len(buf)-n:]...)
		}
		if err == io.EOF {
			break
		}
		if err != nil {
			return "", err
		}
	}
	if len(buf) > n {
		buf = buf[len(buf)-n:]
	}
	return string(buf), nil
}

// RerunFailed re-runs the failed jobs of a run.
func (h *Host) RerunFailed(ctx context.Context, repo domain.Repository, runID int64) error {
	base, err := h.base(repo)
	if err != nil {
		return err
	}
	status, err := h.call(ctx, http.MethodPost, fmt.Sprintf("%s/actions/runs/%d/rerun-failed-jobs", base, runID), map[string]any{}, nil)
	return needs(status, err, "Actions: Read and write")
}

// UpsertComment posts or edits one comment on a pull request.
func (h *Host) UpsertComment(ctx context.Context, repo domain.Repository, number int, id, body string) (string, error) {
	base, err := h.base(repo)
	if err != nil {
		return "", err
	}
	var c struct {
		ID int64 `json:"id"`
	}
	if id != "" {
		status, err := h.call(ctx, http.MethodPatch, base+"/issues/comments/"+id, map[string]any{"body": body}, &c)
		if err == nil {
			return id, nil
		}
		if status != http.StatusNotFound {
			return "", needs(status, err, "Pull requests: Read and write")
		}
		// Deleted by someone: post a new one.
	}
	status, err := h.call(ctx, http.MethodPost, fmt.Sprintf("%s/issues/%d/comments", base, number), map[string]any{"body": body}, &c)
	if err != nil {
		return "", needs(status, err, "Pull requests: Read and write")
	}
	return strconv.FormatInt(c.ID, 10), nil
}
