package postgres

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

const suggestionCols = `id, ticket_id, run_id, source, type, revision, title, description, serves, kind, priority, status,
	after, COALESCE(child_key, ''), decided_at, created_at, repo_ids`

func scanSuggestion(row pgx.Row) (domain.Suggestion, error) {
	var s domain.Suggestion
	var kind string
	err := row.Scan(&s.ID, &s.TicketID, &s.RunID, &s.Source, &s.Type, &s.Revision, &s.Title, &s.Description, &s.Serves,
		&kind, &s.Priority, &s.Status, &s.After, &s.ChildKey, &s.DecidedAt, &s.CreatedAt, &s.RepoIDs)
	s.Kind = domain.TicketKind(kind)
	return s, notFound(err)
}

// ReplaceSuggestions swaps the open suggestions a source made for a ticket
// for a new set. Accepted and dismissed ones are kept: they record what
// someone decided. Each one's AfterIndex is stored as the ids of the
// others in the set.
func (s *Agent) ReplaceSuggestions(ctx context.Context, ticketID int64, source string, ss []domain.Suggestion, ev *domain.Event) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM ticket_suggestions WHERE ticket_id = $1 AND source = $2 AND status = 'open'`,
			ticketID, source); err != nil {
			return err
		}
		ids := make([]int64, len(ss))
		for i, x := range ss {
			out, err := insertSuggestion(ctx, tx, ticketID, x)
			if err != nil {
				return err
			}
			ids[i] = out.ID
		}
		for i, x := range ss {
			after := []int64{}
			for _, j := range x.AfterIndex {
				if j >= 0 && j < len(ids) && j != i {
					after = append(after, ids[j])
				}
			}
			if len(after) == 0 {
				continue
			}
			if _, err := tx.Exec(ctx, `UPDATE ticket_suggestions SET after = $2 WHERE id = $1`, ids[i], after); err != nil {
				return err
			}
		}
		if ev != nil {
			return insertEvent(ctx, tx, *ev)
		}
		return nil
	})
}

// AddSuggestion stores one more suggestion for a ticket.
func (s *Agent) AddSuggestion(ctx context.Context, x domain.Suggestion, ev domain.Event) (domain.Suggestion, error) {
	var out domain.Suggestion
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		if out, err = insertSuggestion(ctx, tx, x.TicketID, x); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

func insertSuggestion(ctx context.Context, tx pgx.Tx, ticketID int64, x domain.Suggestion) (domain.Suggestion, error) {
	return scanSuggestion(tx.QueryRow(ctx, `INSERT INTO ticket_suggestions
		(ticket_id, run_id, source, type, revision, title, description, serves, kind, priority, repo_ids)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING `+suggestionCols,
		ticketID, x.RunID, x.Source, x.Type, x.Revision, x.Title, x.Description, x.Serves, string(x.Kind), x.Priority, nonNilIDs(x.RepoIDs)))
}

func nonNilIDs(ids []int64) []int64 {
	if ids == nil {
		return []int64{}
	}
	return ids
}

// Suggestions returns a ticket's suggestions, oldest first.
func (s *Agent) Suggestions(ctx context.Context, ticketID int64) ([]domain.Suggestion, error) {
	rows, err := s.db.Query(ctx, `SELECT `+suggestionCols+` FROM ticket_suggestions WHERE ticket_id = $1 ORDER BY id`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Suggestion{}
	for rows.Next() {
		x, err := scanSuggestion(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, x)
	}
	return out, rows.Err()
}

// OpenSuggestionCounts returns how many open suggestions each ticket has.
func (s *Agent) OpenSuggestionCounts(ctx context.Context, keys []string) (map[string]int, error) {
	rows, err := s.db.Query(ctx, `SELECT t.key, count(*) FROM ticket_suggestions x JOIN tickets t ON t.id = x.ticket_id
		WHERE x.status = 'open' AND t.key = ANY($1) GROUP BY t.key`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]int{}
	for rows.Next() {
		var k string
		var n int
		if err := rows.Scan(&k, &n); err != nil {
			return nil, err
		}
		out[k] = n
	}
	return out, rows.Err()
}

// DismissSuggestion marks an open suggestion dismissed.
func (s *Agent) DismissSuggestion(ctx context.Context, ticketID, id int64, ev domain.Event) (domain.Suggestion, error) {
	var out domain.Suggestion
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		if out, err = lockOpenSuggestion(ctx, tx, ticketID, id); err != nil {
			return err
		}
		if out, err = scanSuggestion(tx.QueryRow(ctx, `UPDATE ticket_suggestions SET status = 'dismissed', decided_at = now()
			WHERE id = $1 RETURNING `+suggestionCols, id)); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

// CreateFollowUp creates the ticket made from an open suggestion and marks
// the suggestion accepted, in one transaction, so a suggestion makes one
// ticket however often it is accepted. A taken key is domain.ErrConflict;
// a suggestion that is no longer open is domain.ErrSuggestionDecided.
func (s *Agent) CreateFollowUp(ctx context.Context, ticketID, id int64, t domain.Ticket, ev domain.Event) (domain.Ticket, error) {
	var out domain.Ticket
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := lockOpenSuggestion(ctx, tx, ticketID, id); err != nil {
			return err
		}
		models, _ := json.Marshal(nonNilMap(t.Models))
		var err error
		if out, err = insertTicket(ctx, tx, t, models); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `UPDATE ticket_suggestions SET status = 'accepted', child_key = $2, decided_at = now() WHERE id = $1`,
			id, out.Key); err != nil {
			return err
		}
		if err := insertEvent(ctx, tx, domain.Event{TicketKey: out.Key, Type: domain.EventTicketCreated, Origin: ev.Origin, Message: out.Title}); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

func lockOpenSuggestion(ctx context.Context, tx pgx.Tx, ticketID, id int64) (domain.Suggestion, error) {
	x, err := scanSuggestion(tx.QueryRow(ctx, `SELECT `+suggestionCols+` FROM ticket_suggestions WHERE id = $1 AND ticket_id = $2 FOR UPDATE`,
		id, ticketID))
	if err != nil {
		return x, err
	}
	if x.Status != domain.SuggestionOpen {
		return x, fmt.Errorf("%w: it is %s", domain.ErrSuggestionDecided, x.Status)
	}
	return x, nil
}

// FollowUpsOf returns the tickets made from parentKey's suggestions,
// oldest first.
func (s *Agent) FollowUpsOf(ctx context.Context, parentKey string) ([]domain.Ticket, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+` FROM tickets WHERE follow_up_of = $1 ORDER BY id`, parentKey)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Ticket{}
	for rows.Next() {
		t, err := scanTicket(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// OpenTicketRefs returns the newest unfinished tickets of a repository (or
// of tasks without one), so a run can avoid suggesting what exists.
func (s *Agent) OpenTicketRefs(ctx context.Context, repoID *int64, limit int) ([]orchestrator.TicketRef, error) {
	rows, err := s.db.Query(ctx, `SELECT key, title FROM tickets t
		WHERE (($1::bigint IS NULL AND t.repo_id IS NULL) OR ($1::bigint IS NOT NULL AND `+touchesSQL+`)) AND state NOT IN ('done', 'rejected')
		ORDER BY updated_at DESC LIMIT $2`, repoID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []orchestrator.TicketRef{}
	for rows.Next() {
		var r orchestrator.TicketRef
		if err := rows.Scan(&r.Key, &r.Title); err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	return out, rows.Err()
}
