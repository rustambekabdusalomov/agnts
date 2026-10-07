package toolchain

import (
	"regexp"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// asdfNames maps .tool-versions names to mise's.
var asdfNames = map[string]string{
	"nodejs": "node", "golang": "go", "dotnet-core": "dotnet", "python3": "python", "jdk": "java",
}

// readPins reads mise.toml, .mise.toml, .config/mise.toml and
// .tool-versions in dir. The first pin of a tool wins (root first).
func (d *detector) readPins(dir string) {
	for _, name := range []string{"mise.toml", ".mise.toml", ".config/mise.toml"} {
		for tool, ver := range miseTools(d.t.read(dir, name)) {
			d.pin(tool, ver, join(dir, name))
		}
	}
	for _, line := range strings.Split(d.t.read(dir, ".tool-versions"), "\n") {
		if i := strings.IndexByte(line, '#'); i >= 0 {
			line = line[:i]
		}
		f := strings.Fields(line)
		if len(f) < 2 {
			continue
		}
		d.pin(f[0], f[1], join(dir, ".tool-versions"))
	}
}

func (d *detector) pin(tool, ver, source string) {
	tool = strings.ToLower(strings.TrimSpace(tool))
	if n, ok := asdfNames[tool]; ok {
		tool = n
	}
	ver = strings.TrimSpace(ver)
	if tool == "node" {
		ver = nodeVersion(ver)
	}
	if ver == "" || ver == "system" || ver == "ref" || strings.HasPrefix(ver, "path:") || strings.HasPrefix(ver, "ref:") {
		return
	}
	if _, ok := d.pins[tool]; ok {
		return
	}
	d.pins[tool] = domain.Toolchain{Tool: tool, Version: ver, Source: source}
}

// miseTools reads the [tools] table of a mise.toml: name = "v",
// name = ["v1", "v2"] (first wins) and name = { version = "v" }.
// Backend-qualified names ("npm:prettier") are left out.
func miseTools(src string) map[string]string {
	out := map[string]string{}
	in := false
	for _, line := range strings.Split(src, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "[") {
			in = line == "[tools]"
			continue
		}
		if !in || line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		k, v, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		k = strings.Trim(strings.TrimSpace(k), `"'`)
		if strings.ContainsAny(k, ":/") {
			continue
		}
		if m := quoted.FindStringSubmatch(v); m != nil {
			out[k] = m[1]
		}
	}
	return out
}

var (
	quoted     = regexp.MustCompile(`["']([^"']+)["']`)
	leadingVer = regexp.MustCompile(`(\d+)(?:\.(\d+))?(?:\.(\d+))?`)
)

// ltsNames are Node's LTS code names, for .nvmrc's lts/<name>.
var ltsNames = map[string]string{
	"argon": "4", "boron": "6", "carbon": "8", "dubnium": "10", "erbium": "12", "fermium": "14",
	"gallium": "16", "hydrogen": "18", "iron": "20", "jod": "22", "krypton": "24",
}

// nodeVersion reads an .nvmrc-style version.
func nodeVersion(s string) string {
	s = strings.ToLower(strings.TrimSpace(firstLine(s)))
	s = strings.TrimPrefix(s, "v")
	switch {
	case s == "":
		return ""
	case s == "lts/*" || s == "lts" || s == "lts/latest":
		return "lts"
	case strings.HasPrefix(s, "lts/"):
		if v, ok := ltsNames[strings.TrimPrefix(s, "lts/")]; ok {
			return v
		}
		return "lts"
	case s == "node" || s == "stable" || s == "latest" || s == "current":
		return "latest"
	}
	if m := leadingVer.FindString(s); m != "" {
		return m
	}
	return ""
}

// rangeVersion turns a semver range ("^20.11.0", "18.x", ">=18",
// "20 || 22", "~3.2") into a mise prefix: the highest alternative's major
// (major.minor for ~). It returns "" for open lower bounds, where the
// caller's default (the latest LTS or stable) satisfies the range.
func rangeVersion(r string) string {
	alts := strings.Split(r, "||")
	a := strings.TrimSpace(alts[len(alts)-1])
	if a == "" || a == "*" || a == "x" {
		return ""
	}
	if (strings.HasPrefix(a, ">=") || strings.HasPrefix(a, ">")) && !strings.Contains(a, "<") {
		return ""
	}
	m := leadingVer.FindStringSubmatch(a)
	if m == nil {
		return ""
	}
	switch {
	case strings.HasPrefix(a, "~") && !strings.HasPrefix(a, "~>") && m[2] != "":
		return m[1] + "." + m[2]
	case strings.HasPrefix(a, "~>") && m[3] != "":
		return m[1] + "." + m[2]
	case strings.HasPrefix(a, "~>"):
		return m[1]
	case strings.HasPrefix(a, "^") || strings.Contains(a, "x") || strings.Contains(a, "*") || strings.HasPrefix(a, ">"):
		return m[1]
	case strings.Contains(a, "<"):
		// "<21" with no lower bound: one major below.
		if n, err := strconv.Atoi(m[1]); err == nil && n > 0 && strings.HasPrefix(a, "<") {
			return strconv.Itoa(n - 1)
		}
		return m[1]
	}
	return m[0]
}

// pythonVersion picks a CPython minor for a requires-python constraint
// such as ">=3.9,<3.12" or "^3.11": the most common modern release that
// satisfies it.
func pythonVersion(constraint string) string {
	constraint = strings.TrimSpace(constraint)
	if constraint == "" {
		return ""
	}
	prefs := []int{12, 13, 11, 10, 14, 9, 8, 7}
	for _, minor := range prefs {
		if satisfiesPython(constraint, minor) {
			return "3." + strconv.Itoa(minor)
		}
	}
	return ""
}

func satisfiesPython(constraint string, minor int) bool {
	for _, c := range strings.Split(constraint, ",") {
		c = strings.TrimSpace(c)
		m := leadingVer.FindStringSubmatch(c)
		if m == nil || m[1] != "3" {
			if m != nil && m[1] != "3" && !strings.HasPrefix(c, "<") {
				return false
			}
			continue
		}
		if m[2] == "" {
			continue // "3.*", "^3": any 3.x
		}
		want, _ := strconv.Atoi(m[2])
		op := strings.TrimSpace(c[:strings.Index(c, m[0])])
		switch op {
		case ">=", "^", "~=":
			if minor < want || (op == "~=" && m[3] != "" && minor != want) {
				return false
			}
		case ">":
			if minor < want || (minor == want && m[3] == "") {
				return false
			}
		case "<":
			if minor > want || (minor == want && m[3] == "") {
				return false
			}
		case "<=":
			if minor > want {
				return false
			}
		case "==", "", "~":
			if minor != want {
				return false
			}
		case "!=":
			if minor == want && (m[3] == "" || strings.HasSuffix(c, ".*")) {
				return false
			}
		}
	}
	return true
}

// javaMajor reads "1.8", "17", "17.0.2", "21.0.2-tem" as a major version.
func javaMajor(s string) string {
	m := leadingVer.FindStringSubmatch(s)
	if m == nil {
		return ""
	}
	if m[1] == "1" && m[2] != "" {
		return m[2]
	}
	return m[1]
}

func firstLine(s string) string {
	for _, line := range strings.Split(s, "\n") {
		if line = strings.TrimSpace(line); line != "" && !strings.HasPrefix(line, "#") {
			return line
		}
	}
	return ""
}

// find returns the first submatch of re in s, or "".
func find(re *regexp.Regexp, s string) string {
	if m := re.FindStringSubmatch(s); m != nil {
		return m[1]
	}
	return ""
}
