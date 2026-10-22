package httpapi

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"time"

	"agnts/internal/admin"
	"agnts/internal/docs"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

// Admin groups the services behind the Phase 2 pages.
type Admin struct {
	Settings interface {
		Get(ctx context.Context) (domain.Settings, error)
		Put(ctx context.Context, s domain.Settings, origin domain.Origin) (domain.Settings, error)
	}
	Usage        *usage.Tracker
	Refresher    *usage.Refresher
	Logs         *postgres.Agent
	Dashboard    *admin.Dashboard
	Integrations *admin.Integrations
	Repos        *admin.Repos
	Docs         *docs.Docs
}

func (s *Server) adminReady(w http.ResponseWriter) bool {
	if s.opt.Admin == nil {
		writeError(w, http.StatusNotImplemented, "unsupported", "not available")
		return false
	}
	return true
}

// ---- ticket extras ----

// StartTicket implements gen.ServerInterface.
func (s *Server) StartTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Start(ctx, key, origin(r)) })
}

// StopTicket implements gen.ServerInterface.
func (s *Server) StopTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) { return s.opt.Tickets.Stop(ctx, key, origin(r)) })
}

// SetTicketModels implements gen.ServerInterface.
func (s *Server) SetTicketModels(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.ModelOverrides
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	m := map[string]string{}
	if req.Analyze != nil {
		m[domain.ModelAnalyze] = *req.Analyze
	}
	if req.Coding != nil {
		m[domain.ModelCoding] = *req.Coding
	}
	if req.Retry != nil {
		m[domain.ModelRetry] = *req.Retry
	}
	if req.Preview != nil {
		m[domain.ModelPreview] = *req.Preview
	}
	if req.Review != nil {
		m[domain.ModelReview] = *req.Review
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetModels(ctx, key, m, origin(r))
	})
}

// SetTicketRepo implements gen.ServerInterface.
func (s *Server) SetTicketRepo(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.TicketRepo
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetRepo(ctx, key, req.RepoId, origin(r))
	})
}

// ImplementTicket implements gen.ServerInterface.
func (s *Server) ImplementTicket(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.ImplementInput
	if err := decodeOptionalJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var in orchestrator.ImplementInput
	if req.RepoId != nil {
		in.RepoID = *req.RepoId
	}
	if req.RepoIds != nil {
		in.RepoIDs = *req.RepoIds
	}
	if req.GroupId != nil {
		in.GroupID = *req.GroupId
	}
	if req.Start != nil {
		in.Start = string(*req.Start)
	}
	t, err := s.opt.Tickets.Implement(r.Context(), key, in, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// SetTicketKind implements gen.ServerInterface.
func (s *Server) SetTicketKind(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.TicketKindInput
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	if !req.Kind.Valid() {
		writeError(w, http.StatusBadRequest, "bad_request", "unknown kind "+string(req.Kind))
		return
	}
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.SetKind(ctx, key, string(req.Kind), origin(r))
	})
}

// CreateTask implements gen.ServerInterface.
func (s *Server) CreateTask(w http.ResponseWriter, r *http.Request) {
	var req gen.TaskCreate
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	in := orchestrator.TaskInput{Title: req.Title, Priority: string(req.Priority),
		AfterApprove: string(req.AfterApprove), Start: string(req.Start), TicketNumber: req.TicketNumber}
	if req.RepoId != nil {
		in.RepoID = *req.RepoId
	}
	if req.RepoIds != nil {
		in.RepoIDs = *req.RepoIds
	}
	if req.GroupId != nil {
		in.GroupID = *req.GroupId
	}
	if req.Kind != nil {
		in.Kind = string(*req.Kind)
	}
	if req.Description != nil {
		in.Description = *req.Description
	}
	if req.FollowUps != nil {
		on, ok := followUpsMode(*req.FollowUps)
		if !ok {
			writeError(w, http.StatusBadRequest, "bad_request", "followUps must be inherit, on or off")
			return
		}
		in.FollowUps = on
	}
	in.Attachments = req.Attachments
	t, err := s.opt.Tickets.CreateTask(r.Context(), in, origin(r))
	if err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	s.writeTicket(w, r, http.StatusCreated, t)
}

// UpdateTask implements gen.ServerInterface.
func (s *Server) UpdateTask(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	var req gen.TaskUpdate
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	var in orchestrator.TaskInput
	if req.Title != nil {
		in.Title = *req.Title
	}
	if req.Description != nil {
		in.Description = *req.Description
	}
	if req.Priority != nil {
		in.Priority = string(*req.Priority)
	}
	if req.AfterApprove != nil {
		in.AfterApprove = string(*req.AfterApprove)
	}
	if req.Kind != nil {
		in.Kind = string(*req.Kind)
	}
	in.TicketNumber = req.TicketNumber
	in.Attachments = req.Attachments
	s.ticketAction(w, r, func(ctx context.Context) (domain.Ticket, error) {
		return s.opt.Tickets.UpdateTask(ctx, key, in, origin(r))
	})
}

