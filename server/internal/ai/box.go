package ai

import (
	"context"
	"io"

	"agnts/internal/domain"
)

// Paths inside a run container (the runner image), which providers use.
const (
	WorkDir    = "/workspace"
	HomeDir    = "/home/agent"
	ClaudeHome = HomeDir + "/.claude"
	// OutDir is where runs write what agnts reads back (analysis.json).
	OutDir = "/agnts/out"
)

// Cmd is a command run in a box, as its agent user.
type Cmd struct {
	Argv []string
	Env  []string // KEY=value, on top of the box's own
	// Dir is the working directory; "" is WorkDir.
	Dir string
}

// Box is a container an agent runs in: the runner's run containers, or a
// throwaway one (Boxes). Providers run their tools through it.
type Box interface {
	ID() string
	// Run runs cmd, writing its stdout and stderr, and returns its exit
	// code.
	Run(ctx context.Context, cmd Cmd, stdout, stderr io.Writer) (int, error)
	// Attach starts cmd with stdin attached (processes that speak a
	// protocol over stdio).
	Attach(ctx context.Context, cmd Cmd, stderr io.Writer) (Process, error)
	// ReadFile returns a file, or domain.ErrNotFound.
	ReadFile(ctx context.Context, path string) ([]byte, error)
	// WriteFile puts a file in, readable by the agent.
	WriteFile(ctx context.Context, path string, data []byte) error
	// OOM returns an *OOMError when a process that exited with code was
	// killed at the box's memory limit, else nil.
	OOM(ctx context.Context, code int) error
}

// Process is a command started with Box.Attach.
type Process interface {
	io.ReadWriteCloser // Close ends its stdin
	Kill() error
	// Wait waits for it to end and returns its exit code.
	Wait(ctx context.Context) (int, error)
}

// BoxSpec describes a throwaway box: no repository, a network to reach
// the provider's API, small limits.
type BoxSpec struct {
	Image    string
	Label    string // what it is for (the "agnts" label)
	MemoryMB int64
}

// Boxes opens throwaway boxes, for work that has no run container
// (hearing a meeting).
type Boxes interface {
	OpenBox(ctx context.Context, spec BoxSpec) (Box, func(), error)
}

// Segment is a stretch of speech heard in a recording.
type Segment = domain.MeetingSegment
