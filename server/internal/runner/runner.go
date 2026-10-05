package runner

import (
	"archive/tar"
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"path"
	"strconv"
	"strings"
	"sync"
	"time"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
)

// Paths inside the runner image (deploy/runner/Dockerfile).
const (
	workDir    = "/workspace"
	homeDir    = "/home/agent"
	claudeHome = "/home/agent/.claude"
	outDir     = "/hiro/out"
	agentUser  = "agent"
	agentUID   = 1000 // the image's agent user, owner of files hiro writes
)

// Config sets container limits.
type Config struct {
	Network  string // user-defined bridge for run containers
	Proxy    string // egress proxy URL; with an internal network, the only way out
	MemoryMB int64
	CPUs     float64
	PIDs     int64
}

// DefaultConfig returns limits for a small VPS.
func DefaultConfig() Config {
	return Config{Network: "hiro-runs", MemoryMB: 4096, CPUs: 2, PIDs: 1024}
}

// TokenSource returns the Claude OAuth token at the moment a run starts,
// so a rotated token is picked up without a restart.
type TokenSource func(ctx context.Context) (string, error)

// Runner implements orchestrator.Runner with Docker.
type Runner struct {
	docker *Docker
	cfg    Config
	token  TokenSource

	netOnce sync.Once
	netErr  error
}

var _ orchestrator.Runner = (*Runner)(nil)

// New returns a Docker-backed runner.
func New(docker *Docker, cfg Config, token TokenSource) *Runner {
	return &Runner{docker: docker, cfg: cfg, token: token}
}

// Open creates a container, copies the repository (and any earlier Claude
// session) into it, and starts it idle; work happens through exec.
func (r *Runner) Open(ctx context.Context, spec orchestrator.WorkspaceSpec) (orchestrator.Workspace, error) {
	r.netOnce.Do(func() { r.netErr = r.docker.EnsureNetwork(ctx, r.cfg.Network, r.cfg.Proxy != "") })
	if r.netErr != nil {
		return nil, fmt.Errorf("run network: %w", r.netErr)
	}
	suffix := make([]byte, 3)
	_, _ = rand.Read(suffix)
	id, err := r.docker.Create(ctx, ContainerConfig{
		Name:       "hiro-" + sanitize(spec.TicketKey) + "-" + hex.EncodeToString(suffix),
		Image:      spec.Image,
		User:       agentUser,
		WorkingDir: workDir,
		Cmd:        []string{"sleep", "infinity"},
		Labels:     map[string]string{"hiro.ticket": spec.TicketKey},
		Network:    r.cfg.Network,
		MemoryMB:   r.cfg.MemoryMB,
		CPUs:       r.cfg.CPUs,
		PIDs:       r.cfg.PIDs,
		Volumes:    []string{workDir, homeDir, outDir},
		Tmpfs:      map[string]string{"/tmp": "rw,exec,nosuid,size=2g"},
		Env:        proxyEnv(r.cfg.Proxy),
	})
	if err != nil {
		return nil, err
	}
	ws := &workspace{docker: r.docker, id: id, token: r.token}
	fail := func(err error) (orchestrator.Workspace, error) {
		_ = r.docker.Remove(context.WithoutCancel(ctx), id)
		return nil, err
	}
	if err := r.docker.PutArchive(ctx, id, workDir, spec.Repo); err != nil {
		return fail(fmt.Errorf("copy repository: %w", err))
	}
	if len(spec.ClaudeHome) > 0 {
		if err := r.docker.PutArchive(ctx, id, homeDir, bytes.NewReader(spec.ClaudeHome)); err != nil {
			return fail(fmt.Errorf("restore claude session: %w", err))
		}
	}
	if err := r.docker.Start(ctx, id); err != nil {
		return fail(err)
	}
	return ws, nil
}

// proxyEnv points every tool in the container (Claude Code, git, go, npm,
// pip) at the egress proxy.
func proxyEnv(proxy string) []string {
	if proxy == "" {
		return nil
	}
	env := []string{}
	for _, k := range []string{"HTTPS_PROXY", "HTTP_PROXY", "https_proxy", "http_proxy"} {
		env = append(env, k+"="+proxy)
	}
	return append(env, "NO_PROXY=localhost,127.0.0.1", "no_proxy=localhost,127.0.0.1")
}

type workspace struct {
	docker *Docker
	id     string
	token  TokenSource
}

func (w *workspace) ID() string { return w.id }

// timeoutCmd wraps argv in coreutils timeout so the process inside the
// container is killed too, not just our stream.
func timeoutCmd(d time.Duration, argv ...string) []string {
	if d <= 0 {
		return argv
	}
	secs := strconv.Itoa(int(d.Seconds()))
	return append([]string{"timeout", "--kill-after=15", secs}, argv...)
}