// DeleteTask implements gen.ServerInterface.
func (s *Server) DeleteTask(w http.ResponseWriter, r *http.Request, key gen.TicketKey) {
	if err := s.opt.Tickets.DeleteTask(r.Context(), key, origin(r)); err != nil {
		s.writeUseCaseError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ---- logs ----

// ListEvents implements gen.ServerInterface.
func (s *Server) ListEvents(w http.ResponseWriter, r *http.Request, p gen.ListEventsParams) {
	if !s.adminReady(w) {
		return
	}
	f := postgres.LogFilter{Type: "all", Limit: 100}
	if p.Type != nil {
		f.Type = string(*p.Type)
	}
	if p.Key != nil {
		f.Key = *p.Key
	}
	if p.Errors != nil {
		f.Errors = *p.Errors
	}
	if p.Before != nil {
		f.Before = *p.Before
	}
	if p.Limit != nil {
		f.Limit = *p.Limit
	}
	evs, err := s.opt.Admin.Logs.ListEvents(r.Context(), f)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.EventPage{Events: make([]gen.Event, len(evs))}
	for i, e := range evs {
		out.Events[i] = toEvent(e)
	}
	if len(evs) == f.Limit {
		next := evs[len(evs)-1].ID
		out.NextBefore = &next
	}
	writeJSON(w, http.StatusOK, out)
}

// GetEventSummary implements gen.ServerInterface.
func (s *Server) GetEventSummary(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	sum, err := s.opt.Admin.Logs.EventSummary(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.EventSummary{RunsStarted: sum.RunsStarted, ReachedReview: sum.ReachedReview, AvgTurns: sum.AvgTurns,
		Stops: sum.Stops, Errors: sum.Errors, Steps: make([]gen.StepDuration, len(sum.Steps))}
	for i, st := range sum.Steps {
		ms := st.Avg.Milliseconds()
		out.Steps[i] = gen.StepDuration{State: gen.TicketState(st.State), AvgMs: &ms, Count: st.Count}
	}
	writeJSON(w, http.StatusOK, out)
}

// ExportEvents implements gen.ServerInterface.
func (s *Server) ExportEvents(w http.ResponseWriter, r *http.Request, p gen.ExportEventsParams) {
	if !s.adminReady(w) {
		return
	}
	format := "json"
	if p.Format != nil {
		format = string(*p.Format)
	}
	name := "agnts-events-" + time.Now().Format("2006-01-02")
	var err error
	if format == "csv" {
		w.Header().Set("Content-Type", "text/csv; charset=utf-8")
		w.Header().Set("Content-Disposition", `attachment; filename="`+name+`.csv"`)
		cw := csv.NewWriter(w)
		_ = cw.Write([]string{"id", "time", "ticket", "step", "type", "level", "origin", "message", "duration_ms", "data"})
		err = s.opt.Admin.Logs.ExportEvents(r.Context(), func(e domain.Event) error {
			data, _ := json.Marshal(e.Data)
			dur := ""
			if e.DurationMS != nil {
				dur = strconv.FormatInt(*e.DurationMS, 10)
			}
			return cw.Write([]string{strconv.FormatInt(e.ID, 10), e.CreatedAt.UTC().Format(time.RFC3339), e.TicketKey, e.Step,
				e.Type, string(e.Level), string(e.Origin), csvSafe(e.Message), dur, string(data)})
		})
		cw.Flush()
	} else {
		w.Header().Set("Content-Type", "application/x-ndjson")
		w.Header().Set("Content-Disposition", `attachment; filename="`+name+`.jsonl"`)
		enc := json.NewEncoder(w)
		err = s.opt.Admin.Logs.ExportEvents(r.Context(), func(e domain.Event) error { return enc.Encode(toEvent(e)) })
	}
	if err != nil {
		s.opt.Log.Error("export events", "err", err)
	}
}

// csvSafe stops spreadsheet formula injection from event text.
func csvSafe(s string) string {
	if s != "" && (s[0] == '=' || s[0] == '+' || s[0] == '-' || s[0] == '@') {
		return "'" + s
	}
	return s
}

// ---- dashboard and usage ----

// GetDashboard implements gen.ServerInterface.
func (s *Server) GetDashboard(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	d, err := s.opt.Admin.Dashboard.Build(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.Dashboard{
		Counts: gen.DashboardCounts{Needs: d.Counts["needs"], Answers: d.Counts["answers"], Reviews: d.Counts["reviews"],
			Stopped: d.Counts["stopped"], Running: d.Counts["running"], Queued: d.Counts["queued"]},
		Waiting: make([]gen.Ticket, len(d.Waiting)), Live: make([]gen.LiveRun, len(d.Live)),
		Pipeline: d.Pipeline, TodayByHour: make([]gen.HourBucket, len(d.TodayByHour)),
		Week: toWeek(d.Week), LastWeek: toWeek(d.LastWeek), Repos: make([]gen.RepoActivity, len(d.Repos)),
		Recent: make([]gen.Event, len(d.Recent)), Usage: toUsage(d.Usage), Parallel: d.Parallel,
	}
	if m, ok := memberFrom(r.Context()); ok && m.w.Slots > 0 {
		out.Parallel = m.w.Slots
	}
	for i, row := range d.Waiting {
		out.Waiting[i] = toTicketRow(row)
	}
	for i, l := range d.Live {
		out.Live[i] = gen.LiveRun{Ticket: toTicketRow(l.Row), Model: l.Model, Turns: l.Turns, MaxTurns: l.MaxTurns, LastMessage: l.LastMessage}
	}
	for i, b := range d.TodayByHour {
		out.TodayByHour[i] = gen.HourBucket{Hour: b.Hour, Agnts: b.Agnts, You: b.You, Problems: b.Problems}
	}
	for i, a := range d.Repos {
		out.Repos[i] = gen.RepoActivity{Repo: toRepo(a.Repo), Open: a.Repo.Open}
		if a.Latest != nil {
			t := toTicketRow(*a.Latest)
			out.Repos[i].Latest = &t
		}
	}
	for i, e := range d.Recent {
		out.Recent[i] = toEvent(e)
	}
	writeJSON(w, http.StatusOK, out)
}

func toWeek(w postgres.WeekStats) gen.WeekStats {
	return gen.WeekStats{Picked: w.Picked, Pushed: w.Pushed, FirstTryPct: w.FirstTryPct, AvgTurns: w.AvgTurns, AvgWaitMin: w.AvgWaitMin, Stopped: w.Stopped}
}

func toUsage(v usage.View) gen.Usage {
	return gen.Usage{
		FiveHour: gen.UsageWindow{Utilization: v.FiveHour, ResetsAt: v.FiveHourResets},
		SevenDay: gen.UsageWindow{Utilization: v.SevenDay, ResetsAt: v.SevenDayResets},
		Status:   gen.UsageStatus(v.Status), UpdatedAt: v.UpdatedAt, Paused: v.Paused, PausedUntil: v.PausedUntil,
		PauseAbove: v.PauseAbove, Refreshing: v.Refreshing,
	}
}

// GetUsage implements gen.ServerInterface.
func (s *Server) GetUsage(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	st, err := s.opt.Admin.Settings.Get(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	v, err := s.opt.Admin.Usage.Current(r.Context(), st)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, toUsage(v))
}

// RefreshUsage implements gen.ServerInterface.
func (s *Server) RefreshUsage(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	if s.opt.Admin.Refresher == nil {
		writeError(w, http.StatusConflict, "conflict", "the agent loop is off, so usage cannot be refreshed")
		return
	}
	if err := s.opt.Admin.Refresher.Refresh(r.Context()); errors.Is(err, usage.ErrBusy) {
		writeError(w, http.StatusConflict, "conflict", err.Error())
		return
	} else if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	st, _ := s.opt.Admin.Settings.Get(r.Context())
	v, err := s.opt.Admin.Usage.Current(r.Context(), st)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusAccepted, toUsage(v))
}

// ---- settings ----

func toSettings(v domain.Settings) gen.Settings {
	learn, autoLearn, lessons := v.Models.Learn, v.AutoLearn, v.Notify.Lessons
	review, autoReview, reviewNote := v.Models.Review, v.AutoReview, v.Notify.Review
	followUps, followUpsNote := v.SuggestFollowUps, v.Notify.FollowUps
	preview, autoPreview, visualCheck := v.Models.Preview, v.AutoPreview, v.VisualCheck
	previewNote, previewPhotos, egress := v.Notify.Preview, v.Notify.PreviewPhotos, append([]string{}, v.EgressAllow...)
	autoBrief, selfReview, reflect, publicDocs := v.AutoBrief, v.SelfReview, v.Reflect, v.PublicDocuments
	ciNote := v.Notify.CI
	ci := gen.CISettings{AutoFix: v.CI.AutoFix, MaxAutoPerDay: v.CI.MaxAutoPerDay, RetryFlaky: v.CI.RetryFlaky,
		FeedbackRounds: v.CI.FeedbackRounds, InfraPatterns: append([]string{}, v.CI.InfraPatterns...)}
	pulls := gen.PullReviewSettings{Enabled: v.PullReviews.Enabled, ReviewRequested: v.PullReviews.ReviewRequested, All: &v.PullReviews.All,
		SkipDrafts: v.PullReviews.SkipDrafts, Rereview: v.PullReviews.Rereview, MergeMethod: gen.PullReviewSettingsMergeMethod(v.PullReviews.MergeMethod)}
	guard := gen.GuardSettings{Profile: gen.GuardProfile(v.Guard.Profile), FactCheck: v.Guard.FactCheck, Disabled: []gen.GuardHook{}}
	if guard.Profile == "" {
		guard.Profile = gen.GuardProfile(domain.GuardStandard)
	}
	for _, h := range v.Guard.Disabled {
		guard.Disabled = append(guard.Disabled, gen.GuardHook(h))
	}
	stalls, deep, prove, learnRuns, second, methods := v.Stalls, v.DeepReview, v.ProveFixes, v.LearnFromRuns, v.SecondOpinion, v.MethodSkills
	maxRepos := v.TicketRepoLimit()
	recheck, baseline := v.RecheckComplex, v.BaselineChecks
	effort := gen.EffortSettings{Analyze: gen.EffortSettingsAnalyze(v.Effort.Analyze), Coding: gen.EffortSettingsCoding(v.Effort.Coding),
		Review: gen.EffortSettingsReview(v.Effort.Review), Complex: gen.EffortSettingsComplex(v.Effort.Complex)}
	return gen.Settings{
		Effort: &effort, RecheckComplex: &recheck, BaselineChecks: &baseline,
		MaxTicketRepos: &maxRepos,
		Guard:          &guard, Stalls: &stalls, DeepReview: &deep, ProveFixes: &prove, LearnFromRuns: &learnRuns, SecondOpinion: &second, MethodSkills: &methods,
		PullReviews: &pulls,
		PrComments: &gen.PRCommentSettings{Attribution: v.PRComments.Attribution, LearnFromComments: v.PRComments.LearnFromComments,
			ResolveFixed: v.PRComments.ResolveFixed, AutoAddress: v.PRComments.AutoAddress},
		Ci: &ci,
		Models: gen.StageModels{Analyze: v.Models.Analyze, Coding: v.Models.Coding,
			Retry: v.Models.Retry, Helper: v.Models.Helper, Learn: &learn, Review: &review, Preview: &preview},
		AutoPreview: &autoPreview, VisualCheck: &visualCheck, EgressAllow: &egress, AutoBrief: &autoBrief, SelfReview: &selfReview, Reflect: &reflect, PublicDocuments: &publicDocs,
		MaxTurns: v.MaxTurns, TimeoutMin: v.TimeoutMin, Allow: v.Allow, Deny: v.Deny,
		AskFirst: v.AskFirst, AutoResume: v.AutoResume, PauseAbove: v.PauseAbove, Parallel: v.Parallel, AutoLearn: &autoLearn,
		AutoReview: &autoReview, SuggestFollowUps: &followUps,
		Git: gen.GitSettings{AuthorName: v.Git.AuthorName, AuthorEmail: v.Git.AuthorEmail, CoAuthor: v.Git.CoAuthor,
			PrTitle: v.Git.PRTitle, Draft: v.Git.Draft},
		Notify: &gen.NotifySettings{Push: v.Notify.Push, Telegram: v.Notify.Telegram, NeedsYou: v.Notify.NeedsYou,
			Stopped: v.Notify.Stopped, Done: v.Notify.Done, Lessons: &lessons, Review: &reviewNote, FollowUps: &followUpsNote,
			Preview: &previewNote, PreviewPhotos: &previewPhotos, Ci: &ciNote},
	}
}

// GetSettings implements gen.ServerInterface.
func (s *Server) GetSettings(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	v, err := s.opt.Admin.Settings.Get(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, s.settingsView(r.Context(), v))
}

// settingsView shows settings with the workspace's slots as its parallel
// runs: slots come with the plan (Billing), not from Settings.
func (s *Server) settingsView(ctx context.Context, v domain.Settings) gen.Settings {
	out := toSettings(v)
	if m, ok := memberFrom(ctx); ok && m.w.Slots > 0 {
		out.Parallel = m.w.Slots
	}
	return out
}

// PutSettings implements gen.ServerInterface.
func (s *Server) PutSettings(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	var req gen.Settings
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	cur, err := s.opt.Admin.Settings.Get(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	v := domain.Settings{
		Models: domain.StageModels{Analyze: req.Models.Analyze, Coding: req.Models.Coding,
			Retry: req.Models.Retry, Helper: req.Models.Helper, Learn: cur.Models.Learn, Review: cur.Models.Review,
			Preview: cur.Models.Preview},
		AutoPreview: cur.AutoPreview, VisualCheck: cur.VisualCheck, EgressAllow: cur.EgressAllow,
		AutoBrief: cur.AutoBrief, SelfReview: cur.SelfReview, Reflect: cur.Reflect, PublicDocuments: cur.PublicDocuments,
		MaxTurns: req.MaxTurns, TimeoutMin: req.TimeoutMin, Allow: req.Allow, Deny: req.Deny,
		AskFirst: req.AskFirst, AutoResume: req.AutoResume, PauseAbove: req.PauseAbove, Parallel: cur.Parallel, AutoLearn: cur.AutoLearn,
		AutoReview: cur.AutoReview, SuggestFollowUps: cur.SuggestFollowUps, PullReviews: cur.PullReviews, PRComments: cur.PRComments, CI: cur.CI,
		Guard: cur.Guard, Stalls: cur.Stalls, DeepReview: cur.DeepReview, ProveFixes: cur.ProveFixes, LearnFromRuns: cur.LearnFromRuns, MethodSkills: cur.MethodSkills,
		SecondOpinion: cur.SecondOpinion, MaxTicketRepos: cur.MaxTicketRepos, Effort: cur.Effort, RecheckComplex: cur.RecheckComplex, BaselineChecks: cur.BaselineChecks,
		Git: domain.GitSettings{AuthorName: req.Git.AuthorName, AuthorEmail: req.Git.AuthorEmail, CoAuthor: req.Git.CoAuthor,
			PRTitle: req.Git.PrTitle, Draft: req.Git.Draft},
		Notify: cur.Notify,
	}
	if req.Notify != nil {
		v.Notify = domain.NotifySettings{Push: req.Notify.Push, Telegram: req.Notify.Telegram, NeedsYou: req.Notify.NeedsYou,
			Stopped: req.Notify.Stopped, Done: req.Notify.Done, Progress: cur.Notify.Progress, Lessons: cur.Notify.Lessons, Review: cur.Notify.Review,
			FollowUps: cur.Notify.FollowUps, Preview: cur.Notify.Preview, PreviewPhotos: cur.Notify.PreviewPhotos, CI: cur.Notify.CI}
		if req.Notify.Ci != nil {
			v.Notify.CI = *req.Notify.Ci
		}
		if req.Notify.Preview != nil {
			v.Notify.Preview = *req.Notify.Preview
		}
		if req.Notify.PreviewPhotos != nil {
			v.Notify.PreviewPhotos = *req.Notify.PreviewPhotos
		}
		if req.Notify.Lessons != nil {
			v.Notify.Lessons = *req.Notify.Lessons
		}
		if req.Notify.Review != nil {
			v.Notify.Review = *req.Notify.Review
		}
		if req.Notify.FollowUps != nil {
			v.Notify.FollowUps = *req.Notify.FollowUps
		}
		if req.Notify.Progress != nil {
			v.Notify.Progress = *req.Notify.Progress
		}
	}
	if req.Models.Learn != nil {
		v.Models.Learn = *req.Models.Learn
	}
	if req.AutoLearn != nil {
		v.AutoLearn = *req.AutoLearn
	}
	if req.Models.Review != nil {
		v.Models.Review = *req.Models.Review
	}
	if req.AutoReview != nil {
		v.AutoReview = *req.AutoReview
	}
	if req.SuggestFollowUps != nil {
		v.SuggestFollowUps = *req.SuggestFollowUps
	}
	if req.MaxTicketRepos != nil {
		v.MaxTicketRepos = *req.MaxTicketRepos
	}
	if req.Models.Preview != nil {
		v.Models.Preview = *req.Models.Preview
	}
	if req.AutoPreview != nil {
		v.AutoPreview = *req.AutoPreview
	}
	if req.VisualCheck != nil {
		v.VisualCheck = *req.VisualCheck
	}
	if req.AutoBrief != nil {
		v.AutoBrief = *req.AutoBrief
	}
	if req.PublicDocuments != nil {
		v.PublicDocuments = *req.PublicDocuments
	}
	if req.SelfReview != nil {
		v.SelfReview = *req.SelfReview
	}
	if req.Reflect != nil {
		v.Reflect = *req.Reflect
	}
	if req.EgressAllow != nil {
		v.EgressAllow = *req.EgressAllow
	}
	if p := req.PullReviews; p != nil {
		all := v.PullReviews.All // a client that does not know it leaves it alone
		if p.All != nil {
			all = *p.All
		}
		v.PullReviews = domain.PullReviewSettings{Enabled: p.Enabled, ReviewRequested: p.ReviewRequested, All: all, SkipDrafts: p.SkipDrafts,
			Rereview: p.Rereview, MergeMethod: string(p.MergeMethod)}
	}
	if p := req.PrComments; p != nil {
		v.PRComments = domain.PRCommentSettings{Attribution: p.Attribution, LearnFromComments: p.LearnFromComments,
			ResolveFixed: p.ResolveFixed, AutoAddress: p.AutoAddress}
	}
	if g := req.Guard; g != nil {
		v.Guard = domain.GuardSettings{Profile: string(g.Profile), FactCheck: g.FactCheck, Disabled: []string{}}
		for _, h := range g.Disabled {
			v.Guard.Disabled = append(v.Guard.Disabled, string(h))
		}
	}
	if req.Stalls != nil {
		v.Stalls = *req.Stalls
	}
	if req.DeepReview != nil {
		v.DeepReview = *req.DeepReview
	}
	if req.ProveFixes != nil {
		v.ProveFixes = *req.ProveFixes
	}
	if req.LearnFromRuns != nil {
		v.LearnFromRuns = *req.LearnFromRuns
	}
	if req.MethodSkills != nil {
		v.MethodSkills = *req.MethodSkills
	}
	if req.SecondOpinion != nil {
		v.SecondOpinion = *req.SecondOpinion
	}
	if e := req.Effort; e != nil {
		v.Effort = domain.EffortSettings{Analyze: string(e.Analyze), Coding: string(e.Coding), Review: string(e.Review), Complex: string(e.Complex)}
	}
	if req.RecheckComplex != nil {
		v.RecheckComplex = *req.RecheckComplex
	}
	if req.BaselineChecks != nil {
		v.BaselineChecks = *req.BaselineChecks
	}
	if c := req.Ci; c != nil {
		v.CI = domain.CISettings{AutoFix: c.AutoFix, MaxAutoPerDay: c.MaxAutoPerDay, RetryFlaky: c.RetryFlaky,
			FeedbackRounds: c.FeedbackRounds, InfraPatterns: c.InfraPatterns}
	}
	saved, err := s.opt.Admin.Settings.Put(r.Context(), v, origin(r))
	if err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	s.opt.Tickets.Wake()
	writeJSON(w, http.StatusOK, s.settingsView(r.Context(), saved))
}

// ---- repositories ----

func toRepo(x admin.RepoView) gen.Repository {
	st := x.ClaudeMDState
	if st == "" {
		st = "unknown"
	}
	return gen.Repository{Id: x.ID, Name: x.Name, Kind: gen.RepositoryKind(x.Kind), Provider: gen.RepositoryProvider(x.Provider),
		CloneUrl: x.CloneURL, DefaultBranch: x.DefaultBranch, BuildCmd: x.BuildCmd, LintCmd: x.LintCmd, TestCmd: x.TestCmd,
		BranchPrefix: x.BranchPrefix, BranchTemplate: &x.BranchTemplate, CommitTemplate: &x.CommitTemplate, TaskPrefix: orchestrator.TaskPrefix(x.Repository), Instructions: x.ClaudeMD,
		JiraProject: x.JiraProject, PlaneProject: &x.PlaneProject, ClaudeMd: gen.RepositoryClaudeMd(st), OpenTickets: x.Open, DeployWorkflow: &x.DeployWorkflow,
		ArchivedAt: x.ArchivedAt, Preview: toRepoPreview(x.Preview),
		Stack: &x.Stack, Toolchains: ptr(toToolchains(x.Toolchains)), ToolchainsOverride: &x.ToolchainsOverride,
		ToolchainsDetectedAt: x.ToolchainsDetectedAt, ToolchainNotes: ptr(nonNil(x.ToolchainNotes)),
		RunnerImage: &x.RunnerImage, MemoryMb: &x.MemoryMB, BuildEnvSet: &x.BuildEnvSet, BuildEnvNames: ptr(nonNil(x.BuildEnvNames)),
		Harness: toRepoHarness(x.Repository), Groups: ptr(toGroupRefs(x.Groups))}
}

func ptr[T any](v T) *T { return &v }

func nonNil(v []string) []string {
	if v == nil {
		return []string{}
	}
	return v
}

func toToolchains(ts []domain.Toolchain) []gen.Toolchain {
	out := make([]gen.Toolchain, len(ts))
	for i, t := range ts {
		out[i] = gen.Toolchain{Tool: t.Tool, Version: t.Version}
		if t.Source != "" {
			out[i].Source = ptr(t.Source)
		}
		if t.Dir != "" {
			out[i].Dir = ptr(t.Dir)
		}
	}
	return out
}

func fromToolchains(ts []gen.Toolchain) []domain.Toolchain {
	out := make([]domain.Toolchain, len(ts))
	for i, t := range ts {
		out[i] = domain.Toolchain{Tool: t.Tool, Version: t.Version}
		if t.Source != nil {
			out[i].Source = *t.Source
		}
		if t.Dir != nil {
			out[i].Dir = *t.Dir
		}
	}
	return out
}

// DetectRepo implements gen.ServerInterface.
func (s *Server) DetectRepo(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	var in gen.RepoDetectInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	x := domain.Repository{}
	if in.Id != nil {
		x.ID = *in.Id
	}
	if in.CloneUrl != nil {
		x.CloneURL = *in.CloneUrl
	}
	if in.DefaultBranch != nil {
		x.DefaultBranch = *in.DefaultBranch
	}
	if x.ID == 0 && x.CloneURL == "" {
		writeError(w, http.StatusBadRequest, "bad_request", "give a repository id or a clone URL")
		return
	}
	det, byClaude, err := s.opt.Admin.Repos.Detect(r.Context(), x, in.Deep != nil && *in.Deep)
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	src := gen.RepoDetectionSourceFiles
	if byClaude {
		src = gen.RepoDetectionSourceClaude
	}
	writeJSON(w, http.StatusOK, gen.RepoDetection{Toolchains: toToolchains(det.Toolchains), BuildCmd: det.Build, LintCmd: det.Lint,
		TestCmd: det.Test, Notes: nonNil(det.Notes), Stack: det.Stack(), Source: src})
}

func toRepoPreview(p domain.PreviewConfig) *gen.RepoPreview {
	nn := func(v []string) []string {
		if v == nil {
			return []string{}
		}
		return v
	}
	rp := p.ReadyPath
	if rp == "" {
		rp = "/"
	}
	return &gen.RepoPreview{Command: p.Command, Port: p.Port, ReadyPath: rp, Routes: nn(p.Routes), UiPaths: nn(p.UIPaths),
		Login: p.Login, EnvSet: p.EnvSet, EnvNames: nn(p.EnvNames)}
}

// ArchiveRepo implements gen.ServerInterface.
func (s *Server) ArchiveRepo(w http.ResponseWriter, r *http.Request, id int64) {
	s.setArchived(w, r, id, true)
}

// UnarchiveRepo implements gen.ServerInterface.
func (s *Server) UnarchiveRepo(w http.ResponseWriter, r *http.Request, id int64) {
	s.setArchived(w, r, id, false)
}

func (s *Server) setArchived(w http.ResponseWriter, r *http.Request, id int64, archived bool) {
	if !s.adminReady(w) {
		return
	}
	x, err := s.opt.Admin.Repos.SetArchived(r.Context(), id, archived, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toRepo(x))
}

// ListRepos implements gen.ServerInterface.
func (s *Server) ListRepos(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	list, err := s.opt.Admin.Repos.List(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.Repository, len(list))
	for i, x := range list {
		out[i] = toRepo(x)
	}
	writeJSON(w, http.StatusOK, out)
}

// GetRepo implements gen.ServerInterface.
func (s *Server) GetRepo(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.adminReady(w) {
		return
	}
	x, err := s.opt.Admin.Repos.Get(r.Context(), id)
	if err != nil {
		s.writeAdminError(w, r, err, "no such repository")
		return
	}
	writeJSON(w, http.StatusOK, toRepo(x))
}

func repoFromInput(in gen.RepositoryInput) domain.Repository {
	x := domain.Repository{Name: in.Name, CloneURL: in.CloneUrl} // kind is derived in admin.Validate
	str := func(p *string) string {
		if p == nil {
			return ""
		}
		return *p
	}
	x.DefaultBranch, x.BuildCmd, x.LintCmd, x.TestCmd = str(in.DefaultBranch), str(in.BuildCmd), str(in.LintCmd), str(in.TestCmd)
	x.BranchPrefix, x.TaskPrefix, x.ClaudeMD, x.JiraProject = str(in.BranchPrefix), str(in.TaskPrefix), str(in.Instructions), str(in.JiraProject)
	x.DeployWorkflow = str(in.DeployWorkflow)
	x.BranchTemplate, x.CommitTemplate = str(in.BranchTemplate), str(in.CommitTemplate)
	x.PlaneProject = str(in.PlaneProject)
	if in.Toolchains != nil {
		x.Toolchains = fromToolchains(*in.Toolchains)
	}
	if in.ToolchainsOverride != nil {
		x.ToolchainsOverride = *in.ToolchainsOverride
	}
	x.RunnerImage = str(in.RunnerImage)
	if in.MemoryMb != nil {
		x.MemoryMB = *in.MemoryMb
	}
	if p := in.Preview; p != nil {
		x.Preview = domain.PreviewConfig{Command: str(p.Command), ReadyPath: str(p.ReadyPath), Login: str(p.Login)}
		if p.Port != nil {
			x.Preview.Port = *p.Port
		}
		if p.Routes != nil {
			x.Preview.Routes = *p.Routes
		}
		if p.UiPaths != nil {
			x.Preview.UIPaths = *p.UiPaths
		}
	}
	return x
}

// previewEnv is the environment a repository input replaces, or nil.
func previewEnv(in gen.RepositoryInput) *string {
	if in.Preview == nil {
		return nil
	}
	return in.Preview.Env
}

// CreateRepo implements gen.ServerInterface.
func (s *Server) CreateRepo(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	var in gen.RepositoryInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	x, err := s.opt.Admin.Repos.SaveRun(r.Context(), repoFromInput(in), admin.SaveOptions{PreviewEnv: previewEnv(in), BuildEnv: in.BuildEnv})
	if err != nil {
		s.writeAdminError(w, r, err, "a repository with that name, Jira project or Plane project already exists")
		return
	}
	writeJSON(w, http.StatusCreated, toRepo(x))
}

// UpdateRepo implements gen.ServerInterface.
func (s *Server) UpdateRepo(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.adminReady(w) {
		return
	}
	var in gen.RepositoryInput
	if err := decodeJSON(r, &in); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	x := repoFromInput(in)
	x.ID = id
	// A client that sends no toolchains (an older one) keeps the stored
	// run settings.
	saved, err := s.opt.Admin.Repos.SaveRun(r.Context(), x, admin.SaveOptions{
		KeepPreview: in.Preview == nil, PreviewEnv: previewEnv(in), KeepRun: in.Toolchains == nil, BuildEnv: in.BuildEnv,
		KeepPlane: in.PlaneProject == nil,
	})
	if err != nil {
		s.writeAdminError(w, r, err, "a repository with that name, Jira project or Plane project already exists")
		return
	}
	writeJSON(w, http.StatusOK, toRepo(saved))
}

func (s *Server) writeAdminError(w http.ResponseWriter, r *http.Request, err error, conflictMsg string) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", "not found")
	case errors.Is(err, domain.ErrConflict):
		writeError(w, http.StatusConflict, "conflict", conflictMsg)
	case errors.Is(err, admin.ErrInvalid):
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
	default:
		s.writeInternal(w, r, err)
	}
}

// ---- integrations ----

func toIntegration(v admin.View) gen.Integration {
	out := gen.Integration{Provider: v.Provider, Connected: v.Connected, Settings: v.Settings}
	if v.CheckedAt != nil {
		if t, err := time.Parse(time.RFC3339, *v.CheckedAt); err == nil {
			out.CheckedAt = &t
		}
	}
	if v.Account != "" {
		out.Account = &v.Account
	}
	if v.TokenHint != "" {
		out.TokenHint = &v.TokenHint
	}
	if v.LastError != "" {
		out.LastError = &v.LastError
	}
	if v.WebhookURL != "" {
		out.WebhookUrl = &v.WebhookURL
	}
	if v.Provider == "plane" {
		out.WebhookSecretSet = &v.WebhookSecretSet
	}
	if v.WebhookSecret != "" {
		out.WebhookSecret = &v.WebhookSecret
	}
	return out
}

// ListIntegrations implements gen.ServerInterface.
func (s *Server) ListIntegrations(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	list, err := s.opt.Admin.Integrations.List(r.Context())
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := make([]gen.Integration, len(list))
	for i, v := range list {
		out[i] = toIntegration(v)
	}
	writeJSON(w, http.StatusOK, out)
}

// ConnectIntegration implements gen.ServerInterface.
func (s *Server) ConnectIntegration(w http.ResponseWriter, r *http.Request, provider gen.Provider) {
	if !s.adminReady(w) {
		return
	}
	var req gen.ConnectIntegrationJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	settings := map[string]string{}
	if req.Settings != nil {
		settings = *req.Settings
	}
	hook := ""
	if req.WebhookSecret != nil {
		hook = *req.WebhookSecret
	}
	v, secret, err := s.opt.Admin.Integrations.Connect(r.Context(), string(provider), req.Token, settings, hook, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	out := gen.ConnectResult{Integration: toIntegration(v)}
	if secret != "" {
		out.WebhookSecret = &secret
	}
	writeJSON(w, http.StatusOK, out)
}

// TestIntegration implements gen.ServerInterface.
func (s *Server) TestIntegration(w http.ResponseWriter, r *http.Request, provider gen.Provider) {
	if !s.adminReady(w) {
		return
	}
	v, err := s.opt.Admin.Integrations.Test(r.Context(), string(provider))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toIntegration(v))
}

// ListRemoteRepos implements gen.ServerInterface.
func (s *Server) ListRemoteRepos(w http.ResponseWriter, r *http.Request, provider gen.Provider) {
	if !s.adminReady(w) {
		return
	}
	list, err := s.opt.Admin.Repos.Remote(r.Context(), string(provider))
	if err != nil {
		if errors.Is(err, admin.ErrInvalid) {
			s.writeAdminError(w, r, err, "")
			return
		}
		s.opt.Log.Warn("list remote repositories", "provider", provider, "err", err)
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
		return
	}
	out := make([]gen.RemoteRepository, len(list))
	for i, x := range list {
		out[i] = gen.RemoteRepository{FullName: x.FullName, CloneUrl: x.CloneURL, DefaultBranch: x.DefaultBranch, Private: x.Private, Added: x.Added}
		if x.Description != "" {
			out[i].Description = &x.Description
		}
		if !x.UpdatedAt.IsZero() {
			out[i].UpdatedAt = &x.UpdatedAt
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// DisconnectIntegration implements gen.ServerInterface.
func (s *Server) DisconnectIntegration(w http.ResponseWriter, r *http.Request, provider gen.Provider) {
	if !s.adminReady(w) {
		return
	}
	v, err := s.opt.Admin.Integrations.Disconnect(r.Context(), string(provider), origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toIntegration(v))
}

// UpdateIntegration implements gen.ServerInterface.
func (s *Server) UpdateIntegration(w http.ResponseWriter, r *http.Request, provider gen.Provider) {
	if !s.adminReady(w) {
		return
	}
	var req gen.UpdateIntegrationJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Admin.Integrations.Update(r.Context(), string(provider), req.Settings, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toIntegration(v))
}

// SyncJira implements gen.ServerInterface.
func (s *Server) SyncJira(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	res, err := s.opt.Admin.Integrations.SyncJira(r.Context())
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, map[string]int{"found": res.Found, "created": res.Created, "updated": res.Updated, "waiting": res.Waiting})
}

// SyncPlane implements gen.ServerInterface.
func (s *Server) SyncPlane(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	found, created, err := s.opt.Admin.Integrations.SyncPlane(r.Context())
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, map[string]int{"found": found, "created": created})
}

// SetPlaneWebhookSecret implements gen.ServerInterface.
func (s *Server) SetPlaneWebhookSecret(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	var req gen.SetPlaneWebhookSecretJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	v, err := s.opt.Admin.Integrations.SetPlaneWebhookSecret(r.Context(), req.Secret, origin(r))
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	writeJSON(w, http.StatusOK, toIntegration(v))
}

// ListPlaneStates implements gen.ServerInterface.
func (s *Server) ListPlaneStates(w http.ResponseWriter, r *http.Request) {
	if !s.adminReady(w) {
		return
	}
	sts, err := s.opt.Admin.Integrations.PlaneStates(r.Context())
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	out := make([]gen.PlaneState, len(sts))
	for i, x := range sts {
		out[i] = gen.PlaneState{Name: x.Name, Group: gen.PlaneStateGroup(x.Group), Projects: x.Projects}
	}
	writeJSON(w, http.StatusOK, out)
}

// ---- docs ----

// GetPageDoc implements gen.ServerInterface.
func (s *Server) GetPageDoc(w http.ResponseWriter, r *http.Request, page string, p gen.GetPageDocParams) {
	if !s.adminReady(w) {
		return
	}
	lang := "en"
	if p.Lang != nil {
		lang = string(*p.Lang)
	}
	b, err := s.opt.Admin.Docs.Get(page, lang)
	if err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	w.Header().Set("Content-Type", "text/markdown; charset=utf-8")
	w.Header().Set("Cache-Control", "no-cache")
	_, _ = w.Write(b)
}
