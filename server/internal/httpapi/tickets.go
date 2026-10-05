package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"hiro/internal/domain"
	"hiro/internal/httpapi/gen"
	"hiro/internal/orchestrator"
)

// Tickets is the ticket use-case layer (the orchestrator).
type Tickets interface {
	List(ctx context.Context, f orchestrator.TicketFilter) ([]domain.Ticket, error)
	View(ctx context.Context, key string) (orchestrator.TicketView, error)
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	Answer(ctx context.Context, key string, answers []domain.Answer, origin domain.Origin) (domain.Ticket, error)
	Approve(ctx context.Context, key string, assignees []string, postReport bool, origin domain.Origin) (domain.Ticket, error)
	RequestChanges(ctx context.Context, key, feedback string, origin domain.Origin) (domain.Ticket, error)
	Reject(ctx context.Context, key, reason string, origin domain.Origin) (domain.Ticket, error)
	Retry(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	Start(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	Stop(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	SetModels(ctx context.Context, key string, models map[string]string, origin domain.Origin) (domain.Ticket, error)
	SetRepo(ctx context.Context, key string, repoID int64, origin domain.Origin) (domain.Ticket, error)
	SetKind(ctx context.Context, key, kind string, origin domain.Origin) (domain.Ticket, error)
	Implement(ctx context.Context, key string, in orchestrator.ImplementInput, origin domain.Origin) (domain.Ticket, error)
	CreateTask(ctx context.Context, in orchestrator.TaskInput, origin domain.Origin) (domain.Ticket, error)
	UpdateTask(ctx context.Context, key string, in orchestrator.TaskInput, origin domain.Origin) (domain.Ticket, error)
	DeleteTask(ctx context.Context, key string, origin domain.Origin) error
	Rows(ctx context.Context, ts []domain.Ticket) ([]orchestrator.TicketRow, error)
	Learn(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	Review(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	Wake()
}

// origin tells the audit log which client acted: the web panel uses the
// cookie, the mobile app the bearer token.
func origin(r *http.Request) domain.Origin {
	if r.Header.Get("Authorization") != "" {
		return domain.OriginMobile
	}
	return domain.OriginWeb
}

// writeUseCaseError maps use-case errors to HTTP statuses.
func (s *Server) writeUseCaseError(w http.ResponseWriter, r *http.Request, err error) {
	var te *domain.TransitionError
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "no such ticket")
	case errors.As(err, &te):
		writeError(w, http.StatusConflict, "conflict", "not possible while the ticket is "+string(te.From))
	case errors.Is(err, orchestrator.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

// ListTickets implements gen.ServerInterface.
func (s *Server) ListTickets(w http.ResponseWriter, r *http.Request, p gen.ListTicketsParams) {
	var f orchestrator.TicketFilter
	if p.State != nil {
		for _, st := range *p.State {
			ds := domain.TicketState(st)
			if !ds.Valid() {
				writeError(w, http.StatusBadRequest, "bad_request", "unknown state "+string(st))
				return
			}
			f.States = append(f.States, ds)
		}
	}
	ts, err := s.opt.Tickets.List(r.Context(), f)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	rows, err := s.opt.Tickets.Rows(r.Context(), ts)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := make([]gen.Ticket, len(rows))
	for i, row := range rows {
		out[i] = toTicketRow(row)
	}
	writeJSON(w, http.StatusOK, out)
}

// GetTicket implements gen.ServerInterface.
func (s *Server) GetTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	v, err := s.opt.Tickets.View(r.Context(), key)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	d := gen.TicketDetail{
		Ticket:    toTicketRow(orchestrator.TicketRow{Ticket: v.Ticket, Info: v.Info, RepoName: v.RepoName}),
		Questions: make([]gen.Question, len(v.Questions)),
		History:   &[]gen.HistoryItem{},
		MaxTurns:  &v.Settings.MaxTurns,
	}
	for _, h := range v.History {
		*d.History = append(*d.History, gen.HistoryItem{At: h.At, State: gen.TicketState(h.State), Message: h.Message, Origin: string(h.Origin)})
	}
	em := gen.StageModels{
		Analyze: gen.Model(v.Settings.ModelFor(v.Ticket, domain.ModelAnalyze)),
		Coding:  gen.Model(v.Settings.ModelFor(v.Ticket, domain.ModelCoding)),
		Retry:   gen.Model(v.Settings.ModelFor(v.Ticket, domain.ModelRetry)),
		Helper:  gen.Model(v.Settings.Models.Helper),
	}
	rm := gen.ReviewModel(v.Settings.ModelFor(v.Ticket, domain.ModelReview))
	em.Review = &rm
	d.EffectiveModels = &em
	for i, q := range v.Questions {
		opts := q.Options
		if opts == nil {
			opts = []string{}
		}
		d.Questions[i] = gen.Question{Id: q.ID, Position: q.Position, Text: q.Text, Options: opts, Answer: q.Answer, Note: q.Note}
	}
	if v.Analysis != nil {
		plan := v.Analysis.Plan
		if plan == nil {
			plan = []string{}
		}
		d.Analysis = &gen.Analysis{Summary: v.Analysis.Summary, Plan: plan}
		if c := gen.AnalysisComplexity(v.Analysis.Complexity); c.Valid() {
			d.Analysis.Complexity = &c
		}
	}
	if v.Result != nil {
		d.Result = toResult(*v.Result)
	}
	if v.ChildKey != "" {
		child := v.ChildKey
		d.ChildKey = &child
	}
	if v.Review != nil {
		d.Review = toReview(*v.Review)
	}
	writeJSON(w, http.StatusOK, d)
}

// ListTicketEvents implements gen.ServerInterface.
func (s *Server) ListTicketEvents(w http.ResponseWriter, r *http.Request, key gen.TicketKey, p gen.ListTicketEventsParams) {
	f := orchestrator.EventFilter{TicketKey: key}
	if p.After != nil {
		f.AfterID = *p.After
	}
	if p.Limit != nil {
		f.Limit = *p.Limit
	}
	evs, err := s.opt.Tickets.Events(r.Context(), f)
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := make([]gen.Event, len(evs))
	for i, e := range evs {
		out[i] = toEvent(e)
	}
	writeJSON(w, http.StatusOK, out)
}

func toEvent(e domain.Event) gen.Event {
	// Typed clients (the Dart one) reject null map values; drop them.
	data := make(map[string]any, len(e.Data))
	for k, v := range e.Data {
		if v != nil {
			data[k] = v
		}
	}
	return gen.Event{
		Id: e.ID, TicketKey: e.TicketKey, RunId: e.RunID, Step: e.Step, Type: e.Type,
		Level: gen.EventLevel(e.Level), Origin: gen.EventOrigin(e.Origin), Message: e.Message,
		Data: data, DurationMs: e.DurationMS, CreatedAt: e.CreatedAt,
	}
}

// AnswerQuestions implements gen.ServerInterface.
func (s *Server) AnswerQuestions(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.AnswersRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	as := make([]domain.Answer, len(req.Answers))
	for i, a := range req.Answers {
		as[i] = domain.Answer{QuestionID: a.QuestionId, Answer: a.Answer}
		if a.Note != nil {
			as[i].Note = *a.Note
		}
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Answer(ctx, key, as, origin(r))
	})
}

// ApproveTicket implements gen.ServerInterface.
func (s *Server) ApproveTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.ApproveTicketJSONRequestBody
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var assignees []string
	if req.Assignees != nil {
		assignees = *req.Assignees
	}
	post := req.PostReport != nil && *req.PostReport
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Approve(ctx, key, assignees, post, origin(r))
	})
}

// RequestChanges implements gen.ServerInterface.
func (s *Server) RequestChanges(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.RequestChangesJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.RequestChanges(ctx, key, req.Feedback, origin(r))
	})
}

