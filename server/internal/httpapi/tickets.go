package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"slices"

	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
)

// Tickets is the ticket use-case layer (the orchestrator).
type Tickets interface {
	List(ctx context.Context, f orchestrator.TicketFilter) ([]domain.Ticket, error)
	View(ctx context.Context, key string) (orchestrator.TicketView, error)
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	Answer(ctx context.Context, key string, answers []domain.Answer, origin domain.Origin) (domain.Ticket, error)
	Approve(ctx context.Context, key string, assignees []string, postReport bool, origin domain.Origin) (domain.Ticket, error)
	AcknowledgeSecrets(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	RequestChanges(ctx context.Context, key, feedback string, shots []domain.ShotRef, files []int64, origin domain.Origin) (domain.Ticket, error)
	Reject(ctx context.Context, key, reason string, origin domain.Origin) (domain.Ticket, error)
	RetryWithNote(ctx context.Context, key, note string, files []int64, origin domain.Origin) (domain.Ticket, error)
	Continue(ctx context.Context, key, note string, files []int64, origin domain.Origin) (domain.Ticket, error)
	StartOver(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	RenameBranch(ctx context.Context, key string, repoID int64, name string, origin domain.Origin) (domain.Ticket, error)
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
	Replay(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	ReplayReport(ctx context.Context) (orchestrator.ReplayReport, error)
	Review(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	RestartWithUpdate(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	KeepCurrentVersion(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	Preview(ctx context.Context, key string, compare *bool, origin domain.Origin) (domain.Ticket, error)
	OpenShot(ctx context.Context, key string, runID int64, shotID string) (io.ReadCloser, error)
	Translate(ctx context.Context, key, lang string) ([]orchestrator.TranslatedText, error)
	SetMember(ctx context.Context, key string, userID int64, name string, origin domain.Origin) (domain.Ticket, error)
	FollowUpTickets
	RelationTickets
	Attachments
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
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", err.Error())
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
		Ticket: toTicketRow(orchestrator.TicketRow{Ticket: v.Ticket, Info: v.Info, RepoName: v.RepoName, Spend: v.Spend,
			OpenSuggestions: openSuggestions(v.FollowUps.Suggestions), Blockers: v.Relations.Blockers, Member: v.Member, CreatedBy: v.CreatedBy}),
		Questions:   make([]gen.Question, len(v.Questions)),
		Attachments: make([]gen.Attachment, len(v.Attachments)),
		History:     &[]gen.HistoryItem{},
		MaxTurns:    &v.Settings.MaxTurns,
	}
	stages := toStageSpend(v.Stages)
	d.SpendByStage = &stages
	for _, h := range v.History {
		item := gen.HistoryItem{At: h.At, State: gen.TicketState(h.State), Message: h.Message, Origin: string(h.Origin)}
		if h.User != "" {
			user := h.User
			item.User = &user
		}
		*d.History = append(*d.History, item)
	}
	em := gen.StageModels{
		Analyze: v.Settings.ModelFor(v.Ticket, domain.ModelAnalyze),
		Coding:  v.Settings.ModelFor(v.Ticket, domain.ModelCoding),
		Retry:   v.Settings.ModelFor(v.Ticket, domain.ModelRetry),
		Helper:  v.Settings.Models.Helper,
	}
	rm := v.Settings.ModelFor(v.Ticket, domain.ModelReview)
	em.Review = &rm
	pm := v.Settings.ModelFor(v.Ticket, domain.ModelPreview)
	em.Preview = &pm
	canPreview := v.CanPreview
	d.Ticket.CanPreview = &canPreview
	if v.ContinueTo != "" {
		to, startOver := gen.TicketState(v.ContinueTo), v.CanStartOver
		d.Ticket.ContinueTo, d.Ticket.CanStartOver = &to, &startOver
	}
	if d.Ticket.Repos != nil {
		for i, r := range *d.Ticket.Repos {
			if slices.Contains(v.RenameBranch, r.RepoId) {
				(*d.Ticket.Repos)[i].CanRenameBranch = ptr(true)
			}
		}
	}
	d.EffectiveModels = &em
	for i, q := range v.Questions {
		opts := q.Options
		if opts == nil {
			opts = []string{}
		}
		d.Questions[i] = gen.Question{Id: q.ID, Position: q.Position, Text: q.Text, Options: opts, Multiple: q.Multiple, Answer: q.Answer, Note: q.Note}
	}
	for i, a := range v.Attachments {
		d.Attachments[i] = toAttachment(a)
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
		d.Analysis.Footprint = toFootprint(v.Analysis.Footprint)
		toDesign(d.Analysis, *v.Analysis)
		if v.Analysis.Defect {
			d.Analysis.Defect = ptr(true)
		}
		if len(v.Analysis.Acceptance) > 0 {
			var g gen.Analysis
			_ = json.Unmarshal(mustJSON(map[string]any{"acceptance": v.Analysis.Acceptance}), &g)
			d.Analysis.Acceptance = g.Acceptance
		}
		if v.SecondOpinion != nil {
			d.Analysis.SecondOpinion = ptr(via[gen.SecondOpinion](v.SecondOpinion))
		}
	}
	rels := toRelations(v.Ticket.Key, v.Relations)
	d.Relations = &rels
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
	if v.Preview != nil {
		d.Preview = toPreview(v.Ticket.Key, *v.Preview)
	}
	fu := toFollowUps(v.FollowUps, v.FollowUpsOn, v.Ticket.State)
	d.FollowUps = &fu
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
	out := gen.Event{
		Id: e.ID, TicketKey: e.TicketKey, RunId: e.RunID, Step: e.Step, Type: e.Type,
		Level: gen.EventLevel(e.Level), Origin: gen.EventOrigin(e.Origin), Message: e.Message,
		Data: data, DurationMs: e.DurationMS, CreatedAt: e.CreatedAt,
	}
	if e.Username != "" {
		user := e.Username
		out.User = &user
	}
	return out
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
		as[i] = domain.Answer{QuestionID: a.QuestionId, Answer: a.Answer, Attachments: ids(a.Attachments)}
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
		var shots []domain.ShotRef
		if req.Shots != nil {
			for _, x := range *req.Shots {
				shots = append(shots, domain.ShotRef{RunID: x.RunId, ShotID: x.ShotId})
			}
		}
		return s.opt.Tickets.RequestChanges(ctx, key, req.Feedback, shots, ids(req.Attachments), origin(r))
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
	var req gen.RetryTicketJSONRequestBody
	if r.ContentLength != 0 {
		if err := decodeJSON(r, &req); err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", err.Error())
			return
		}
	}
	note := ""
	if req.Note != nil {
		note = *req.Note
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.RetryWithNote(ctx, key, note, ids(req.Attachments), origin(r))
	})
}

// ContinueTicket implements gen.ServerInterface.
func (s *Server) ContinueTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.ContinueTicketJSONRequestBody
	if r.ContentLength != 0 {
		if err := decodeJSON(r, &req); err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", err.Error())
			return
		}
	}
	note := ""
	if req.Note != nil {
		note = *req.Note
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Continue(ctx, key, note, ids(req.Attachments), origin(r))
	})
}

