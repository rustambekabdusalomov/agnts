package domain

import (
	"slices"
	"strings"
	"time"
)

// A chat has a mode. In Chat mode the assistant answers about the
// workspace (see assistant.go). In Code mode a person picks repositories
// and asks for a change: the work runs as an ordinary ticket, which the
// conversation drives. What a message does depends on the ticket's state,
// never on a model: it starts a ticket, answers its questions, asks for
// changes, continues or retries it, or waits until its run stops. Approve,
// reject and push stay buttons on the ticket.

// ChatMode is what a conversation does.
type ChatMode string

// Chat modes. A conversation's mode never changes.
const (
	ChatModeChat ChatMode = "chat"
	ChatModeCode ChatMode = "code"
)

// Valid reports whether m is a known mode.
func (m ChatMode) Valid() bool { return m == ChatModeChat || m == ChatModeCode }

// CodeRouted says what a Code message did to the conversation's ticket.
type CodeRouted string

// Routes. Queued messages wait for the run to stop and become sent (or
// failed) when they go to the ticket; steered ones went into the running
// turn.
const (
	RoutedCreated   CodeRouted = "created"   // started a new ticket
	RoutedAnswered  CodeRouted = "answered"  // answered the ticket's questions
	RoutedChanges   CodeRouted = "changes"   // asked for changes on work waiting for review
	RoutedContinued CodeRouted = "continued" // continued a rejected ticket
	RoutedRetried   CodeRouted = "retried"   // retried a stopped ticket with it as a note
	RoutedQueued    CodeRouted = "queued"    // waits until the running stage ends
	RoutedSent      CodeRouted = "sent"      // a queued message, sent
	RoutedFailed    CodeRouted = "failed"    // a queued message the ticket would not take (Error says why)
	RoutedSteered   CodeRouted = "steered"   // delivered into the running Muse turn
)

// CodeTicket is a ticket a Code conversation drives or drove.
type CodeTicket struct {
	Key   string
	Title string
	State TicketState
	Kind  TicketKind
	Repos []string // repository names, the primary first
	// Current is the ticket new messages go to: the newest one still
	// attached. A ticket moved to another conversation is Moved.
	Current    bool
	Moved      bool
	AttachedAt time.Time
}

// CodeHandoff is an answer's offer to do a code change in Code mode: the
// request and the repositories, which the person opens and sends.
type CodeHandoff struct {
	Request string   `json:"request"`
	RepoIDs []int64  `json:"repo_ids"`
	Repos   []string `json:"repos"` // their names, for the card
}

// TimelineItem is one entry of a Code conversation: a person's message or
// an event of one of its tickets.
type TimelineItem struct {
	At      time.Time
	Message *AssistantMessage
	Event   *Event
}

// Limits of Code mode.
const (
	CodeMaxMessage = 4000 // characters
	// CodeMaxRunning is how many of one person's Code tickets may be
	// running (not waiting for them) at once.
	CodeMaxRunning = 3
	// CodeTimelineEvents caps the ticket events one timeline returns: the
	// newest are kept.
	CodeTimelineEvents = 600
)

// CodeTimelineTypes are the ticket events a Code conversation shows.
var CodeTimelineTypes = []string{
	EventStateChanged, EventTicketCreated, EventClaudeText, EventClaudeTool, EventCheck, EventAnswered, EventFeedback,
	EventPushed, EventPROpened, EventMerged, EventError, EventRateLimit, EventReview, EventReadyForReview, EventQueued,
	EventGuard, EventCheckpoint, EventBudget, EventKind,
}

// CodeStopped reports whether a ticket in state s has no stage running: a
// message can go to it now instead of waiting.
func CodeStopped(s TicketState) bool {
	switch s {
	case StateWaitingForAnswers, StateWaitingForReview, StateFailed, StateRateLimited, StateRejected, StateDone:
		return true
	}
	return false
}

// CodeApprovalStatus is where a question about a tool call stands.
type CodeApprovalStatus string

// Approval statuses.
const (
	ApprovalPending CodeApprovalStatus = "pending"
	ApprovalAllowed CodeApprovalStatus = "allowed"
	ApprovalDenied  CodeApprovalStatus = "denied"
	ApprovalExpired CodeApprovalStatus = "expired"
)

// CodeApproval is a tool call a Muse run in a Code conversation's ticket
// waits on: a rule says to ask the person (installing a dependency, say).
// It lives as long as the run; nobody answering in CodeApprovalTTL denies
// it.
type CodeApproval struct {
	ID             string
	ConversationID int64
	UserID         int64
	TicketKey      string
	Tool           string
	Command        string
	Path           string
	Reason         string // why a rule asks
	Status         CodeApprovalStatus
	ExpiresAt      time.Time
}

// CodeApprovalTTL is how long a run waits for a person's decision.
const CodeApprovalTTL = 5 * time.Minute

// MentionedRepos returns the repositories a Code message names, in the
// order the list has them: "@name" always counts, and with plain the name
// alone, as a word, counts too. A name is matched without case, and a
// repository named owner/name also answers to name.
func MentionedRepos(text string, repos []Repository, plain bool) []int64 {
	words := map[string]bool{}  // every word, lower case
	tagged := map[string]bool{} // the words after an @
	low := strings.ToLower(text)
	for i := 0; i < len(low); {
		if !repoNameChar(low[i]) {
			i++
			continue
		}
		j := i
		for j < len(low) && repoNameChar(low[j]) {
			j++
		}
		w := strings.TrimRight(low[i:j], ".") // a full stop ends the sentence, not the name
		words[w] = true
		if i > 0 && low[i-1] == '@' {
			tagged[w] = true
		}
		i = j
	}
	var out []int64
	for _, r := range repos {
		name := strings.ToLower(r.Name)
		names := []string{name}
		if k := strings.LastIndexByte(name, '/'); k >= 0 && k < len(name)-1 {
			names = append(names, name[k+1:])
		}
		if slices.ContainsFunc(names, func(n string) bool { return tagged[n] || plain && words[n] }) {
			out = append(out, r.ID)
		}
	}
	return out
}

// repoNameChar reports whether c may be part of a repository name.
func repoNameChar(c byte) bool {
	return c >= 'a' && c <= 'z' || c >= '0' && c <= '9' || c == '-' || c == '_' || c == '.' || c == '/'
}

// ChoiceOf is a choice of the repositories ids.
func ChoiceOf(ids []int64) RepoChoice {
	if len(ids) == 1 {
		return RepoChoice{RepoID: ids[0]}
	}
	return RepoChoice{RepoIDs: ids}
}
