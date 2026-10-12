package httpapi

import (
	"net/http"

	"agnts/internal/httpapi/gen"
	"agnts/internal/store/postgres"
)

// The Analytics page's Delivery, CI and Learning tabs.

func daysParam[T ~int](p *T) int {
	if p == nil {
		return 30
	}
	return int(*p)
}

func toSpread(s postgres.Spread) gen.Spread {
	return gen.Spread{P50: f32p(s.P50), P90: f32p(s.P90)}
}

func f32p(v *float64) *float32 {
	if v == nil {
		return nil
	}
	f := float32(*v)
	return &f
}

func toDeliveryPeriod(p postgres.DeliveryPeriod) gen.DeliveryPeriod {
	return gen.DeliveryPeriod{Opened: p.Opened, Merged: p.Merged, Closed: p.Closed, MergeMin: toSpread(p.MergeMin),
		Pushed: p.Pushed, PushedMin: toSpread(p.PushedMin), MergedTickets: p.MergedTickets, MergedMin: toSpread(p.MergedMin),
		Questions: p.Questions, AskedTickets: p.AskedTickets, AnalyzedTickets: p.AnalyzedTickets, AnswerMin: toSpread(p.AnswerMin)}
}

// GetAnalyticsDelivery implements gen.ServerInterface.
func (s *Server) GetAnalyticsDelivery(w http.ResponseWriter, r *http.Request, p gen.GetAnalyticsDeliveryParams) {
	if !s.adminReady(w) {
		return
	}
	days := daysParam(p.Days)
	d, err := s.opt.Admin.Dashboard.Delivery(r.Context(), days)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.AnalyticsDelivery{Days: days, Current: toDeliveryPeriod(d.Current), Previous: toDeliveryPeriod(d.Prev),
		PerDay: make([]gen.DeliveryDay, len(d.Days)), Slowest: make([]gen.SlowTicket, len(d.Slowest)),
		Stale: make([]gen.StalePR, len(d.Stale)), Unanswered: d.Unanswered}
	for i, x := range d.Days {
		out.PerDay[i] = gen.DeliveryDay{Merged: x.Merged, Closed: x.Closed, PushedMin: f32p(x.PushedMin), MergedMin: f32p(x.MergedMin)}
		out.PerDay[i].Date.Time = x.Date
	}
	for i, x := range d.Slowest {
		out.Slowest[i] = gen.SlowTicket{Key: x.Key, Title: x.Title, CycleMin: float32(x.CycleMin), AgntsMin: float32(x.AgntsMin),
			AnswersMin: float32(x.AnswersMin), ReviewMin: float32(x.ReviewMin), QueueMin: float32(x.QueueMin), Merged: x.Merged}
	}
	for i, x := range d.Stale {
		out.Stale[i] = gen.StalePR{Key: x.Key, Title: x.Title, Repo: x.Repo, Url: x.URL, OpenedAt: x.OpenedAt}
	}
	writeJSON(w, http.StatusOK, out)
}

func toCIPeriod(p postgres.CIPeriod) gen.CIPeriod {
	return gen.CIPeriod{Seen: p.Seen, New: p.New, Fixed: p.Fixed, AutoFixed: p.AutoFixed, Flaky: p.Flaky,
		FixMin: toSpread(p.FixMin), OwnFixes: p.OwnFixes}
}

// GetAnalyticsCi implements gen.ServerInterface.
func (s *Server) GetAnalyticsCi(w http.ResponseWriter, r *http.Request, p gen.GetAnalyticsCiParams) {
	if !s.adminReady(w) {
		return
	}
	days := daysParam(p.Days)
	h, err := s.opt.Admin.Dashboard.CIHealth(r.Context(), days)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.AnalyticsCI{Days: days, Watching: h.Watching, Current: toCIPeriod(h.Current), Previous: toCIPeriod(h.Prev),
		ByClass: h.ByClass, PerDay: make([]gen.CIDay, len(h.Days)), Flakiest: make([]gen.FlakyJob, len(h.Flakiest)), Open: h.Open}
	for i, x := range h.Days {
		out.PerDay[i] = gen.CIDay{New: x.New, Fixed: x.Fixed}
		out.PerDay[i].Date.Time = x.Date
	}
	for i, x := range h.Flakiest {
		out.Flakiest[i] = gen.FlakyJob{Id: x.ID, Repo: x.Repo, Workflow: x.Workflow, Job: x.Job, Title: x.Title, Flaky: x.Flaky, Failures: x.Failures}
	}
	writeJSON(w, http.StatusOK, out)
}

func toLearningPeriod(p postgres.LearningPeriod) gen.LearningPeriod {
	return gen.LearningPeriod{Lessons: p.Lessons, LessonsLearned: p.LessonsLearned, RulesSuggested: p.RulesSuggested,
		RulesAdopted: p.RulesAdopted, RulesManual: p.RulesManual, Reflections: p.Reflections, ReflectionRules: p.ReflectionRules,
		FollowUps: p.FollowUps, Accepted: p.Accepted, Dismissed: p.Dismissed, ReviewerNotes: p.ReviewerNotes}
}

func toFollowUpCounts(cs []postgres.FollowUpCount) []gen.FollowUpCount {
	out := make([]gen.FollowUpCount, len(cs))
	for i, c := range cs {
		out[i] = gen.FollowUpCount{Name: c.Name, Suggested: c.Suggested, Accepted: c.Accepted, Dismissed: c.Dismissed}
	}
	return out
}

// GetAnalyticsLearning implements gen.ServerInterface.
func (s *Server) GetAnalyticsLearning(w http.ResponseWriter, r *http.Request, p gen.GetAnalyticsLearningParams) {
	if !s.adminReady(w) {
		return
	}
	days := daysParam(p.Days)
	l, err := s.opt.Admin.Dashboard.Learning(r.Context(), days)
	if err != nil {
		s.writeInternal(w, r, err)
		return
	}
	out := gen.AnalyticsLearning{Days: days, Current: toLearningPeriod(l.Current), Previous: toLearningPeriod(l.Prev),
		Lessons: make([]gen.LessonCount, len(l.Lessons)), FollowUpTypes: toFollowUpCounts(l.FollowUpTypes),
		FollowUpSources: toFollowUpCounts(l.FollowUpSources), Reviewers: make([]gen.ReviewerStat, len(l.Reviewers))}
	for i, x := range l.Lessons {
		out.Lessons[i] = gen.LessonCount{Category: x.Category, Created: x.Created, Learned: x.Learned}
	}
	for i, x := range l.Reviewers {
		repos := x.Repos
		if repos == nil {
			repos = []string{}
		}
		out.Reviewers[i] = gen.ReviewerStat{Login: x.Login, Rereview: x.Rereview, Dismissed: x.Dismissed, Manual: x.Manual, Repos: repos}
	}
	writeJSON(w, http.StatusOK, out)
}
