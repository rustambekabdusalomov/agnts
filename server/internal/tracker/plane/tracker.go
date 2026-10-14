package plane

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// workItem is a Plane work item as the API returns it with
// expand=labels,state,project. Without expand, labels are ids and state
// and project are ids; both forms decode.
type workItem struct {
	ID              string          `json:"id"`
	SequenceID      int             `json:"sequence_id"`
	Name            string          `json:"name"`
	DescriptionHTML string          `json:"description_html"`
	Priority        string          `json:"priority"` // urgent, high, medium, low, none
	Project         json.RawMessage `json:"project"`
	State           json.RawMessage `json:"state"`
	Labels          json.RawMessage `json:"labels"`
	ArchivedAt      *string         `json:"archived_at"`
	DeletedAt       *string         `json:"deleted_at"`
}

// projectRef reads the project as an id or an expanded object.
func (w workItem) projectRef() (id, identifier string) {
	var s string
	if json.Unmarshal(w.Project, &s) == nil {
		return s, ""
	}
	var p Project
	_ = json.Unmarshal(w.Project, &p)
	return p.ID, p.Identifier
}

// stateRef reads the state as an id or an expanded object.
func (w workItem) stateRef() State {
	var s string
	if json.Unmarshal(w.State, &s) == nil {
		return State{ID: s}
	}
	var st State
	_ = json.Unmarshal(w.State, &st)
	return st
}

// labelRefs reads the labels as ids or expanded objects.
func (w workItem) labelRefs() []label {
	var raw []json.RawMessage
	if json.Unmarshal(w.Labels, &raw) != nil {
		return nil
	}
	out := make([]label, 0, len(raw))
	for _, r := range raw {
		var id string
		if json.Unmarshal(r, &id) == nil {
			out = append(out, label{ID: id})
			continue
		}
		var l label
		if json.Unmarshal(r, &l) == nil {
			out = append(out, l)
		}
	}
	return out
}

// item is a work item with everything ingest needs resolved.
type item struct {
	ref
	key        string
	project    string // identifier
	title      string
	desc       string
	priority   string
	state      State
	labels     []string // names
	gone       bool     // archived or deleted
	dependsOn  []string
	dependents []string
	linksKnown bool
}

// labels are the labels that hand a work item to agnts: the base label and
// one per kind.
func labels(base string) []string {
	out := []string{base}
	for _, k := range domain.Kinds {
		out = append(out, base+"-"+string(k))
	}
	return out
}

// forAgnts reports whether the item carries any of agnts's labels.
func (it item) forAgnts(base string) bool {
	for _, want := range labels(base) {
		for _, l := range it.labels {
			if strings.EqualFold(l, want) {
				return true
			}
		}
	}
	return false
}

// kind is the kind its labels name (the first in domain.Kinds order when
// there are several), or "" for agnts to pick.
func (it item) kind(base string) domain.TicketKind {
	for _, k := range domain.Kinds {
		for _, l := range it.labels {
			if strings.EqualFold(l, base+"-"+string(k)) {
				return k
			}
		}
	}
	return ""
}

// closed reports whether the work item is finished in Plane.
func (it item) closed() bool {
	return it.gone || it.state.Group == "completed" || it.state.Group == "cancelled"
}

func (it item) incoming(base string) orchestrator.Incoming {
	return orchestrator.Incoming{
		Source: domain.SourcePlane, Key: it.key, Project: it.project, Title: it.title, Description: it.desc,
		Priority: priority(it.priority), Kind: it.kind(base), Repo: domain.RepoFromLabels(it.labels), Repos: domain.ReposFromLabels(it.labels), Group: domain.GroupFromLabels(it.labels),
		LinksKnown: it.linksKnown, DependsOn: it.dependsOn, Dependents: it.dependents,
	}
}

// priority maps Plane's priority to agnts's (low, medium, high).
func priority(p string) string {
	switch p {
	case "urgent", "high":
		return "high"
	case "medium":
		return "medium"
	case "low":
		return "low"
	}
	return ""
}

// planePriority maps agnts's priority to Plane's.
func planePriority(p string) string {
	switch p {
	case "low", "medium", "high":
		return p
	}
	return "none"
}

