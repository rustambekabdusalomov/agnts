-- +goose Up
-- Which sibling suggestions must land first: when both become tickets,
-- this one depends on them, so the queue starts them in order.
ALTER TABLE ticket_suggestions ADD COLUMN after bigint[] NOT NULL DEFAULT '{}';

-- +goose Down
ALTER TABLE ticket_suggestions DROP COLUMN after;
