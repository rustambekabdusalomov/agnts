package orchestrator

import (
	"cmp"
	"context"
	"fmt"
	"slices"
	"sync"
	"time"

	"agnts/internal/domain"
)

// QueueClass is the kind of run a ticket waits for.
type QueueClass string

// Queue classes, in the order the scheduler serves them inside a
// workspace: rule reviews (short, someone waits on them), the ticket's
// own stages, repository surveys, then the side runs.
const (
	ClassRule    QueueClass = "rule"
	ClassMain    QueueClass = "main"
	ClassBrief   QueueClass = "brief"
	ClassReview  QueueClass = "review"
	ClassPreview QueueClass = "preview"
	ClassLearn   QueueClass = "learn"
	ClassReflect QueueClass = "reflect"
)

func (c QueueClass) rank() int {
	return map[QueueClass]int{ClassRule: 0, ClassMain: 1, ClassBrief: 2, ClassReview: 3, ClassPreview: 4, ClassLearn: 5, ClassReflect: 6}[c]
}

// QueueItem is a ticket waiting for a run.
type QueueItem struct {
	TicketID    int64
	WorkspaceID int64
	Key         string
	State       domain.TicketState
	Kind        domain.TicketKind
	Class       QueueClass
	// Held tickets wait until someone starts them; Blocked ones wait for
	// related tickets (dependencies, conflicts).
	Held, Blocked bool
	Priority      int // higher first
	Unblocks      int // open tickets waiting for this one
	UpdatedAt     time.Time
	QueuedAt      *time.Time
	WaitReason    domain.WaitReason
	WaitMessage   string
	MemberID      *int64
	RepoID        *int64
	MemoryMB      int // the repository's memory setting (0: default)
}

// since is when the item started waiting, for fairness and starvation.
func (q QueueItem) since() time.Time {
	if q.QueuedAt != nil {
		return *q.QueuedAt
	}
	return q.UpdatedAt
}

// WaitChange is a new wait reason for a ticket.
type WaitChange struct {
	TicketID    int64
	WorkspaceID int64
	Key         string
	Reason      domain.WaitReason
	Message     string
	// Announce writes an event to the ticket's history (only when the
	// reason itself changed, not just its wording).
	Announce bool
}

// Queue is what the scheduler needs from the store on top of Store.
type Queue interface {
	// QueueItems returns every ticket waiting for a run, across every
	// workspace the context sees.
	QueueItems(ctx context.Context) ([]QueueItem, error)
	// ClaimTicket starts the run of class one ticket waits for; ok is false
	// when it no longer waits or another worker took it.
	ClaimTicket(ctx context.Context, ticketID int64, class QueueClass) (domain.Ticket, domain.Run, bool, error)
	// SetWaitReasons records the reasons that changed.
	SetWaitReasons(ctx context.Context, changes []WaitChange) error
}

// Workspaces gives the scheduler each workspace's plan and choices.
type Workspaces interface {
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
	Active(ctx context.Context) ([]int64, error)
}

// ClaudeAccounts picks the Claude account each run uses.
type ClaudeAccounts interface {
	// Pick returns the account a run of a ticket of member (nil: the
	// workspace's default member) in w uses now. ok is false when none is
	// usable: why says so for the ticket, until when it may be (zero when
	// unknown).
	Pick(ctx context.Context, w domain.Workspace, member *int64) (acct domain.ClaudeAccount, ok bool, why string, until time.Time)
}

// Credits charges runs that ran on agnts's API key to their workspace.
type Credits interface {
	// Within reports whether a run on credits may go on (what it spent is
	// under the run cap and the balance), and why not.
	Within(ctx context.Context, ws, runID int64) (bool, string)
	// Settle charges a finished run's cost, once.
	Settle(ctx context.Context, ws, runID int64, key string) error
}

// RunAccounts records which Claude account a run used.
type RunAccounts interface {
	SetRunAccount(ctx context.Context, runID int64, connection *int64, credits bool) error
}

// Capacity is the server's room for run containers.
type Capacity interface {
	// RunMemory is the memory limit a run gets for a repository memory
	// setting (0: the default).
	RunMemory(repoMB int) int64
	// Reserve takes mb of the run memory budget. ok is false when the
	// server has no room: why says what is short.
	Reserve(mb int64) (release func(), ok bool, why string)
	// Spare reports whether mb fits with as much again left over (side
	// runs that nobody waits for only take spare room).
	Spare(mb int64) bool
	Status() CapacityStatus
}

