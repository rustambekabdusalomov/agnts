package postgres

import (
	"context"
	"time"
)

// The Analytics page's Delivery, CI and Learning tabs. Each tab is its own
// query set, so the page only runs the ones a person opens.

// window is a period of days ending tonight in tz, and the one before it.
func window(days int, tz *time.Location) (start, end, prevStart time.Time) {
	now := time.Now().In(tz)
	end = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, tz).AddDate(0, 0, 1)
	start = end.AddDate(0, 0, -days)
	return start, end, start.AddDate(0, 0, -days)
}

// Spread is the typical (median) and slow (90th percentile) value of a
// duration in minutes; nil when nothing was measured.
type Spread struct {
	P50, P90 *float64
}

// DeliveryPeriod sums what happened to agnts's pull requests in a period.
type DeliveryPeriod struct {
	Opened, Merged, Closed int    // pull requests opened in the period, and how they ended so far
	MergeMin               Spread // opened → merged
	Pushed                 int    // tickets that first reached done in the period
	PushedMin              Spread // picked → pushed
	MergedTickets          int    // tickets merged in the period
	MergedMin              Spread // picked → merged
	Questions              int    // questions asked in the period
	AskedTickets           int    // tickets that asked them
	AnalyzedTickets        int    // tickets analysed in the period
	AnswerMin              Spread // asked → answered
}

// DeliveryDay is one day of cycle time.
type DeliveryDay struct {
	Date                 time.Time
	Merged, Closed       int
	PushedMin, MergedMin *float64 // median picked → pushed / merged of that day's tickets
}

// SlowTicket is one of the period's slowest tickets and where its time went.
type SlowTicket struct {
	Key, Title                                string
	CycleMin                                  float64 // picked → pushed
	AgntsMin, AnswersMin, ReviewMin, QueueMin float64
	Merged                                    bool
}

// StalePR is a pull request still open after a week.
type StalePR struct {
	Key, Title, Repo, URL string
	OpenedAt              time.Time
}

// Delivery is the Delivery tab.
type Delivery struct {
	Current, Prev DeliveryPeriod
	Days          []DeliveryDay
	Slowest       []SlowTicket
	Stale         []StalePR
	Unanswered    int // questions waiting for an answer now
}

// prOpened is a CTE of agnts's pull requests and when each was opened.
const prOpened = `prs AS (
	SELECT t.key, t.title, t.repo_id, t.pr_url, t.merged_at, t.closed_at, min(e.created_at) AS opened
	FROM tickets t JOIN events e ON e.ticket_key = t.key AND e.type = 'pr_opened' AND e.data ? 'number'
	WHERE t.kind <> 'review' AND t.replay_of = ''
	GROUP BY t.id)`

// firstDone is a CTE of when each ticket first reached done.
const firstDone = `pushed AS (
	SELECT t.key, t.title, t.created_at, t.merged_at, min(e.created_at) AS done_at
	FROM tickets t JOIN events e ON e.ticket_key = t.key AND e.type = 'state_changed' AND e.data->>'to' = 'done'
	WHERE t.kind <> 'review' AND t.replay_of = ''
	GROUP BY t.id)`

// spread is the median and 90th percentile of expr in minutes, over the rows where cond holds.
func spread(expr, cond string) string {
	return `percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM ` + expr + `) / 60) FILTER (WHERE ` + cond + `),
		percentile_cont(0.9) WITHIN GROUP (ORDER BY extract(epoch FROM ` + expr + `) / 60) FILTER (WHERE ` + cond + `)`
}

