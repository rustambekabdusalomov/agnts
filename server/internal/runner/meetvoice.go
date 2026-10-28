package runner

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

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Meeting audio: the notes of a meeting are heard by Muse Code, like a
// spoken question, but a meeting is long and Muse hears short clips. In a
// throwaway container from the run image (which has ffmpeg), agnts finds
// the pauses, cuts the audio at them into clips of at most a minute and a
// half, skips the silence, and has Muse hear each clip. A clip's place in
// the file gives its segment's times.

// Where the meeting's audio and its clips go in the container.
const (
	meetAudioDir = homeDir + "/voice"
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

// TranscribeMeeting hears a meeting's audio (an Ogg or MP4 file Egress
// wrote) on the Muse account in ctx and returns what was said, with times
// from the file's start. Clips without words are left out.
func (r *Runner) TranscribeMeeting(ctx context.Context, image string, audio []byte, ext string) ([]domain.MeetingSegment, error) {
	if len(audio) == 0 {
		return nil, errors.New("the meeting's audio is empty")
	}
	c, err := r.token(ctx)
	if err != nil {
		return nil, fmt.Errorf("muse credential: %w", err)
	}
	cred, err := museCredential(c)
	if err != nil {
		return nil, err
	}
	env, files, err := cred.Setup(museAuthPath)
	if err != nil {
		return nil, err
	}
	// The container lives as long as the work may take: a minute per
	// minute of audio is far more than hearing it needs.
	id, err := r.docker.Create(ctx, ContainerConfig{
		Image: image, User: agentUser, Cmd: []string{"sleep", "21600"}, Network: "bridge",
		MemoryMB: 1024, CPUs: 2, PIDs: 256, Labels: map[string]string{"agnts": "muse-meeting"},
		Volumes: []string{homeDir},
		Tmpfs:   map[string]string{"/tmp": "rw,exec,nosuid,size=256m,uid=1000,gid=1000"},
	})
	if err != nil {
		return nil, fmt.Errorf("meeting audio container: %w", err)
	}
	defer func() { _ = r.docker.Remove(context.WithoutCancel(ctx), id) }()
	if err := r.docker.Start(ctx, id); err != nil {
		return nil, err
	}
	w := &workspace{docker: r.docker, id: id}
	for _, f := range files {
		if err := w.WriteFile(ctx, f.Path, f.Data); err != nil {
			return nil, fmt.Errorf("muse credential file: %w", err)
		}
	}
	in := meetAudioDir + "/meeting." + strings.TrimPrefix(ext, ".")
	if err := w.WriteFile(ctx, in, audio); err != nil {
		return nil, fmt.Errorf("meeting audio: %w", err)
	}
	museEnv := append([]string{"HOME=" + homeDir, "XDG_DATA_HOME=" + homeDir + "/.local/share", "NO_COLOR=1",
		"MUSE_UPDATE_INTERVAL_SECONDS=31536000", museFileCredentials}, env...)
	run := func(ctx context.Context, cmd ...string) (int, string, string, error) {
		var stdout, stderr tailBuffer
		code, err := r.docker.Exec(ctx, id, ExecConfig{Cmd: cmd, User: agentUser, Env: museEnv}, &stdout, &stderr)
		return code, stdout.String(), stderr.String(), err
	}

	code, out, errOut, err := run(ctx, "ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=nw=1:nk=1", in)
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
	code, _, errOut, err = run(ctx, "sh", "-c", `ffmpeg -hide_banner -nostats -i "$1" -af "$2" -f null - 2> "$3"`, "sh", in, meetSilenceFilter, pauses)
	if err != nil {
		return nil, err
	}
	if code != 0 {
		return nil, fmt.Errorf("ffmpeg could not read the meeting's audio: %s", strings.TrimSpace(errOut))
	}
	raw, err := w.ReadFile(ctx, pauses)
	if err != nil {
		return nil, err
	}
	clips := planClips(dur, parseSilences(string(raw), dur), meetClipMax.Seconds(), meetClipMin.Seconds())

	segs := make([]domain.MeetingSegment, len(clips))
	errs := make([]error, len(clips))
	var wg sync.WaitGroup
	next := make(chan int)
	for range min(meetWorkers, len(clips)) {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for i := range next {
				segs[i], errs[i] = r.hearClip(ctx, run, in, i, clips[i])
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
	r.keepVoiceLogin(ctx, w, files)
	if ctx.Err() != nil {
		return nil, ctx.Err()
	}
	out2 := make([]domain.MeetingSegment, 0, len(segs))
	failed := 0
	var firstErr error
	for i, s := range segs {
		switch {
		case errors.Is(errs[i], orchestrator.ErrNoSpeech):
		case errs[i] != nil:
			failed++
			if firstErr == nil {
				firstErr = errs[i]
			}
		case strings.TrimSpace(s.Text) != "":
			out2 = append(out2, s)
		}
	}
	// A few clips Muse could not hear leave gaps; most of them failing
	// means the speech service is down: say so rather than write notes
	// from scraps.
	if failed > 0 && failed*3 >= len(clips) {
		return nil, fmt.Errorf("muse could not hear %d of %d parts of the meeting: %w", failed, len(clips), firstErr)
	}
	return out2, nil
}

// hearClip cuts one clip to WAV (what Muse reads) and hears it.
func (r *Runner) hearClip(ctx context.Context, run func(context.Context, ...string) (int, string, string, error), in string, i int, c span) (domain.MeetingSegment, error) {
	ctx, cancel := context.WithTimeout(ctx, meetClipTimeout)
	defer cancel()
	clip := fmt.Sprintf("%s/clip-%04d.wav", meetAudioDir, i)
	code, _, errOut, err := run(ctx, "ffmpeg", "-v", "error", "-y", "-ss", fmt.Sprintf("%.3f", c.start), "-t", fmt.Sprintf("%.3f", c.dur()),
		"-i", in, "-ac", "1", "-ar", "16000", "-c:a", "pcm_s16le", clip)
	if err != nil {
		return domain.MeetingSegment{}, err
	}
	if code != 0 {
		return domain.MeetingSegment{}, fmt.Errorf("cut clip %d: %s", i, strings.TrimSpace(errOut))
	}
	code, out, errOut, err := run(ctx, "muse", "voice", "transcribe", clip)
	_, _, _, _ = run(context.WithoutCancel(ctx), "rm", "-f", clip)
	if err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return domain.MeetingSegment{}, fmt.Errorf("muse took longer than %s to hear a part", meetClipTimeout)
		}
		return domain.MeetingSegment{}, err
	}
	text, err := voiceResult(code, out, strings.TrimSpace(errOut))
	if err != nil {
		return domain.MeetingSegment{}, err
	}
	return domain.MeetingSegment{StartMS: int(c.start * 1000), EndMS: int(c.end * 1000), Text: strings.TrimSpace(text)}, nil
}
