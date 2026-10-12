package orchestrator

import (
	"context"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/guard"
)

// enforcedRules are the team rules agnts-guard enforces in runs of repoID:
// the file and command rules (diff rules are checked on the server).
func (o *Orchestrator) enforcedRules(ctx context.Context, repoID int64) []guard.Rule {
	rules, err := o.enforced(ctx, &repoID)
	if err != nil {
		o.log.Warn("load enforced rules", "err", err)
		return nil
	}
	var out []guard.Rule
	for _, r := range rules {
		if e := r.Enforce; e.On == guard.OnFile || e.On == guard.OnBash {
			out = append(out, guard.Rule{ID: r.ID, Title: r.Title, On: e.On, Paths: e.Paths, Pattern: e.Pattern, Action: e.Action, Message: e.Message})
		}
	}
	return out
}

// enforced returns the active rules with an enforcement for repoID.
func (o *Orchestrator) enforced(ctx context.Context, repoID *int64) ([]domain.Rule, error) {
	if o.rules == nil {
		return nil, nil
	}
	rules, err := o.rules.ActiveRules(ctx, repoID)
	if err != nil {
		return nil, err
	}
	var out []domain.Rule
	for _, r := range rules {
		if r.Enforce != nil && r.Kind == domain.KindInstruction {
			out = append(out, r)
		}
	}
	return out, nil
}

// RuleHit is where an enforced rule matches a change.
type RuleHit struct {
	RuleID int64
	Title  string
	Path   string
	Line   int
	Text   string
	Action string
}

// ruleHits checks a finished change against file and diff rules: the
// server's backstop for agnts-guard, and the "try on history" check.
func ruleHits(files []domain.FileChange, rules []domain.Rule) []RuleHit {
	var out []RuleHit
	for _, r := range rules {
		e := r.Enforce
		if e == nil || e.On == guard.OnBash {
			continue
		}
		var re *regexp.Regexp
		if e.Pattern != "" {
			var err error
			if re, err = regexp.Compile(e.Pattern); err != nil {
				continue
			}
		}
		for _, f := range files {
			if len(e.Paths) > 0 && !matchesAny(e.Paths, f.Path) {
				continue
			}
			if re == nil {
				out = append(out, RuleHit{RuleID: r.ID, Title: r.Title, Path: f.Path, Text: fmt.Sprintf("changed (+%d −%d)", f.Add, f.Del), Action: e.Action})
				continue
			}
			for _, l := range addedLines(f.Diff) {
				if re.MatchString(l.text) {
					out = append(out, RuleHit{RuleID: r.ID, Title: r.Title, Path: f.Path, Line: l.n, Text: truncate(strings.TrimSpace(l.text), 200), Action: e.Action})
					break // one hit per file is enough to show it
				}
			}
		}
	}
	return out
}

func matchesAny(globs []string, p string) bool {
	for _, g := range globs {
		if guard.MatchGlob(g, p) {
			return true
		}
	}
	return false
}

type numberedLine struct {
	n    int
	text string
}

// addedLines returns the lines a unified diff adds, with their numbers in
// the new file.
func addedLines(diff string) []numberedLine {
	var out []numberedLine
	n := 0
	for _, l := range strings.Split(diff, "\n") {
		switch {
		case strings.HasPrefix(l, "@@"):
			if _, after, ok := strings.Cut(l, "+"); ok {
				num, _, _ := strings.Cut(after, ",")
				num, _, _ = strings.Cut(num, " ")
				n, _ = strconv.Atoi(num)
			}
		case strings.HasPrefix(l, "+++"), strings.HasPrefix(l, "---"):
		case strings.HasPrefix(l, "+"):
			out = append(out, numberedLine{n, l[1:]})
			n++
		case strings.HasPrefix(l, " "):
			n++
		}
	}
	return out
}

// ruleFlags turns rule hits into red flags for the reviewer.
func ruleFlags(hits []RuleHit) []domain.RedFlag {
	var out []domain.RedFlag
	for _, h := range hits {
		out = append(out, domain.RedFlag{Kind: domain.FlagRuleViolation, Path: h.Path, Line: h.Line,
			Text: truncate("team rule \""+h.Title+"\": "+h.Text, 200)})
	}
	return out
}

// ChangeHistory finds the changes agnts made before. A Store may
// implement it; Try on history needs it.
type ChangeHistory interface {
	// RecentChanges returns the changed files of the newest done tickets
	// in repoID (nil: every repository), newest first.
	RecentChanges(ctx context.Context, repoID *int64, limit int) ([]InFlight, error)
}

