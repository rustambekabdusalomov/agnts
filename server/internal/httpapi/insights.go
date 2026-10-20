package httpapi

import (
	"errors"
	"net/http"
	"regexp"
	"strings"
	"time"

	"agnts/internal/admin"
	"agnts/internal/domain"
	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
	"agnts/internal/vcs"
)

func toPeriod(p postgres.Period) gen.PeriodStats {
	return gen.PeriodStats{Picked: p.Picked, Pushed: p.Pushed, Rejected: p.Rejected, Stopped: p.Stopped, FirstTry: p.FirstTry,
		AfterChanges: p.AfterChanges, AgntsMin: float32(p.AgntsMin), WaitMin: float32(p.WaitMin), ReviewMin: float32(p.ReviewMin),
		AnswerMin: float32(p.AnswerMin), Turns: float32(p.Turns), Merged: p.Merged, Closed: p.Closed, Spend: toTokenSpend(p.Spend)}
}

func toQualityStat(q postgres.QualityStats) gen.QualityStat {
	out := gen.QualityStat{PromptVersion: q.PromptVersion, Tickets: q.Tickets, ReachedReview: q.ReachedReview, Done: q.Done,
		FirstTry: q.FirstTry, Rejected: q.Rejected, ChangeRounds: float32(q.ChangeRounds), FixAttempts: float32(q.FixAttempts),
		Serious: q.Serious, RedFlags: q.RedFlags, SelfFixes: q.SelfFixes,
		GuardBlocks: ptr(q.GuardBlocks), StopSaves: ptr(q.StopSaves), Stalls: ptr(q.Stalls), ProofDue: ptr(q.ProofDue), Proven: ptr(q.Proven),
		Findings: ptr(q.Findings), Adopted: ptr(q.Adopted), Tokens: ptr(float32(q.Tokens)), FactCheck: ptr(q.FactCheck), FactCheckFirst: ptr(q.FactCheckFirst)}
	if q.FootprintHit >= 0 {
		v := float32(q.FootprintHit)
		out.FootprintHit = &v
	}
	return out
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
		PerDay: make([]gen.DayStat, len(a.Days)), Hours: a.Hours[:], SpendByStage: toStageSpend(a.Spend)}
	for k, v := range a.Steps {
		out.Steps[k] = float32(v)
	}
	if out.Stops == nil {
		out.Stops = map[string]int{}
	}
	for i, d := range a.Days {
		ds := gen.DayStat{Picked: d.Picked, Pushed: d.Pushed, Rejected: d.Rejected, Stopped: d.Stopped,
			AgntsMin: float32(d.AgntsMin), WaitMin: float32(d.WaitMin), Turns: float32(d.Turns), Spend: toTokenSpend(d.Spend)}
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
		AgntsMin   float32 `json:"agntsMin"`
		Analyzed   int     `json:"analyzed"`
		Asked      int     `json:"asked"`
		AvgTurns   float32 `json:"avgTurns"`
		CiFailures int     `json:"ciFailures"`
		ClaudeMd   string  `json:"claudeMd"`
		Closed     int     `json:"closed"`
		Done       int     `json:"done"`
		Finished   int     `json:"finished"`
		Kind       string  `json:"kind"`
		Merged     int     `json:"merged"`
		Name       string  `json:"name"`
		RepoId     int64   `json:"repoId"`
		Tickets    int     `json:"tickets"`
	}, len(a.Repos))
	for i, x := range a.Repos {
		r := &out.Repos[i]
		r.AvgTurns, r.ClaudeMd, r.Done, r.Finished = float32(x.AvgTurns), x.ClaudeMD, x.Done, x.Finished
		r.AgntsMin, r.Kind, r.Name, r.RepoId, r.Tickets = float32(x.AgntsMin), x.Kind, x.Name, x.RepoID, x.Tickets
		r.Merged, r.Closed, r.Asked, r.Analyzed, r.CiFailures = x.Merged, x.Closed, x.Asked, x.Analyzed, x.CIFails
	}
	out.Insights = make([]struct {
		Kind   gen.AnalyticsInsightsKind `json:"kind"`
		Values map[string]string         `json:"values"`
	}, len(a.Insights))
	for i, in := range a.Insights {
		out.Insights[i].Kind, out.Insights[i].Values = gen.AnalyticsInsightsKind(in.Kind), in.Values
	}
	out.Quality = make([]gen.QualityStat, len(a.Quality))
	for i, q := range a.Quality {
		out.Quality[i] = toQualityStat(q)
	}
	skills := make([]gen.SkillStat, len(a.Skills))
	for i, x := range a.Skills {
		skills[i] = gen.SkillStat{Skill: x.Skill, Tickets: x.Tickets, Loaded: x.Loaded, Done: x.Done, FirstTry: x.FirstTry,
			LoadedDone: x.LoadedDone, LoadedFirstTry: x.LoadedFirstTry, Findings: x.Findings, Tokens: float32(x.Tokens)}
	}
	out.Skills = &skills
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

