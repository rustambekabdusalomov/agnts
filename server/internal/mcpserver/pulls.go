package mcpserver

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

// PullInput names a pull request by repository and number.
type PullInput struct {
	Repository string `json:"repository" jsonschema:"the repository's name in agnts"`
	Number     int    `json:"number" jsonschema:"the pull request number (GitLab: the merge request IID)"`
}

// PullCommentOut is one comment of a pull request.
type PullCommentOut struct {
	Author  string    `json:"author"`
	Body    string    `json:"body"`
	At      time.Time `json:"at"`
	ByAgnts bool      `json:"byAgnts,omitempty"`
	Edited  bool      `json:"edited,omitempty"`
}

// PullThreadOut is one thread of a pull request.
type PullThreadOut struct {
	Kind        string           `json:"kind"`
	Path        string           `json:"path,omitempty"`
	Line        int              `json:"line,omitempty"`
	Outdated    bool             `json:"outdated,omitempty"`
	Resolved    bool             `json:"resolved,omitempty"`
	ReviewState string           `json:"reviewState,omitempty"`
	SentToAgnts bool             `json:"sentToAgnts,omitempty"`
	Comments    []PullCommentOut `json:"comments"`
}

// PullThreadsOut is get_pull_request_comments's output.
type PullThreadsOut struct {
	Title     string          `json:"title"`
	URL       string          `json:"url"`
	State     string          `json:"state"`
	TicketKey string          `json:"ticketKey,omitempty"`
	Threads   []PullThreadOut `json:"threads"`
}

func (t *tools) getPullComments(ctx context.Context, _ *mcp.CallToolRequest, in PullInput) (*mcp.CallToolResult, PullThreadsOut, error) {
	list, err := t.d.Repos.List(ctx)
	if err != nil {
		return nil, PullThreadsOut{}, err
	}
	var repoID int64
	for _, r := range list {
		if strings.EqualFold(r.Name, strings.TrimSpace(in.Repository)) {
			repoID = r.ID
		}
	}
	if repoID == 0 {
		return nil, PullThreadsOut{}, fmt.Errorf("no repository named %q", in.Repository)
	}
	v, err := t.d.Orch.Pull(ctx, repoID, in.Number)
	if err != nil {
		return nil, PullThreadsOut{}, err
	}
	ts, err := t.d.Orch.PullThreads(ctx, repoID, in.Number)
	if err != nil {
		return nil, PullThreadsOut{}, err
	}
	out := PullThreadsOut{Title: v.Pull.Title, URL: v.Pull.URL, State: v.Pull.State, TicketKey: v.TicketKey, Threads: []PullThreadOut{}}
	for _, th := range ts {
		o := PullThreadOut{Kind: th.Kind, Path: th.Path, Line: max(th.Line, th.OldLine), Outdated: th.Outdated, Resolved: th.Resolved,
			ReviewState: th.ReviewState, SentToAgnts: th.Sent, Comments: []PullCommentOut{}}
		for _, c := range th.Comments {
			if c.System {
				continue
			}
			o.Comments = append(o.Comments, PullCommentOut{Author: c.Author, Body: c.Body, At: c.CreatedAt, ByAgnts: c.Agnts, Edited: c.Edited()})
		}
		out.Threads = append(out.Threads, o)
	}
	return nil, out, nil
}
