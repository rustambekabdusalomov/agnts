package httpapi

import (
	"context"
	"errors"
	"net/http"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// Lessons is what the Learn pages read and change.
type Lessons interface {
	ListLessons(ctx context.Context, f postgres.LessonFilter) ([]domain.Lesson, error)
	Lesson(ctx context.Context, id int64) (domain.Lesson, error)
	SetLessonLearned(ctx context.Context, id int64, learned bool) (domain.Lesson, error)
	LessonCounts(ctx context.Context) (total, unlearned int, err error)
	LearnQueue(ctx context.Context) ([]postgres.LearnQueueItem, error)
}

// GetLearnQueue implements gen.ServerInterface.
func (s *Server) GetLearnQueue(w http.ResponseWriter, r *http.Request) {
	if !s.lessonsReady(w) {
		return
	}
	q, err := s.opt.Lessons.LearnQueue(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.LearnQueueItem, len(q))
	for i, x := range q {
		out[i] = gen.LearnQueueItem{Key: x.Key, Title: x.Title, RepoName: x.RepoName,
			Status: gen.LearnQueueItemStatus(x.Status), Lessons: x.Lessons, UpdatedAt: x.UpdatedAt}
	}
	writeJSON(w, http.StatusOK, out)
}

func (s *Server) lessonsReady(w http.ResponseWriter) bool {
	if s.opt.Lessons == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

func (s *Server) writeLessonError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, domain.ErrNotFound) {
		writeError(w, http.StatusNotFound, "not_found", "no such lesson")
		return
	}
	s.writeInternal(w, r, err)
}

// ListLessons implements gen.ServerInterface.
func (s *Server) ListLessons(w http.ResponseWriter, r *http.Request, p gen.ListLessonsParams) {
	if !s.lessonsReady(w) {
		return
	}
	var f postgres.LessonFilter
	if p.Repo != nil {
		f.RepoID = *p.Repo
	}
	if p.Ticket != nil {
		f.TicketKey = *p.Ticket
	}
	if p.Q != nil {
		f.Query = *p.Q
	}
	if p.Limit != nil {
		f.Limit = *p.Limit
	}
	if p.Status != nil && *p.Status != gen.ListLessonsParamsStatusAll {
		learned := *p.Status == gen.ListLessonsParamsStatusLearned
		f.Learned = &learned
	}
	ls, err := s.opt.Lessons.ListLessons(r.Context(), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	total, unlearned, err := s.opt.Lessons.LessonCounts(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.LessonList{Items: make([]gen.LessonBrief, len(ls)), Total: total, Unlearned: unlearned}
	for i, l := range ls {
		out.Items[i] = gen.LessonBrief{
			Id: l.ID, RepoId: l.RepoID, RepoName: l.RepoName, TicketKey: l.TicketKey, Slug: l.Slug, Title: l.Title,
			Category: gen.LessonCategory(l.Category), Level: gen.LessonLevel(l.Level), Summary: l.Summary,
			QuizCount: len(l.Quiz), ReadMinutes: l.ReadMinutes(), LearnedAt: l.LearnedAt, CreatedAt: l.CreatedAt,
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// GetLesson implements gen.ServerInterface.
func (s *Server) GetLesson(w http.ResponseWriter, r *http.Request, id gen.LessonID) {
	if !s.lessonsReady(w) {
		return
	}
	l, err := s.opt.Lessons.Lesson(r.Context(), id)
	if err != nil {
		s.writeLessonError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toLesson(l))
}

// MarkLessonLearned implements gen.ServerInterface.
func (s *Server) MarkLessonLearned(w http.ResponseWriter, r *http.Request, id gen.LessonID) {
	s.setLearned(w, r, id, true)
}

// UnmarkLessonLearned implements gen.ServerInterface.
func (s *Server) UnmarkLessonLearned(w http.ResponseWriter, r *http.Request, id gen.LessonID) {
	s.setLearned(w, r, id, false)
}

func (s *Server) setLearned(w http.ResponseWriter, r *http.Request, id int64, learned bool) {
	if !s.lessonsReady(w) {
		return
	}
	l, err := s.opt.Lessons.SetLessonLearned(r.Context(), id, learned)
	if err != nil {
		s.writeLessonError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toLesson(l))
}

// LearnFromTicket implements gen.ServerInterface.
func (s *Server) LearnFromTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Learn(ctx, key, origin(r)) })
}

func toLesson(l domain.Lesson) gen.Lesson {
	out := gen.Lesson{
		Id: l.ID, RepoId: l.RepoID, RepoName: l.RepoName, TicketKey: l.TicketKey, Slug: l.Slug, Title: l.Title,
		Category: gen.LessonCategory(l.Category), Level: gen.LessonLevel(l.Level), Summary: l.Summary,
		Explanation: l.Explanation, WhyHere: l.WhyHere, ReadMinutes: l.ReadMinutes(), LearnedAt: l.LearnedAt, CreatedAt: l.CreatedAt,
		Refs: make([]gen.LessonRef, len(l.Refs)), Quiz: make([]gen.QuizQuestion, len(l.Quiz)), Reading: make([]gen.Link, len(l.Reading)),
	}
	for i, x := range l.Refs {
		out.Refs[i] = gen.LessonRef{Path: x.Path}
		if x.Line > 0 {
			out.Refs[i].Line = &x.Line
		}
		if x.Note != "" {
			out.Refs[i].Note = &x.Note
		}
	}
	for i, q := range l.Quiz {
		out.Quiz[i] = gen.QuizQuestion{Question: q.Question, Options: q.Options, Answer: q.Answer}
		if q.Explanation != "" {
			out.Quiz[i].Explanation = &q.Explanation
		}
	}
	for i, k := range l.Reading {
		out.Reading[i] = gen.Link{Title: k.Title, Url: k.URL}
	}
	return out
}