// Delivery computes the Delivery tab for [now-days, now) in tz.
func (s *Agent) Delivery(ctx context.Context, days int, tz *time.Location) (Delivery, error) {
	start, end, prevStart := window(days, tz)
	var d Delivery
	var err error
	if d.Current, err = s.deliveryPeriod(ctx, start, end); err != nil {
		return d, err
	}
	if d.Prev, err = s.deliveryPeriod(ctx, prevStart, start); err != nil {
		return d, err
	}

	byDay := map[string]*DeliveryDay{}
	for day := start; day.Before(end); day = day.AddDate(0, 0, 1) {
		d.Days = append(d.Days, DeliveryDay{Date: day})
	}
	for i := range d.Days {
		byDay[d.Days[i].Date.Format("2006-01-02")] = &d.Days[i]
	}
	tzName := tz.String()
	rows, err := s.db.Query(ctx, `WITH `+firstDone+`
		SELECT to_char(done_at AT TIME ZONE $3, 'YYYY-MM-DD'),
			percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM done_at - created_at) / 60)
		FROM pushed WHERE done_at >= $1 AND done_at < $2 GROUP BY 1`, start, end, tzName)
	if err != nil {
		return d, err
	}
	for rows.Next() {
		var day string
		var m float64
		if err := rows.Scan(&day, &m); err != nil {
			rows.Close()
			return d, err
		}
		if x := byDay[day]; x != nil {
			x.PushedMin = &m
		}
	}
	rows.Close()
	rows, err = s.db.Query(ctx, `SELECT to_char(at AT TIME ZONE $3, 'YYYY-MM-DD'),
			count(*) FILTER (WHERE merged), count(*) FILTER (WHERE NOT merged),
			percentile_cont(0.5) WITHIN GROUP (ORDER BY mins) FILTER (WHERE merged)
		FROM (SELECT merged_at AS at, true AS merged, extract(epoch FROM merged_at - created_at) / 60 AS mins FROM tickets
		        WHERE merged_at >= $1 AND merged_at < $2 AND kind <> 'review' AND replay_of = ''
		      UNION ALL
		      SELECT closed_at, false, 0 FROM tickets
		        WHERE closed_at >= $1 AND closed_at < $2 AND merged_at IS NULL AND kind <> 'review' AND replay_of = '') x
		GROUP BY 1`, start, end, tzName)
	if err != nil {
		return d, err
	}
	for rows.Next() {
		var day string
		var merged, closed int
		var m *float64
		if err := rows.Scan(&day, &merged, &closed, &m); err != nil {
			rows.Close()
			return d, err
		}
		if x := byDay[day]; x != nil {
			x.Merged, x.Closed, x.MergedMin = merged, closed, m
		}
	}
	rows.Close()

	// The slowest tickets pushed in the period, and where their time went.
	rows, err = s.db.Query(ctx, `WITH `+firstDone+`, `+stateSpans+`,
		slow AS (SELECT * FROM pushed WHERE done_at >= $1 AND done_at < $2 ORDER BY done_at - created_at DESC LIMIT 5)
		SELECT s.key, s.title, extract(epoch FROM s.done_at - s.created_at) / 60, s.merged_at IS NOT NULL,
			COALESCE(sum(extract(epoch FROM sp.left_at - sp.entered)) FILTER (WHERE sp.state = ANY($3)), 0) / 60,
			COALESCE(sum(extract(epoch FROM sp.left_at - sp.entered)) FILTER (WHERE sp.state = 'waiting_for_answers'), 0) / 60,
			COALESCE(sum(extract(epoch FROM sp.left_at - sp.entered)) FILTER (WHERE sp.state = 'waiting_for_review'), 0) / 60
		FROM slow s LEFT JOIN spans sp ON sp.ticket_key = s.key AND sp.left_at IS NOT NULL AND sp.left_at <= s.done_at
		GROUP BY s.key, s.title, s.done_at, s.created_at, s.merged_at
		ORDER BY s.done_at - s.created_at DESC`, start, end, working)
	if err != nil {
		return d, err
	}
	for rows.Next() {
		var t SlowTicket
		if err := rows.Scan(&t.Key, &t.Title, &t.CycleMin, &t.Merged, &t.AgntsMin, &t.AnswersMin, &t.ReviewMin); err != nil {
			rows.Close()
			return d, err
		}
		// Whatever is not agnts working or a person: queued, paused, retried.
		t.QueueMin = max(0, t.CycleMin-t.AgntsMin-t.AnswersMin-t.ReviewMin)
		d.Slowest = append(d.Slowest, t)
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `WITH `+prOpened+`
		SELECT p.key, p.title, COALESCE(r.name, ''), p.pr_url, p.opened FROM prs p
		LEFT JOIN repositories r ON r.id = p.repo_id
		WHERE p.merged_at IS NULL AND p.closed_at IS NULL AND p.opened < now() - interval '7 days'
		ORDER BY p.opened LIMIT 5`)
	if err != nil {
		return d, err
	}
	for rows.Next() {
		var p StalePR
		if err := rows.Scan(&p.Key, &p.Title, &p.Repo, &p.URL, &p.OpenedAt); err != nil {
			rows.Close()
			return d, err
		}
		d.Stale = append(d.Stale, p)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return d, err
	}

	err = s.db.QueryRow(ctx, `SELECT count(*) FROM questions q JOIN tickets t ON t.id = q.ticket_id
		WHERE q.answered_at IS NULL AND t.state = 'waiting_for_answers'`).Scan(&d.Unanswered)
	return d, err
}

