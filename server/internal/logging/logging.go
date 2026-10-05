// Package logging builds the process-wide slog logger.
package logging

import (
	"io"
	"log/slog"
)

// New returns a logger writing to w in the given format ("json" or "text")
// at the given level ("debug", "info", "warn", "error").
func New(w io.Writer, format, level string) *slog.Logger {
	var lvl slog.Level
	_ = lvl.UnmarshalText([]byte(level))
	opts := &slog.HandlerOptions{Level: lvl}
	if format == "text" {
		return slog.New(slog.NewTextHandler(w, opts))
	}
	return slog.New(slog.NewJSONHandler(w, opts))
}
