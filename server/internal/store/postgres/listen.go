package postgres

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Listen calls notify for every NOTIFY on channel until ctx ends,
// reconnecting after errors. Notifications may be coalesced.
func Listen(ctx context.Context, db *pgxpool.Pool, channel string, notify func(), log *slog.Logger) {
	for ctx.Err() == nil {
		err := listenOnce(ctx, db, channel, notify)
		if ctx.Err() != nil {
			return
		}
		log.Warn("listen: reconnecting", "channel", channel, "err", err)
		notify() // catch up on anything missed while disconnected
		select {
		case <-ctx.Done():
			return
		case <-time.After(2 * time.Second):
		}
	}
}

func listenOnce(ctx context.Context, db *pgxpool.Pool, channel string, notify func()) error {
	conn, err := db.Acquire(ctx)
	if err != nil {
		return err
	}
	defer conn.Release()
	if _, err := conn.Exec(ctx, "LISTEN "+channel); err != nil {
		return err
	}
	for {
		if _, err := conn.Conn().WaitForNotification(ctx); err != nil {
			return err
		}
		notify()
	}
}

// MaxEventID returns the newest event id.
func (s *Agent) MaxEventID(ctx context.Context) (int64, error) {
	var id int64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(max(id), 0) FROM events`).Scan(&id)
	return id, err
}
