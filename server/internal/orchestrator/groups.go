package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// GroupInput creates or replaces a repository group.
type GroupInput struct {
	Name         string
	Description  string
	Instructions string
	TaskPrefix   string
	Members      []GroupMemberInput
}

// GroupMemberInput is a repository of a group, in order.
type GroupMemberInput struct {
	RepoID int64
	Role   string
}

// GroupView is a group with what its compatibility check found.
type GroupView struct {
	domain.RepoGroup
	Warnings []string
}

// Groups returns the workspace's repository groups.
func (o *Orchestrator) Groups(ctx context.Context) ([]domain.RepoGroup, error) {
	return o.store.ListGroups(ctx)
}

// Group returns one group with its compatibility warnings.
func (o *Orchestrator) Group(ctx context.Context, id int64) (GroupView, error) {
	g, err := o.store.GroupByID(ctx, id)
	if err != nil {
		return GroupView{}, err
	}
	repos, err := o.groupRepos(ctx, g.RepoIDs())
	if err != nil {
		return GroupView{}, err
	}
	return GroupView{RepoGroup: g, Warnings: o.CheckCompatible(ctx, repos).Warnings}, nil
}

// SaveGroup creates (id 0) or replaces a group. Its repositories must be
// able to share one run container; what they share uneasily comes back as
// warnings.
func (o *Orchestrator) SaveGroup(ctx context.Context, id int64, in GroupInput, origin domain.Origin) (GroupView, error) {
	g := domain.RepoGroup{ID: id, Name: strings.TrimSpace(in.Name), Description: strings.TrimSpace(in.Description),
		Instructions: strings.TrimSpace(in.Instructions), TaskPrefix: strings.ToUpper(strings.TrimSpace(in.TaskPrefix))}
	if g.Name == "" {
		return GroupView{}, invalid("a group needs a name")
	}
	if len(g.Name) > 100 {
		return GroupView{}, invalid("a group name is at most 100 characters")
	}
	if len(g.Instructions) > 20000 {
		return GroupView{}, invalid("the group instructions are at most 20000 characters")
	}
	for _, c := range g.TaskPrefix {
		if c < 'A' || c > 'Z' {
			return GroupView{}, invalid("task prefix may only contain letters")
		}
	}
	if len(g.TaskPrefix) > 10 {
		return GroupView{}, invalid("task prefix is at most 10 letters")
	}
	var cur *domain.RepoGroup
	if id != 0 {
		c, err := o.store.GroupByID(ctx, id)
		if err != nil {
			return GroupView{}, err
		}
		cur = &c
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return GroupView{}, err
	}
	if len(in.Members) == 0 {
		return GroupView{}, invalid("a group needs at least one repository")
	}
	if n := st.TicketRepoLimit(); len(in.Members) > n {
		return GroupView{}, invalid("a group has at most %d repositories (Settings → maximum repositories per ticket)", n)
	}
	var repos []domain.Repository
	for _, m := range in.Members {
		if slices.ContainsFunc(g.Members, func(x domain.GroupMember) bool { return x.RepoID == m.RepoID }) {
			return GroupView{}, invalid("repository %d is in the group twice", m.RepoID)
		}
		repo, err := o.store.RepositoryByID(ctx, m.RepoID)
		if errors.Is(err, domain.ErrNotFound) {
			return GroupView{}, invalid("no repository %d", m.RepoID)
		}
		if err != nil {
			return GroupView{}, err
		}
		kept := false
		if cur != nil {
			_, kept = cur.Member(repo.ID)
		}
		if repo.ArchivedAt != nil && !kept {
			return GroupView{}, invalid("%s is archived: only active repositories can be added to a group", repo.Name)
		}
		role := strings.TrimSpace(m.Role)
		if len(role) > 40 {
			return GroupView{}, invalid("a role is at most 40 characters")
		}
		g.Members = append(g.Members, domain.GroupMember{RepoID: repo.ID, RepoName: repo.Name, Role: role})
		repos = append(repos, repo)
	}
	compat := o.CheckCompatible(ctx, repos)
	if !compat.OK() {
		return GroupView{}, invalid("these repositories cannot share one run container: %s", strings.Join(compat.Errors, "; "))
	}
	if g.TaskPrefix != "" {
		if err := o.checkGroupPrefix(ctx, g); err != nil {
			return GroupView{}, err
		}
	}
	saved, err := o.store.SaveGroup(ctx, g)
	if errors.Is(err, domain.ErrConflict) {
		return GroupView{}, invalid("a group named %s (or with the task prefix %s) already exists", g.Name, g.TaskPrefix)
	}
	if err != nil {
		return GroupView{}, err
	}
	verb := "created"
	if id != 0 {
		verb = "changed"
	}
	o.event(ctx, domain.Event{Type: domain.EventGroup, Origin: origin, Message: fmt.Sprintf("repository group %s %s: %s", saved.Name, verb, groupRepoNames(saved)),
		Data: map[string]any{"group": saved.ID, "repos": saved.RepoIDs()}})
	return GroupView{RepoGroup: saved, Warnings: compat.Warnings}, nil
}