// CapacityStatus is the server's room as the queue page shows it.
type CapacityStatus struct {
	BudgetMB   int64
	ReservedMB int64
	Runs       int
	DiskFreeMB int64 // -1 when unknown
	Full       bool  // the last reservation that failed, since the last success
}

// starveAfter is how long a run that does not fit may wait before smaller
// runs stop being admitted ahead of it.
const starveAfter = 10 * time.Minute

// wsCacheTTL is how long the scheduler trusts a workspace's row.
const wsCacheTTL = 15 * time.Second

type wsEntry struct {
	w  domain.Workspace
	at time.Time
}

// schedState is the scheduler's memory between ticks.
type schedState struct {
	mu        sync.Mutex
	running   map[int64]int       // workspace -> runs in progress
	lastStart map[int64]time.Time // workspace -> when its last run started
	runs      map[int64]runInfo   // run id -> what runs
	stageAvg  map[domain.Stage]time.Duration
	wsCache   map[int64]wsEntry
	// serverQueue lists the main runs waiting for the server, first first.
	serverQueue []domain.TicketRef
}

type runInfo struct {
	ws      int64
	key     string
	stage   domain.Stage
	started time.Time
}

func newSchedState() *schedState {
	return &schedState{running: map[int64]int{}, lastStart: map[int64]time.Time{}, runs: map[int64]runInfo{},
		stageAvg: map[domain.Stage]time.Duration{}, wsCache: map[int64]wsEntry{}}
}

// workspace returns a workspace's row, cached briefly.
func (o *Orchestrator) workspace(ctx context.Context, id int64) (domain.Workspace, error) {
	o.sched.mu.Lock()
	e, ok := o.sched.wsCache[id]
	o.sched.mu.Unlock()
	if ok && time.Since(e.at) < wsCacheTTL {
		return e.w, nil
	}
	if o.workspaces == nil {
		return domain.Workspace{ID: id, Slots: 0, ClaudeMode: domain.ClaudeShared}, nil
	}
	w, err := o.workspaces.ByID(ctx, id)
	if err != nil {
		return w, err
	}
	o.sched.mu.Lock()
	o.sched.wsCache[id] = wsEntry{w: w, at: time.Now()}
	o.sched.mu.Unlock()
	return w, nil
}

// ForgetWorkspace drops a workspace's cached row (its plan or Claude
// choices changed).
func (o *Orchestrator) ForgetWorkspace(id int64) {
	o.sched.mu.Lock()
	delete(o.sched.wsCache, id)
	o.sched.mu.Unlock()
	o.Wake()
}

// wsQueue is one workspace's waiting runs during a tick.
type wsQueue struct {
	w       domain.Workspace
	ctx     context.Context
	s       domain.Settings
	items   []QueueItem
	next    int
	running int
	slots   int
	// accounts caches the account pick per member this tick.
	accounts map[int64]accountPick
}

type accountPick struct {
	acct  domain.ClaudeAccount
	ok    bool
	why   string
	until time.Time
}

func (q *wsQueue) full() bool { return q.running >= q.slots }

// slotsOf is how many runs a workspace may have at once: its plan's
// slots; an install without workspaces rows uses Settings.Parallel.
func slotsOf(w domain.Workspace, s domain.Settings) int {
	if w.Slots > 0 {
		return w.Slots
	}
	return max(1, s.Parallel)
}

