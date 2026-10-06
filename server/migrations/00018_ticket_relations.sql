-- +goose Up
-- Ordering constraints between tickets. depends_on: ticket_key does not
-- start coding until other_key is merged (or rejected). conflicts: the two
-- change the same code, so whichever starts coding second waits until the
-- first is merged; the pair is stored with the smaller key first.
-- source: jira (a "blocks" link), user, agnts (the analysis read it from
-- the tickets), rule (predicted footprints overlap) or git (the finished
-- branches touch the same lines). Only active relations hold the queue;
-- proposed ones wait for someone, dismissed ones are never proposed again.
-- found_by is the ticket whose analysis found an agnts or rule relation,
-- so a new analysis of it replaces what the old one found. confirmed_at is
-- when the finished changes proved a conflict real; the source still says
-- who predicted it (git when nobody did), which is what the eval scores.
CREATE TABLE ticket_relations (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_key  text        NOT NULL REFERENCES tickets (key) ON DELETE CASCADE,
    other_key   text        NOT NULL REFERENCES tickets (key) ON DELETE CASCADE,
    type        text        NOT NULL CHECK (type IN ('depends_on', 'conflicts')),
    source      text        NOT NULL CHECK (source IN ('jira', 'user', 'agnts', 'rule', 'git')),
    status      text        NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'proposed', 'dismissed')),
    confidence  real        NOT NULL DEFAULT 1,
    reason      text        NOT NULL DEFAULT '',
    basis       text        NOT NULL DEFAULT '',
    files       text[]      NOT NULL DEFAULT '{}',
    found_by    text,
    confirmed_at timestamptz,
    decided_at  timestamptz,
    created_at  timestamptz NOT NULL DEFAULT now(),
    CHECK (ticket_key <> other_key),
    CHECK (type <> 'conflicts' OR ticket_key < other_key),
    UNIQUE (ticket_key, other_key, type)
);
CREATE INDEX ticket_relations_other_idx ON ticket_relations (other_key);

-- +goose Down
DROP TABLE ticket_relations;