// fetch loads a work item by project and work item id and resolves its
// key, state, labels and blocking relations.
func (c *Client) fetch(ctx context.Context, cfg Config, projectID, id string) (item, error) {
	var w workItem
	path := ws(cfg) + "/projects/" + url.PathEscape(projectID) + "/work-items/" + url.PathEscape(id) + "/"
	if err := c.call(ctx, cfg, http.MethodGet, path+"?expand=labels,state,project", nil, &w); err != nil {
		return item{}, err
	}
	return c.resolveItem(ctx, cfg, projectID, w, true)
}

// resolveItem turns a decoded work item into an item. withLinks also
// reads its relations (one more request).
func (c *Client) resolveItem(ctx context.Context, cfg Config, projectID string, w workItem, withLinks bool) (item, error) {
	pid, ident := w.projectRef()
	if pid == "" {
		pid = projectID
	}
	if ident == "" {
		var err error
		if ident, err = c.projectIdentifier(ctx, pid); err != nil {
			return item{}, err
		}
	}
	if w.ID == "" || w.SequenceID == 0 {
		return item{}, errors.New("plane returned a work item without id or sequence id")
	}
	it := item{
		ref: ref{project: pid, id: w.ID}, key: strings.ToUpper(ident) + "-" + strconv.Itoa(w.SequenceID), project: strings.ToUpper(ident),
		title: strings.TrimSpace(w.Name), desc: textFromHTML(w.DescriptionHTML), priority: w.Priority, state: w.stateRef(),
		gone: w.ArchivedAt != nil || w.DeletedAt != nil,
	}
	c.remember(cfg, it.key, it.ref)

	if it.state.Group == "" && it.state.ID != "" {
		if sts, err := c.loadStates(ctx, cfg, pid); err == nil {
			if i := slices.IndexFunc(sts, func(s State) bool { return s.ID == it.state.ID }); i >= 0 {
				it.state = sts[i]
			}
		}
	}
	refs := w.labelRefs()
	if slices.ContainsFunc(refs, func(l label) bool { return l.Name == "" }) {
		all, err := c.loadLabels(ctx, cfg, pid, false)
		if err != nil {
			return item{}, err
		}
		for i, l := range refs {
			if j := slices.IndexFunc(all, func(x label) bool { return x.ID == l.ID }); l.Name == "" && j >= 0 {
				refs[i].Name = all[j].Name
			}
		}
	}
	for _, l := range refs {
		if l.Name != "" {
			it.labels = append(it.labels, l.Name)
		}
	}
	if withLinks {
		it.dependsOn, it.dependents, it.linksKnown = c.relations(ctx, cfg, it.ref)
	}
	return it, nil
}

