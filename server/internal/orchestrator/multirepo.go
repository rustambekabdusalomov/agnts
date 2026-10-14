package orchestrator

import (
	"archive/tar"
	"context"
	"errors"
	"fmt"
	"io"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
)

// runRepo is one repository of a ticket's run: the repository, the
// ticket's state in it, and the branch the run checks out. A ticket in one
// repository has it at /workspace; a ticket in several has each in a
// folder of its own, /workspace/<folder>.
type runRepo struct {
	domain.Repository
	Row    domain.TicketRepo
	Branch string
	// Frozen: its pull request is merged or closed. The run sees it at the
	// default branch, and nothing in it is committed or pushed again.
	Frozen bool
}

// Folder is the repository's folder under /workspace ("" for /workspace).
func (r runRepo) Folder() string { return r.Row.Folder }

// Dir is the repository's directory in the run.
func (r runRepo) Dir() string { return r.Row.Dir() }

// Rel is a path in the repository as seen from /workspace.
func (r runRepo) Rel(p string) string {
	if r.Folder() == "" {
		return p
	}
	return r.Folder() + "/" + p
}

// Cmd runs cmd in the repository's directory.
func (r runRepo) Cmd(cmd string) string {
	if r.Folder() == "" {
		return cmd
	}
	return "cd " + shellQuote(r.Folder()) + " && {\n" + cmd + "\n}"
}

// Label names the repository in messages of a run in several ("api: ").
func (r runRepo) Label(multi bool) string {
	if !multi {
		return ""
	}
	return r.Name + ": "
}

func shellQuote(s string) string {
	return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'"
}

// reposFor loads the ticket's repositories in order, the primary first,
// with the branch each run checks out: the ticket's own branch (or its
// new one), the default branch where the ticket's change is merged or
// closed. errNoRepo when the ticket has none.
func (o *Orchestrator) reposFor(ctx context.Context, t domain.Ticket) ([]runRepo, error) {
	if t.RepoID == nil {
		return nil, errNoRepo
	}
	t.SyncRepos()
	out := make([]runRepo, 0, len(t.Repos))
	for _, row := range t.Repos {
		repo, err := o.store.RepositoryByID(ctx, row.RepoID)
		if err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				continue // deleted: the others carry on
			}
			return nil, err
		}
		if row.RepoName == "" {
			row.RepoName = repo.Name
		}
		r := runRepo{Repository: repo, Row: row, Branch: row.Branch}
		if r.Branch == "" {
			r.Branch = branchFor(repo, t.Key)
		}
		if row.MergedAt != nil || row.ClosedAt != nil || row.State == domain.RepoDropped {
			r.Frozen, r.Branch = true, repo.DefaultBranch
		}
		out = append(out, r)
	}
	if len(out) == 0 {
		return nil, errNoRepo
	}
	if len(out) == 1 {
		out[0].Row.Folder = "" // the primary alone is /workspace
	}
	return out, nil
}

// optionalRepos is reposFor for stages that also run without a repository:
// nil when the ticket has none and its kind allows it (or agnts has yet to
// pick the kind).
func (o *Orchestrator) optionalRepos(ctx context.Context, t domain.Ticket) ([]runRepo, error) {
	if t.RepoID == nil {
		if t.Kind.Spec().NeedsRepo && !t.KindAuto {
			return nil, errNoRepo
		}
		return nil, nil
	}
	return o.reposFor(ctx, t)
}

// primaryOf returns the primary repository of a run, or nil for none.
func primaryOf(rs []runRepo) *domain.Repository {
	if len(rs) == 0 {
		return nil
	}
	r := rs[0].Repository
	return &r
}

// soloRepo is a run of one repository at /workspace, not a ticket's.
func soloRepo(repo domain.Repository) []runRepo {
	return []runRepo{{Repository: repo, Branch: repo.DefaultBranch}}
}

// repoByID finds a run's repository.
func repoByID(rs []runRepo, id int64) (runRepo, bool) {
	for _, r := range rs {
		if r.ID == id {
			return r, true
		}
	}
	return runRepo{}, false
}

// repoIDsOf lists a run's repository ids.
func repoIDsOf(rs []runRepo) []int64 {
	out := make([]int64, len(rs))
	for i, r := range rs {
		out[i] = r.ID
	}
	return out
}

