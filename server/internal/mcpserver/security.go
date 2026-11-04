package mcpserver

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
)

// SecurityFindings reads the security findings of the workspace's
// repositories (postgres.Security).
type SecurityFindings interface {
	SecurityFindings(ctx context.Context, flt domain.SecFindingFilter) ([]domain.SecurityFinding, error)
	SecurityFinding(ctx context.Context, id int64) (domain.SecurityFinding, error)
}

// securityListMax is how many findings list_security_findings returns.
const securityListMax = 50

// SecurityFindingsInput narrows list_security_findings.
type SecurityFindingsInput struct {
	Repository string `json:"repository,omitempty" jsonschema:"repository name; all repositories when empty"`
	Status     string `json:"status,omitempty" jsonschema:"active (open, being fixed or verified, reopened: the default), fixed, dismissed or all"`
	Severity   string `json:"severity,omitempty" jsonschema:"the lowest severity to list: critical, high, medium, low or info (all when empty)"`
}

// SecurityFindingBrief is a security finding in lists.
type SecurityFindingBrief struct {
	ID         int64  `json:"id"`
	Repository string `json:"repository"`
	Severity   string `json:"severity"`
	Confidence string `json:"confidence,omitempty"`
	Category   string `json:"category"`
	Source     string `json:"source" jsonschema:"what found it: code, config, dependency, secret, history (a secret in git history) or agent"`
	Title      string `json:"title"`
	Status     string `json:"status"`
	Location   string `json:"location,omitempty" jsonschema:"file:line, or the route"`
	Function   string `json:"function,omitempty"`
	Package    string `json:"package,omitempty" jsonschema:"for a dependency: package@version, and the version that fixes it"`
	Ticket     string `json:"ticket,omitempty" jsonschema:"the ticket fixing it"`
	FirstSeen  string `json:"first_seen"`
	LastSeen   string `json:"last_seen"`
}

// SecurityFindingList is list_security_findings's output.
type SecurityFindingList struct {
	Findings []SecurityFindingBrief `json:"findings"`
	// More is how many matching findings were left out.
	More int `json:"more,omitempty"`
}

func securityBrief(f domain.SecurityFinding) SecurityFindingBrief {
	b := SecurityFindingBrief{ID: f.ID, Repository: f.RepoName, Severity: string(f.Severity), Confidence: string(f.Data.Confidence),
		Category: f.Category, Source: string(f.Source), Title: f.Data.Title, Status: string(f.Status), Function: f.Symbol, Ticket: f.TicketKey,
		FirstSeen: f.FirstSeen.UTC().Format(time.RFC3339), LastSeen: f.LastSeen.UTC().Format(time.RFC3339)}
	switch l := f.Data.Location; {
	case l.File != "" && l.Line > 0:
		b.Location = fmt.Sprintf("%s:%d", l.File, l.Line)
	case l.File != "":
		b.Location = l.File
	default:
		b.Location = l.URL
	}
	if f.Data.Package != "" {
		b.Package = f.Data.Package + "@" + f.Data.Version
		if f.Data.FixedIn != "" {
			b.Package += ", fixed in " + f.Data.FixedIn
		}
	}
	return b
}

func (t *tools) listSecurityFindings(ctx context.Context, _ *mcp.CallToolRequest, in SecurityFindingsInput) (*mcp.CallToolResult, SecurityFindingList, error) {
	if t.d.Security == nil {
		return nil, SecurityFindingList{}, errors.New("security testing is not available")
	}
	var q domain.SecFindingFilter
	switch s := strings.TrimSpace(in.Status); s {
	case "", "active":
		q.Active = true
	case "fixed", "dismissed":
		q.Status = domain.SecStatus(s)
	case "all":
	default:
		return nil, SecurityFindingList{}, errors.New("status must be active, fixed, dismissed or all")
	}
	var floor domain.SecSeverity
	if s := strings.ToLower(strings.TrimSpace(in.Severity)); s != "" {
		floor = domain.SecSeverity(s)
		if !floor.Valid() {
			return nil, SecurityFindingList{}, errors.New("severity must be critical, high, medium, low or info")
		}
	}
	if name := strings.TrimSpace(in.Repository); name != "" {
		r, err := t.d.Store.RepositoryByName(ctx, name)
		if err != nil {
			return nil, SecurityFindingList{}, errors.New("no repository named " + name)
		}
		q.RepoID = r.ID
	}
	fs, err := t.d.Security.SecurityFindings(ctx, q)
	if err != nil {
		return nil, SecurityFindingList{}, err
	}
	domain.SortFindings(fs)
	out := SecurityFindingList{Findings: []SecurityFindingBrief{}}
	for _, f := range fs {
		if floor != "" && f.Severity.Rank() < floor.Rank() {
			continue
		}
		if len(out.Findings) == securityListMax {
			out.More++
			continue
		}
		out.Findings = append(out.Findings, securityBrief(f))
	}
	return nil, out, nil
}

// SecurityFindingInput names one finding.
type SecurityFindingInput struct {
	ID int64 `json:"id" jsonschema:"the finding id from list_security_findings"`
}

// SecurityFindingDetail is get_security_finding's output.
type SecurityFindingDetail struct {
	SecurityFindingBrief
	CWE         string   `json:"cwe,omitempty"`
	OWASP       string   `json:"owasp,omitempty"`
	Rules       []string `json:"rules,omitempty"`
	Evidence    string   `json:"evidence,omitempty"`
	Impact      string   `json:"impact,omitempty"`
	Fix         string   `json:"fix,omitempty"`
	Patch       string   `json:"patch,omitempty"`
	Advisories  []string `json:"advisories,omitempty"`
	References  []string `json:"references,omitempty"`
	SecretMask  string   `json:"masked_secret,omitempty" jsonschema:"a masked secret: the value itself is never stored"`
	Commit      string   `json:"commit,omitempty" jsonschema:"for a secret in git history: the commit"`
	Note        string   `json:"note,omitempty" jsonschema:"what the last recheck said"`
	Dismissed   string   `json:"dismissed,omitempty" jsonschema:"why it was dismissed: false_positive, accepted_risk or wont_fix, and the note"`
	LastChecked string   `json:"last_checked"`
}

func (t *tools) getSecurityFinding(ctx context.Context, _ *mcp.CallToolRequest, in SecurityFindingInput) (*mcp.CallToolResult, SecurityFindingDetail, error) {
	if t.d.Security == nil {
		return nil, SecurityFindingDetail{}, errors.New("security testing is not available")
	}
	f, err := t.d.Security.SecurityFinding(ctx, in.ID)
	if err != nil {
		return nil, SecurityFindingDetail{}, err
	}
	d := f.Data
	// Stored evidence and patches are masked already; mask again so a
	// secret that slipped through never reaches a chat.
	out := SecurityFindingDetail{SecurityFindingBrief: securityBrief(f), CWE: d.CWE, OWASP: d.OWASP, Rules: d.Rules,
		Evidence: domain.MaskSecret(d.Evidence), Impact: d.Impact, Fix: domain.MaskSecret(d.Fix.Explanation), Patch: domain.MaskSecret(d.Fix.Patch),
		Advisories: d.Advisories, References: d.References, SecretMask: d.SecretMask, Commit: d.Commit, Note: d.Note,
		LastChecked: f.LastChecked.UTC().Format(time.RFC3339)}
	if f.Status == domain.SecDismissed {
		out.Dismissed = strings.TrimSpace(f.DismissReason + " " + f.DismissNote)
	}
	return nil, out, nil
}
