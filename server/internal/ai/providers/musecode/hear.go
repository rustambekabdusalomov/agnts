package musecode

import (
	"context"
	"errors"
	"fmt"
	"math"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/rustambekabdusalomov/agnts-muse/credential"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// Hearing: Muse Code's `muse voice transcribe` turns speech into text, in
// a throwaway box from the run image with the person's Muse account. A
// spoken question is one short WAV clip. A meeting is long and Muse hears
// short clips: agnts finds the pauses (the run image has ffmpeg), cuts
// the audio at them into clips of at most a minute and a half, skips the
// silence, and has Muse hear each clip. A clip's place in the file gives
// its segment's times.

// voiceClip is where a spoken question goes in the box.
const voiceClip = ai.HomeDir + "/voice/clip.wav"

// ClipTimeout bounds hearing one spoken question, the box included.
const ClipTimeout = 90 * time.Second

// Exit codes of `muse voice transcribe` (Muse 1.4.13).
const (
	voiceNoCredential = 4
	voiceNoDecoder    = 5
	voiceServiceError = 6
	voiceNoWords      = 7
)

// Where the meeting's audio and its clips go in the container.
const (
	meetAudioDir = ai.HomeDir + "/voice"
	meetClipMax  = 90 * time.Second // a clip Muse hears at once
	meetClipMin  = 400 * time.Millisecond
	// meetClipTimeout bounds hearing one clip.
	meetClipTimeout = 2 * time.Minute
	// meetWorkers are clips heard at once.
	meetWorkers = 3
	// meetSilence is what ffmpeg counts as a pause: quieter than -35 dB
	// for 0.6 seconds.
	meetSilenceFilter = "silencedetect=noise=-35dB:d=0.6"
)

// span is a stretch of a file, in seconds.
type span struct{ start, end float64 }

func (s span) dur() float64 { return s.end - s.start }

var (
	silenceStartRe = regexp.MustCompile(`silence_start: (-?[0-9.]+)`)
	silenceEndRe   = regexp.MustCompile(`silence_end: (-?[0-9.]+)`)
)

// parseSilences reads ffmpeg's silencedetect output into the pauses of a
// file of dur seconds. A pause still open at the end runs to the end.
func parseSilences(out string, dur float64) []span {
	var spans []span
	open := -1.0
	for _, line := range strings.Split(out, "\n") {
		if m := silenceStartRe.FindStringSubmatch(line); m != nil {
			open, _ = strconv.ParseFloat(m[1], 64)
			open = math.Max(open, 0)
			continue
		}
		if m := silenceEndRe.FindStringSubmatch(line); m != nil && open >= 0 {
			end, _ := strconv.ParseFloat(m[1], 64)
			if end > open {
				spans = append(spans, span{open, math.Min(end, dur)})
			}
			open = -1
		}
	}
	if open >= 0 && open < dur {
		spans = append(spans, span{open, dur})
	}
	return spans
}

// planClips cuts a file of dur seconds with these pauses into the clips
// Muse hears: the speech between pauses, joined while a clip stays under
// max, split where one stretch of speech runs longer. Clips start and end
// inside the pauses around them (by up to a quarter second), so no word
// is cut.
func planClips(dur float64, silences []span, maxClip, minClip float64) []span {
	if dur <= 0 {
		return nil
	}
	sort.Slice(silences, func(i, j int) bool { return silences[i].start < silences[j].start })
	// Speech is what the pauses leave.
	var speech []span
	at := 0.0
	for _, s := range silences {
		if s.start > at {
			speech = append(speech, span{at, s.start})
		}
		at = math.Max(at, s.end)
	}
	if at < dur {
		speech = append(speech, span{at, dur})
	}
	const pad = 0.25
	var clips []span
	var cur *span
	flush := func() {
		if cur != nil && cur.dur() >= minClip {
			clips = append(clips, *cur)
		}
		cur = nil
	}
	for _, s := range speech {
		s = span{math.Max(0, s.start-pad), math.Min(dur, s.end+pad)}
		for s.dur() > maxClip { // one long stretch: cut it every max
			flush()
			clips = append(clips, span{s.start, s.start + maxClip})
			s.start += maxClip
		}
		if cur != nil && s.end-cur.start <= maxClip {
			cur.end = s.end
			continue
		}
		flush()
		c := s
		cur = &c
	}
	flush()
	return clips
}

// hearing is a throwaway box with a Muse credential in it.
type hearing struct {
	box   ai.Box
	env   []string
	files []credential.File
}

// openHearing opens a box for spec and puts the credential in it.
func (p *Provider) openHearing(ctx context.Context, c ai.Credential, spec ai.BoxSpec) (*hearing, *credential.Credential, func(), error) {
	if p.cfg.Boxes == nil {
		return nil, nil, nil, errors.New("muse does not hear audio on this server")
	}
	cred, err := museCredential(c)
	if err != nil {
		return nil, nil, nil, err
	}
	env, files, err := cred.Setup(authPath)
	if err != nil {
		return nil, nil, nil, err
	}
	spec.Image = p.cfg.Image
	box, closeBox, err := p.cfg.Boxes.OpenBox(ctx, spec)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("%s container: %w", spec.Label, err)
	}
	for _, f := range files {
		if err := box.WriteFile(ctx, f.Path, f.Data); err != nil {
			closeBox()
			return nil, nil, nil, fmt.Errorf("muse credential file: %w", err)
		}
	}
	h := &hearing{box: box, files: files, env: append([]string{"HOME=" + ai.HomeDir, "XDG_DATA_HOME=" + ai.HomeDir + "/.local/share", "NO_COLOR=1",
		"MUSE_UPDATE_INTERVAL_SECONDS=31536000", fileCredentials}, env...)}
	return h, &cred, closeBox, nil
}

