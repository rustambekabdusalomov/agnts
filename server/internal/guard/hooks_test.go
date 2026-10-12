package guard

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
)

type fakeEnv struct {
	files map[string]string
	runs  []string
	exit  map[string]int // by command substring
	out   string
	now   time.Time
}

func (f *fakeEnv) Run(cmd string, _ time.Duration) (int, string, time.Duration) {
	f.runs = append(f.runs, cmd)
	for k, v := range f.exit {
		if strings.Contains(cmd, k) {
			return v, f.out, 10 * time.Millisecond
		}
	}
	return 0, "", 10 * time.Millisecond
}

func (f *fakeEnv) ReadFile(p string) ([]byte, error) {
	if s, ok := f.files[p]; ok {
		return []byte(s), nil
	}
	return nil, errors.New("not found")
}

func (f *fakeEnv) Now() time.Time {
	if f.now.IsZero() {
		return time.Unix(1_800_000_000, 0)
	}
	return f.now
}

func toolInput(tool string, v any) Input {
	b, _ := json.Marshal(v)
	return Input{ToolName: tool, ToolInput: b, Cwd: Workspace}
}

func edit1(path, old, next string) Input {
	return toolInput("Edit", map[string]string{"file_path": "/workspace/" + path, "old_string": old, "new_string": next})
}

func TestPreBlocksRedFlags(t *testing.T) {
	cases := []struct {
		name    string
		profile Profile
		allow   []string
		in      Input
		block   string // red flag kind, "" for none
	}{
		{"skip in a test", Standard, nil, edit1("pay/pay_test.go", "func TestA(t *testing.T) {", "func TestA(t *testing.T) {\n\tt.Skip(\"flaky\")"), domain.FlagSkippedTest},
		{"skip allowed for the ticket", Standard, []string{domain.FlagSkippedTest}, edit1("pay/pay_test.go", "x", "\tt.Skip(\"flaky\")"), ""},
		{"skip on minimal", Minimal, nil, edit1("pay/pay_test.go", "x", "\tt.Skip(\"flaky\")"), ""},
		{"nolint", Standard, nil, edit1("pay/pay.go", "func f() {}", "//nolint:errcheck\nfunc f() {}"), domain.FlagSilencedLint},
		{"secret even on minimal", Minimal, nil, edit1("pay/client.go", "", `const key = "AKIAIOSFODNN7EXAMPLQ"`), domain.FlagSecret},
		{"secret in testdata", Standard, nil, edit1("pay/testdata/fixture.go", "", `const key = "AKIAIOSFODNN7EXAMPLQ"`), ""},
		{"placeholder is no secret", Standard, nil, edit1("pay/client.go", "", `apiKey: "your-api-key-goes-here-ok"`), ""},
		{"swallowed error on standard", Standard, nil, edit1("pay/pay.go", "", "\tif err != nil {}"), ""},
		{"swallowed error on strict", Strict, nil, edit1("pay/pay.go", "", "\tif err != nil {}"), domain.FlagSwallowedError},
		{"lint config", Standard, nil, edit1(".golangci.yml", "a", "b"), domain.FlagCheckConfig},
		{"lint config allowed", Standard, []string{domain.FlagCheckConfig}, edit1(".golangci.yml", "a", "b"), ""},
		{"dotenv", Minimal, nil, toolInput("Write", map[string]string{"file_path": "/workspace/.env", "content": "A=1"}), domain.FlagEnvFile},
		{"dotenv example", Minimal, nil, toolInput("Write", map[string]string{"file_path": "/workspace/.env.example", "content": "A="}), ""},
		{"outside the workspace", Strict, nil, toolInput("Write", map[string]string{"file_path": "/agnts/out/summary.json", "content": `{"key": "AKIAIOSFODNN7EXAMPLQ"}`}), ""},
		{"removed assertions on strict", Strict, nil, edit1("a/a_test.go", "assert.Equal(t, 1, f())\nassert.Equal(t, 2, g())", "assert.Equal(t, 1, f())"), domain.FlagRemovedAssert},
		{"rm a test", Standard, nil, toolInput("Bash", map[string]string{"command": "rm -f pay/pay_test.go && go test ./..."}), domain.FlagDeletedTest},
		{"rm something else", Standard, nil, toolInput("Bash", map[string]string{"command": "rm -rf /tmp/build"}), ""},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			res, log := Handle("pre", c.in, Config{Profile: c.profile, Allow: c.allow}, &State{}, &fakeEnv{})
			if c.block == "" {
				if res.Exit != 0 {
					t.Fatalf("blocked: %s", res.Stderr)
				}
				return
			}
			if res.Exit != 2 || len(log) != 1 || log[0].Kind != c.block || log[0].Decision != DecisionBlock {
				t.Fatalf("want a %s block, got exit %d %+v: %s", c.block, res.Exit, log, res.Stderr)
			}
			if strings.Contains(res.Stderr, "AKIAIOSFODNN7EXAMPLQ") {
				t.Fatalf("the secret is echoed back: %s", res.Stderr)
			}
		})
	}
}

