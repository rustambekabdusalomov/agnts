// Package chat is the team chat: workspace channels where members talk
// and agnts takes part. It posts cards when work needs a person (a log
// finding, a change ready for review, a pull request to merge) whose
// buttons run the real action, links messages to what they are about,
// turns messages into tickets, and answers @agnts from the workspace's
// memory. Model work never runs on the send path: a message is stored with
// its jobs (the outbox) and a worker does them after.
package chat

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"regexp"
	"slices"
	"strings"
	"sync"
	"time"

	"agnts/internal/actions"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Store is the chat's storage (postgres.Chat).
type Store interface {
	Channels(ctx context.Context, user int64) ([]domain.ChatChannel, error)
	Channel(ctx context.Context, id int64) (domain.ChatChannel, error)
	AgentChannel(ctx context.Context) (domain.ChatChannel, error)
	CreateChannel(ctx context.Context, name, topic string, agents bool, user int64) (domain.ChatChannel, error)
	UpdateChannel(ctx context.Context, id int64, topic *string, agents *bool, archive bool) (domain.ChatChannel, error)
	MarkRead(ctx context.Context, user, channel, last int64) error
	Messages(ctx context.Context, channel, before, after int64, limit int) ([]domain.ChatMessage, error)
	Message(ctx context.Context, id int64) (domain.ChatMessage, error)
	MessagesByID(ctx context.Context, ids []int64) ([]domain.ChatMessage, error)
	Search(ctx context.Context, words []string, channel int64, limit int) ([]domain.ChatMessage, []string, error)
	Send(ctx context.Context, user int64, in domain.ChatSend, jobs []string) (domain.ChatMessage, bool, error)
	CopyFilesToTicket(ctx context.Context, msg int64, key string) (int64, error)
	FileData(ctx context.Context, id int64) ([]byte, error)
	Post(ctx context.Context, m domain.ChatMessage) (domain.ChatMessage, error)
	Update(ctx context.Context, id int64, fn func(*domain.ChatMessage) error) (domain.ChatMessage, error)
	CardsOf(ctx context.Context, key string) ([]domain.ChatMessage, error)
	AddRefs(ctx context.Context, msg int64, refs []domain.ChatRef) (domain.ChatMessage, error)
	RemoveRef(ctx context.Context, msg int64, typ, id string) (domain.ChatMessage, error)
	AddJob(ctx context.Context, msg int64, kind string, user int64, data map[string]any) error
	TakeJob(ctx context.Context) (postgres.ChatJob, bool, error)
	FinishJob(ctx context.Context, j postgres.ChatJob, jobErr error, maxAttempts int) error
	RequeueStale(ctx context.Context, older time.Duration) error
	JobsToday(ctx context.Context, kind string) (int, error)
	// OpenPRWorkspaces are the workspaces with an open pull request card of
	// the last day (ctx: the system's).
	OpenPRWorkspaces(ctx context.Context) ([]int64, error)
	SendVoice(ctx context.Context, user int64, in domain.ChatSend, v postgres.ChatVoice) (domain.ChatMessage, bool, error)
	Voice(ctx context.Context, msg int64, wav bool) (string, []byte, error)
	SetTranscript(ctx context.Context, msg int64, text, state, why string, jobs []string, user int64) (domain.ChatMessage, error)
}

var _ Store = (*postgres.Chat)(nil)

// Events reads the event log after a cursor that survives restarts
// (postgres.Agent).
type Events interface {
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	MaxEventID(ctx context.Context) (int64, error)
	Cursor(ctx context.Context, name string) (int64, error)
	SetCursor(ctx context.Context, name string, id int64) error
}

