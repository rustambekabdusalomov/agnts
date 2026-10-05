// Package migrations holds the SQL schema migrations, applied with goose.
package migrations

import "embed"

// FS contains every migration file.
//
//go:embed *.sql
var FS embed.FS
