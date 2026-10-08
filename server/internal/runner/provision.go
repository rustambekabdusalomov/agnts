package runner

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Paths for toolchains and caches (deploy/runner/Dockerfile creates them
// owned by the agent user, so new volumes start out writable for it).
const (
	toolchainDir = "/opt/toolchains"
	cacheDir     = "/home/agent/.cache"
)

// provisioned is what a set of toolchains adds to a run container's
// environment: PATH entries and variables such as JAVA_HOME or GOROOT.
type provisioned struct {
	path     []string // toolchain bin directories, in mise's order
	basePath string   // the image's PATH
	env      []string // KEY=value
	at       time.Time
}

// provisionTTL is how long a resolved toolchain set is trusted before mise
// is asked again (so "node@20" moves to a new 20.x eventually).
const provisionTTL = 6 * time.Hour

// installTimeout bounds one mise install (compiling Erlang can take long).
const installTimeout = 30 * time.Minute

type provisioner struct {
	install sync.Mutex // one provision container at a time
	mu      sync.Mutex // guards cache; never held during an install
	cache   map[string]provisioned
}

func (p *provisioner) get(key string) (provisioned, bool) {
	p.mu.Lock()
	defer p.mu.Unlock()
	v, ok := p.cache[key]
	return v, ok && time.Since(v.at) < provisionTTL
}

func (p *provisioner) put(key string, v provisioned) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.cache == nil {
		p.cache = map[string]provisioned{}
	}
	p.cache[key] = v
}

// specsOf returns the mise specs to install: "system" toolchains come
// with the image and need nothing.
func specsOf(tcs []domain.Toolchain) []string {
	var out []string
	for _, t := range tcs {
		if t.Version == "system" || t.Validate() != nil {
			continue
		}
		out = append(out, t.Spec())
	}
	slices.Sort(out)
	return slices.Compact(out)
}

// provision installs specs into the toolchain volume (if needed) and
// returns the environment they need. Installs happen in a container of
// their own that never sees repository code and is the only one with the
// volume writable; mise is given exact tool@version arguments built and
// checked by agnts, so no repository config, plugin or hook runs.
func (r *Runner) provision(ctx context.Context, image string, specs []string, progress func(string)) (provisioned, error) {
	key := image + "|" + strings.Join(specs, " ")
	if p, ok := r.prov.get(key); ok {
		return p, nil
	}
	r.prov.install.Lock()
	defer r.prov.install.Unlock()
	if p, ok := r.prov.get(key); ok {
		return p, nil // installed while this run waited
	}
	if err := r.docker.EnsureVolume(ctx, r.cfg.ToolchainVolume, map[string]string{"agnts": "toolchains"}); err != nil {
		return provisioned{}, fmt.Errorf("toolchain volume: %w", err)
	}
	suffix := make([]byte, 3)
	_, _ = rand.Read(suffix)
	id, err := r.docker.Create(ctx, ContainerConfig{
		Name:       "agnts-provision-" + hex.EncodeToString(suffix),
		Image:      image,
		User:       agentUser,
		WorkingDir: "/tmp",
		Cmd:        []string{"sleep", "infinity"},
		Labels:     map[string]string{"agnts.provision": "1"},
		Network:    r.cfg.Network,
		MemoryMB:   r.cfg.MemoryMB,
		CPUs:       r.cfg.CPUs,
		PIDs:       r.cfg.PIDs,
		Volumes:    []string{homeDir},
		Mounts:     []Mount{{Volume: r.cfg.ToolchainVolume, Target: toolchainDir}},
		Tmpfs:      map[string]string{"/tmp": "rw,exec,nosuid,size=2g"},
		Env:        proxyEnv(r.cfg.Proxy),
	})
	if err != nil {
		return provisioned{}, err
	}
	defer func() { _ = r.docker.Remove(context.WithoutCancel(ctx), id) }()
	if err := r.docker.Start(ctx, id); err != nil {
		return provisioned{}, err
	}
	exec := func(timeout time.Duration, argv ...string) (int, string, error) {
		var buf tailBuffer
		code, err := r.docker.Exec(ctx, id, ExecConfig{Cmd: timeoutCmd(timeout, argv...), User: agentUser, WorkingDir: "/tmp",
			Env: []string{"NO_COLOR=1"}}, &buf, &buf)
		return code, stripANSI(buf.String()), err
	}

	install := append([]string{"mise", "install", "--yes"}, specs...)
	code, out, err := exec(installTimeout, install...)
	if err != nil {
		return provisioned{}, fmt.Errorf("mise install: %w", err)
	}
	if code != 0 {
		return provisioned{}, &orchestrator.ToolchainError{Spec: strings.Join(specs, " "), Output: tail(misePlain(out), 3000)}
	}
	if progress != nil {
		for _, line := range installedLines(out) {
			progress("installed " + line + " (kept for later runs)")
		}
	}
	code, base, err := exec(time.Minute, "env", "-0")
	if err != nil || code != 0 {
		return provisioned{}, fmt.Errorf("read image environment (exit %d): %w", code, err)
	}
	code, with, err := exec(5*time.Minute, append(append([]string{"mise", "exec"}, specs...), "--", "env", "-0")...)
	if err != nil || code != 0 {
		return provisioned{}, &orchestrator.ToolchainError{Spec: strings.Join(specs, " "), Output: tail(misePlain(with), 3000)}
	}
	p := envDiff(parseEnv0(base), parseEnv0(with))
	p.at = time.Now()
	r.prov.put(key, p)
	return p, nil
}

