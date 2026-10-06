package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Lessons stores what agnts learned from finished tickets.
type Lessons struct{ db *pgxpool.Pool }

var _ orchestrator.Lessons = (*Lessons)(nil)

// NewLessons returns the lessons store.
func NewLessons(db *pgxpool.Pool) *Lessons { return &Lessons{db: db} }

const lessonCols = `l.id, l.repo_id, r.name, l.ticket_key, l.slug, l.title, l.category, l.level, l.summary,
	l.explanation, l.why_here, l.refs, l.quiz, l.reading, l.learned_at, l.created_at`

const lessonFrom = ` FROM lessons l JOIN repositories r ON r.id = l.repo_id`

func scanLesson(row pgx.Row) (domain.Lesson, error) {
	var l domain.Lesson
	var refs, quiz, reading []byte
	err := row.Scan(&l.ID, &l.RepoID, &l.RepoName, &l.TicketKey, &l.Slug, &l.Title, &l.Category, &l.Level, &l.Summary,
		&l.Explanation, &l.WhyHere, &refs, &quiz, &reading, &l.LearnedAt, &l.CreatedAt)
	if err != nil {
		return l, notFound(err)
	}
	_ = json.Unmarshal(refs, &l.Refs)
	_ = json.Unmarshal(quiz, &l.Quiz)
	_ = json.Unmarshal(reading, &l.Reading)
	return l, nil
}

// LessonTopics returns a repository's known concepts, newest first.
func (s *Lessons) LessonTopics(ctx context.Context, repoID int64) ([]domain.LessonTopic, error) {
	rows, err := s.db.Query(ctx, `SELECT slug, title FROM lessons WHERE repo_id = $1 ORDER BY created_at DESC LIMIT 1000`, repoID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.LessonTopic
	for rows.Next() {
		var t domain.LessonTopic
		if err := rows.Scan(&t.Slug, &t.Title); err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// SaveLessons inserts lessons whose slug is new to their repository, marks
// the ticket's learn run done and writes the event built from the lessons,
// in one transaction.
func (s *Lessons) SaveLessons(ctx context.Context, ticketKey string, ls []domain.Lesson, ev func([]domain.Lesson) domain.Event) ([]domain.Lesson, error) {
	saved := []domain.Lesson{}
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		for _, l := range ls {
			refs, _ := json.Marshal(nonNil(l.Refs))
			quiz, _ := json.Marshal(nonNil(l.Quiz))
			reading, _ := json.Marshal(nonNil(l.Reading))
			var id int64
			err := tx.QueryRow(ctx, `INSERT INTO lessons
				(repo_id, ticket_key, slug, title, category, level, summary, explanation, why_here, refs, quiz, reading)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
				ON CONFLICT (repo_id, slug) DO NOTHING RETURNING id`,
				l.RepoID, l.TicketKey, l.Slug, l.Title, l.Category, l.Level, l.Summary, l.Explanation, l.WhyHere,
				refs, quiz, reading).Scan(&id)
			if errors.Is(err, pgx.ErrNoRows) {
				continue // the repository already has this concept
			}
			if err != nil {
				return err
			}
			l.ID = id
			saved = append(saved, l)
		}
		if _, err := tx.Exec(ctx, `UPDATE tickets SET learn_state = $2, updated_at = now() WHERE key = $1`, ticketKey, domain.LearnDone); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev(saved))
	})
	if err != nil {
		return nil, err
	}
	return saved, nil
}

func nonNil[T any](s []T) []T {
	if s == nil {
		return []T{}
	}
	return s
}

// LessonFilter narrows ListLessons.
type LessonFilter struct {
	RepoID    int64
	TicketKey string
	Learned   *bool // nil: all
	Query     string
	Limit     int
}

