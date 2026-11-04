package domain

import "testing"

func TestIsSquashOf(t *testing.T) {
	gh := MergedPull{Number: 7, MergeSHA: "sq"}
	own := []PushedCommit{{SHA: "a", Message: "wip"}, {SHA: "b", Message: "Add login"}}
	cases := []struct {
		name   string
		commit PushedCommit
		pr     MergedPull
		own    []PushedCommit
		want   bool
	}{
		{"github squash of many", PushedCommit{SHA: "SQ", Message: "Add login (#7)", Parents: []string{"p"}}, gh, own, true},
		{"github squash of one", PushedCommit{SHA: "sq", Message: "Add login (#7)"}, gh, own[1:], true},
		{"github rebase keeps the subject", PushedCommit{SHA: "sq", Message: "Add login"}, gh, own, false},
		{"not the merge sha", PushedCommit{SHA: "other", Message: "x"}, gh, own, false},
		{"a merge commit", PushedCommit{SHA: "sq", Message: "Merge", Parents: []string{"a", "b"}}, gh, own, false},
		{"one of its own commits", PushedCommit{SHA: "a", Message: "wip"}, MergedPull{MergeSHA: "a"}, own, false},
		{"gitlab says squash", PushedCommit{SHA: "sq"}, MergedPull{MergeSHA: "sq", Squash: true, SquashKnown: true}, nil, true},
		{"gitlab says not", PushedCommit{SHA: "sq"}, MergedPull{MergeSHA: "sq", SquashKnown: true}, nil, false},
	}
	for _, c := range cases {
		if got := IsSquashOf(c.commit, c.pr, c.own); got != c.want {
			t.Errorf("%s: got %v", c.name, got)
		}
	}
}

func TestRevertedSHA(t *testing.T) {
	if got := RevertedSHA("Revert \"x\"\n\nThis reverts commit 0A1B2C3D4E5F."); got != "0a1b2c3d4e5f" {
		t.Fatal(got)
	}
	if RevertedSHA("Revert \"x\"") != "" {
		t.Fatal("no sha")
	}
}

func TestTrackerDone(t *testing.T) {
	nd := DefaultNotDoneResolutions
	cases := []struct {
		src  TicketSource
		r    TrackerResolution
		want bool
	}{
		{SourceJira, TrackerResolution{Closed: true, Resolution: "Done"}, true},
		{SourceJira, TrackerResolution{Closed: true}, true},
		{SourceJira, TrackerResolution{Closed: true, Resolution: "won't do"}, false},
		{SourceJira, TrackerResolution{Closed: false, Resolution: "Done"}, false},
		{SourcePlane, TrackerResolution{Closed: true, Resolution: "completed"}, true},
		{SourcePlane, TrackerResolution{Closed: true, Resolution: "cancelled"}, false},
	}
	for i, c := range cases {
		if got := c.r.DoneIn(c.src, nd); got != c.want {
			t.Errorf("case %d: got %v", i, got)
		}
	}
	if (PerfReviewSettings{NotDone: []string{}}).NotDoneResolutions() == nil || len(PerfReviewSettings{}.NotDoneResolutions()) == 0 {
		t.Fatal("defaults")
	}
}