// tick starts every run that may start now and records why the others
// wait. start runs a claimed job in the background.
func (o *Orchestrator) tick(ctx context.Context, start func(job scheduled)) {
	sys := domain.System(ctx)
	items, err := o.queue.QueueItems(sys)
	if err != nil {
		if ctx.Err() == nil {
			o.log.Error("read the queue", "err", err)
		}
		return
	}
	var ruleWS []int64
	if o.rules != nil {
		if ruleWS, err = o.rules.PendingRuleWorkspaces(sys); err != nil && ctx.Err() == nil {
			o.log.Warn("read pending rule reviews", "err", err)
		}
	}

	var briefWS []int64
	if o.briefs != nil {
		if briefWS, err = o.briefs.PendingBriefWorkspaces(sys); err != nil && ctx.Err() == nil {
			o.log.Warn("read pending surveys", "err", err)
		}
	}

	var reflectWS []int64
	if o.reflections != nil {
		if reflectWS, err = o.reflections.PendingReflectionWorkspaces(sys); err != nil && ctx.Err() == nil {
			o.log.Warn("read pending reflect runs", "err", err)
		}
	}

	queues := map[int64]*wsQueue{}
	get := func(id int64) *wsQueue {
		if q, ok := queues[id]; ok {
			return q
		}
		w, err := o.workspace(sys, id)
		if err != nil || w.DeletedAt != nil || w.SuspendedAt != nil {
			queues[id] = nil
			return nil
		}
		wctx := domain.WithWorkspace(ctx, id)
		s, err := o.settings.Get(wctx)
		if err != nil {
			o.log.Warn("load settings", "workspace", id, "err", err)
			queues[id] = nil
			return nil
		}
		o.sched.mu.Lock()
		running := o.sched.running[id]
		o.sched.mu.Unlock()
		q := &wsQueue{w: w, ctx: wctx, s: s, running: running, slots: slotsOf(w, s), accounts: map[int64]accountPick{}}
		queues[id] = q
		return q
	}
	for _, id := range ruleWS {
		if q := get(id); q != nil {
			q.items = append(q.items, QueueItem{WorkspaceID: id, Class: ClassRule})
		}
	}
	for _, id := range briefWS {
		if q := get(id); q != nil {
			q.items = append(q.items, QueueItem{WorkspaceID: id, Class: ClassBrief})
		}
	}
	for _, id := range reflectWS {
		if q := get(id); q != nil {
			q.items = append(q.items, QueueItem{WorkspaceID: id, Class: ClassReflect})
		}
	}
	for _, it := range items {
		if q := get(it.WorkspaceID); q != nil {
			q.items = append(q.items, it)
		}
	}
	for _, q := range queues {
		if q == nil {
			continue
		}
		slices.SortStableFunc(q.items, func(a, b QueueItem) int {
			return cmp.Or(cmp.Compare(a.Class.rank(), b.Class.rank()), cmp.Compare(b.Priority, a.Priority),
				cmp.Compare(b.Unblocks, a.Unblocks), a.UpdatedAt.Compare(b.UpdatedAt))
		})
	}

	changes := map[int64]WaitChange{}
	wait := func(it QueueItem, r domain.WaitReason, msg string) {
		if it.Class != ClassMain || it.TicketID == 0 {
			return
		}
		if _, done := changes[it.TicketID]; done {
			return
		}
		changes[it.TicketID] = WaitChange{TicketID: it.TicketID, WorkspaceID: it.WorkspaceID, Key: it.Key, Reason: r, Message: msg}
	}
	var serverWaits []QueueItem
	stop := false // a run that waited too long for room holds smaller ones back

	for !stop && ctx.Err() == nil {
		// Fair between workspaces: the one using the smallest share of its
		// slots goes first, the one that started least recently among equals.
		var order []*wsQueue
		for _, q := range queues {
			if q != nil && !q.full() && q.next < len(q.items) {
				order = append(order, q)
			}
		}
		if len(order) == 0 {
			break
		}
		o.sched.mu.Lock()
		slices.SortFunc(order, func(a, b *wsQueue) int {
			ra, rb := float64(a.running)/float64(a.slots), float64(b.running)/float64(b.slots)
			return cmp.Or(cmp.Compare(ra, rb), o.sched.lastStart[a.w.ID].Compare(o.sched.lastStart[b.w.ID]), cmp.Compare(a.w.ID, b.w.ID))
		})
		o.sched.mu.Unlock()

		progressed := false
	workspaces:
		for _, q := range order {
			for q.next < len(q.items) {
				it := q.items[q.next]
				q.next++
				if it.Class == ClassMain && it.Held {
					wait(it, domain.WaitBlocked, "held until someone starts it")
					continue
				}
				if it.Class == ClassMain && it.Blocked {
					wait(it, domain.WaitBlocked, "waiting for related tickets to land")
					continue
				}
				pick := o.pickAccount(q, it)
				if !pick.ok {
					wait(it, domain.WaitClaude, pick.why)
					continue
				}
				mem := int64(0)
				var release func()
				if o.capacity != nil {
					mem = o.capacity.RunMemory(it.MemoryMB)
					if (it.Class == ClassLearn || it.Class == ClassReflect) && !o.capacity.Spare(mem) {
						continue // learn and reflect runs only take spare room
					}
					rel, fits, why := o.capacity.Reserve(mem)
					if !fits {
						if it.Class == ClassMain {
							serverWaits = append(serverWaits, it)
							wait(it, domain.WaitServer, "waiting for the server: "+why)
						}
						if time.Since(it.since()) > starveAfter && it.Class == ClassMain {
							stop = true
							break workspaces
						}
						continue
					}
					release = rel
				}
				job, ok := o.claimItem(sys, it)
				if !ok {
					if release != nil {
						release()
					}
					continue
				}
				job.release, job.acct, job.hasAcct = release, pick.acct, o.accounts != nil
				q.running++
				o.sched.mu.Lock()
				o.sched.running[q.w.ID]++
				o.sched.lastStart[q.w.ID] = time.Now()
				o.sched.mu.Unlock()
				start(job)
				progressed = true
				continue workspaces // one run per workspace per round
			}
		}
		if !progressed {
			break
		}
	}

	// What was not reached waits for a slot, or for the server when a run
	// that waited too long holds the rest back.
	for _, q := range queues {
		if q == nil {
			continue
		}
		for _, it := range q.items[q.next:] {
			switch {
			case it.Class != ClassMain:
			case it.Held:
				wait(it, domain.WaitBlocked, "held until someone starts it")
			case it.Blocked:
				wait(it, domain.WaitBlocked, "waiting for related tickets to land")
			case stop:
				serverWaits = append(serverWaits, it)
				wait(it, domain.WaitServer, "waiting for the server: a larger run that waited longer goes first")
			case q.full():
				wait(it, domain.WaitSlots, fmt.Sprintf("waiting for a free slot (%d of %d in use)", q.running, q.slots))
			}
		}
	}

	slices.SortStableFunc(serverWaits, func(a, b QueueItem) int { return a.since().Compare(b.since()) })
	sq := make([]domain.TicketRef, 0, len(serverWaits))
	for _, it := range serverWaits {
		sq = append(sq, domain.TicketRef{WorkspaceID: it.WorkspaceID, Key: it.Key})
	}
	o.sched.mu.Lock()
	o.sched.serverQueue = sq
	o.sched.mu.Unlock()

	var out []WaitChange
	for _, it := range items {
		c, ok := changes[it.TicketID]
		if it.Class != ClassMain {
			continue
		}
		if !ok {
			c = WaitChange{TicketID: it.TicketID, WorkspaceID: it.WorkspaceID, Key: it.Key, Reason: domain.WaitNone}
		}
		if c.Reason != it.WaitReason || c.Message != it.WaitMessage {
			c.Announce = c.Reason != it.WaitReason
			out = append(out, c)
		}
	}
	if err := o.queue.SetWaitReasons(sys, out); err != nil && ctx.Err() == nil {
		o.log.Warn("record wait reasons", "err", err)
	}
}

