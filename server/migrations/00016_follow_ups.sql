-- +goose Up
-- A run may suggest follow-up tickets: what its parent ticket still needs
-- to be finished (prerequisites, parts to split off, work left undone,
-- gaps a report found). Nothing is created until someone accepts one;
-- the new ticket then points back with follow_up_of. A ticket can have
-- any number of follow-ups, unlike parent_key (one implementation).
-- suggest_follow_ups: NULL follows the setting, true/false overrides it.
CREATE TABLE ticket_suggestions (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id   bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    run_id      bigint      REFERENCES runs (id) ON DELETE SET NULL,
    source      text        NOT NULL CHECK (source IN ('analyze', 'work', 'review', 'manual')),
    type        text        NOT NULL CHECK (type IN ('prerequisite', 'split', 'unfinished', 'gap')),
    revision    integer     NOT NULL DEFAULT 0,
    title       text        NOT NULL,
    description text        NOT NULL DEFAULT '',
    serves      text        NOT NULL,
    kind        text        NOT NULL,
    priority    text        NOT NULL,
    status      text        NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'accepted', 'dismissed')),
    child_key   text,
    decided_at  timestamptz,
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ticket_suggestions_ticket_idx ON ticket_suggestions (ticket_id, status);

ALTER TABLE tickets
    ADD COLUMN follow_up_of text,
    ADD COLUMN suggest_follow_ups boolean;
CREATE INDEX tickets_follow_up_of_idx ON tickets (follow_up_of) WHERE follow_up_of IS NOT NULL;

-- +goose Down
DROP INDEX tickets_follow_up_of_idx;
ALTER TABLE tickets DROP COLUMN suggest_follow_ups, DROP COLUMN follow_up_of;
DROP TABLE ticket_suggestions;
