package domain

import (
	"slices"
	"testing"
	"time"
)

func TestAssignFolders(t *testing.T) {
	rs := []TicketRepo{{RepoID: 1, RepoName: "Shop API"}, {RepoID: 2, RepoName: "shop-api"}, {RepoID: 3, RepoName: "web", Folder: "w"}}
	AssignFolders(rs)
	if rs[0].Folder != "shop-api" || rs[1].Folder != "shop-api-2" || rs[2].Folder != "w" {
		t.Fatalf("folders: %+v", rs)
	}
	one := []TicketRepo{{RepoID: 1, RepoName: "api", Folder: "api"}}
	AssignFolders(one)
	if one[0].Folder != "" {
		t.Fatalf("a single repository is /workspace: %+v", one)
	}
	if RepoFolder("../../etc") != "etc" || RepoFolder("  ") != "repo" {
		t.Fatalf("unsafe folder: %q %q", RepoFolder("../../etc"), RepoFolder("  "))
	}
}

func TestSyncReposMirrorsPrimary(t *testing.T) {
	api, web := int64(1), int64(2)
	n := 7
	tk := Ticket{RepoID: &api, Branch: "agnts/X-1", HeadSHA: "abc", PRNumber: &n, PRURL: "u",
		Repos: []TicketRepo{{RepoID: web, RepoName: "web"}, {RepoID: api, RepoName: "api"}}}
	tk.SyncRepos()
	if tk.Repos[0].RepoID != api || tk.Repos[0].HeadSHA != "abc" || tk.Repos[0].Folder != "api" || tk.Repos[1].Folder != "web" {
		t.Fatalf("primary first, mirrored: %+v", tk.Repos)
	}
	tk.UpdateRepo(api, func(r *TicketRepo) { r.HeadSHA = "def" })
	if tk.HeadSHA != "def" {
		t.Fatalf("the ticket's own head follows its primary: %q", tk.HeadSHA)
	}
	tk.UpdateRepo(web, func(r *TicketRepo) { r.HeadSHA = "w1" })
	if tk.HeadSHA != "def" {
		t.Fatal("another repository changed the ticket's head")
	}
}

func TestAllMerged(t *testing.T) {
	api, web := int64(1), int64(2)
	n1, n2 := 1, 2
	now := time.Now()
	tk := Ticket{RepoID: &api, PRNumber: &n1, Repos: []TicketRepo{{RepoID: api}, {RepoID: web, PRNumber: &n2}}}
	if tk.AllMerged() {
		t.Fatal("nothing merged")
	}
	tk.Repos[0].MergedAt = &now
	if tk.AllMerged() {
		t.Fatal("one of two merged")
	}
	tk.Repos[1].ClosedAt, tk.Repos[1].State = &now, RepoDropped
	if !tk.AllMerged() || !tk.PartlyMerged() {
		t.Fatal("one merged, one closed: merged, partly")
	}
	if (Ticket{}).AllMerged() {
		t.Fatal("no pull request is not merged")
	}
}

func TestRepoLabels(t *testing.T) {
	ls := []string{"agnts", "repo:api", "Repo:Web", "repo:API", "group:Shop", "group:other"}
	if got := ReposFromLabels(ls); !slices.Equal(got, []string{"api", "Web"}) {
		t.Fatalf("repos: %v", got)
	}
	if GroupFromLabels(ls) != "Shop" || GroupFromLabels([]string{"repo:x"}) != "" {
		t.Fatal("group label")
	}
}

func TestRepoChoiceCheck(t *testing.T) {
	if (RepoChoice{RepoID: 1, GroupID: 2}).Check() == nil {
		t.Fatal("two ways at once")
	}
	if (RepoChoice{RepoIDs: []int64{1, 2}}).Check() != nil || !(RepoChoice{}).Empty() {
		t.Fatal("valid choices refused")
	}
}

func TestFilesIn(t *testing.T) {
	api := int64(1)
	fs := []FileChange{{Path: "a.go"}, {Repo: "web", RepoID: 2, Path: "b.ts"}, {Repo: "api", RepoID: 1, Path: "c.go"}}
	got := FilesIn(fs, 1, &api)
	if len(got) != 2 || got[0].Path != "a.go" || got[1].Path != "c.go" || got[1].Repo != "" {
		t.Fatalf("api's files: %+v", got)
	}
	if got := FilesIn(fs, 2, &api); len(got) != 1 || got[0].Where() != "b.ts" {
		t.Fatalf("web's files: %+v", got)
	}
}
