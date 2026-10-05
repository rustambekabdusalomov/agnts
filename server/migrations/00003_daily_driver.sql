-- +goose Up
ALTER TABLE tickets
    ADD COLUMN held      boolean NOT NULL DEFAULT false,
    ADD COLUMN ask_first boolean NOT NULL DEFAULT true;

ALTER TABLE repositories
    ADD COLUMN task_prefix      text    NOT NULL DEFAULT '',
    ADD COLUMN task_seq         integer NOT NULL DEFAULT 0,
    ADD COLUMN claude_md_status text    NOT NULL DEFAULT 'unknown'
        CHECK (claude_md_status IN ('found', 'missing', 'unknown'));

ALTER TABLE usage_snapshots
    ADD COLUMN seven_day_resets_at timestamptz,
    ADD COLUMN raw jsonb NOT NULL DEFAULT '{}';

ALTER TABLE integrations
    ADD COLUMN account    text NOT NULL DEFAULT '',
    ADD COLUMN last_error text NOT NULL DEFAULT '';

CREATE INDEX events_level_idx ON events (level, created_at) WHERE level IN ('warn', 'error');

-- Every insert into events wakes SSE listeners (delivered on commit).
-- +goose StatementBegin
CREATE FUNCTION notify_event() RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify('hiro_events', NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER events_notify AFTER INSERT ON events FOR EACH ROW EXECUTE FUNCTION notify_event();

-- +goose Down
DROP TRIGGER events_notify ON events;
DROP FUNCTION notify_event();
DROP INDEX events_level_idx;
ALTER TABLE integrations DROP COLUMN last_error, DROP COLUMN account;
ALTER TABLE usage_snapshots DROP COLUMN raw, DROP COLUMN seven_day_resets_at;
ALTER TABLE repositories DROP COLUMN claude_md_status, DROP COLUMN task_seq, DROP COLUMN task_prefix;
ALTER TABLE tickets DROP COLUMN ask_first, DROP COLUMN held;