// checkGroupPrefix refuses a group prefix that would number tickets like a
// repository, another group, or a tracker project.
func (o *Orchestrator) checkGroupPrefix(ctx context.Context, g domain.RepoGroup) error {
	if g.TaskPrefix == NoRepoTaskPrefix || g.TaskPrefix == CIPrefix {
		return invalid("%s is agnts's own prefix: pick another", g.TaskPrefix)
	}
	taken, err := o.store.TaskPrefixTaken(ctx, g.TaskPrefix, 0, g.ID)
	if err != nil {
		return err
	}
	if taken {
		return invalid("a repository or group already numbers tickets %s-1, %s-2, …: pick another task prefix", g.TaskPrefix, g.TaskPrefix)
	}
	repos, err := o.listRepos(ctx)
	if err != nil {
		return err
	}
	for _, r := range repos {
		if r.JiraProject == g.TaskPrefix || r.PlaneProject == g.TaskPrefix || TaskPrefix(r) == g.TaskPrefix {
			return invalid("%s already numbers tickets %s-1, %s-2, …: pick another task prefix", r.Name, g.TaskPrefix, g.TaskPrefix)
		}
	}
	return nil
}

// RepoLister lists the workspace's repositories. A Store may implement it.
type RepoLister interface {
	ListRepositories(ctx context.Context) ([]domain.Repository, error)
}

func (o *Orchestrator) listRepos(ctx context.Context) ([]domain.Repository, error) {
	l, ok := o.store.(RepoLister)
	if !ok {
		return nil, nil
	}
	return l.ListRepositories(ctx)
}

// DeleteGroup removes a group. Tickets made from it keep their
// repositories.
func (o *Orchestrator) DeleteGroup(ctx context.Context, id int64, origin domain.Origin) error {
	g, err := o.store.GroupByID(ctx, id)
	if err != nil {
		return err
	}
	if err := o.store.DeleteGroup(ctx, id); err != nil {
		return err
	}
	o.event(ctx, domain.Event{Type: domain.EventGroup, Origin: origin, Message: "repository group " + g.Name + " deleted",
		Data: map[string]any{"group": id}})
	return nil
}

func groupRepoNames(g domain.RepoGroup) string {
	names := make([]string, len(g.Members))
	for i, m := range g.Members {
		names[i] = m.RepoName
	}
	return strings.Join(names, ", ")
}

