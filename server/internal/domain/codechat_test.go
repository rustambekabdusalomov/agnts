package domain_test

import (
	"slices"
	"testing"

	"agnts/internal/domain"
)

func TestMentionedRepos(t *testing.T) {
	repos := []domain.Repository{{ID: 1, Name: "api"}, {ID: 2, Name: "web-admin"}, {ID: 3, Name: "acme/mobile"}}
	for _, c := range []struct {
		text  string
		plain bool
		want  []int64
	}{
		{"fix login in @api", false, []int64{1}},
		{"fix login in the api", false, nil},
		{"fix login in the api", true, []int64{1}},
		{"@WEB-ADMIN and @api: rename it", false, []int64{1, 2}},
		{"@web is not web-admin", false, nil},
		{"update @mobile.", false, []int64{3}},
		{"update @acme/mobile", false, []int64{3}},
		{"see src/api/handler.go", true, nil},
		{"rapid change", true, nil},
		{"mail me at x@api.dev", false, nil},
	} {
		if got := domain.MentionedRepos(c.text, repos, c.plain); !slices.Equal(got, c.want) {
			t.Errorf("%q (plain %v) = %v, want %v", c.text, c.plain, got, c.want)
		}
	}
}
