package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"agnts/internal/domain"
)

// Limits of the learn stage: it runs after the work is shipped, so it gets
// a smaller budget than coding.
const (
	learnMaxTurns   = 40
	learnTimeoutMin = 20
	learnMaxLessons = 3
	learnMaxDiff    = 400 << 10
	learnMaxTopics  = 400
	learnMaxFiles   = 200 // listed in the prompt, which goes through argv
)

// LessonsFile is what the learn stage must write to LessonsPath.
type LessonsFile struct {
	Lessons []LessonOut `json:"lessons"`
}

// LessonOut is one lesson as Claude writes it.
type LessonOut struct {
	Slug        string                `json:"slug"`
	Title       string                `json:"title"`
	Category    string                `json:"category"`
	Level       string                `json:"level"`
	Summary     string                `json:"summary"`
	Explanation string                `json:"explanation"`
	WhyHere     string                `json:"whyHere"`
	Refs        []domain.LessonRef    `json:"refs"`
	Quiz        []domain.QuizQuestion `json:"quiz"`
	Reading     []domain.Link         `json:"reading"`
}

// parseLessons reads lessons.json and keeps the usable, distinct lessons.
func parseLessons(b []byte, repoID int64, key string) ([]domain.Lesson, error) {
	var f LessonsFile
	if err := json.Unmarshal(b, &f); err != nil {
		return nil, fmt.Errorf("lessons.json is not valid JSON: %w", err)
	}
	out := []domain.Lesson{}
	seen := map[string]bool{}
	for _, x := range f.Lessons {
		l := domain.Lesson{
			RepoID: repoID, TicketKey: key, Slug: x.Slug, Title: x.Title, Category: x.Category, Level: x.Level,
			Summary: x.Summary, Explanation: x.Explanation, WhyHere: x.WhyHere, Refs: x.Refs, Quiz: x.Quiz, Reading: x.Reading,
		}
		if !l.Normalize() || seen[l.Slug] {
			continue
		}
		seen[l.Slug] = true
		if out = append(out, l); len(out) == learnMaxLessons {
			break
		}
	}
	return out, nil
}

// learnQueued reports whether a ticket that just got done should be learned from.
func (o *Orchestrator) learnQueued(s domain.Settings, t domain.Ticket) bool {
	return o.lessons != nil && s.AutoLearn && t.RepoID != nil && t.Kind.Spec().Learn
}

// Learn queues a learn run for a done ticket (again, if it already ran).
func (o *Orchestrator) Learn(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	if o.lessons == nil {
		return domain.Ticket{}, invalid("learning is not available on this server")
	}
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateDone {
		return t, invalid("agnts learns from tickets once they are pushed")
	}
	if !pushedBranch(t) {
		return t, invalid("this ticket has no pushed branch to learn from")
	}
	if t.LearnState == domain.LearnPending {
		return t, nil
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Step: string(domain.StageLearn), Message: "queued to learn from",
	}, func(x *domain.Ticket) { x.LearnState = domain.LearnPending })
	if err == nil {
		o.Wake()
	}
	return t, err
}

// pushedBranch reports whether a ticket has a branch with its work in at
// least one repository.
func pushedBranch(t domain.Ticket) bool {
	for _, id := range t.RepoIDs() {
		if r, ok := t.RepoState(id); ok && r.Branch != "" && r.State != domain.RepoUnchanged {
			return true
		}
	}
	return false
}

// learn reads a pushed change and stores lessons for whatever it does that
// the repository never did before. It never changes the ticket's state. A
// ticket in several repositories is learned from in each it changed, one
// repository at a time: lessons belong to a repository.
func (o *Orchestrator) learn(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	if o.lessons == nil {
		return o.setLearnState(ctx, t.Key, domain.LearnNone)
	}
	rs, err := o.reposFor(ctx, t)
	if err != nil {
		return err
	}
	if !pushedBranch(t) {
		return errors.New("no pushed branch to learn from")
	}
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return fmt.Errorf("load the reviewed diff: %w", err)
	}
	var found []domain.Lesson
	for _, r := range rs {
		if r.Row.Branch == "" || r.Row.State == domain.RepoUnchanged {
			continue
		}
		files := domain.FilesIn(res.Files, r.ID, t.RepoID)
		if len(rs) > 1 && len(files) == 0 {
			continue
		}
		ls, err := o.learnRepo(ctx, s, t, run, r, files)
		if err != nil {
			if len(rs) > 1 {
				return fmt.Errorf("%s: %w", r.Name, err)
			}
			return err
		}
		found = append(found, ls...)
	}
	_, err = o.lessons.SaveLessons(ctx, t.Key, found, func(saved []domain.Lesson) domain.Event {
		return lessonsEvent(t.Key, run, saved)
	})
	return err
}

