package mcpserver

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
)

// LogFindingsInput narrows list_log_findings.
type LogFindingsInput struct {
	Category   string `json:"category,omitempty" jsonschema:"error or security; both when empty"`
	Repository string `json:"repository,omitempty" jsonschema:"repository name; all repositories when empty"`
	Status     string `json:"status,omitempty" jsonschema:"active (needs attention, the default), fixed, muted or all"`
}

// LogFindingBrief is a log finding in lists.
type LogFindingBrief struct {
	ID           int64    `json:"id"`
	Service      string   `json:"service"`
	Repositories []string `json:"repositories"`
	Category     string   `json:"category"`
	Class        string   `json:"class"`
	Severity     string   `json:"severity"`
	Title        string   `json:"title"`
	Status       string   `json:"status"`
	Count        int64    `json:"count"`
	FirstSeen    string   `json:"first_seen"`
	LastSeen     string   `json:"last_seen"`
	Remediation  string   `json:"remediation,omitempty"`
	Reason       string   `json:"reason,omitempty"`
	MaskedSecret string   `json:"masked_secret,omitempty"`
	Ticket       string   `json:"ticket,omitempty"`
}

// LogFindingList is list_log_findings's output.
type LogFindingList struct {
	Findings []LogFindingBrief `json:"findings"`
}

func logBrief(f domain.LogFinding) LogFindingBrief {
	repos := f.RepoNames
	if repos == nil {
		repos = []string{}
	}
	return LogFindingBrief{ID: f.ID, Service: f.Service, Repositories: repos, Category: string(f.Category), Class: string(f.Class),
		Severity: string(f.Severity), Title: f.Title, Status: string(f.Status), Count: f.Count,
		FirstSeen: f.FirstSeenAt.UTC().Format(time.RFC3339), LastSeen: f.LastSeenAt.UTC().Format(time.RFC3339),
		Remediation: f.Remediation, Reason: f.Reason, MaskedSecret: f.SecretMask, Ticket: f.TicketKey}
}

func (t *tools) listLogFindings(ctx context.Context, _ *mcp.CallToolRequest, in LogFindingsInput) (*mcp.CallToolResult, LogFindingList, error) {
	if t.d.Logs == nil {
		return nil, LogFindingList{}, errors.New("the log watcher is not available")
	}
	q := domain.LogFindingFilter{Limit: 100}
	switch in.Category {
	case "", "error", "security":
		q.Category = domain.LogCategory(in.Category)
	default:
		return nil, LogFindingList{}, errors.New("category must be error or security")
	}
	switch in.Status {
	case "", "active":
		q.Active = true
	case "fixed", "muted":
		q.Status = domain.LogStatus(in.Status)
	case "all":
	default:
		return nil, LogFindingList{}, errors.New("status must be active, fixed, muted or all")
	}
	if name := strings.TrimSpace(in.Repository); name != "" {
		r, err := t.d.Store.RepositoryByName(ctx, name)
		if err != nil {
			return nil, LogFindingList{}, errors.New("no repository named " + name)
		}
		q.RepoID = r.ID
	}
	fs, err := t.d.Logs.Findings(ctx, q)
	if err != nil {
		return nil, LogFindingList{}, err
	}
	out := LogFindingList{Findings: []LogFindingBrief{}}
	for _, f := range fs {
		out.Findings = append(out.Findings, logBrief(f))
	}
	return nil, out, nil
}

// LogFindingInput names one finding.
type LogFindingInput struct {
	ID int64 `json:"id" jsonschema:"the finding id from list_log_findings"`
}

// LogFindingDetail is get_log_finding's output.
type LogFindingDetail struct {
	LogFindingBrief
	Excerpt     string   `json:"log_excerpt"`
	Occurrences []string `json:"occurrences"`
}

func (t *tools) getLogFinding(ctx context.Context, _ *mcp.CallToolRequest, in LogFindingInput) (*mcp.CallToolResult, LogFindingDetail, error) {
	if t.d.Logs == nil {
		return nil, LogFindingDetail{}, errors.New("the log watcher is not available")
	}
	f, err := t.d.Logs.Finding(ctx, in.ID)
	if err != nil {
		return nil, LogFindingDetail{}, err
	}
	out := LogFindingDetail{LogFindingBrief: logBrief(f), Excerpt: f.Sample, Occurrences: []string{}}
	for _, o := range f.Occurrences {
		line := o.At.UTC().Format(time.RFC3339) + " " + o.Service
		if o.Revision != "" {
			line += " " + o.Revision
		}
		out.Occurrences = append(out.Occurrences, line+" ×"+strconv.Itoa(o.Count))
	}
	return nil, out, nil
}