func (s *Agent) deliveryPeriod(ctx context.Context, from, to time.Time) (DeliveryPeriod, error) {
	var p DeliveryPeriod
	err := s.db.QueryRow(ctx, `WITH `+prOpened+`
		SELECT count(*), count(*) FILTER (WHERE merged_at IS NOT NULL), count(*) FILTER (WHERE closed_at IS NOT NULL AND merged_at IS NULL),
			`+spread("merged_at - opened", "merged_at IS NOT NULL")+`
		FROM prs WHERE opened >= $1 AND opened < $2`, from, to).
		Scan(&p.Opened, &p.Merged, &p.Closed, &p.MergeMin.P50, &p.MergeMin.P90)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `WITH `+firstDone+`
		SELECT count(*), `+spread("done_at - created_at", "true")+`
		FROM pushed WHERE done_at >= $1 AND done_at < $2`, from, to).Scan(&p.Pushed, &p.PushedMin.P50, &p.PushedMin.P90)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(*), `+spread("merged_at - created_at", "true")+`
		FROM tickets WHERE merged_at >= $1 AND merged_at < $2 AND kind <> 'review' AND replay_of = ''`, from, to).
		Scan(&p.MergedTickets, &p.MergedMin.P50, &p.MergedMin.P90)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(*), count(DISTINCT ticket_id), `+spread("answered_at - created_at", "answered_at IS NOT NULL")+`
		FROM questions WHERE created_at >= $1 AND created_at < $2`, from, to).
		Scan(&p.Questions, &p.AskedTickets, &p.AnswerMin.P50, &p.AnswerMin.P90)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(DISTINCT ticket_id) FROM runs
		WHERE stage = 'analyze' AND started_at >= $1 AND started_at < $2`, from, to).Scan(&p.AnalyzedTickets)
	return p, err
}

// CIPeriod sums CI failures in a period.
type CIPeriod struct {
	Seen      int    // failure groups that failed in the period
	New       int    // first seen in the period
	Fixed     int    // fixed in the period
	AutoFixed int    // fixed by an agnts ticket
	Flaky     int    // seen in the period and found flaky
	FixMin    Spread // first seen → fixed
	OwnFixes  int    // red CI sent agnts's own pull request back to coding
}

// CIDay is one day of CI failures.
type CIDay struct {
	Date       time.Time
	New, Fixed int
}

// FlakyJob is a job that failed and passed on re-run.
type FlakyJob struct {
	ID                         int64
	Repo, Workflow, Job, Title string
	Flaky, Failures            int
}

// CIHealth is the CI part of the Quality tab.
type CIHealth struct {
	Watching      bool // CI watching is set up for at least one repository
	Current, Prev CIPeriod
	ByClass       map[string]int // failure groups seen in the period by class
	Days          []CIDay
	Flakiest      []FlakyJob
	Open          int // groups that need attention now
}

// CIHealth computes CI health for [now-days, now) in tz.
func (s *Agent) CIHealth(ctx context.Context, days int, tz *time.Location) (CIHealth, error) {
	start, end, prevStart := window(days, tz)
	h := CIHealth{ByClass: map[string]int{}}
	if err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM ci_watches) OR EXISTS (SELECT 1 FROM ci_failures)`).Scan(&h.Watching); err != nil || !h.Watching {
		return h, err
	}
	var err error
	if h.Current, err = s.ciPeriod(ctx, start, end); err != nil {
		return h, err
	}
	if h.Prev, err = s.ciPeriod(ctx, prevStart, start); err != nil {
		return h, err
	}

	rows, err := s.db.Query(ctx, `SELECT class, count(*) FROM ci_failures
		WHERE last_seen_at >= $1 AND first_seen_at < $2 GROUP BY class`, start, end)
	if err != nil {
		return h, err
	}
	for rows.Next() {
		var c string
		var n int
		if err := rows.Scan(&c, &n); err != nil {
			rows.Close()
			return h, err
		}
		if c == "" {
			c = "unknown"
		}
		h.ByClass[c] += n
	}
	rows.Close()

	byDay := map[string]*CIDay{}
	for day := start; day.Before(end); day = day.AddDate(0, 0, 1) {
		h.Days = append(h.Days, CIDay{Date: day})
	}
	for i := range h.Days {
		byDay[h.Days[i].Date.Format("2006-01-02")] = &h.Days[i]
	}
	rows, err = s.db.Query(ctx, `SELECT to_char(at AT TIME ZONE $3, 'YYYY-MM-DD'), count(*) FILTER (WHERE fixed), count(*) FILTER (WHERE NOT fixed)
		FROM (SELECT first_seen_at AS at, false AS fixed FROM ci_failures WHERE first_seen_at >= $1 AND first_seen_at < $2
		      UNION ALL SELECT fixed_at, true FROM ci_failures WHERE fixed_at >= $1 AND fixed_at < $2) x GROUP BY 1`, start, end, tz.String())
	if err != nil {
		return h, err
	}
	for rows.Next() {
		var day string
		var fixed, n int
		if err := rows.Scan(&day, &fixed, &n); err != nil {
			rows.Close()
			return h, err
		}
		if x := byDay[day]; x != nil {
			x.New, x.Fixed = n, fixed
		}
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `SELECT f.id, COALESCE(r.name, ''), f.workflow, f.job, f.title, f.flaky_count, f.count
		FROM ci_failures f LEFT JOIN repositories r ON r.id = f.repo_id
		WHERE f.flaky_count > 0 AND f.last_seen_at >= $1 AND f.first_seen_at < $2
		ORDER BY f.flaky_count DESC, f.last_seen_at DESC LIMIT 5`, start, end)
	if err != nil {
		return h, err
	}
	for rows.Next() {
		var j FlakyJob
		if err := rows.Scan(&j.ID, &j.Repo, &j.Workflow, &j.Job, &j.Title, &j.Flaky, &j.Failures); err != nil {
			rows.Close()
			return h, err
		}
		h.Flakiest = append(h.Flakiest, j)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return h, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(*) FROM ci_failures WHERE status IN ('open', 'fixing', 'regression', 'triage')`).Scan(&h.Open)
	return h, err
}

func (s *Agent) ciPeriod(ctx context.Context, from, to time.Time) (CIPeriod, error) {
	var p CIPeriod
	err := s.db.QueryRow(ctx, `SELECT
			count(*) FILTER (WHERE last_seen_at >= $1 AND first_seen_at < $2),
			count(*) FILTER (WHERE first_seen_at >= $1 AND first_seen_at < $2),
			count(*) FILTER (WHERE fixed_at >= $1 AND fixed_at < $2),
			count(*) FILTER (WHERE fixed_at >= $1 AND fixed_at < $2 AND ticket_key <> ''),
			count(*) FILTER (WHERE last_seen_at >= $1 AND first_seen_at < $2 AND (class = 'flaky' OR flaky_count > 0)),
			`+spread("fixed_at - first_seen_at", "fixed_at >= $1 AND fixed_at < $2")+`
		FROM ci_failures`, from, to).
		Scan(&p.Seen, &p.New, &p.Fixed, &p.AutoFixed, &p.Flaky, &p.FixMin.P50, &p.FixMin.P90)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT COALESCE(sum(ci_fixes), 0) FROM tickets
		WHERE ci_fixes > 0 AND updated_at >= $1 AND updated_at < $2`, from, to).Scan(&p.OwnFixes)
	return p, err
}

