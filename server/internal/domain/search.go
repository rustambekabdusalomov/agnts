package domain

import (
	"strings"
	"unicode"
	"unicode/utf8"
)

// Marks around the matched words in a search snippet. Clients turn them
// into highlights; they are control characters, so text never holds them.
const (
	SearchMarkStart = "\x02"
	SearchMarkEnd   = "\x03"
)

// Limits on a chat search.
const (
	SearchMinRunes = 2  // a word shorter than this is left out
	SearchMaxWords = 8  // words of a query used
	SearchLimit    = 40 // hits returned
)

// SearchWords splits a search query into its lower-case words (letters and
// digits, any script), each at least SearchMinRunes long, without repeats,
// at most SearchMaxWords. Every word must match (as a word's start).
func SearchWords(q string) []string {
	var out []string
	for _, w := range strings.FieldsFunc(strings.ToLower(q), func(r rune) bool { return !unicode.IsLetter(r) && !unicode.IsDigit(r) }) {
		if utf8.RuneCountInString(w) < SearchMinRunes || contains(out, w) {
			continue
		}
		out = append(out, w)
		if len(out) == SearchMaxWords {
			break
		}
	}
	return out
}

func contains(ws []string, w string) bool {
	for _, x := range ws {
		if x == w {
			return true
		}
	}
	return false
}

// SearchSnippet is the part of text around the first of words it holds, at
// most about width runes on one line, with every occurrence of the words
// marked (SearchMarkStart … SearchMarkEnd). Text that holds none of them
// is cut from its start.
func SearchSnippet(text string, words []string, width int) string {
	r := []rune(strings.Join(strings.Fields(text), " "))
	lower := []rune(strings.ToLower(string(r)))
	if len(lower) != len(r) { // a rune whose lower case is longer: no marks
		return cut(r, 0, width)
	}
	type span struct{ from, to int }
	var spans []span
	for i := 0; i < len(lower); i++ {
		if i > 0 && (unicode.IsLetter(lower[i-1]) || unicode.IsDigit(lower[i-1])) {
			continue // matches start words
		}
		for _, w := range words {
			wr := []rune(w)
			if i+len(wr) <= len(lower) && string(lower[i:i+len(wr)]) == w {
				spans = append(spans, span{i, i + len(wr)})
				i += len(wr) - 1
				break
			}
		}
	}
	start := 0
	if len(spans) > 0 && spans[0].from > width/3 {
		start = spans[0].from - width/3
	}
	end := min(len(r), start+width)
	var b strings.Builder
	if start > 0 {
		b.WriteString("…")
	}
	at := start
	for _, s := range spans {
		if s.from < start || s.to > end {
			continue
		}
		b.WriteString(string(r[at:s.from]))
		b.WriteString(SearchMarkStart + string(r[s.from:s.to]) + SearchMarkEnd)
		at = s.to
	}
	b.WriteString(string(r[at:end]))
	if end < len(r) {
		b.WriteString("…")
	}
	return b.String()
}

func cut(r []rune, start, width int) string {
	if len(r) <= width {
		return string(r)
	}
	return string(r[start:start+width]) + "…"
}
