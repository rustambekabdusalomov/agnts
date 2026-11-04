package orchestrator

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"sync"
	"time"
	"unicode/utf8"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// Recorder keeps run history: one transcript per Claude Code or Codex
// invocation, for the Admin console.
type Recorder interface {
	// StartTranscript stores a running transcript with its prompt.
	StartTranscript(ctx context.Context, s domain.TranscriptStart) (int64, error)
	// AppendTranscript adds a gzip member to the body and updates the
	// running counts.
	AppendTranscript(ctx context.Context, id int64, chunk []byte, c domain.TranscriptCounts) error
	// FinishTranscript adds the last gzip member and closes the transcript.
	FinishTranscript(ctx context.Context, id int64, chunk []byte, end domain.TranscriptEnd) error
	// RecoverTranscripts closes transcripts a crash left running.
	RecoverTranscripts(ctx context.Context) (int, error)
	RunHistorySettings(ctx context.Context) (domain.RunHistorySettings, error)
}

// SetRecorder turns run history on.
func (o *Orchestrator) SetRecorder(r Recorder) { o.recorder = r }

// Flushing: a transcript's buffer goes to the database every flushBytes of
// input or flushEvery, whichever comes first, so a crash loses at most the
// last stretch of a long run.
const (
	flushBytes = 256 << 10
	flushEvery = time.Minute
	// recordTimeout bounds one database write of the recorder; a slow
	// database must not hold up the stream.
	recordTimeout = 10 * time.Second
)

// transcriptMeta says where an invocation comes from.
type transcriptMeta struct {
	Purpose domain.TranscriptPurpose
	// WorkspaceID is the workspace; 0 takes the one ctx acts in, then the
	// run's ticket's.
	WorkspaceID int64
	Run         *domain.Run // nil outside a ticket's stages
	TicketKey   string
	Subject     string // what a background call is about
	ModelStage  string
	// DocumentRunID is the document generation a call is charged to.
	DocumentRunID int64
	// ScoreRunID is the performance review score a call is charged to.
	ScoreRunID int64
	// Person is whose modules and account a call outside a scheduled run
	// uses; 0: the person acting in ctx.
	Person int64
	// Route is where the call runs, when the caller routed it first.
	Route *ai.Route
}

// stageName names a model stage in messages.
func stageName(modelStage string) string {
	switch modelStage {
	case domain.ModelAnalyze:
		return "analysis"
	case domain.ModelRetry:
		return "the fix"
	case "second_opinion":
		return "the second opinion"
	}
	return "the " + modelStage + " stage"
}

// modelName names a stored model in messages: "Muse Wonder", "Claude
// opus", "Codex gpt-5".
func modelName(model string) string {
	ref, _ := ai.ParseModel(model)
	name := ref.Name
	if ref.Provider == ai.Muse && len(name) > 0 {
		name = strings.ToUpper(name[:1]) + name[1:]
	}
	return ai.ModuleName(ref.Provider) + " " + name
}

// whoFor is who a call of m is for, outside an admitted run: m's person,
// else the person acting in ctx (their modules when ctx carries them).
func (o *Orchestrator) whoFor(ctx context.Context, m transcriptMeta) ai.Who {
	w := ai.Who{Workspace: m.WorkspaceID, Person: m.Person}
	if w.Workspace == 0 {
		w.Workspace = domain.WorkspaceOf(ctx)
	}
	if w.Person == 0 {
		if a, ok := domain.ActorOf(ctx); ok {
			w.Person = a.UserID
		}
	}
	if a, ok := domain.AccessIn(ctx); ok {
		w.Access = &a
	}
	return w
}

// hold says why a call of m on model cannot run now (callClaude would
// refuse it), before the work for it is prepared; nil when it can.
func (o *Orchestrator) hold(ctx context.Context, m transcriptMeta, model string) error {
	if _, h := o.ai.RouteCall(ctx, ai.Call{Who: o.whoFor(ctx, m), Purpose: m.Purpose, Req: ai.Request{Model: model}}); h != nil {
		return h
	}
	return nil
}

// callClaude runs one agent invocation through the AI gateway and records
// its transcript. Every invocation of the orchestrator goes through here;
// recording problems are logged and never fail the run.
func (o *Orchestrator) callClaude(ctx context.Context, ws Workspace, m transcriptMeta, req ai.Request, onEvent func(ai.Event)) (ai.Result, error) {
	// Where it runs: the run's route for its model's module, else routed
	// now for its person.
	call := ai.Call{Who: o.whoFor(ctx, m), Purpose: m.Purpose, Box: ws, Req: req, ModelStage: m.ModelStage, DocumentRunID: m.DocumentRunID, ScoreRunID: m.ScoreRunID}
	var route ai.Route
	if m.Route != nil {
		route = *m.Route // the caller routed it to build the request
	} else {
		var hold *ai.Hold
		if route, hold = o.ai.RouteCall(ctx, call); hold != nil {
			return ai.Result{}, hold
		}
	}
	call.Route = &route
	if route.Model != "" {
		req.Model = route.Model
	}
	req = o.fitPrompt(ctx, ws, m, req)
	if m.Run != nil && req.RunID == 0 {
		req.RunID = m.Run.ID
	}
	if req.WorkspaceID == 0 {
		req.WorkspaceID = m.WorkspaceID
	}
	call.Req = req
	if m.Run != nil {
		call.RunID = m.Run.ID // a ticket run's calls are charged to it
	}
	if rec := o.record(ctx, m, req, route); rec != nil {
		call.Record = rec
	}
	return o.ai.Run(ctx, call, onEvent)
}

