package runner

import (
	"archive/tar"
	"bytes"
	"context"
	"io"
	"os"
	"slices"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestEnvDiff(t *testing.T) {
	base := parseEnv0("PATH=/usr/local/bin:/usr/bin\x00HOME=/home/agent\x00LANG=C.UTF-8\x00")
	with := parseEnv0(strings.Join([]string{
		"PATH=/opt/toolchains/installs/go/1.24.13/bin:/opt/toolchains/cargo/bin:/usr/local/bin:/usr/bin",
		"HOME=/home/agent", "LANG=C.UTF-8", "GOROOT=/opt/toolchains/installs/go/1.24.13", "RUSTUP_TOOLCHAIN=stable",
		"__MISE_DIFF=xyz", "MISE_DATA_DIR=/opt/toolchains", "_=/usr/local/bin/mise",
	}, "\x00"))
	p := envDiff(base, with)
	if want := []string{"/opt/toolchains/installs/go/1.24.13/bin", "/opt/toolchains/cargo/bin"}; !slices.Equal(p.path, want) {
		t.Errorf("path = %v, want %v", p.path, want)
	}
	if want := []string{"GOROOT=/opt/toolchains/installs/go/1.24.13", "RUSTUP_TOOLCHAIN=stable"}; !slices.Equal(p.env, want) {
		t.Errorf("env = %v, want %v", p.env, want)
	}
	if p.basePath != "/usr/local/bin:/usr/bin" {
		t.Errorf("base path = %q", p.basePath)
	}
}

func TestRunEnv(t *testing.T) {
	tcs := []domain.Toolchain{{Tool: "python", Version: "3.12"}, {Tool: "go", Version: "1.24"}}
	p := provisioned{
		path:     []string{"/opt/toolchains/installs/python/3.12/bin", "/opt/toolchains/installs/go/1.24/bin"},
		basePath: "/usr/bin:/bin",
		env:      []string{"GOBIN=/opt/toolchains/installs/go/1.24/bin", "GOROOT=/opt/toolchains/installs/go/1.24"},
	}
	env := runEnv("http://egress:3128", tcs, p, []string{"NPM_TOKEN=x", "GOFLAGS=-mod=mod"})
	get := func(k string) string {
		for _, kv := range env {
			if v, ok := strings.CutPrefix(kv, k+"="); ok {
				return v
			}
		}
		return ""
	}
	if get("GOBIN") != "/home/agent/go/bin" {
		t.Errorf("GOBIN = %q: the read-only toolchain dir must not win", get("GOBIN"))
	}
	if get("GOROOT") != "/opt/toolchains/installs/go/1.24" || get("HTTPS_PROXY") != "http://egress:3128" || get("NPM_TOKEN") != "x" {
		t.Errorf("env = %v", env)
	}
	if !strings.Contains(get("JAVA_TOOL_OPTIONS"), "-Dhttps.proxyHost=egress -Dhttps.proxyPort=3128") {
		t.Errorf("JVM proxy settings missing: %q", get("JAVA_TOOL_OPTIONS"))
	}
	if get("GOFLAGS") != "-mod=mod" {
		t.Errorf("the build env must override defaults, GOFLAGS = %q", get("GOFLAGS"))
	}
	path := strings.Split(get("PATH"), ":")
	if path[0] != "/home/agent/.cache/venv-3.12/bin" || get("VIRTUAL_ENV") != "/home/agent/.cache/venv-3.12" {
		t.Errorf("the virtualenv must come first: %v", path)
	}
	py, sys := slices.Index(path, "/opt/toolchains/installs/python/3.12/bin"), slices.Index(path, "/usr/bin")
	if py < 0 || sys < py {
		t.Errorf("toolchains must come before the system: %v", path)
	}
	if n := len(slices.DeleteFunc(slices.Clone(env), func(kv string) bool { return !strings.HasPrefix(kv, "PATH=") })); n != 1 {
		t.Errorf("PATH set %d times", n)
	}

	if env := runEnv("", nil, provisioned{}, nil); len(env) != 0 {
		t.Errorf("no toolchains, no proxy: env = %v", env)
	}
}

func TestSpecsAndInstalled(t *testing.T) {
	got := specsOf([]domain.Toolchain{{Tool: "php", Version: "system"}, {Tool: "node", Version: "20"}, {Tool: "go", Version: "1.24"},
		{Tool: "bad;rm", Version: "1"}, {Tool: "node", Version: "20"}})
	if want := []string{"go@1.24", "node@20"}; !slices.Equal(got, want) {
		t.Errorf("specs = %v, want %v", got, want)
	}
	out := "mise ████ 0/1\nmise python@3.12.15 Python 3.12.15\nmise ✓ python@3.12.15  15.1s  cpython.tar.gz\nmise ✓ go@1.24.13 2s\n"
	if got := installedLines(out); !slices.Equal(got, []string{"python@3.12.15", "go@1.24.13"}) {
		t.Errorf("installed = %v", got)
	}
	if strings.Contains(misePlain(out), "█") {
		t.Error("progress bars kept")
	}
	colored := "\x1b[2mmise\x1b[0m \x1b[32m✓\x1b[0m \x1b[34mgo\x1b[0m@1.23.12  22.4s"
	if got := installedLines(stripANSI(colored)); !slices.Equal(got, []string{"go@1.23.12"}) {
		t.Errorf("installed from coloured output = %v", got)
	}
}

// testRunner is a Runner for the Docker tests. AGNTS_TEST_RUN_NETWORK and
// AGNTS_TEST_RUN_PROXY put runs behind an egress proxy as in production;
// AGNTS_TEST_TOOLCHAIN_VOLUME picks the toolchain volume (a fresh one makes
// every download go through the proxy).
func testRunner(t *testing.T, ctx context.Context) (*Runner, *Docker) {
	t.Helper()
	sock := os.Getenv("AGNTS_DOCKER_SOCKET")
	if sock == "" {
		sock = "/var/run/docker.sock"
	}
	d := NewDocker(sock)
	cfg := DefaultConfig()
	cfg.Network, cfg.ToolchainVolume, cfg.Proxy = "agnts-test-runs", "agnts-test-toolchains", os.Getenv("AGNTS_TEST_RUN_PROXY")
	if v := os.Getenv("AGNTS_TEST_RUN_NETWORK"); v != "" {
		cfg.Network = v
	}
	if v := os.Getenv("AGNTS_TEST_TOOLCHAIN_VOLUME"); v != "" {
		cfg.ToolchainVolume = v
	}
	if err := d.EnsureNetwork(ctx, cfg.Network, cfg.Proxy != ""); err != nil {
		t.Fatal(err)
	}
	return New(d, cfg, func(context.Context) (Credential, error) { return Credential{}, nil }), d
}

// Provisions real toolchains with the runner image when
// AGNTS_TEST_RUNNER_IMAGE is set (e.g. agnts-runner:latest, built from
// deploy/runner). Takes a few minutes the first time.
func TestProvisionDocker(t *testing.T) {
	image := os.Getenv("AGNTS_TEST_RUNNER_IMAGE")
	if image == "" {
		t.Skip("AGNTS_TEST_RUNNER_IMAGE not set")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Minute)
	defer cancel()
	r, _ := testRunner(t, ctx)

	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	var progress []string
	ws, err := r.Open(ctx, orchestrator.WorkspaceSpec{
		TicketKey: "test-provision", Image: image, Repo: &empty, CacheKey: "test",
		Toolchains: []domain.Toolchain{{Tool: "python", Version: "3.12"}, {Tool: "node", Version: "lts"}, {Tool: "go", Version: "1.24"}},
		Progress:   func(m string) { progress = append(progress, m) },
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = ws.Close(context.Background()) }()
	t.Logf("progress: %v", progress)
	if !slices.ContainsFunc(progress, func(m string) bool { return strings.Contains(m, "installed go@1.24") }) {
		t.Errorf("no progress line for the go install: %v", progress)
	}
	for _, c := range []struct{ cmd, want string }{
		{`python -c 'import ssl, sqlite3, sys; print(sys.prefix)'`, "/home/agent/.cache/venv-3.12"},
		{`pip install -q six && python -c 'import six; print("six ok")'`, "six ok"},
		{`node -e 'console.log("node", process.versions.node)'`, "node "},
		{`cd /tmp && mkdir -p n && cd n && npm init -y >/dev/null && npm install --silent left-pad && node -e 'console.log(require("left-pad")("ok", 4))'`, "  ok"},
		{`touch /opt/toolchains/x 2>&1 || echo read-only`, "read-only"},
		{`claude --version`, "Claude Code"},
		{`cd /tmp && mkdir -p g && cd g && printf 'module x\n\ngo 1.24\n' > go.mod && printf 'package main\nimport _ "github.com/google/uuid"\nfunc main(){}\n' > m.go && go get github.com/google/uuid && go build ./... && echo go ok`, "go ok"},
	} {
		res, err := ws.Exec(ctx, c.cmd, 3*time.Minute)
		if err != nil || res.ExitCode != 0 || !strings.Contains(res.Output, c.want) {
			t.Errorf("%s: exit %d, %v\n%s", c.cmd, res.ExitCode, err, res.Output)
		}
	}
	_, _ = io.Copy(io.Discard, &empty)
}

// With AGNTS_TEST_ALL_LANGUAGES=1 too, provisions and builds a hello world
// in the heavier languages (several minutes and a few GB the first time).
func TestProvisionLanguagesDocker(t *testing.T) {
	image := os.Getenv("AGNTS_TEST_RUNNER_IMAGE")
	if image == "" || os.Getenv("AGNTS_TEST_ALL_LANGUAGES") != "1" {
		t.Skip("AGNTS_TEST_RUNNER_IMAGE and AGNTS_TEST_ALL_LANGUAGES=1 not set")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 45*time.Minute)
	defer cancel()
	r, _ := testRunner(t, ctx)
	for _, c := range []struct {
		name string
		tcs  []domain.Toolchain
		cmd  string
		want string
	}{
		{"rust", []domain.Toolchain{{Tool: "rust", Version: "stable"}},
			`cd /tmp && cargo new -q hello && cd hello && cargo add -q itoa && cargo build -q && ./target/debug/hello`, "Hello, world!"},
		{"java", []domain.Toolchain{{Tool: "java", Version: "temurin-21"}, {Tool: "maven", Version: "3"}},
			`cd /tmp && printf 'class H{public static void main(String[] a){System.out.println("java ok");}}' > H.java && java H.java && mvn -q -B dependency:get -Dartifact=junit:junit:4.13.2 && echo maven ok`, "maven ok"},
		{"dotnet", []domain.Toolchain{{Tool: "dotnet", Version: "8"}},
			`cd /tmp && dotnet new console -o hello >/dev/null && cd hello && dotnet add package Humanizer.Core >/dev/null && dotnet run`, "Hello, World!"},
		{"ruby", []domain.Toolchain{{Tool: "ruby", Version: "3.3"}},
			`gem install --no-document rake >/dev/null && ruby -e 'require "rake"; puts "ruby ok"'`, "ruby ok"},
		{"elixir", []domain.Toolchain{{Tool: "erlang", Version: "latest"}, {Tool: "elixir", Version: "latest"}},
			`elixir -e 'IO.puts("elixir ok")'`, "elixir ok"},
		{"php", []domain.Toolchain{{Tool: "php", Version: "system"}},
			`php -r 'echo "php ok\n";' && composer --version`, "php ok"},
	} {
		t.Run(c.name, func(t *testing.T) {
			var empty bytes.Buffer
			_ = tar.NewWriter(&empty).Close()
			ws, err := r.Open(ctx, orchestrator.WorkspaceSpec{TicketKey: "test-" + c.name, Image: image, Repo: &empty,
				CacheKey: "test-" + c.name, Toolchains: c.tcs, Progress: func(m string) { t.Log(m) }})
			if err != nil {
				t.Fatal(err)
			}
			defer func() { _ = ws.Close(context.Background()) }()
			res, err := ws.Exec(ctx, c.cmd, 15*time.Minute)
			if err != nil || res.ExitCode != 0 || !strings.Contains(res.Output, c.want) {
				t.Errorf("%s: exit %d, %v\n%s", c.cmd, res.ExitCode, err, res.Output)
			}
		})
	}
}
