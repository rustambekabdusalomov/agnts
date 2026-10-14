// Package guard is agnts-guard: the Claude Code hooks that run inside every
// run container. Claude Code calls the agnts-guard binary on its hook
// events; the server describes what to enforce with a Config passed in the
// environment of each Claude invocation (hooks inherit it). Every guard here
// has a backstop on the server after the run (the diff scan, the checks),
// so a missing or broken guard never lets work through unchecked.
package guard

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"slices"
)

// Paths and names shared by the server and the binary.
const (
	// ConfigEnv carries the run's Config, base64 of its JSON.
	ConfigEnv = "AGNTS_GUARD_CONFIG"
	// BinaryPath is where the runner puts the agnts-guard binary in a run.
	BinaryPath = "/home/agent/.agnts/bin/agnts-guard"
	// StateDir holds the guard's log and state between hook calls.
	StateDir = "/agnts/out/.guard"
	// LogPath is one JSON line per decision; the server reads it after a run.
	LogPath = StateDir + "/guard.jsonl"
	// StatePath is the counters hooks share within a run.
	StatePath = StateDir + "/state.json"
	// ProgressPath is the plan and progress the coding prompt asks Claude to
	// keep; the session hook gives it back after a compaction or resume.
	ProgressPath = "/agnts/out/progress.md"
	// NoticePath is a message the server leaves for Claude (a stall): the
	// next tool call is held back once, with the message.
	NoticePath = StateDir + "/notice.json"
)

// Notice is a message for Claude, delivered once.
type Notice struct {
	ID      string `json:"id"`
	Message string `json:"message"`
}

// Profile is how strict the guards are.
type Profile string

// Profiles, from the least to the most strict.
const (
	Minimal  Profile = "minimal"
	Standard Profile = "standard"
	Strict   Profile = "strict"
)

// Profiles lists the valid profiles.
var Profiles = []Profile{Minimal, Standard, Strict}

// Valid reports whether p is a known profile.
func (p Profile) Valid() bool { return slices.Contains(Profiles, p) }

// Hook ids: stable names a profile or a person turns guards on and off by.
const (
	HookSecret      = "pre:secret"       // block credentials and dotenv files
	HookRedFlags    = "pre:redflags"     // block skipped tests, silenced linters, weakened checks
	HookRules       = "pre:rules"        // enforce team rules with a pattern
	HookFactCheck   = "pre:fact-check"   // ask for facts before the first edit of a file
	HookEditCheck   = "post:edit-check"  // format and lint the file just edited
	HookStopGate    = "stop:gate"        // build and lint before Claude may finish
	HookProgress    = "session:progress" // give the progress file back after a compaction
	HookDestructive = "pre:destructive"  // ask for a rollback plan before destructive commands
	HookNotice      = "pre:notice"       // deliver a message from the server (always on)
)

// HookIDs lists every hook id.
var HookIDs = []string{HookSecret, HookRedFlags, HookRules, HookFactCheck, HookDestructive, HookEditCheck, HookStopGate, HookProgress}

// Command is a shell command a hook runs in /workspace, or in its Dir.
type Command struct {
	Name       string `json:"name"`
	Cmd        string `json:"cmd"`
	TimeoutSec int    `json:"timeoutSec,omitempty"`
	// Dir is the repository's folder under /workspace in a run of several
	// repositories ("" for /workspace). With IfChanged the command only
	// runs when that repository has changes.
	Dir       string `json:"dir,omitempty"`
	IfChanged bool   `json:"ifChanged,omitempty"`
}

// Shell is the command line to run from /workspace.
func (c Command) Shell() string {
	cmd := c.Cmd
	if c.IfChanged {
		cmd = `if [ -z "$(git status --porcelain)" ]; then exit 0; fi; ` + cmd
	}
	if c.Dir == "" {
		return cmd
	}
	return "cd " + shellQuote(c.Dir) + " && { " + cmd + "\n}"
}