// recording keeps one invocation's transcript (ai.Recording).
type recording struct {
	o            *Orchestrator
	ctx          context.Context
	m            transcriptMeta
	tw           *transcriptWriter
	id           int64
	stallsBefore int
}

// record starts the transcript of an invocation; nil when run history is
// off or it cannot be stored.
func (o *Orchestrator) record(ctx context.Context, m transcriptMeta, req ai.Request, route ai.Route) *recording {
	if o.recorder == nil {
		return nil
	}
	tw, id := o.startTranscript(ctx, m, req, route.Account)
	if tw == nil {
		return nil
	}
	r := &recording{o: o, ctx: ctx, m: m, tw: tw, id: id}
	if m.Run != nil {
		r.stallsBefore = len(m.Run.Harness.Stalls)
		o.transcripts.Store(m.Run.ID, tw)
	}
	return r
}

// Event implements ai.Recording.
func (r *recording) Event(e ai.Event) {
	r.tw.event(e)
	if r.tw.due(time.Now()) {
		r.o.flushTranscript(r.ctx, r.id, r.tw)
	}
}

// Finish implements ai.Recording.
func (r *recording) Finish(ctx context.Context, res ai.Result, err error) int64 {
	if r.m.Run != nil {
		r.o.transcripts.Delete(r.m.Run.ID)
	}
	end := transcriptEnd(ctx, res, err)
	if r.m.Run != nil {
		end.Stalls = len(r.m.Run.Harness.Stalls) - r.stallsBefore
	}
	chunk, counts := r.tw.take()
	end.Counts = counts
	wctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), recordTimeout)
	defer cancel()
	if ferr := r.o.recorder.FinishTranscript(wctx, r.id, chunk, end); ferr != nil {
		r.o.log.Error("finish transcript", "transcript", r.id, "err", ferr)
		return 0
	}
	return r.id
}

// startTranscript stores the running transcript; nil when it cannot be.
func (o *Orchestrator) startTranscript(ctx context.Context, m transcriptMeta, req ai.Request, acct domain.ClaudeAccount) (*transcriptWriter, int64) {
	wsID := m.WorkspaceID
	if wsID == 0 {
		wsID = domain.WorkspaceOf(ctx)
	}
	if wsID == 0 {
		o.log.Error("transcript without a workspace: not recorded", "purpose", m.Purpose, "ticket", m.TicketKey)
		return nil, 0
	}
	wctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), recordTimeout)
	defer cancel()
	lim, err := o.recorder.RunHistorySettings(wctx)
	if err != nil {
		lim = domain.DefaultRunHistory
	}
	var redact *domain.Redactor
	if m.Run != nil {
		if r, ok := o.redactors.Load(m.Run.ID); ok {
			rr := r.(domain.Redactor)
			redact = &rr
		}
	}
	tw := newTranscriptWriter(lim.Normalize(), redact)
	s := domain.TranscriptStart{
		WorkspaceID: wsID, TicketKey: m.TicketKey, Subject: m.Subject, Purpose: m.Purpose, ModelStage: m.ModelStage,
		Engine: "claude", Model: req.Model, Prompt: gzipBytes([]byte(tw.mask(req.Prompt))),
	}
	if domain.IsCodex(req.Model) {
		s.Engine = "codex"
	}
	if domain.IsMuse(req.Model) {
		s.Engine = "muse"
	}
	if m.Run != nil {
		s.RunID = &m.Run.ID
	}
	if s.Engine == "claude" {
		if acct.ConnectionID > 0 {
			s.ConnectionID = &acct.ConnectionID
		}
		s.ClaudeLabel = acct.Label
	}
	id, err := o.recorder.StartTranscript(wctx, s)
	if err != nil {
		o.log.Error("start transcript", "purpose", m.Purpose, "ticket", m.TicketKey, "err", err)
		return nil, 0
	}
	return tw, id
}