// ListLessons returns lessons, newest first.
func (s *Lessons) ListLessons(ctx context.Context, f LessonFilter) ([]domain.Lesson, error) {
	limit := f.Limit
	if limit <= 0 || limit > 500 {
		limit = 200
	}
	q := "%" + strings.NewReplacer(`\`, `\\`, "%", `\%`, "_", `\_`).Replace(strings.TrimSpace(f.Query)) + "%"
	rows, err := s.db.Query(ctx, `SELECT `+lessonCols+lessonFrom+`
		WHERE ($1 = 0 OR l.repo_id = $1) AND ($2 = '' OR l.ticket_key = $2)
		  AND ($3::boolean IS NULL OR (l.learned_at IS NOT NULL) = $3)
		  AND ($4 = '%%' OR l.title ILIKE $4 OR l.summary ILIKE $4 OR l.slug ILIKE $4)
		ORDER BY l.created_at DESC, l.id DESC LIMIT $5`, f.RepoID, f.TicketKey, f.Learned, q, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Lesson{}
	for rows.Next() {
		l, err := scanLesson(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

// Lesson returns one lesson.
func (s *Lessons) Lesson(ctx context.Context, id int64) (domain.Lesson, error) {
	return scanLesson(s.db.QueryRow(ctx, `SELECT `+lessonCols+lessonFrom+` WHERE l.id = $1`, id))
}

// SetLessonLearned marks a lesson learned (true) or new again.
func (s *Lessons) SetLessonLearned(ctx context.Context, id int64, learned bool) (domain.Lesson, error) {
	tag, err := s.db.Exec(ctx, `UPDATE lessons SET learned_at = CASE WHEN $2 THEN coalesce(learned_at, now()) END WHERE id = $1`, id, learned)
	if err != nil {
		return domain.Lesson{}, err
	}
	if tag.RowsAffected() == 0 {
		return domain.Lesson{}, domain.ErrNotFound
	}
	return s.Lesson(ctx, id)
}

// LessonCounts returns how many lessons there are and how many are not
// learned yet.
func (s *Lessons) LessonCounts(ctx context.Context) (total, unlearned int, err error) {
	err = s.db.QueryRow(ctx, `SELECT count(*), count(*) FILTER (WHERE learned_at IS NULL) FROM lessons`).Scan(&total, &unlearned)
	return total, unlearned, err
}

// LearnQueueItem is a done ticket and where its learn run stands.
type LearnQueueItem struct {
	Key       string
	Title     string
	RepoName  string
	Status    string // running, pending, failed or none (never learned from)
	Lessons   int    // lessons it produced so far
	UpdatedAt time.Time
}

// LearnQueue lists done tickets whose learn run is running, queued, failed
// or never happened: running first, then queued oldest first (the order
// they will run in), then failed and never learned, newest first.
func (s *Lessons) LearnQueue(ctx context.Context) ([]LearnQueueItem, error) {
	rows, err := s.db.Query(ctx, `SELECT t.key, t.title, coalesce(r.name, ''),
			CASE WHEN EXISTS (SELECT 1 FROM runs x WHERE x.ticket_id = t.id AND x.stage = 'learn' AND x.finished_at IS NULL) THEN 'running'
			     WHEN t.learn_state = '' THEN 'none' ELSE t.learn_state END AS status,
			(SELECT count(*) FROM lessons l WHERE l.ticket_key = t.key), t.updated_at
		FROM tickets t LEFT JOIN repositories r ON r.id = t.repo_id
		WHERE t.state = 'done' AND t.repo_id IS NOT NULL AND t.branch <> '' AND t.learn_state <> 'done'
		ORDER BY CASE WHEN EXISTS (SELECT 1 FROM runs x WHERE x.ticket_id = t.id AND x.stage = 'learn' AND x.finished_at IS NULL) THEN 0
		              WHEN t.learn_state = 'pending' THEN 1 WHEN t.learn_state = 'failed' THEN 2 ELSE 3 END,
		         CASE WHEN t.learn_state = 'pending' THEN t.updated_at END ASC,
		         t.updated_at DESC
		LIMIT 200`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []LearnQueueItem{}
	for rows.Next() {
		var x LearnQueueItem
		if err := rows.Scan(&x.Key, &x.Title, &x.RepoName, &x.Status, &x.Lessons, &x.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, x)
	}
	return out, rows.Err()
}
