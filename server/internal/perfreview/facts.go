package perfreview

import (
	"path"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// Risky areas a diff may touch.
const (
	RiskConcurrency = "concurrency"
	RiskAuth        = "auth"
	RiskMoney       = "money"
	RiskBackfill    = "migration with backfill"
)

// Facts are what the code computes about a delivery's filtered diff.
type Facts struct {
	ChangedLines int      `json:"changedLines"` // added plus deleted
	Added        int      `json:"added"`
	Deleted      int      `json:"deleted"`
	Files        int      `json:"files"`
	Packages     int      `json:"packages"` // distinct directories
	NewFiles     int      `json:"newFiles"`
	NewLines     int      `json:"newLines"`  // lines added in new files: new logic
	TestFiles    int      `json:"testFiles"` // test files changed
	TestLines    int      `json:"testLines"` // lines added to tests
	RiskyAreas   []string `json:"riskyAreas"`
	Repositories int      `json:"repositories"`
	Dropped      []string `json:"dropped,omitempty"` // noise left out
}

// Risky reports whether a risky area is touched.
func (f Facts) Risky() bool { return len(f.RiskyAreas) > 0 }

var (
	concurrencyRe = regexp.MustCompile(`\bgo func\b|\bgo [a-zA-Z_.]+\(|\bsync\.|\batomic\.|\bchan\b|\bMutex\b|\bselect \{|\bWaitGroup\b|` +
		`\bsynchronized\b|\bThread\(|\bthreading\.|\basyncio\.(gather|Lock|Semaphore)|\bPromise\.all\b|\bFOR UPDATE\b|\bpg_advisory|\bSemaphore\b|\bLock\(\)`)
	backfillRe = regexp.MustCompile(`(?i)^\s*(UPDATE\s+\w+|INSERT\s+INTO\s+\w+[^;]*\bSELECT\b|INSERT\s+INTO\s+\w+\s*\([^)]*\)\s*SELECT\b)`)
	authPathRe = regexp.MustCompile(`(?i)(^|/)(auth|oauth|login|session|sessions|password|passwords|permissions?|rbac|acl|jwt|tokens?|guard|crypto|secret|secrets)([/._-]|$)`)
	moneyPath  = regexp.MustCompile(`(?i)(^|/)(billing|payments?|credits?|invoices?|pricing|prices?|money|ledger|wallet|checkout|subscriptions?|payme|stripe|click)([/._-]|$)`)
)

// isTest reports whether a path is a test.
func isTest(p string) bool {
	base := path.Base(p)
	return strings.HasSuffix(base, "_test.go") || strings.Contains(base, ".test.") || strings.Contains(base, ".spec.") ||
		strings.HasPrefix(base, "test_") || strings.HasSuffix(base, "_test.py") || strings.HasSuffix(base, "Test.java") ||
		strings.HasSuffix(base, "_test.dart") || strings.Contains(p, "/tests/") || strings.HasPrefix(p, "tests/") ||
		strings.Contains(p, "/__tests__/") || strings.HasPrefix(p, "test/") || strings.Contains(p, "/test/")
}

// isMigration reports whether a path is a database migration.
func isMigration(p string) bool {
	return strings.Contains(p, "migrations/") || strings.Contains(p, "migrate/") || strings.Contains(p, "/db/migrate")
}

// newFile reports whether the patch creates the file.
func newFile(f domain.FileChange) bool {
	return f.Del == 0 && (strings.HasPrefix(f.Diff, "@@ -0,0 ") || f.Diff == "")
}

// ComputeFacts reads the facts of a delivery's diff, given per repository
// (already filtered or not: noise is dropped here).
func ComputeFacts(byRepo map[int64][]domain.FileChange) Facts {
	var f Facts
	dirs := map[string]bool{}
	risky := map[string]bool{}
	for repo, files := range byRepo {
		kept, dropped := Filter(files)
		f.Dropped = append(f.Dropped, dropped...)
		if len(kept) > 0 {
			f.Repositories++
		}
		for _, c := range kept {
			f.Files++
			f.Added += c.Add
			f.Deleted += c.Del
			dirs[strconv.FormatInt(repo, 10)+":"+path.Dir(c.Path)] = true
			test := isTest(c.Path)
			if test {
				f.TestFiles++
				f.TestLines += c.Add
			}
			if newFile(c) && !test {
				f.NewFiles++
				f.NewLines += c.Add
			}
			if !test && authPathRe.MatchString(c.Path) {
				risky[RiskAuth] = true
			}
			if !test && moneyPath.MatchString(c.Path) {
				risky[RiskMoney] = true
			}
			for line := range strings.Lines(c.Diff) {
				if !strings.HasPrefix(line, "+") || strings.HasPrefix(line, "+++") {
					continue
				}
				l := line[1:]
				if !test && concurrencyRe.MatchString(l) {
					risky[RiskConcurrency] = true
				}
				if isMigration(c.Path) && backfillRe.MatchString(l) {
					risky[RiskBackfill] = true
				}
			}
		}
	}
	f.ChangedLines = f.Added + f.Deleted
	f.Packages = len(dirs)
	for r := range risky {
		f.RiskyAreas = append(f.RiskyAreas, r)
	}
	slices.Sort(f.RiskyAreas)
	slices.Sort(f.Dropped)
	return f
}
