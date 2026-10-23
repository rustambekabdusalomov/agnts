package domain

import (
	"regexp"
	"strings"
	"unicode/utf8"
)

// SlideLayout is how a slide is laid out, chosen from its content so the
// page, the public page, the phone and the PDF (printed without scripts)
// all agree.
type SlideLayout string

// Slide layouts.
const (
	// SlideLead is a title or section slide: headings and at most two short
	// lines, centered and large.
	SlideLead SlideLayout = "lead"
	// SlideNormal is a slide of ordinary length.
	SlideNormal SlideLayout = "normal"
	// SlideDense and SlideDenser have more text, in a smaller font.
	SlideDense  SlideLayout = "dense"
	SlideDenser SlideLayout = "denser"
)

// Slide is one slide of a deck.
type Slide struct {
	Body   string // Markdown
	Notes  string // the speaker's, not shown on the slide
	Layout SlideLayout
}

// frontMatterLine is a "key: value" line of Marp's front matter.
var frontMatterLine = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_-]*:`)

// listOrBlock starts a line that is not plain text: a list item, a table
// row, a fence or a quote.
var listOrBlock = regexp.MustCompile(`^([-*+] |\d+[.)] |\||` + "```" + `|~~~|>)`)

// SplitSlides cuts a deck's text into slides. A line that is exactly ---
// (spaces around it allowed) outside a code fence separates slides; a
// line starting with "Notes:" (any case) begins the speaker notes of its
// slide. Empty slides are dropped, and Marp's front matter is skipped.
// slides.ts and slides.dart follow the same rule.
func SplitSlides(body string) []Slide {
	lines := strings.Split(strings.ReplaceAll(body, "\r\n", "\n"), "\n")
	lines = skipFrontMatter(lines)
	var out []Slide
	var cur, notes []string
	inNotes := false
	fence := ""
	flush := func() {
		b := strings.TrimSpace(strings.Join(cur, "\n"))
		if b != "" {
			out = append(out, Slide{Body: b, Notes: strings.TrimSpace(strings.Join(notes, "\n")), Layout: slideLayout(b)})
		}
		cur, notes, inNotes = nil, nil, false
	}
	for _, line := range lines {
		t := strings.TrimSpace(line)
		if fence != "" {
			if strings.HasPrefix(t, fence) && strings.Trim(t, fence[:1]) == "" {
				fence = ""
			}
		} else if f := fenceOf(t); f != "" {
			fence = f
		} else if t == "---" {
			flush()
			continue
		} else if !inNotes && strings.HasPrefix(strings.ToLower(t), "notes:") {
			inNotes = true
			notes = append(notes, strings.TrimSpace(t[len("notes:"):]))
			continue
		}
		if inNotes {
			notes = append(notes, line)
		} else {
			cur = append(cur, line)
		}
	}
	flush()
	return out
}

// fenceOf is the fence a line opens (``` or ~~~, three or more), "" when
// it opens none.
func fenceOf(t string) string {
	for _, c := range []string{"`", "~"} {
		if strings.HasPrefix(t, c+c+c) {
			n := len(t) - len(strings.TrimLeft(t, c))
			return strings.Repeat(c, n)
		}
	}
	return ""
}

// skipFrontMatter drops a leading block of "key: value" lines between two
// --- lines.
func skipFrontMatter(lines []string) []string {
	if len(lines) < 3 || strings.TrimSpace(lines[0]) != "---" {
		return lines
	}
	for i := 1; i < len(lines); i++ {
		t := strings.TrimSpace(lines[i])
		if t == "---" {
			if i == 1 {
				return lines
			}
			return lines[i+1:]
		}
		if t != "" && !frontMatterLine.MatchString(t) {
			return lines
		}
	}
	return lines
}

// slideLayout picks a slide's layout from its text: lead for headings
// and at most two short lines of text, then by how much text there is.
func slideLayout(body string) SlideLayout {
	var lines []string
	runes := 0
	for _, l := range strings.Split(body, "\n") {
		if t := strings.TrimSpace(l); t != "" {
			lines = append(lines, t)
			runes += utf8.RuneCountInString(t)
		}
	}
	heading, others, plain := false, 0, true
	for _, l := range lines {
		if strings.HasPrefix(l, "#") {
			heading = true
			continue
		}
		others++
		if listOrBlock.MatchString(l) || utf8.RuneCountInString(l) > 160 {
			plain = false
		}
	}
	if heading && plain && others <= 2 {
		return SlideLead
	}
	switch w := len(lines) + runes/90; {
	case w > 18:
		return SlideDenser
	case w > 12:
		return SlideDense
	}
	return SlideNormal
}

// SlidesWithoutNotes is a deck's text without its speaker notes, for
// readers outside the workspace.
func SlidesWithoutNotes(body string) string {
	slides := SplitSlides(body)
	parts := make([]string, len(slides))
	for i, s := range slides {
		parts[i] = s.Body
	}
	return strings.Join(parts, "\n\n---\n\n")
}
