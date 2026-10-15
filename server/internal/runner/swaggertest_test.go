package runner

import (
	"archive/tar"
	"bytes"
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"agnts/internal/orchestrator"
)

// A run's grants live as long as its container: the egress proxy asks
// WhoIs, and a closed container's address grants nothing.
func TestGrantsFollowTheContainer(t *testing.T) {
	r := &Runner{}
	r.remember("172.18.0.9", Identity{Workspace: 3, Ticket: "API-7", Grants: []orchestrator.Grant{{Host: "api.staging.test", Port: 8080}}})
	id, ok := r.WhoIs("172.18.0.9")
	if !ok || !id.Granted("API.staging.test.", 8080) || id.Granted("api.staging.test", 443) || id.Granted("other.test", 8080) {
		t.Fatalf("%+v", id)
	}
	r.forget("172.18.0.9")
	if _, ok := r.WhoIs("172.18.0.9"); ok {
		t.Fatal("a closed container keeps its grants")
	}
}

func TestGuardArchiveLinksAgntsAPI(t *testing.T) {
	tr := tar.NewReader(bytes.NewReader(guardArchive([]byte("bin"))))
	found := false
	for {
		h, err := tr.Next()
		if err != nil {
			break
		}
		if h.Name == ".local/bin/agnts-api" && h.Typeflag == tar.TypeSymlink && h.Linkname == APIBinary {
			found = true
		}
	}
	if !found {
		t.Fatal("agnts-api is not linked onto the PATH")
	}
}

// TestAgntsAPIInContainer runs the real agnts-api (the agnts-guard binary,
// built for Linux) in a container against a tiny API served there.
func TestAgntsAPIInContainer(t *testing.T) {
	if os.Getenv("AGNTS_TEST_DOCKER") != "1" {
		t.Skip("AGNTS_TEST_DOCKER=1 not set")
	}
	sock := os.Getenv("AGNTS_DOCKER_SOCKET")
	if sock == "" {
		sock = "/var/run/docker.sock"
	}
	bin := filepath.Join(t.TempDir(), "agnts-guard")
	build := exec.Command("go", "build", "-o", bin, "../../cmd/agnts-guard")
	build.Env = append(os.Environ(), "CGO_ENABLED=0", "GOOS=linux")
	if out, err := build.CombinedOutput(); err != nil {
		t.Fatalf("build agnts-guard: %v\n%s", err, out)
	}
	guardBin, _ := os.ReadFile(bin)
	users, _ := os.ReadFile("testdata/swaggertest/users")

	image := os.Getenv("AGNTS_TEST_RUNNER_IMAGE")
	if image == "" {
		image = "agnts-runner:latest"
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	d := NewDocker(sock)
	id, err := d.Create(ctx, ContainerConfig{
		Name: "agnts-test-api-" + time.Now().Format("150405.000000"), Image: image, User: agentUser, WorkingDir: "/workspace",
		Cmd: []string{"sleep", "180"}, Labels: map[string]string{"agnts.test": "1"}, MemoryMB: 512, CPUs: 0.5, PIDs: 128,
		Volumes: []string{workDir, homeDir, outDir, contextDir}, Tmpfs: map[string]string{"/tmp": "rw,exec,nosuid,size=64m"},
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = d.Remove(context.Background(), id) }()
	if err := d.PutArchive(ctx, id, homeDir, bytes.NewReader(guardArchive(guardBin))); err != nil {
		t.Fatal(err)
	}
	if err := d.Start(ctx, id); err != nil {
		t.Fatal(err)
	}
	ws := &workspace{docker: d, id: id}
	must := func(p, s string) {
		if err := ws.WriteFile(ctx, p, []byte(s)); err != nil {
			t.Fatal(err)
		}
	}
	must("/workspace/www/users", string(users))
	must("/workspace/www/index.php", `<?php header("Content-Type: application/json"); readfile(__DIR__."/users");`)
	must("/agnts/context/api/test.json", `{"baseUrl":"http://127.0.0.1:8080","operations":["GET /users"],"auth":{"kind":"bearer"},"rate":50}`)
	must("/agnts/context/api/.auth", `{"kind":"bearer","value":"smoke-test-token-1"}`)
	must("/agnts/out/api/plan.json", `{"cases":[
		{"id":"list","method":"GET","path":"/users","expect":{"status":[200]}},
		{"id":"create","method":"POST","path":"/users","body":{"name":"x"}},
		{"id":"chained","method":"GET","path":"/users","query":{"first":"{{list.body.items.0.id}}"}},
		{"id":"broken","method":"GET","path":"/users/{id}","params":{"id":"{{create.body.id}}"}}]}`)
	sh := func(cmd string) string {
		res, err := ws.Exec(ctx, cmd, time.Minute)
		if err != nil {
			t.Fatal(err)
		}
		return res.Output
	}
	sh("(php -S 127.0.0.1:8080 -t /workspace/www >/tmp/php.log 2>&1 &) ; sleep 1")
	out := sh("PATH=/home/agent/.local/bin:$PATH agnts-api run /agnts/out/api/plan.json")
	for _, want := range []string{"ok list", "→ 200", "create", "write requests are off", "broken", "blocked"} {
		if !strings.Contains(out, want) {
			t.Errorf("run output misses %q:\n%s", want, out)
		}
	}
	if out := sh("PATH=/home/agent/.local/bin:$PATH agnts-api GET http://other.example/users; echo exit=$?"); !strings.Contains(out, "exit=3") {
		t.Errorf("another host: %s", out)
	}
	log := sh("cat /agnts/out/api/log.jsonl")
	if strings.Contains(log, "smoke-test-token-1") || !strings.Contains(log, "first=7") {
		t.Errorf("log: %s", log)
	}
}
