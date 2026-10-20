package domain

import (
	"regexp"
	"slices"
	"strings"
	"time"
)

// Where a commit link's ticket number was found.
const (
	MatchBranch  = "branch"  // the branch the commit was pushed to
	MatchMessage = "message" // the commit message
)

// PushedCommit is a commit on the git host, as a push or a history read
// reports it. Message is the full message.
type PushedCommit struct {
	SHA         string
	Message     string
	Author      string
	AuthorLogin string // the host account, when known
	Date        time.Time
	URL         string
}

// Push is a push to a repository's branch, as a webhook reports it.
type Push struct {
	Provider string
	Repo     string // owner/name (GitHub) or the project path (GitLab)
	Branch   string // without refs/heads/
	Before   string // the branch's tip before the push; all zeros for a new branch
	After    string
	Pusher   string
	Commits  []PushedCommit
	// Total is how many commits the push brought; more than len(Commits)
	// when the host left some out of the payload.
	Total int
}

// NewBranch reports whether the push created the branch.
func (p Push) NewBranch() bool { return zeroSHA(p.Before) }

// Deleted reports whether the push deleted the branch.
func (p Push) Deleted() bool { return zeroSHA(p.After) }

func zeroSHA(s string) bool { return s == "" || strings.Trim(s, "0") == "" }

// CommitLink ties a commit on the git host to a ticket whose number (or
// key) is in the commit's branch or message.
type CommitLink struct {
	TicketID    int64
	TicketKey   string // filled when read
	RepoID      int64
	RepoName    string // filled when read
	SHA         string
	Branch      string // the branch it was first seen on
	Subject     string // the message's first line
	Author      string
	AuthorLogin string
	URL         string
	CommittedAt time.Time
	MatchedOn   []string // MatchBranch, MatchMessage
	Token       string   // what matched, lower case (amanat-2288)
	CreatedAt   time.Time
}

// LinkedTicket is a ticket a commit is linked to, for the commit views.
type LinkedTicket struct {
	Key    string
	Number string
	Title  string
	State  TicketState
}

// ticketTokenRe finds what looks like a ticket number: letters, then a
// dash, then digits (AMANAT-2288, vis-1). Boundaries are checked by hand,
// since \b treats _ as a word character.
var ticketTokenRe = regexp.MustCompile(`(?i)[a-z][a-z0-9_]*-[0-9]+`)

// TicketTokens returns the ticket-number-shaped tokens in s, lower case,
// once each, in the order they appear. A token is whole: the characters
// around it are not letters or digits, so AMANAT-22 is not found in
// AMANAT-2288, and feature/AMANAT-2288-login gives amanat-2288.
func TicketTokens(s string) []string {
	var out []string
	for _, m := range ticketTokenRe.FindAllStringIndex(s, -1) {
		if m[0] > 0 && alnum(s[m[0]-1]) {
			continue
		}
		if m[1] < len(s) && alnum(s[m[1]]) {
			continue
		}
		t := strings.ToLower(s[m[0]:m[1]])
		if !slices.Contains(out, t) {
			out = append(out, t)
		}
	}
	return out
}

func alnum(c byte) bool {
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9'
}

// Subject is a commit message's first line.
func Subject(message string) string {
	s, _, _ := strings.Cut(strings.TrimSpace(message), "\n")
	return strings.TrimSpace(s)
}

// TicketTokensOf returns the lower-case tokens that stand for t: its
// number and its key.
func TicketTokensOf(t Ticket) []string {
	out := []string{strings.ToLower(t.Key)}
	if n := strings.ToLower(t.TicketNumber); n != "" && n != out[0] {
		out = append(out, n)
	}
	return out
}

// PickTicket chooses the ticket a token stands for among the tickets
// whose number or key it is: an open ticket with that number, else the
// ticket with that key, else the closed ticket with that number updated
// last. Numbers are unique only among open tickets; keys always are.
func PickTicket(token string, candidates []Ticket) (Ticket, bool) {
	var byKey, closed *Ticket
	for i := range candidates {
		t := &candidates[i]
		if strings.EqualFold(t.TicketNumber, token) {
			if !t.State.Terminal() {
				return *t, true
			}
			if closed == nil || t.UpdatedAt.After(closed.UpdatedAt) {
				closed = t
			}
		}
		if strings.EqualFold(t.Key, token) {
			byKey = t
		}
	}
	switch {
	case byKey != nil:
		return *byKey, true
	case closed != nil:
		return *closed, true
	}
	return Ticket{}, false
}
