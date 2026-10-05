package httpapi

import (
	"errors"
	"net/http"
	"strings"

	"hiro/internal/admin"
	"hiro/internal/domain"
	"hiro/internal/httpapi/gen"
	"hiro/internal/store/postgres"
	"hiro/internal/vcs"
)

func toPeriod(p postgres.Period) gen.PeriodStats {
	return gen.PeriodStats{Picked: p.Picked, Pushed: p.Pushed, Rejected: p.Rejected, Stopped: p.Stopped, FirstTry: p.FirstTry,
		AfterChanges: p.AfterChanges, HiroMin: float32(p.HiroMin), WaitMin: float32(p.WaitMin), ReviewMin: float32(p.ReviewMin),
		AnswerMin: float32(p.AnswerMin), Turns: float32(p.Turns)}
}

// GetAnalytics implements gen.ServerInterface.
func (s *Server) GetAnalytics(w http.ResponseWriter, r *http.Request, p gen.GetAnalyticsParams) {
	if !s.adminReady(w) {
		return
	}
	days := 30
	if p.Days != nil {
		days = int(*p.Days)
	}
	a, err := s.opt.Admin.Dashboard.Analytics(r.Context(), days)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.Analytics{Days: days, Current: toPeriod(a.Current), Previous: toPeriod(a.Prev), Steps: map[string]float32{}, Stops: a.Stops,
		PerDay: make([]gen.DayStat, len(a.Days)), Hours: a.Hours[:]}
	for k, v := range a.Steps {
		out.Steps[k] = float32(v)
	}
	if out.Stops == nil {
		out.Stops = map[string]int{}
	}
	for i, d := range a.Days {
		ds := gen.DayStat{Picked: d.Picked, Pushed: d.Pushed, Rejected: d.Rejected, Stopped: d.Stopped,
			HiroMin: float32(d.HiroMin), WaitMin: float32(d.WaitMin), Turns: float32(d.Turns)}
		ds.Date.Time = d.Date
		if d.PeakUsage != nil {
			v := float32(*d.PeakUsage)
			ds.PeakUsage = &v
		}
		out.PerDay[i] = ds
	}
	out.Models = []struct {
		AvgTurns      float32 `json:"avgTurns"`
		Model         string  `json:"model"`
		ReachedReview int     `json:"reachedReview"`
		Runs          int     `json:"runs"`
	}{}
	for _, m := range a.Models {
		out.Models = append(out.Models, struct {
			AvgTurns      float32 `json:"avgTurns"`
			Model         string  `json:"model"`
			ReachedReview int     `json:"reachedReview"`
			Runs          int     `json:"runs"`
		}{AvgTurns: float32(m.AvgTurns), Model: m.Model, ReachedReview: m.ReachedReview, Runs: m.Runs})
	}
	out.Repos = make([]struct {
		AvgTurns float32 `json:"avgTurns"`
		ClaudeMd string  `json:"claudeMd"`
		Done     int     `json:"done"`
		Finished int     `json:"finished"`
		HiroMin  float32 `json:"hiroMin"`
		Kind     string  `json:"kind"`
		Name     string  `json:"name"`
		RepoId   int64   `json:"repoId"`
		Tickets  int     `json:"tickets"`
	}, len(a.Repos))
	for i, x := range a.Repos {
		out.Repos[i].AvgTurns, out.Repos[i].ClaudeMd, out.Repos[i].Done, out.Repos[i].Finished = float32(x.AvgTurns), x.ClaudeMD, x.Done, x.Finished
		out.Repos[i].HiroMin, out.Repos[i].Kind, out.Repos[i].Name, out.Repos[i].RepoId, out.Repos[i].Tickets = float32(x.HiroMin), x.Kind, x.Name, x.RepoID, x.Tickets
	}
	out.Insights = make([]struct {
		Kind   gen.AnalyticsInsightsKind `json:"kind"`
		Values map[string]string         `json:"values"`
	}, len(a.Insights))
	for i, in := range a.Insights {
		out.Insights[i].Kind, out.Insights[i].Values = gen.AnalyticsInsightsKind(in.Kind), in.Values
	}
	writeJSON(w, http.StatusOK, out)
}

// pageParam reads an optional page number (from 1, at most 1000).
func pageParam(w http.ResponseWriter, p *int) (int, bool) {
	if p == nil {
		return 1, true
	}
	if *p < 1 || *p > 1000 {
		writeError(w, http.StatusBadRequest, "bad_request", "page must be between 1 and 1000")
		return 0, false
	}
	return *p, true
}

// browse loads one part of the repository page; page (from 1) applies to commits.
func (s *Server) browse(w http.ResponseWriter, r *http.Request, id int64, part string, page int) (admin.RepoActivityView, bool) {
	if !s.adminReady(w) {
		return admin.RepoActivityView{}, false
	}
	v, err := s.opt.Admin.Repos.Browse(r.Context(), id, part, page)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			s.writeAdminError(w, r, err, "")
			return v, false
		}
		s.opt.Log.Warn("browse repository", "repo", id, "part", part, "err", err)
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
		return v, false
	}
	return v, true
}

// ticketForBranch links hiro's branches (prefix + KEY) to tickets.
func ticketForBranch(v admin.RepoActivityView, branch string) *string {
	prefix := v.Repo.BranchPrefix
	if prefix == "" {
		prefix = "hiro/"
	}
	if k, ok := strings.CutPrefix(branch, prefix); ok && k != "" {
		return &k
	}
	return nil
}