func tail(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return "…" + s[len(s)-n:]
}

var ansiRe = regexp.MustCompile(`\x1b\[[0-9;]*[A-Za-z]`)

// stripANSI removes terminal colour codes (mise colours even without a TTY).
func stripANSI(s string) string { return ansiRe.ReplaceAllString(s, "") }

// misePlain drops mise's progress bar lines and its "not activated"
// warnings (agnts activates toolchains itself) from its output.
func misePlain(out string) string {
	var keep []string
	for _, line := range strings.Split(out, "\n") {
		if strings.ContainsAny(line, "░█") || strings.Contains(line, "not activated") {
			continue
		}
		keep = append(keep, line)
	}
	return strings.Join(keep, "\n")
}

// installedLines picks "python@3.12.15" from mise's "mise ✓ python@3.12.15  15.1s ..." lines.
func installedLines(out string) []string {
	var got []string
	for _, line := range strings.Split(out, "\n") {
		_, rest, ok := strings.Cut(line, "✓ ")
		if !ok {
			continue
		}
		if f := strings.Fields(rest); len(f) > 0 && strings.Contains(f[0], "@") && !slices.Contains(got, f[0]) {
			got = append(got, f[0])
		}
	}
	return got
}

func parseEnv0(s string) map[string]string {
	env := map[string]string{}
	for _, kv := range strings.Split(s, "\x00") {
		if k, v, ok := strings.Cut(kv, "="); ok && k != "" && !strings.ContainsAny(k, "\n ") {
			env[k] = v
		}
	}
	return env
}

// envDiff keeps what mise exec added to the image's environment: PATH
// entries it put in front and the variables it set (JAVA_HOME, GOROOT,
// RUSTUP_TOOLCHAIN, ...), minus mise's own bookkeeping.
func envDiff(base, with map[string]string) provisioned {
	p := provisioned{basePath: base["PATH"]}
	have := map[string]bool{}
	for _, e := range strings.Split(base["PATH"], ":") {
		have[e] = true
	}
	for _, e := range strings.Split(with["PATH"], ":") {
		if e != "" && !have[e] {
			have[e] = true
			p.path = append(p.path, e)
		}
	}
	keys := make([]string, 0, len(with))
	for k, v := range with {
		switch {
		case k == "PATH", k == "_", k == "PWD", k == "OLDPWD", k == "SHLVL", k == "HOSTNAME", k == "HOME",
			strings.HasPrefix(k, "MISE_"), strings.HasPrefix(k, "__MISE"):
			continue
		}
		if base[k] != v {
			keys = append(keys, k)
		}
	}
	slices.Sort(keys)
	for _, k := range keys {
		p.env = append(p.env, k+"="+with[k])
	}
	return p
}