func TestWriteOverExistingFileFlagsOnlyNewLines(t *testing.T) {
	env := &fakeEnv{files: map[string]string{"/workspace/a/a.go": "//nolint:all\npackage a\n"}}
	in := toolInput("Write", map[string]string{"file_path": "/workspace/a/a.go", "content": "//nolint:all\npackage a\n\nfunc F() {}\n"})
	if res, _ := Handle("pre", in, Config{Profile: Strict}, &State{}, env); res.Exit != 0 {
		t.Fatalf("an existing nolint was blamed on the edit: %s", res.Stderr)
	}
}

func TestEnforcedRules(t *testing.T) {
	cfg := Config{Profile: Minimal, Rules: []Rule{
		{ID: 1, Title: "Applied migrations are never edited", On: OnFile, Paths: []string{"server/migrations/*.sql"}, Action: ActionBlock, Message: "add a new migration"},
		{ID: 2, Title: "No SQL in handlers", On: OnFile, Paths: []string{"internal/httpapi/**"}, Pattern: `(?i)\bselect\b.+\bfrom\b`, Action: ActionWarn, Message: "use internal/store"},
		{ID: 3, Title: "Never run the migrate tool", On: OnBash, Pattern: `\bgoose\b`, Action: ActionBlock},
	}}
	res, log := Handle("pre", edit1("server/migrations/00001_init.sql", "a", "b"), cfg, &State{}, &fakeEnv{})
	if res.Exit != 2 || log[0].Kind != domain.FlagRuleViolation || !strings.Contains(res.Stderr, "add a new migration") {
		t.Fatalf("migration rule: %d %s", res.Exit, res.Stderr)
	}
	if res, _ := Handle("pre", edit1("server/internal/x.go", "a", "b"), cfg, &State{}, &fakeEnv{}); res.Exit != 0 {
		t.Fatalf("rule applied outside its paths: %s", res.Stderr)
	}
	// A warn rule never blocks; it is feedback after the edit.
	in := edit1("internal/httpapi/tickets.go", "", `rows := db.Query("SELECT id FROM tickets")`)
	if res, _ := Handle("pre", in, cfg, &State{}, &fakeEnv{}); res.Exit != 0 {
		t.Fatalf("a warn rule blocked: %s", res.Stderr)
	}
	res, log = Handle("post", in, cfg, &State{}, &fakeEnv{})
	if res.Exit != 2 || !strings.Contains(res.Stderr, "No SQL in handlers") || log[0].Decision != DecisionWarn {
		t.Fatalf("warn rule: %d %s %+v", res.Exit, res.Stderr, log)
	}
	if res, _ := Handle("pre", toolInput("Bash", map[string]string{"command": "goose up"}), cfg, &State{}, &fakeEnv{}); res.Exit != 2 {
		t.Fatal("bash rule did not block")
	}
}