// StartTicketOver implements gen.ServerInterface.
func (s *Server) StartTicketOver(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.StartOver(ctx, key, origin(r))
	})
}

// RenameTicketBranch implements gen.ServerInterface.
func (s *Server) RenameTicketBranch(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.RenameTicketBranchJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var repoID int64
	if req.RepoId != nil {
		repoID = *req.RepoId
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.RenameBranch(ctx, key, repoID, req.Branch, origin(r))
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
	if !r.Spend.IsZero() {
		sp := toTokenSpend(r.Spend)
		out.Spend = &sp
	}
	if r.OpenSuggestions > 0 {
		n := r.OpenSuggestions
		out.OpenSuggestions = &n
	}
	if len(r.Blockers) > 0 {
		bs := toBlockers(r.Blockers)
		out.BlockedBy = &bs
	}
	if r.Member != "" {
		m := r.Member
		out.Member = &m
	}
	if r.CreatedBy != "" {
		c := r.CreatedBy
		out.CreatedBy = &c
	}
	return out
}

func openSuggestions(ss []domain.Suggestion) int {
	n := 0
	for _, x := range ss {
		if x.Status == domain.SuggestionOpen {
			n++
		}
	}
	return n
}

func toTokenSpend(u domain.TokenUsage) gen.TokenSpend {
	return gen.TokenSpend{Input: u.Input, Output: u.Output, CacheRead: u.CacheRead, CacheWrite: u.CacheWrite,
		Total: u.Total(), CostUsd: u.CostUSD}
}

func toStageSpend(stages []domain.StageUsage) []gen.StageSpend {
	out := make([]gen.StageSpend, len(stages))
	for i, st := range stages {
		out[i] = gen.StageSpend{Stage: gen.StageSpendStage(st.ModelStage), Model: st.Model, Calls: st.Calls,
			Turns: st.Turns, Partial: st.Partial, Spend: toTokenSpend(st.Usage)}
	}
	return out
}

func toTicket(t domain.Ticket) gen.Ticket {
	out := gen.Ticket{
		Key: t.Key, Source: gen.TicketSource(t.Source), RepoId: t.RepoID, Title: t.Title, Description: t.Description,
		Priority: t.Priority, State: gen.TicketState(t.State), Revision: t.Revision, Turns: t.Turns,
		Branch: t.Branch, PrNumber: t.PRNumber, PrUrl: t.PRURL, CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt,
		Kind: gen.TicketKind(t.Kind), KindAuto: t.KindAuto, MemberId: t.MemberID, QueuedAt: t.QueuedAt,
	}
	if t.TicketNumber != "" {
		out.TicketNumber = ptr(t.TicketNumber)
	}
	if t.CIFixes > 0 {
		out.CiFixes = ptr(t.CIFixes)
	}
	if rs := toTicketRepos(t); len(rs) > 0 {
		out.Repos = &rs
	}
	if t.GroupID != nil {
		out.Group = &gen.RepoGroupRef{Id: *t.GroupID, Name: t.GroupName}
	}
	if t.PartlyMerged() {
		out.PartlyMerged = ptr(true)
	}
	if t.WaitReason != domain.WaitNone {
		wr := gen.WaitReason(t.WaitReason)
		out.WaitReason = &wr
		if t.WaitMessage != "" {
			msg := t.WaitMessage
			out.WaitMessage = &msg
		}
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
	if t.FollowUpOf != "" {
		of := t.FollowUpOf
		out.FollowUpOf = &of
	}
	if t.ReplayOf != "" {
		of := t.ReplayOf
		out.ReplayOf = &of
	}
	mode := toFollowUpsMode(t.SuggestFollowUps)
	out.SuggestFollowUps = &mode
	if t.State == domain.StateFailed || t.State == domain.StateRateLimited {
		rs := gen.TicketState(t.ResumeState)
		out.ResumeState = &rs
	}
	out.MergedAt = t.MergedAt
	if t.HeadSHA != "" {
		sha := t.HeadSHA
		out.HeadSha = &sha
	}
	if t.Pull != nil {
		pr := toPullRequest(*t.Pull)
		out.Pull = &pr
	}
	if u := t.Update; u != nil && !t.State.Terminal() {
		out.TrackerUpdate = &gen.TrackerUpdate{Title: u.Title, Description: u.Description, At: u.At}
	}
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
	ps := gen.TicketPreviewState(t.PreviewState)
	if ps == "" {
		ps = gen.TicketPreviewStateNone
	}
	compare := t.PreviewCompare
	out.PreviewState, out.PreviewCompare = &ps, &compare
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
			mv := v
			m.Analyze = &mv
		}
		if v, ok := t.Models[domain.ModelCoding]; ok {
			mv := v
			m.Coding = &mv
		}
		if v, ok := t.Models[domain.ModelRetry]; ok {
			mv := v
			m.Retry = &mv
		}
		if v, ok := t.Models[domain.ModelReview]; ok {
			mv := v
			m.Review = &mv
		}
		if v, ok := t.Models[domain.ModelPreview]; ok {
			mv := v
			m.Preview = &mv
		}
		out.Models = &m
	}
	return out
}