// cacheEnv points every package manager's cache, and every directory a
// tool installs into, at the writable home (the per-repository cache
// volume where there is one): toolchains themselves are read-only.
var cacheEnv = []string{
	"GOPATH=/home/agent/go", "GOBIN=/home/agent/go/bin", "GOMODCACHE=" + cacheDir + "/go-mod", "GOCACHE=" + cacheDir + "/go-build",
	"GOFLAGS=-buildvcs=false",
	"CARGO_HOME=" + cacheDir + "/cargo",
	"npm_config_cache=" + cacheDir + "/npm", "NPM_CONFIG_PREFIX=/home/agent/.npm-global",
	"COREPACK_HOME=" + cacheDir + "/corepack", "COREPACK_ENABLE_DOWNLOAD_PROMPT=0",
	"YARN_CACHE_FOLDER=" + cacheDir + "/yarn", "PNPM_HOME=/home/agent/.local/share/pnpm", "BUN_INSTALL_CACHE_DIR=" + cacheDir + "/bun",
	"DENO_DIR=" + cacheDir + "/deno",
	"PIP_CACHE_DIR=" + cacheDir + "/pip", "PIP_DISABLE_PIP_VERSION_CHECK=1", "UV_CACHE_DIR=" + cacheDir + "/uv",
	"POETRY_CACHE_DIR=" + cacheDir + "/poetry", "POETRY_VIRTUALENVS_CREATE=false", "PIPENV_VENV_IN_PROJECT=0",
	"GRADLE_USER_HOME=" + cacheDir + "/gradle", "MAVEN_OPTS=-Dmaven.repo.local=" + cacheDir + "/m2", "MAVEN_USER_HOME=" + cacheDir + "/m2-wrapper",
	"SBT_OPTS=-Dsbt.global.base=" + cacheDir + "/sbt -Dsbt.ivy.home=" + cacheDir + "/ivy2 -Dsbt.boot.directory=" + cacheDir + "/sbt-boot",
	"COURSIER_CACHE=" + cacheDir + "/coursier",
	"NUGET_PACKAGES=" + cacheDir + "/nuget", "DOTNET_CLI_HOME=/home/agent", "DOTNET_CLI_TELEMETRY_OPTOUT=1", "DOTNET_NOLOGO=1",
	"DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1",
	"GEM_HOME=" + cacheDir + "/gems", "BUNDLE_PATH=" + cacheDir + "/bundle", "BUNDLE_USER_HOME=" + cacheDir + "/bundle-home",
	"COMPOSER_HOME=" + cacheDir + "/composer",
	"MIX_HOME=" + cacheDir + "/mix", "HEX_HOME=" + cacheDir + "/hex", "REBAR_CACHE_DIR=" + cacheDir + "/rebar3",
	"PUB_CACHE=" + cacheDir + "/pub", "STACK_ROOT=" + cacheDir + "/stack", "JULIA_DEPOT_PATH=" + cacheDir + "/julia",
	"ZIG_GLOBAL_CACHE_DIR=" + cacheDir + "/zig", "NIMBLE_DIR=" + cacheDir + "/nimble",
}

// homeBins are the writable bin directories, ahead of the toolchains on
// PATH: tools a run installs itself (go install, npm -g, cargo install,
// gem install, corepack's pnpm and yarn).
var homeBins = []string{
	"/home/agent/.local/bin", "/home/agent/go/bin", "/home/agent/.npm-global/bin", cacheDir + "/cargo/bin", cacheDir + "/gems/bin",
	"/home/agent/.local/share/pnpm",
}

// venvDir is where a repository's Python virtualenv lives: in its cache
// volume, so installed packages survive between runs, one per Python spec.
func venvDir(tcs []domain.Toolchain) string {
	for _, t := range tcs {
		if t.Tool == "python" {
			return cacheDir + "/venv-" + strings.Map(func(r rune) rune {
				if r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '.' || r == '-' {
					return r
				}
				return '_'
			}, t.Version)
		}
	}
	return ""
}

