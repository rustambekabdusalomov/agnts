package meetings

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"

	"agnts/internal/ai"
)

// An uploaded recording is heard from its sound only. The server has no
// ffmpeg, so a throwaway box from the run image takes the sound out: the
// file is streamed onto the box's disk, ffmpeg keeps the first audio
// track as a small mono Ogg (about 11 MB an hour), and only that comes
// back. The picture never leaves the box, and the box is removed.

// SoundTaker writes the sound of the recording src to the Ogg file dst.
type SoundTaker interface {
	TakeSound(ctx context.Context, src, dst string) error
}

// ErrNoSound says the recording has no audio track.
var ErrNoSound = errors.New("the recording has no sound")

// BoxSound is a SoundTaker that runs ffmpeg in a box of Image.
type BoxSound struct {
	Boxes ai.Boxes
	Image string
}

// soundTimeout bounds taking the sound out of one recording.
const soundTimeout = 90 * time.Minute

// TakeSound implements SoundTaker.
func (b BoxSound) TakeSound(ctx context.Context, src, dst string) error {
	f, err := os.Open(src) //nolint:gosec // G304: a name agnts made, in the meetings directory
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()
	info, err := f.Stat()
	if err != nil {
		return err
	}
	box, closeBox, err := b.Boxes.OpenBox(ctx, ai.BoxSpec{Image: b.Image, Label: "meeting-sound", MemoryMB: 1024, CPUs: 2, TmpMB: 64, Life: 2 * time.Hour})
	if err != nil {
		return fmt.Errorf("the sound box: %w", err)
	}
	defer closeBox()
	sw, ok := box.(ai.StreamWriter)
	if !ok {
		return errors.New("this server cannot stream a recording into a box")
	}
	in, out := ai.HomeDir+"/voice/upload", ai.HomeDir+"/voice/sound.ogg"
	if err := sw.WriteFileFrom(ctx, in, f, info.Size()); err != nil {
		return fmt.Errorf("copy the recording: %w", err)
	}
	var errOut bytes.Buffer
	code, err := box.Run(ctx, ai.Cmd{Argv: ai.TimeoutArgv(soundTimeout, "ffmpeg", "-nostdin", "-v", "error", "-y", "-i", in,
		"-map", "0:a:0", "-vn", "-sn", "-dn", "-ac", "1", "-c:a", "libopus", "-b:a", "24k", out)}, &bytes.Buffer{}, &errOut)
	if err != nil {
		return err
	}
	msg := strings.TrimSpace(errOut.String())
	switch {
	case code == 127:
		return errors.New("ffmpeg is not installed in the runner image: rebuild it (docker compose --profile build build runner)")
	case code != 0 && strings.Contains(msg, "matches no streams"):
		return ErrNoSound
	case code != 0:
		if len(msg) > 300 {
			msg = msg[len(msg)-300:]
		}
		return fmt.Errorf("ffmpeg could not read the recording: %s", msg)
	}
	data, err := box.ReadFile(ctx, out)
	if err != nil {
		return fmt.Errorf("read the sound: %w", err)
	}
	return os.WriteFile(dst, data, 0o600)
}
