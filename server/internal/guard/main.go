package guard

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"time"
)

// Main is the agnts-guard command: it reads the hook input from stdin, the
// config from the environment, decides, writes stdout and stderr, and
// returns the exit code. A missing config means agnts did not ask for any
// guard (an older server, or a run without one): everything passes.
func Main(event string, stdin io.Reader, stdout, stderr io.Writer) int {
	raw := os.Getenv(ConfigEnv)
	if raw == "" {
		return 0
	}
	cfg, err := Decode(raw)
	if err != nil {
		writeLog([]Entry{{At: time.Now(), Event: event, Decision: DecisionError, Msg: err.Error()}})
		return 0
	}
	b, err := io.ReadAll(io.LimitReader(stdin, MaxInput+1))
	if err != nil {
		return 0
	}
	var in Input
	if len(b) > MaxInput {
		// Too large to inspect: refuse what safety guards would check,
		// pass the rest.
		if event == "pre" {
			_, _ = io.WriteString(stderr, "agnts-guard: this tool call is too large to check (over 1 MiB). Make the change in smaller steps.")
			writeLog([]Entry{{At: time.Now(), Event: event, Decision: DecisionBlock, Msg: "input over 1 MiB"}})
			return 2
		}
		return 0
	}
	if json.Unmarshal(b, &in) != nil {
		return 0
	}

	unlock := lock()
	defer unlock()
	st := loadState()
	res, log := Handle(event, in, cfg, &st, osEnv{cwd: in.Cwd})
	saveState(st)
	writeLog(log)

	if res.Stdout != "" {
		_, _ = io.WriteString(stdout, res.Stdout)
	}
	if res.Stderr != "" {
		_, _ = io.WriteString(stderr, res.Stderr)
	}
	return res.Exit
}

// lock serialises hooks of one run: Claude Code may run several at once
// (parallel tool calls), and they share the state file.
func lock() func() {
	if err := os.MkdirAll(StateDir, 0o750); err != nil {
		return func() {}
	}
	f, err := os.OpenFile(StatePath+".lock", os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return func() {}
	}
	if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX); err != nil {
		_ = f.Close()
		return func() {}
	}
	return func() {
		_ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN)
		_ = f.Close()
	}
}

func loadState() State {
	var st State
	if b, err := os.ReadFile(StatePath); err == nil {
		_ = json.Unmarshal(b, &st)
	}
	return st
}

func saveState(st State) {
	b, _ := json.Marshal(st)
	tmp := StatePath + ".tmp"
	if os.WriteFile(tmp, b, 0o600) == nil {
		_ = os.Rename(tmp, StatePath)
	}
}

func writeLog(es []Entry) {
	if len(es) == 0 {
		return
	}
	if err := os.MkdirAll(filepath.Dir(LogPath), 0o750); err != nil {
		return
	}
	f, err := os.OpenFile(LogPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o600)
	if err != nil {
		return
	}
	defer func() { _ = f.Close() }()
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	for _, e := range es {
		_ = enc.Encode(e)
	}
	_, _ = f.Write(buf.Bytes())
}

// osEnv runs commands with bash in the workspace.
type osEnv struct{ cwd string }

func (e osEnv) Run(cmd string, timeout time.Duration) (int, string, time.Duration) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	c := exec.CommandContext(ctx, "bash", "-c", cmd) //nolint:gosec // the commands come from the server's run config (the repository's checks)
	c.Dir = Workspace
	if e.cwd != "" {
		c.Dir = e.cwd
	}
	c.WaitDelay = 5 * time.Second
	var out limitedBuffer
	c.Stdout, c.Stderr = &out, &out
	start := time.Now()
	err := c.Run()
	took := time.Since(start)
	if ctx.Err() != nil {
		return 124, out.String(), took
	}
	var ee *exec.ExitError
	switch {
	case err == nil:
		return 0, out.String(), took
	case errors.As(err, &ee):
		return ee.ExitCode(), out.String(), took
	default:
		return 127, err.Error(), took
	}
}

func (osEnv) ReadFile(p string) ([]byte, error) {
	f, err := os.Open(p) //nolint:gosec // reading the file Claude is about to change, inside its own container
	if err != nil {
		return nil, err
	}
	defer func() { _ = f.Close() }()
	return io.ReadAll(io.LimitReader(f, 4<<20))
}

func (osEnv) Now() time.Time { return time.Now() }

// limitedBuffer keeps the first and last 64 KiB of a command's output.
type limitedBuffer struct {
	head, tail []byte
	dropped    bool
}

const half = 64 << 10

func (b *limitedBuffer) Write(p []byte) (int, error) {
	n := len(p)
	if room := half - len(b.head); room > 0 {
		k := min(room, len(p))
		b.head = append(b.head, p[:k]...)
		p = p[k:]
	}
	if len(p) > 0 {
		b.tail = append(b.tail, p...)
		if len(b.tail) > half {
			b.tail = b.tail[len(b.tail)-half:]
			b.dropped = true
		}
	}
	return n, nil
}

func (b *limitedBuffer) String() string {
	if b.dropped {
		return string(b.head) + "\n…\n" + string(b.tail)
	}
	return string(b.head) + string(b.tail)
}