func TestEditChecks(t *testing.T) {
	cfg := Config{Profile: Standard, EditChecks: []EditCheck{
		{Name: "gofmt", Globs: []string{"*.go"}, Cmd: "test -z \"$(gofmt -l {file})\""},
		{Name: "vet", Globs: []string{"**/*.go"}, Cmd: "go vet ./{dir}", Every: 60},
	}}
	env := &fakeEnv{exit: map[string]int{"gofmt": 1}, out: "pay/pay.go"}
	st := &State{}
	res, log := Handle("post", edit1("pay/pay.go", "a", "b"), cfg, st, env)
	if res.Exit != 2 || !strings.Contains(res.Stderr, "gofmt reports problems") {
		t.Fatalf("edit check: %d %s", res.Exit, res.Stderr)
	}
	if len(env.runs) != 2 || !strings.Contains(env.runs[0], "'pay/pay.go'") || !strings.Contains(env.runs[1], "go vet ./'pay'") {
		t.Fatalf("commands: %q", env.runs)
	}
	if len(log) != 2 {
		t.Fatalf("log: %+v", log)
	}
	// vet runs at most once a minute.
	env.runs = nil
	Handle("post", edit1("pay/pay.go", "a", "b"), cfg, st, env)
	if len(env.runs) != 1 {
		t.Fatalf("vet ran again within a minute: %q", env.runs)
	}
	// Not on minimal, not for files the globs miss, not on read-only runs.
	env.runs = nil
	Handle("post", edit1("pay/pay.go", "a", "b"), Config{Profile: Minimal, EditChecks: cfg.EditChecks}, &State{}, env)
	Handle("post", edit1("web/app.ts", "a", "b"), cfg, &State{}, env)
	if len(env.runs) != 0 {
		t.Fatalf("ran: %q", env.runs)
	}
	// A missing tool is not Claude's problem.
	env = &fakeEnv{exit: map[string]int{"gofmt": 127}}
	if res, _ := Handle("post", edit1("pay/pay.go", "a", "b"), cfg, &State{}, env); res.Exit != 0 {
		t.Fatalf("missing tool fed back: %s", res.Stderr)
	}
}

func TestStopGate(t *testing.T) {
	cfg := Config{Profile: Standard, StopAttempts: 2, Stop: []Command{{Name: "build", Cmd: "make build"}, {Name: "lint", Cmd: "make lint"}}}
	env := &fakeEnv{exit: map[string]int{"make lint": 1}, out: "pay.go:3: unused variable x"}
	st := &State{}
	for i := 1; i <= 2; i++ {
		res, _ := Handle("stop", Input{StopHookActive: i > 1}, cfg, st, env)
		if res.Exit != 2 || !strings.Contains(res.Stderr, "unused variable x") || !strings.Contains(res.Stderr, "the lint check") {
			t.Fatalf("attempt %d: %d %s", i, res.Exit, res.Stderr)
		}
	}
	if res, log := Handle("stop", Input{StopHookActive: true}, cfg, st, env); res.Exit != 0 || log[0].Decision != DecisionPass {
		t.Fatalf("not let through after the limit: %d %+v", res.Exit, log)
	}
	// Green checks let Claude finish.
	if res, _ := Handle("stop", Input{}, cfg, &State{}, &fakeEnv{}); res.Exit != 0 {
		t.Fatalf("green: %s", res.Stderr)
	}
	// Read-only runs never build.
	env = &fakeEnv{}
	Handle("stop", Input{}, Config{Profile: Strict, ReadOnly: true, Stop: cfg.Stop}, &State{}, env)
	if len(env.runs) != 0 {
		t.Fatalf("read-only run built: %q", env.runs)
	}
}

func TestSessionGivesProgressBack(t *testing.T) {
	env := &fakeEnv{files: map[string]string{ProgressPath: "## Plan\n1. store\n2. api (done)"}}
	cfg := Config{Profile: Minimal}
	if res, _ := Handle("session", Input{Source: "startup"}, cfg, &State{}, env); res.Stdout != "" {
		t.Fatalf("startup got context: %q", res.Stdout)
	}
	res, _ := Handle("session", Input{Source: "compact"}, cfg, &State{}, env)
	if !strings.Contains(res.Stdout, "2. api (done)") || res.Exit != 0 {
		t.Fatalf("compact: %+v", res)
	}
}

