-- +goose Up
-- self_fixes counts the times agnts's own review sent findings back to the
-- coder since a person last asked for changes (at most one round each).
-- quiet_review marks a ticket that reached review without being announced,
-- because agnts's own review may still send it back; it is announced when
-- that review ends.
ALTER TABLE tickets ADD COLUMN self_fixes integer NOT NULL DEFAULT 0;
ALTER TABLE tickets ADD COLUMN quiet_review boolean NOT NULL DEFAULT false;

-- What agnts's scan of a change flagged (skipped tests, removed assertions,
-- silenced linters, ...), kept with the change.
ALTER TABLE results ADD COLUMN red_flags jsonb NOT NULL DEFAULT '[]';

-- +goose Down
ALTER TABLE results DROP COLUMN red_flags;
ALTER TABLE tickets DROP COLUMN quiet_review;
ALTER TABLE tickets DROP COLUMN self_fixes;
