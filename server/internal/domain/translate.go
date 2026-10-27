package domain

import (
	"regexp"
	"strings"
	"unicode"
)

// Segment is a piece of a document's text: a Markdown block to translate,
// or text kept as written (code, separators, blank lines, the Notes:
// marker). Joined in order, the segments are the text again.
type Segment struct {
	Text      string
	Translate bool
}

// onlyLink is a block that is just an image, a link or a URL: nothing to
// translate.
var onlyLink = regexp.MustCompile(`^(!?\[[^\]]*\]\([^)]*\)|<?https?://\S+>?)$`)

// SegmentDocument cuts a document's body into segments. Blocks are split
// by blank lines; fenced code, --- lines, a deck's front matter and the
// Notes: marker that starts a slide's speaker notes are kept, so the
// joined translation splits into the same slides (SplitSlides).
func SegmentDocument(k DocumentKind, body string) []Segment {
	lines := strings.Split(strings.ReplaceAll(body, "\r\n", "\n"), "\n")
	var out []Segment
	keep := func(s string) {
		if s == "" {
			return
		}
		if n := len(out); n > 0 && !out[n-1].Translate {
			out[n-1].Text += s
			return
		}
		out = append(out, Segment{Text: s})
	}
	// block is the block being read; blockNL ends its last line.
	var block []string
	blockNL := ""
	flush := func() {
		if len(block) == 0 {
			return
		}
		text := strings.Join(block, "\n")
		block = nil
		if t := strings.TrimSpace(text); !hasLetter(t) || onlyLink.MatchString(t) {
			keep(text)
		} else {
			out = append(out, Segment{Text: text, Translate: true})
		}
		keep(blockNL)
	}
	start := 0
	if k == DocKindSlides {
		start = len(lines) - len(skipFrontMatter(lines))
		if start > 0 {
			keep(strings.Join(lines[:start], "\n") + "\n")
		}
	}
	fence := ""
	for i := start; i < len(lines); i++ {
		line, t := lines[i], strings.TrimSpace(lines[i])
		nl := "\n"
		if i == len(lines)-1 {
			nl = ""
		}
		switch {
		case fence != "":
			keep(line + nl)
			if strings.HasPrefix(t, fence) && strings.Trim(t, fence[:1]) == "" {
				fence = ""
			}
			continue
		case fenceOf(t) != "":
			flush()
			fence = fenceOf(t)
			keep(line + nl)
			continue
		case t == "" || t == "---":
			flush()
			keep(line + nl)
			continue
		case k == DocKindSlides && len(block) == 0 && strings.HasPrefix(strings.ToLower(t), "notes:"):
			// The marker stays; the note after it is translated.
			lead := len(line) - len(strings.TrimLeft(line, " \t"))
			cut := lead + len("notes:")
			cut += len(line[cut:]) - len(strings.TrimLeft(line[cut:], " \t"))
			keep(line[:cut])
			if line[cut:] == "" {
				keep(nl)
				continue
			}
			line = line[cut:]
		}
		block, blockNL = append(block, line), nl
	}
	flush()
	return out
}

// hasLetter reports whether s has a letter of any script.
func hasLetter(s string) bool {
	for _, r := range s {
		if unicode.IsLetter(r) {
			return true
		}
	}
	return false
}

// SegmentTexts lists the distinct texts of segments to translate.
func SegmentTexts(segs []Segment) []string {
	var out []string
	seen := map[string]bool{}
	for _, s := range segs {
		if s.Translate && !seen[s.Text] {
			seen[s.Text] = true
			out = append(out, s.Text)
		}
	}
	return out
}

// JoinSegments puts a translated text back together: each block replaced
// by its translation, kept text as it was. A block with no translation,
// or one whose translation would change the text's structure (a blank
// line, a --- line or a code fence that would split it), stays as
// written. It reports whether every block was translated.
func JoinSegments(segs []Segment, tr map[string]string) (string, bool) {
	var b strings.Builder
	complete := true
	for _, s := range segs {
		t, ok := tr[s.Text]
		if s.Translate && ok && keepsShape(t) {
			// The block's indent stays: it can put it inside a list.
			b.WriteString(s.Text[:len(s.Text)-len(strings.TrimLeft(s.Text, " \t"))])
			b.WriteString(strings.TrimSpace(t))
			continue
		}
		if s.Translate {
			complete = false
		}
		b.WriteString(s.Text)
	}
	return b.String(), complete
}

// keepsShape reports whether a translated block is one block still.
func keepsShape(t string) bool {
	t = strings.TrimSpace(t)
	if t == "" {
		return false
	}
	for line := range strings.SplitSeq(t, "\n") {
		l := strings.TrimSpace(line)
		if l == "" || l == "---" || fenceOf(l) != "" {
			return false
		}
	}
	return true
}
