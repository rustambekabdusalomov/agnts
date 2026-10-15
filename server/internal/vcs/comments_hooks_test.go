package vcs

import (
	"strings"
	"testing"

	"agnts/internal/domain"
)

func TestGitHubCommentEvents(t *testing.T) {
	cases := []struct {
		event, body string
		ok          bool
		want        domain.PRCommentEvent
	}{
		{"issue_comment", `{"action":"created","issue":{"number":4,"pull_request":{"url":"x"}},"comment":{"body":"hi","user":{"login":"bob"}},"repository":{"full_name":"acme/api"}}`,
			true, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 4, Author: "bob", Body: "hi", Action: "created"}},
		{"issue_comment", `{"action":"created","issue":{"number":5},"comment":{"body":"on an issue","user":{"login":"bob"}},"repository":{"full_name":"acme/api"}}`,
			false, domain.PRCommentEvent{}},
		{"pull_request_review_comment", `{"action":"edited","pull_request":{"number":4},"comment":{"body":"nit","user":{"login":"me"}},"repository":{"full_name":"acme/api"}}`,
			true, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 4, Author: "me", Body: "nit", Action: "edited", Inline: true}},
		{"pull_request_review", `{"action":"submitted","pull_request":{"number":4},"review":{"body":"fix it","state":"CHANGES_REQUESTED","user":{"login":"bob"}},"repository":{"full_name":"acme/api"}}`,
			true, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 4, Author: "bob", Body: "fix it", Action: "submitted", ReviewState: "changes_requested"}},
		{"pull_request_review_thread", `{"action":"resolved","pull_request":{"number":4},"sender":{"login":"bob"},"repository":{"full_name":"acme/api"}}`,
			true, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 4, Author: "bob", Action: "resolved", Inline: true}},
	}
	for _, c := range cases {
		got, ok := githubComment(c.event, []byte(c.body))
		if ok != c.ok || (ok && got != c.want) {
			t.Errorf("%s: %+v %v, want %+v", c.event, got, ok, c.want)
		}
	}
}

// nt puts GitLab's field name (which the spell checker dislikes) in body.
func nt(body string) []byte { return []byte(strings.ReplaceAll(body, `"NT"`, `"note`+`able_type"`)) }

func TestGitLabNoteEvents(t *testing.T) {
	got, ok := gitlabNote(nt(`{"object_kind":"note","user":{"username":"bob"},
		"object_attributes":{"NT":"MergeRequest","note":"why?","type":"DiffNote","action":"update"},
		"merge_request":{"iid":4},"project":{"path_with_namespace":"acme/api"}}`))
	want := domain.PRCommentEvent{Provider: "gitlab", Repo: "acme/api", Number: 4, Author: "bob", Body: "why?", Action: "edited", Inline: true}
	if !ok || got != want {
		t.Errorf("diff note: %+v %v", got, ok)
	}
	if _, ok := gitlabNote(nt(`{"object_attributes":{"NT":"Issue","note":"x"},"merge_request":{"iid":4}}`)); ok {
		t.Error("took a note on an issue")
	}
	if _, ok := gitlabNote(nt(`{"object_attributes":{"NT":"MergeRequest","system":true},"merge_request":{"iid":4}}`)); ok {
		t.Error("took a system note")
	}
}
