-- +goose Up
-- CI watching: agnts triages failed CI runs (GitHub Actions, GitLab
-- pipelines) into groups by fingerprint, and fixes the ones in the code.

-- ci_watches is one repository's watch settings (no row: not watched).
CREATE TABLE ci_watches (
  repo_id      bigint      PRIMARY KEY REFERENCES repositories ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  config     jsonb       NOT NULL DEFAULT '{}',
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ci_failures groups the failures of one job with the same fingerprint on
-- one branch. A ticket is made per group, never per run.
CREATE TABLE ci_failures (
  id            bigserial   PRIMARY KEY,
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id       bigint      NOT NULL REFERENCES repositories ON DELETE CASCADE,
  branch        text        NOT NULL,
  workflow      text        NOT NULL,             -- workflow file, or "pipeline" on GitLab
  job           text        NOT NULL,
  fingerprint   text        NOT NULL,
  class         text        NOT NULL DEFAULT '',  -- code, test, config, dependency, infra, flaky
  title         text        NOT NULL,
  status        text        NOT NULL DEFAULT 'open',
  count         integer     NOT NULL DEFAULT 1,
  flaky_count   integer     NOT NULL DEFAULT 0,
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at  timestamptz NOT NULL DEFAULT now(),
  first_sha     text        NOT NULL DEFAULT '',
  last_sha      text        NOT NULL DEFAULT '',
  sample        bytea,                            -- redacted log excerpt, sealed with AGNTS_ENC_KEY
  occurrences   jsonb       NOT NULL DEFAULT '[]', -- the last 20 failing runs
  ticket_key    text        NOT NULL DEFAULT '',
  fixed_sha     text        NOT NULL DEFAULT '',
  fixed_at      timestamptz,
  pr_number     integer     NOT NULL DEFAULT 0,   -- another person's pull request (comment mode)
  comment_id    text        NOT NULL DEFAULT '',
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (repo_id, branch, workflow, fingerprint)
);
CREATE INDEX ci_failures_open ON ci_failures (workspace_id, status, last_seen_at DESC);
CREATE INDEX ci_failures_ticket ON ci_failures (ticket_key) WHERE ticket_key <> '';

ALTER TABLE ci_watches ENABLE ROW LEVEL SECURITY;
ALTER TABLE ci_watches FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON ci_watches USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE ci_failures ENABLE ROW LEVEL SECURITY;
ALTER TABLE ci_failures FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON ci_failures USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Tickets agnts opens for failing CI have their own source.
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git', 'ci'));

-- ci_fixes counts the rounds red CI sent a ticket's pull request back to
-- coding since a person last approved it.
ALTER TABLE tickets ADD COLUMN ci_fixes integer NOT NULL DEFAULT 0;

-- +goose Down
ALTER TABLE tickets DROP COLUMN ci_fixes;
DELETE FROM tickets WHERE source = 'ci';
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git'));
DROP TABLE ci_failures;
DROP TABLE ci_watches;