// learnRepo has Claude read the change in one repository (at /workspace,
// on the ticket's branch) and returns the lessons it found.
func (o *Orchestrator) learnRepo(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run, r runRepo, files []domain.FileChange) ([]domain.Lesson, error) {
	topics, err := o.lessons.LessonTopics(ctx, r.ID)
	if err != nil {
		return nil, err
	}
	if len(topics) > learnMaxTopics {
		topics = topics[:learnMaxTopics]
	}
	r.Row.Folder, r.Branch = "", r.Row.Branch // alone in its run: at /workspace
	ws, err := o.openWorkspace(ctx, t, []runRepo{r}, run)
	if err != nil {
		return nil, err
	}
	defer o.closeWorkspace(ctx, t, ws)
	if err := ws.WriteFile(ctx, ChangePath, changeDiff(files)); err != nil {
		return nil, fmt.Errorf("copy the diff into the workspace: %w", err)
	}

	if len(files) > learnMaxFiles {
		files = files[:learnMaxFiles]
	}
	prompt, err := render("learn", promptData{T: t, Repo: r.Repository, Files: files, Topics: topics, MaxLessons: learnMaxLessons})
	if err != nil {
		return nil, err
	}
	ls := s
	ls.MaxTurns = min(s.MaxTurns, learnMaxTurns)
	ls.TimeoutMin = min(s.TimeoutMin, learnTimeoutMin)
	if _, err := o.claude(ctx, ls, ws, &t, run, domain.ModelLearn, prompt, ""); err != nil {
		return nil, err
	}
	raw, err := ws.ReadFile(ctx, LessonsPath)
	if err != nil {
		return nil, fmt.Errorf("claude did not write %s: %w", LessonsPath, err)
	}
	return parseLessons(raw, r.ID, t.Key)
}

// lessonsEvent is the log line for a learn run's outcome; the notifier
// announces it when count is above zero.
func lessonsEvent(key string, run *domain.Run, saved []domain.Lesson) domain.Event {
	ids, titles := make([]int64, len(saved)), make([]string, len(saved))
	for i, l := range saved {
		ids[i], titles[i] = l.ID, l.Title
	}
	msg := "nothing new to learn from this change"
	if len(saved) > 0 {
		msg = fmt.Sprintf("%d new %s: %s", len(saved), plural(len(saved), "lesson", "lessons"), strings.Join(titles, ", "))
	}
	return domain.Event{
		TicketKey: key, RunID: &run.ID, Step: string(domain.StageLearn), Type: domain.EventLessons, Message: msg,
		Data: map[string]any{"count": len(saved), "ids": ids, "titles": titles},
	}
}

func (o *Orchestrator) setLearnState(ctx context.Context, key, state string) error {
	_, err := o.store.UpdateTicket(ctx, key, nil, func(x *domain.Ticket) { x.LearnState = state })
	return err
}

// learnFailed records a failed learn run. The ticket itself stays done.
func (o *Orchestrator) learnFailed(ctx context.Context, key string, run domain.Run, cause error) {
	if _, err := o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, RunID: &run.ID, Type: domain.EventError, Level: domain.LevelWarn, Step: string(domain.StageLearn),
		Message: "could not learn from this change: " + cause.Error(),
	}, func(x *domain.Ticket) { x.LearnState = domain.LearnFailed }); err != nil {
		o.log.Error("mark learn failed", "ticket", key, "err", err)
	}
}

// changeDiff joins the reviewed per-file diffs, capped so the run stays
// cheap. A change in several repositories is grouped by repository, each
// under a line that names its folder (the diff's paths are the
// repository's own).
func changeDiff(files []domain.FileChange) []byte {
	var b strings.Builder
	repo := ""
	for _, f := range files {
		if b.Len()+len(f.Diff) > learnMaxDiff {
			fmt.Fprintf(&b, "\n… diff of %s and later files left out; read them in /workspace …\n", f.Where())
			break
		}
		if f.Repo != "" && f.Repo != repo {
			repo = f.Repo
			fmt.Fprintf(&b, "\n### Repository %s/ (paths below are relative to /workspace/%s)\n\n", repo, repo)
		}
		b.WriteString(f.Diff)
		if !strings.HasSuffix(f.Diff, "\n") {
			b.WriteString("\n")
		}
	}
	return []byte(b.String())
}

func plural(n int, one, many string) string {
	if n == 1 {
		return one
	}
	return many
}