func (w *workspace) Claude(ctx context.Context, req orchestrator.ClaudeRequest, onEvent func(orchestrator.ClaudeEvent)) (orchestrator.ClaudeResult, error) {
	token, err := w.token(ctx)
	if err != nil {
		return orchestrator.ClaudeResult{}, fmt.Errorf("claude token: %w", err)
	}
	if token == "" {
		return orchestrator.ClaudeResult{}, errors.New("claude is not connected; run `hiro integration set claude`")
	}
	argv := []string{"claude", "-p", req.Prompt,
		"--output-format", "stream-json", "--verbose",
		"--permission-mode", "dontAsk"}
	if req.Model != "" {
		argv = append(argv, "--model", req.Model)
	}
	if req.MaxTurns > 0 {
		argv = append(argv, "--max-turns", strconv.Itoa(req.MaxTurns))
	}
	if req.Resume != "" {
		argv = append(argv, "--resume", req.Resume)
	}
	if req.Settings != "" {
		argv = append(argv, "--settings", req.Settings)
	}

	pr, pw := io.Pipe()
	var stderr tailBuffer
	type execOut struct {
		code int
		err  error
	}
	done := make(chan execOut, 1)
	go func() {
		code, err := w.docker.Exec(ctx, w.id, ExecConfig{
			Cmd:        timeoutCmd(req.Timeout, argv...),
			User:       agentUser,
			WorkingDir: workDir,
			Env: []string{
				"CLAUDE_CODE_OAUTH_TOKEN=" + token,
				"CLAUDE_CONFIG_DIR=" + claudeHome,
				"DISABLE_AUTOUPDATER=1",
			},
		}, pw, &stderr)
		_ = pw.CloseWithError(err)
		done <- execOut{code, err}
	}()

	start := time.Now()
	res, perr := ParseStream(pr, onEvent)
	_, _ = io.Copy(io.Discard, pr) // drain so Exec can finish
	out := <-done
	if res.Duration == 0 {
		res.Duration = time.Since(start)
	}
	switch {
	case out.err != nil:
		return res, out.err
	case out.code == 124:
		return res, fmt.Errorf("claude timed out after %s", req.Timeout)
	case perr != nil:
		return res, fmt.Errorf("%w (exit %d): %s", perr, out.code, stderr.String())
	}
	return res, nil
}

func (w *workspace) Exec(ctx context.Context, cmd string, timeout time.Duration) (orchestrator.ExecResult, error) {
	var buf tailBuffer
	start := time.Now()
	code, err := w.docker.Exec(ctx, w.id, ExecConfig{
		Cmd:        timeoutCmd(timeout, "bash", "-c", cmd), // not -l: /etc/profile would reset PATH
		User:       agentUser,
		WorkingDir: workDir,
	}, &buf, &buf)
	return orchestrator.ExecResult{
		ExitCode: code, Output: buf.String(), Duration: time.Since(start), TimedOut: code == 124,
	}, err
}

func (w *workspace) ReadFile(ctx context.Context, path string) ([]byte, error) {
	rc, err := w.docker.GetArchive(ctx, w.id, path)
	if err != nil {
		return nil, err
	}
	defer func() { _ = rc.Close() }()
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil, domain.ErrNotFound
			}
			return nil, err
		}
		if h.Typeflag == tar.TypeReg {
			return io.ReadAll(io.LimitReader(tr, 4<<20))
		}
	}
}

func (w *workspace) WriteFile(ctx context.Context, p string, data []byte) error {
	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	if err := tw.WriteHeader(&tar.Header{
		Name: path.Base(p), Mode: 0o644, Size: int64(len(data)), Typeflag: tar.TypeReg,
		Uid: agentUID, Gid: agentUID, Uname: agentUser, Gname: agentUser, ModTime: time.Now(),
	}); err != nil {
		return err
	}
	if _, err := tw.Write(data); err != nil {
		return err
	}
	if err := tw.Close(); err != nil {
		return err
	}
	return w.docker.PutArchive(ctx, w.id, path.Dir(p), &buf)
}

// ExportRepo streams a tar of the files git would see in /workspace:
// tracked and untracked-but-not-ignored. Build output and dependencies
// (node_modules, target/, ...) stay in the container. Paths are relative.
func (w *workspace) ExportRepo(ctx context.Context) (io.ReadCloser, error) {
	pr, pw := io.Pipe()
	var stderr tailBuffer
	go func() {
		code, err := w.docker.Exec(ctx, w.id, ExecConfig{
			Cmd:        []string{"bash", "-c", "set -o pipefail; git ls-files -z -co --exclude-standard | tar --null --no-recursion --ignore-failed-read -T - -cf -"},
			User:       agentUser,
			WorkingDir: workDir,
		}, pw, &stderr)
		if err == nil && code != 0 {
			err = fmt.Errorf("export workspace (exit %d): %s", code, stderr.String())
		}
		_ = pw.CloseWithError(err)
	}()
	return pr, nil
}

func (w *workspace) ExportClaudeHome(ctx context.Context) ([]byte, error) {
	rc, err := w.docker.GetArchive(ctx, w.id, claudeHome)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	defer func() { _ = rc.Close() }()
	return io.ReadAll(io.LimitReader(rc, 256<<20))
}

func (w *workspace) Close(ctx context.Context) error {
	return w.docker.Remove(ctx, w.id)
}

// tailBuffer keeps the last 256 KiB written to it.
type tailBuffer struct {
	mu  sync.Mutex
	buf []byte
}

const tailMax = 256 << 10

func (t *tailBuffer) Write(p []byte) (int, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.buf = append(t.buf, p...)
	if len(t.buf) > tailMax {
		t.buf = append([]byte(nil), t.buf[len(t.buf)-tailMax:]...)
	}
	return len(p), nil
}

func (t *tailBuffer) String() string {
	t.mu.Lock()
	defer t.mu.Unlock()
	return string(t.buf)
}

func sanitize(s string) string {
	return strings.Map(func(r rune) rune {
		if r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '-' || r == '_' {
			return r
		}
		return '-'
	}, s)
}
