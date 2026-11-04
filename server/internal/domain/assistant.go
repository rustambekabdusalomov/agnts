package domain

import (
	"encoding/json"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"
)

// The assistant answers a person's questions about their workspace, in
// text, from a read-only snapshot of it. It takes no actions itself: asked
// to act, it proposes actions on its answer, and only the person's confirm
// does them. This is the chat's Chat mode; Code mode (codechat.go) drives
// tickets instead and never runs the assistant.

// AssistantRole says who wrote a message.
type AssistantRole string

// Message roles.
const (
	AssistantUser  AssistantRole = "user"
	AssistantReply AssistantRole = "assistant"
)

// AssistantStatus is where an answer stands.
type AssistantStatus string

// Answer statuses. A question is stored done; its answer starts pending.
const (
	AssistantPending   AssistantStatus = "pending"
	AssistantAnswering AssistantStatus = "answering"
	AssistantDone      AssistantStatus = "done"
	AssistantFailed    AssistantStatus = "failed"
)

// Open reports whether the answer is still being made.
func (s AssistantStatus) Open() bool { return s == AssistantPending || s == AssistantAnswering }

// AssistantLink points from an answer to a screen of the app.
type AssistantLink struct {
	Kind string `json:"kind"`          // ticket, ci or lesson
	Key  string `json:"key,omitempty"` // a ticket's key
	ID   int64  `json:"id,omitempty"`  // a CI failure or a lesson
}

// Valid reports whether the link names something the app can open.
func (l AssistantLink) Valid() bool {
	switch l.Kind {
	case "ticket":
		return l.Key != "" && len(l.Key) <= 64
	case "ci", "lesson":
		return l.ID > 0
	}
	return false
}

// AssistantTiming splits an answer's time into its parts, in milliseconds.
type AssistantTiming struct {
	StartMS    int64 `json:"start_ms"`    // opening (or reusing) the container
	SnapshotMS int64 `json:"snapshot_ms"` // reading the workspace and writing the files
	ClaudeMS   int64 `json:"claude_ms"`   // the Claude Code run
	Warm       bool  `json:"warm"`        // the container was kept from the last answer
}

// AssistantMessage is a question or an answer.
type AssistantMessage struct {
	ID             int64
	ConversationID int64
	Role           AssistantRole
	Text           string // Markdown for the screen
	Speech         string // the answer in 1-3 plain sentences
	Links          []AssistantLink
	Status         AssistantStatus
	Error          string
	Lang           string
	PromptVersion  string
	Model          string
	Tokens         int
	CostUSD        float64
	DurationMS     int64
	Timing         AssistantTiming
	Files          []string // the snapshot files the answer had
	Rating         int      // -1, 0 (none) or 1
	RatingComment  string
	Shared         bool // its snapshot was kept for replays
	// Actions are the writes the answer proposes; ActionErrors the ones it
	// tried to propose that could not be prepared, and why.
	Actions      []AssistantAction
	ActionErrors []string
	// Handoff offers to do a code change in Code mode (Chat answers).
	Handoff *CodeHandoff
	// TicketKey and Routed say what a Code message did, and to which
	// ticket; Attachments are the uploads that went with it.
	TicketKey   string
	Routed      CodeRouted
	Attachments []int64
	// AttachedFiles are the uploads of Attachments still there, to show.
	AttachedFiles []FileRef
	CreatedAt     time.Time
}

// AssistantProposal is a write an answer asks for: a write tool's name and
// its input, as the run wrote them. Nothing trusts it until it is checked.
type AssistantProposal struct {
	Tool string          `json:"tool"`
	Args json.RawMessage `json:"args"`
}

// DestructiveAction reports whether the write tool cannot be taken back
// (it pushes or stops work): people are asked once more before it.
func DestructiveAction(tool string) bool { return tool == "approve_ticket" || tool == "reject_ticket" }

// AssistantActionStatus is where a proposed action stands.
type AssistantActionStatus string

// Action statuses. Running is between the confirm and its outcome; expired
// is a proposal nobody confirmed in time.
const (
	ActionProposed  AssistantActionStatus = "proposed"
	ActionRunning   AssistantActionStatus = "running"
	ActionDone      AssistantActionStatus = "done"
	ActionFailed    AssistantActionStatus = "failed"
	ActionCancelled AssistantActionStatus = "cancelled"
	ActionExpired   AssistantActionStatus = "expired"
)

// AssistantAction is a checked proposal, waiting for its asker or done.
type AssistantAction struct {
	ID             string
	MessageID      int64
	ConversationID int64
	Tool           string
	TicketKey      string // the ticket it acts on, or the one it made
	Summary        string // agnts's words for what it does, not the model's
	Destructive    bool
	Status         AssistantActionStatus
	Result         string // what happened, or why not
	ExpiresAt      time.Time
}

