// Package agentcfg scans a repository's instructions and configuration for
// AI agents (CLAUDE.md, AGENTS.md, .claude/, .mcp.json, Cursor and Copilot
// rules) for text that tries to steer an agent: hidden characters,
// instructions aimed at the agent, commands that send data out. agnts never
// runs a repository's hooks or MCP servers (managed settings forbid them),
// but it does read these files, so people see what they contain. It never
// blocks; it informs.
package agentcfg

import (
	"encoding/json"
	"fmt"
	"path"
	"regexp"
	"slices"
	"strings"
	"unicode/utf8"

	"agnts/internal/domain"
)

// Finding kinds.
const (
	KindHidden      = "hidden_unicode"    // invisible or direction-changing characters
	KindInstruction = "agent_instruction" // text that tries to steer an agent
	KindExfil       = "exfiltration"      // a command that sends data out or runs fetched code
	KindBlob        = "encoded_blob"      // a long encoded string in an instructions file
	KindHooks       = "hooks"             // Claude Code hooks (agnts ignores them)
	KindMCP         = "mcp_server"        // MCP servers (agnts ignores them)
)

// Severities.
const (
	High   = "high"
	Medium = "medium"
	Info   = "info"
)

// Finding is one thing the scan found.
type Finding = domain.AgentConfigFinding

// MaxFindings caps one scan.
const MaxFindings = 30

// Wanted reports whether p is an agent instructions or configuration file.
func Wanted(p string) bool {
	base := path.Base(p)
	switch base {
	case "CLAUDE.md", "CLAUDE.local.md", "AGENTS.md", "GEMINI.md", ".mcp.json", ".cursorrules", ".windsurfrules", ".clinerules", "copilot-instructions.md":
		return true
	}
	return strings.HasPrefix(p, ".claude/") || strings.Contains(p, "/.claude/") ||
		strings.HasPrefix(p, ".cursor/rules/") || strings.HasPrefix(p, ".github/instructions/")
}

var (
	reInstruction = regexp.MustCompile(`(?i)\b(ignore|disregard|forget|override)\b.{0,30}\b(previous|prior|above|earlier|all|system|your)\b.{0,20}\b(instructions?|rules?|prompts?|guidelines?)\b` +
		`|\byou are now\b|\bnew instructions?:|\bdo not (tell|inform|mention|reveal)\b.{0,30}\b(user|reviewer|developer|human|person)\b` +
		`|\b(approve|merge|accept)\b.{0,20}\b(this|the)\b.{0,10}\b(pull request|PR|merge request|change)\b.{0,40}\b(without|regardless|no matter)\b` +
		`|"?verdict"?\s*[:=]\s*"?looks_good|\bmark (it|this|the change) as (safe|approved|looks[_ ]good)\b` +
		`|\b(print|reveal|show|send|post|upload|exfiltrate)\b.{0,30}\b(environment variables|env vars|api keys?|tokens?|secrets?|credentials?|ssh keys?)\b.{0,30}\b(to|into|at)\b`)
	reExfil = regexp.MustCompile(`(?i)\b(curl|wget)\b[^\n]*\bhttps?://|\bnc\s+-|\bncat\b|/dev/tcp/|\bbase64\s+(-d|--decode)\b[^\n]*\|\s*(ba)?sh\b|\|\s*(ba)?sh\b|\beval\s*["'$(]|\bpython3?\s+-c\b|\bnode\s+-e\b`)
	reBlob  = regexp.MustCompile(`[A-Za-z0-9+/=_-]{200,}`)
)

// hidden reports the first invisible or direction-changing character in s.
func hidden(s string) (rune, bool) {
	for i, r := range s {
		switch {
		case r == 0xFEFF && i == 0: // a byte order mark at the start is harmless
		case r >= 0x200B && r <= 0x200F, r >= 0x202A && r <= 0x202E, r >= 0x2060 && r <= 0x2064,
			r >= 0x2066 && r <= 0x2069, r == 0xFEFF, r == 0x00AD, r >= 0xE0000 && r <= 0xE007F:
			return r, true
		}
	}
	return 0, false
}