// run runs a command in the hearing box.
func (h *hearing) run(ctx context.Context, argv ...string) (int, string, string, error) {
	var stdout, stderr ai.TailBuffer
	code, err := h.box.Run(ctx, ai.Cmd{Argv: argv, Env: h.env}, &stdout, &stderr)
	return code, stdout.String(), stderr.String(), err
}

// HearClip implements ai.Hearer: the words spoken in a WAV clip.
func (p *Provider) HearClip(ctx context.Context, c ai.Credential, wav []byte) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, ClipTimeout)
	defer cancel()
	h, cred, closeBox, err := p.openHearing(ctx, c, ai.BoxSpec{Label: "muse-voice", MemoryMB: 512, CPUs: 1, TmpMB: 64, Life: 2 * time.Minute})
	if err != nil {
		return "", err
	}
	defer closeBox()
	if err := h.box.WriteFile(ctx, voiceClip, wav); err != nil {
		return "", fmt.Errorf("voice clip: %w", err)
	}
	code, out, errOut, err := h.run(ctx, "muse", "voice", "transcribe", voiceClip)
	if err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return "", fmt.Errorf("muse took longer than %s to hear the clip", ClipTimeout)
		}
		return "", err
	}
	keepLogin(ctx, ctx, h.box, p.cfg.KeepLogin, c.Account, h.files)
	said := domain.NewSecretRedactor(cred.Secrets()...).String(strings.TrimSpace(errOut))
	return voiceResult(code, out, said)
}