// AssistantConversation is one person's thread of questions (Chat mode),
// or of requests for code changes (Code mode, see codechat.go).
type AssistantConversation struct {
	ID        int64
	UserID    int64
	Title     string
	Mode      ChatMode
	CreatedAt time.Time
	UpdatedAt time.Time
	// Code mode: the repositories new tickets work in, their kind ("" lets
	// agnts pick), whether they skip checks, and the conversation's
	// tickets, oldest first (in lists, only the current one).
	Repos   RepoChoice
	Kind    string
	Quick   bool
	Tickets []CodeTicket
	// Messages are oldest first: all of them for one conversation, only
	// the last one in lists.
	Messages []AssistantMessage
}

// CurrentTicket is the ticket a Code conversation's messages go to, or nil.
func (c AssistantConversation) CurrentTicket() *CodeTicket {
	for i := len(c.Tickets) - 1; i >= 0; i-- {
		if c.Tickets[i].Current {
			return &c.Tickets[i]
		}
	}
	return nil
}

// Limits of the assistant.
const (
	AssistantMaxQuestion = 1000 // characters
	AssistantTitleLen    = 80
	AssistantHistory     = 6 // earlier messages a question sees
	AssistantPerHour     = 30
	AssistantKeepDays    = 30
	AssistantMaxActions  = 3 // actions one answer may propose
	// AssistantMaxVoice is the longest spoken question; AssistantMaxVoiceBytes
	// fits it as 16 kHz mono 16-bit WAV, the panel's recording.
	AssistantMaxVoice      = 2 * time.Minute
	AssistantMaxVoiceBytes = 4 << 20
	// AssistantActionTTL is how long a proposed action waits for a confirm.
	AssistantActionTTL = 30 * time.Minute
)

// AssistantLanguages are the languages the assistant answers in: the app's.
var AssistantLanguages = map[string]string{"en": "English", "ru": "Russian", "uz": "Uzbek"}

// AssistantSearchHit is a message of the person's AI chat a search found:
// its conversation, and the part that matched (SearchSnippet's marks).
type AssistantSearchHit struct {
	ConversationID int64
	Title          string
	Mode           ChatMode
	MessageID      int64
	Role           AssistantRole
	Text           string // the message's text and its files' names, for the snippet
	Snippet        string
	CreatedAt      time.Time
}

// AssistantTitle is a conversation's title made from its first question.
func AssistantTitle(question string) string {
	t := strings.Join(strings.Fields(question), " ")
	if utf8.RuneCountInString(t) <= AssistantTitleLen {
		return t
	}
	r := []rune(t)[:AssistantTitleLen-1]
	return strings.TrimSpace(string(r)) + "…"
}

var ticketKeyRe = regexp.MustCompile(`\b([A-Za-z][A-Za-z0-9]{0,15})-(\d{1,7})\b`)

// TicketKeysIn returns the ticket keys named in texts (PAY-214, pay-214),
// upper-cased, each once, in the order they first appear.
func TicketKeysIn(texts ...string) []string {
	var out []string
	seen := map[string]bool{}
	for _, s := range texts {
		for _, m := range ticketKeyRe.FindAllStringSubmatch(s, -1) {
			k := strings.ToUpper(m[1]) + "-" + m[2]
			if !seen[k] {
				seen[k] = true
				out = append(out, k)
			}
		}
	}
	return out
}

// AssistantStats is how the assistant did over a period.
type AssistantStats struct {
	Days      int
	Questions int // answers asked for
	Answered  int
	Failed    int
	People    int // who asked
	MedianMS  int64
	P90MS     int64
	// The median of each part of an answer's time, and how many answers
	// found their container warm.
	StartMS, SnapshotMS, ClaudeMS int64
	Warm                          int
	Up, Down                      int
	Tokens                        int64
	CostUSD                       float64
	Actions                       AssistantActionStats
	Versions                      []AssistantVersionStats // newest prompt version first
}

// AssistantActionStats counts the actions answers proposed by what became
// of them; NotOffered the proposals that failed agnts's checks.
type AssistantActionStats struct {
	Proposed, Done, Failed, Cancelled, Expired, NotOffered int
}

// AssistantVersionStats is AssistantStats for one prompt version.
type AssistantVersionStats struct {
	PromptVersion string
	Answered      int
	Failed        int
	Up, Down      int
	MedianMS      int64
	Tokens        int64
	Proposed      int // actions proposed
	Done          int // actions confirmed and done
}

// AssistantRated is an answer someone rated, with its question: what
// workspace owners read to see where the assistant falls short.
type AssistantRated struct {
	MessageID     int64
	Username      string
	Question      string
	Answer        string
	Rating        int
	Comment       string
	PromptVersion string
	Shared        bool
	Actions       []AssistantAction // what the answer proposed
	RatedAt       time.Time
}
