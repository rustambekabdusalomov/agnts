package domain

import (
	"path"
	"slices"
	"strconv"
	"strings"
	"time"
)

// RelationType says how two tickets constrain each other's order.
type RelationType string

// Relation types.
const (
	// RelDependsOn: the ticket needs the other's change first. It does not
	// start coding until the other is merged (or rejected).
	RelDependsOn RelationType = "depends_on"
	// RelConflicts: both change the same code. Either may go first, but not
	// both at once: the second waits until the first is merged.
	RelConflicts RelationType = "conflicts"
	// RelRegressionOf: the ticket is a bug the other ticket's delivered
	// work caused. It never holds the queue; performance reviews count it
	// once the owner confirms it.
	RelRegressionOf RelationType = "regression_of"
)

// Valid reports whether t is a known relation type.
func (t RelationType) Valid() bool { return t == RelDependsOn || t == RelConflicts }

// RelationSource says who found a relation. Jira links and people are
// trusted as given; agnts's own findings are proposals unless confident.
type RelationSource string

// Relation sources.
const (
	RelFromJira  RelationSource = "jira"  // a "blocks" link on the issue
	RelFromPlane RelationSource = "plane" // a "blocked by" relation on the work item
	RelFromUser  RelationSource = "user"  // someone added it
	RelFromAgnts RelationSource = "agnts" // the analysis read it from the tickets
	RelFromRule  RelationSource = "rule"  // predicted footprints overlap (same files, shared hot spot)
	RelFromGit   RelationSource = "git"   // the finished branches change the same lines, and nobody predicted it
)

// RelationStatus is whether a relation constrains the queue.
type RelationStatus string

// Relation statuses.
const (
	RelActive    RelationStatus = "active"    // the queue follows it
	RelProposed  RelationStatus = "proposed"  // waiting for someone to accept it
	RelDismissed RelationStatus = "dismissed" // declined; never proposed again
)

// AutoApplyConfidence is the confidence from which a relation agnts read
// from the tickets applies without asking. Below it, it is only proposed:
// a missed relation costs a merge conflict, a wrong one only waiting time,
// but the person decides on the unsure ones.
const AutoApplyConfidence = 0.6

// Basis values say what a rule or git relation rests on.
const (
	BasisFiles      = "files"      // predicted to change the same files
	BasisMigrations = "migrations" // both add a database migration
	BasisLockfile   = "lockfile"   // both change dependency lockfiles
	BasisCodegen    = "codegen"    // both change an API spec or generated code
	BasisI18n       = "i18n"       // both change translation dictionaries
	BasisDiff       = "diff"       // the finished changes touch the same lines
)

// Relation is an ordering constraint between two tickets, by key. For
// RelDependsOn, TicketKey waits for OtherKey. For RelConflicts the pair is
// stored with the smaller key first.
type Relation struct {
	ID         int64
	TicketKey  string
	OtherKey   string
	Type       RelationType
	Source     RelationSource
	Status     RelationStatus
	Confidence float64
	Reason     string   // why, in words (from Claude or the person)
	Basis      string   // for rule and git relations: Basis*
	Files      []string // the files both change, when known
	FoundBy    string   // the ticket whose analysis found it, for agnts and rule relations
	// ConfirmedAt is when the finished changes proved the conflict real.
	ConfirmedAt *time.Time
	DecidedAt   *time.Time
	CreatedAt   time.Time
}

// Normalize orders a conflict's keys so each pair is stored once.
func (r Relation) Normalize() Relation {
	if r.Type == RelConflicts && r.OtherKey < r.TicketKey {
		r.TicketKey, r.OtherKey = r.OtherKey, r.TicketKey
	}
	return r
}

// Involves reports whether key is either side of the relation.
func (r Relation) Involves(key string) bool { return r.TicketKey == key || r.OtherKey == key }

// Other returns the side of the relation that is not key.
func (r Relation) Other(key string) string {
	if r.TicketKey == key {
		return r.OtherKey
	}
	return r.TicketKey
}

// Blocker is a ticket another one waits for before coding, and why.
type Blocker struct {
	Key   string
	Title string
	State TicketState
	Type  RelationType
}

// Releases reports whether t no longer holds back tickets that wait for it:
// its change is on the default branch (merged, pushed straight to it, or a
// report that changes no code) or it will never be (rejected).
func (t Ticket) Releases() bool {
	if t.State == StateRejected {
		return true
	}
	if t.State != StateDone {
		return false
	}
	return t.MergedAt != nil || t.Kind.Report() || (t.AfterApprove == "main" && t.Source == SourceLocal)
}