func (o *Orchestrator) groupRepos(ctx context.Context, ids []int64) ([]domain.Repository, error) {
	var out []domain.Repository
	for _, id := range ids {
		r, err := o.store.RepositoryByID(ctx, id)
		if errors.Is(err, domain.ErrNotFound) {
			continue
		}
		if err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	return out, nil
}

// resolvedRepos is a repository choice made concrete: the repositories in
// order (the primary first) with their roles, the group they came from,
// and the key prefix new tickets get.
type resolvedRepos struct {
	Repos  []domain.Repository
	Rows   []domain.TicketRepo
	Group  *domain.RepoGroup
	Prefix string
	// Skipped are archived group members left out, for a notice.
	Skipped []string
}

// resolveRepos turns a choice of repositories (one, several or a group)
// into the ticket's list, checking each exists and is active, that there
// are not more than the workspace allows, that they can share a container
// and that kind may span several. An empty choice resolves to none.
func (o *Orchestrator) resolveRepos(ctx context.Context, c domain.RepoChoice, kind domain.TicketKind, auto bool) (resolvedRepos, error) {
	var out resolvedRepos
	if err := c.Check(); err != nil {
		return out, invalid("%v", err)
	}
	ids := c.RepoIDs
	roles := map[int64]string{}
	if c.RepoID != 0 {
		ids = []int64{c.RepoID}
	}
	if c.GroupID != 0 {
		g, err := o.store.GroupByID(ctx, c.GroupID)
		if errors.Is(err, domain.ErrNotFound) {
			return out, invalid("no repository group %d", c.GroupID)
		}
		if err != nil {
			return out, err
		}
		out.Group = &g
		for _, m := range g.Members {
			if m.Archived {
				out.Skipped = append(out.Skipped, m.RepoName)
				continue
			}
			ids = append(ids, m.RepoID)
			roles[m.RepoID] = m.Role
		}
		if len(ids) == 0 {
			return out, invalid("every repository of the group %s is archived", g.Name)
		}
	}
	if len(ids) == 0 {
		return out, nil
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return out, err
	}
	seen := map[int64]bool{}
	for _, id := range ids {
		if seen[id] {
			continue // picked twice: the first place wins
		}
		seen[id] = true
		repo, err := o.store.RepositoryByID(ctx, id)
		if errors.Is(err, domain.ErrNotFound) {
			return out, invalid("no repository %d", id)
		}
		if err != nil {
			return out, err
		}
		if repo.ArchivedAt != nil {
			return out, invalid("%s is archived: restore it on the Repositories page to add tasks", repo.Name)
		}
		out.Repos = append(out.Repos, repo)
		out.Rows = append(out.Rows, domain.TicketRepo{RepoID: repo.ID, RepoName: repo.Name, Role: roles[repo.ID], State: domain.RepoPending})
	}
	if n := st.TicketRepoLimit(); len(out.Repos) > n {
		return out, invalid("a ticket has at most %d repositories (Settings → maximum repositories per ticket)", n)
	}
	if len(out.Repos) > 1 {
		if !auto && !kind.Spec().MultiRepo {
			return out, invalid("%s work happens in one repository: pick one", kind)
		}
		if compat := o.CheckCompatible(ctx, out.Repos); !compat.OK() {
			return out, invalid("these repositories cannot share one run container: %s", strings.Join(compat.Errors, "; "))
		}
	}
	out.Prefix = TaskPrefix(out.Repos[0])
	if out.Group != nil && out.Group.TaskPrefix != "" {
		out.Prefix = out.Group.TaskPrefix
	}
	domain.AssignFolders(out.Rows)
	return out, nil
}

// apply puts the resolved repositories on a ticket.
func (r resolvedRepos) apply(t *domain.Ticket) {
	if len(r.Repos) == 0 {
		t.RepoID, t.Repos, t.GroupID = nil, nil, nil
		return
	}
	id := r.Repos[0].ID
	t.RepoID = &id
	t.Repos = append([]domain.TicketRepo(nil), r.Rows...)
	if r.Group != nil {
		gid := r.Group.ID
		t.GroupID, t.GroupName = &gid, r.Group.Name
	} else {
		t.GroupID, t.GroupName = nil, ""
	}
}

// SetRepos changes a ticket's repositories: one, several or a group. It
// is allowed while no stage runs and nothing was pushed: on a new ticket,
// or a failed or rate-limited one. Work so far belongs to the old set, so
// a stopped ticket starts over from analysis on Retry; repositories it
// keeps keep their branch.
func (o *Orchestrator) SetRepos(ctx context.Context, key string, c domain.RepoChoice, origin domain.Origin) (domain.Ticket, error) {
	cur, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return cur, err
	}
	if !canSetRepos(cur) {
		return cur, &domain.TransitionError{Key: key, From: cur.State, To: cur.State}
	}
	res, err := o.resolveRepos(ctx, c, cur.Kind, cur.KindAuto)
	if err != nil {
		return cur, err
	}
	if len(res.Repos) == 0 {
		return cur, invalid("pick a repository, several or a group")
	}
	var bad error
	names := make([]string, len(res.Repos))
	for i, r := range res.Repos {
		names[i] = r.Name
	}
	msg := "repository set to " + names[0]
	if len(names) > 1 {
		msg = "repositories set to " + strings.Join(names, ", ")
	}
	if res.Group != nil {
		msg += " (group " + res.Group.Name + ")"
	}
	t, err := o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: msg,
		Data: map[string]any{"repoId": res.Repos[0].ID, "repoIds": repoIDsOfRepos(res.Repos)},
	}, func(x *domain.Ticket) {
		stopped := x.State == domain.StateFailed || x.State == domain.StateRateLimited
		if !canSetRepos(*x) { // changed since the check above
			bad = &domain.TransitionError{Key: key, From: x.State, To: x.State}
			return
		}
		old := map[int64]domain.TicketRepo{}
		for _, id := range x.RepoIDs() {
			if r, ok := x.RepoState(id); ok {
				old[id] = r
			}
		}
		res.apply(x)
		x.Branch, x.HeadSHA, x.BaseSHA, x.PRNumber, x.PRURL, x.Assignees, x.CIFixes = "", "", "", nil, "", nil, 0
		for i := range x.Repos {
			if prev, ok := old[x.Repos[i].RepoID]; ok && !stopped {
				x.Repos[i].Branch = prev.Branch // kept: same repository, same branch
			}
		}
		x.Branch = x.Repos[0].Branch
		if stopped {
			x.ResumeState = domain.StateNew
			x.Feedback = ""
		}
	})
	if bad != nil {
		return t, bad
	}
	return t, err
}

// canSetRepos reports whether a ticket's repositories may change: before
// work starts, or on a stopped ticket that pushed nothing.
func canSetRepos(x domain.Ticket) bool {
	stopped := x.State == domain.StateFailed || x.State == domain.StateRateLimited
	return (x.State == domain.StateNew || stopped) && !x.Pushed() && x.ResumeState != domain.StatePushing && x.Kind != domain.KindReview
}

func repoIDsOfRepos(rs []domain.Repository) []int64 {
	out := make([]int64, len(rs))
	for i, r := range rs {
		out[i] = r.ID
	}
	return out
}
