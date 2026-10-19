-- +goose Up
-- The assistant proposes writes on its answers: each is a pending action
-- that only the person who asked may confirm (user_id), shown with the
-- answer that proposed it, with what happened when it was confirmed or
-- declined. The run itself still cannot act.
ALTER TABLE pending_actions DROP CONSTRAINT pending_actions_origin_check;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_origin_check CHECK (origin IN ('mcp', 'telegram', 'assistant'));
ALTER TABLE pending_actions ADD COLUMN user_id bigint REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE pending_actions ADD COLUMN assistant_message_id bigint REFERENCES assistant_messages (id) ON DELETE CASCADE;
ALTER TABLE pending_actions ADD COLUMN outcome text CHECK (outcome IN ('done', 'failed', 'cancelled'));
ALTER TABLE pending_actions ADD COLUMN result text NOT NULL DEFAULT '';
ALTER TABLE pending_actions ADD COLUMN finished_at timestamptz;
CREATE INDEX pending_actions_assistant_message ON pending_actions (assistant_message_id) WHERE assistant_message_id IS NOT NULL;

-- Proposals the run made that agnts could not prepare, and why.
ALTER TABLE assistant_messages ADD COLUMN action_errors text[] NOT NULL DEFAULT '{}';

ALTER TABLE events DROP CONSTRAINT events_origin_check;
ALTER TABLE events ADD CONSTRAINT events_origin_check
    CHECK (origin IN ('system', 'web', 'mobile', 'mcp', 'telegram', 'webhook', 'assistant'));

-- +goose Down
UPDATE events SET origin = 'mobile' WHERE origin = 'assistant';
ALTER TABLE events DROP CONSTRAINT events_origin_check;
ALTER TABLE events ADD CONSTRAINT events_origin_check
    CHECK (origin IN ('system', 'web', 'mobile', 'mcp', 'telegram', 'webhook'));
ALTER TABLE assistant_messages DROP COLUMN action_errors;
DELETE FROM pending_actions WHERE origin = 'assistant';
DROP INDEX pending_actions_assistant_message;
ALTER TABLE pending_actions DROP COLUMN finished_at;
ALTER TABLE pending_actions DROP COLUMN result;
ALTER TABLE pending_actions DROP COLUMN outcome;
ALTER TABLE pending_actions DROP COLUMN assistant_message_id;
ALTER TABLE pending_actions DROP COLUMN user_id;
ALTER TABLE pending_actions DROP CONSTRAINT pending_actions_origin_check;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_origin_check CHECK (origin IN ('mcp', 'telegram'));
