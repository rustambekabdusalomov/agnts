package orchestrator

import (
	"context"
	"strings"

	"agnts/internal/domain"
)

// LogPrefix is the key prefix of tickets the log watcher opens.
const LogPrefix = "LOG"

// LogTicketInput is a log finding to turn into a ticket.
type LogTicketInput struct {
	// RepoIDs are the repositories the service runs on, the one the error
	// is most likely in first.
	RepoIDs     []int64
	Title       string
	Description string
	Priority    string
	// Kind is code (the analysis may switch it to a bug report) or bug (a
	// cause outside the code: config, infra).
	Kind domain.TicketKind
	// Log is the redacted excerpt, attached as log-excerpt.txt so the run
	// can read all of it while the prompt stays short.
	Log string
}

// CreateLogTicket opens a ticket in agnts for a log finding, on every
// repository of the service (one multi-repository ticket for a gateway).
// Like CI tickets, it never asks questions first.
func (o *Orchestrator) CreateLogTicket(ctx context.Context, in LogTicketInput, origin domain.Origin) (domain.Ticket, error) {
	if len(in.RepoIDs) == 0 {
		return domain.Ticket{}, invalid("select the repositories this service runs on first")
	}
	kind := in.Kind
	if kind == "" {
		kind = domain.KindCode
	}
	res, err := o.resolveRepos(ctx, domain.RepoChoice{RepoIDs: in.RepoIDs}, kind, kind == domain.KindCode)
	if err != nil {
		return domain.Ticket{}, err
	}
	if len(res.Repos) == 0 {
		return domain.Ticket{}, invalid("the service's repositories are archived or gone")
	}
	if in.Priority == "" {
		in.Priority = "high"
	}
	var files []int64
	if strings.TrimSpace(in.Log) != "" {
		a, err := o.Upload(ctx, "log-excerpt.txt", []byte(in.Log))
		if err != nil {
			o.log.Warn("log excerpt attachment", "err", err)
		} else {
			files = []int64{a.ID}
		}
	}
	title := strings.TrimSpace(in.Title)
	if r := []rune(title); len(r) > 200 {
		title = string(r[:199]) + "…"
	}
	t := domain.Ticket{
		Source: domain.SourceLogs, Title: title, Description: strings.TrimSpace(in.Description),
		Priority: in.Priority, State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr",
		AskFirst: false, Kind: kind, KindAuto: kind == domain.KindCode,
	}
	res.apply(&t)
	return o.createTask(ctx, t, LogPrefix, files, origin)
}
