package domain

import "time"

// TicketContext is what a tracker knows about an issue besides its title
// and description: its parent, linked issues and subtasks, the discussion
// in its comments, and the images attached to it. Runs read it as data
// from people outside agnts, like the description.
type TicketContext struct {
	Parent   *IssueBrief
	Links    []IssueBrief
	Subtasks []IssueBrief
	Comments []IssueComment
	Images   []IssueImage
	// Refs are the links and images in the description, which its plain
	// text leaves out.
	Refs []string
}

// Empty reports whether there is nothing to show.
func (c TicketContext) Empty() bool {
	return c.Parent == nil && len(c.Links) == 0 && len(c.Subtasks) == 0 && len(c.Comments) == 0 && len(c.Images) == 0 && len(c.Refs) == 0
}

// IssueBrief is another issue as a ticket's context names it.
type IssueBrief struct {
	Key         string
	Title       string
	Status      string
	Relation    string // how it relates: "blocks", "relates to", ...
	Description string // the parent's, shortened; empty for the others
}

// IssueComment is one comment on an issue.
type IssueComment struct {
	Author string
	At     time.Time
	Body   string
}

// IssueImage is an image attached to an issue.
type IssueImage struct {
	Name string
	MIME string
	Data []byte
}
