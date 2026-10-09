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
	"maps"
	"net/url"
	"path"
	"strconv"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Paths inside the runner image (deploy/runner/Dockerfile).
const (
	workDir    = "/workspace"
	homeDir    = "/home/agent"
	claudeHome = "/home/agent/.claude"
	outDir     = "/agnts/out"
	agentUser  = "agent"
	agentUID   = 1000 // the image's agent user, owner of files agnts writes
)

// Config sets container limits.
type Config struct {
	Network  string // user-defined bridge for run containers
	Proxy    string // egress proxy URL; with an internal network, the only way out
	MemoryMB int64
	CPUs     float64
	PIDs     int64
	// MaxMemoryMB caps a repository's memory override.
	MaxMemoryMB int64
	// ToolchainVolume is the shared volume mise installs toolchains into.
	ToolchainVolume string
	// Runtime is the OCI runtime for run containers (runsc: gVisor); ""
	// is Docker's default.
	Runtime string
	// NetworkPerRun gives every run a network of its own, so runs cannot
	// reach each other; the egress proxy container (ProxyContainer) joins
	// each one.
	NetworkPerRun  bool
	ProxyContainer string
	// StampDir keeps a file per package cache, touched on every use, so
	// caches nobody used for a while can be emptied.
	StampDir string
	// Models are the full model ids for agnts's short names (opus, sonnet,
	// haiku). Claude Code resolves a short name to the newest model it
	// knows, so a pinned older release would pick older models; a full id
	// does not depend on the release.
	Models map[string]string
}

// DefaultModels are the current Claude models.
var DefaultModels = map[string]string{
	"opus":   "claude-opus-5-5",
	"sonnet": "claude-sonnet-5-5",
	"haiku":  "claude-haiku-5-5",
}

// DefaultConfig returns limits for a small VPS.
func DefaultConfig() Config {
	return Config{Network: "agnts-runs", MemoryMB: 4096, CPUs: 2, PIDs: 1024, MaxMemoryMB: 8192, ToolchainVolume: "agnts-toolchains",
		Models: maps.Clone(DefaultModels)}
}

// Credential is how Claude Code reaches Claude: Env is the variable it
// reads the token from (CLAUDE_CODE_OAUTH_TOKEN for a subscription,
// ANTHROPIC_API_KEY for an API key).
type Credential struct {
	Env   string
	Token string
}

// TokenSource returns the credential of the account a run uses (from its
// context) at the moment it calls Claude, so a rotated token is picked up
// without a restart.
type TokenSource func(ctx context.Context) (Credential, error)

