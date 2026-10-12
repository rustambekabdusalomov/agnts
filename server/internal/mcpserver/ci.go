package mcpserver

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
)

// CIInput narrows list_ci_failures.
type CIInput struct {
	Repository string `json:"repository,omitempty" jsonschema:"repository name; all repositories when empty"`
	Status     string `json:"status,omitempty" jsonschema:"red (still needs attention, the default), flaky, infra or all"`
}

// CIBrief is a CI failure group in lists.
type CIBrief struct {
	ID         int64  `json:"id"`
	Repository string `json:"repository"`
	Branch     string `json:"branch"`
	Workflow   string `json:"workflow"`
	Job        string `json:"job"`
	Title      string `json:"title"`
	Status     string `json:"status"`
	Class      string `json:"class,omitempty"`
	Count      int    `json:"count"`
	FirstSHA   string `json:"first_failing_commit"`
	LastSeen   string `json:"last_seen"`
	LastRunURL string `json:"last_run_url,omitempty"`
	Ticket     string `json:"ticket,omitempty"`
}

// CIList is list_ci_failures's output.
type CIList struct {
	Failures []CIBrief `json:"failures"`
}

func ciBrief(f domain.CIFailure) CIBrief {
	b := CIBrief{ID: f.ID, Repository: f.RepoName, Branch: f.Branch, Workflow: f.Workflow, Job: f.Job, Title: f.Title,
		Status: string(f.Status), Class: f.Class, Count: f.Count, FirstSHA: f.FirstSHA, LastSeen: f.LastSeenAt.UTC().Format(time.RFC3339),
		Ticket: f.TicketKey}
	if last, ok := f.LastRun(); ok {
		b.LastRunURL = last.URL
	}
	return b
}

func (t *tools) listCIFailures(ctx context.Context, _ *mcp.CallToolRequest, in CIInput) (*mcp.CallToolResult, CIList, error) {
	if t.d.CI == nil {
		return nil, CIList{}, errors.New("CI watching is not available")
	}
	f := domain.CIFilter{}
	switch in.Status {
	case "", "red":
		f.Statuses = []domain.CIStatus{domain.CIOpen, domain.CIFixing, domain.CIRegression, domain.CITriage}
	case "flaky":
		f.Statuses = []domain.CIStatus{domain.CIFlaky}
	case "infra":
		f.Statuses = []domain.CIStatus{domain.CIInfra}
	case "all":
	default:
		return nil, CIList{}, errors.New("status must be red, flaky, infra or all")
	}
	if name := strings.TrimSpace(in.Repository); name != "" {
		r, err := t.d.Store.RepositoryByName(ctx, name)
		if err != nil {
			return nil, CIList{}, errors.New("no repository named " + name)
		}
		f.RepoID = r.ID
	}
	fs, err := t.d.CI.List(ctx, f)
	if err != nil {
		return nil, CIList{}, err
	}
	out := CIList{Failures: []CIBrief{}}
	for _, x := range fs {
		out.Failures = append(out.Failures, ciBrief(x))
	}
	return nil, out, nil
}

// CIFailureInput names one failure group.
type CIFailureInput struct {
	ID int64 `json:"id" jsonschema:"the failure id from list_ci_failures"`
}

// CIDetail is get_ci_failure's output.
type CIDetail struct {
	CIBrief
	Log         string   `json:"log_excerpt"`
	Occurrences []string `json:"occurrences"`
}

func (t *tools) getCIFailure(ctx context.Context, _ *mcp.CallToolRequest, in CIFailureInput) (*mcp.CallToolResult, CIDetail, error) {
	if t.d.CI == nil {
		return nil, CIDetail{}, errors.New("CI watching is not available")
	}
	f, err := t.d.CI.Get(ctx, in.ID)
	if err != nil {
		return nil, CIDetail{}, err
	}
	out := CIDetail{CIBrief: ciBrief(f), Log: f.Sample, Occurrences: []string{}}
	for _, o := range f.Occurrences {
		line := o.At.UTC().Format(time.RFC3339) + " " + o.SHA + " " + o.Job + " " + o.URL
		if o.Flaky {
			line += " (passed on re-run)"
		}
		out.Occurrences = append(out.Occurrences, line)
	}
	return nil, out, nil
}
