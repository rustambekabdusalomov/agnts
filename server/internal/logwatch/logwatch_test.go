package logwatch

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/logsource"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// memStore is an in-memory Store.
type memStore struct {
	mu       sync.Mutex
	sources  map[int64]domain.LogSource
	findings map[int64]*domain.LogFinding
	samples  map[int64]string
	tokens   map[string]int64
	reads    []postgres.LogReadState
	autos    int
	nextID   int64
}

func newMem() *memStore {
	return &memStore{sources: map[int64]domain.LogSource{}, findings: map[int64]*domain.LogFinding{}, samples: map[int64]string{}, tokens: map[string]int64{}}
}

func (m *memStore) LogSources(context.Context) ([]domain.LogSource, error) {
	var out []domain.LogSource
	for _, s := range m.sources {
		out = append(out, s)
	}
	return out, nil
}
func (m *memStore) PullSources(ctx context.Context) ([]domain.LogSource, error) {
	return m.LogSources(ctx)
}
func (m *memStore) LogSource(_ context.Context, id int64, _ bool) (domain.LogSource, error) {
	s, ok := m.sources[id]
	if !ok {
		return s, domain.ErrNotFound
	}
	return s, nil
}
func (m *memStore) LogSourceByPushToken(_ context.Context, hash []byte) (domain.LogSource, error) {
	id, ok := m.tokens[string(hash)]
	if !ok {
		return domain.LogSource{}, domain.ErrNotFound
	}
	return m.sources[id], nil
}
func (m *memStore) SaveLogSource(_ context.Context, x domain.LogSource, _ bool) (domain.LogSource, error) {
	if x.ID == 0 {
		m.nextID++
		x.ID = m.nextID
	}
	m.sources[x.ID] = x
	return x, nil
}
func (m *memStore) DeleteLogSource(_ context.Context, id int64) error {
	delete(m.sources, id)
	return nil
}
func (m *memStore) SetLogPushToken(_ context.Context, id int64, hash []byte) error {
	m.tokens[string(hash)] = id
	return nil
}
func (m *memStore) SaveLogRead(_ context.Context, id int64, st postgres.LogReadState) error {
	m.reads = append(m.reads, st)
	s := m.sources[id]
	s.Cursor, s.Status, s.LastError = st.Cursor, st.Status, st.LastError
	m.sources[id] = s
	return nil
}
func (m *memStore) SetLogServices(_ context.Context, id int64, svcs []domain.LogService) ([]domain.LogService, error) {
	s := m.sources[id]
	s.Services = svcs
	m.sources[id] = s
	return svcs, nil
}
func (m *memStore) LogKey(context.Context) ([]byte, error) { return []byte("key"), nil }
func (m *memStore) RotateLogKey(context.Context) error     { return nil }
func (m *memStore) LogFinding(_ context.Context, id int64) (domain.LogFinding, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	f, ok := m.findings[id]
	if !ok {
		return domain.LogFinding{}, domain.ErrNotFound
	}
	out := *f
	out.Sample = m.samples[id]
	return out, nil
}
func (m *memStore) LogFindingByTicket(_ context.Context, key string) (domain.LogFinding, error) {
	for _, f := range m.findings {
		if f.TicketKey == key {
			return *f, nil
		}
	}
	return domain.LogFinding{}, domain.ErrNotFound
}
func (m *memStore) ListLogFindings(_ context.Context, q domain.LogFindingFilter) ([]domain.LogFinding, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var out []domain.LogFinding
	for _, f := range m.findings {
		if (q.Status == "" || f.Status == q.Status) && (!q.Active || f.Status.Active()) && (q.Category == "" || f.Category == q.Category) {
			out = append(out, *f)
		}
	}
	return out, nil
}
func (m *memStore) UpsertLogFinding(_ context.Context, key domain.LogFinding, sample string, mut func(*domain.LogFinding, bool) error) (domain.LogFinding, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for id, f := range m.findings {
		if f.Scope == key.Scope && f.Fingerprint == key.Fingerprint {
			if err := mut(f, false); err != nil {
				return *f, err
			}
			if sample != "" {
				m.samples[id] = sample
			}
			return *f, nil
		}
	}
	m.nextID++
	f := key
	f.ID, f.Status, f.LastSeenAt = m.nextID, domain.LogOpen, key.FirstSeenAt
	if err := mut(&f, true); err != nil {
		return f, err
	}
	m.findings[f.ID] = &f
	m.samples[f.ID] = sample
	return f, nil
}
func (m *memStore) UpdateLogFinding(_ context.Context, id int64, mut func(*domain.LogFinding) error) (domain.LogFinding, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	f, ok := m.findings[id]
	if !ok {
		return domain.LogFinding{}, domain.ErrNotFound
	}
	if err := mut(f); err != nil {
		return *f, err
	}
	return *f, nil
}
func (m *memStore) MergeLogScope(_ context.Context, from, to string, repos []int64) error {
	for _, f := range m.findings {
		if f.Scope == from {
			f.Scope, f.RepoIDs = to, repos
		}
	}
	return nil
}
func (m *memStore) AutoLogTickets(context.Context, time.Time) (int, error) { return m.autos, nil }
func (m *memStore) PruneLogSamples(context.Context) (int64, error)         { return 0, nil }

