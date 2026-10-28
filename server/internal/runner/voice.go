package runner

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/rustambekabdusalomov/agnts-muse/credential"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Voice: Muse Code's `muse voice transcribe` turns a spoken question into
// text, in a throwaway container from the run image with the person's
// Muse account, like a sign-in. Muse reads 16-bit PCM WAV itself; other
// formats need ffmpeg, which the run image does not have, so agnts takes
// WAV only (the panel records it).

// voiceClip is where the clip goes in the container.
const voiceClip = homeDir + "/voice/clip.wav"

// TranscribeTimeout bounds one transcription, the container included.
const TranscribeTimeout = 90 * time.Second

// Exit codes of `muse voice transcribe` (Muse 1.4.13).
const (
	voiceNoCredential = 4
	voiceNoDecoder    = 5
	voiceServiceError = 6
	voiceNoWords      = 7
)

// Transcribe returns the words spoken in a WAV clip, heard by Muse on the
// Muse account in ctx.
func (r *Runner) Transcribe(ctx context.Context, image string, wav []byte) (string, error) {
	c, err := r.token(ctx)
	if err != nil {
		return "", fmt.Errorf("muse credential: %w", err)
	}
	cred, err := museCredential(c)
	if err != nil {
		return "", err
	}
	env, files, err := cred.Setup(museAuthPath)
	if err != nil {
		return "", err
	}
	ctx, cancel := context.WithTimeout(ctx, TranscribeTimeout)
	defer cancel()
	id, err := r.docker.Create(ctx, ContainerConfig{
		Image: image, User: agentUser, Cmd: []string{"sleep", "120"}, Network: "bridge",
		MemoryMB: 512, CPUs: 1, PIDs: 256, Labels: map[string]string{"agnts": "muse-voice"},
		// A volume, not a tmpfs: Docker's archive API writes the clip and
		// the credential file, and reads a refreshed one back.
		Volumes: []string{homeDir},
		Tmpfs:   map[string]string{"/tmp": "rw,exec,nosuid,size=64m,uid=1000,gid=1000"},
	})
	if err != nil {
		return "", fmt.Errorf("voice container: %w", err)
	}
	defer func() { _ = r.docker.Remove(context.WithoutCancel(ctx), id) }()
	if err := r.docker.Start(ctx, id); err != nil {
		return "", err
	}
	w := &workspace{docker: r.docker, id: id}
	for _, f := range files {
		if err := w.WriteFile(ctx, f.Path, f.Data); err != nil {
			return "", fmt.Errorf("muse credential file: %w", err)
		}
	}
	if err := w.WriteFile(ctx, voiceClip, wav); err != nil {
		return "", fmt.Errorf("voice clip: %w", err)
	}
	var stdout, stderr tailBuffer
	code, err := r.docker.Exec(ctx, id, ExecConfig{
		Cmd:  []string{"muse", "voice", "transcribe", voiceClip},
		User: agentUser,
		Env: append([]string{"HOME=" + homeDir, "XDG_DATA_HOME=" + homeDir + "/.local/share", "NO_COLOR=1",
			"MUSE_UPDATE_INTERVAL_SECONDS=31536000", museFileCredentials}, env...),
	}, &stdout, &stderr)
	if err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return "", fmt.Errorf("muse took longer than %s to hear the clip", TranscribeTimeout)
		}
		return "", err
	}
	r.keepVoiceLogin(ctx, w, files)
	said := domain.NewSecretRedactor(cred.Secrets()...).String(strings.TrimSpace(stderr.String()))
	return voiceResult(code, stdout.String(), said)
}

// voiceResult reads `muse voice transcribe`'s exit: the words, or why not.
func voiceResult(code int, stdout, stderr string) (string, error) {
	switch code {
	case 0:
		if text := strings.TrimSpace(stdout); text != "" {
			return text, nil
		}
		return "", orchestrator.ErrNoSpeech
	case voiceNoWords:
		return "", orchestrator.ErrNoSpeech
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

// keepVoiceLogin saves a login Muse refreshed while it listened.
func (r *Runner) keepVoiceLogin(ctx context.Context, w *workspace, files []credential.File) {
	if r.keepLogin == nil {
		return
	}
	for _, f := range files {
		if f.Path != museAuthPath {
			continue
		}
		now, err := w.ReadFile(ctx, f.Path)
		if err != nil || len(now) == 0 || string(now) == string(f.Data) {
			return
		}
		_ = r.keepLogin(context.WithoutCancel(ctx), now)
	}
}