// relations reads the blocking relations of a work item as keys. ok is
// false when Plane did not answer (older versions have no relations
// endpoint): agnts then leaves existing relations alone.
func (c *Client) relations(ctx context.Context, cfg Config, r ref) (dependsOn, dependents []string, ok bool) {
	var resp struct {
		Blocking  []relRef `json:"blocking"`
		BlockedBy []relRef `json:"blocked_by"`
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(r.project) + "/work-items/" + url.PathEscape(r.id) + "/relations/"
	if err := c.call(ctx, cfg, http.MethodGet, path, nil, &resp); err != nil {
		return nil, nil, false
	}
	keys := func(rs []relRef) ([]string, bool) {
		var out []string
		for _, x := range rs {
			k, err := c.keyOf(ctx, cfg, x.ProjectID, x.IssueID)
			if errors.Is(err, errNotFound) {
				continue // deleted, or in a project the key cannot see
			}
			if err != nil {
				return nil, false
			}
			if !slices.Contains(out, k) {
				out = append(out, k)
			}
		}
		return out, true
	}
	var okA, okB bool
	dependsOn, okA = keys(resp.BlockedBy)
	dependents, okB = keys(resp.Blocking)
	return dependsOn, dependents, okA && okB
}

type relRef struct {
	ProjectID string `json:"project_id"`
	IssueID   string `json:"issue_id"`
}

// keyOf returns the key (WEB-7) of a work item by ids.
func (c *Client) keyOf(ctx context.Context, cfg Config, projectID, id string) (string, error) {
	c.mu.Lock()
	for k, r := range c.cache(cfg).refs {
		if r.id == id {
			c.mu.Unlock()
			return k, nil
		}
	}
	c.mu.Unlock()
	var w struct {
		SequenceID int `json:"sequence_id"`
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(projectID) + "/work-items/" + url.PathEscape(id) + "/?fields=id,sequence_id"
	if err := c.call(ctx, cfg, http.MethodGet, path, nil, &w); err != nil {
		return "", err
	}
	ident, err := c.projectIdentifier(ctx, projectID)
	if err != nil {
		return "", err
	}
	key := strings.ToUpper(ident) + "-" + strconv.Itoa(w.SequenceID)
	c.remember(cfg, key, ref{project: projectID, id: id})
	return key, nil
}

// Search returns the open work items carrying an agnts label in the given
// projects (identifiers). Plane's API cannot filter by label, so it reads
// every work item of each project and filters here; relations are read
// only for the ones that are for agnts.
func (c *Client) Search(ctx context.Context, projects []string) ([]orchestrator.Incoming, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return nil, err
	}
	var out []orchestrator.Incoming
	for _, ident := range projects {
		pid, err := c.projectID(ctx, ident)
		if err != nil {
			return out, err
		}
		var mine []item
		err = c.list(ctx, cfg, ws(cfg)+"/projects/"+url.PathEscape(pid)+"/work-items/", url.Values{
			"expand": {"labels,state"},
		}, func(raw json.RawMessage) error {
			var w workItem
			if err := json.Unmarshal(raw, &w); err != nil {
				return err
			}
			it, err := c.resolveItem(ctx, cfg, pid, w, false)
			if err != nil {
				return err
			}
			if it.forAgnts(cfg.Label) && !it.closed() {
				mine = append(mine, it)
			}
			return nil
		})
		if err != nil {
			return out, fmt.Errorf("project %s: %w", ident, err)
		}
		for _, it := range mine {
			it.dependsOn, it.dependents, it.linksKnown = c.relations(ctx, cfg, it.ref)
			out = append(out, it.incoming(cfg.Label))
		}
	}
	return out, nil
}

// Comment posts a plain-text comment unless that kind of comment is
// turned off.
func (c *Client) Comment(ctx context.Context, key string, kind orchestrator.CommentKind, text string) (bool, error) {
	cfg, err := c.config(ctx)
	if errors.Is(err, ErrNotConnected) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	if on, set := cfg.Comments[string(kind)]; set && !on {
		return false, nil
	}
	r, err := c.resolve(ctx, cfg, key)
	if err != nil {
		return false, err
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(r.project) + "/work-items/" + url.PathEscape(r.id) + "/comments/"
	err = c.call(ctx, cfg, http.MethodPost, path, map[string]any{"comment_html": htmlFromText(text)}, nil)
	return err == nil, err
}

// fallbackGroup is the state group a milestone moves to when no state is
// named for it. Plane has no review group, so in_review moves only to a
// named state.
var fallbackGroup = map[orchestrator.TrackerStatus]string{
	orchestrator.TrackerStarted:  "started",
	orchestrator.TrackerMerged:   "completed",
	orchestrator.TrackerRejected: "cancelled",
}

// pickState finds the state a milestone moves to: the one named in
// settings, else the first of its fallback group. ok is false when there
// is nothing to do.
func pickState(states []State, want string, s orchestrator.TrackerStatus) (State, bool, error) {
	if want = strings.TrimSpace(want); want != "" {
		if i := slices.IndexFunc(states, func(x State) bool { return strings.EqualFold(x.Name, want) }); i >= 0 {
			return states[i], true, nil
		}
		return State{}, false, fmt.Errorf("the project has no state %q", want)
	}
	g, ok := fallbackGroup[s]
	if !ok {
		return State{}, false, nil
	}
	if i := slices.IndexFunc(states, func(x State) bool { return x.Group == g }); i >= 0 {
		return states[i], true, nil
	}
	return State{}, false, nil
}

// MoveTo sets the work item's state to the one for milestone s. Plane has
// no transition rules: any state can be set directly.
func (c *Client) MoveTo(ctx context.Context, key string, s orchestrator.TrackerStatus) error {
	cfg, err := c.config(ctx)
	if errors.Is(err, ErrNotConnected) {
		return nil
	}
	if err != nil {
		return err
	}
	r, err := c.resolve(ctx, cfg, key)
	if err != nil {
		return err
	}
	states, err := c.loadStates(ctx, cfg, r.project)
	if err != nil {
		return err
	}
	st, ok, err := pickState(states, cfg.Statuses[string(s)], s)
	if err != nil || !ok {
		return err
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(r.project) + "/work-items/" + url.PathEscape(r.id) + "/"
	return c.call(ctx, cfg, http.MethodPatch, path, map[string]any{"state": st.ID}, nil)
}

// CreateIssue files a work item in the project (identifier), without
// agnts's labels, and returns its key.
func (c *Client) CreateIssue(ctx context.Context, in orchestrator.NewIssue) (string, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return "", err
	}
	pid, err := c.projectID(ctx, in.Project)
	if err != nil {
		return "", err
	}
	var w workItem
	err = c.call(ctx, cfg, http.MethodPost, ws(cfg)+"/projects/"+url.PathEscape(pid)+"/work-items/", map[string]any{
		"name": in.Title, "description_html": htmlFromText(in.Description), "priority": planePriority(in.Priority),
	}, &w)
	if err != nil {
		return "", err
	}
	if w.ID == "" || w.SequenceID == 0 {
		return "", errors.New("plane created the work item but returned no id")
	}
	key := strings.ToUpper(in.Project) + "-" + strconv.Itoa(w.SequenceID)
	c.remember(cfg, key, ref{project: pid, id: w.ID})
	return key, nil
}

// LabelIssue adds the kind label (agnts-code, agnts-plan, ...), creating
// it in the project when missing, which hands the work item to agnts with
// that kind.
func (c *Client) LabelIssue(ctx context.Context, key string, kind domain.TicketKind) error {
	cfg, err := c.config(ctx)
	if err != nil {
		return err
	}
	r, err := c.resolve(ctx, cfg, key)
	if err != nil {
		return err
	}
	want := cfg.Label + "-" + string(kind)
	lb, err := c.ensureLabel(ctx, cfg, r.project, want)
	if err != nil {
		return err
	}
	var cur struct {
		Labels []string `json:"labels"`
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(r.project) + "/work-items/" + url.PathEscape(r.id) + "/"
	if err := c.call(ctx, cfg, http.MethodGet, path+"?fields=id,labels", nil, &cur); err != nil {
		return err
	}
	if slices.Contains(cur.Labels, lb.ID) {
		return nil
	}
	return c.call(ctx, cfg, http.MethodPatch, path, map[string]any{"labels": append(cur.Labels, lb.ID)}, nil)
}

// ensureLabel returns the project's label called name, creating it.
func (c *Client) ensureLabel(ctx context.Context, cfg Config, projectID, name string) (label, error) {
	for _, fresh := range []bool{false, true} {
		all, err := c.loadLabels(ctx, cfg, projectID, fresh)
		if err != nil {
			return label{}, err
		}
		if i := slices.IndexFunc(all, func(l label) bool { return strings.EqualFold(l.Name, name) }); i >= 0 {
			return all[i], nil
		}
	}
	var lb label
	err := c.call(ctx, cfg, http.MethodPost, ws(cfg)+"/projects/"+url.PathEscape(projectID)+"/labels/",
		map[string]any{"name": name, "color": "#6366F1"}, &lb)
	if err != nil {
		return label{}, fmt.Errorf("create label %s: %w", name, err)
	}
	c.mu.Lock()
	delete(c.cache(cfg).labels, projectID)
	c.mu.Unlock()
	return lb, nil
}

// LinkIssues relates key to other.
func (c *Client) LinkIssues(ctx context.Context, key, other string) error {
	cfg, err := c.config(ctx)
	if err != nil {
		return err
	}
	a, err := c.resolve(ctx, cfg, key)
	if err != nil {
		return err
	}
	b, err := c.resolve(ctx, cfg, other)
	if err != nil {
		return err
	}
	path := ws(cfg) + "/projects/" + url.PathEscape(a.project) + "/work-items/" + url.PathEscape(a.id) + "/relations/"
	return c.call(ctx, cfg, http.MethodPost, path, map[string]any{"relation_type": "relates_to", "issues": []string{b.id}}, nil)
}
