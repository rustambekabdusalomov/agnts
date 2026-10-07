package domain

import (
	"fmt"
	"regexp"
	"strings"
)

// Toolchain is one language runtime or build tool a repository needs in
// its run container, installed by mise into the shared toolchain volume.
type Toolchain struct {
	Tool    string `json:"tool"`             // mise name: "go", "node", "python", "rust", "java", ...
	Version string `json:"version"`          // exact or a prefix: "1.24.2", "20", "3.12", "temurin-21", "latest", "lts"
	Source  string `json:"source,omitempty"` // where it was found: "go.mod", ".nvmrc", "default", "manual"
	Dir     string `json:"dir,omitempty"`    // subdirectory it was found in, "" for the root
}

// Spec is the mise argument, tool@version.
func (t Toolchain) Spec() string { return t.Tool + "@" + t.Version }

func (t Toolchain) String() string {
	if t.Dir != "" {
		return t.Spec() + " (" + t.Dir + ")"
	}
	return t.Spec()
}

var (
	toolName    = regexp.MustCompile(`^[a-z][a-z0-9-]{0,39}$`)
	toolVersion = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9.+_-]{0,63}$`)
)

// MaxToolchains caps a repository's toolchain list.
const MaxToolchains = 12

// ParseToolchain reads "tool@version" (version defaults to "latest").
func ParseToolchain(s string) (Toolchain, error) {
	s = strings.TrimSpace(s)
	tool, ver, ok := strings.Cut(s, "@")
	if !ok || ver == "" {
		ver = "latest"
	}
	t := Toolchain{Tool: strings.ToLower(strings.TrimSpace(tool)), Version: strings.TrimSpace(ver), Source: "manual"}
	return t, t.Validate()
}

// Validate checks that a toolchain is safe to pass to mise on a command
// line: a plain tool name from a registry backend (no "asdf:" or URL) and
// a plain version.
func (t Toolchain) Validate() error {
	if !toolName.MatchString(t.Tool) {
		return fmt.Errorf("%q is not a toolchain name (examples: go, node, python, rust, java, dotnet)", t.Tool)
	}
	if !toolVersion.MatchString(t.Version) {
		return fmt.Errorf("%q is not a valid version for %s", t.Version, t.Tool)
	}
	if strings.Contains(t.Dir, "..") || strings.HasPrefix(t.Dir, "/") {
		return fmt.Errorf("toolchain directory %q must be relative to the repository", t.Dir)
	}
	return nil
}

// ValidateToolchains checks and deduplicates a list (one version per tool).
func ValidateToolchains(in []Toolchain) ([]Toolchain, error) {
	out := []Toolchain{}
	seen := map[string]bool{}
	for _, t := range in {
		t.Tool, t.Version = strings.ToLower(strings.TrimSpace(t.Tool)), strings.TrimSpace(t.Version)
		if t.Version == "" {
			t.Version = "latest"
		}
		if err := t.Validate(); err != nil {
			return nil, err
		}
		if seen[t.Tool] {
			continue
		}
		seen[t.Tool] = true
		out = append(out, t)
	}
	if len(out) > MaxToolchains {
		return nil, fmt.Errorf("at most %d toolchains", MaxToolchains)
	}
	return out, nil
}

// StackOf is the comma-separated tool list shown as a repository's stack.
func StackOf(ts []Toolchain) string {
	names := make([]string, 0, len(ts))
	for _, t := range ts {
		names = append(names, t.Tool)
	}
	return strings.Join(names, ",")
}

var imageRef = regexp.MustCompile(`^[a-z0-9][a-z0-9._/:@-]{0,254}$`)

// ValidImage checks a Docker image reference loosely (no spaces, flags or
// uppercase), enough to keep it from being anything but an image name.
func ValidImage(s string) bool { return imageRef.MatchString(s) && !strings.Contains(s, "..") }