// Tickets are the ticket reads and the merge the cards use (the
// orchestrator).
type Tickets interface {
	View(ctx context.Context, key string) (orchestrator.TicketView, error)
	MergeTicketPR(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
}

// Actions are agnts's checked writes, shared with the assistant and MCP
// (actions.Deps).
type Actions interface {
	Prepare(ctx context.Context, tool string, args json.RawMessage) (actions.Prepared, error)
	Execute(ctx context.Context, a postgres.PendingAction, origin domain.Origin) (actions.Result, error)
}

// Logs is the log watcher (logwatch.Service).
type Logs interface {
	Finding(ctx context.Context, id int64) (domain.LogFinding, error)
	Fix(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error)
	Mute(ctx context.Context, id int64, mute bool) (domain.LogFinding, error)
}

// Repos reads repositories (postgres.Agent).
type Repos interface {
	RepositoryByID(ctx context.Context, id int64) (domain.Repository, error)
}

// Checks says what CI reports about a commit (vcs.Multi).
type Checks interface {
	CommitChecks(ctx context.Context, repo domain.Repository, sha string) (string, []string, error)
}

// Live sends events that are not stored to everyone in a workspace (the
// SSE broker).
type Live interface {
	PublishWorkspace(ws int64, e domain.Event)
}

// Roles says a person's role in a workspace.
type Roles interface {
	Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
}

// Deps are what the chat uses. Logs, Checks, Live, Roles and Brain may be
// nil.
type Deps struct {
	Store   Store
	Memory  Memory
	Events  Events
	Tickets Tickets
	Actions Actions
	Logs    Logs
	Repos   Repos
	Checks  Checks
	Live    Live
	Roles   Roles
	// Brain does the model work (links, answers, drafts); nil turns it off
	// and only explicit links are made.
	Brain Brain
	Log   *slog.Logger
}

// Service is the team chat's use cases.
type Service struct {
	Deps
	wake chan struct{}

	mu   sync.Mutex
	busy map[int64]bool // cards whose button is running
}

// New returns the chat service; call Run for its background work.
func New(d Deps) *Service {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	return &Service{Deps: d, wake: make(chan struct{}, 1), busy: map[int64]bool{}}
}

// Errors the HTTP layer maps.
var (
	// ErrInvalid is a request the chat refuses as it is.
	ErrInvalid = errors.New("invalid")
	// ErrSettled is a card whose button was already pressed.
	ErrSettled = errors.New("settled")
	// ErrBusy is a card whose button is running now.
	ErrBusy = errors.New("busy")
	// ErrLimit is a daily cap reached.
	ErrLimit = errors.New("limit")
)

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// Wake tells the worker there may be new events or jobs.
func (s *Service) Wake() {
	select {
	case s.wake <- struct{}{}:
	default:
	}
}

// uniqueIDs drops repeated ids, keeping the first of each in place.
func uniqueIDs(ids []int64) []int64 {
	var out []int64
	for _, id := range ids {
		if !slices.Contains(out, id) {
			out = append(out, id)
		}
	}
	return out
}

func actor(ctx context.Context) (int64, string) {
	a, _ := domain.ActorOf(ctx)
	return a.UserID, a.Username
}

// ---------------------------------------------------------------------
// Channels and messages

// Channels lists the workspace's channels with the asker's unread counts.
func (s *Service) Channels(ctx context.Context) ([]domain.ChatChannel, error) {
	u, _ := actor(ctx)
	return s.Store.Channels(ctx, u)
}

// CreateChannel makes a channel.
func (s *Service) CreateChannel(ctx context.Context, name, topic string, agents bool) (domain.ChatChannel, error) {
	n, ok := domain.ChatChannelName(name)
	if !ok {
		return domain.ChatChannel{}, invalid("a channel name is 1 to 40 lower case letters, digits, - or _")
	}
	if len(topic) > 300 {
		return domain.ChatChannel{}, invalid("the topic is longer than 300 characters")
	}
	cs, err := s.Channels(ctx)
	if err != nil {
		return domain.ChatChannel{}, err
	}
	if len(cs) >= domain.ChatMaxChannels {
		return domain.ChatChannel{}, invalid("a workspace has at most %d channels", domain.ChatMaxChannels)
	}
	u, _ := actor(ctx)
	return s.Store.CreateChannel(ctx, n, strings.TrimSpace(topic), agents, u)
}

// UpdateChannel changes a channel's topic, makes it agnts's channel, or
// archives it (not agnts's own).
func (s *Service) UpdateChannel(ctx context.Context, id int64, topic *string, agents *bool, archive bool) (domain.ChatChannel, error) {
	c, err := s.Store.Channel(ctx, id)
	if err != nil {
		return c, err
	}
	if archive && c.Agents {
		return c, invalid("make another channel agnts's channel before archiving #%s", c.Name)
	}
	if topic != nil && len(*topic) > 300 {
		return c, invalid("the topic is longer than 300 characters")
	}
	return s.Store.UpdateChannel(ctx, id, topic, agents, archive)
}

// Messages pages a channel.
func (s *Service) Messages(ctx context.Context, channel, before, after int64, limit int) ([]domain.ChatMessage, error) {
	if _, err := s.Store.Channel(ctx, channel); err != nil {
		return nil, err
	}
	return s.Store.Messages(ctx, channel, before, after, limit)
}

var uuidRe = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)

