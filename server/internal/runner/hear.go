package runner

import (
	"context"
	"strconv"
	"time"

	"agnts/internal/ai"
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
