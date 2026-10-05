-- +goose Up
-- After a ticket is pushed, a learn run looks for things the change does that
-- the repository never did before and writes them up as lessons.
-- learn_state: '' (not queued), pending, done or failed.
ALTER TABLE tickets ADD COLUMN learn_state text NOT NULL DEFAULT '';
CREATE INDEX tickets_learn_pending_idx ON tickets (updated_at) WHERE learn_state = 'pending';

-- One row per concept per repository: (repo_id, slug) is the knowledge base
-- the learn run checks before calling something new.
CREATE TABLE lessons (
    id          bigserial PRIMARY KEY,
    repo_id     bigint NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
    ticket_key  text NOT NULL,
    slug        text NOT NULL,
    title       text NOT NULL,
    category    text NOT NULL,
    level       text NOT NULL,
    summary     text NOT NULL,
    explanation text NOT NULL DEFAULT '',
    why_here    text NOT NULL DEFAULT '',
    refs        jsonb NOT NULL DEFAULT '[]',
    quiz        jsonb NOT NULL DEFAULT '[]',
    reading     jsonb NOT NULL DEFAULT '[]',
    learned_at  timestamptz,
    created_at  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (repo_id, slug)
);
CREATE INDEX lessons_ticket_idx ON lessons (ticket_key);
CREATE INDEX lessons_created_idx ON lessons (created_at DESC);

-- +goose Down
DROP TABLE lessons;
DROP INDEX tickets_learn_pending_idx;
ALTER TABLE tickets DROP COLUMN learn_state;
