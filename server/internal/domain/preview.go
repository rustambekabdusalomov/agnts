package domain

import (
	"fmt"
	"path"
	"regexp"
	"slices"
	"strings"
	"time"
)

// Preview states of a ticket: where the preview of its latest result
// stands. Like the code review, the preview is advice for the human
// reviewer and never gates approval.
const (
	PreviewNone    = ""
	PreviewPending = "pending"
	PreviewRunning = "running"
	PreviewDone    = "done"
	PreviewFailed  = "failed"
)

// Preview statuses: how far the app got.
const (
	PreviewOK      = "ok"      // every route was captured
	PreviewPartial = "partial" // some routes failed (a login wall, a crash)
	PreviewBroken  = "failed"  // the app never started
)

// Preview viewports and sides.
var (
	PreviewViewports = []string{"desktop", "phone"}
	PreviewSides     = []string{"after", "before"}
)

// PreviewIssueSeverities lists issue severities, most severe first.
var PreviewIssueSeverities = []string{"high", "medium", "low"}

// Limits of one preview.
const (
	MaxPreviewShots  = 24
	MaxPreviewIssues = 20
)

// ShotIDPattern is what a screenshot id may look like; ids become file
// names, so nothing else is accepted.
var ShotIDPattern = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,63}$`)

// Preview is what a preview run captured of a ticket's result. It is stored
// as the preview run's result; a preview of an older revision is stale.
type Preview struct {
	Revision int            `json:"revision"`
	Model    string         `json:"model"`
	Compare  bool           `json:"compare"` // before shots were taken too
	Status   string         `json:"status"`
	Summary  string         `json:"summary"`
	Shots    []Shot         `json:"shots"`
	Issues   []PreviewIssue `json:"issues"`
	// RunID is the run whose files hold the screenshots.
	RunID     int64     `json:"-"`
	CreatedAt time.Time `json:"-"`
}

// Shot is one screenshot.
type Shot struct {
	ID            string `json:"id"`
	File          string `json:"file,omitempty"` // in the container; cleared once stored
	Name          string `json:"name"`
	Route         string `json:"route"`
	Viewport      string `json:"viewport"`
	Side          string `json:"side"`
	Note          string `json:"note,omitempty"`
	Width         int    `json:"width,omitempty"`
	Height        int    `json:"height,omitempty"`
	ConsoleErrors int    `json:"consoleErrors,omitempty"`
}

// PreviewIssue is a visual problem the preview run noticed.
type PreviewIssue struct {
	Severity    string `json:"severity"`
	Description string `json:"description"`
	ShotID      string `json:"shotId,omitempty"`
}

// Normalize cleans a preview written by Claude: it trims and caps every
// field, drops shots with a bad id, viewport or file, and issues pointing
// at shots that are not there. It reports false when there is no summary.
func (p *Preview) Normalize() bool {
	p.Summary = clip(strings.TrimSpace(p.Summary), 3000)
	if p.Summary == "" {
		return false
	}
	if p.Status = strings.ToLower(strings.TrimSpace(p.Status)); !slices.Contains([]string{PreviewOK, PreviewPartial, PreviewBroken}, p.Status) {
		p.Status = PreviewPartial
	}
	shots, seen := []Shot{}, map[string]bool{}
	for _, s := range p.Shots {
		s.ID = strings.ToLower(strings.TrimSpace(s.ID))
		if !ShotIDPattern.MatchString(s.ID) || seen[s.ID] || len(shots) >= MaxPreviewShots {
			continue
		}
		if s.Viewport = strings.ToLower(strings.TrimSpace(s.Viewport)); !slices.Contains(PreviewViewports, s.Viewport) {
			continue
		}
		if s.Side = strings.ToLower(strings.TrimSpace(s.Side)); !slices.Contains(PreviewSides, s.Side) {
			s.Side = "after"
		}
		if s.File != "" && !SafeOutFile(s.File) {
			continue
		}
		s.Name = clip(strings.TrimSpace(s.Name), 200)
		if s.Name == "" {
			s.Name = s.ID
		}
		s.Route = clip(strings.TrimSpace(s.Route), 500)
		s.Note = clip(strings.TrimSpace(s.Note), 500)
		s.Width, s.Height, s.ConsoleErrors = max(s.Width, 0), max(s.Height, 0), max(s.ConsoleErrors, 0)
		seen[s.ID] = true
		shots = append(shots, s)
	}
	p.Shots = shots

	issues := []PreviewIssue{}
	for _, is := range p.Issues {
		is.Description = clip(strings.TrimSpace(is.Description), 1000)
		if is.Description == "" || len(issues) >= MaxPreviewIssues {
			continue
		}
		if is.Severity = strings.ToLower(strings.TrimSpace(is.Severity)); !slices.Contains(PreviewIssueSeverities, is.Severity) {
			is.Severity = "medium"
		}
		if is.ShotID = strings.ToLower(strings.TrimSpace(is.ShotID)); !seen[is.ShotID] {
			is.ShotID = ""
		}
		issues = append(issues, is)
	}
	slices.SortStableFunc(issues, func(a, b PreviewIssue) int {
		return slices.Index(PreviewIssueSeverities, a.Severity) - slices.Index(PreviewIssueSeverities, b.Severity)
	})
	p.Issues = issues
	return true
}

// Shot returns the shot with id, if there is one.
func (p Preview) Shot(id string) (Shot, bool) {
	for _, s := range p.Shots {
		if s.ID == id {
			return s, true
		}
	}
	return Shot{}, false
}

// SafeOutFile reports whether f is a relative path inside the preview's
// shots folder (shots/<name>.png), with nothing that could climb out.
func SafeOutFile(f string) bool {
	if f != path.Clean(f) || !strings.HasPrefix(f, "shots/") || !strings.HasSuffix(f, ".png") {
		return false
	}
	return !strings.Contains(f, "..") && strings.Count(f, "/") == 1
}

// ShotRef points at a stored screenshot: the preview run and the shot id.
// Feedback refers to screenshots this way.
type ShotRef struct {
	RunID  int64  `json:"runId"`
	ShotID string `json:"shotId"`
}

// MaxFeedbackShots caps the screenshots one round of feedback carries.
const MaxFeedbackShots = 6

// MatchUIPaths reports whether any of files matches one of the globs. A
// glob is matched against the whole path; "**" matches any number of
// folders and "{a,b}" either alternative. No globs match every change.
func MatchUIPaths(files []string, globs []string) bool {
	if len(globs) == 0 {
		return len(files) > 0
	}
	for _, f := range files {
		for _, g := range globs {
			if globMatch(g, f) {
				return true
			}
		}
	}
	return false
}

// globMatch matches name against pattern with "**" and "{a,b}" support.
func globMatch(pattern, name string) bool {
	if i := strings.Index(pattern, "{"); i >= 0 {
		if j := strings.Index(pattern[i:], "}"); j > 0 {
			for _, alt := range strings.Split(pattern[i+1:i+j], ",") {
				if globMatch(pattern[:i]+alt+pattern[i+j+1:], name) {
					return true
				}
			}
			return false
		}
	}
	return matchSegments(strings.Split(pattern, "/"), strings.Split(name, "/"))
}

func matchSegments(pat, name []string) bool {
	for len(pat) > 0 {
		if pat[0] == "**" {
			for i := 0; i <= len(name); i++ {
				if matchSegments(pat[1:], name[i:]) {
					return true
				}
			}
			return false
		}
		if len(name) == 0 {
			return false
		}
		if ok, err := path.Match(pat[0], name[0]); err != nil || !ok {
			return false
		}
		pat, name = pat[1:], name[1:]
	}
	return len(name) == 0
}

var envKey = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_]*$`)

// MaxPreviewEnv caps the size of a repository's preview environment.
const MaxPreviewEnv = 16 << 10

// ParseEnv checks KEY=value lines (blank lines and # comments allowed) and
// returns the variable names in order.
func ParseEnv(env string) ([]string, error) {
	if len(env) > MaxPreviewEnv {
		return nil, fmt.Errorf("the environment is over %d KB", MaxPreviewEnv>>10)
	}
	names := []string{}
	for i, line := range strings.Split(env, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		k, _, ok := strings.Cut(strings.TrimPrefix(line, "export "), "=")
		if k = strings.TrimSpace(k); !ok || !envKey.MatchString(k) {
			return nil, fmt.Errorf("line %d is not KEY=value", i+1)
		}
		if !slices.Contains(names, k) {
			names = append(names, k)
		}
	}
	return names, nil
}
