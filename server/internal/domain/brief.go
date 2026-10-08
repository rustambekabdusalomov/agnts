package domain

import (
	"errors"
	"strings"
	"time"
	"unicode/utf8"
)

// BriefStatus is where the survey of a repository stands.
type BriefStatus string

// Brief statuses. A brief reaches prompts whatever its status, as long as a
// person approved a body.
const (
	BriefIdle      BriefStatus = "idle"      // nothing queued
	BriefPending   BriefStatus = "pending"   // queued for a survey
	BriefSurveying BriefStatus = "surveying" // Claude is surveying the repository
	BriefFailed    BriefStatus = "failed"    // the last survey did not finish
)

// Limits of a brief.
const (
	BriefMaxBody = 40000 // bytes, of the body and of a draft
	// BriefRefreshMerges is how many merged tickets make a brief stale
	// enough to survey again.
	BriefRefreshMerges = 10
)

// RepoBrief is what agnts knows about how a repository works: its
// architecture, the recipes for common changes, the files to copy, its
// conventions and pitfalls. A survey run writes a draft; a person approves
// it (or edits the body directly), and only the approved body reaches the
// runs, as /agnts/context/brief.md.
type RepoBrief struct {
	RepoID      int64
	WorkspaceID int64
	RepoName    string // filled on reads
	Body        string // approved, what runs read
	BodySHA     string // the commit the approved body describes
	Draft       string // the latest survey, waiting for a person
	DraftSHA    string // the commit the draft describes
	Status      BriefStatus
	MergesSince int // tickets merged since the body was approved
	Error       string
	Revision    int // bumped by every change a person makes
	SurveyedAt  *time.Time
	ApprovedAt  *time.Time
	UpdatedAt   time.Time
}

// Ready reports whether runs get the brief.
func (b RepoBrief) Ready() bool { return strings.TrimSpace(b.Body) != "" }

// Busy reports whether a survey is queued or running.
func (b RepoBrief) Busy() bool { return b.Status == BriefPending || b.Status == BriefSurveying }

// Stale reports whether enough has merged since the approved body to
// survey again.
func (b RepoBrief) Stale() bool {
	return b.Ready() && b.MergesSince >= BriefRefreshMerges
}

// CleanBriefText trims a brief or a draft and checks its size.
func CleanBriefText(s string) (string, error) {
	s = strings.TrimSpace(strings.ReplaceAll(s, "\r\n", "\n"))
	if len(s) > BriefMaxBody {
		return s, errors.New("the brief is longer than 40000 bytes")
	}
	if !utf8.ValidString(s) {
		return s, errors.New("the brief is not valid UTF-8")
	}
	return s, nil
}
