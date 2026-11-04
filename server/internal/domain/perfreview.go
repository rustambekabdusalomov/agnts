package domain

import (
	"slices"
	"strings"
	"time"
)

// PerfReviewSettings are a workspace's performance review choices (see
// plans/Performance review plan.md).
type PerfReviewSettings struct {
	// Enabled shows the Developers tab and scores delivered tickets. Off
	// by default: automated scoring of people needs the workspace to
	// check its obligations first.
	Enabled bool `json:"enabled"`
	// NotDone are the Jira resolutions that close an issue without the
	// work being done; such an issue never delivers its ticket.
	NotDone []string `json:"notDone"`
}

// DefaultNotDoneResolutions are Jira's usual resolutions for work that
// was not done.
var DefaultNotDoneResolutions = []string{"Won't Do", "Won't Fix", "Duplicate", "Cannot Reproduce", "Declined", "Incomplete"}

// NotDoneResolutions returns the list in force: the default when unset.
func (p PerfReviewSettings) NotDoneResolutions() []string {
	if p.NotDone == nil {
		return DefaultNotDoneResolutions
	}
	return p.NotDone
}

// TrackerResolution is how a tracker reports an issue's end.
type TrackerResolution struct {
	// Closed: Jira's status category Done, Plane's completed or cancelled
	// state group.
	Closed bool
	// Resolution names how: Jira's resolution ("" when it has none),
	// Plane's state group.
	Resolution string
	// At is when it was resolved, when the tracker says; else now.
	At *time.Time
}

// DoneIn reports whether the issue is resolved as done: closed, and not
// with one of the not-done resolutions (Plane: completed, not cancelled).
func (r TrackerResolution) DoneIn(source TicketSource, notDone []string) bool {
	if !r.Closed {
		return false
	}
	if source == SourcePlane {
		return r.Resolution == "completed"
	}
	return !slices.ContainsFunc(notDone, func(n string) bool { return strings.EqualFold(strings.TrimSpace(n), strings.TrimSpace(r.Resolution)) })
}
