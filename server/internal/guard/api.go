package guard

import (
	"encoding/json"
	"path"
	"regexp"
	"strings"
)

// preAPI enforces a Swagger test run's two rules: the credential file is
// agnts-api's alone, and only agnts-api calls the API under test (it adds
// the credential, keeps to the base URL host and the read-only mode, and
// logs every exchange as evidence). It reports whether it blocked.
func (h *handler) preAPI() bool {
	g := h.cfg.API
	if mentionsAuth(string(h.in.ToolInput), g) {
		h.block(HookAPI, "api-credential", g.AuthPath, "agnts-guard: the API credential is for agnts-api alone. Never read, copy, print or search it: agnts-api adds it to every request.")
		return true
	}
	var in struct {
		Path    string `json:"path"`
		Pattern string `json:"pattern"`
		Command string `json:"command"`
	}
	_ = json.Unmarshal(h.in.ToolInput, &in)
	switch h.in.ToolName {
	case "Grep", "Glob", "LS":
		// A search from the credential's folder or any folder above it
		// would read the file too.
		p := in.Path
		if p == "" && h.in.ToolName != "LS" {
			p = h.cwd()
		}
		if p != "" && contains(h.abs(p), g.InDir) {
			h.block(HookAPI, "api-credential", p, "agnts-guard: do not search "+p+": it holds the API credential. Read the spec and test files by name ("+g.InDir+"/spec.json, test.json).")
			return true
		}
	case "Bash":
		cmd := in.Command
		if g.Host != "" && callsHost(cmd, g.Host) {
			h.block(HookAPI, "api-client", "", "agnts-guard: call the API under test only with agnts-api (agnts-api <METHOD> <path>, or agnts-api run <plan.json>): it adds the credential, keeps to the test's rules and logs the evidence. Other clients are refused.")
			return true
		}
		if touchesInDir(cmd, g.InDir) {
			h.block(HookAPI, "api-credential", g.InDir, "agnts-guard: this command could read the API credential in "+g.InDir+". Read the spec and test files by name with Read instead.")
			return true
		}
	}
	return false
}

// mentionsAuth reports whether a tool's input names the credential file.
func mentionsAuth(input string, g *APIGuard) bool {
	return strings.Contains(input, g.AuthPath) || strings.Contains(input, path.Base(g.AuthPath)) && strings.Contains(input, "api")
}

// contains reports whether dir is p or a folder inside p.
func contains(p, dir string) bool {
	p, dir = path.Clean(p), path.Clean(dir)
	return p == dir || p == "/" || strings.HasPrefix(dir, p+"/")
}

var (
	// clients that make HTTP requests.
	reClient = regexp.MustCompile(`(?i)(^|[\s;&|(` + "`" + `$])(curl|wget|http|https|xh|httpie|nc|ncat|netcat|socat|telnet|openssl\s+s_client|python[0-9.]*|node|deno|bun|ruby|perl|php|go\s+run)\b`)
	// recursive readers, archivers and globs that would take a dotfile in.
	reSweep = regexp.MustCompile(`(?i)(\b(grep|egrep|rg|ag|ack)\b[^|;&]*\s-[a-zA-Z]*[rR]|\b(rg|ag|ack|find|tar|zip|rsync|du)\b|\bcp\s+-[a-zA-Z]*[rRa]|\bls\s+-[a-zA-Z]*a|[*?\[])`)
)

// callsHost reports whether a command calls host with another HTTP client
// (agnts-api itself, given a full URL, is fine).
func callsHost(cmd, host string) bool {
	host = strings.ToLower(host)
	if !strings.Contains(strings.ToLower(cmd), host) {
		return false
	}
	// Leave out agnts-api's own invocations; anything else that names the
	// host next to an HTTP client (even quoted, as in python -c "...") is
	// another client.
	var rest []string
	for _, seg := range reSegment.Split(cmd, -1) {
		words := strings.Fields(seg)
		for len(words) > 0 && strings.Contains(words[0], "=") {
			words = words[1:] // VAR=value before the command
		}
		if len(words) > 0 && path.Base(words[0]) == "agnts-api" {
			continue
		}
		rest = append(rest, seg)
	}
	other := strings.Join(rest, ";")
	return strings.Contains(strings.ToLower(other), host) && reClient.MatchString(other)
}

var reSegment = regexp.MustCompile(`[;&|\n]+`)

// touchesInDir reports whether a command could read the credential's
// folder wholesale: a glob or dotfile under it, or a recursive tool or glob
// aimed at it or a folder above it.
func touchesInDir(cmd, inDir string) bool {
	inDir = path.Clean(inDir)
	sweep := reSweep.MatchString(cmd)
	for _, tok := range rePath.FindAllString(cmd, -1) {
		t := strings.TrimRight(tok, "/")
		if t == "" {
			t = "/"
		}
		stem := t
		if i := strings.IndexAny(t, "*?["); i >= 0 {
			stem = path.Dir(t[:i] + "x")
		}
		switch {
		case strings.HasPrefix(t, inDir+"/"):
			if strings.ContainsAny(t, "*?[") || strings.Contains(strings.TrimPrefix(t, inDir), "/.") {
				return true
			}
		case contains(stem, inDir) && (sweep || stem != t):
			return true
		}
	}
	return false
}

var rePath = regexp.MustCompile(`/[^\s'"|;&<>()]*`)
