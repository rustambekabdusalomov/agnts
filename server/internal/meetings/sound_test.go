package meetings_test

import (
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"agnts/internal/meetings"
	"agnts/internal/runner"
)

// TestBoxSoundTakesTheSoundOut runs the sound step for real: a video is
// streamed into a box, ffmpeg keeps its audio, and only an Ogg comes back.
// It needs Docker and an image with ffmpeg and the agent user
// (AGNTS_TEST_FFMPEG_IMAGE, e.g. the run image), and ffmpeg here to make
// the video.
func TestBoxSoundTakesTheSoundOut(t *testing.T) {
	image := os.Getenv("AGNTS_TEST_FFMPEG_IMAGE")
	if os.Getenv("AGNTS_TEST_DOCKER") != "1" || image == "" {
		t.Skip("AGNTS_TEST_DOCKER=1 and AGNTS_TEST_FFMPEG_IMAGE not set")
	}
	if _, err := exec.LookPath("ffmpeg"); err != nil {
		t.Skip("no ffmpeg to make the test video")
	}
	dir := t.TempDir()
	video, silent := filepath.Join(dir, "call.mp4"), filepath.Join(dir, "screen.mp4")
	for _, args := range [][]string{
		{"-f", "lavfi", "-i", "testsrc=duration=6:size=640x360:rate=25", "-f", "lavfi", "-i", "sine=frequency=440:duration=6",
			"-c:v", "libx264", "-c:a", "aac", "-shortest", video},
		{"-f", "lavfi", "-i", "testsrc=duration=2:size=320x240:rate=10", "-c:v", "libx264", silent},
	} {
		if out, err := exec.Command("ffmpeg", append([]string{"-v", "error", "-y"}, args...)...).CombinedOutput(); err != nil { //nolint:gosec // G204: the test's own arguments
			t.Fatalf("make the video: %v %s", err, out)
		}
	}
	sock := os.Getenv("AGNTS_DOCKER_SOCKET")
	if sock == "" {
		sock = "/var/run/docker.sock"
	}
	b := meetings.BoxSound{Boxes: runner.New(runner.NewDocker(sock), runner.Config{}), Image: image}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()

	ogg := filepath.Join(dir, "call.sound.ogg")
	if err := b.TakeSound(ctx, video, ogg); err != nil {
		t.Fatal(err)
	}
	probe, err := exec.Command("ffprobe", "-v", "error", "-show_entries", "stream=codec_type,codec_name,channels", "-of", "csv=p=0", ogg).Output() //nolint:gosec // G204: the test's own file
	if err != nil {
		t.Fatal(err)
	}
	if got := string(probe); got != "opus,audio,1\n" {
		t.Errorf("the sound is %q, want one mono opus track and no picture", got)
	}
	if err := b.TakeSound(ctx, silent, filepath.Join(dir, "screen.sound.ogg")); !errors.Is(err, meetings.ErrNoSound) {
		t.Errorf("a video without sound: %v", err)
	}
}
