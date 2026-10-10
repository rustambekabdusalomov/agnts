package github

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"agnts/internal/domain"
)

func TestReviewQueueMergeAndComment(t *testing.T) {
	var merged, comment map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/user":
			_, _ = io.WriteString(w, `{"login":"me"}`)
		case r.Method == "GET" && r.URL.Path == "/repos/acme/api/pulls":
			_, _ = io.WriteString(w, `[
				{"number":1,"title":"Mine","user":{"login":"me"},"assignees":[{"login":"me"}],"head":{"ref":"a","sha":"s1"},"base":{"ref":"main"}},
				{"number":2,"title":"Assigned","user":{"login":"bob"},"assignees":[{"login":"Me"}],"head":{"ref":"b","sha":"s2"},"base":{"ref":"main"}},
				{"number":3,"title":"Asked","user":{"login":"bob"},"requested_reviewers":[{"login":"me"}],"head":{"ref":"c","sha":"s3"},"base":{"ref":"main"}},
				{"number":4,"title":"Other","user":{"login":"bob"},"head":{"ref":"d","sha":"s4"},"base":{"ref":"main"}}]`)
		case r.Method == "PUT" && r.URL.Path == "/repos/acme/api/pulls/2/merge":
			_ = json.NewDecoder(r.Body).Decode(&merged)
			_, _ = io.WriteString(w, `{"merged":true}`)
		case r.Method == "POST" && r.URL.Path == "/repos/acme/api/issues/2/comments":
			_ = json.NewDecoder(r.Body).Decode(&comment)
			w.WriteHeader(http.StatusCreated)
			_, _ = io.WriteString(w, `{}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	ctx := context.Background()

	prs, err := h.ReviewQueue(ctx, repo, true)
	if err != nil || len(prs) != 2 || prs[0].Number != 2 || prs[0].Why != domain.PullAssigned || prs[1].Why != domain.PullReviewRequested ||
		prs[0].FetchRef != "refs/pull/2/head" || prs[0].Login != "me" {
		t.Fatalf("queue: %+v %v", prs, err)
	}
	if prs, _ := h.ReviewQueue(ctx, repo, false); len(prs) != 1 {
		t.Fatalf("assigned only: %+v", prs)
	}
	if err := h.MergePR(ctx, repo, 2, "s2", "squash"); err != nil || merged["sha"] != "s2" || merged["merge_method"] != "squash" {
		t.Fatalf("merge: %v %v", merged, err)
	}
	if err := h.CommentPR(ctx, repo, 2, "## agnts review"); err != nil || comment["body"] != "## agnts review" {
		t.Fatalf("comment: %v %v", comment, err)
	}
}
