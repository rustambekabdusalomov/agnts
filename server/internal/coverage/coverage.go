// Package coverage reads test coverage reports (Go cover profiles and
// lcov) and measures how much of a change's added lines the tests ran.
package coverage

import (
	"bufio"
	"fmt"
	"path"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// Lines is a report: per file (relative to the repository), each
// executable line and how many times it ran.
type Lines map[string]map[int]int

// Parse reads a Go cover profile or an lcov report. modulePrefixes are
// the Go module paths and the directories they live in (from go.mod
// files: "agnts" -> "server"), to turn import paths into repository
// paths; root is the absolute path of the repository (/workspace).
func Parse(report []byte, root string, modulePrefixes map[string]string) (Lines, error) {
	text := string(report)
	if strings.HasPrefix(text, "mode:") {
		return parseGo(text, modulePrefixes)
	}
	if strings.Contains(text, "SF:") {
		return parseLcov(text, root), nil
	}
	return nil, fmt.Errorf("not a Go cover profile or an lcov report")
}

func parseGo(text string, mods map[string]string) (Lines, error) {
	out := Lines{}
	sc := bufio.NewScanner(strings.NewReader(text))
	sc.Buffer(make([]byte, 64<<10), 4<<20)
	for sc.Scan() {
		l := sc.Text()
		if strings.HasPrefix(l, "mode:") || l == "" {
			continue
		}
		// path/file.go:12.34,15.2 3 1
		colon := strings.LastIndex(l, ":")
		if colon < 0 {
			continue
		}
		file, rest := l[:colon], l[colon+1:]
		var sl, sc2, el, ec, n, count int
		if _, err := fmt.Sscanf(rest, "%d.%d,%d.%d %d %d", &sl, &sc2, &el, &ec, &n, &count); err != nil {
			continue
		}
		p := goPath(file, mods)
		m := out[p]
		if m == nil {
			m = map[int]int{}
			out[p] = m
		}
		for line := sl; line <= el; line++ {
			m[line] = max(m[line], count) // a line in several blocks ran if any of them did
		}
	}
	return out, sc.Err()
}

// goPath turns a Go import path file into a repository path, using the
// longest module prefix that matches.
func goPath(file string, mods map[string]string) string {
	best := ""
	for mod := range mods {
		if (file == mod || strings.HasPrefix(file, mod+"/")) && len(mod) > len(best) {
			best = mod
		}
	}
	if best == "" {
		return file
	}
	return path.Join(mods[best], strings.TrimPrefix(strings.TrimPrefix(file, best), "/"))
}

func parseLcov(text, root string) Lines {
	out := Lines{}
	var cur map[int]int
	for _, l := range strings.Split(text, "\n") {
		l = strings.TrimSpace(l)
		switch {
		case strings.HasPrefix(l, "SF:"):
			p := strings.TrimPrefix(l, "SF:")
			if root != "" {
				p = strings.TrimPrefix(p, strings.TrimSuffix(root, "/")+"/")
			}
			p = strings.TrimPrefix(p, "./")
			cur = out[p]
			if cur == nil {
				cur = map[int]int{}
				out[p] = cur
			}
		case strings.HasPrefix(l, "DA:") && cur != nil:
			parts := strings.Split(strings.TrimPrefix(l, "DA:"), ",")
			if len(parts) < 2 {
				continue
			}
			line, err1 := strconv.Atoi(parts[0])
			count, err2 := strconv.Atoi(parts[1])
			if err1 == nil && err2 == nil {
				cur[line] = max(cur[line], count)
			}
		case l == "end_of_record":
			cur = nil
		}
	}
	return out
}

// Measure is how much of the lines a change adds the report covers. Only
// executable lines the report knows count: comments, blank lines and
// files it does not cover (docs, configuration) do not.
func Measure(files []domain.FileChange, report Lines, threshold int) domain.Coverage {
	c := domain.Coverage{Threshold: threshold}
	for _, f := range files {
		lines := report[f.Path]
		if lines == nil {
			// A suffix match tolerates reports with paths relative to a
			// subdirectory.
			for p, ls := range report {
				if strings.HasSuffix(f.Path, "/"+p) || strings.HasSuffix(p, "/"+f.Path) {
					lines = ls
					break
				}
			}
		}
		if lines == nil {
			continue
		}
		fc := domain.FileCoverage{Path: f.Path}
		for _, n := range added(f.Diff) {
			count, ok := lines[n]
			if !ok {
				continue
			}
			fc.Total++
			if count > 0 {
				fc.Covered++
				continue
			}
			if k := len(fc.Uncovered); k > 0 && fc.Uncovered[k-1].To == n-1 {
				fc.Uncovered[k-1].To = n
			} else {
				fc.Uncovered = append(fc.Uncovered, domain.LineRange{From: n, To: n})
			}
		}
		if fc.Total > 0 {
			c.Files = append(c.Files, fc)
			c.Total += fc.Total
			c.Covered += fc.Covered
		}
	}
	if c.Total > 0 {
		c.Percent = float64(int(float64(c.Covered)/float64(c.Total)*1000+0.5)) / 10
	}
	return c
}

// added returns the numbers (in the new file) of the lines a diff adds.
func added(diff string) []int {
	var out []int
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
			out = append(out, n)
			n++
		case strings.HasPrefix(l, " "):
			n++
		}
	}
	return out
}
