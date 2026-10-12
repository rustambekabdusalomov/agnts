package admin

import (
	"testing"

	"agnts/internal/store/postgres"
)

func kinds(in []Insight) map[string]map[string]string {
	out := map[string]map[string]string{}
	for _, i := range in {
		out[i.Kind] = i.Values
	}
	return out
}

func TestInsightsDeliveryAndLearning(t *testing.T) {
	a := postgres.Analytics{Stops: map[string]int{}}
	a.Current.Merged, a.Current.Closed = 2, 3
	a.Current.AnswerMin = 300
	a.FollowUpsAccepted, a.FollowUpsDismissed = 1, 9
	a.Flakiest = postgres.FlakyJob{Repo: "api", Workflow: "ci", Job: "e2e", Flaky: 4}
	got := kinds(insights(a))
	if v := got["mergeRate"]; v["pct"] != "40" || v["closed"] != "3" {
		t.Fatalf("mergeRate: %v", got)
	}
	if got["slowAnswers"]["hours"] != "5" {
		t.Fatalf("slowAnswers: %v", got)
	}
	if got["followUpsNoise"]["pct"] != "10" {
		t.Fatalf("followUpsNoise: %v", got)
	}
	if v := got["flakyJob"]; v["job"] != "ci / e2e" || v["repo"] != "api" || v["n"] != "4" {
		t.Fatalf("flakyJob: %v", got)
	}

	// Too few to judge, or healthy: nothing.
	a.Current.Merged, a.Current.Closed = 9, 1
	a.Current.AnswerMin = 30
	a.FollowUpsAccepted, a.FollowUpsDismissed = 1, 2
	a.Flakiest = postgres.FlakyJob{Job: "e2e", Flaky: 2}
	for _, k := range []string{"mergeRate", "slowAnswers", "followUpsNoise", "flakyJob"} {
		if _, ok := kinds(insights(a))[k]; ok {
			t.Fatalf("%s shown for healthy numbers", k)
		}
	}
}
