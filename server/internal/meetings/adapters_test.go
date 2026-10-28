package meetings_test

import (
	"context"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/livekit"
	"agnts/internal/meetings"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// The adapters agnts wires in implement the service's ports.
var (
	_ meetings.Store   = (*postgres.Meetings)(nil)
	_ meetings.LiveKit = (*livekit.Client)(nil)
	_ meetings.Notes   = (*documents.Service)(nil)
	_ meetings.Hearer  = (*orchestrator.Orchestrator)(nil)
	// Tickets: the orchestrator makes tasks, the store finds tickets
	// (cmd/agnts joins them).
	_ interface {
		CreateTask(ctx context.Context, in orchestrator.TaskInput, origin domain.Origin) (domain.Ticket, error)
	} = (*orchestrator.Orchestrator)(nil)
	_ interface {
		TicketByKey(ctx context.Context, key string) (domain.Ticket, error)
	} = (*postgres.Agent)(nil)
)
