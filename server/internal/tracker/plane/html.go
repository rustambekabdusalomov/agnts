package plane

import (
	"html"
	"regexp"
	"strings"

	xhtml "golang.org/x/net/html"
	"golang.org/x/net/html/atom"
)

// textFromHTML turns a Plane description (editor HTML) into the plain
// text agnts gives Claude: paragraphs, "- " list items, fenced code blocks
// and links as "text (url)".
func textFromHTML(s string) string {
	if strings.TrimSpace(s) == "" {
		return ""
	}
	doc, err := xhtml.Parse(strings.NewReader(s))
	if err != nil {
		return strings.TrimSpace(html.UnescapeString(s))
	}
	var b strings.Builder
	var walk func(n *xhtml.Node, pre bool)
	walk = func(n *xhtml.Node, pre bool) {
		switch n.Type {
		case xhtml.TextNode:
			t := n.Data
			if !pre {
				t = spaces.ReplaceAllString(t, " ")
				if strings.HasPrefix(t, " ") && endsWithSpace(&b) {
					t = t[1:]
				}
			}
			b.WriteString(t)
			return
		case xhtml.ElementNode:
		default:
			for c := n.FirstChild; c != nil; c = c.NextSibling {
				walk(c, pre)
			}
			return
		}
		switch n.DataAtom {
		case atom.Br:
			b.WriteString("\n")
			return
		case atom.Pre:
			block(&b)
			b.WriteString("```\n")
			for c := n.FirstChild; c != nil; c = c.NextSibling {
				walk(c, true)
			}
			trimSpaceEnd(&b)
			b.WriteString("\n```\n\n")
			return
		case atom.Li:
			line(&b)
			b.WriteString("- ")
		case atom.P, atom.Div:
			if inItem(n) {
				break // the editor wraps each list item's text in a paragraph
			}
			block(&b)
		case atom.H1, atom.H2, atom.H3, atom.H4, atom.H5, atom.H6, atom.Blockquote, atom.Ul, atom.Ol, atom.Table, atom.Tr:
			block(&b)
		case atom.Img:
			if alt := attr(n, "alt"); alt != "" {
				b.WriteString("[image: " + alt + "]")
			}
			return
		}
		start := b.Len()
		for c := n.FirstChild; c != nil; c = c.NextSibling {
			walk(c, pre)
		}
		switch n.DataAtom {
		case atom.A:
			if href := attr(n, "href"); href != "" && href != strings.TrimSpace(b.String()[start:]) {
				b.WriteString(" (" + href + ")")
			}
		case atom.Td, atom.Th:
			b.WriteString("\t")
		case atom.P, atom.Div:
			if !inItem(n) {
				block(&b)
			}
		case atom.H1, atom.H2, atom.H3, atom.H4, atom.H5, atom.H6, atom.Blockquote, atom.Ul, atom.Ol, atom.Table:
			block(&b)
		case atom.Li, atom.Tr:
			line(&b)
		}
	}
	walk(doc, false)
	return collapseBlankLines(strings.TrimSpace(b.String()))
}

// inItem reports whether n is directly inside a list item.
func inItem(n *xhtml.Node) bool { return n.Parent != nil && n.Parent.DataAtom == atom.Li }

func attr(n *xhtml.Node, key string) string {
	for _, a := range n.Attr {
		if a.Key == key {
			return a.Val
		}
	}
	return ""
}

var spaces = regexp.MustCompile(`\s+`)

func endsWithSpace(b *strings.Builder) bool {
	s := b.String()
	return s == "" || strings.HasSuffix(s, " ") || strings.HasSuffix(s, "\n")
}

// trimSpaceEnd drops trailing spaces and newlines.
func trimSpaceEnd(b *strings.Builder) {
	s := strings.TrimRight(b.String(), " \t\n")
	b.Reset()
	b.WriteString(s)
}

// line starts a new line unless at the start of one.
func line(b *strings.Builder) {
	trimTrailingSpaces(b)
	if s := b.String(); s != "" && !strings.HasSuffix(s, "\n") {
		b.WriteString("\n")
	}
}

// block leaves an empty line before what follows.
func block(b *strings.Builder) {
	trimTrailingSpaces(b)
	s := b.String()
	switch {
	case s == "" || strings.HasSuffix(s, "\n\n"):
	case strings.HasSuffix(s, "\n"):
		b.WriteString("\n")
	default:
		b.WriteString("\n\n")
	}
}

func trimTrailingSpaces(b *strings.Builder) {
	s := b.String()
	if t := strings.TrimRight(s, " \t"); t != s {
		b.Reset()
		b.WriteString(t)
	}
}

var blankLines = regexp.MustCompile(`\n{3,}`)

func collapseBlankLines(s string) string { return blankLines.ReplaceAllString(s, "\n\n") }

var urlRE = regexp.MustCompile(`https?://[^\s<>"]+[^\s<>".,;:!?)\]]`)

// htmlFromText turns agnts's plain text into Plane comment HTML: one
// paragraph per line, with URLs linked.
func htmlFromText(text string) string {
	var b strings.Builder
	for _, l := range strings.Split(strings.TrimSpace(text), "\n") {
		if strings.TrimSpace(l) == "" {
			continue
		}
		b.WriteString("<p>")
		last := 0
		for _, m := range urlRE.FindAllStringIndex(l, -1) {
			b.WriteString(html.EscapeString(l[last:m[0]]))
			u := html.EscapeString(l[m[0]:m[1]])
			b.WriteString(`<a href="` + u + `" target="_blank" rel="noopener noreferrer">` + u + `</a>`)
			last = m[1]
		}
		b.WriteString(html.EscapeString(l[last:]))
		b.WriteString("</p>")
	}
	if b.Len() == 0 {
		return "<p></p>"
	}
	return b.String()
}
