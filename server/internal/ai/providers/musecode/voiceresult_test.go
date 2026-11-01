package musecode

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/ai"
)

func TestVoiceResult(t *testing.T) {
	if text, err := voiceResult(0, "  Add a dark mode toggle.\n", ""); err != nil || text != "Add a dark mode toggle." {
		t.Fatalf("heard %q, %v", text, err)
	}
	for _, c := range []struct {
		code           int
		stdout, stderr string
		want           string
	}{
		{0, "\n", "", "no words"},
		{voiceNoWords, "", "error: no words heard: voice session closed before final transcript", "no words"},
		{voiceNoCredential, "", "error: no speech credential", "no credential for voice"},
		{voiceNoDecoder, "", "error: no audio decoder on this host for .wav", "cannot read the clip"},
		{voiceServiceError, "", "error: the speech service failed: Unauthorized", "speech service failed: error: the speech service failed: Unauthorized"},
		{127, "", "", "not installed"},
		{2, "", "error: unexpected argument", "exited 2"},
	} {
		_, err := voiceResult(c.code, c.stdout, c.stderr)
		if err == nil || !strings.Contains(err.Error(), c.want) {
			t.Errorf("exit %d: %v (want %q)", c.code, err, c.want)
		}
		if noWords := c.want == "no words"; errors.Is(err, ai.ErrNoSpeech) != noWords {
			t.Errorf("exit %d: ErrNoSpeech is %v", c.code, !noWords)
		}
	}
}