func (o *Orchestrator) flushTranscript(ctx context.Context, id int64, tw *transcriptWriter) {
	chunk, counts := tw.take()
	if len(chunk) == 0 {
		return
	}
	wctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), recordTimeout)
	defer cancel()
	if err := o.recorder.AppendTranscript(wctx, id, chunk, counts); err != nil {
		o.log.Warn("append transcript", "transcript", id, "err", err)
	}
}

// noteTranscript adds an agnts-side marker (a stall) to the transcript a
// run is recording, if any.
func (o *Orchestrator) noteTranscript(runID int64, text string) {
	if tw, ok := o.transcripts.Load(runID); ok {
		tw.(*transcriptWriter).note(text)
	}
}

// transcriptEnd says how an invocation ended.
func transcriptEnd(ctx context.Context, res ai.Result, err error) domain.TranscriptEnd {
	end := domain.TranscriptEnd{Status: domain.TranscriptDone, ExitReason: res.Subtype, SessionID: res.SessionID,
		Model: res.Model, Turns: res.Turns, Usage: res.Usage}
	var oom *OOMError
	switch {
	case errors.As(err, &oom):
		end.Status, end.ExitReason = domain.TranscriptOOM, err.Error()
	case err != nil && errors.Is(ctx.Err(), context.DeadlineExceeded), err != nil && strings.Contains(err.Error(), "timed out after"):
		end.Status, end.ExitReason = domain.TranscriptTimeout, err.Error()
	case err != nil && ctx.Err() != nil:
		end.Status, end.ExitReason = domain.TranscriptCancelled, "stopped"
	case err != nil:
		end.Status, end.ExitReason = domain.TranscriptError, err.Error()
	case res.RateLimited:
		end.Status, end.ExitReason = domain.TranscriptError, "rate_limited"
	case res.IsError:
		end.Status = domain.TranscriptError
	}
	end.ExitReason = truncate(end.ExitReason, 500)
	return end
}

// transcriptWriter turns an invocation's events into gzipped JSONL lines,
// masked and within the limits. Lines are gzipped as they come; take
// closes the gzip member, so the stored body is a series of members,
// which reads back as one gzip stream.
type transcriptWriter struct {
	mu     sync.Mutex
	lim    domain.RunHistorySettings
	redact *domain.Redactor
	start  time.Time

	buf      bytes.Buffer
	gz       *gzip.Writer
	pending  int // input bytes since the last take
	lastTake time.Time
	counts   domain.TranscriptCounts
}

func newTranscriptWriter(lim domain.RunHistorySettings, redact *domain.Redactor) *transcriptWriter {
	now := time.Now()
	return &transcriptWriter{lim: lim, redact: redact, start: now, lastTake: now}
}

// mask removes credentials from text: the run's own (a Swagger test's)
// and anything shaped like one.
func (w *transcriptWriter) mask(s string) string {
	if w.redact != nil {
		s = w.redact.String(s)
	}
	return domain.MaskCredentials(s)
}

// event records one stream event.
func (w *transcriptWriter) event(e ai.Event) {
	line := map[string]any{}
	toolOut, text := w.lim.ToolOutputKB<<10, w.lim.TextKB<<10
	switch e.Kind {
	case ai.EventInit:
		line["k"] = "init"
		line["session_id"], line["model"] = e.Data["session_id"], e.Data["model"]
	case ai.EventText:
		line["k"] = "text"
		line["text"], line["cut"] = cutMiddle(e.Text, text)
	case ai.EventTool:
		w.mu.Lock()
		w.counts.ToolCalls++
		w.mu.Unlock()
		line["k"] = "tool"
		line["id"], line["name"], line["summary"] = e.Data["id"], e.Data["tool"], e.Tool
		if in := toolInput(e.Data["input"]); in != "" {
			if len(in) > text {
				line["input"], line["cut"] = cutMiddle(in, text) // too big to keep as JSON
			} else {
				line["input"] = json.RawMessage(in)
			}
		}
	case ai.EventToolResult:
		failed, _ := e.Data["is_error"].(bool)
		if failed {
			w.mu.Lock()
			w.counts.ToolErrors++
			w.mu.Unlock()
		}
		line["k"] = "tool_result"
		line["id"], line["error"] = e.Data["id"], failed
		if code, ok := e.Data["exit_code"]; ok {
			line["exit_code"] = code
		}
		out, _ := e.Data["output"].(string)
		line["output"], line["cut"] = cutMiddle(out, toolOut)
	case ai.EventRateLimit:
		line["k"] = "rate_limit"
		line["status"] = rateStatus(e.Data)
	case ai.EventResult:
		line["k"] = "result"
		line["subtype"], line["error"], line["turns"] = e.Data["subtype"], e.Data["is_error"], e.Data["num_turns"]
		if c, ok := e.Data["total_cost_usd"]; ok {
			line["cost"] = c
		}
		line["text"], line["cut"] = cutMiddle(e.Text, text)
	default:
		return
	}
	w.write(line)
}

