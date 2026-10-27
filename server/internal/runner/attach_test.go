package runner

import (
	"bufio"
	"context"
	"io"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"
)

// TestExecAttach runs against a real Docker daemon (AGNTS_TEST_DOCKER=1):
// stdin reaches the process, its stdout comes back line by line, closing
// stdin ends it, and the exit code is read.
func TestExecAttach(t *testing.T) {
	if os.Getenv("AGNTS_TEST_DOCKER") == "" {
		t.Skip("AGNTS_TEST_DOCKER is not set")
	}
	sock := os.Getenv("AGNTS_TEST_DOCKER_SOCKET")
	if sock == "" {
		sock = "/var/run/docker.sock"
	}
	out, err := exec.Command("docker", "run", "-d", "--rm", "alpine:3.20", "sleep", "60").Output()
	if err != nil {
		t.Skipf("docker run: %v", err)
	}
	id := strings.TrimSpace(string(out))
	t.Cleanup(func() { _ = exec.Command("docker", "rm", "-f", id).Run() })

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	d := NewDocker(sock)
	a, err := d.ExecAttach(ctx, id, ExecConfig{Cmd: []string{"sh", "-c", "while read l; do echo \"got $l\"; done; exit 3"}}, io.Discard)
	if err != nil {
		t.Fatal(err)
	}
	r := bufio.NewReader(a)
	for _, msg := range []string{"one", "two"} {
		if _, err := io.WriteString(a, msg+"\n"); err != nil {
			t.Fatal(err)
		}
		line, err := r.ReadString('\n')
		if err != nil || line != "got "+msg+"\n" {
			t.Fatalf("read %q, %v", line, err)
		}
	}
	if err := a.Close(); err != nil {
		t.Fatal(err)
	}
	code, err := a.Wait(ctx)
	if err != nil || code != 3 {
		t.Fatalf("exit %d, %v", code, err)
	}
}
