package main

import (
	"errors"
	"net/url"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/egress"
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

func TestMuseAlertText(t *testing.T) {
	pub, _ := url.Parse("https://app.agnts.uz")
	since := time.Now().Add(-12 * time.Minute)
	down := museAlertText(egress.Alert{Down: true, Since: since, Status: egress.UpstreamStatus{Configured: true,
		Via: "socks5://172.19.0.1:1080", Error: "the upstream proxy refused the connection: is the tunnel or proxy running?"}}, pub)
	for _, want := range []string{"is down since", "refused the connection", "-R 172.19.0.1:1080 root@app.agnts.uz", "https://app.agnts.uz/admin"} {
		if !strings.Contains(down, want) {
			t.Errorf("down alert lacks %q:\n%s", want, down)
		}
	}
	up := museAlertText(egress.Alert{Since: since, Status: egress.UpstreamStatus{OK: true, Exit: &egress.ExitAddress{IP: "82.215.78.90", Org: "AS12365 ISP Sarkor Telecom"}}}, pub)
	if !strings.Contains(up, "works again") || !strings.Contains(up, "12m") || !strings.Contains(up, "82.215.78.90") {
		t.Errorf("up alert:\n%s", up)
	}
}
