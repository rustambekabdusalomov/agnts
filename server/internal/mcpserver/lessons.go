package mcpserver

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// LessonsInput narrows list_lessons.
type LessonsInput struct {
	Repository string `json:"repository,omitempty" jsonschema:"repository name; all repositories when empty"`
	Ticket     string `json:"ticket,omitempty" jsonschema:"only lessons from this ticket, e.g. PAY-214"`
	Status     string `json:"status,omitempty" jsonschema:"new (not learned yet), learned or all (default all)"`
	Query      string `json:"query,omitempty" jsonschema:"search in titles and summaries"`
	Limit      int    `json:"limit,omitempty" jsonschema:"at most this many, default 30"`
}

// LessonBrief is a lesson in lists.
type LessonBrief struct {
	ID         int64  `json:"id"`
	Title      string `json:"title"`
	Category   string `json:"category"`
	Level      string `json:"level"`
	Summary    string `json:"summary"`
	Repository string `json:"repository"`
	Ticket     string `json:"ticket"`
	Learned    bool   `json:"learned"`
	ReadMin    int    `json:"read_minutes"`
	Created    string `json:"created"`
}

// LessonList is list_lessons's output.
type LessonList struct {
	Lessons   []LessonBrief `json:"lessons"`
	Unlearned int           `json:"unlearned"`
}

func (t *tools) listLessons(ctx context.Context, _ *mcp.CallToolRequest, in LessonsInput) (*mcp.CallToolResult, LessonList, error) {
	if t.d.Lessons == nil {
		return nil, LessonList{}, errors.New("lessons are not available")
	}
	f := postgres.LessonFilter{TicketKey: strings.TrimSpace(in.Ticket), Query: in.Query, Limit: in.Limit}
	if f.Limit <= 0 || f.Limit > 100 {
		f.Limit = 30
	}
	switch in.Status {
	case "", "all":
	case "new", "learned":
		learned := in.Status == "learned"
		f.Learned = &learned
	default:
		return nil, LessonList{}, fmt.Errorf("status must be new, learned or all")
	}
	if name := strings.TrimSpace(in.Repository); name != "" {
		list, err := t.d.Repos.List(ctx)
		if err != nil {
			return nil, LessonList{}, err
		}
		for _, r := range list {
			if strings.EqualFold(r.Name, name) {
				f.RepoID = r.ID
			}
		}
		if f.RepoID == 0 {
			return nil, LessonList{}, fmt.Errorf("no repository named %q", name)
		}
	}
	ls, err := t.d.Lessons.ListLessons(ctx, f)
	if err != nil {
		return nil, LessonList{}, err
	}
	_, unlearned, err := t.d.Lessons.LessonCounts(ctx)
	if err != nil {
		return nil, LessonList{}, err
	}
	out := LessonList{Lessons: []LessonBrief{}, Unlearned: unlearned}
	for _, l := range ls {
		out.Lessons = append(out.Lessons, LessonBrief{
			ID: l.ID, Title: l.Title, Category: l.Category, Level: l.Level, Summary: l.Summary,
			Repository: l.RepoName, Ticket: l.TicketKey, Learned: l.LearnedAt != nil, ReadMin: l.ReadMinutes(), Created: l.CreatedAt.Format("2006-01-02"),
		})
	}
	return nil, out, nil
}

// LessonIDInput names a lesson.
type LessonIDInput struct {
	ID int64 `json:"id" jsonschema:"lesson id from list_lessons"`
}

// LessonOut is one full lesson.
type LessonOut struct {
	LessonBrief
	Explanation string                `json:"explanation"`
	WhyHere     string                `json:"why_here"`
	Refs        []domain.LessonRef    `json:"code_refs"`
	Quiz        []domain.QuizQuestion `json:"quiz"`
	Reading     []domain.Link         `json:"reading"`
}

func (t *tools) getLesson(ctx context.Context, _ *mcp.CallToolRequest, in LessonIDInput) (*mcp.CallToolResult, LessonOut, error) {
	if t.d.Lessons == nil {
		return nil, LessonOut{}, errors.New("lessons are not available")
	}
	l, err := t.d.Lessons.Lesson(ctx, in.ID)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, LessonOut{}, fmt.Errorf("no lesson %d", in.ID)
	}
	if err != nil {
		return nil, LessonOut{}, err
	}
	return nil, LessonOut{
		LessonBrief: LessonBrief{
			ID: l.ID, Title: l.Title, Category: l.Category, Level: l.Level, Summary: l.Summary,
			Repository: l.RepoName, Ticket: l.TicketKey, Learned: l.LearnedAt != nil, ReadMin: l.ReadMinutes(), Created: l.CreatedAt.Format("2006-01-02"),
		},
		Explanation: l.Explanation, WhyHere: l.WhyHere, Refs: l.Refs, Quiz: l.Quiz, Reading: l.Reading,
	}, nil
}