// runEnv is a run container's environment, later entries winning.
func runEnv(proxy string, tcs []domain.Toolchain, p provisioned, extra []string) []string {
	var env []string
	env = append(env, proxyEnv(proxy)...)
	if len(tcs) > 0 {
		env = append(env, p.env...)
		env = append(env, cacheEnv...)
		path := slices.Clone(homeBins)
		if v := venvDir(tcs); v != "" {
			path = append([]string{v + "/bin"}, path...)
			env = append(env, "VIRTUAL_ENV="+v, "UV_PROJECT_ENVIRONMENT="+v)
		}
		path = append(path, p.path...)
		if p.basePath != "" {
			path = append(path, p.basePath)
		} else {
			path = append(path, "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
		}
		env = append(env, "PATH="+strings.Join(path, ":"))
	}
	env = append(env, extra...)
	return dedupeEnv(env)
}

// dedupeEnv keeps the last value of each variable, in first-seen order.
func dedupeEnv(env []string) []string {
	idx := map[string]int{}
	var out []string
	for _, kv := range env {
		k, _, _ := strings.Cut(kv, "=")
		if i, ok := idx[k]; ok {
			out[i] = kv
			continue
		}
		idx[k] = len(out)
		out = append(out, kv)
	}
	return out
}

// setupScript runs once in a new run container with toolchains: it
// creates the Python virtualenv (kept in the cache volume) and puts
// corepack's pnpm and yarn shims in a writable directory. Failures are
// reported, not fatal: the checks will say what is missing.
const setupScript = `set -u
mkdir -p "$HOME/.local/bin"
if [ -n "${VIRTUAL_ENV:-}" ] && [ ! -x "$VIRTUAL_ENV/bin/python" ]; then
  py=$(command -v python3 || true)
  if [ -n "$py" ]; then "$py" -m venv "$VIRTUAL_ENV" || echo "could not create the Python virtualenv"; fi
fi
if command -v corepack >/dev/null 2>&1; then
  corepack enable --install-directory "$HOME/.local/bin" >/dev/null 2>&1 || true
fi
# Maven reads its proxy only from settings.xml (Gradle and sbt take the
# JAVA_TOOL_OPTIONS properties).
if [ -n "${HTTPS_PROXY:-}" ] && command -v java >/dev/null 2>&1 && [ ! -e "$HOME/.m2/settings.xml" ]; then
  hp=${HTTPS_PROXY#*://}; hp=${hp%%/*}; host=${hp%:*}; port=${hp##*:}
  [ "$port" = "$hp" ] && port=80
  mkdir -p "$HOME/.m2"
  for proto in https http; do
    printf '<proxy><id>agnts-%s</id><active>true</active><protocol>%s</protocol><host>%s</host><port>%s</port><nonProxyHosts>localhost|127.0.0.1</nonProxyHosts></proxy>' "$proto" "$proto" "$host" "$port"
  done | { printf '<settings><proxies>'; cat; printf '</proxies></settings>\n'; } > "$HOME/.m2/settings.xml"
fi
`

// ImageOK checks that a custom runner image exists on the server and was
// built from the agnts runner image (it carries the agnts.runner label).
func (r *Runner) ImageOK(ctx context.Context, image string) error {
	if !domain.ValidImage(image) {
		return fmt.Errorf("%q is not a Docker image name", image)
	}
	labels, err := r.docker.ImageLabels(ctx, image)
	if err != nil {
		return err
	}
	if labels["agnts.runner"] == "" {
		return fmt.Errorf("image %s was not built FROM the agnts runner image (it has no agnts.runner label)", image)
	}
	return nil
}

// SweepCaches deletes repository cache volumes over maxBytes that no
// container uses; the next run of that repository starts with an empty
// cache. It returns the volumes removed.
func (r *Runner) SweepCaches(ctx context.Context, maxBytes int64) ([]string, error) {
	vols, err := r.docker.Volumes(ctx)
	if err != nil {
		return nil, err
	}
	var removed []string
	for _, v := range vols {
		if v.Labels["agnts"] != "cache" || v.Size <= maxBytes || v.RefCount > 0 {
			continue
		}
		if err := r.docker.RemoveVolume(ctx, v.Name); err != nil {
			continue // in use by now
		}
		removed = append(removed, v.Name)
	}
	return removed, nil
}

// stampCache records that a package cache volume was used now.
func (r *Runner) stampCache(vol string) {
	if r.cfg.StampDir == "" {
		return
	}
	if err := os.MkdirAll(r.cfg.StampDir, 0o750); err != nil {
		return
	}
	p := filepath.Join(r.cfg.StampDir, vol)
	now := time.Now()
	if err := os.Chtimes(p, now, now); err != nil {
		_ = os.WriteFile(p, nil, 0o600)
	}
}

// SweepIdleCaches empties package caches no run used for idle (a cache
// never stamped counts from the first sweep that sees it).
func (r *Runner) SweepIdleCaches(ctx context.Context, idle time.Duration) ([]string, error) {
	if r.cfg.StampDir == "" || idle <= 0 {
		return nil, nil
	}
	vols, err := r.docker.Volumes(ctx)
	if err != nil {
		return nil, err
	}
	var removed []string
	for _, v := range vols {
		if v.Labels["agnts"] != "cache" || v.RefCount > 0 {
			continue
		}
		st, err := os.Stat(filepath.Join(r.cfg.StampDir, v.Name))
		if err != nil {
			r.stampCache(v.Name)
			continue
		}
		if time.Since(st.ModTime()) < idle {
			continue
		}
		if err := r.docker.RemoveVolume(ctx, v.Name); err != nil {
			continue // in use by now
		}
		_ = os.Remove(filepath.Join(r.cfg.StampDir, v.Name))
		removed = append(removed, v.Name)
	}
	return removed, nil
}

// RemoveCache deletes a package cache (its repository was archived or its
// workspace deleted); a missing one is not an error.
func (r *Runner) RemoveCache(ctx context.Context, key string) error {
	vol := "agnts-cache-" + sanitize(key)
	err := r.docker.RemoveVolume(ctx, vol)
	var ae *apiError
	if errors.As(err, &ae) && ae.Status == http.StatusNotFound {
		err = nil
	}
	if err == nil && r.cfg.StampDir != "" {
		_ = os.Remove(filepath.Join(r.cfg.StampDir, vol))
	}
	return err
}