// historyTickets is how many past changes Try on history checks.
const historyTickets = 50

// TryResult is what an enforcement would have caught in past changes.
type TryResult struct {
	Checked int       // changes looked at
	Hits    []RuleHit // where it matched, at most 50
	Tickets []string  // the tickets with hits
	Note    string    // what the check could not do (command rules)
}

// TryEnforce checks an enforcement against the last changes agnts made in
// repoID (nil: all repositories), so people see what it would catch, and
// what it would wrongly catch, before they turn it on.
func (o *Orchestrator) TryEnforce(ctx context.Context, e domain.RuleEnforce, repoID *int64) (TryResult, error) {
	if err := e.Validate(); err != nil {
		return TryResult{}, invalid("%s", err)
	}
	hist, ok := o.store.(ChangeHistory)
	if !ok {
		return TryResult{}, invalid("trying rules on history is not available on this server")
	}
	if e.On == guard.OnBash {
		return TryResult{Note: "command rules apply to the commands Claude runs, which agnts does not keep; they cannot be tried on past changes"}, nil
	}
	changes, err := hist.RecentChanges(ctx, repoID, historyTickets)
	if err != nil {
		return TryResult{}, err
	}
	res := TryResult{Checked: len(changes)}
	rule := domain.Rule{Title: "this rule", Enforce: &e}
	for _, c := range changes {
		hits := ruleHits(c.Files, []domain.Rule{rule})
		if len(hits) == 0 {
			continue
		}
		res.Tickets = append(res.Tickets, c.Ticket.Key)
		for _, h := range hits {
			if len(res.Hits) < 50 {
				h.Title = c.Ticket.Key
				res.Hits = append(res.Hits, h)
			}
		}
	}
	return res, nil
}

// SkillsDir is where Claude Code finds user skills in a run
// (CLAUDE_CONFIG_DIR/skills, see the runner).
const SkillsDir = "/home/agent/.claude/skills"

// skillName is a rule's skill name: lowercase letters, digits and hyphens.
func skillName(r domain.Rule) string {
	var b strings.Builder
	dash := false
	for _, c := range strings.ToLower(r.Title) {
		switch {
		case c >= 'a' && c <= 'z', c >= '0' && c <= '9':
			b.WriteRune(c)
			dash = false
		case !dash && b.Len() > 0:
			b.WriteByte('-')
			dash = true
		}
		if b.Len() >= 40 {
			break
		}
	}
	slug := strings.Trim(b.String(), "-")
	if slug == "" {
		slug = "rule"
	}
	return "agnts-" + slug + "-" + strconv.FormatInt(r.ID, 10)
}

// skillMarkdown is a rule as a Claude Code skill.
func skillMarkdown(r domain.Rule) string {
	desc := strings.TrimSpace(r.SkillDescription)
	if desc == "" {
		desc = "Use when the work touches what this team rule covers: " + r.Title + "."
	}
	what := map[domain.RuleKind]string{domain.KindInstruction: "Team rule", domain.KindContext: "Business context", domain.KindTip: "Tip from earlier runs"}[r.Kind]
	scope := "every repository"
	if r.RepoID != nil {
		scope = "the repository " + r.RepoName
	}
	return fmt.Sprintf("---\nname: %s\ndescription: %s\n---\n\n# %s\n\n%s\n\n(%s for %s, approved by the team in agnts.)\n",
		skillName(r), strings.ReplaceAll(desc, "\n", " "), r.Title, r.Text(), what, scope)
}

// writeSkills puts the rules delivered as skills, and the tips, into the
// run as Claude Code skills, replacing those of earlier runs. It returns
// how many it wrote.
func (o *Orchestrator) writeSkills(ctx context.Context, ws Workspace, repoID *int64) int {
	if o.rules == nil {
		return 0
	}
	rules, err := o.rules.ActiveRules(ctx, repoID)
	if err != nil {
		o.log.Warn("load skill rules", "err", err)
		return 0
	}
	_, _ = ws.Exec(ctx, "rm -rf "+SkillsDir+"/agnts-*", time.Minute)
	n := 0
	for _, r := range rules {
		if r.Delivery != domain.DeliverSkill && r.Kind != domain.KindTip {
			continue
		}
		if err := ws.WriteFile(ctx, SkillsDir+"/"+skillName(r)+"/SKILL.md", []byte(skillMarkdown(r))); err != nil {
			o.log.Warn("write skill", "rule", r.ID, "err", err)
			continue
		}
		n++
	}
	return n
}