// Send stores a person's message and queues the model work on it: links
// always, an answer when it asks @agnts. created is false for a resend of
// a stored message (the same client id), which queues nothing.
func (s *Service) Send(ctx context.Context, in domain.ChatSend) (domain.ChatMessage, bool, error) {
	if !uuidRe.MatchString(in.ClientMsgID) {
		return domain.ChatMessage{}, false, invalid("clientMsgId must be a UUID")
	}
	in.Files = uniqueIDs(in.Files)
	switch {
	case len(in.Files) > domain.MaxAttachments:
		return domain.ChatMessage{}, false, invalid("attach at most %d files", domain.MaxAttachments)
	case len(in.Files) > 0 && strings.TrimSpace(in.Body) == "":
		in.Body = "" // files alone are a message
	case !domain.ChatBodyOK(in.Body):
		return domain.ChatMessage{}, false, invalid("a message is 1 to %d bytes of text", domain.ChatMaxBody)
	}
	toAgent := false
	if in.ReplyTo != nil {
		p, err := s.Store.Message(ctx, *in.ReplyTo)
		if err != nil || p.ChannelID != in.ChannelID {
			return domain.ChatMessage{}, false, invalid("replyTo is not a message of this channel")
		}
		toAgent = p.FromAgent()
	}
	u, _ := actor(ctx)
	jobs := []string{postgres.ChatJobLink}
	// A reply to agnts's answer or card is said to agnts, as @agnts is.
	if domain.MentionsAgent(in.Body) || toAgent {
		jobs = append(jobs, postgres.ChatJobAnswer)
	}
	if strings.TrimSpace(in.Body) == "" {
		jobs = nil // nothing to link or answer in files alone
		if toAgent {
			jobs = []string{postgres.ChatJobAnswer}
		}
	}
	m, created, err := s.Store.Send(ctx, u, in, jobs)
	if errors.Is(err, domain.ErrConflict) {
		return m, false, invalid("a file is not a new upload of yours: upload it again")
	}
	if err == nil && created {
		s.Wake()
	}
	return m, created, err
}

// Search finds the messages holding every word of q (as a word's start, in
// their text or their files' names), newest first, in channel (0: all of
// them), each with the part that matched.
func (s *Service) Search(ctx context.Context, q string, channel int64) ([]domain.ChatSearchHit, error) {
	words := domain.SearchWords(q)
	if len(words) == 0 {
		return nil, invalid("search for a word of %d letters or more", domain.SearchMinRunes)
	}
	ms, names, err := s.Store.Search(ctx, words, channel, domain.SearchLimit)
	if err != nil {
		return nil, err
	}
	out := make([]domain.ChatSearchHit, len(ms))
	for i, m := range ms {
		text := m.Body
		if len(m.Files) > 0 {
			text = strings.TrimSpace(text + " 📎 " + fileNames(m.Files))
		}
		out[i] = domain.ChatSearchHit{Message: m, Channel: names[i], Snippet: domain.SearchSnippet(text, words, 160)}
	}
	return out, nil
}

// Message returns one message with its refs.
func (s *Service) Message(ctx context.Context, id int64) (domain.ChatMessage, error) {
	return s.Store.Message(ctx, id)
}

// VoiceInput is a voice message as the browser sends it: the recording to
// keep and play, and the same audio as WAV for Muse to hear.
type VoiceInput struct {
	ClientMsgID string
	ReplyTo     *int64
	ContentType string
	Data, WAV   []byte
	DurationMS  int64
}