// ticketForBranch links agnts's branches to tickets: the branch a ticket
// stored, else prefix + KEY (the default naming).
func ticketForBranch(v admin.RepoActivityView, branch string) *string {
	if k, ok := v.Tickets[branch]; ok {
		return &k
	}
	prefix := v.Repo.BranchPrefix
	if prefix == "" {
		prefix = "agnts/"
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
	shas := make([]string, len(v.Commits))
	for i, c := range v.Commits {
		shas[i] = c.SHA
	}
	linked := s.commitTickets(r.Context(), v.Repo.ID, shas)
	out := make([]gen.Commit, len(v.Commits))
	for i, c := range v.Commits {
		out[i] = gen.Commit{Sha: c.SHA, Message: c.Message, Author: c.Author, Add: c.Add, Del: c.Del, Ci: gen.CI(c.CI), Url: &c.URL}
		if !c.Date.IsZero() {
			d := c.Date
			out[i].Date = &d
		}
		out[i].Tickets, out[i].TicketKey = toCommitTickets(linked[strings.ToLower(c.SHA)], ticketKeyOf(c.Message))
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
	writeJSON(w, http.StatusOK, toPipelines(v.Pipelines))
}

func toPipelines(ps []vcs.Pipeline) []gen.Pipeline {
	out := make([]gen.Pipeline, len(ps))
	for i, p := range ps {
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
	return out
}

// ticketKeyOf reads the ticket key agnts puts before a commit message ("KEY-1: ...").
func ticketKeyOf(message string) *string {
	if k, _, found := strings.Cut(message, ":"); found && strings.Contains(k, "-") && !strings.Contains(k, " ") && !strings.Contains(k, "\n") {
		return &k
	}
	return nil
}

var shaRe = regexp.MustCompile(`^[0-9a-fA-F]{7,64}$`)

// GetRepoCommit implements gen.ServerInterface.
func (s *Server) GetRepoCommit(w http.ResponseWriter, r *http.Request, id gen.RepoID, sha string) {
	if !s.adminReady(w) {
		return
	}
	if !shaRe.MatchString(sha) {
		writeError(w, http.StatusBadRequest, "bad_request", "sha must be 7 to 64 hex characters")
		return
	}
	v, c, err := s.opt.Admin.Repos.Commit(r.Context(), id, sha)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			s.writeAdminError(w, r, err, "")
			return
		}
		s.opt.Log.Warn("read commit", "repo", id, "sha", sha, "err", err)
		writeError(w, http.StatusBadGateway, "git_host", err.Error())
		return
	}
	str := func(v string) *string {
		if v == "" {
			return nil
		}
		return &v
	}
	at := func(t time.Time) *time.Time {
		if t.IsZero() {
			return nil
		}
		return &t
	}
	out := gen.CommitDetail{Sha: c.SHA, Message: c.Message, Author: c.Author, AuthorEmail: str(c.AuthorEmail), AuthorLogin: str(c.AuthorLogin),
		AuthorAvatar: str(c.AuthorAvatar), Date: at(c.Date), Committer: str(c.Committer), CommitterEmail: str(c.CommitterEmail),
		CommittedDate: at(c.CommittedDate), Parents: c.Parents, Url: c.URL, Add: c.Add, Del: c.Del,
		Files: make([]gen.FileChange, len(c.Files)), Pipelines: toPipelines(c.Pipelines), Pulls: make([]gen.CommitPull, len(c.Pulls)),
		Provider: gen.CommitDetailProvider(v.Provider)}
	out.Tickets, out.TicketKey = toCommitTickets(s.commitTickets(r.Context(), id, []string{c.SHA})[strings.ToLower(c.SHA)], ticketKeyOf(c.Message))
	if out.Parents == nil {
		out.Parents = []string{}
	}
	if len(c.Files) >= vcs.MaxCommitFiles {
		capped := true
		out.FilesCapped = &capped
	}
	for i, f := range c.Files {
		out.Files[i] = gen.FileChange{Path: f.Path, Add: f.Add, Del: f.Del, Diff: f.Diff}
	}
	for i, p := range c.Pulls {
		out.Pulls[i] = gen.CommitPull{Number: p.Number, Title: p.Title, State: gen.CommitPullState(p.State), Url: p.URL}
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

// codeParams checks a ref and a path from the repository root for the code
// view, returning the path without outer slashes.
func codeParams(w http.ResponseWriter, ref *string, path string) (string, string, bool) {
	bad := func(s string) bool {
		return strings.ContainsFunc(s, func(r rune) bool { return r < 0x20 || r == 0x7f })
	}
	rf := ""
	if ref != nil {
		rf = strings.TrimSpace(*ref)
	}
	if bad(rf) || strings.Contains(rf, "..") || strings.ContainsAny(rf, " ~^:?*[\\") {
		writeError(w, http.StatusBadRequest, "bad_request", "ref is not a valid branch, tag or commit")
		return "", "", false
	}
	path = strings.Trim(path, "/")
	if bad(path) {
		writeError(w, http.StatusBadRequest, "bad_request", "path has control characters")
		return "", "", false
	}
	if path != "" {
		for _, seg := range strings.Split(path, "/") {
			if seg == "" || seg == "." || seg == ".." {
				writeError(w, http.StatusBadRequest, "bad_request", "path must not have empty, . or .. parts")
				return "", "", false
			}
		}
	}
	return rf, path, true
}

// codeError writes the error of a code view read.
func (s *Server) codeError(w http.ResponseWriter, r *http.Request, id int64, path string, err error) {
	if errors.Is(err, domain.ErrNotFound) {
		s.writeAdminError(w, r, err, "")
		return
	}
	s.opt.Log.Warn("read repository code", "repo", id, "path", path, "err", err)
	writeError(w, http.StatusBadGateway, "git_host", err.Error())
}

// ListRepoTree implements gen.ServerInterface.
func (s *Server) ListRepoTree(w http.ResponseWriter, r *http.Request, id gen.RepoID, params gen.ListRepoTreeParams) {
	if !s.adminReady(w) {
		return
	}
	path := ""
	if params.Path != nil {
		path = *params.Path
	}
	ref, path, ok := codeParams(w, params.Ref, path)
	if !ok {
		return
	}
	ref, es, err := s.opt.Admin.Repos.Tree(r.Context(), id, ref, path)
	if err != nil {
		s.codeError(w, r, id, path, err)
		return
	}
	out := gen.RepoTree{Ref: ref, Path: path, Entries: make([]gen.TreeEntry, len(es))}
	if len(es) >= vcs.MaxTreeEntries {
		capped := true
		out.Capped = &capped
	}
	for i, e := range es {
		out.Entries[i] = gen.TreeEntry{Name: e.Name, Path: e.Path, Type: gen.TreeEntryType(e.Type)}
		if e.Type == vcs.EntryFile && e.Size > 0 {
			size := e.Size
			out.Entries[i].Size = &size
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// GetRepoFile implements gen.ServerInterface.
func (s *Server) GetRepoFile(w http.ResponseWriter, r *http.Request, id gen.RepoID, params gen.GetRepoFileParams) {
	if !s.adminReady(w) {
		return
	}
	ref, path, ok := codeParams(w, params.Ref, params.Path)
	if !ok {
		return
	}
	if path == "" {
		writeError(w, http.StatusBadRequest, "bad_request", "path is required")
		return
	}
	ref, f, err := s.opt.Admin.Repos.File(r.Context(), id, ref, path)
	if err != nil {
		s.codeError(w, r, id, path, err)
		return
	}
	out := gen.RepoFile{Ref: ref, Path: path, Size: f.Size, Binary: f.Binary, TooLarge: f.TooLarge, Url: f.URL}
	if !f.Binary && !f.TooLarge {
		out.Content = &f.Content
	}
	writeJSON(w, http.StatusOK, out)
}
