package domain

import (
	"fmt"
	"regexp"
	"slices"
	"strings"
	"time"
)

// RepoGroup is a named set of repositories in a workspace, for tickets that
// change several of them together (a backend and its web app, a service and
// its shared library). A ticket created from a group copies its members:
// later edits of the group never change tickets already made.
type RepoGroup struct {
	ID          int64
	WorkspaceID int64
	Name        string
	Description string
	// Instructions say how the repositories fit together (contracts, the
	// order of changes); every prompt of the group's tickets gets them.
	Instructions string
	TaskPrefix   string // key prefix of tickets made from the group (SHOP-12)
	Members      []GroupMember
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

// GroupMember is a repository in a group.
type GroupMember struct {
	RepoID   int64
	RepoName string
	Role     string // "backend", "web": a label for people and prompts
	Position int
	Archived bool // the repository is archived: tickets from the group skip it
}

// RepoIDs returns the members' repository ids in order.
func (g RepoGroup) RepoIDs() []int64 {
	out := make([]int64, 0, len(g.Members))
	for _, m := range g.Members {
		out = append(out, m.RepoID)
	}
	return out
}

// Member returns the member for a repository, if it is one.
func (g RepoGroup) Member(repoID int64) (GroupMember, bool) {
	for _, m := range g.Members {
		if m.RepoID == repoID {
			return m, true
		}
	}
	return GroupMember{}, false
}

// DefaultMaxTicketRepos is how many repositories a ticket (and a group) may
// have when the workspace does not say otherwise.
const DefaultMaxTicketRepos = 6

// TicketRepoState is how far a ticket's work got in one repository.
type TicketRepoState string

// Ticket repository states.
const (
	RepoPending   TicketRepoState = "pending"   // nothing committed yet
	RepoUnchanged TicketRepoState = "unchanged" // the work did not change it: no pull request
	RepoPushed    TicketRepoState = "pushed"    // its branch (and pull request) are up
	RepoMerged    TicketRepoState = "merged"
	RepoDropped   TicketRepoState = "dropped" // its pull request was closed without a merge
)

// TicketRepo is the git side of a ticket in one repository. A ticket with
// one repository has one; its values are the ticket's own branch, head and
// pull request (Ticket.Branch and the rest mirror the primary's).
type TicketRepo struct {
	RepoID   int64
	RepoName string // loaded with the ticket
	Position int
	// Folder is where the repository is in a run: "" for /workspace itself
	// (a ticket with one repository), else /workspace/<Folder>.
	Folder    string
	Role      string
	Branch    string
	HeadSHA   string
	BaseSHA   string
	PRNumber  *int
	PRURL     string
	Assignees []string
	CIFixes   int
	MergedAt  *time.Time
	ClosedAt  *time.Time
	State     TicketRepoState
	PushError string // why its last push failed, "" when it did not
	Files     int    // files its last commit changed against the default branch
	Archived  bool   // loaded with the ticket
}

// Dir is the repository's directory in a run.
func (r TicketRepo) Dir() string {
	if r.Folder == "" {
		return "/workspace"
	}
	return "/workspace/" + r.Folder
}

// Changed reports whether the work changed the repository.
func (r TicketRepo) Changed() bool {
	return r.State != RepoUnchanged && r.HeadSHA != ""
}

// Multi reports whether the ticket works in more than one repository.
func (t Ticket) Multi() bool { return len(t.Repos) > 1 }

// RepoIDs returns the ticket's repositories in order, the primary first.
func (t Ticket) RepoIDs() []int64 {
	if len(t.Repos) == 0 {
		if t.RepoID != nil {
			return []int64{*t.RepoID}
		}
		return nil
	}
	out := make([]int64, 0, len(t.Repos))
	for _, r := range t.Repos {
		out = append(out, r.RepoID)
	}
	return out
}

// HasRepo reports whether the ticket works in repository id.
func (t Ticket) HasRepo(id int64) bool {
	return slices.Contains(t.RepoIDs(), id)
}

// RepoState returns the ticket's state in repository id, with the
// primary's values taken from the ticket itself.
func (t Ticket) RepoState(id int64) (TicketRepo, bool) {
	for _, r := range t.Repos {
		if r.RepoID == id {
			if t.RepoID != nil && *t.RepoID == id {
				t.mirrorInto(&r)
			}
			return r, true
		}
	}
	if t.RepoID != nil && *t.RepoID == id {
		r := TicketRepo{RepoID: id, State: RepoPending}
		t.mirrorInto(&r)
		return r, true
	}
	return TicketRepo{}, false
}

// UpdateRepo changes the ticket's state in repository id. For the primary
// repository the ticket's own fields change with it, so code that reads
// them (Branch, HeadSHA, PRNumber, ...) sees the same values.
func (t *Ticket) UpdateRepo(id int64, fn func(*TicketRepo)) {
	t.SyncRepos()
	for i := range t.Repos {
		if t.Repos[i].RepoID != id {
			continue
		}
		fn(&t.Repos[i])
		if t.RepoID != nil && *t.RepoID == id {
			r := t.Repos[i]
			t.Branch, t.HeadSHA, t.BaseSHA, t.PRNumber, t.PRURL = r.Branch, r.HeadSHA, r.BaseSHA, r.PRNumber, r.PRURL
			t.Assignees, t.CIFixes = r.Assignees, r.CIFixes
		}
		return
	}
}

// SyncRepos makes Repos match the ticket: the primary repository is in it,
// first, with the ticket's own branch, head and pull request (those win,
// as most code changes them). Stores call it before saving.
func (t *Ticket) SyncRepos() {
	if t.RepoID == nil {
		return
	}
	at := -1
	for i, r := range t.Repos {
		if r.RepoID == *t.RepoID {
			at = i
			break
		}
	}
	if at < 0 {
		t.Repos = append([]TicketRepo{{RepoID: *t.RepoID, State: RepoPending}}, t.Repos...)
		at = 0
	}
	if at > 0 {
		p := t.Repos[at]
		t.Repos = append(t.Repos[:at:at], t.Repos[at+1:]...)
		t.Repos = append([]TicketRepo{p}, t.Repos...)
	}
	t.mirrorInto(&t.Repos[0])
	for i := range t.Repos {
		t.Repos[i].Position = i
		if t.Repos[i].State == "" {
			t.Repos[i].State = RepoPending
		}
	}
	AssignFolders(t.Repos)
}

// mirrorInto copies the ticket's own git fields into its primary's row.
// MergedAt is not one of them: the ticket's is when all its pull requests
// were merged, the row's when its own was.
func (t Ticket) mirrorInto(r *TicketRepo) {
	r.Branch, r.HeadSHA, r.BaseSHA, r.PRNumber, r.PRURL = t.Branch, t.HeadSHA, t.BaseSHA, t.PRNumber, t.PRURL
	r.Assignees, r.CIFixes = t.Assignees, t.CIFixes
	if !t.Multi() && t.MergedAt != nil && r.MergedAt == nil {
		r.MergedAt, r.State = t.MergedAt, RepoMerged
	}
}

// AnyPR reports whether the ticket opened a pull request in any of its
// repositories.
func (t Ticket) AnyPR() bool {
	if t.PRURL != "" || t.PRNumber != nil {
		return true
	}
	for _, r := range t.Repos {
		if r.PRURL != "" || r.PRNumber != nil {
			return true
		}
	}
	return false
}

// Pushed reports whether anything of the ticket's work was pushed.
func (t Ticket) Pushed() bool {
	if t.AnyPR() {
		return true
	}
	for _, r := range t.Repos {
		if r.State == RepoPushed || r.State == RepoMerged || r.State == RepoDropped {
			return true
		}
	}
	return false
}

// Primary returns the primary repository's row.
func (t Ticket) Primary() (TicketRepo, bool) {
	if t.RepoID == nil {
		return TicketRepo{}, false
	}
	return t.RepoState(*t.RepoID)
}

// OpenedPRs returns the repositories with a pull request agnts opened.
func (t Ticket) OpenedPRs() []TicketRepo {
	var out []TicketRepo
	for _, id := range t.RepoIDs() {
		if r, ok := t.RepoState(id); ok && r.PRNumber != nil {
			out = append(out, r)
		}
	}
	return out
}

// AllMerged reports whether every pull request the ticket opened is
// merged; a pull request closed without a merge does not count as open.
// False when it opened none.
func (t Ticket) AllMerged() bool {
	prs := t.OpenedPRs()
	if len(prs) == 0 {
		return false
	}
	merged := 0
	for _, r := range prs {
		switch {
		case r.MergedAt != nil:
			merged++
		case r.ClosedAt != nil || r.State == RepoDropped:
		default:
			return false
		}
	}
	return merged > 0
}

// PartlyMerged reports whether some of the ticket's pull requests are
// merged and at least one was closed without a merge.
func (t Ticket) PartlyMerged() bool {
	merged, dropped := false, false
	for _, r := range t.OpenedPRs() {
		if r.MergedAt != nil {
			merged = true
		} else if r.ClosedAt != nil || r.State == RepoDropped {
			dropped = true
		}
	}
	return merged && dropped
}

// folderRe keeps the characters a run folder may use.
var folderRe = regexp.MustCompile(`[^a-z0-9._-]+`)

// RepoFolder is the run folder for a repository name: lower case, safe for
// a path ("Shop API" -> "shop-api").
func RepoFolder(name string) string {
	f := strings.Trim(folderRe.ReplaceAllString(strings.ToLower(strings.TrimSpace(name)), "-"), "-.")
	if f == "" {
		return "repo"
	}
	return f
}

// AssignFolders gives each repository of a ticket its run folder: none for
// a single repository (it is /workspace), else its name's folder, with -2,
// -3 for names that clash.
// Folders already given are kept, so a run never moves a repository.
func AssignFolders(rs []TicketRepo) {
	if len(rs) == 1 {
		rs[0].Folder = ""
		return
	}
	seen := map[string]bool{}
	for _, r := range rs {
		if r.Folder != "" {
			seen[r.Folder] = true
		}
	}
	for i := range rs {
		r := &rs[i]
		if r.Folder != "" {
			continue
		}
		name := r.RepoName
		if name == "" {
			name = fmt.Sprintf("repo-%d", r.RepoID)
		}
		base := RepoFolder(name)
		f := base
		for n := 2; seen[f]; n++ {
			f = fmt.Sprintf("%s-%d", base, n)
		}
		seen[f] = true
		r.Folder = f
	}
}

// RepoChoice is how a ticket's repositories were picked: one, several
// (the first is the primary) or a group. At most one of them is set.
type RepoChoice struct {
	RepoID  int64
	RepoIDs []int64
	GroupID int64
}

// Empty reports whether no repository was picked.
func (c RepoChoice) Empty() bool { return c.RepoID == 0 && len(c.RepoIDs) == 0 && c.GroupID == 0 }

// Check reports a choice that names repositories in more than one way.
func (c RepoChoice) Check() error {
	n := 0
	if c.RepoID != 0 {
		n++
	}
	if len(c.RepoIDs) > 0 {
		n++
	}
	if c.GroupID != 0 {
		n++
	}
	if n > 1 {
		return fmt.Errorf("pick a repository, several repositories or a group, not more than one of them")
	}
	return nil
}

// GroupLabelPrefix starts a tracker label that hands an issue to a group of
// repositories (group:shop).
const GroupLabelPrefix = "group:"

// ReposFromLabels returns the repository names every repo: label names, in
// order and without repeats. The prefix is matched in any case.
func ReposFromLabels(labels []string) []string {
	var out []string
	for _, l := range labels {
		if name := labelValue(l, RepoLabelPrefix); name != "" && !slices.ContainsFunc(out, func(x string) bool { return strings.EqualFold(x, name) }) {
			out = append(out, name)
		}
	}
	return out
}

// GroupFromLabels returns the group the first group: label names, or "".
func GroupFromLabels(labels []string) string {
	for _, l := range labels {
		if name := labelValue(l, GroupLabelPrefix); name != "" {
			return name
		}
	}
	return ""
}

func labelValue(l, prefix string) string {
	l = strings.TrimSpace(l)
	if len(l) > len(prefix) && strings.EqualFold(l[:len(prefix)], prefix) {
		return strings.TrimSpace(l[len(prefix):])
	}
	return ""
}

// PRRef names a pull request in a webhook or CI run: its address, its
// branch, and the repository it is in (its id, or the host's full name,
// owner/name), as far as the caller knows them.
type PRRef struct {
	URL    string
	Branch string
	RepoID int64
	Repo   string
}

// FilesIn returns the changes a result lists in repository repoID, for a
// ticket whose primary repository is primary: rows without a repository
// (one-repository tickets, older results) are the primary's. Their Repo
// folder is cleared, so paths are the repository's own.
func FilesIn(files []FileChange, repoID int64, primary *int64) []FileChange {
	var out []FileChange
	for _, f := range files {
		if f.RepoID == repoID || (f.RepoID == 0 && primary != nil && *primary == repoID) {
			f.Repo, f.RepoID = "", 0
			out = append(out, f)
		}
	}
	return out
}

// ResetWork forgets the commits of the ticket's work in every repository
// that has no pull request merged or closed, for a restart: their heads,
// and their branches too when branches is set.
func (t *Ticket) ResetWork(branches bool) {
	t.SyncRepos()
	for i := range t.Repos {
		r := &t.Repos[i]
		if r.MergedAt != nil || r.ClosedAt != nil {
			continue
		}
		r.HeadSHA, r.Files, r.PushError = "", 0, ""
		if r.State == RepoUnchanged {
			r.State = RepoPending
		}
		if branches {
			r.Branch = ""
		}
	}
	t.HeadSHA = ""
	if branches {
		t.Branch = ""
	}
}

// WorkSHA names the ticket's reviewed work: its head for a ticket in one
// repository, every repository's head for one in several, so that a new
// commit in any of them is new work.
func (t Ticket) WorkSHA() string {
	if !t.Multi() {
		return t.HeadSHA
	}
	var parts []string
	for _, id := range t.RepoIDs() {
		if r, ok := t.RepoState(id); ok && r.HeadSHA != "" {
			parts = append(parts, r.HeadSHA)
		}
	}
	return strings.Join(parts, "+")
}
