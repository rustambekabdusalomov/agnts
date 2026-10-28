package runner

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

// TestTranscribeMeetingLive runs TranscribeMeeting in a real container when
// AGNTS_TEST_MEET_IMAGE names an image with ffmpeg and a `muse` (a stand-in
// that answers "heard a clip of N seconds" is enough) and
// AGNTS_TEST_MEET_AUDIO is a spoken recording with pauses.
func TestTranscribeMeetingLive(t *testing.T) {
	image, audio := os.Getenv("AGNTS_TEST_MEET_IMAGE"), os.Getenv("AGNTS_TEST_MEET_AUDIO")
	if image == "" || audio == "" {
		t.Skip("AGNTS_TEST_MEET_IMAGE and AGNTS_TEST_MEET_AUDIO not set")
	}
	data, err := os.ReadFile(audio)
	if err != nil {
		t.Fatal(err)
	}
	r := New(NewDocker("/var/run/docker.sock"), Config{}, func(context.Context) (Credential, error) {
		return Credential{Env: MuseKeyEnv, Token: "LLM_test-key-for-a-stand-in-muse"}, nil
	})
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	segs, err := r.TranscribeMeeting(ctx, image, data, strings.TrimPrefix(filepath.Ext(audio), "."))
	if err != nil {
		t.Fatal(err)
	}
	if len(segs) == 0 {
		t.Fatal("nothing heard")
	}
	for i, s := range segs {
		t.Logf("%d: %d–%d ms %q", i, s.StartMS, s.EndMS, s.Text)
		if !strings.HasPrefix(s.Text, "heard a clip") || s.EndMS <= s.StartMS || (i > 0 && s.StartMS < segs[i-1].StartMS) {
			t.Errorf("segment %d: %+v", i, s)
		}
	}
}
