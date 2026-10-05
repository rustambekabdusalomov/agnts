package runner

import (
	"archive/tar"
	"bytes"
	"context"
	"errors"
	"io"
	"os"
	"strings"
	"testing"
	"time"

	"hiro/internal/domain"
)

// Runs against a real Docker daemon when HIRO_TEST_DOCKER=1, using the small
// alpine image (pulled once if missing).
func TestDockerClient(t *testing.T) {
	if os.Getenv("HIRO_TEST_DOCKER") != "1" {
		t.Skip("HIRO_TEST_DOCKER=1 not set")
	}
	sock := os.Getenv("HIRO_DOCKER_SOCKET")
	if sock == "" {
		sock = "/var/run/docker.sock"
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	d := NewDocker(sock)
	if err := d.Ping(ctx); err != nil {
		t.Fatal(err)
	}
	if err := d.EnsureNetwork(ctx, "hiro-test-runs", true); err != nil {
		t.Fatal(err)
	}
	if err := d.EnsureNetwork(ctx, "hiro-test-runs", true); err != nil {
		t.Fatalf("second ensure: %v", err)
	}
	t.Cleanup(func() { _ = d.json(context.Background(), "DELETE", "/networks/hiro-test-runs", nil, nil, nil) })

	id, err := d.Create(ctx, ContainerConfig{
		Name:       "hiro-test-" + time.Now().Format("150405.000000"),
		Image:      "alpine:3.20",
		WorkingDir: "/workspace",
		Cmd:        []string{"sleep", "300"},
		Labels:     map[string]string{"hiro.test": "1"},
		Network:    "hiro-test-runs",
		MemoryMB:   256, CPUs: 0.5, PIDs: 64,
		Volumes: []string{"/workspace", "/hiro/out"},
		Tmpfs:   map[string]string{"/tmp": "rw,size=16m"},
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() {
		if err := d.Remove(context.Background(), id); err != nil {
			t.Errorf("remove: %v", err)
		}
	}()

	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	body := "hello from hiro\n"
	_ = tw.WriteHeader(&tar.Header{Name: "src/main.txt", Mode: 0o644, Size: int64(len(body)), Typeflag: tar.TypeReg})
	_, _ = tw.Write([]byte(body))
	_ = tw.Close()
	if err := d.PutArchive(ctx, id, "/workspace", &buf); err != nil {
		t.Fatalf("put archive into a volume before start: %v", err)
	}
	if err := d.Start(ctx, id); err != nil {
		t.Fatal(err)
	}

	var out, errOut bytes.Buffer
	code, err := d.Exec(ctx, id, ExecConfig{Cmd: []string{"sh", "-c", "cat src/main.txt; echo oops >&2; exit 3"}, WorkingDir: "/workspace"}, &out, &errOut)
	if err != nil || code != 3 || out.String() != body || strings.TrimSpace(errOut.String()) != "oops" {
		t.Fatalf("exec: code=%d err=%v stdout=%q stderr=%q", code, err, out.String(), errOut.String())
	}

	// The root filesystem is read-only; volumes and /tmp are writable.
	code, _ = d.Exec(ctx, id, ExecConfig{Cmd: []string{"sh", "-c", "touch /etc/x"}}, io.Discard, io.Discard)
	if code == 0 {
		t.Fatal("root filesystem is writable")
	}
	code, _ = d.Exec(ctx, id, ExecConfig{Cmd: []string{"sh", "-c", `echo '{"summary":"x"}' > /hiro/out/summary.json && touch /tmp/ok`}}, io.Discard, io.Discard)
	if code != 0 {
		t.Fatal("volume or tmpfs not writable")
	}

	ws := &workspace{docker: d, id: id}
	b, err := ws.ReadFile(ctx, "/hiro/out/summary.json")
	if err != nil || strings.TrimSpace(string(b)) != `{"summary":"x"}` {
		t.Fatalf("read file: %q %v", b, err)
	}
	if _, err := ws.ReadFile(ctx, "/hiro/out/missing.json"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing file: %v", err)
	}

	// Large output passes through the demuxer intact.
	out.Reset()
	code, err = d.Exec(ctx, id, ExecConfig{Cmd: []string{"sh", "-c", "head -c 300000 /dev/zero | tr '\\0' a"}}, &out, io.Discard)
	if err != nil || code != 0 || out.Len() != 300000 {
		t.Fatalf("large output: %d bytes, code %d, %v", out.Len(), code, err)
	}
}
