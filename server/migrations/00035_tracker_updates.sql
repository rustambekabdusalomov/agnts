-- +goose Up
-- A newer version of an issue from the tracker that arrived after agnts
-- started on its ticket: tracker_update holds it until a person restarts
-- the ticket with it or keeps the current one (tracker_kept is the hash of
-- the version they kept, so it is not asked about again).
ALTER TABLE tickets ADD COLUMN tracker_update jsonb;
ALTER TABLE tickets ADD COLUMN tracker_kept text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE tickets DROP COLUMN tracker_kept;
ALTER TABLE tickets DROP COLUMN tracker_update;