// ReviewTicket implements gen.ServerInterface.
func (s *Server) ReviewTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Review(ctx, key, origin(r)) })
}

// RestartWithUpdate implements gen.ServerInterface.
func (s *Server) RestartWithUpdate(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.RestartWithUpdate(ctx, key, origin(r))
	})
}

// KeepCurrentVersion implements gen.ServerInterface.
func (s *Server) KeepCurrentVersion(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.KeepCurrentVersion(ctx, key, origin(r))
	})
}

// PostPullReview implements gen.ServerInterface.
func (s *Server) PostPullReview(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if !s.reviewsReady(w) {
		return
	}
	var req gen.PostReviewInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	opt := orchestrator.PostReviewOptions{Summary: req.Summary == nil || *req.Summary, RequestChanges: req.RequestChanges != nil && *req.RequestChanges}
	if req.Findings != nil {
		opt.Findings = *req.Findings
		if opt.Findings == nil {
			opt.Findings = []int{}
		}
	}
	t, _, err := s.opt.Reviews.PostPullReview(r.Context(), key, opt, origin(r))
	switch {
	case errors.Is(err, orchestrator.ErrHost):
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
	case err != nil:
		s.writeUseCaseError(w, r, err)
	default:
		s.writeTicket(w, r, http.StatusOK, t)
	}
}

