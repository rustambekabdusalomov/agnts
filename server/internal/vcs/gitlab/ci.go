package gitlab

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

// CIRuns lists the newest finished pipelines.
func (h *Host) CIRuns(ctx context.Context, repo domain.Repository, perPage int) ([]domain.CIRun, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		ID        int64     `json:"id"`
		SHA       string    `json:"sha"`
		Ref       string    `json:"ref"`
		Status    string    `json:"status"`
		Source    string    `json:"source"`
		UpdatedAt time.Time `json:"updated_at"`
		WebURL    string    `json:"web_url"`
	}
	if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/pipelines?scope=finished&per_page=%d", p, min(max(perPage, 1), 50)), nil, &list); err != nil {
		return nil, err
	}
	path, _ := strings.CutPrefix(p, "/projects/")
	out := make([]domain.CIRun, 0, len(list))
	for _, x := range list {
		out = append(out, domain.CIRun{Provider: "gitlab", Repo: unescape(path), RunID: x.ID, Attempt: 1, Workflow: "pipeline",
			Name: "pipeline", Branch: x.Ref, SHA: x.SHA, Event: x.Source, Conclusion: x.Status, URL: x.WebURL, Finished: x.UpdatedAt})
	}
	return out, nil
}

func unescape(s string) string { return strings.ReplaceAll(s, "%2F", "/") }

// FailedJobs lists a pipeline's failed jobs (retried ones left out).
func (h *Host) FailedJobs(ctx context.Context, repo domain.Repository, runID int64) ([]domain.CIJob, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var jobs []struct {
		ID            int64  `json:"id"`
		Name          string `json:"name"`
		Stage         string `json:"stage"`
		Status        string `json:"status"`
		AllowFailure  bool   `json:"allow_failure"`
		WebURL        string `json:"web_url"`
		FailureReason string `json:"failure_reason"`
	}
	path := fmt.Sprintf("%s/pipelines/%d/jobs?scope[]=failed&per_page=100&include_retried=false", p, runID)
	if _, err := h.call(ctx, http.MethodGet, path, nil, &jobs); err != nil {
		return nil, err
	}
	var out []domain.CIJob
	for _, j := range jobs {
		if j.Status != "failed" {
			continue
		}
		out = append(out, domain.CIJob{ID: j.ID, Name: j.Name, Stage: j.Stage, Conclusion: j.Status, AllowFailure: j.AllowFailure,
			URL: j.WebURL, FailedStep: strings.ReplaceAll(j.FailureReason, "_", " ")})
	}
	return out, nil
}

// JobLog returns the end of a job's trace.
func (h *Host) JobLog(ctx context.Context, repo domain.Repository, jobID int64) (string, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return "", err
	}
	c, ok, err := h.cfg(ctx)
	if err != nil {
		return "", err
	}
	if !ok || c.Token == "" {
		return "", fmt.Errorf("gitlab is %w", vcs.ErrNotConnected)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(c.URL, "/")+"/api/v4"+p+"/jobs/"+strconv.FormatInt(jobID, 10)+"/trace", nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("PRIVATE-TOKEN", c.Token)
	resp, err := h.hc.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return "", fmt.Errorf("gitlab job trace %d: %s: %s", jobID, resp.Status, strings.TrimSpace(string(b)))
	}
	b, err := io.ReadAll(io.LimitReader(resp.Body, 16*vcs.MaxJobLogBytes))
	if err != nil {
		return "", err
	}
	if len(b) > vcs.MaxJobLogBytes {
		b = b[len(b)-vcs.MaxJobLogBytes:]
	}
	return string(b), nil
}

// RerunFailed retries a pipeline's failed jobs.
func (h *Host) RerunFailed(ctx context.Context, repo domain.Repository, runID int64) error {
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	_, err = h.call(ctx, http.MethodPost, fmt.Sprintf("%s/pipelines/%d/retry", p, runID), nil, nil)
	return err
}

// UpsertComment posts or edits one note on a merge request.
func (h *Host) UpsertComment(ctx context.Context, repo domain.Repository, number int, id, body string) (string, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return "", err
	}
	notes := fmt.Sprintf("%s/merge_requests/%d/notes", p, number)
	var n struct {
		ID int64 `json:"id"`
	}
	if id != "" {
		status, err := h.call(ctx, http.MethodPut, notes+"/"+id, map[string]any{"body": body}, &n)
		if err == nil {
			return id, nil
		}
		if status != http.StatusNotFound {
			return "", err
		}
	}
	if _, err := h.call(ctx, http.MethodPost, notes, map[string]any{"body": body}, &n); err != nil {
		return "", err
	}
	return strconv.FormatInt(n.ID, 10), nil
}