// repoNames lists a run's repository names: "api, web".
func repoNames(rs []runRepo) string {
	names := make([]string, len(rs))
	for i, r := range rs {
		names[i] = r.Name
	}
	return strings.Join(names, ", ")
}

// workspaceTree is the tar a run of several repositories starts from: each
// repository under its folder. open archives the i-th repository; it is
// called only once the one before is read and closed.
func workspaceTree(open func(i int) (io.ReadCloser, error), rs []runRepo) io.ReadCloser {
	pr, pw := io.Pipe()
	go func() {
		tw := tar.NewWriter(pw)
		for i := range rs {
			rc, err := open(i)
			if err == nil {
				err = prefixTar(tw, rc, rs[i].Folder())
				_ = rc.Close()
			}
			if err != nil {
				_ = pw.CloseWithError(fmt.Errorf("%s: %w", rs[i].Name, err))
				return
			}
		}
		_ = pw.CloseWithError(tw.Close())
	}()
	return pr
}

// prefixTar copies a repository's tar into tw under folder.
func prefixTar(tw *tar.Writer, src io.Reader, folder string) error {
	if err := tw.WriteHeader(&tar.Header{Name: folder + "/", Typeflag: tar.TypeDir, Mode: 0o755,
		Uid: agentUID, Gid: agentUID, Uname: "agent", Gname: "agent"}); err != nil {
		return err
	}
	tr := tar.NewReader(src)
	for {
		h, err := tr.Next()
		if errors.Is(err, io.EOF) {
			return nil
		}
		if err != nil {
			return err
		}
		if h.Typeflag == tar.TypeXGlobalHeader {
			continue
		}
		name := strings.TrimPrefix(h.Name, "./")
		if name == "" || name == "/" {
			continue
		}
		h.Name = folder + "/" + name
		if h.Typeflag == tar.TypeLink {
			h.Linkname = folder + "/" + strings.TrimPrefix(h.Linkname, "./")
		}
		if err := tw.WriteHeader(h); err != nil {
			return err
		}
		if _, err := io.Copy(tw, tr); err != nil { //nolint:gosec // G110: agnts's own checkout, copied as it streams
			return err
		}
	}
}

// agentUID owns the files agnts puts in a run (the image's agent user).
const agentUID = 1000

// mergeSpec sets a run's container from all its repositories: the
// toolchains of all (each under its folder), one package cache for the
// set, the most memory any of them asks for, their shared runner image
// and their build environments together.
func (o *Orchestrator) mergeSpec(ctx context.Context, spec *WorkspaceSpec, rs []runRepo, ticketKey string, run *domain.Run) error {
	if len(rs) == 1 {
		return o.repoSpec(ctx, spec, rs[0].Repository, ticketKey, run)
	}
	// Checked when the ticket was made, but toolchains are detected again
	// on every run.
	repos := make([]domain.Repository, len(rs))
	for i, r := range rs {
		repos[i] = r.Repository
	}
	if c := Compatible(repos); !c.OK() {
		return fmt.Errorf("these repositories can no longer share one run container: %s", strings.Join(c.Errors, "; "))
	}
	var ids []string
	images := map[string]string{}
	for _, r := range rs {
		ids = append(ids, strconv.FormatInt(r.ID, 10))
		spec.MemoryMB = max(spec.MemoryMB, r.MemoryMB)
		if r.RunnerImage != "" {
			images[r.RunnerImage] = r.Name
		}
		for _, tc := range r.Toolchains {
			if tc.Dir != "" {
				tc.Dir = r.Folder() + "/" + tc.Dir
			} else {
				tc.Dir = r.Folder()
			}
			if !slices.ContainsFunc(spec.Toolchains, func(x domain.Toolchain) bool { return x.Tool == tc.Tool && x.Version == tc.Version && x.Dir == tc.Dir }) {
				spec.Toolchains = append(spec.Toolchains, tc)
			}
		}
		if r.BuildEnvSet && o.builds != nil {
			env, err := o.builds.BuildEnv(ctx, r.ID)
			if err != nil {
				return fmt.Errorf("load build environment of %s: %w", r.Name, err)
			}
			for _, line := range domain.EnvLines(env) {
				name, _, _ := strings.Cut(line, "=")
				spec.Env = slices.DeleteFunc(spec.Env, func(x string) bool { return strings.HasPrefix(x, name+"=") })
				spec.Env = append(spec.Env, line) // the later repository wins
			}
		}
	}
	if len(images) > 1 {
		var list []string
		for img, name := range images {
			list = append(list, name+" uses "+img)
		}
		slices.Sort(list)
		return fmt.Errorf("the repositories need different runner images (%s): they share one container, so give them the same image", strings.Join(list, "; "))
	}
	for img := range images {
		spec.Image = img
	}
	// One cache for the set: each repository's own cache would need its
	// own package manager settings, and the set never mixes with another.
	spec.CacheKey = "repos-" + strings.Join(ids, "-")
	spec.Progress = func(msg string) {
		o.event(ctx, domain.Event{TicketKey: ticketKey, RunID: &run.ID, Step: "toolchain", Type: domain.EventToolchain, Message: msg})
	}
	return nil
}