// ScanFile scans one file's content.
func ScanFile(p string, content []byte) []Finding {
	if !Wanted(p) || !utf8.Valid(content) {
		return nil
	}
	var out []Finding
	add := func(f Finding) {
		if len(out) < MaxFindings {
			f.Path, f.Text = p, clip(strings.TrimSpace(f.Text), 200)
			out = append(out, f)
		}
	}
	isConfig := strings.HasSuffix(p, ".json")
	for i, l := range strings.Split(string(content), "\n") {
		out = append(out, scanLine(p, i+1, l, isConfig)...)
	}
	if isConfig {
		var cfg struct {
			Hooks      map[string]json.RawMessage `json:"hooks"`
			MCPServers map[string]json.RawMessage `json:"mcpServers"`
		}
		if json.Unmarshal(content, &cfg) == nil {
			if len(cfg.Hooks) > 0 {
				events := make([]string, 0, len(cfg.Hooks))
				for e := range cfg.Hooks {
					events = append(events, e)
				}
				slices.Sort(events)
				add(Finding{Kind: KindHooks, Severity: Info, Text: "defines Claude Code hooks (" + strings.Join(events, ", ") + "); agnts does not run them"})
			}
			if len(cfg.MCPServers) > 0 {
				names := make([]string, 0, len(cfg.MCPServers))
				for n := range cfg.MCPServers {
					names = append(names, n)
				}
				slices.Sort(names)
				add(Finding{Kind: KindMCP, Severity: Info, Text: "defines MCP servers (" + strings.Join(names, ", ") + "); agnts does not start them"})
			}
		}
	}
	if len(out) > MaxFindings {
		out = out[:MaxFindings]
	}
	return out
}

func scanLine(p string, n int, l string, isConfig bool) []Finding {
	var out []Finding
	if r, ok := hidden(l); ok {
		out = append(out, Finding{Path: p, Line: n, Kind: KindHidden, Severity: High,
			Text: fmt.Sprintf("invisible character U+%04X in: %s", r, clip(visible(l), 160))})
	}
	if m := reInstruction.FindString(l); m != "" {
		out = append(out, Finding{Path: p, Line: n, Kind: KindInstruction, Severity: High, Text: clip(strings.TrimSpace(l), 200)})
	}
	if isConfig && reExfil.MatchString(l) {
		out = append(out, Finding{Path: p, Line: n, Kind: KindExfil, Severity: High, Text: clip(strings.TrimSpace(l), 200)})
	}
	if reBlob.MatchString(l) {
		out = append(out, Finding{Path: p, Line: n, Kind: KindBlob, Severity: Medium, Text: fmt.Sprintf("an encoded string of %d characters", len(reBlob.FindString(l)))})
	}
	return out
}

// visible replaces invisible characters with a marker, so the text shows
// where they are.
func visible(s string) string {
	var b strings.Builder
	for _, r := range s {
		if _, ok := hidden(string(r)); ok {
			fmt.Fprintf(&b, "[U+%04X]", r)
			continue
		}
		b.WriteRune(r)
	}
	return b.String()
}

// ScanTree scans every agent file in a repository listing (path → content;
// files without content are skipped).
func ScanTree(files map[string][]byte) []Finding {
	paths := make([]string, 0, len(files))
	for p, b := range files {
		if b != nil && Wanted(p) {
			paths = append(paths, p)
		}
	}
	slices.Sort(paths)
	var out []Finding
	for _, p := range paths {
		out = append(out, ScanFile(p, files[p])...)
		if len(out) >= MaxFindings {
			return out[:MaxFindings]
		}
	}
	return out
}

// ScanChange scans the lines a change adds to agent files: what a pull
// request would put in front of the next agent that works on the code.
func ScanChange(files []domain.FileChange) []Finding {
	var out []Finding
	for _, f := range files {
		if !Wanted(f.Path) {
			continue
		}
		isConfig := strings.HasSuffix(f.Path, ".json")
		var added []string
		line := 0
		for _, l := range strings.Split(f.Diff, "\n") {
			switch {
			case strings.HasPrefix(l, "@@"):
				if _, after, ok := strings.Cut(l, "+"); ok {
					_, _ = fmt.Sscanf(after, "%d", &line)
				}
			case strings.HasPrefix(l, "+++"), strings.HasPrefix(l, "---"):
			case strings.HasPrefix(l, "+"):
				out = append(out, scanLine(f.Path, line, l[1:], isConfig)...)
				added = append(added, l[1:])
				line++
			case strings.HasPrefix(l, " "):
				line++
			}
		}
		if isConfig {
			joined := strings.Join(added, "\n")
			if strings.Contains(joined, `"hooks"`) {
				out = append(out, Finding{Path: f.Path, Kind: KindHooks, Severity: Medium, Text: "adds Claude Code hooks: commands an agent's harness would run on every tool call"})
			}
			if strings.Contains(joined, `"mcpServers"`) {
				out = append(out, Finding{Path: f.Path, Kind: KindMCP, Severity: Medium, Text: "adds MCP servers an agent would start"})
			}
		}
		if len(out) >= MaxFindings {
			return out[:MaxFindings]
		}
	}
	return out
}

// Serious keeps the findings worth a person's attention: high and medium.
func Serious(fs []Finding) []Finding {
	var out []Finding
	for _, f := range fs {
		if f.Severity == High || f.Severity == Medium {
			out = append(out, f)
		}
	}
	return out
}

func clip(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}