// ListRepoBranches implements gen.ServerInterface.
func (s *Server) ListRepoBranches(w http.ResponseWriter, r *http.Request, id int64) {
	v, ok := s.browse(w, r, id, "branches", 1)
	if !ok {
		return
	}
	out := make([]gen.Branch, len(v.Branches))
	for i, b := range v.Branches {
		out[i] = gen.Branch{Name: b.Name, Default: b.Default, Sha: b.SHA, Message: b.Message, Author: b.Author, Ahead: b.Ahead,
			Behind: b.Behind, Ci: gen.CI(b.CI), TicketKey: ticketForBranch(v, b.Name)}
		if !b.Date.IsZero() {
			d := b.Date
			out[i].Date = &d
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListRepoCommits implements gen.ServerInterface.
func (s *Server) ListRepoCommits(w http.ResponseWriter, r *http.Request, id int64, params gen.ListRepoCommitsParams) {
	page, ok := pageParam(w, params.Page)
	if !ok {
		return
	}
	v, ok := s.browse(w, r, id, "commits", page)
	if !ok {
		return
	}
	out := make([]gen.Commit, len(v.Commits))
	for i, c := range v.Commits {
		out[i] = gen.Commit{Sha: c.SHA, Message: c.Message, Author: c.Author, Add: c.Add, Del: c.Del, Ci: gen.CI(c.CI), Url: &c.URL}
		if !c.Date.IsZero() {
			d := c.Date
			out[i].Date = &d
		}
		if k, _, found := strings.Cut(c.Message, ":"); found && strings.Contains(k, "-") && !strings.Contains(k, " ") {
			out[i].TicketKey = &k
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListRepoLocalBranches implements gen.ServerInterface.
func (s *Server) ListRepoLocalBranches(w http.ResponseWriter, r *http.Request, id int64) {
	v, ok := s.browse(w, r, id, "local", 1)
	if !ok {
		return
	}
	out := make([]gen.LocalBranch, len(v.Local))
	for i, b := range v.Local {
		out[i] = gen.LocalBranch{Name: b.Name, Sha: b.SHA, Message: b.Message, Author: b.Author, Ahead: b.Ahead, Behind: b.Behind,
			Status: gen.LocalBranchStatus(b.Status), Unpushed: b.Unpushed, TicketKey: ticketForBranch(v, b.Name)}
		if !b.Date.IsZero() {
			d := b.Date
			out[i].Date = &d
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListRepoMembers implements gen.ServerInterface.
func (s *Server) ListRepoMembers(w http.ResponseWriter, r *http.Request, id int64) {
	v, ok := s.browse(w, r, id, "members", 1)
	if !ok {
		return
	}
	str := func(v string) *string {
		if v == "" {
			return nil
		}
		return &v
	}
	out := make([]gen.RepoMember, len(v.Members))
	for i, m := range v.Members {
		out[i] = gen.RepoMember{Username: m.Username, Role: m.Role, Name: str(m.Name), AvatarUrl: str(m.AvatarURL), Url: str(m.URL)}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListRepoPipelines implements gen.ServerInterface.
func (s *Server) ListRepoPipelines(w http.ResponseWriter, r *http.Request, id int64, params gen.ListRepoPipelinesParams) {
	page, ok := pageParam(w, params.Page)
	if !ok {
		return
	}
	v, ok := s.browse(w, r, id, "pipelines", page)
	if !ok {
		return
	}
	out := make([]gen.Pipeline, len(v.Pipelines))
	for i, p := range v.Pipelines {
		out[i] = gen.Pipeline{Id: p.ID, Name: p.Name, Branch: p.Branch, Sha: p.SHA, Message: p.Message, Trigger: p.Trigger,
			Status: gen.CI(p.Status), DurationMs: p.Duration.Milliseconds(), Url: p.URL, Stages: make([]gen.Stage, len(p.Stages))}
		if !p.Created.IsZero() {
			c := p.Created
			out[i].Created = &c
		}
		for j, st := range p.Stages {
			out[i].Stages[j] = gen.Stage{Id: st.ID, Name: st.Name, Status: gen.CI(st.Status), DurationMs: st.Duration.Milliseconds(), Manual: st.Manual}
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// ListRepoEnvironments implements gen.ServerInterface.
func (s *Server) ListRepoEnvironments(w http.ResponseWriter, r *http.Request, id int64) {
	v, ok := s.browse(w, r, id, "environments", 1)
	if !ok {
		return
	}
	out := make([]gen.Environment, len(v.Environments))
	for i, e := range v.Environments {
		out[i] = gen.Environment{Name: e.Name, Sha: e.SHA, Url: e.URL, DeployedAt: e.DeployedAt}
	}
	writeJSON(w, http.StatusOK, out)
}

// DeployRepo implements gen.ServerInterface.
func (s *Server) DeployRepo(w http.ResponseWriter, r *http.Request, id int64) {
	if !s.adminReady(w) {
		return
	}
	var req gen.DeployRepoJSONRequestBody
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_request", err.Error())
		return
	}
	d := vcs.Deploy{}
	if req.JobId != nil {
		d.JobID = *req.JobId
	}
	if req.Ref != nil {
		d.Ref = *req.Ref
	}
	if err := s.opt.Admin.Repos.Deploy(r.Context(), id, d, origin(r)); err != nil {
		s.writeAdminError(w, r, err, "")
		return
	}
	w.WriteHeader(http.StatusAccepted)
}
