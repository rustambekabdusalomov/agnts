-- +goose Up
-- While a ticket waits for the human review, a review run reads the change
-- (or the report) and writes findings next to it. It never changes the
-- ticket's state and never gates approval.
-- review_state: '' (none), pending, running, done or failed. The review
-- itself is a results row of the review run.
ALTER TABLE tickets ADD COLUMN review_state text NOT NULL DEFAULT '';
CREATE INDEX tickets_review_pending_idx ON tickets (updated_at) WHERE review_state = 'pending';

-- +goose Down
DROP INDEX tickets_review_pending_idx;
ALTER TABLE tickets DROP COLUMN review_state;