// LearningPeriod sums what agnts learned in a period.
type LearningPeriod struct {
	Lessons, LessonsLearned        int // lessons written / marked learned in the period
	RulesSuggested, RulesAdopted   int // suggested from tickets / of those, in use now
	RulesManual                    int // written by a person
	Reflections, ReflectionRules   int // reflections on changed or rejected tickets, and the rules they suggested
	FollowUps, Accepted, Dismissed int // follow-ups suggested / decided in the period
	ReviewerNotes                  int
}

// LessonCount is one lesson category.
type LessonCount struct {
	Category         string
	Created, Learned int
}

// FollowUpCount is follow-ups suggested in the period of one type or source,
// by what happened to them so far.
type FollowUpCount struct {
	Name                           string
	Suggested, Accepted, Dismissed int
}

// ReviewerStats is one reviewer's notes in the period.
type ReviewerStats struct {
	Login                       string
	Rereview, Dismissed, Manual int
	Repos                       []string
}

// Learning is the Learning tab.
type Learning struct {
	Current, Prev   LearningPeriod
	Lessons         []LessonCount
	FollowUpTypes   []FollowUpCount
	FollowUpSources []FollowUpCount
	Reviewers       []ReviewerStats
}

// Learning computes the Learning tab for [now-days, now) in tz.
func (s *Agent) Learning(ctx context.Context, days int, tz *time.Location) (Learning, error) {
	start, end, prevStart := window(days, tz)
	l := Learning{Lessons: []LessonCount{}, FollowUpTypes: []FollowUpCount{}, FollowUpSources: []FollowUpCount{}, Reviewers: []ReviewerStats{}}
	var err error
	if l.Current, err = s.learningPeriod(ctx, start, end); err != nil {
		return l, err
	}
	if l.Prev, err = s.learningPeriod(ctx, prevStart, start); err != nil {
		return l, err
	}

	rows, err := s.db.Query(ctx, `SELECT category,
			count(*) FILTER (WHERE created_at >= $1 AND created_at < $2),
			count(*) FILTER (WHERE learned_at >= $1 AND learned_at < $2)
		FROM lessons WHERE (created_at >= $1 AND created_at < $2) OR (learned_at >= $1 AND learned_at < $2)
		GROUP BY category ORDER BY 2 DESC, 1`, start, end)
	if err != nil {
		return l, err
	}
	for rows.Next() {
		var c LessonCount
		if err := rows.Scan(&c.Category, &c.Created, &c.Learned); err != nil {
			rows.Close()
			return l, err
		}
		l.Lessons = append(l.Lessons, c)
	}
	rows.Close()

	for _, col := range []string{"type", "source"} {
		rows, err := s.db.Query(ctx, `SELECT `+col+`, count(*), count(*) FILTER (WHERE status = 'accepted'), count(*) FILTER (WHERE status = 'dismissed')
			FROM ticket_suggestions WHERE created_at >= $1 AND created_at < $2 GROUP BY 1 ORDER BY 2 DESC, 1`, start, end)
		if err != nil {
			return l, err
		}
		for rows.Next() {
			var c FollowUpCount
			if err := rows.Scan(&c.Name, &c.Suggested, &c.Accepted, &c.Dismissed); err != nil {
				rows.Close()
				return l, err
			}
			if col == "type" {
				l.FollowUpTypes = append(l.FollowUpTypes, c)
			} else {
				l.FollowUpSources = append(l.FollowUpSources, c)
			}
		}
		rows.Close()
	}

	rows, err = s.db.Query(ctx, `SELECT n.login,
			count(*) FILTER (WHERE n.kind = 'rereview'), count(*) FILTER (WHERE n.kind = 'dismissed'), count(*) FILTER (WHERE n.kind = 'manual'),
			COALESCE(array_agg(DISTINCT r.name) FILTER (WHERE r.name IS NOT NULL), '{}')
		FROM reviewer_notes n LEFT JOIN repositories r ON r.id = n.repo_id
		WHERE n.created_at >= $1 AND n.created_at < $2
		GROUP BY n.login ORDER BY count(*) DESC, n.login LIMIT 10`, start, end)
	if err != nil {
		return l, err
	}
	for rows.Next() {
		var r ReviewerStats
		if err := rows.Scan(&r.Login, &r.Rereview, &r.Dismissed, &r.Manual, &r.Repos); err != nil {
			rows.Close()
			return l, err
		}
		l.Reviewers = append(l.Reviewers, r)
	}
	rows.Close()
	return l, rows.Err()
}