func TestFactCheckAsksOncePerFile(t *testing.T) {
	cfg := Config{Profile: Strict, FactCheck: true}
	st := &State{}
	in := edit1("pay/pay.go", "a", "b")
	if res, _ := Handle("pre", in, cfg, st, &fakeEnv{}); res.Exit != 2 || !strings.Contains(res.Stderr, "Who uses it") {
		t.Fatalf("first edit: %d %s", res.Exit, res.Stderr)
	}
	if res, _ := Handle("pre", in, cfg, st, &fakeEnv{}); res.Exit != 0 {
		t.Fatalf("second edit blocked: %s", res.Stderr)
	}
	// A new file has no callers to ask about.
	newFile := toolInput("Write", map[string]string{"file_path": "/workspace/pay/new.go", "content": "package pay"})
	if res, _ := Handle("pre", newFile, cfg, st, &fakeEnv{}); res.Exit != 0 {
		t.Fatalf("new file blocked: %s", res.Stderr)
	}
	cmd := toolInput("Bash", map[string]string{"command": "git reset --hard HEAD"})
	if res, _ := Handle("pre", cmd, cfg, st, &fakeEnv{}); res.Exit != 2 {
		t.Fatal("destructive command passed")
	}
	if res, _ := Handle("pre", cmd, cfg, st, &fakeEnv{}); res.Exit != 0 {
		t.Fatal("destructive command blocked twice")
	}
}

func TestConfigRoundTripAndDisabled(t *testing.T) {
	c := Config{Profile: Strict, Disabled: []string{HookRedFlags}, Stop: []Command{{Name: "build", Cmd: "go build ./..."}}}
	got, err := Decode(c.Encode())
	if err != nil || got.Profile != Strict || got.Stop[0].Cmd != "go build ./..." {
		t.Fatalf("round trip: %+v %v", got, err)
	}
	if got.On(HookRedFlags) || !got.On(HookStopGate) || !got.On(HookSecret) {
		t.Fatal("hook switches")
	}
	in := edit1("a/a_test.go", "x", "\tt.Skip()")
	if res, _ := Handle("pre", in, got, &State{}, &fakeEnv{}); res.Exit != 0 {
		t.Fatal("a disabled hook still blocked")
	}
	if c, _ := Decode(Config{Profile: "bogus"}.Encode()); c.Profile != Standard {
		t.Fatalf("unknown profile: %q", c.Profile)
	}
}

func TestMatchGlob(t *testing.T) {
	for _, c := range []struct {
		g, p string
		ok   bool
	}{
		{"*.go", "a/b/c.go", true},
		{"server/migrations/*.sql", "server/migrations/0001.sql", true},
		{"server/migrations/*.sql", "server/migrations/x/0001.sql", false},
		{"internal/**", "internal/a/b.go", true},
		{"**/*_test.go", "a_test.go", true},
		{"**/*_test.go", "x/y/a_test.go", true},
		{"web/**/*.vue", "web/src/A.vue", true},
		{"web/**/*.vue", "api/src/A.vue", false},
	} {
		if MatchGlob(c.g, c.p) != c.ok {
			t.Errorf("MatchGlob(%q, %q) != %v", c.g, c.p, c.ok)
		}
	}
}

func TestNoticeIsDeliveredOnce(t *testing.T) {
	env := &fakeEnv{files: map[string]string{NoticePath: `{"id":"stall-1","message":"agnts noticed that you seem to be stuck"}`}}
	st := &State{}
	in := toolInput("Read", map[string]string{"file_path": "/workspace/a.go"})
	res, log := Handle("pre", in, Config{Profile: Minimal}, st, env)
	if res.Exit != 2 || !strings.Contains(res.Stderr, "seem to be stuck") || log[0].Hook != HookNotice {
		t.Fatalf("first call: %+v %+v", res, log)
	}
	if res, _ := Handle("pre", in, Config{Profile: Minimal}, st, env); res.Exit != 0 {
		t.Fatalf("delivered twice: %s", res.Stderr)
	}
}
