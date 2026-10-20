package orchestrator

import (
	"context"

	"agnts/internal/domain"
)

// CommitLinker links commits on the git host to tickets by their number
// or key (commitlink.Service).
type CommitLinker interface {
	// TicketNumberChanged hears that a ticket arrived (old "") or that its
	// number changed from old; it returns at once.
	TicketNumberChanged(ctx context.Context, t domain.Ticket, old string)
}

// SetCommitLinker sets the linker (nil for none). Call it before Run.
func (o *Orchestrator) SetCommitLinker(l CommitLinker) { o.links = l }

func (o *Orchestrator) numberChanged(ctx context.Context, t domain.Ticket, old string) {
	if o.links != nil && t.ID != 0 {
		o.links.TicketNumberChanged(ctx, t, old)
	}
}