// EditCheck is a quick check of one edited file: Cmd with {file} (the
// path relative to /workspace, or to Dir) and {dir} (its directory)
// filled in, run when the path matches one of the globs.
type EditCheck struct {
	// Dir is the repository's folder in a run of several repositories:
	// the check covers files under it only, runs in it, and its globs and
	// {file} are relative to it.
	Dir        string   `json:"dir,omitempty"`
	Name       string   `json:"name"`
	Globs      []string `json:"globs"`
	Cmd        string   `json:"cmd"`
	TimeoutSec int      `json:"timeoutSec,omitempty"`
	// Every limits how often it runs, in seconds (a slow typecheck); 0 runs
	// it after every edit (still debounced).
	Every int `json:"every,omitempty"`
}

// Rule is a team rule enforced while Claude works.
type Rule struct {
	ID      int64    `json:"id"`
	Title   string   `json:"title"`
	On      string   `json:"on"` // "file" (edits) or "bash" (commands); "diff" is checked on the server only
	Paths   []string `json:"paths,omitempty"`
	Pattern string   `json:"pattern,omitempty"`
	Action  string   `json:"action"` // "block" or "warn"
	Message string   `json:"message"`
}

// Rule actions and targets.
const (
	ActionBlock = "block"
	ActionWarn  = "warn"
	OnFile      = "file"
	OnBash      = "bash"
	OnDiff      = "diff"
)

// Config is what the guards enforce in one Claude invocation.
type Config struct {
	Profile  Profile `json:"profile"`
	ReadOnly bool    `json:"readOnly,omitempty"`
	// Disabled are hook ids turned off.
	Disabled []string `json:"disabled,omitempty"`
	// Allow are red flag kinds a person allowed for this ticket.
	Allow []string `json:"allow,omitempty"`
	// SecretAllow are path globs where example credentials are expected.
	SecretAllow []string `json:"secretAllow,omitempty"`
	// Stop are the commands the stop gate runs, in order.
	Stop []Command `json:"stop,omitempty"`
	// StopAttempts is how many times the stop gate may send Claude back.
	StopAttempts int         `json:"stopAttempts,omitempty"`
	EditChecks   []EditCheck `json:"editChecks,omitempty"`
	Rules        []Rule      `json:"rules,omitempty"`
	// FactCheck asks for facts before the first edit of each existing file.
	FactCheck bool `json:"factCheck,omitempty"`
}

// On reports whether hook id runs in this config.
func (c Config) On(id string) bool {
	if slices.Contains(c.Disabled, id) {
		return false
	}
	switch id {
	case HookSecret, HookProgress, HookRules:
		return true
	case HookRedFlags:
		return c.Profile == Standard || c.Profile == Strict
	case HookEditCheck:
		return !c.ReadOnly && c.Profile != Minimal && len(c.EditChecks) > 0
	case HookStopGate:
		return !c.ReadOnly && len(c.Stop) > 0
	case HookFactCheck, HookDestructive:
		return !c.ReadOnly && c.FactCheck
	}
	return false
}

// Allowed reports whether a person allowed red flag kind for the ticket.
func (c Config) Allowed(kind string) bool { return slices.Contains(c.Allow, kind) }

// Encode returns the value of ConfigEnv for c.
func (c Config) Encode() string {
	b, _ := json.Marshal(c)
	return base64.StdEncoding.EncodeToString(b)
}

// Decode reads a ConfigEnv value.
func Decode(v string) (Config, error) {
	var c Config
	b, err := base64.StdEncoding.DecodeString(v)
	if err != nil {
		return c, fmt.Errorf("guard config: %w", err)
	}
	if err := json.Unmarshal(b, &c); err != nil {
		return c, fmt.Errorf("guard config: %w", err)
	}
	if !c.Profile.Valid() {
		c.Profile = Standard
	}
	return c, nil
}