// PreviewTicket implements gen.ServerInterface.
func (s *Server) PreviewTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.PreviewInput
	if r.ContentLength != 0 {
		if err := decodeJSON(r, &req); err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", err.Error())
			return
		}
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.Preview(ctx, key, req.Compare, origin(r))
	})
}

// GetPreviewShot implements gen.ServerInterface. A run's screenshots never
// change, so the browser may keep them.
func (s *Server) GetPreviewShot(w http.ResponseWriter, r *http.Request, key gen.TicketKey, runID int64, shotID string) {
	rc, err := s.opt.Tickets.OpenShot(r.Context(), key, runID, shotID)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			writeError(w, http.StatusNotFound, "not_found", "no such screenshot")
			return
		}
		s.writeInternal(w, r, err)
		return
	}
	defer func() { _ = rc.Close() }()
	w.Header().Set("Content-Type", "image/png")
	w.Header().Set("Cache-Control", "private, max-age=31536000, immutable")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	if _, err := io.Copy(w, rc); err != nil {
		s.opt.Log.Debug("send screenshot", "err", err)
	}
}

func toPreview(key string, p domain.Preview) *gen.TicketPreview {
	out := &gen.TicketPreview{
		RunId: p.RunID, Revision: p.Revision, Model: p.Model, Compare: p.Compare,
		Status: gen.TicketPreviewStatus(p.Status), Summary: p.Summary, CreatedAt: p.CreatedAt,
		Shots: make([]gen.PreviewShot, len(p.Shots)), Issues: make([]gen.PreviewIssue, len(p.Issues)),
	}
	opt := func(s string) *string {
		if s == "" {
			return nil
		}
		return &s
	}
	optInt := func(n int) *int {
		if n == 0 {
			return nil
		}
		return &n
	}
	for i, sh := range p.Shots {
		out.Shots[i] = gen.PreviewShot{
			Id: sh.ID, Name: sh.Name, Route: sh.Route, Viewport: gen.PreviewShotViewport(sh.Viewport), Side: gen.PreviewShotSide(sh.Side),
			Note: opt(sh.Note), Width: optInt(sh.Width), Height: optInt(sh.Height), ConsoleErrors: optInt(sh.ConsoleErrors),
			Url: fmt.Sprintf("/tickets/%s/preview/%d/shots/%s", key, p.RunID, sh.ID),
		}
	}
	for i, is := range p.Issues {
		out.Issues[i] = gen.PreviewIssue{Severity: gen.PreviewIssueSeverity(is.Severity), Description: is.Description, ShotId: opt(is.ShotID)}
	}
	if p.Acceptance != nil {
		out.Acceptance = ptr(via[gen.Acceptance](p.Acceptance))
	}
	return out
}

// TranslateTicket implements gen.ServerInterface.
func (s *Server) TranslateTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.TranslateInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Lang.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "unknown language "+string(req.Lang))
		return
	}
	items, err := s.opt.Tickets.Translate(r.Context(), key, string(req.Lang))
	if errors.Is(err, orchestrator.ErrPlanLimit) {
		writeError(w, http.StatusTooManyRequests, "plan_limit", err.Error())
		return
	}
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	out := gen.Translation{Lang: req.Lang, Items: make([]struct {
		Source string `json:"source"`
		Text   string `json:"text"`
	}, len(items))}
	for i, x := range items {
		out.Items[i].Source, out.Items[i].Text = x.Source, x.Text
	}
	writeJSON(w, http.StatusOK, out)
}