type memTickets struct {
	mu      sync.Mutex
	events  []domain.Event
	tickets map[string]domain.Ticket
}

func (t *memTickets) TicketByKey(_ context.Context, key string) (domain.Ticket, error) {
	x, ok := t.tickets[key]
	if !ok {
		return x, domain.ErrNotFound
	}
	return x, nil
}
func (t *memTickets) RepositoryByID(_ context.Context, id int64) (domain.Repository, error) {
	return domain.Repository{ID: id, Name: fmt.Sprint("repo", id)}, nil
}
func (t *memTickets) ListRepositories(context.Context) ([]domain.Repository, error) {
	return []domain.Repository{{ID: 3, Name: "api"}}, nil
}
func (t *memTickets) AppendEvent(_ context.Context, ev domain.Event) error {
	t.mu.Lock()
	t.events = append(t.events, ev)
	t.mu.Unlock()
	return nil
}
func (t *memTickets) notified() []domain.Event {
	var out []domain.Event
	for _, e := range t.events {
		if on, _ := e.Data["notify"].(bool); on && e.Type == domain.EventLogFinding {
			out = append(out, e)
		}
	}
	return out
}

type memWork struct {
	inputs []orchestrator.LogTicketInput
	store  *memStore
	tix    *memTickets
}

func (w *memWork) CreateLogTicket(_ context.Context, in orchestrator.LogTicketInput, _ domain.Origin) (domain.Ticket, error) {
	w.inputs = append(w.inputs, in)
	w.store.autos++
	t := domain.Ticket{Key: fmt.Sprintf("LOG-%d", len(w.inputs)), State: domain.StateNew, Kind: in.Kind}
	w.tix.tickets[t.Key] = t
	return t, nil
}

type memSettings struct{ s domain.Settings }

func (m *memSettings) Get(context.Context) (domain.Settings, error) { return m.s, nil }

type fixture struct {
	svc   *Service
	store *memStore
	tix   *memTickets
	work  *memWork
	st    *memSettings
	src   domain.LogSource
	ctx   context.Context
	now   time.Time
}

