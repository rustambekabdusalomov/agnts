-- +goose Up
-- Which question a Telegram message asks, so a text reply answers it.
ALTER TABLE telegram_messages ADD COLUMN ref bigint;
ALTER TABLE telegram_messages DROP CONSTRAINT telegram_messages_kind_check;
ALTER TABLE telegram_messages ADD CONSTRAINT telegram_messages_kind_check
    CHECK (kind IN ('questions', 'question', 'review', 'feedback', 'confirm', 'notice'));

ALTER TABLE pending_actions ADD COLUMN ticket_key text NOT NULL DEFAULT '';
CREATE INDEX pending_actions_expires_idx ON pending_actions (expires_at);

-- +goose Down
DROP INDEX pending_actions_expires_idx;
ALTER TABLE pending_actions DROP COLUMN ticket_key;
ALTER TABLE telegram_messages DROP CONSTRAINT telegram_messages_kind_check;
DELETE FROM telegram_messages WHERE kind NOT IN ('questions', 'review', 'confirm', 'notice');
ALTER TABLE telegram_messages ADD CONSTRAINT telegram_messages_kind_check
    CHECK (kind IN ('questions', 'review', 'confirm', 'notice'));
ALTER TABLE telegram_messages DROP COLUMN ref;