// Reachable reports whether to can be reached from from along edges
// (key -> keys it depends on). Adding from->to would close a cycle when to
// already reaches from.
func Reachable(edges map[string][]string, from, to string) bool {
	seen := map[string]bool{from: true}
	stack := []string{from}
	for len(stack) > 0 {
		k := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		if k == to {
			return true
		}
		for _, n := range edges[k] {
			if !seen[n] {
				seen[n] = true
				stack = append(stack, n)
			}
		}
	}
	return false
}

// Footprint is what the analysis predicts a ticket will change. The queue
// compares footprints to find tickets that must not run side by side.
type Footprint struct {
	// Files are the paths it expects to change, relative to the repository root.
	Files []string `json:"files"`
	// Modules are the packages, layers or features it touches, in words.
	Modules []string `json:"modules,omitempty"`
	// Provides are what it adds that other work could use ("endpoint GET /tasks").
	Provides []string `json:"provides,omitempty"`
	// Consumes are what it needs that may not exist yet.
	Consumes []string `json:"consumes,omitempty"`
	// Migrations is true when it adds or changes a database migration.
	Migrations bool `json:"migrations,omitempty"`
}

// Clean normalizes the paths (no ./, /workspace/ or leading slash),
// drops empty and duplicate ones and caps the lists.
func (f Footprint) Clean() Footprint {
	out := Footprint{Migrations: f.Migrations}
	seen := map[string]bool{}
	for _, p := range f.Files {
		p = CleanPath(p)
		if p == "" || seen[p] || len(out.Files) >= 200 {
			continue
		}
		seen[p] = true
		out.Files = append(out.Files, p)
	}
	trim := func(in []string, n int) []string {
		var o []string
		for _, s := range in {
			if s = strings.TrimSpace(s); s != "" && len(o) < n {
				o = append(o, truncateRunes(s, 200))
			}
		}
		return o
	}
	out.Modules, out.Provides, out.Consumes = trim(f.Modules, 30), trim(f.Provides, 30), trim(f.Consumes, 30)
	return out
}

func truncateRunes(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n])
}

// CleanPath turns a path Claude wrote into one relative to the repository.
func CleanPath(p string) string {
	p = strings.TrimSpace(strings.Trim(strings.TrimSpace(p), "`"))
	p = strings.TrimPrefix(p, "/workspace/")
	p = strings.TrimPrefix(p, "./")
	p = strings.TrimLeft(p, "/")
	if p == "" || strings.ContainsAny(p, "*?") || strings.HasSuffix(p, "/") {
		return "" // globs and directories are too broad to compare
	}
	return path.Clean(p)
}

// SharedFiles returns the paths both footprints expect to change, sorted.
func SharedFiles(a, b Footprint) []string {
	in := map[string]bool{}
	for _, p := range a.Files {
		in[p] = true
	}
	var out []string
	for _, p := range b.Files {
		if in[p] {
			out = append(out, p)
			in[p] = false
		}
	}
	slices.Sort(out)
	return out
}

// HotSpots returns the shared resources a footprint touches that two
// tickets can rarely change side by side without a conflict, even in
// different files: numbered migrations, lockfiles, an API spec with its
// generated code, translation dictionaries. Sorted Basis* values.
func HotSpots(f Footprint) []string {
	set := map[string]bool{}
	if f.Migrations {
		set[BasisMigrations] = true
	}
	for _, p := range f.Files {
		if b := hotSpot(p); b != "" {
			set[b] = true
		}
	}
	out := make([]string, 0, len(set))
	for b := range set {
		out = append(out, b)
	}
	slices.Sort(out)
	return out
}

var lockfiles = map[string]bool{
	"package-lock.json": true, "yarn.lock": true, "pnpm-lock.yaml": true, "bun.lockb": true, "go.sum": true,
	"Cargo.lock": true, "poetry.lock": true, "uv.lock": true, "Pipfile.lock": true, "Gemfile.lock": true,
	"composer.lock": true, "pubspec.lock": true, "Podfile.lock": true, "mix.lock": true,
}