// Tick starts what may start now, as one turn of Run does, and waits for
// those runs to end. It returns how many started.
func (o *Orchestrator) Tick(ctx context.Context) int {
	var wg sync.WaitGroup
	n := 0
	o.tick(ctx, func(j scheduled) {
		n++
		wg.Add(1)
		go func() {
			defer wg.Done()
			o.runScheduled(ctx, j)
		}()
	})
	wg.Wait()
	return n
}

// pickAccount returns the Claude account a run of it would use, cached per
// member for the tick.
func (o *Orchestrator) pickAccount(q *wsQueue, it QueueItem) accountPick {
	var member int64
	if q.w.ClaudeMode == domain.ClaudePerMember && it.MemberID != nil {
		member = *it.MemberID
	}
	if p, ok := q.accounts[member]; ok {
		return p
	}
	var p accountPick
	if o.accounts != nil {
		var m *int64
		if member != 0 {
			m = &member
		}
		p.acct, p.ok, p.why, p.until = o.accounts.Pick(q.ctx, q.w, m)
	} else {
		paused, until := o.usage.Paused(q.ctx, q.s)
		p.ok, p.until = !paused, until
		if paused {
			p.why = "Claude limit reached"
			if !until.IsZero() {
				p.why += "; resumes at " + until.Format("15:04")
			}
		}
	}
	q.accounts[member] = p
	return p
}