// Compatibility is what makes repositories unable, or unwise, to share
// one run container.
type Compatibility struct {
	Errors   []string
	Warnings []string
}

// OK reports whether the repositories can share a container.
func (c Compatibility) OK() bool { return len(c.Errors) == 0 }

// CheckCompatible checks that repositories can share one run container
// (see Compatible).
func (o *Orchestrator) CheckCompatible(_ context.Context, repos []domain.Repository) Compatibility {
	return Compatible(repos)
}

// Compatible checks that repositories can share one run container: the
// same runner image, no two versions of a tool at their roots. Build
// environment variables both set are a warning: the later one wins.
func Compatible(repos []domain.Repository) Compatibility {
	var c Compatibility
	images := map[string][]string{}
	for _, r := range repos {
		img := r.RunnerImage
		if img == "" {
			img = "the default image"
		}
		images[img] = append(images[img], r.Name)
	}
	if len(images) > 1 {
		var parts []string
		for img, names := range images {
			parts = append(parts, strings.Join(names, ", ")+" use "+img)
		}
		slices.Sort(parts)
		c.Errors = append(c.Errors, "different runner images: "+strings.Join(parts, "; "))
	}
	type root struct{ version, repo string }
	roots := map[string]root{}
	for _, r := range repos {
		for _, tc := range r.Toolchains {
			if tc.Dir != "" {
				continue // a subdirectory's own version is mise's to pick
			}
			if prev, ok := roots[tc.Tool]; ok && prev.version != tc.Version {
				c.Errors = append(c.Errors, fmt.Sprintf("%s %s in %s conflicts with %s %s in %s", tc.Tool, prev.version, prev.repo, tc.Tool, tc.Version, r.Name))
				continue
			}
			roots[tc.Tool] = root{tc.Version, r.Name}
		}
	}
	envs := map[string]string{}
	for _, r := range repos {
		for _, name := range r.BuildEnvNames {
			if prev, ok := envs[name]; ok && prev != r.Name {
				c.Warnings = append(c.Warnings, fmt.Sprintf("build variable %s is set in %s and %s: in a ticket of both, %s's value wins", name, prev, r.Name, r.Name))
			}
			envs[name] = r.Name
		}
	}
	return c
}

// activeRules returns the rules runs in these repositories get, each once
// (global ones first); no repositories gives the global ones only.
func (o *Orchestrator) activeRules(ctx context.Context, repoIDs []int64) ([]domain.Rule, error) {
	if o.rules == nil {
		return nil, nil
	}
	if len(repoIDs) <= 1 {
		var id *int64
		if len(repoIDs) == 1 {
			id = &repoIDs[0]
		}
		return o.rules.ActiveRules(ctx, id)
	}
	var out []domain.Rule
	seen := map[int64]bool{}
	for _, id := range repoIDs {
		rs, err := o.rules.ActiveRules(ctx, &id)
		if err != nil {
			return nil, err
		}
		for _, r := range rs {
			if !seen[r.ID] {
				seen[r.ID] = true
				out = append(out, r)
			}
		}
	}
	// Global rules first, then each repository's, as for one repository.
	slices.SortStableFunc(out, func(a, b domain.Rule) int {
		switch {
		case a.RepoID == nil && b.RepoID != nil:
			return -1
		case a.RepoID != nil && b.RepoID == nil:
			return 1
		}
		return 0
	})
	return out, nil
}