// RejectTicket implements gen.ServerInterface.
func (s *Server) RejectTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.RejectTicketJSONRequestBody
	if r.ContentLength != 0 {
		if err := decodeJSON(r, &req); err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", err.Error())
			return
		}
	}
	reason := ""
	if req.Reason != nil {
		reason = *req.Reason
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Reject(ctx, key, reason, origin(r))
	})
}

// RetryTicket implements gen.ServerInterface.
func (s *Server) RetryTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Retry(ctx, key, origin(r))
	})
}

func (s *Server) ticketAction(w http.ResponseWriter, r *http.Request, f func(context.Context) (domain.Ticket, error)) {
	t, err := f(r.Context())
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusOK, t)
}

func (s *Server) writeTicket(w http.ResponseWriter, r *http.Request, status int, t domain.Ticket) {
	rows, err := s.opt.Tickets.Rows(r.Context(), []domain.Ticket{t})
	if err != nil || len(rows) == 0 {
		writeJSON(w, status, toTicket(t))
		return
	}
	writeJSON(w, status, toTicketRow(rows[0]))
}

func toTicketRow(r orchestrator.TicketRow) gen.Ticket {
	out := toTicket(r.Ticket)
	if !r.Info.Since.IsZero() {
		since := r.Info.Since
		out.Since = &since
	}
	if (r.Ticket.State == domain.StateFailed || r.Ticket.State == domain.StateRateLimited) && r.Info.Reason != "" {
		reason := r.Info.Reason
		out.StopReason = &reason
	}
	if r.RepoName != "" {
		name := r.RepoName
		out.RepoName = &name
	}
	return out
}