// scheduled is a claimed run ready to start.
type scheduled struct {
	ws      int64
	key     string
	runID   int64
	stage   domain.Stage
	work    func(ctx context.Context)
	release func()
	acct    domain.ClaudeAccount
	hasAcct bool
}

// claimItem claims the run an item waits for.
func (o *Orchestrator) claimItem(ctx context.Context, it QueueItem) (scheduled, bool) {
	wctx := domain.WithWorkspace(ctx, it.WorkspaceID)
	if it.Class == ClassRule {
		r, ok, err := o.rules.ClaimRule(wctx)
		if err != nil {
			o.log.Error("claim rule review", "workspace", it.WorkspaceID, "err", err)
		}
		if !ok {
			return scheduled{}, false
		}
		return scheduled{ws: it.WorkspaceID, stage: "rule", work: func(ctx context.Context) { o.reviewRule(ctx, r) }}, true
	}
	if it.Class == ClassBrief {
		b, ok, err := o.briefs.ClaimBrief(wctx)
		if err != nil {
			o.log.Error("claim survey", "workspace", it.WorkspaceID, "err", err)
		}
		if !ok {
			return scheduled{}, false
		}
		return scheduled{ws: it.WorkspaceID, stage: "brief", work: func(ctx context.Context) { o.surveyBrief(ctx, b) }}, true
	}
	if it.Class == ClassReflect {
		r, ok, err := o.reflections.ClaimReflection(wctx)
		if err != nil {
			o.log.Error("claim reflect run", "workspace", it.WorkspaceID, "err", err)
		}
		if !ok {
			return scheduled{}, false
		}
		return scheduled{ws: it.WorkspaceID, stage: "reflect", work: func(ctx context.Context) { o.reflect(ctx, r) }}, true
	}
	t, run, ok, err := o.queue.ClaimTicket(wctx, it.TicketID, it.Class)
	if err != nil {
		o.log.Error("claim", "ticket", it.Key, "err", err)
	}
	if !ok {
		return scheduled{}, false
	}
	return scheduled{ws: t.WorkspaceID, key: t.Key, runID: run.ID, stage: run.Stage,
		work: func(ctx context.Context) { o.work(ctx, t, run) }}, true
}

// runScheduled runs a claimed job in the workspace's context and on its
// Claude account, then frees its slot and memory.
func (o *Orchestrator) runScheduled(ctx context.Context, j scheduled) {
	started := time.Now()
	o.sched.mu.Lock()
	if j.runID > 0 {
		o.sched.runs[j.runID] = runInfo{ws: j.ws, key: j.key, stage: j.stage, started: started}
	}
	o.sched.mu.Unlock()
	defer func() {
		if j.release != nil {
			j.release()
		}
		o.sched.mu.Lock()
		o.sched.running[j.ws]--
		if o.sched.running[j.ws] <= 0 {
			delete(o.sched.running, j.ws)
		}
		delete(o.sched.runs, j.runID)
		if j.stage != "" && ctx.Err() == nil {
			d := time.Since(started)
			if avg, ok := o.sched.stageAvg[j.stage]; ok {
				o.sched.stageAvg[j.stage] = (avg*3 + d) / 4
			} else {
				o.sched.stageAvg[j.stage] = d
			}
		}
		o.sched.mu.Unlock()
	}()
	wctx := domain.WithWorkspace(ctx, j.ws)
	if j.hasAcct {
		wctx = domain.WithClaude(wctx, j.acct)
		if ra, ok := o.store.(RunAccounts); ok && j.runID > 0 {
			var conn *int64
			if j.acct.ConnectionID > 0 {
				conn = &j.acct.ConnectionID
			}
			if err := ra.SetRunAccount(wctx, j.runID, conn, j.acct.Credits); err != nil {
				o.log.Warn("record run account", "run_id", j.runID, "err", err)
			}
		}
	}
	j.work(wctx)
	if j.hasAcct && j.acct.Credits && o.credits != nil && j.runID > 0 {
		if err := o.credits.Settle(context.WithoutCancel(wctx), j.ws, j.runID, j.key); err != nil {
			o.log.Error("charge run to credits", "run_id", j.runID, "err", err)
		}
	}
}

