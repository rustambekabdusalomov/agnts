package domain

import (
	"testing"
	"time"
)

func TestMergeReviewDrafts(t *testing.T) {
	now := time.Now()
	in := func(kind, key, body string, line int) ReviewDraft {
		return ReviewDraft{Kind: kind, Key: key, Body: body, Line: line, Path: "a.go", HeadSHA: "new", State: DraftOpen}
	}
	ex := func(id int64, kind, key, state, body string, edited bool) ReviewDraft {
		return ReviewDraft{ID: id, Kind: kind, Key: key, State: state, Body: body, Edited: edited, Path: "a.go", Line: 1, HeadSHA: "old"}
	}
	existing := []ReviewDraft{
		ex(1, DraftSummary, DraftSummary, DraftPublished, "old summary", true),
		ex(2, DraftFinding, "open", DraftOpen, "old", false),
		ex(3, DraftFinding, "edited", DraftAccepted, "mine", true),
		ex(4, DraftFinding, "dismissed", DraftDismissed, "old", false),
		ex(5, DraftFinding, "published", DraftPublished, "old", false),
		ex(6, DraftFinding, "outdated", DraftOutdated, "old", false),
		ex(7, DraftFinding, "gone", DraftAccepted, "old", false),
		ex(8, DraftFinding, "busy", DraftPublishing, "old", false),
		ex(9, DraftComment, "c1", DraftAccepted, "a person's", false),
		ex(10, DraftFinding, "gone-dismissed", DraftDismissed, "old", false),
	}
	existing[0].PostID = new(int64)
	incoming := []ReviewDraft{
		in(DraftSummary, DraftSummary, "new summary", 0),
		in(DraftFinding, "open", "new", 5),
		in(DraftFinding, "edited", "new", 5),
		in(DraftFinding, "dismissed", "new", 5),
		in(DraftFinding, "published", "new", 5),
		in(DraftFinding, "outdated", "new", 5),
		in(DraftFinding, "busy", "new", 5),
		in(DraftFinding, "fresh", "new", 5),
	}
	got := map[string]ReviewDraft{}
	for _, d := range MergeReviewDrafts(existing, incoming, now) {
		got[d.Key] = d
	}
	want := map[string]struct {
		state, body string
		edited      bool
	}{
		DraftSummary: {DraftOpen, "new summary", false}, // published: a new verdict
		"open":       {DraftOpen, "new", false},
		"edited":     {DraftAccepted, "mine", true}, // a person's text is kept
		"dismissed":  {DraftDismissed, "old", false},
		"published":  {DraftPublished, "old", false},
		"outdated":   {DraftOpen, "new", false},
		"gone":       {DraftOutdated, "old", false},
		"fresh":      {DraftOpen, "new", false},
	}
	for k, w := range want {
		d, ok := got[k]
		if !ok {
			t.Fatalf("%s: not returned", k)
		}
		if d.State != w.state || d.Body != w.body || d.Edited != w.edited {
			t.Errorf("%s: state %s body %q edited %v, want %+v", k, d.State, d.Body, d.Edited, w)
		}
		if k != "gone" && d.Line != 5 && k != DraftSummary {
			t.Errorf("%s: anchor not refreshed: line %d", k, d.Line)
		}
	}
	if got[DraftSummary].PostID == nil {
		t.Error("the published summary lost its post: it could not be edited in place")
	}
	if got["fresh"].ID != 0 {
		t.Error("a new finding is not new")
	}
	for _, k := range []string{"busy", "c1", "gone-dismissed"} {
		if _, ok := got[k]; ok {
			t.Errorf("%s changed", k)
		}
	}
	// Nothing new: nothing to save.
	again := MergeReviewDrafts([]ReviewDraft{{ID: 1, Kind: DraftFinding, Key: "k", State: DraftOpen, Body: "b", HeadSHA: "new"}},
		[]ReviewDraft{{Kind: DraftFinding, Key: "k", State: DraftOpen, Body: "b", HeadSHA: "new"}}, now)
	if len(again) != 0 {
		t.Fatalf("an unchanged draft was saved: %+v", again)
	}
}
