-- +goose Up
-- A replay re-runs a done ticket with the current prompts, from the commit
-- the original started from, to compare the two (Analytics → Replay
-- evaluation). replay_of is the original's key; base_sha is the commit a
-- replay's branch is cut from. Replays are never pushed.
ALTER TABLE tickets ADD COLUMN replay_of text NOT NULL DEFAULT '';
ALTER TABLE tickets ADD COLUMN base_sha text NOT NULL DEFAULT '';
CREATE INDEX tickets_replay_of_idx ON tickets (workspace_id, replay_of) WHERE replay_of <> '';

-- +goose Down
DROP INDEX tickets_replay_of_idx;
ALTER TABLE tickets DROP COLUMN base_sha;
ALTER TABLE tickets DROP COLUMN replay_of;
