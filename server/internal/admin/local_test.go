package admin

import (
	"context"
	"errors"
	"testing"

	"hiro/internal/domain"
	"hiro/internal/vcs"
)

type fakeLocal []vcs.LocalBranch

func (f fakeLocal) LocalBranches(domain.Repository) ([]vcs.LocalBranch, error) { return f, nil }

// fakeBrowser serves Branches only; the embedded nil Browser panics on anything else.
type fakeBrowser struct {
	vcs.Browser
	branches []vcs.Branch
	err      error
}

func (f fakeBrowser) Branches(context.Context, domain.Repository) ([]vcs.Branch, error) {
	return f.branches, f.err
}

func TestLocalBranchStatus(t *testing.T) {
	local := fakeLocal{
		{Name: "hiro/A-1", SHA: "a1", Unpushed: -1}, // never pushed
		{Name: "hiro/A-2", SHA: "a2", Unpushed: 0},  // pushed
		{Name: "hiro/A-3", SHA: "a3", Unpushed: 2},  // two commits not pushed
		{Name: "hiro/A-4", SHA: "a4", Unpushed: 0},  // someone pushed to origin since
	}
	origin := []vcs.Branch{{Name: "main", SHA: "m"}, {Name: "hiro/A-2", SHA: "a2"}, {Name: "hiro/A-3", SHA: "old"}, {Name: "hiro/A-4", SHA: "theirs"}}

	r := &Repos{local: local, browser: fakeBrowser{branches: origin}}
	got, err := r.localBranches(context.Background(), domain.Repository{})
	if err != nil {
		t.Fatal(err)
	}
	want := []struct {
		status   string
		unpushed int
	}{{LocalOnly, 0}, {LocalPushed, 0}, {LocalUnpushed, 2}, {LocalDiffers, 0}}
	for i, w := range want {
		if got[i].Status != w.status || got[i].Unpushed != w.unpushed {
			t.Errorf("%s: %s/%d, want %s/%d", got[i].Name, got[i].Status, got[i].Unpushed, w.status, w.unpushed)
		}
	}

	// Host unreachable: fall back on the clone's last fetch.
	r.browser = fakeBrowser{err: errors.New("offline")}
	got, _ = r.localBranches(context.Background(), domain.Repository{})
	if got[0].Status != LocalOnly || got[1].Status != LocalPushed || got[2].Status != LocalUnpushed || got[2].Unpushed != 2 {
		t.Errorf("offline: %+v", got)
	}
}