func toTicket(t domain.Ticket) gen.Ticket {
	out := gen.Ticket{
		Key: t.Key, Source: gen.TicketSource(t.Source), RepoId: t.RepoID, Title: t.Title, Description: t.Description,
		Priority: t.Priority, State: gen.TicketState(t.State), Revision: t.Revision, Turns: t.Turns,
		Branch: t.Branch, PrNumber: t.PRNumber, PrUrl: t.PRURL, CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt,
		Kind: gen.TicketKind(t.Kind), KindAuto: t.KindAuto,
	}
	if out.Kind == "" {
		out.Kind = gen.TicketKindCode
	}
	if t.PostReport {
		post := true
		out.PostReport = &post
	}
	if t.ParentKey != "" {
		parent := t.ParentKey
		out.ParentKey = &parent
	}
	if t.State == domain.StateFailed || t.State == domain.StateRateLimited {
		rs := gen.TicketState(t.ResumeState)
		out.ResumeState = &rs
	}
	out.MergedAt = t.MergedAt
	ls := gen.TicketLearnState(t.LearnState)
	if ls == "" {
		ls = gen.TicketLearnStateNone
	}
	out.LearnState = &ls
	rs := gen.TicketReviewState(t.ReviewState)
	if rs == "" {
		rs = gen.TicketReviewStateNone
	}
	out.ReviewState = &rs
	if len(t.Assignees) > 0 {
		as := t.Assignees
		out.Assignees = &as
	}
	after := gen.TicketAfterApprove(t.AfterApprove)
	held, ask := t.Held, t.AskFirst
	out.AfterApprove, out.Held, out.AskFirst = &after, &held, &ask
	if len(t.Models) > 0 {
		m := gen.ModelOverrides{}
		if v, ok := t.Models[domain.ModelAnalyze]; ok {
			mv := gen.Model(v)
			m.Analyze = &mv
		}
		if v, ok := t.Models[domain.ModelCoding]; ok {
			mv := gen.Model(v)
			m.Coding = &mv
		}
		if v, ok := t.Models[domain.ModelRetry]; ok {
			mv := gen.Model(v)
			m.Retry = &mv
		}
		if v, ok := t.Models[domain.ModelReview]; ok {
			mv := gen.Model(v)
			m.Review = &mv
		}
		out.Models = &m
	}
	return out
}

// ReviewTicket implements gen.ServerInterface.
func (s *Server) ReviewTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Review(ctx, key, origin(r)) })
}

func toReview(rv domain.Review) *gen.CodeReview {
	out := &gen.CodeReview{
		Revision: rv.Revision, Model: gen.Model(rv.Model), ModelReason: rv.ModelReason, Verdict: gen.CodeReviewVerdict(rv.Verdict),
		Summary: rv.Summary, Findings: make([]gen.Finding, len(rv.Findings)), Strengths: rv.Strengths, CreatedAt: rv.CreatedAt,
	}
	if out.Strengths == nil {
		out.Strengths = []string{}
	}
	opt := func(s string) *string {
		if s == "" {
			return nil
		}
		return &s
	}
	for i, f := range rv.Findings {
		out.Findings[i] = gen.Finding{Severity: gen.FindingSeverity(f.Severity), Category: gen.FindingCategory(f.Category), Title: f.Title,
			File: opt(f.File), Detail: opt(f.Detail), Suggestion: opt(f.Suggestion)}
		if f.Line > 0 {
			line := f.Line
			out.Findings[i].Line = &line
		}
	}
	return out
}

func toResult(r domain.Result) *gen.Result {
	var sum orchestrator.Summary
	_ = json.Unmarshal(r.Summary, &sum)
	var steps []orchestrator.CheckStep
	_ = json.Unmarshal(r.Tests, &steps)
	out := &gen.Result{
		Summary: sum.Summary, Notes: sum.Notes, Checks: make([]gen.CheckStep, len(steps)),
		Files: make([]gen.FileChange, len(r.Files)), CreatedAt: r.CreatedAt,
	}
	if out.Notes == nil {
		out.Notes = []string{}
	}
	for i, c := range steps {
		c := c
		out.Checks[i] = gen.CheckStep{Name: c.Name, Command: c.Command, ExitCode: c.ExitCode, DurationMs: c.DurationMS}
		if c.TimedOut {
			out.Checks[i].TimedOut = &c.TimedOut
		}
		if c.Output != "" {
			out.Checks[i].Output = &c.Output
		}
	}
	for i, f := range r.Files {
		out.Files[i] = gen.FileChange{Path: f.Path, Add: f.Add, Del: f.Del, Diff: f.Diff}
	}
	if r.Report != "" {
		report := r.Report
		out.Report = &report
	}
	return out
}
