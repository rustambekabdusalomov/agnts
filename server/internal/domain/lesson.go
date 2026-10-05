package domain

import (
	"net/url"
	"regexp"
	"slices"
	"strings"
	"time"
	"unicode/utf8"
)

// Learn states of a ticket: whether a learn run is queued for it.
const (
	LearnNone    = ""
	LearnPending = "pending"
	LearnDone    = "done"
	LearnFailed  = "failed"
)

// LessonCategories classify what a lesson teaches.
var LessonCategories = []string{
	"pattern", "architecture", "algorithm", "library", "language",
	"testing", "security", "performance", "tooling", "other",
}

// LessonLevels say how much background a lesson assumes.
var LessonLevels = []string{"beginner", "intermediate", "advanced"}

// Lesson explains something a ticket's change did that the repository had
// never done before, so the people who own the code learn it too.
type Lesson struct {
	ID          int64
	RepoID      int64
	RepoName    string // filled on reads
	TicketKey   string
	Slug        string // stable concept id, unique per repository
	Title       string
	Category    string
	Level       string
	Summary     string
	Explanation string
	WhyHere     string
	Refs        []LessonRef
	Quiz        []QuizQuestion
	Reading     []Link
	LearnedAt   *time.Time
	CreatedAt   time.Time
}

// LessonRef points at the code a lesson is about.
type LessonRef struct {
	Path string `json:"path"`
	Line int    `json:"line,omitempty"`
	Note string `json:"note,omitempty"`
}

// QuizQuestion checks a lesson was understood. Answer is the index of the
// correct option.
type QuizQuestion struct {
	Question    string   `json:"question"`
	Options     []string `json:"options"`
	Answer      int      `json:"answer"`
	Explanation string   `json:"explanation,omitempty"`
}

// Link is further reading.
type Link struct {
	Title string `json:"title"`
	URL   string `json:"url"`
}

// LessonTopic is a known concept, given to the learn run so it does not
// teach the same thing twice.
type LessonTopic struct {
	Slug  string
	Title string
}

var slugRe = regexp.MustCompile(`[^\p{L}\p{N}]+`)

// Slugify turns a title into a lesson slug.
func Slugify(s string) string {
	s = strings.Trim(slugRe.ReplaceAllString(strings.ToLower(s), "-"), "-")
	return clip(s, 64)
}

// Normalize cleans a lesson written by the learn run: it trims and caps
// every field, drops invalid references, quiz questions and links, and
// reports false when nothing usable is left (no title or summary).
func (l *Lesson) Normalize() bool {
	l.Title = clip(strings.TrimSpace(l.Title), 120)
	l.Summary = clip(strings.TrimSpace(l.Summary), 600)
	if l.Title == "" || l.Summary == "" {
		return false
	}
	if l.Slug = Slugify(l.Slug); l.Slug == "" {
		l.Slug = Slugify(l.Title)
	}
	if l.Slug == "" {
		return false
	}
	if l.Category = strings.ToLower(strings.TrimSpace(l.Category)); !slices.Contains(LessonCategories, l.Category) {
		l.Category = "other"
	}
	if l.Level = strings.ToLower(strings.TrimSpace(l.Level)); !slices.Contains(LessonLevels, l.Level) {
		l.Level = "intermediate"
	}
	l.Explanation = clip(strings.TrimSpace(l.Explanation), 10000)
	l.WhyHere = clip(strings.TrimSpace(l.WhyHere), 3000)

	refs := []LessonRef{}
	for _, r := range l.Refs {
		r.Path = strings.TrimPrefix(strings.TrimSpace(r.Path), "/workspace/")
		if r.Path == "" || strings.HasPrefix(r.Path, "/") || slices.Contains(strings.Split(r.Path, "/"), "..") {
			continue
		}
		r.Path, r.Note, r.Line = clip(r.Path, 300), clip(strings.TrimSpace(r.Note), 300), max(r.Line, 0)
		if refs = append(refs, r); len(refs) == 10 {
			break
		}
	}
	l.Refs = refs

	quiz := []QuizQuestion{}
	for _, q := range l.Quiz {
		q.Question = clip(strings.TrimSpace(q.Question), 500)
		opts := []string{}
		for _, o := range q.Options {
			if o = clip(strings.TrimSpace(o), 300); o != "" {
				opts = append(opts, o)
			}
		}
		if q.Question == "" || len(opts) != len(q.Options) || len(opts) < 2 || len(opts) > 6 || q.Answer < 0 || q.Answer >= len(opts) {
			continue
		}
		q.Options, q.Explanation = opts, clip(strings.TrimSpace(q.Explanation), 1000)
		if quiz = append(quiz, q); len(quiz) == 5 {
			break
		}
	}
	l.Quiz = quiz

	links := []Link{}
	for _, k := range l.Reading {
		u, err := url.Parse(strings.TrimSpace(k.URL))
		if err != nil || u.Scheme != "https" || u.Host == "" || len(k.URL) > 500 {
			continue // only https links: they are shown as clickable
		}
		k.URL, k.Title = u.String(), clip(strings.TrimSpace(k.Title), 200)
		if k.Title == "" {
			k.Title = u.Host
		}
		if links = append(links, k); len(links) == 5 {
			break
		}
	}
	l.Reading = links
	return true
}

// clip cuts s to at most n bytes without splitting a UTF-8 character.
func clip(s string, n int) string {
	if len(s) <= n {
		return s
	}
	s = s[:n]
	for !utf8.ValidString(s) {
		s = s[:len(s)-1]
	}
	return s
}

// Reading speed for ReadMinutes, in words per minute. Code is read at
// half speed, so code-heavy lessons get more time.
const readWPM = 200

// ReadMinutes estimates how long the lesson takes to read and answer:
// summary, explanation, why it was needed, references and quiz.
func (l Lesson) ReadMinutes() int {
	words := 0
	count := func(s string) {
		inCode := false
		for _, line := range strings.Split(s, "\n") {
			if strings.HasPrefix(strings.TrimSpace(line), "```") {
				inCode = !inCode
				continue
			}
			n := len(strings.Fields(line))
			if inCode || strings.HasPrefix(line, "    ") || strings.HasPrefix(line, "\t") {
				n *= 2
			}
			words += n
		}
	}
	count(l.Summary)
	count(l.Explanation)
	count(l.WhyHere)
	for _, r := range l.Refs {
		count(r.Note)
	}
	for _, q := range l.Quiz {
		count(q.Question)
		count(strings.Join(q.Options, " "))
		count(q.Explanation)
	}
	return max(1, (words+readWPM-1)/readWPM)
}
