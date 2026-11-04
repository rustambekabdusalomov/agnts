package domain

import (
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

// ChatChannel is a room of a workspace's team chat. Every member sees
// every channel. Agents marks the channel agnts posts its cards to.
type ChatChannel struct {
	ID          int64      `json:"id"`
	Name        string     `json:"name"`
	Topic       string     `json:"topic"`
	Agents      bool       `json:"agents"`
	CreatedAt   time.Time  `json:"createdAt"`
	ArchivedAt  *time.Time `json:"archivedAt,omitempty"`
	LastID      int64      `json:"lastId"`     // the newest message's id, 0 for none
	Unread      int        `json:"unread"`     // messages after the reader's last read one
	LastReadID  int64      `json:"lastReadId"` // the reader's last read message
	WorkspaceID int64      `json:"-"`
}

// DefaultChatChannel is the channel made with a workspace's first list.
const DefaultChatChannel = "general"

// ChatMessageKind is what a chat message is.
type ChatMessageKind string

// Chat message kinds.
const (
	ChatKindText   ChatMessageKind = "text"       // a person wrote it
	ChatKindCard   ChatMessageKind = "agent_card" // agnts's card with buttons
	ChatKindAgent  ChatMessageKind = "agent_text" // agnts's answer or note
	ChatKindSystem ChatMessageKind = "system"
)

// ChatAgent is the author name of agnts's own messages.
const ChatAgent = "agnts"

// Chat limits.
const (
	ChatMaxBody     = 8000
	ChatMaxChannels = 100
)

// ChatMessage is one message of a channel.
type ChatMessage struct {
	ID          int64           `json:"id"`
	ChannelID   int64           `json:"channelId"`
	ReplyTo     *int64          `json:"replyTo,omitempty"`
	AuthorID    *int64          `json:"authorId,omitempty"`
	Author      string          `json:"author"` // the person's username, or "agnts"
	Kind        ChatMessageKind `json:"kind"`
	Body        string          `json:"body"`
	Card        *ChatCard       `json:"card,omitempty"`
	AI          *ChatAI         `json:"ai,omitempty"`
	TicketKey   string          `json:"ticketKey,omitempty"`
	Audio       *ChatAudio      `json:"audio,omitempty"` // a voice message; Body is its transcript
	Files       []FileRef       `json:"files,omitempty"` // uploads that came with it
	ClientMsgID string          `json:"clientMsgId,omitempty"`
	Refs        []ChatRef       `json:"refs"`
	CreatedAt   time.Time       `json:"createdAt"`
	WorkspaceID int64           `json:"-"`
}

// ChatAudio is a voice message's recording, kept to play back, and where
// its transcript stands.
type ChatAudio struct {
	ContentType string `json:"contentType"`
	DurationMS  int64  `json:"durationMs"`
	Transcript  string `json:"transcript"` // pending, done, none (no words heard) or failed
	Error       string `json:"error,omitempty"`
}

// Where a voice message's transcript stands.
const (
	VoicePending = "pending"
	VoiceDone    = "done"
	VoiceNone    = "none"
	VoiceFailed  = "failed"
)

// Voice message limits: as long as a spoken question, the recording at
// most 3 MB (2 minutes of Opus is a fraction of that).
const (
	ChatMaxVoice      = 2 * time.Minute
	ChatMaxVoiceBytes = 3 << 20
)

// chatAudioTypes are the recordings browsers make, which they also play.
var chatAudioTypes = map[string]bool{"audio/webm": true, "audio/ogg": true, "audio/mp4": true, "audio/mpeg": true, "audio/aac": true, "audio/wav": true}

// ChatAudioType returns the bare media type of a recording ("audio/webm;
// codecs=opus" → "audio/webm") and whether chat keeps that kind.
func ChatAudioType(ct string) (string, bool) {
	t := strings.ToLower(strings.TrimSpace(strings.SplitN(ct, ";", 2)[0]))
	return t, chatAudioTypes[t]
}

// FromAgent reports whether agnts wrote the message (an answer, a note or
// a card).
func (m ChatMessage) FromAgent() bool { return m.Kind == ChatKindAgent || m.Kind == ChatKindCard }

// ChatAI is which model made a message or a ref, and what it took.
type ChatAI struct {
	Provider string  `json:"provider"`
	Model    string  `json:"model"`
	MS       int64   `json:"ms"`
	CostUSD  float64 `json:"costUsd"`
}

// Card types.
const (
	CardLogFinding  = "log_finding"
	CardReviewReady = "review_ready"
	CardPROpened    = "pr_opened"
	CardTicketDraft = "ticket_draft"
)

// Card states.
const (
	CardOpen    = "open"
	CardDone    = "done"
	CardFailed  = "failed"
	CardExpired = "expired" // the ticket moved on without the card
)

// Card actions.
const (
	CardFix            = "fix"     // log finding → ticket
	CardMute           = "mute"    // log finding
	CardApprove        = "approve" // review_ready → push and open the PR
	CardRequestChanges = "request_changes"
	CardMerge          = "merge"  // pr_opened
	CardCreate         = "create" // ticket_draft
	CardCreateAssign   = "create_assign"
)

// ChatCard is what an agent card shows and which buttons it has. The
// server builds it from domain data; a model never chooses its actions.
type ChatCard struct {
	Type    string         `json:"type"`
	State   string         `json:"state"`
	Title   string         `json:"title"`
	Summary string         `json:"summary,omitempty"`
	Actions []string       `json:"actions"`
	Data    map[string]any `json:"data,omitempty"`
	By      string         `json:"by,omitempty"`     // who pressed the button that settled it
	Done    string         `json:"done,omitempty"`   // which action settled it
	Result  string         `json:"result,omitempty"` // what happened, or why it failed
	At      *time.Time     `json:"at,omitempty"`
}

// Has reports whether the card offers action a.
func (c ChatCard) Has(a string) bool {
	for _, x := range c.Actions {
		if x == a {
			return true
		}
	}
	return false
}

// Ref types.
const (
	RefTicket  = "ticket"
	RefPR      = "pr"
	RefRepo    = "repo"
	RefFinding = "finding"
)

// Ref sources.
const (
	RefExplicit = "explicit"
	RefModel    = "model"
	RefCard     = "card"
	RefRemoved  = "removed"
)

// ChatRef links a message to a ticket, pull request, repository or log
// finding. A PR's id is "<repo>#<number>".
type ChatRef struct {
	Type       string  `json:"type"`
	ID         string  `json:"id"`
	Source     string  `json:"source"`
	Confidence float64 `json:"confidence"`
	Reason     string  `json:"reason,omitempty"`
	Label      string  `json:"label,omitempty"` // a title to show
	URL        string  `json:"url,omitempty"`
	AI         *ChatAI `json:"ai,omitempty"`
}

// Key is "type:id", the ref's id in citations.
func (r ChatRef) Key() string { return r.Type + ":" + r.ID }

// ChatSend is a person's new message.
// ChatSearchHit is a message a team chat search found, with its channel's
// name and the part of it that matched (SearchSnippet's marks).
type ChatSearchHit struct {
	Message ChatMessage `json:"message"`
	Channel string      `json:"channel"`
	Snippet string      `json:"snippet"`
}

type ChatSend struct {
	ChannelID   int64
	ClientMsgID string
	Body        string
	ReplyTo     *int64
	Files       []int64 // pending uploads of the sender's
}

var chatChannelRe = regexp.MustCompile(`^[a-z0-9][a-z0-9_-]{0,39}$`)

// ChatChannelName normalises a channel name ("#Payments Team" →
// "payments-team") and reports whether the result is valid.
func ChatChannelName(s string) (string, bool) {
	s = strings.ToLower(strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(s), "#")))
	s = strings.Join(strings.Fields(s), "-")
	return s, chatChannelRe.MatchString(s)
}

