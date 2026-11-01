package runner

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

var _ ai.Boxes = (*Runner)(nil)

// OpenBox implements ai.Boxes: a throwaway container from spec's image,
// with a network to reach the provider's API and nothing of a workspace.
// close removes it.
func (r *Runner) OpenBox(ctx context.Context, spec ai.BoxSpec) (ai.Box, func(), error) {
	life := spec.Life
	if life <= 0 {
		life = time.Hour
	}
	cpus := spec.CPUs
	if cpus <= 0 {
		cpus = 1
	}
	tmp := spec.TmpMB
	if tmp <= 0 {
		tmp = 64
	}
	id, err := r.docker.Create(ctx, ContainerConfig{
		Image: spec.Image, User: agentUser, Cmd: []string{"sleep", strconv.Itoa(int(life.Seconds()))}, Network: "bridge",
		MemoryMB: spec.MemoryMB, CPUs: cpus, PIDs: 256, Labels: map[string]string{"agnts": spec.Label},
		// A volume, not a tmpfs: Docker's archive API writes the files in
		// (credential, audio) and reads a refreshed login back.
		Volumes: []string{homeDir},
		Tmpfs:   map[string]string{"/tmp": "rw,exec,nosuid,size=" + strconv.Itoa(tmp) + "m,uid=1000,gid=1000"},
	})
	if err != nil {
		return nil, nil, err
	}
	closeBox := func() { _ = r.docker.Remove(context.WithoutCancel(ctx), id) }
	if err := r.docker.Start(ctx, id); err != nil {
		closeBox()
		return nil, nil, err
	}
	return &workspace{docker: r.docker, id: id, memoryMB: spec.MemoryMB}, closeBox, nil
}

// hearer is the provider that hears audio.
func (r *Runner) hearer() (ai.Hearer, error) {
	if r.providers == nil {
		return nil, errors.New("muse is not available on this server")
	}
	p, ok := r.providers.Get(ai.Muse)
	h, can := p.(ai.Hearer)
	if !ok || !can || !p.Caps().Has(ai.CapAudio) {
		return nil, errors.New("muse does not hear audio on this server")
	}
	return h, nil
}

// TranscribeTimeout bounds hearing one spoken question.
const TranscribeTimeout = 90 * time.Second

// Transcribe returns the words spoken in a WAV clip, heard by Muse on the
// Muse account in ctx.
func (r *Runner) Transcribe(ctx context.Context, _ string, wav []byte) (string, error) {
	h, err := r.hearer()
	if err != nil {
		return "", err
	}
	c, err := r.token(ctx)
	if err != nil {
		return "", fmt.Errorf("muse credential: %w", err)
	}
	return h.HearClip(ctx, c, wav)
}

// TranscribeMeeting hears a meeting's audio on the Muse account in ctx.
func (r *Runner) TranscribeMeeting(ctx context.Context, _ string, audio []byte, ext string) ([]domain.MeetingSegment, error) {
	h, err := r.hearer()
	if err != nil {
		return nil, err
	}
	c, err := r.token(ctx)
	if err != nil {
		return nil, fmt.Errorf("muse credential: %w", err)
	}
	return h.Hear(ctx, c, audio, ext)
}