// note records an agnts-side marker.
func (w *transcriptWriter) note(text string) {
	w.write(map[string]any{"k": "note", "text": text})
}

// write appends one line. Past the transcript cap only tool calls (without
// input) and the result are kept, and the transcript is marked truncated.
func (w *transcriptWriter) write(line map[string]any) {
	if c, ok := line["cut"].(int); ok && c == 0 {
		delete(line, "cut")
	}
	w.mu.Lock()
	defer w.mu.Unlock()
	line["t"] = time.Since(w.start).Milliseconds()
	if w.counts.RawBytes >= w.lim.TranscriptMB<<20 {
		switch line["k"] {
		case "tool":
			delete(line, "input")
		case "result":
		default:
			w.counts.Truncated = true
			return
		}
		w.counts.Truncated = true
	}
	b, err := json.Marshal(line)
	if err != nil {
		return
	}
	b = append([]byte(w.mask(string(b))), '\n')
	if w.gz == nil {
		w.gz = gzip.NewWriter(&w.buf)
	}
	_, _ = w.gz.Write(b)
	w.pending += len(b)
	w.counts.RawBytes += len(b)
}

// due reports whether the buffer should go to the database now.
func (w *transcriptWriter) due(now time.Time) bool {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.pending >= flushBytes || (w.pending > 0 && now.Sub(w.lastTake) >= flushEvery)
}

// take closes the current gzip member and returns it with the counts so
// far; the chunk is empty when nothing was written since the last take.
func (w *transcriptWriter) take() ([]byte, domain.TranscriptCounts) {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.lastTake = time.Now()
	if w.gz == nil {
		return nil, w.counts
	}
	_ = w.gz.Close()
	chunk := bytes.Clone(w.buf.Bytes())
	w.buf.Reset()
	w.gz, w.pending = nil, 0
	return chunk, w.counts
}

// toolInput is a tool call's input as JSON text.
func toolInput(v any) string {
	switch x := v.(type) {
	case nil:
		return ""
	case json.RawMessage:
		return string(x)
	case []byte:
		return string(x)
	case string:
		return x
	default:
		b, _ := json.Marshal(x)
		return string(b)
	}
}

// cutMiddle keeps s within max bytes: its first three quarters and its
// last quarter, since an error is often at the end. cut is the original
// length when s was shortened, else 0.
func cutMiddle(s string, max int) (string, int) {
	if len(s) <= max || max <= 0 {
		return s, 0
	}
	head, tail := max*3/4, max/4
	h, t := s[:head], s[len(s)-tail:]
	for len(h) > 0 && !utf8.ValidString(h) {
		h = h[:len(h)-1]
	}
	for len(t) > 0 && !utf8.ValidString(t) {
		t = t[1:]
	}
	return h + "\n… [" + humanBytes(len(s)-len(h)-len(t)) + " cut] …\n" + t, len(s)
}

func humanBytes(n int) string {
	switch {
	case n >= 1<<20:
		return strconv.FormatFloat(float64(n)/(1<<20), 'f', 1, 64) + " MB"
	case n >= 1<<10:
		return strconv.FormatFloat(float64(n)/(1<<10), 'f', 1, 64) + " KB"
	}
	return strconv.Itoa(n) + " B"
}

func gzipBytes(b []byte) []byte {
	var buf bytes.Buffer
	zw := gzip.NewWriter(&buf)
	_, _ = zw.Write(b)
	_ = zw.Close()
	return buf.Bytes()
}

// Prompts travel as one command-line argument, which Linux caps at 128 KiB
// (MAX_ARG_STRLEN). A prompt near that size goes into a file the run reads
// first.
const (
	maxArgPrompt = 96 << 10
	// PromptPath is where a run finds a prompt too long for the command line.
	PromptPath = ContextDir + "/prompt.md"
)

// fitPrompt moves a prompt too long for the command line into PromptPath.
func (o *Orchestrator) fitPrompt(ctx context.Context, ws Workspace, m transcriptMeta, req ai.Request) ai.Request {
	if len(req.Prompt) <= maxArgPrompt {
		return req
	}
	if err := ws.WriteFile(ctx, PromptPath, []byte(req.Prompt)); err != nil {
		o.log.Warn("write a long prompt to a file", "ticket", m.TicketKey, "err", err)
		return req
	}
	if m.TicketKey != "" {
		o.event(ctx, domain.Event{TicketKey: m.TicketKey, Level: domain.LevelWarn, Type: domain.EventClaudeText,
			Message: fmt.Sprintf("the prompt is %d KB, too long for the command line: the run reads it from %s (fewer or shorter team rules keep it small)", len(req.Prompt)>>10, PromptPath)})
	}
	req.Prompt = "Your full instructions are in " + PromptPath + ". Read the whole file first (it is long: read it in parts if you must), then follow it exactly as if it were this message."
	return req
}
