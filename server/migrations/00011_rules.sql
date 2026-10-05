-- +goose Up
-- Rules the user writes for hiro to follow on every ticket: global ones
-- (repo_id NULL) and per-repository ones. Claude reviews each rule before it
-- applies and may ask questions; status says where that review is.
-- questions holds every question asked so far, answered or not.
-- revision counts edits and answers, so a review of an older version is
-- discarded instead of overwriting the newer one.
CREATE TABLE rules (
    id             bigserial PRIMARY KEY,
    repo_id        bigint REFERENCES repositories (id) ON DELETE CASCADE,
    title          text NOT NULL,
    body           text NOT NULL,
    enabled        boolean NOT NULL DEFAULT true,
    status         text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'analyzing', 'questions', 'ready', 'failed')),
    interpretation text NOT NULL DEFAULT '',
    clarified      text NOT NULL DEFAULT '',
    questions      jsonb NOT NULL DEFAULT '[]',
    rounds         integer NOT NULL DEFAULT 0,
    revision       integer NOT NULL DEFAULT 0,
    error          text NOT NULL DEFAULT '',
    analyzed_at    timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX rules_repo_idx ON rules (repo_id);
CREATE INDEX rules_pending_idx ON rules (updated_at) WHERE status = 'pending';

-- +goose Down
DROP TABLE rules;