func (s *Agent) learningPeriod(ctx context.Context, from, to time.Time) (LearningPeriod, error) {
	var p LearningPeriod
	err := s.db.QueryRow(ctx, `SELECT
			(SELECT count(*) FROM lessons WHERE created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM lessons WHERE learned_at >= $1 AND learned_at < $2),
			(SELECT count(*) FROM rules WHERE source_ticket <> '' AND created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM rules WHERE source_ticket <> '' AND status NOT IN ('suggested', 'dismissed') AND created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM rules WHERE source_ticket = '' AND created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM reflections WHERE status = 'done' AND created_at >= $1 AND created_at < $2),
			(SELECT COALESCE(sum(suggested), 0) FROM reflections WHERE status = 'done' AND created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM ticket_suggestions WHERE created_at >= $1 AND created_at < $2),
			(SELECT count(*) FROM ticket_suggestions WHERE status = 'accepted' AND decided_at >= $1 AND decided_at < $2),
			(SELECT count(*) FROM ticket_suggestions WHERE status = 'dismissed' AND decided_at >= $1 AND decided_at < $2),
			(SELECT count(*) FROM reviewer_notes WHERE created_at >= $1 AND created_at < $2)`, from, to).
		Scan(&p.Lessons, &p.LessonsLearned, &p.RulesSuggested, &p.RulesAdopted, &p.RulesManual, &p.Reflections, &p.ReflectionRules,
			&p.FollowUps, &p.Accepted, &p.Dismissed, &p.ReviewerNotes)
	return p, err
}
