package main

import (
	"errors"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/vcs/gitrepo"
)

func TestOwnerAuthor(t *testing.T) {
	missing := errors.New("missing")
	u := domain.User{Username: "rustam", DisplayName: "Rustambek Abdusalomov", Email: "r@example.com"}
	for _, c := range []struct {
		name string
		u    domain.User
		g    domain.GitSettings
		want gitrepo.Author
		err  bool
	}{
		{"nothing set: the owner's account", u, domain.GitSettings{}, gitrepo.Author{Name: "Rustambek Abdusalomov", Email: "r@example.com"}, false},
		{"a name set: the owner's email", u, domain.GitSettings{AuthorName: "Team bot"}, gitrepo.Author{Name: "Team bot", Email: "r@example.com"}, false},
		{"an email set: the owner's name", u, domain.GitSettings{AuthorEmail: "bot@example.com"}, gitrepo.Author{Name: "Rustambek Abdusalomov", Email: "bot@example.com"}, false},
		{"no display name: the username", domain.User{Username: "rustam", DisplayName: "  ", Email: "r@example.com"}, domain.GitSettings{},
			gitrepo.Author{Name: "rustam", Email: "r@example.com"}, false},
		{"no email anywhere", domain.User{Username: "rustam"}, domain.GitSettings{}, gitrepo.Author{}, true},
	} {
		got, err := ownerAuthor(c.u, c.g, missing)
		if (err != nil) != c.err || got != c.want {
			t.Errorf("%s: %+v %v", c.name, got, err)
		}
	}
}

func TestProviderName(t *testing.T) {
	for in, want := range map[string]string{
		"https://inference.baseten.co/v1": "baseten",
		"https://api.together.xyz:443/v1": "together",
		"https://localhost/v1":            "localhost",
	} {
		if got := providerName(in); got != want {
			t.Errorf("providerName(%q) = %q, want %q", in, got, want)
		}
	}
}