func toReview(rv domain.Review) *gen.CodeReview {
	out := &gen.CodeReview{
		Revision: rv.Revision, Model: rv.Model, ModelReason: rv.ModelReason, Verdict: gen.CodeReviewVerdict(rv.Verdict),
		Summary: rv.Summary, Findings: make([]gen.Finding, len(rv.Findings)), Strengths: rv.Strengths, CreatedAt: rv.CreatedAt,
	}
	if out.Strengths == nil {
		out.Strengths = []string{}
	}
	if rv.Deep {
		out.Deep = ptr(true)
	}
	if rv.Dropped > 0 {
		out.Dropped = ptr(rv.Dropped)
	}
	opt := func(s string) *string {
		if s == "" {
			return nil
		}
		return &s
	}
	for i, f := range rv.Findings {
		out.Findings[i] = gen.Finding{Severity: gen.FindingSeverity(f.Severity), Category: gen.FindingCategory(f.Category), Title: f.Title,
			File: opt(f.File), Detail: opt(f.Detail), Suggestion: opt(f.Suggestion), Pass: opt(f.Pass)}
		if f.Confidence > 0 {
			c := float32(f.Confidence)
			out.Findings[i].Confidence = &c
		}
		if f.Adopted {
			out.Findings[i].Adopted = ptr(true)
		}
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
	if len(sum.Deviations) > 0 {
		out.Deviations = &sum.Deviations
	}
	if p := r.Harness.Proof; p != nil {
		out.Proof = ptr(via[gen.Proof](p))
	}
	if c := r.Harness.Coverage; c != nil {
		out.Coverage = ptr(via[gen.Coverage](c))
	}
	if len(r.RedFlags) > 0 {
		flags := make([]gen.RedFlag, len(r.RedFlags))
		for i, f := range r.RedFlags {
			flags[i] = gen.RedFlag{Kind: gen.RedFlagKind(f.Kind), Path: f.Path, Text: f.Text}
			if f.Line > 0 {
				line := f.Line
				flags[i].Line = &line
			}
		}
		out.RedFlags = &flags
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
		if f.Repo != "" {
			out.Files[i].Repo, out.Files[i].RepoId = ptr(f.Repo), ptr(f.RepoID)
		}
	}
	if r.Report != "" {
		report := r.Report
		out.Report = &report
	}
	return out
}

// SetTicketMember implements gen.ServerInterface.
func (s *Server) SetTicketMember(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.SetTicketMemberJSONBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	u, _ := userFrom(r.Context())
	m, _ := memberFrom(r.Context())
	uid, name := req.UserId, u.Username
	if uid == 0 {
		uid = u.ID
	}
	if uid != u.ID {
		if s.opt.Workspaces == nil {
			writeError(w, http.StatusBadRequest, "bad_request", "not a member of this workspace")
			return
		}
		role, err := s.opt.Workspaces.Role(r.Context(), m.w.ID, uid)
		if err != nil {
			writeError(w, http.StatusBadRequest, "bad_request", "not a member of this workspace")
			return
		}
		if !role.CanEdit() {
			writeError(w, http.StatusConflict, "conflict", "a viewer cannot own a ticket")
			return
		}
		if s.opt.Users != nil {
			if x, err := s.opt.Users.ByID(r.Context(), uid); err == nil {
				name = x.Username
			}
		}
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetMember(ctx, key, uid, name, origin(r))
	})
}

// toDesign adds the analysis's approaches, scope and ship notes.
func toDesign(out *gen.Analysis, a orchestrator.Analysis) {
	if len(a.Approaches) > 0 {
		aps := make([]gen.Approach, len(a.Approaches))
		for i, x := range a.Approaches {
			aps[i] = gen.Approach{Title: x.Title, Sketch: x.Sketch, Pros: nonNilStrings(x.Pros), Cons: nonNilStrings(x.Cons), Chosen: x.Chosen}
			if x.Fit != "" {
				aps[i].Fit = &x.Fit
			}
			if x.Why != "" {
				aps[i].Why = &x.Why
			}
		}
		out.Approaches = &aps
	}
	if len(a.OutOfScope) > 0 {
		scope := a.OutOfScope
		out.OutOfScope = &scope
	}
	if n := a.ShipPlan(); n != nil {
		sn := gen.ShipNotes{}
		for _, f := range []struct {
			v   string
			dst **string
		}{{n.Migrations, &sn.Migrations}, {n.Compatibility, &sn.Compatibility}, {n.Rollout, &sn.Rollout}, {n.Rollback, &sn.Rollback}} {
			if f.v != "" {
				v := f.v
				*f.dst = &v
			}
		}
		out.Ship = &sn
	}
}

func nonNilStrings(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}