// Runner implements orchestrator.Runner with Docker.
type Runner struct {
	docker *Docker
	cfg    Config
	token  TokenSource

	netOnce sync.Once
	netErr  error
	prov    provisioner
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
	specs := specsOf(spec.Toolchains)
	var prov provisioned
	if len(specs) > 0 {
		var err error
		if prov, err = r.provision(ctx, spec.Image, specs, spec.Progress); err != nil {
			return nil, err
		}
	}
	var mounts []Mount
	if len(spec.Toolchains) > 0 {
		mounts = append(mounts, Mount{Volume: r.cfg.ToolchainVolume, Target: toolchainDir, ReadOnly: true})
	}
	if spec.CacheKey != "" {
		vol := "agnts-cache-" + sanitize(spec.CacheKey)
		if err := r.docker.EnsureVolume(ctx, vol, map[string]string{"agnts": "cache", "agnts.cache": spec.CacheKey}); err != nil {
			return nil, fmt.Errorf("cache volume: %w", err)
		}
		mounts = append(mounts, Mount{Volume: vol, Target: cacheDir})
		r.stampCache(vol)
	}
	memory := r.cfg.MemoryMB
	if spec.MemoryMB > 0 {
		memory = min(int64(spec.MemoryMB), max(r.cfg.MaxMemoryMB, r.cfg.MemoryMB))
	}
	suffix := make([]byte, 3)
	_, _ = rand.Read(suffix)
	network, ownNet := r.cfg.Network, ""
	if r.cfg.NetworkPerRun {
		ownNet = "agnts-run-" + hex.EncodeToString(suffix)
		if err := r.runNetwork(ctx, ownNet); err != nil {
			return nil, fmt.Errorf("run network: %w", err)
		}
		network = ownNet
	}
	id, err := r.docker.Create(ctx, ContainerConfig{
		Name:       "agnts-" + strconv.FormatInt(domain.WorkspaceOf(ctx), 10) + "-" + sanitize(spec.TicketKey) + "-" + hex.EncodeToString(suffix),
		Image:      spec.Image,
		User:       agentUser,
		WorkingDir: workDir,
		Cmd:        []string{"sleep", "infinity"},
		Labels:     map[string]string{"agnts.ticket": spec.TicketKey, "agnts.workspace": strconv.FormatInt(domain.WorkspaceOf(ctx), 10)},
		Network:    network,
		MemoryMB:   memory,
		Runtime:    r.cfg.Runtime,
		CPUs:       r.cfg.CPUs,
		PIDs:       r.cfg.PIDs,
		Volumes:    []string{workDir, homeDir, outDir},
		Mounts:     mounts,
		Tmpfs:      map[string]string{"/tmp": "rw,exec,nosuid,size=2g"},
		Env:        runEnv(r.cfg.Proxy, spec.Toolchains, prov, spec.Env),
	})
	if err != nil {
		if ownNet != "" {
			_ = r.docker.RemoveNetwork(context.WithoutCancel(ctx), ownNet, r.cfg.ProxyContainer)
		}
		return nil, err
	}
	ws := &workspace{docker: r.docker, id: id, token: r.token, memoryMB: memory, network: ownNet, proxy: r.cfg.ProxyContainer, models: r.cfg.Models}
	fail := func(err error) (orchestrator.Workspace, error) {
		_ = ws.Close(context.WithoutCancel(ctx))
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
	if len(spec.Toolchains) > 0 {
		res, err := ws.Exec(ctx, setupScript, 5*time.Minute)
		if out := strings.TrimSpace(res.Output); spec.Progress != nil && (err != nil || out != "") {
			if err != nil {
				out = err.Error()
			}
			spec.Progress("environment setup: " + tail(out, 1000))
		}
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
	env = append(env, "NO_PROXY=localhost,127.0.0.1", "no_proxy=localhost,127.0.0.1")
	// The JVM ignores the variables above: Maven, Gradle and sbt need
	// system properties, which JAVA_TOOL_OPTIONS gives every JVM.
	if u, err := url.Parse(proxy); err == nil && u.Hostname() != "" {
		port := u.Port()
		if port == "" {
			port = "80"
		}
		h := u.Hostname()
		env = append(env, "JAVA_TOOL_OPTIONS=-Dhttp.proxyHost="+h+" -Dhttp.proxyPort="+port+
			" -Dhttps.proxyHost="+h+" -Dhttps.proxyPort="+port+" -Dhttp.nonProxyHosts=localhost|127.0.0.1")
	}
	return env
}

type workspace struct {
	docker   *Docker
	id       string
	token    TokenSource
	memoryMB int64
	// network is the run's own network ("" on the shared one), removed
	// with the container; proxy is the egress proxy that joined it.
	network, proxy string
	models         map[string]string
}

// runNetwork creates a run's own network: internal (no route out) when
// the egress proxy is the way out, which then joins it under the name in
// the proxy URL.
func (r *Runner) runNetwork(ctx context.Context, name string) error {
	internal := r.cfg.Proxy != ""
	if err := r.docker.CreateNetwork(ctx, name, internal, map[string]string{"agnts": "run"}); err != nil {
		return err
	}
	if !internal || r.cfg.ProxyContainer == "" {
		return nil
	}
	alias := ""
	if u, err := url.Parse(r.cfg.Proxy); err == nil {
		alias = u.Hostname()
	}
	if err := r.docker.ConnectNetwork(ctx, name, r.cfg.ProxyContainer, []string{alias}); err != nil {
		_ = r.docker.RemoveNetwork(context.WithoutCancel(ctx), name, "")
		return fmt.Errorf("connect the egress proxy: %w", err)
	}
	return nil
}

// errOOM explains a run the kernel killed at its memory limit.
func (w *workspace) errOOM(ctx context.Context, code int) error {
	if code != 137 {
		return nil
	}
	if oom, err := w.docker.OOMKilled(context.WithoutCancel(ctx), w.id); err != nil || !oom {
		return nil
	}
	return &orchestrator.OOMError{LimitMB: w.memoryMB}
}

func (w *workspace) ID() string { return w.id }

// modelID is the full id for a short model name; anything else (a full
// id already, or a name without a mapping) goes to Claude Code as is.
func modelID(models map[string]string, name string) string {
	if id := models[name]; id != "" {
		return id
	}
	return name
}

// modelEnv points Claude Code's own short names at the same models: it
// uses them for sub-agents and its quick background calls.
func modelEnv(models map[string]string) []string {
	var env []string
	for _, name := range []string{"opus", "sonnet", "haiku"} {
		if id := models[name]; id != "" {
			env = append(env, "ANTHROPIC_DEFAULT_"+strings.ToUpper(name)+"_MODEL="+id)
		}
	}
	return env
}

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
	cred, err := w.token(ctx)
	if err != nil {
		return orchestrator.ClaudeResult{}, fmt.Errorf("claude token: %w", err)
	}
	if cred.Token == "" {
		return orchestrator.ClaudeResult{}, errors.New("claude is not connected: connect an account in Workspace settings → Claude")
	}
	if cred.Env == "" {
		cred.Env = "CLAUDE_CODE_OAUTH_TOKEN"
	}
	argv := []string{"claude", "-p", req.Prompt,
		"--output-format", "stream-json", "--verbose",
		"--permission-mode", "dontAsk"}
	if req.Model != "" {
		argv = append(argv, "--model", modelID(w.models, req.Model))
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
			Env: append([]string{
				cred.Env + "=" + cred.Token,
				"CLAUDE_CONFIG_DIR=" + claudeHome,
				"DISABLE_AUTOUPDATER=1",
			}, modelEnv(w.models)...),
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
	if oom := w.errOOM(ctx, out.code); oom != nil {
		return res, oom
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
	if oom := w.errOOM(ctx, code); oom != nil && err == nil {
		err = oom
	}
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
	err := w.docker.Remove(ctx, w.id)
	if w.network != "" {
		err = errors.Join(err, w.docker.RemoveNetwork(ctx, w.network, w.proxy))
	}
	return err
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
