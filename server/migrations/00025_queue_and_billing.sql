-- +goose Up
-- Why a ticket waits for a worker, in a sentence ("waiting for a free slot
-- (1 of 1 in use)"), next to wait_reason.
ALTER TABLE tickets ADD COLUMN wait_message text NOT NULL DEFAULT '';

-- Billing: a cloud workspace's plan is paid a month at a time from its
-- prepaid balance; paid_until is when the next month is due.
ALTER TABLE workspaces ADD COLUMN paid_until timestamptz;

-- +goose Down
ALTER TABLE workspaces DROP COLUMN paid_until;
ALTER TABLE tickets DROP COLUMN wait_message;