// Hear implements ai.Hearer: what was said in a meeting's audio (an Ogg or
// MP4 file Egress wrote), with times from the file's start. Clips without
// words are left out.
func (p *Provider) Hear(ctx context.Context, c ai.Credential, audio []byte, ext string) ([]ai.Segment, error) {
	if len(audio) == 0 {
		return nil, errors.New("the meeting's audio is empty")
	}
	// The box lives as long as the work may take: a minute per minute of
	// audio is far more than hearing it needs.
	h, _, closeBox, err := p.openHearing(ctx, c, ai.BoxSpec{Label: "muse-meeting", MemoryMB: 1024, CPUs: 2, TmpMB: 256, Life: 6 * time.Hour})
	if err != nil {
		return nil, err
	}
	defer closeBox()
	in := meetAudioDir + "/meeting." + strings.TrimPrefix(ext, ".")
	if err := h.box.WriteFile(ctx, in, audio); err != nil {
		return nil, fmt.Errorf("meeting audio: %w", err)
	}
	code, out, errOut, err := h.run(ctx, "ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=nw=1:nk=1", in)
	if err != nil {
		return nil, err
	}
	if code == 127 {
		return nil, errors.New("ffmpeg is not installed in the runner image: rebuild it (docker compose --profile build build runner)")
	}
	dur, perr := strconv.ParseFloat(strings.TrimSpace(out), 64)
	if code != 0 || perr != nil || dur <= 0 {
		return nil, fmt.Errorf("cannot read the meeting's audio: %s", strings.TrimSpace(errOut))
	}
	// The pauses, written to a file: a long meeting has thousands.
	pauses := meetAudioDir + "/silence.txt"
	code, _, errOut, err = h.run(ctx, "sh", "-c", `ffmpeg -hide_banner -nostats -i "$1" -af "$2" -f null - 2> "$3"`, "sh", in, meetSilenceFilter, pauses)
	if err != nil {
		return nil, err
	}
	if code != 0 {
		return nil, fmt.Errorf("ffmpeg could not read the meeting's audio: %s", strings.TrimSpace(errOut))
	}
	raw, err := h.box.ReadFile(ctx, pauses)
	if err != nil {
		return nil, err
	}
	clips := planClips(dur, parseSilences(string(raw), dur), meetClipMax.Seconds(), meetClipMin.Seconds())

	segs := make([]ai.Segment, len(clips))
	errs := make([]error, len(clips))
	var wg sync.WaitGroup
	next := make(chan int)
	for range min(meetWorkers, len(clips)) {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for i := range next {
				segs[i], errs[i] = h.hearClip(ctx, in, i, clips[i])
			}
		}()
	}
	for i := range clips {
		if ctx.Err() != nil {
			break
		}
		next <- i
	}
	close(next)
	wg.Wait()
	keepLogin(ctx, ctx, h.box, p.cfg.KeepLogin, c.Account, h.files)
	if ctx.Err() != nil {
		return nil, ctx.Err()
	}
	heard := make([]ai.Segment, 0, len(segs))
	failed := 0
	var firstErr error
	for i, s := range segs {
		switch {
		case errors.Is(errs[i], ai.ErrNoSpeech):
		case errs[i] != nil:
			failed++
			if firstErr == nil {
				firstErr = errs[i]
			}
		case strings.TrimSpace(s.Text) != "":
			heard = append(heard, s)
		}
	}
	// A few clips Muse could not hear leave gaps; most of them failing
	// means the speech service is down: say so rather than write notes
	// from scraps.
	if failed > 0 && failed*3 >= len(clips) {
		return nil, fmt.Errorf("muse could not hear %d of %d parts of the meeting: %w", failed, len(clips), firstErr)
	}
	return heard, nil
}

// hearClip cuts one clip to WAV (what Muse reads) and hears it.
func (h *hearing) hearClip(ctx context.Context, in string, i int, c span) (ai.Segment, error) {
	ctx, cancel := context.WithTimeout(ctx, meetClipTimeout)
	defer cancel()
	clip := fmt.Sprintf("%s/clip-%04d.wav", meetAudioDir, i)
	code, _, errOut, err := h.run(ctx, "ffmpeg", "-v", "error", "-y", "-ss", fmt.Sprintf("%.3f", c.start), "-t", fmt.Sprintf("%.3f", c.dur()),
		"-i", in, "-ac", "1", "-ar", "16000", "-c:a", "pcm_s16le", clip)
	if err != nil {
		return ai.Segment{}, err
	}
	if code != 0 {
		return ai.Segment{}, fmt.Errorf("cut clip %d: %s", i, strings.TrimSpace(errOut))
	}
	code, out, errOut, err := h.run(ctx, "muse", "voice", "transcribe", clip)
	_, _, _, _ = h.run(context.WithoutCancel(ctx), "rm", "-f", clip)
	if err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return ai.Segment{}, fmt.Errorf("muse took longer than %s to hear a part", meetClipTimeout)
		}
		return ai.Segment{}, err
	}
	text, err := voiceResult(code, out, strings.TrimSpace(errOut))
	if err != nil {
		return ai.Segment{}, err
	}
	return ai.Segment{StartMS: int(c.start * 1000), EndMS: int(c.end * 1000), Text: strings.TrimSpace(text)}, nil
}

// voiceResult reads `muse voice transcribe`'s exit: the words, or why not.
func voiceResult(code int, stdout, stderr string) (string, error) {
	switch code {
	case 0:
		if text := strings.TrimSpace(stdout); text != "" {
			return text, nil
		}
		return "", ai.ErrNoSpeech
	case voiceNoWords:
		return "", ai.ErrNoSpeech
	case 127:
		return "", errors.New("muse is not installed in the runner image: build it with --build-arg MUSE_VERSION=<version>")
	case voiceNoCredential:
		return "", fmt.Errorf("muse has no credential for voice: %s", stderr)
	case voiceNoDecoder:
		return "", fmt.Errorf("muse cannot read the clip: %s", stderr)
	case voiceServiceError:
		return "", fmt.Errorf("the Muse speech service failed: %s", stderr)
	}
	return "", fmt.Errorf("muse voice exited %d: %s", code, stderr)
}