// defaultStageTime is assumed for a stage before one has finished.
const defaultStageTime = 10 * time.Minute

// QueueStatus is where a workspace's tickets stand in the server queue.
type QueueStatus struct {
	Capacity CapacityStatus
	// Running is the workspace's runs in progress, Slots its limit.
	Running, Slots int
	// Waiting counts its tickets by wait reason.
	Waiting map[domain.WaitReason]int
	// ServerQueue is the server queue: its own tickets with their position,
	// and how many tickets of other workspaces wait ahead of each.
	ServerQueue []ServerQueueEntry
	// ServerQueueLen is the whole server queue's length.
	ServerQueueLen int
}

// ServerQueueEntry is one of the workspace's tickets waiting for the server.
type ServerQueueEntry struct {
	Key      string
	Position int // 1-based, in the whole server queue
	Others   int // tickets of other workspaces ahead of it
	// Estimate is how long until it may start, from the running runs'
	// expected remaining time (0 when unknown).
	Estimate time.Duration
}

// QueueStatus returns the queue as workspace ws sees it: its own tickets
// by name, other workspaces only as counts.
func (o *Orchestrator) QueueStatus(ctx context.Context) (QueueStatus, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return QueueStatus{}, err
	}
	out := QueueStatus{Waiting: map[domain.WaitReason]int{}}
	if o.capacity != nil {
		out.Capacity = o.capacity.Status()
	}
	w, err := o.workspace(ctx, ws)
	if err != nil {
		return out, err
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return out, err
	}
	out.Slots = slotsOf(w, s)
	ts, err := o.store.ListTickets(ctx, TicketFilter{States: []domain.TicketState{domain.StateNew, domain.StateCoding, domain.StatePushing}, Limit: 500})
	if err != nil {
		return out, err
	}
	for _, t := range ts {
		if t.WaitReason != domain.WaitNone {
			out.Waiting[t.WaitReason]++
		}
	}

	o.sched.mu.Lock()
	defer o.sched.mu.Unlock()
	out.Running = o.sched.running[ws]
	remaining := make([]time.Duration, 0, len(o.sched.runs))
	for _, r := range o.sched.runs {
		avg, ok := o.sched.stageAvg[r.stage]
		if !ok {
			avg = defaultStageTime
		}
		remaining = append(remaining, max(avg-time.Since(r.started), time.Minute))
	}
	slices.Sort(remaining)
	out.ServerQueueLen = len(o.sched.serverQueue)
	others := 0
	for i, ref := range o.sched.serverQueue {
		if ref.WorkspaceID != ws {
			others++
			continue
		}
		e := ServerQueueEntry{Key: ref.Key, Position: i + 1, Others: others}
		// Each run that ends frees room for about one waiting run.
		if len(remaining) > 0 {
			e.Estimate = remaining[min(i, len(remaining)-1)]
			if i >= len(remaining) {
				e.Estimate += time.Duration(i/len(remaining)) * defaultStageTime
			}
		}
		out.ServerQueue = append(out.ServerQueue, e)
	}
	return out, nil
}

// ServerStatus is the whole queue for the operator console.
type ServerStatus struct {
	Capacity    CapacityStatus
	Running     map[int64]int // workspace -> runs in progress
	ServerQueue []domain.TicketRef
	Runs        []RunningRun
}

// RunningRun is a run in progress.
type RunningRun struct {
	WorkspaceID int64
	Key         string
	Stage       domain.Stage
	Started     time.Time
}

// ServerStatus returns every workspace's running runs and the server queue.
func (o *Orchestrator) ServerStatus() ServerStatus {
	out := ServerStatus{Running: map[int64]int{}}
	if o.capacity != nil {
		out.Capacity = o.capacity.Status()
	}
	o.sched.mu.Lock()
	defer o.sched.mu.Unlock()
	for k, v := range o.sched.running {
		out.Running[k] = v
	}
	out.ServerQueue = slices.Clone(o.sched.serverQueue)
	for _, r := range o.sched.runs {
		out.Runs = append(out.Runs, RunningRun{WorkspaceID: r.ws, Key: r.key, Stage: r.stage, Started: r.started})
	}
	slices.SortFunc(out.Runs, func(a, b RunningRun) int { return a.Started.Compare(b.Started) })
	return out
}