func hotSpot(p string) string {
	lp := "/" + strings.ToLower(p)
	base := path.Base(p)
	lbase := strings.ToLower(base)
	switch {
	case strings.Contains(lp, "/migrations/") || strings.Contains(lp, "/db/migrate/") || strings.Contains(lp, "/alembic/versions/"):
		return BasisMigrations
	case lockfiles[base]:
		return BasisLockfile
	case strings.HasPrefix(lbase, "openapi.") || strings.HasPrefix(lbase, "swagger.") || strings.HasSuffix(lbase, ".proto") ||
		strings.HasSuffix(lbase, ".graphql") || strings.HasSuffix(lbase, ".graphqls") ||
		strings.Contains(lbase, ".gen.") || strings.HasSuffix(lbase, ".g.dart") || strings.HasSuffix(lbase, ".pb.go") ||
		strings.HasSuffix(lbase, "_pb2.py"):
		return BasisCodegen
	case strings.Contains(lp, "/i18n/") || strings.Contains(lp, "/locales/") || strings.Contains(lp, "/l10n/") ||
		strings.HasSuffix(lbase, ".arb") || strings.HasSuffix(lbase, ".po") || strings.HasSuffix(lbase, ".xliff"):
		return BasisI18n
	}
	return ""
}

// FileConflict is a file two finished changes both touch, and whether
// their edits overlap so that git could not merge them on its own.
type FileConflict struct {
	Path string
	// Lines is true when the edits touch the same or adjacent lines (or the
	// file is added, deleted or binary on both sides); false when they only
	// share the file.
	Lines bool
}

// DiffConflicts compares two changes made from the same default branch and
// returns the files both touch, sorted. A file whose edited line ranges
// overlap, or sit next to each other, is a line conflict: git refuses to
// merge those. Ranges are compared in the base file's numbering, so the
// answer is exact when both branches start from the same commit and close
// otherwise. A diff cut short for size counts as a line conflict.
func DiffConflicts(a, b []FileChange) []FileConflict {
	bs := map[string]FileChange{}
	for _, f := range b {
		bs[f.Path] = f
	}
	var out []FileConflict
	for _, fa := range a {
		fb, ok := bs[fa.Path]
		if !ok {
			continue
		}
		ra, okA := editRegions(fa.Diff)
		rb, okB := editRegions(fb.Diff)
		out = append(out, FileConflict{Path: fa.Path, Lines: !okA || !okB || regionsTouch(ra, rb)})
	}
	slices.SortFunc(out, func(x, y FileConflict) int { return strings.Compare(x.Path, y.Path) })
	return out
}

// region is a span of edited positions in the base file. Line n sits at
// position 2n and the gap after it at 2n+1, so an insertion between two
// lines is a point too.
type region struct{ from, to int }

// editRegions reads a unified diff of one file. ok is false when the edits
// cannot be placed: a truncated or binary diff, or a whole-file add or
// delete (which any other edit of the file conflicts with).
func editRegions(diff string) (rs []region, ok bool) {
	if diff == "" || strings.Contains(diff, "diff truncated") {
		return nil, false
	}
	var old int // the base line the next diff line lines up with
	inHunk := false
	for _, line := range strings.Split(diff, "\n") {
		switch {
		case strings.HasPrefix(line, "--- /dev/null"), strings.HasPrefix(line, "+++ /dev/null"):
			return nil, false
		case strings.HasPrefix(line, "Binary files"):
			return nil, false
		case strings.HasPrefix(line, "@@ "):
			start, ok := hunkOldStart(line)
			if !ok {
				return nil, false
			}
			old, inHunk = start, true
		case !inHunk:
		case strings.HasPrefix(line, "-"):
			rs = addRegion(rs, region{2 * old, 2 * old})
			old++
		case strings.HasPrefix(line, "+"):
			g := 2*old - 1 // the gap before base line old
			rs = addRegion(rs, region{g, g})
		case strings.HasPrefix(line, " "):
			old++
		}
	}
	return rs, len(rs) > 0
}

// hunkOldStart parses "@@ -12,5 +12,7 @@" to 12; "-0,0" (an empty base) gives 1.
func hunkOldStart(h string) (int, bool) {
	f := strings.Fields(h)
	if len(f) < 2 || !strings.HasPrefix(f[1], "-") {
		return 0, false
	}
	n, err := strconv.Atoi(strings.SplitN(f[1][1:], ",", 2)[0])
	if err != nil {
		return 0, false
	}
	return max(n, 1), true
}

func addRegion(rs []region, r region) []region {
	if n := len(rs); n > 0 && r.from <= rs[n-1].to+1 {
		rs[n-1].to = max(rs[n-1].to, r.to)
		return rs
	}
	return append(rs, r)
}

// regionsTouch reports whether any two regions overlap or are adjacent
// (no untouched base line between them), which is when git conflicts.
func regionsTouch(a, b []region) bool {
	for _, x := range a {
		for _, y := range b {
			if x.from-2 <= y.to && y.from-2 <= x.to {
				return true
			}
		}
	}
	return false
}