// ChatBodyOK reports whether a message body may be sent.
func ChatBodyOK(body string) bool {
	b := strings.TrimSpace(body)
	return b != "" && len(body) <= ChatMaxBody && utf8.ValidString(body)
}

var (
	mentionRe = regexp.MustCompile(`(?i)(^|[^\w@])@agnts\b`)
	prRe      = regexp.MustCompile(`(?:^|[\s(])#(\d{1,7})\b`)
	prURLRe   = regexp.MustCompile(`https?://[^\s/]+/([\w.-]+)/([\w.-]+)/(?:pull|-/merge_requests)/(\d+)`)
)

// MentionsAgent reports whether a message asks agnts (@agnts).
func MentionsAgent(body string) bool { return mentionRe.MatchString(body) }

// ExplicitRefs are the refs a message names itself: ticket keys that
// exist, pull request numbers and URLs, and repository names. isTicket
// and repos say what exists, so "UTF-8" is not a ticket.
func ExplicitRefs(body string, isTicket func(key string) bool, repos []string) []ChatRef {
	var out []ChatRef
	seen := map[string]bool{}
	add := func(r ChatRef) {
		if !seen[r.Key()] {
			seen[r.Key()] = true
			r.Source, r.Confidence = RefExplicit, 1
			out = append(out, r)
		}
	}
	for _, k := range TicketKeysIn(body) {
		if isTicket(k) {
			add(ChatRef{Type: RefTicket, ID: k})
		}
	}
	for _, m := range prURLRe.FindAllStringSubmatch(body, -1) {
		add(ChatRef{Type: RefPR, ID: m[2] + "#" + m[3], URL: m[0]})
	}
	if len(repos) == 1 { // "#142" is only clear with one repository
		for _, m := range prRe.FindAllStringSubmatch(body, -1) {
			add(ChatRef{Type: RefPR, ID: repos[0] + "#" + m[1]})
		}
	}
	lower := strings.ToLower(body)
	for _, r := range repos {
		if len(r) >= 3 && containsWord(lower, strings.ToLower(r)) {
			add(ChatRef{Type: RefRepo, ID: r})
		}
	}
	return out
}

// containsWord reports whether w occurs in s with no letter, digit or
// underscore on either side.
func containsWord(s, w string) bool {
	for i := 0; ; {
		j := strings.Index(s[i:], w)
		if j < 0 {
			return false
		}
		j += i
		before := j == 0 || !isWordByte(s[j-1])
		end := j + len(w)
		after := end == len(s) || !isWordByte(s[end])
		if before && after {
			return true
		}
		i = j + 1
	}
}

func isWordByte(b byte) bool {
	return b == '_' || b >= '0' && b <= '9' || b >= 'a' && b <= 'z' || b >= 'A' && b <= 'Z'
}

// ParseCitation splits "ticket:PAY-1", "msg:812", "pr:api#14", "repo:x",
// "finding:3" or "file:path:42" into its type and id.
func ParseCitation(s string) (typ, id string, ok bool) {
	s = strings.TrimSpace(strings.Trim(s, "[]"))
	i := strings.IndexByte(s, ':')
	if i <= 0 || i == len(s)-1 {
		return "", "", false
	}
	typ, id = s[:i], s[i+1:]
	switch typ {
	case "msg", "finding":
		_, err := strconv.ParseInt(id, 10, 64)
		return typ, id, err == nil
	case RefTicket, RefPR, RefRepo, "file":
		return typ, id, true
	}
	return "", "", false
}
