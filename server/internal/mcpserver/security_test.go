package mcpserver_test

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
	"agnts/internal/mcpserver"
)

type fakeSecurity struct{ fs []domain.SecurityFinding }

func (f *fakeSecurity) SecurityFindings(_ context.Context, q domain.SecFindingFilter) ([]domain.SecurityFinding, error) {
	var out []domain.SecurityFinding
	for _, x := range f.fs {
		if (q.RepoID == 0 || x.RepoID == q.RepoID) && (!q.Active || x.Status.Active()) && (q.Status == "" || x.Status == q.Status) {
			out = append(out, x)
		}
	}
	return out, nil
}

func (f *fakeSecurity) SecurityFinding(_ context.Context, id int64) (domain.SecurityFinding, error) {
	for _, x := range f.fs {
		if x.ID == id {
			return x, nil
		}
	}
	return domain.SecurityFinding{}, domain.ErrNotFound
}

func TestSecurityTools(t *testing.T) {
	d := testDeps(t)
	repo, err := d.Store.RepositoryByName(testCtx, "api")
	if err != nil {
		t.Fatal(err)
	}
	now := time.Now()
	d.Security = &fakeSecurity{fs: []domain.SecurityFinding{
		{ID: 1, RepoID: repo.ID, RepoName: "api", Severity: domain.SecMedium, Category: "dependency", Source: domain.SecFromDependency, Status: domain.SecOpen,
			Data:      domain.SecFindingData{Title: "lodash prototype pollution", Package: "lodash", Version: "4.17.20", FixedIn: "4.17.21", Location: domain.SecLocation{File: "package-lock.json"}},
			FirstSeen: now, LastSeen: now},
		{ID: 2, RepoID: repo.ID, RepoName: "api", Severity: domain.SecCritical, Category: "injection", Source: domain.SecFromCode, Status: domain.SecFixing, TicketKey: "SEC-1",
			Symbol: "Repo.Search", Data: domain.SecFindingData{Title: "SQL injection in search", CWE: "CWE-89", Confidence: domain.SecConfirmed,
				Location: domain.SecLocation{File: "repo.go", Line: 50}, Evidence: "token=ghp_abcdefghijklmnopqrstuvwxyz0123456789 in the query",
				Fix: domain.SecFix{Explanation: "Pass q as $1."}}, FirstSeen: now, LastSeen: now},
		{ID: 3, RepoID: repo.ID, RepoName: "api", Severity: domain.SecHigh, Category: "secret", Source: domain.SecFromSecret, Status: domain.SecDismissed,
			DismissReason: "false_positive", DismissNote: "example key", Data: domain.SecFindingData{Title: "AWS key", SecretMask: "AKIA************"},
			FirstSeen: now, LastSeen: now},
	}}
	srv := mcpserver.NewServer(d, "test")
	st, ct := mcp.NewInMemoryTransports()
	if _, err := srv.Connect(testCtx, st, nil); err != nil {
		t.Fatal(err)
	}
	cs, err := mcp.NewClient(&mcp.Implementation{Name: "test"}, nil).Connect(testCtx, ct, nil)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = cs.Close() }()

	list, _ := cs.ListTools(context.Background(), nil)
	ro := 0
	for _, tl := range list.Tools {
		if (tl.Name == "list_security_findings" || tl.Name == "get_security_finding") && tl.Annotations != nil && tl.Annotations.ReadOnlyHint {
			ro++
		}
	}
	if ro != 2 {
		t.Fatal("the security tools should exist and be read-only")
	}

	// Active by default, worst first.
	out, isErr := call(t, cs, "list_security_findings", map[string]any{})
	fs, _ := out["findings"].([]any)
	if isErr || len(fs) != 2 {
		t.Fatalf("active: %v", out)
	}
	worst := fs[0].(map[string]any)
	if worst["id"] != float64(2) || worst["location"] != "repo.go:50" || worst["ticket"] != "SEC-1" || worst["function"] != "Repo.Search" {
		t.Fatalf("worst first: %v", worst)
	}
	if dep := fs[1].(map[string]any); dep["package"] != "lodash@4.17.20, fixed in 4.17.21" {
		t.Fatalf("dependency: %v", dep)
	}
	// A severity floor, a repository, and the dismissed ones.
	if out, _ := call(t, cs, "list_security_findings", map[string]any{"severity": "high", "repository": "api"}); len(out["findings"].([]any)) != 1 {
		t.Fatalf("high and above: %v", out)
	}
	if out, _ := call(t, cs, "list_security_findings", map[string]any{"status": "dismissed"}); len(out["findings"].([]any)) != 1 {
		t.Fatalf("dismissed: %v", out)
	}
	if _, isErr := call(t, cs, "list_security_findings", map[string]any{"severity": "scary"}); !isErr {
		t.Fatal("an unknown severity is refused")
	}
	if _, isErr := call(t, cs, "list_security_findings", map[string]any{"repository": "nope"}); !isErr {
		t.Fatal("an unknown repository is refused")
	}

	// One finding: evidence and fix, a secret never in the clear.
	one, isErr := call(t, cs, "get_security_finding", map[string]any{"id": 2})
	if isErr || one["fix"] != "Pass q as $1." || one["cwe"] != "CWE-89" {
		t.Fatalf("finding: %v", one)
	}
	if ev, _ := one["evidence"].(string); strings.Contains(ev, "ghp_abcdefghijklmnopqrstuvwxyz0123456789") {
		t.Fatalf("a secret reached the tool's output: %q", ev)
	}
	if dis, _ := call(t, cs, "get_security_finding", map[string]any{"id": 3}); dis["dismissed"] != "false_positive example key" || dis["masked_secret"] != "AKIA************" {
		t.Fatalf("dismissed finding: %v", dis)
	}
	if _, isErr := call(t, cs, "get_security_finding", map[string]any{"id": 99}); !isErr {
		t.Fatal("an unknown finding is an error")
	}
}