func newFixture(t *testing.T, repos ...int64) *fixture {
	t.Helper()
	f := &fixture{store: newMem(), tix: &memTickets{tickets: map[string]domain.Ticket{}}, st: &memSettings{s: domain.DefaultSettings()},
		now: time.Date(2026, 11, 2, 10, 0, 0, 0, time.UTC), ctx: domain.WithWorkspace(context.Background(), 1)}
	f.work = &memWork{store: f.store, tix: f.tix}
	f.svc = New(f.store, f.tix, f.work, f.st, nil, logsource.Dialer{}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	f.svc.now = func() time.Time { return f.now }
	f.src = domain.LogSource{ID: 7, WorkspaceID: 1, Name: "prod", Kind: domain.LogLoki, Environment: "production", PollSeconds: 15, Enabled: true,
		Services: []domain.LogService{{ID: 1, SourceID: 7, Name: "api", RepoIDs: repos, Enabled: true}}}
	f.store.sources[7] = f.src
	return f
}

func (f *fixture) ingest(t *testing.T, msgs ...string) IngestResult {
	t.Helper()
	var es []domain.LogEntry
	for i, m := range msgs {
		es = append(es, domain.LogEntry{Time: f.now.Add(time.Duration(i) * 3 * time.Second), Service: "api", Stream: "api", Message: m})
	}
	r, err := f.svc.Ingest(f.ctx, f.src, es)
	if err != nil {
		t.Fatal(err)
	}
	return r
}

const panicLine = "panic: assignment to entry in nil map"
const tokenLine = `{"level":"info","msg":"request","caller":"auth/mw.go:31","authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"}`

func TestReportByDefault(t *testing.T) {
	f := newFixture(t, 3)
	r := f.ingest(t, panicLine, panicLine, tokenLine)
	if r.Findings != 2 || r.New != 2 {
		t.Fatalf("ingest %+v", r)
	}
	if len(f.work.inputs) != 0 {
		t.Fatal("no tickets by default")
	}
	n := f.tix.notified()
	if len(n) != 2 {
		t.Fatalf("want 2 notifications, got %d", len(n))
	}
	// The same errors again: counted, not notified again.
	f.ingest(t, panicLine, tokenLine)
	if len(f.tix.notified()) != 2 {
		t.Fatal("a finding notifies once")
	}
	for _, x := range f.store.findings {
		if x.Status != domain.LogReported {
			t.Errorf("%s: status %s", x.Title, x.Status)
		}
		if x.Detector == "panic" && x.Count != 3 {
			t.Errorf("panic count %d", x.Count)
		}
		if strings.Contains(f.store.samples[x.ID], "dozjgNry") {
			t.Error("a secret reached the stored sample")
		}
	}
}

func TestThreshold(t *testing.T) {
	f := newFixture(t, 3)
	line := `level=error msg="failed to load cart"`
	f.ingest(t, line, line)
	if len(f.tix.notified()) != 0 {
		t.Fatal("two plain errors are below the threshold of 3")
	}
	f.ingest(t, line)
	if len(f.tix.notified()) != 1 {
		t.Fatal("the third in the hour reports it")
	}
}

func TestTicketMode(t *testing.T) {
	f := newFixture(t, 3, 4)
	f.st.s.LogWatch.Errors = domain.LogModeTicket
	f.ingest(t, panicLine)
	if len(f.work.inputs) != 1 {
		t.Fatalf("want a ticket, got %d", len(f.work.inputs))
	}
	in := f.work.inputs[0]
	if len(in.RepoIDs) != 2 || in.Kind != domain.KindCode || in.Priority != "high" || !strings.Contains(in.Description, "find which of them") {
		t.Errorf("ticket input %+v", in)
	}
	for _, x := range f.store.findings {
		if x.Status != domain.LogFixing || x.TicketKey != "LOG-1" {
			t.Errorf("finding %+v", x)
		}
	}
}

func TestNoRepositoryOnlyReports(t *testing.T) {
	f := newFixture(t)
	f.st.s.LogWatch.Errors = domain.LogModeTicket
	f.ingest(t, panicLine)
	if len(f.work.inputs) != 0 {
		t.Fatal("a service without repositories gets no ticket")
	}
	for _, x := range f.store.findings {
		if x.Status != domain.LogReported || !strings.Contains(x.Reason, "no repository") {
			t.Errorf("finding %+v", x)
		}
	}
	if _, err := f.svc.Fix(f.ctx, 1, domain.OriginSystem); err == nil {
		t.Error("Fix it needs repositories")
	}
}

func TestBudget(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Errors = domain.LogModeTicket
	f.st.s.LogWatch.MaxAutoPerDay = 1
	f.ingest(t, panicLine)
	f.ingest(t, "panic: index out of range [3] with length 3")
	if len(f.work.inputs) != 1 {
		t.Fatalf("budget of 1: %d tickets", len(f.work.inputs))
	}
	var budgeted *domain.LogFinding
	for _, x := range f.store.findings {
		if x.Status == domain.LogReported {
			budgeted = x
		}
	}
	if budgeted == nil || !strings.Contains(budgeted.Reason, "budget") {
		t.Fatalf("over budget: %+v", budgeted)
	}
	// Fix it isn't capped.
	if _, err := f.svc.Fix(f.ctx, budgeted.ID, domain.OriginSystem); err != nil {
		t.Fatal(err)
	}
}

func TestOffAndLeaks(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Errors, f.st.s.LogWatch.Security = domain.LogModeOff, domain.LogModeOff
	f.ingest(t, panicLine, tokenLine)
	n := f.tix.notified()
	if len(n) != 1 || n[0].Data["category"] != "security" {
		t.Fatalf("off still notifies a high leak, nothing else: %+v", n)
	}
	f2 := newFixture(t, 3)
	f2.st.s.LogWatch.Security, f2.st.s.LogWatch.AlwaysNotifyLeaks = domain.LogModeOff, false
	f2.st.s.LogWatch.Errors = domain.LogModeOff
	f2.ingest(t, tokenLine)
	if len(f2.tix.notified()) != 0 {
		t.Fatal("with AlwaysNotifyLeaks off, off is silent")
	}
}

func TestOverrides(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Overrides = []domain.LogOverride{{Service: "prod/api", Errors: domain.LogModeTicket}}
	f.ingest(t, panicLine)
	if len(f.work.inputs) != 1 {
		t.Fatal("the service override opens a ticket")
	}
}

func TestConfigClassIsReportedNotTicketed(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Security = domain.LogModeTicket
	f.ingest(t, `[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.`)
	if len(f.work.inputs) != 0 {
		t.Fatal("debug mode is config: report, not an automatic ticket")
	}
	var id int64
	for _, x := range f.store.findings {
		id = x.ID
		if !strings.Contains(x.Reason, "not a code bug") {
			t.Errorf("reason %q", x.Reason)
		}
	}
	// Fix it opens a bug report for it.
	if _, err := f.svc.Fix(f.ctx, id, domain.OriginSystem); err != nil {
		t.Fatal(err)
	}
	if f.work.inputs[0].Kind != domain.KindBug {
		t.Errorf("kind %s, want bug", f.work.inputs[0].Kind)
	}
}

func TestRepeatedAttackBecomesTicketable(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Security = domain.LogModeTicket
	f.st.s.LogWatch.MinSeverity = domain.LogLow
	f.st.s.LogWatch.Threshold = 1
	burst := func() {
		var es []domain.LogEntry
		for i := range 20 {
			es = append(es, domain.LogEntry{Time: f.now.Add(time.Duration(i) * time.Second), Service: "api", Stream: "api",
				Message: `203.0.113.9 - - [02/Nov/2026:09:00:00 +0000] "POST /api/login HTTP/1.1" 401 12 "-" "curl"`})
		}
		if _, err := f.svc.Ingest(f.ctx, f.src, es); err != nil {
			t.Fatal(err)
		}
	}
	burst()
	if len(f.work.inputs) != 0 {
		t.Fatal("one burst is reported, not ticketed")
	}
	for _, x := range f.store.findings {
		x.Status = domain.LogOpen // a person dismissed the report; the next bursts act again
	}
	for range 2 {
		f.now = f.now.Add(time.Hour)
		burst()
		for _, x := range f.store.findings {
			if x.Status == domain.LogReported {
				x.Status = domain.LogOpen
			}
		}
	}
	if len(f.work.inputs) != 1 || !strings.HasPrefix(f.work.inputs[0].Title, "Harden") {
		t.Fatalf("the third burst opens a hardening ticket: %+v", f.work.inputs)
	}
}

func TestSyncAndSweep(t *testing.T) {
	f := newFixture(t, 3)
	f.st.s.LogWatch.Errors = domain.LogModeTicket
	f.ingest(t, panicLine)
	merged := f.now.Add(time.Hour)
	tk := f.tix.tickets["LOG-1"]
	tk.MergedAt, tk.HeadSHA, tk.State = &merged, "abc123", domain.StateDone
	f.tix.tickets["LOG-1"] = tk
	if err := f.svc.Sync(f.ctx); err != nil {
		t.Fatal(err)
	}
	var x *domain.LogFinding
	for _, y := range f.store.findings {
		x = y
	}
	if x.Status != domain.LogFixed || x.FixedSHA != "abc123" {
		t.Fatalf("after merge %+v", x)
	}
	// Seen again after the merge, no revision: recurred.
	f.now = merged.Add(time.Hour)
	f.ingest(t, panicLine)
	if x.Status != domain.LogRegression || !strings.Contains(x.Reason, "may not be deployed") {
		t.Fatalf("recurred %+v", x)
	}
	n := f.tix.notified()
	if last := n[len(n)-1]; last.Data["kind"] != "regression" {
		t.Errorf("regression notification %+v", last.Data)
	}
	// Quiet after a fix: resolved after ResolveAfterDays.
	x.Status, x.FixedAt, x.LastSeenAt = domain.LogFixed, &merged, merged.Add(-time.Minute)
	f.now = merged.Add(4 * 24 * time.Hour)
	if err := f.svc.Sweep(f.ctx); err != nil {
		t.Fatal(err)
	}
	if x.Status != domain.LogResolved {
		t.Fatalf("after quiet days %s", x.Status)
	}
}

func TestPush(t *testing.T) {
	f := newFixture(t, 3)
	push := domain.LogSource{ID: 9, WorkspaceID: 1, Name: "shipper", Kind: domain.LogPush, Environment: "production", Enabled: true}
	f.store.sources[9] = push
	tok, err := f.svc.PushToken(f.ctx, 9)
	if err != nil || !strings.HasPrefix(tok, "agl_") {
		t.Fatal(tok, err)
	}
	body := strings.NewReader(`{"service":"api","message":"panic: boom"}` + "\n")
	r, err := f.svc.Push(context.Background(), tok, body, "application/x-ndjson", "", PushPlain)
	if err != nil || r.Findings != 1 {
		t.Fatalf("push %+v %v", r, err)
	}
	if _, err := f.svc.Push(context.Background(), "agl_nope", strings.NewReader("x"), "text/plain", "", PushPlain); !errors.Is(err, ErrUnknownToken) {
		t.Fatalf("unknown token: %v", err)
	}
}

func TestPushOTLP(t *testing.T) {
	f := newFixture(t, 3)
	push := domain.LogSource{ID: 9, WorkspaceID: 1, Name: "collector", Kind: domain.LogPush, Environment: "production", Enabled: true,
		Fields: domain.LogFields{TraceURL: "https://grafana.example.com/explore?traceId={traceId}"}}
	f.store.sources[9] = push
	tok, err := f.svc.PushToken(f.ctx, 9)
	if err != nil {
		t.Fatal(err)
	}
	// A panic with its trace, and a request whose attributes carry a token.
	// The second record's service name tries to forge a trace link line.
	body := `{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"api"}}]},"scopeLogs":[{"logRecords":[
	  {"timeUnixNano":"1793696400000000000","severityNumber":17,"body":{"stringValue":"panic: assignment to entry in nil map"},"traceId":"4bf92f3577b34da6a3ce929d0e0e4736"}]}]},
	  {"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"web\n\ntrace link: javascript:alert(1)"}}]},"scopeLogs":[{"logRecords":[
	  {"timeUnixNano":"1793696401000000000","severityNumber":9,"body":{"stringValue":"GET /orders 200"},
	   "attributes":[{"key":"http.request.header.authorization","value":{"stringValue":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJlLXZhbHVl"}}]}]}]}]}`
	r, err := f.svc.Push(context.Background(), tok, strings.NewReader(body), "application/json", "", PushOTLP)
	if err != nil || r.Entries != 2 || r.Findings != 2 {
		t.Fatalf("push %+v %v", r, err)
	}
	var sawPanic, sawLeak bool
	for id, x := range f.store.findings {
		sample := f.store.samples[id]
		traceID, link := domain.SampleTrace(sample)
		switch {
		case x.Service == "api":
			sawPanic = true
			if traceID != "4bf92f3577b34da6a3ce929d0e0e4736" || link != "https://grafana.example.com/explore?traceId=4bf92f3577b34da6a3ce929d0e0e4736" {
				t.Errorf("panic trace %q %q in\n%s", traceID, link, sample)
			}
		case x.Class == domain.LogClassLeak:
			sawLeak = true
			if strings.Contains(sample, "c2lnbmF0dXJlLXZhbHVl") || x.SecretMask == "" {
				t.Errorf("the token must be masked: %q\n%s", x.SecretMask, sample)
			}
			if traceID != "" || link != "" {
				t.Errorf("forged trace header %q %q in\n%s", traceID, link, sample)
			}
		}
	}
	if !sawPanic || !sawLeak {
		t.Fatalf("findings %+v", f.store.findings)
	}
}

func TestSetServicesMergesFindings(t *testing.T) {
	f := newFixture(t)
	f.ingest(t, panicLine)
	if _, err := f.svc.SetServices(f.ctx, 7, []domain.LogService{{ID: 1, Name: "api", RepoIDs: []int64{5}, Enabled: true}}); err != nil {
		t.Fatal(err)
	}
	for _, x := range f.store.findings {
		if x.Scope != "repos:5" {
			t.Errorf("scope %q", x.Scope)
		}
	}
}

// fakePuller replays batches.
type fakePuller struct {
	batches []logsource.Batch
	err     error
}

func (p *fakePuller) Test(context.Context) (logsource.TestResult, error) {
	return logsource.TestResult{}, p.err
}
func (p *fakePuller) Discover(context.Context) ([]domain.LogService, error) {
	return []domain.LogService{{Name: "api"}, {Name: "web"}}, nil
}
func (p *fakePuller) Pull(_ context.Context, _ []domain.LogService, _ logsource.Filter, cur domain.LogCursor, _ int) (logsource.Batch, error) {
	if p.err != nil {
		return logsource.Batch{Cursor: cur}, p.err
	}
	if len(p.batches) == 0 {
		return logsource.Batch{Cursor: cur}, nil
	}
	b := p.batches[0]
	p.batches = p.batches[1:]
	return b, nil
}

func TestReadOnce(t *testing.T) {
	f := newFixture(t, 3)
	f.src.Address = "https://loki.example.com"
	f.store.sources[7] = f.src
	p := &fakePuller{batches: []logsource.Batch{{Entries: []domain.LogEntry{{Time: f.now, Service: "api", Message: panicLine}},
		Cursor: domain.LogCursor{Time: f.now}}}}
	f.svc.newPuller = func(domain.LogSource, *logsource.Client) (logsource.Puller, error) { return p, nil }
	n, more, err := f.svc.readOnce(f.ctx, f.src, false)
	if err != nil || n != 1 || more {
		t.Fatalf("read %d %v %v", n, more, err)
	}
	if got := f.store.sources[7]; !got.Cursor.Time.Equal(f.now) || got.Status != domain.LogSourceOK {
		t.Fatalf("source after read %+v", got)
	}
	// A long outage jumps the cursor and records the gap.
	src := f.store.sources[7]
	f.now = f.now.Add(5 * time.Hour)
	if _, _, err := f.svc.readOnce(f.ctx, src, false); err != nil {
		t.Fatal(err)
	}
	if last := f.store.reads[len(f.store.reads)-1]; last.GapFrom == nil || !last.GapTo.Equal(f.now.Add(-time.Hour)) {
		t.Fatalf("gap %+v", last)
	}
	// Refused credentials stop the source and notify.
	p.err = &logsource.HTTPError{Status: 401}
	if _, _, err := f.svc.readOnce(f.ctx, f.store.sources[7], false); !logsource.Unauthorized(err) {
		t.Fatal(err)
	}
	if f.store.sources[7].Status != domain.LogSourceAuthFailed {
		t.Fatalf("status %s", f.store.sources[7].Status)
	}
}