// SendVoice stores a voice message and queues hearing it; its transcript
// becomes its text, links and @agnts then work on it as on typed ones.
func (s *Service) SendVoice(ctx context.Context, channel int64, in VoiceInput) (domain.ChatMessage, bool, error) {
	if !uuidRe.MatchString(in.ClientMsgID) {
		return domain.ChatMessage{}, false, invalid("clientMsgId must be a UUID")
	}
	ct, ok := domain.ChatAudioType(in.ContentType)
	switch {
	case !ok:
		return domain.ChatMessage{}, false, invalid("a voice message is WebM, Ogg, MP4, MP3, AAC or WAV audio")
	case len(in.Data) == 0:
		return domain.ChatMessage{}, false, invalid("the recording is empty")
	case len(in.Data) > domain.ChatMaxVoiceBytes || len(in.WAV) > domain.AssistantMaxVoiceBytes:
		return domain.ChatMessage{}, false, invalid("a voice message is at most %d minutes", int(domain.ChatMaxVoice.Minutes()))
	case in.DurationMS <= 0 || in.DurationMS > domain.ChatMaxVoice.Milliseconds()+2000:
		return domain.ChatMessage{}, false, invalid("a voice message is at most %d minutes", int(domain.ChatMaxVoice.Minutes()))
	}
	if in.ReplyTo != nil {
		if p, err := s.Store.Message(ctx, *in.ReplyTo); err != nil || p.ChannelID != channel {
			return domain.ChatMessage{}, false, invalid("replyTo is not a message of this channel")
		}
	}
	u, _ := actor(ctx)
	m, created, err := s.Store.SendVoice(ctx, u, domain.ChatSend{ChannelID: channel, ClientMsgID: in.ClientMsgID, ReplyTo: in.ReplyTo},
		postgres.ChatVoice{ContentType: ct, Data: in.Data, WAV: in.WAV, DurationMS: in.DurationMS})
	if err == nil && created {
		s.Wake()
	}
	return m, created, err
}

// Voice returns a voice message's recording to play.
func (s *Service) Voice(ctx context.Context, msg int64) (string, []byte, error) {
	if _, err := s.Store.Message(ctx, msg); err != nil {
		return "", nil, err
	}
	return s.Store.Voice(ctx, msg, false)
}

// MarkRead saves how far the asker has read a channel.
func (s *Service) MarkRead(ctx context.Context, channel, last int64) error {
	u, _ := actor(ctx)
	return s.Store.MarkRead(ctx, u, channel, last)
}

// RemoveRef removes a wrong link under a message.
func (s *Service) RemoveRef(ctx context.Context, msg int64, typ, id string) (domain.ChatMessage, error) {
	return s.Store.RemoveRef(ctx, msg, typ, id)
}

// ToTicket asks the model to draft a ticket from a message; the draft
// card arrives in the channel.
func (s *Service) ToTicket(ctx context.Context, msg int64) error {
	m, err := s.Store.Message(ctx, msg)
	if err != nil {
		return err
	}
	if m.Kind != domain.ChatKindText {
		return invalid("only a person's message can become a ticket")
	}
	if s.Brain == nil {
		return invalid("the team chat has no model on this server")
	}
	if n, err := s.Store.JobsToday(ctx, postgres.ChatJobTicket); err == nil && n >= dailyDrafts {
		return fmt.Errorf("%w: %d ticket drafts a day", ErrLimit, dailyDrafts)
	}
	u, _ := actor(ctx)
	if err := s.Store.AddJob(ctx, msg, postgres.ChatJobTicket, u, nil); err != nil {
		return err
	}
	s.Wake()
	return nil
}

// Stats is what the model did in the chat today.
func (s *Service) Stats(ctx context.Context) (postgres.ChatStats, error) {
	if s.Memory == nil {
		return postgres.ChatStats{}, nil
	}
	return s.Memory.Stats(ctx)
}

// Daily caps per workspace.
const (
	dailyLinks   = 500
	dailyAnswers = 200
	dailyCode    = 30
	dailyDrafts  = 100
)
