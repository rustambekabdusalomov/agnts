package guard

import (
	"encoding/json"
	"fmt"
	"path"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// MaxInput caps the hook input read from stdin.
const MaxInput = 1 << 20

// Input is what Claude Code sends a hook on stdin (the fields agnts uses).
type Input struct {
	Event          string          `json:"hook_event_name"`
	ToolName       string          `json:"tool_name"`
	ToolInput      json.RawMessage `json:"tool_input"`
	StopHookActive bool            `json:"stop_hook_active"`
	Source         string          `json:"source"` // SessionStart: startup, resume, clear or compact
	Cwd            string          `json:"cwd"`
}

// Result is a hook's answer: exit 2 with Stderr blocks a tool call (or,
// after one, sends Stderr to Claude); exit 0 with Stdout adds context
// (SessionStart).
type Result struct {
	Exit   int
	Stderr string
	Stdout string
}

// Entry is one line of the guard log.
type Entry struct {
	At       time.Time `json:"at"`
	Event    string    `json:"event"`
	Hook     string    `json:"hook,omitempty"`
	Tool     string    `json:"tool,omitempty"`
	Decision string    `json:"decision"` // block, feedback, warn, context, pass, error
	Kind     string    `json:"kind,omitempty"`
	Path     string    `json:"path,omitempty"`
	MS       int64     `json:"ms,omitempty"`
	Msg      string    `json:"msg,omitempty"`
}

// Decisions in the log.
const (
	DecisionBlock    = "block"
	DecisionFeedback = "feedback"
	DecisionWarn     = "warn"
	DecisionContext  = "context"
	DecisionPass     = "pass"
	DecisionError    = "error"
)

// State is what hooks remember between calls in one run.
type State struct {
	StopFailures int              `json:"stopFailures"`
	Asked        map[string]bool  `json:"asked,omitempty"`   // files the fact check asked about
	LastRun      map[string]int64 `json:"lastRun,omitempty"` // edit check name -> unix seconds
	Commands     map[string]bool  `json:"commands,omitempty"`
	Notices      map[string]bool  `json:"notices,omitempty"` // delivered notice ids
}

// Env is the outside world of a hook; tests replace it.
type Env interface {
	// Run runs a shell command in the workspace.
	Run(cmd string, timeout time.Duration) (exit int, output string, took time.Duration)
	// ReadFile reads a file (absolute path), or returns an error.
	ReadFile(p string) ([]byte, error)
	Now() time.Time
}

// Workspace is where the repository is checked out in a run.
const Workspace = "/workspace"

// Handle runs the hook for event. It never fails: a guard that cannot
// decide lets the action through, and the server's checks after the run
// still apply.
func Handle(event string, in Input, cfg Config, st *State, env Env) (Result, []Entry) {
	h := handler{cfg: cfg, st: st, env: env, in: in, event: event}
	switch event {
	case "pre":
		h.pre()
	case "post":
		h.post()
	case "stop":
		h.stop()
	case "session":
		h.session()
	}
	return h.res, h.log
}

type handler struct {
	cfg   Config
	st    *State
	env   Env
	in    Input
	event string
	res   Result
	log   []Entry
}

func (h *handler) note(e Entry) {
	e.At, e.Event, e.Tool = h.env.Now(), h.event, h.in.ToolName
	h.log = append(h.log, e)
}

func (h *handler) block(hook, kind, p, msg string) {
	h.res = Result{Exit: 2, Stderr: msg}
	h.note(Entry{Hook: hook, Decision: DecisionBlock, Kind: kind, Path: p, Msg: clip(msg, 300)})
}

// feedback sends msg to Claude after a tool ran (PostToolUse, Stop).
func (h *handler) feedback(hook, kind, p, msg string, took time.Duration) {
	if h.res.Exit == 2 {
		h.res.Stderr += "\n\n" + msg
	} else {
		h.res = Result{Exit: 2, Stderr: msg}
	}
	h.note(Entry{Hook: hook, Decision: DecisionFeedback, Kind: kind, Path: p, MS: took.Milliseconds(), Msg: clip(msg, 300)})
}

// edit is one file change a tool call makes.
type edit struct {
	path    string // relative to the workspace; "" outside it
	added   []string
	oldText string
	newText string
	whole   bool // Write: the file's whole new content
}

func (h *handler) edits() []edit {
	var raw struct {
		FilePath     string `json:"file_path"`
		NotebookPath string `json:"notebook_path"`
		Content      string `json:"content"`
		OldString    string `json:"old_string"`
		NewString    string `json:"new_string"`
		NewSource    string `json:"new_source"`
		Edits        []struct {
			OldString string `json:"old_string"`
			NewString string `json:"new_string"`
		} `json:"edits"`
	}
	if json.Unmarshal(h.in.ToolInput, &raw) != nil {
		return nil
	}
	abs := raw.FilePath
	if abs == "" {
		abs = raw.NotebookPath
	}
	rel := h.rel(abs)
	switch h.in.ToolName {
	case "Write":
		old := ""
		if b, err := h.env.ReadFile(h.abs(abs)); err == nil {
			old = string(b)
		}
		return []edit{{path: rel, added: addedLines(old, raw.Content), oldText: old, newText: raw.Content, whole: true}}
	case "Edit":
		return []edit{{path: rel, added: addedLines(raw.OldString, raw.NewString), oldText: raw.OldString, newText: raw.NewString}}
	case "MultiEdit":
		e := edit{path: rel}
		for _, x := range raw.Edits {
			e.added = append(e.added, addedLines(x.OldString, x.NewString)...)
			e.oldText += x.OldString + "\n"
			e.newText += x.NewString + "\n"
		}
		return []edit{e}
	case "NotebookEdit":
		return []edit{{path: rel, added: addedLines("", raw.NewSource), newText: raw.NewSource}}
	}
	return nil
}

func (h *handler) cwd() string {
	if h.in.Cwd != "" {
		return h.in.Cwd
	}
	return Workspace
}

func (h *handler) abs(p string) string {
	if filepath.IsAbs(p) {
		return p
	}
	return filepath.Join(h.cwd(), p)
}

// rel returns p relative to the workspace, or "" when it is outside
// (agnts's own /agnts/out files, /tmp).
func (h *handler) rel(p string) string {
	if p == "" {
		return ""
	}
	r, err := filepath.Rel(Workspace, filepath.Clean(h.abs(p)))
	if err != nil || r == "." || strings.HasPrefix(r, "..") {
		return ""
	}
	return filepath.ToSlash(r)
}

// addedLines returns the lines of next that old does not have (as many
// times as they are new), trimmed of trailing space.
func addedLines(old, next string) []string {
	have := map[string]int{}
	for _, l := range strings.Split(old, "\n") {
		have[strings.TrimRight(l, " \t\r")]++
	}
	var out []string
	for _, l := range strings.Split(next, "\n") {
		l = strings.TrimRight(l, " \t\r")
		if have[l] > 0 {
			have[l]--
			continue
		}
		if strings.TrimSpace(l) != "" {
			out = append(out, l)
		}
	}
	return out
}

// Why each red flag kind is refused, for Claude.
var flagWhy = map[string]string{
	domain.FlagSecret:         "this line looks like a real credential. Never put secrets in code: read them from the environment or configuration, and use an obvious placeholder in examples and tests",
	domain.FlagEnvFile:        "dotenv files hold real secrets and never belong in a change. Document the variables in an example file (.env.example) instead",
	domain.FlagSkippedTest:    "skipping or focusing a test makes the checks pass without fixing the code. Fix the code or the test instead",
	domain.FlagSilencedLint:   "silencing the linter or type checker hides the problem. Fix the code so the check passes",
	domain.FlagSwallowedError: "an error caught and dropped hides failures. Handle it or return it",
	domain.FlagRemovedAssert:  "this edit removes assertions from a test. Keep what the test checks; change an expectation only when it was wrong",
	domain.FlagDeletedTest:    "deleting a test file removes the checks it made",
	domain.FlagCheckConfig:    "this file configures the checks (a linter, type checker, test runner or CI). Changing it can make checks pass without fixing the code",
}

const lift = "\nIf the ticket really requires it, do not work around this: finish without it and explain in the \"deviations\" of your summary; a person can allow it for this ticket."

func (h *handler) refuse(kind, p, line string) {
	msg := fmt.Sprintf("agnts-guard refused this edit of %s: %s.", p, flagWhy[kind])
	if line != "" {
		msg += "\nLine: " + clip(strings.TrimSpace(domain.MaskSecret(line)), 200)
	}
	hook := HookRedFlags
	if kind == domain.FlagSecret || kind == domain.FlagEnvFile {
		hook = HookSecret
	} else {
		msg += lift
	}
	h.block(hook, kind, p, msg)
}

// blocks reports whether red flag kind is refused under the config.
func (h *handler) blocks(kind string) bool {
	if h.cfg.Allowed(kind) {
		return false
	}
	switch kind {
	case domain.FlagSecret, domain.FlagEnvFile:
		return h.cfg.On(HookSecret)
	case domain.FlagSkippedTest, domain.FlagSilencedLint, domain.FlagDeletedTest, domain.FlagCheckConfig:
		return h.cfg.On(HookRedFlags)
	case domain.FlagSwallowedError, domain.FlagRemovedAssert:
		return h.cfg.On(HookRedFlags) && h.cfg.Profile == Strict
	}
	return false
}

func (h *handler) pre() {
	if h.cfg.On(HookAPI) && h.preAPI() {
		return
	}
	if h.notice() {
		return
	}
	switch h.in.ToolName {
	case "Edit", "Write", "MultiEdit", "NotebookEdit":
		for _, e := range h.edits() {
			if e.path == "" {
				continue // agnts's own files and scratch space
			}
			if h.preEdit(e) {
				return
			}
		}
	case "Bash":
		h.preBash()
	}
}

// notice delivers a message the server left, once: the tool call it
// holds back can simply be made again.
func (h *handler) notice() bool {
	b, err := h.env.ReadFile(NoticePath)
	if err != nil {
		return false
	}
	var n Notice
	if json.Unmarshal(b, &n) != nil || n.ID == "" || n.Message == "" || h.st.Notices[n.ID] {
		return false
	}
	if h.st.Notices == nil {
		h.st.Notices = map[string]bool{}
	}
	h.st.Notices[n.ID] = true
	h.block(HookNotice, "", "", n.Message+"\n\n(This tool call was held back only so you read this; make it again if it is still the right next step.)")
	return true
}

// preEdit checks one edit; it reports whether it blocked.
func (h *handler) preEdit(e edit) bool {
	secretOK := domain.SecretAllowed(e.path, h.cfg.SecretAllow)
	if domain.IsEnvFile(e.path) && !secretOK && h.blocks(domain.FlagEnvFile) {
		h.refuse(domain.FlagEnvFile, e.path, "")
		return true
	}
	if domain.IsCheckConfig(e.path) && h.blocks(domain.FlagCheckConfig) && !h.newOnBranch(e.path) {
		h.refuse(domain.FlagCheckConfig, e.path, "")
		return true
	}
	test := domain.IsTestFile(e.path)
	if test && e.whole && strings.TrimSpace(e.newText) == "" && e.oldText != "" && h.blocks(domain.FlagDeletedTest) {
		h.refuse(domain.FlagDeletedTest, e.path, "")
		return true
	}
	for _, l := range e.added {
		kind := domain.LineFlag(e.path, l)
		if kind == domain.FlagSecret && secretOK {
			continue
		}
		if kind != "" && h.blocks(kind) {
			h.refuse(kind, e.path, l)
			return true
		}
	}
	if test && e.oldText != "" && domain.CountAsserts(e.newText) < domain.CountAsserts(e.oldText) && h.blocks(domain.FlagRemovedAssert) {
		h.refuse(domain.FlagRemovedAssert, e.path, "")
		return true
	}
	if h.cfg.On(HookRules) {
		for _, r := range h.cfg.Rules {
			if r.On == OnFile && r.Action == ActionBlock && ruleHitsEdit(r, e) {
				h.block(HookRules, domain.FlagRuleViolation, e.path, ruleMessage(r, e.path))
				return true
			}
		}
	}
	if h.cfg.On(HookFactCheck) && (!e.whole || e.oldText != "") {
		if h.st.Asked == nil {
			h.st.Asked = map[string]bool{}
		}
		if !h.st.Asked[e.path] {
			h.st.Asked[e.path] = true
			h.block(HookFactCheck, "", e.path, factQuestions(e.path))
			return true
		}
	}
	return false
}

func factQuestions(p string) string {
	return fmt.Sprintf(`agnts-guard: before your first edit of %s, write down (in your reply, briefly):
1. Who uses it: the files that import or call what you are changing, and the command you used to find them.
2. What you change in its public surface: exported functions, types, endpoints, schemas; "nothing" is a fine answer.
3. How this edit carries out the chosen approach.
Then make the edit again. Later edits of this file go through.`, p)
}

var (
	reRm          = regexp.MustCompile(`(?:^|[;&|]\s*|\s)(?:git\s+rm|rm|unlink)\s+([^;&|]+)`)
	reDestructive = regexp.MustCompile(`(?i)\brm\s+-[a-z]*r[a-z]*f?\b|\bgit\s+reset\s+--hard\b|\bgit\s+clean\s+-[a-z]*f|\bgit\s+checkout\s+--\s+\.|\bdrop\s+(table|database|schema)\b|\btruncate\s+table\b`)
)

func (h *handler) preBash() {
	var raw struct {
		Command string `json:"command"`
	}
	if json.Unmarshal(h.in.ToolInput, &raw) != nil || raw.Command == "" {
		return
	}
	cmd := raw.Command
	if h.blocks(domain.FlagDeletedTest) {
		for _, m := range reRm.FindAllStringSubmatch(cmd, -1) {
			for _, arg := range strings.Fields(m[1]) {
				if strings.HasPrefix(arg, "-") {
					continue
				}
				if p := h.rel(strings.Trim(arg, `"'`)); p != "" && domain.IsTestFile(p) {
					h.refuse(domain.FlagDeletedTest, p, "")
					return
				}
			}
		}
	}
	if h.cfg.On(HookRules) {
		for _, r := range h.cfg.Rules {
			if r.On == OnBash && r.Action == ActionBlock && ruleHitsCommand(r, cmd) {
				h.block(HookRules, domain.FlagRuleViolation, "", ruleMessage(r, ""))
				return
			}
		}
	}
	if h.cfg.On(HookDestructive) && reDestructive.MatchString(cmd) {
		if h.st.Commands == nil {
			h.st.Commands = map[string]bool{}
		}
		key := strings.Join(strings.Fields(cmd), " ")
		if !h.st.Commands[key] {
			h.st.Commands[key] = true
			h.block(HookDestructive, "", "", "agnts-guard: this command destroys work or data. Before you run it, list exactly what it removes or resets, and how you would get it back if that turns out wrong. Then run it again.")
		}
	}
}

func (h *handler) post() {
	switch h.in.ToolName {
	case "Edit", "Write", "MultiEdit", "NotebookEdit":
		for _, e := range h.edits() {
			if e.path == "" {
				continue
			}
			h.warnRules(OnFile, e, "")
			h.editChecks(e.path)
		}
	case "Bash":
		var raw struct {
			Command string `json:"command"`
		}
		if json.Unmarshal(h.in.ToolInput, &raw) == nil && raw.Command != "" {
			h.warnRules(OnBash, edit{}, raw.Command)
		}
	}
}

func (h *handler) warnRules(on string, e edit, cmd string) {
	if !h.cfg.On(HookRules) {
		return
	}
	for _, r := range h.cfg.Rules {
		if r.On != on || r.Action != ActionWarn {
			continue
		}
		hit := false
		if on == OnFile {
			hit = ruleHitsEdit(r, e)
		} else {
			hit = ruleHitsCommand(r, cmd)
		}
		if hit {
			h.res = Result{Exit: 2, Stderr: joinMsg(h.res.Stderr, ruleMessage(r, e.path))}
			h.note(Entry{Hook: HookRules, Decision: DecisionWarn, Kind: domain.FlagRuleViolation, Path: e.path, Msg: clip(r.Title, 200)})
		}
	}
}

func joinMsg(a, b string) string {
	if a == "" {
		return b
	}
	return a + "\n\n" + b
}

func (h *handler) editChecks(p string) {
	if !h.cfg.On(HookEditCheck) {
		return
	}
	now := h.env.Now().Unix()
	for _, c := range h.cfg.EditChecks {
		rel := p
		if c.Dir != "" {
			rest, ok := strings.CutPrefix(p, c.Dir+"/")
			if !ok {
				continue
			}
			rel = rest
		}
		if !matchAny(c.Globs, rel) {
			continue
		}
		if c.Every > 0 {
			if h.st.LastRun == nil {
				h.st.LastRun = map[string]int64{}
			}
			if now-h.st.LastRun[c.Name] < int64(c.Every) {
				continue
			}
			h.st.LastRun[c.Name] = now
		}
		cmd := strings.NewReplacer("{file}", shellQuote(rel), "{dir}", shellQuote(dirOf(rel))).Replace(c.Cmd)
		if c.Dir != "" {
			cmd = "cd " + shellQuote(c.Dir) + " && { " + cmd + "\n}"
		}
		timeout := time.Duration(max(c.TimeoutSec, 5)) * time.Second
		exit, out, took := h.env.Run(cmd, timeout)
		if exit == 0 {
			h.note(Entry{Hook: HookEditCheck, Decision: DecisionPass, Kind: c.Name, Path: p, MS: took.Milliseconds()})
			continue
		}
		if exit == 127 || exit == 124 {
			// The tool is missing or too slow: not something to fix in the code.
			h.note(Entry{Hook: HookEditCheck, Decision: DecisionError, Kind: c.Name, Path: p, MS: took.Milliseconds(), Msg: fmt.Sprintf("exit %d", exit)})
			continue
		}
		h.feedback(HookEditCheck, c.Name, p, fmt.Sprintf("agnts-guard: %s reports problems after your edit of %s (exit %d):\n%s\nFix them now, while the change is fresh.",
			c.Name, p, exit, headLines(out, 40)), took)
	}
}

func dirOf(p string) string {
	d := path.Dir(p)
	if d == "" {
		return "."
	}
	return d
}

func (h *handler) stop() {
	if !h.cfg.On(HookStopGate) {
		return
	}
	limit := h.cfg.StopAttempts
	if limit <= 0 {
		limit = 3
	}
	if h.st.StopFailures >= limit {
		h.note(Entry{Hook: HookStopGate, Decision: DecisionPass, Msg: fmt.Sprintf("let through after %d failed attempts; agnts runs the checks itself next", h.st.StopFailures)})
		return
	}
	for _, c := range h.cfg.Stop {
		timeout := time.Duration(max(c.TimeoutSec, 30)) * time.Second
		exit, out, took := h.env.Run(c.Shell(), timeout)
		if exit == 0 {
			h.note(Entry{Hook: HookStopGate, Decision: DecisionPass, Kind: c.Name, MS: took.Milliseconds()})
			continue
		}
		if exit == 127 && strings.Contains(out, "command not found") {
			h.note(Entry{Hook: HookStopGate, Decision: DecisionError, Kind: c.Name, MS: took.Milliseconds(), Msg: "command not found"})
			return
		}
		h.st.StopFailures++
		what := fmt.Sprintf("failed (exit %d)", exit)
		if exit == 124 {
			what = "timed out"
		}
		h.feedback(HookStopGate, c.Name, "", fmt.Sprintf("agnts-guard: before you finish, the %s check must pass. `%s` %s:\n%s\nFix the cause (not the check), then finish.",
			c.Name, c.Cmd, what, tailLines(out, 60)), took)
		return
	}
}

func (h *handler) session() {
	if !h.cfg.On(HookProgress) || (h.in.Source != "compact" && h.in.Source != "resume") {
		return
	}
	b, err := h.env.ReadFile(ProgressPath)
	if err != nil || strings.TrimSpace(string(b)) == "" {
		return
	}
	h.res = Result{Stdout: "agnts: your plan and progress so far, from " + ProgressPath + " (keep it current):\n\n" + clip(string(b), 8000)}
	h.note(Entry{Hook: HookProgress, Decision: DecisionContext, Msg: h.in.Source})
}

// ruleHitsEdit reports whether an edit breaks a file rule.
func ruleHitsEdit(r Rule, e edit) bool {
	if e.path == "" || len(r.Paths) > 0 && !matchAny(r.Paths, e.path) {
		return false
	}
	if r.Pattern == "" {
		return len(r.Paths) > 0 // a path-only rule: any edit of those files
	}
	re, err := regexp.Compile(r.Pattern)
	if err != nil {
		return false
	}
	return slices.ContainsFunc(e.added, re.MatchString)
}

func ruleHitsCommand(r Rule, cmd string) bool {
	if r.Pattern == "" {
		return false
	}
	re, err := regexp.Compile(r.Pattern)
	return err == nil && re.MatchString(cmd)
}

func ruleMessage(r Rule, p string) string {
	msg := "agnts-guard: this breaks the team rule \"" + r.Title + "\""
	if p != "" {
		msg += " (" + p + ")"
	}
	if r.Message != "" {
		msg += ": " + r.Message
	}
	if r.Action == ActionBlock {
		msg += "\nThe team enforces this rule; do it another way. If the ticket cannot be done without breaking it, explain in the \"deviations\" of your summary."
	}
	return msg
}

// MatchGlob reports whether p matches glob g: path.Match per segment, with
// "**" matching any number of directories and a pattern without a slash
// matching the base name anywhere.
func MatchGlob(g, p string) bool {
	if g == "" {
		return false
	}
	if !strings.Contains(g, "/") {
		ok, _ := path.Match(g, path.Base(p))
		return ok
	}
	return matchSegs(strings.Split(g, "/"), strings.Split(p, "/"))
}

func matchSegs(g, p []string) bool {
	for len(g) > 0 {
		if g[0] == "**" {
			for i := 0; i <= len(p); i++ {
				if matchSegs(g[1:], p[i:]) {
					return true
				}
			}
			return false
		}
		if len(p) == 0 {
			return false
		}
		if ok, _ := path.Match(g[0], p[0]); !ok {
			return false
		}
		g, p = g[1:], p[1:]
	}
	return len(p) == 0
}

func matchAny(globs []string, p string) bool {
	return slices.ContainsFunc(globs, func(g string) bool { return MatchGlob(g, p) })
}

// newOnBranch reports whether p (relative to the workspace) is not in the
// commit its repository's change started from: a file the change creates,
// like a new repository's first lint configuration. Unsure (no base known,
// git failing), it is not.
func (h *handler) newOnBranch(p string) bool {
	var base *RepoBase
	for i, b := range h.cfg.Bases {
		if (b.Folder == "" || strings.HasPrefix(p, b.Folder+"/")) && (base == nil || len(b.Folder) > len(base.Folder)) {
			base = &h.cfg.Bases[i]
		}
	}
	if p == "" || base == nil || base.Branch == "" {
		return false
	}
	rel, dir := p, "."
	if base.Folder != "" {
		rel, dir = strings.TrimPrefix(p, base.Folder+"/"), base.Folder
	}
	cmd := "cd " + shellQuote(dir) + " && base=$(git merge-base HEAD " + shellQuote("origin/"+base.Branch) + " 2>/dev/null || git merge-base HEAD " + shellQuote(base.Branch) +
		" 2>/dev/null) && [ -n \"$base\" ] && ! git cat-file -e \"$base\":" + shellQuote(rel) + " 2>/dev/null && echo new"
	exit, out, _ := h.env.Run(cmd, 10*time.Second)
	return exit == 0 && strings.TrimSpace(out) == "new"
}

func shellQuote(s string) string { return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'" }

func clip(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}

func headLines(s string, n int) string {
	ls := strings.Split(strings.TrimRight(s, "\n"), "\n")
	if len(ls) > n {
		ls = append(ls[:n], fmt.Sprintf("… (%d more lines)", len(ls)-n))
	}
	return clip(strings.Join(ls, "\n"), 6000)
}

func tailLines(s string, n int) string {
	ls := strings.Split(strings.TrimRight(s, "\n"), "\n")
	if len(ls) > n {
		ls = append([]string{fmt.Sprintf("… (%d lines before)", len(ls)-n)}, ls[len(ls)-n:]...)
	}
	out := strings.Join(ls, "\n")
	if len(out) > 8000 {
		out = "…" + out[len(out)-8000:]
	}
	return out
}
