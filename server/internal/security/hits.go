// Package security turns what agnts's pinned scanners write into hits,
// and finds the function around a line, for security testing (see
// domain/security.go).
package security

import (
	"cmp"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// Raw is what agnts-sec wrote, by file name under /agnts/out/sec/raw
// (opengrep.json, gitleaks.json, gitleaks-history.json, osv.json,
// trivy.json). A missing file is a tool that did not run.
type Raw map[string][]byte

// Files are the raw files a scan reads.
var Files = []string{"opengrep.json", "gitleaks.json", "gitleaks-history.json", "osv.json", "trivy.json"}

// Hits normalizes every tool's output into hits, numbered h1, h2, ... in
// a stable order. Paths matching exclude are dropped. A tool whose output
// does not parse is reported in errs by tool name; its hits are missing,
// so the caller must not count it as having run.
func Hits(raw Raw, exclude []string) (hits []domain.SecHit, errs map[string]error) {
	errs = map[string]error{}
	add := func(tool string, hs []domain.SecHit, err error) {
		if err != nil {
			errs[tool] = err
			return
		}
		for _, h := range hs {
			if h.File != "" && domain.SecExcluded(h.File, exclude) {
				continue
			}
			hits = append(hits, h)
		}
	}
	if b, ok := raw["opengrep.json"]; ok {
		hs, err := opengrep(b)
		add(domain.ToolOpengrep, hs, err)
	}
	if b, ok := raw["gitleaks.json"]; ok {
		hs, err := gitleaks(b, raw["gitleaks-history.json"])
		add(domain.ToolGitleaks, hs, err)
	}
	if b, ok := raw["osv.json"]; ok {
		hs, err := osv(b)
		add(domain.ToolOSV, hs, err)
	}
	if b, ok := raw["trivy.json"]; ok {
		hs, err := trivy(b)
		add(domain.ToolTrivy, hs, err)
	}
	for i := range hits {
		hits[i].ID = "h" + strconv.Itoa(i+1)
	}
	return hits, errs
}

// repoPath makes a scanner's path relative to the repository.
func repoPath(p string) string {
	p = strings.TrimPrefix(p, "/workspace/")
	p = strings.TrimPrefix(p, "./")
	if !domain.SafeRepoPath(p) {
		return ""
	}
	return p
}

func firstSentence(s string) string {
	s = strings.Join(strings.Fields(s), " ")
	if i := strings.Index(s, ". "); i > 0 && i < 160 {
		return s[:i]
	}
	if r := []rune(s); len(r) > 160 {
		return string(r[:159]) + "…"
	}
	return strings.TrimSuffix(s, ".")
}

// opengrep reads `opengrep scan --json`.
func opengrep(b []byte) ([]domain.SecHit, error) {
	var out struct {
		Results []struct {
			CheckID string `json:"check_id"`
			Path    string `json:"path"`
			Start   struct {
				Line   int `json:"line"`
				Offset int `json:"offset"`
			} `json:"start"`
			Extra struct {
				Message  string `json:"message"`
				Severity string `json:"severity"`
				Lines    string `json:"lines"`
				Metadata struct {
					CWE        any    `json:"cwe"`
					OWASP      any    `json:"owasp"`
					Category   string `json:"category"`
					References any    `json:"references"`
				} `json:"metadata"`
			} `json:"extra"`
		} `json:"results"`
	}
	if err := json.Unmarshal(b, &out); err != nil {
		return nil, fmt.Errorf("opengrep output: %w", err)
	}
	var hs []domain.SecHit
	// A rule can match one place several times, once for each way its
	// metavariables bind (a query built from two parameters); that is one
	// hit to triage, not several.
	type at struct {
		rule, file string
		offset     int
	}
	seen := map[at]bool{}
	for _, r := range out.Results {
		file := repoPath(r.Path)
		if file == "" {
			continue
		}
		rule := r.CheckID
		if i := strings.Index(rule, "agnts."); i >= 0 {
			rule = rule[i:] // opengrep prefixes the rules folder
		}
		k := at{rule, file, r.Start.Offset}
		if seen[k] {
			continue
		}
		seen[k] = true
		sev := domain.SecMedium
		switch strings.ToUpper(r.Extra.Severity) {
		case "ERROR":
			sev = domain.SecHigh
		case "INFO":
			sev = domain.SecLow
		}
		m := r.Extra.Metadata
		hs = append(hs, domain.SecHit{Tool: domain.ToolOpengrep, Source: domain.SecFromCode, Rule: rule, Severity: sev,
			Title: firstSentence(r.Extra.Message), Message: strings.Join(strings.Fields(r.Extra.Message), " "), File: file, Line: r.Start.Line,
			CWE: firstString(m.CWE), OWASP: firstString(m.OWASP), Category: cmp.Or(m.Category, "code"),
			Excerpt: clip(domain.MaskSecret(r.Extra.Lines), 1200), References: strings2(m.References)})
	}
	return hs, nil
}

// firstString reads a metadata value that is a string or a list.
func firstString(v any) string {
	switch x := v.(type) {
	case string:
		return x
	case []any:
		if len(x) > 0 {
			s, _ := x[0].(string)
			return s
		}
	}
	return ""
}

func strings2(v any) []string {
	var out []string
	switch x := v.(type) {
	case string:
		out = append(out, x)
	case []any:
		for _, e := range x {
			if s, ok := e.(string); ok {
				out = append(out, s)
			}
		}
	}
	return out
}

type leak struct {
	RuleID      string `json:"RuleID"`
	Description string `json:"Description"`
	StartLine   int    `json:"StartLine"`
	File        string `json:"File"`
	Secret      string `json:"Secret"`
	Commit      string `json:"Commit"`
}

// gitleaks reads gitleaks's JSON reports: the working tree, and the
// history (secrets that are only in past commits). The secret itself is
// only hashed and masked here; it never leaves this function.
func gitleaks(tree, history []byte) ([]domain.SecHit, error) {
	var t, h []leak
	if err := json.Unmarshal(tree, &t); err != nil {
		return nil, fmt.Errorf("gitleaks output: %w", err)
	}
	if len(history) > 0 {
		if err := json.Unmarshal(history, &h); err != nil {
			return nil, fmt.Errorf("gitleaks history output: %w", err)
		}
	}
	var hs []domain.SecHit
	inTree := map[string]bool{}
	for _, l := range t {
		file := repoPath(l.File)
		if file == "" || l.Secret == "" {
			continue
		}
		sum := secretHash(l.Secret)
		inTree[sum] = true
		hs = append(hs, domain.SecHit{Tool: domain.ToolGitleaks, Source: domain.SecFromSecret, Rule: l.RuleID,
			Severity: domain.SecHigh, Title: secretTitle(l.RuleID) + " committed", File: file, Line: l.StartLine,
			CWE: "CWE-798", OWASP: "A07", Category: "secret", Message: firstSentence(l.Description),
			SecretMask: maskSecret(l.Secret), SecretHash: sum})
	}
	seen := map[string]bool{}
	for _, l := range h {
		if l.Secret == "" {
			continue
		}
		sum := secretHash(l.Secret)
		if inTree[sum] || seen[sum] {
			continue
		}
		seen[sum] = true
		hs = append(hs, domain.SecHit{Tool: domain.ToolGitleaks, Source: domain.SecFromHistory, Rule: l.RuleID,
			Severity: domain.SecHigh, Title: secretTitle(l.RuleID) + " in the git history", File: repoPath(l.File), Line: l.StartLine,
			CWE: "CWE-798", OWASP: "A07", Category: "secret", Commit: l.Commit,
			Message:    "Removed from the code but still in commit " + shortSHA(l.Commit) + ": anyone with the repository can read it. Rotate it.",
			SecretMask: maskSecret(l.Secret), SecretHash: sum})
	}
	return hs, nil
}

func secretHash(s string) string {
	sum := sha256.Sum256([]byte(s))
	return hex.EncodeToString(sum[:])
}

// maskSecret keeps the first four characters of a secret.
func maskSecret(s string) string {
	r := []rune(s)
	if len(r) <= 8 {
		return "****"
	}
	return string(r[:4]) + strings.Repeat("*", min(len(r)-4, 12))
}

func secretTitle(rule string) string {
	t := strings.ReplaceAll(rule, "-", " ")
	if t == "" {
		return "Secret"
	}
	return strings.ToUpper(t[:1]) + t[1:]
}

func shortSHA(s string) string {
	if len(s) > 7 {
		return s[:7]
	}
	return s
}

// osv reads `osv-scanner --format json`: one hit per vulnerable package
// in a lockfile, with every advisory and the version that fixes them all.
func osv(b []byte) ([]domain.SecHit, error) {
	var out struct {
		Results []struct {
			Source struct {
				Path string `json:"path"`
			} `json:"source"`
			Packages []struct {
				Package struct {
					Name      string `json:"name"`
					Version   string `json:"version"`
					Ecosystem string `json:"ecosystem"`
				} `json:"package"`
				Vulnerabilities []struct {
					ID       string   `json:"id"`
					Aliases  []string `json:"aliases"`
					Summary  string   `json:"summary"`
					Affected []struct {
						Package struct {
							Name string `json:"name"`
						} `json:"package"`
						Ranges []struct {
							Events []struct {
								Introduced string `json:"introduced"`
								Fixed      string `json:"fixed"`
							} `json:"events"`
						} `json:"ranges"`
					} `json:"affected"`
				} `json:"vulnerabilities"`
				Groups []struct {
					IDs         []string `json:"ids"`
					MaxSeverity string   `json:"max_severity"`
				} `json:"groups"`
			} `json:"packages"`
		} `json:"results"`
	}
	if err := json.Unmarshal(b, &out); err != nil {
		return nil, fmt.Errorf("osv-scanner output: %w", err)
	}
	var hs []domain.SecHit
	for _, r := range out.Results {
		file := repoPath(r.Source.Path)
		for _, p := range r.Packages {
			if len(p.Vulnerabilities) == 0 {
				continue
			}
			var ids, cves, summaries []string
			fixedIn := ""
			for _, v := range p.Vulnerabilities {
				ids = append(ids, v.ID)
				for _, a := range v.Aliases {
					if strings.HasPrefix(a, "CVE-") && !slices.Contains(cves, a) {
						cves = append(cves, a)
					}
				}
				if v.Summary != "" && len(summaries) < 3 {
					summaries = append(summaries, v.Summary)
				}
				// The lowest fix above the installed version, per advisory;
				// the package needs the highest of those.
				best := ""
				for _, a := range v.Affected {
					if a.Package.Name != "" && a.Package.Name != p.Package.Name {
						continue
					}
					for _, rg := range a.Ranges {
						for _, e := range rg.Events {
							if e.Fixed != "" && compareVersions(e.Fixed, p.Package.Version) > 0 && (best == "" || compareVersions(e.Fixed, best) < 0) {
								best = e.Fixed
							}
						}
					}
				}
				if best != "" && (fixedIn == "" || compareVersions(best, fixedIn) > 0) {
					fixedIn = best
				}
			}
			slices.Sort(ids)
			score := 0.0
			for _, g := range p.Groups {
				if f, err := strconv.ParseFloat(g.MaxSeverity, 64); err == nil && f > score {
					score = f
				}
			}
			title := fmt.Sprintf("%s %s has %d known vulnerabilities", p.Package.Name, p.Package.Version, len(ids))
			if len(ids) == 1 {
				title = fmt.Sprintf("%s %s has a known vulnerability", p.Package.Name, p.Package.Version)
			}
			msg := strings.Join(summaries, "; ")
			if fixedIn != "" {
				msg += ". Fixed in " + fixedIn + "."
			}
			var refs []string
			for _, id := range ids {
				if len(refs) < 5 {
					refs = append(refs, "https://osv.dev/vulnerability/"+id)
				}
			}
			cvss := ""
			if score > 0 {
				cvss = strconv.FormatFloat(score, 'f', 1, 64)
			}
			hs = append(hs, domain.SecHit{Tool: domain.ToolOSV, Source: domain.SecFromDependency, Rule: ids[0],
				Severity: cvssSeverity(score), Title: title, Message: msg, File: file, CWE: "CWE-1395", OWASP: "A06",
				Category: "dependency", Ecosystem: p.Package.Ecosystem, Package: p.Package.Name, Version: p.Package.Version,
				FixedIn: fixedIn, Advisories: append(ids, cves...), CVSS: cvss, References: refs})
		}
	}
	return hs, nil
}

// cvssSeverity maps a CVSS score to a severity; no score is medium.
func cvssSeverity(score float64) domain.SecSeverity {
	switch {
	case score >= 9:
		return domain.SecCritical
	case score >= 7:
		return domain.SecHigh
	case score >= 4 || score == 0:
		return domain.SecMedium
	}
	return domain.SecLow
}

// compareVersions compares dotted versions numerically where it can
// (4.17.9 < 4.17.21), then as text.
func compareVersions(a, b string) int {
	pa, pb := splitVersion(a), splitVersion(b)
	for i := range max(len(pa), len(pb)) {
		var x, y string
		if i < len(pa) {
			x = pa[i]
		}
		if i < len(pb) {
			y = pb[i]
		}
		nx, ex := strconv.Atoi(x)
		ny, ey := strconv.Atoi(y)
		switch {
		case ex == nil && ey == nil:
			if c := cmp.Compare(nx, ny); c != 0 {
				return c
			}
		case x == "":
			return -1
		case y == "":
			return 1
		default:
			if c := strings.Compare(x, y); c != 0 {
				return c
			}
		}
	}
	return 0
}

func splitVersion(v string) []string {
	v = strings.TrimPrefix(v, "v")
	return strings.FieldsFunc(v, func(r rune) bool { return r == '.' || r == '-' || r == '+' })
}

// trivy reads `trivy config --format json`: one hit per failed check.
func trivy(b []byte) ([]domain.SecHit, error) {
	var out struct {
		Results []struct {
			Target            string `json:"Target"`
			Misconfigurations []struct {
				ID            string   `json:"ID"`
				Title         string   `json:"Title"`
				Message       string   `json:"Message"`
				Resolution    string   `json:"Resolution"`
				Severity      string   `json:"Severity"`
				PrimaryURL    string   `json:"PrimaryURL"`
				Status        string   `json:"Status"`
				References    []string `json:"References"`
				CauseMetadata struct {
					StartLine int `json:"StartLine"`
				} `json:"CauseMetadata"`
			} `json:"Misconfigurations"`
		} `json:"Results"`
	}
	if err := json.Unmarshal(b, &out); err != nil {
		return nil, fmt.Errorf("trivy output: %w", err)
	}
	var hs []domain.SecHit
	for _, r := range out.Results {
		file := repoPath(r.Target)
		for _, m := range r.Misconfigurations {
			if m.Status != "" && m.Status != "FAIL" {
				continue
			}
			sev := domain.SecSeverity(strings.ToLower(m.Severity))
			if !sev.Valid() || sev == domain.SecInfo {
				sev = domain.SecLow
			}
			msg := m.Message
			if m.Resolution != "" {
				msg += ". " + m.Resolution
			}
			refs := m.References
			if len(refs) > 3 {
				refs = refs[:3]
			}
			hs = append(hs, domain.SecHit{Tool: domain.ToolTrivy, Source: domain.SecFromConfig, Rule: m.ID, Severity: sev,
				Title: m.Title, Message: msg, File: file, Line: m.CauseMetadata.StartLine, Category: "misconfig", OWASP: "A05",
				References: refs})
		}
	}
	return hs, nil
}

func clip(s string, n int) string {
	if r := []rune(s); len(r) > n {
		return string(r[:n-1]) + "…"
	}
	return s
}
