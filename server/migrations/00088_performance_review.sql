-- +goose Up
-- Performance reviews (plans/Performance review plan.md): a complexity
-- score per delivered ticket, who gets its points, and each month's
-- totals as they were when the month closed.

-- The prompt, model, formula and anchor examples a score was made with.
CREATE TABLE prompt_versions (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  version      text        NOT NULL,
  model        text        NOT NULL,
  anchors      jsonb       NOT NULL DEFAULT '[]',  -- frozen when the version is created
  current_from timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (workspace_id, version)
);

-- One scoring attempt: the owner of its Claude calls and of its charge.
CREATE TABLE score_runs (
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id      bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery       int         NOT NULL,
  prompt_version text        NOT NULL,
  status         text        NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'scoring', 'done', 'failed')),
  attempts       int         NOT NULL DEFAULT 0,
  error          text        NOT NULL DEFAULT '',
  connection_id  bigint      REFERENCES claude_connections (id) ON DELETE SET NULL,
  on_credits     bool        NOT NULL DEFAULT false,
  created_at     timestamptz NOT NULL DEFAULT now(),
  started_at     timestamptz,
  finished_at    timestamptz,
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
);
CREATE INDEX score_runs_queue_idx ON score_runs (workspace_id, created_at) WHERE status = 'queued';
CREATE UNIQUE INDEX score_runs_one_idx ON score_runs (ticket_id, delivery, prompt_version) WHERE status IN ('queued', 'scoring');

ALTER TABLE claude_calls
  ADD COLUMN score_run_id bigint REFERENCES score_runs (id) ON DELETE CASCADE,
  DROP CONSTRAINT claude_calls_owner_check,
  ADD CONSTRAINT claude_calls_owner_check CHECK (num_nonnulls(run_id, document_run_id, score_run_id) = 1);
CREATE INDEX claude_calls_score_run_idx ON claude_calls (score_run_id) WHERE score_run_id IS NOT NULL;

ALTER TABLE credit_ledger
  ADD COLUMN score_run_id bigint REFERENCES score_runs (id) ON DELETE SET NULL,
  DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'document', 'score', 'refund', 'grant'));
CREATE UNIQUE INDEX credit_ledger_score_run_idx ON credit_ledger (score_run_id) WHERE reason = 'score';

CREATE TABLE ticket_scores (
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id       bigint      NOT NULL,
  delivery        int         NOT NULL,
  prompt_version  text        NOT NULL,
  status          text        NOT NULL CHECK (status IN ('scored', 'unscored')),
  points          int         CHECK (points IN (0, 1, 2, 3, 5, 8, 13)),  -- 0: a redelivery with no new commits
  from_facts_only bool        NOT NULL DEFAULT false,
  clamped         bool        NOT NULL DEFAULT false,  -- the model's answer was above the facts' upper bound
  diff_source     text        NOT NULL DEFAULT '',     -- pull_request, squash, commits (per repository, joined)
  rationale       text        NOT NULL DEFAULT '',
  factors         jsonb       NOT NULL DEFAULT '{}',   -- the computed facts, the model's factors and its own answer
  reverted_share  numeric     NOT NULL DEFAULT 0 CHECK (reverted_share >= 0 AND reverted_share <= 1),
  error           text        NOT NULL DEFAULT '',
  model           text        NOT NULL DEFAULT '',
  score_run_id    bigint      REFERENCES score_runs (id) ON DELETE SET NULL,
  scored_at       timestamptz NOT NULL DEFAULT now(),
  override_points int         CHECK (override_points IN (0, 1, 2, 3, 5, 8, 13)),
  overridden_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  overridden_at   timestamptz,
  override_reason text        NOT NULL DEFAULT '',
  PRIMARY KEY (ticket_id, delivery, prompt_version),
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
);
CREATE INDEX ticket_scores_version_idx ON ticket_scores (workspace_id, prompt_version);

-- Who gets a delivery's points.
CREATE TABLE ticket_score_authors (
  workspace_id bigint  NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id    bigint  NOT NULL,
  delivery     int     NOT NULL,
  author_key   text    NOT NULL,  -- 'user:<id>', 'agent', or 'unmapped:<login or email>'
  share        numeric NOT NULL CHECK (share > 0 AND share <= 1),
  days         int     NOT NULL DEFAULT 0,  -- distinct days the author committed on
  PRIMARY KEY (ticket_id, delivery, author_key),
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
);

-- Git logins and emails of workspace members. One login or email
-- belongs to one member.
CREATE TABLE member_git_identities (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  user_id      bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  provider     text        NOT NULL DEFAULT '',
  login        text        NOT NULL DEFAULT '',
  email        text        NOT NULL DEFAULT '',
  auto_matched bool        NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (workspace_id, provider, login, email),
  CHECK (login <> '' OR email <> '')
);
CREATE UNIQUE INDEX member_git_identities_login_idx ON member_git_identities (workspace_id, provider, lower(login)) WHERE login <> '';
CREATE UNIQUE INDEX member_git_identities_email_idx ON member_git_identities (workspace_id, lower(email)) WHERE email <> '';

-- Regressions are a relation type: proposed = suggested by analysis,
-- active = confirmed by the owner. They never hold the queue.
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_type_check,
  ADD CONSTRAINT ticket_relations_type_check CHECK (type IN ('depends_on', 'conflicts', 'regression_of'));
ALTER TABLE ticket_relations ADD COLUMN decided_by bigint REFERENCES users (id) ON DELETE SET NULL;

-- Each month's totals per author as they were when it closed; a re-close
-- adds a closing and keeps the earlier ones.
CREATE TABLE period_snapshots (
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  month          date        NOT NULL,  -- the first day, in the workspace's timezone
  closing        int         NOT NULL DEFAULT 1,
  prompt_version text        NOT NULL,
  author_key     text        NOT NULL,
  points         numeric     NOT NULL,
  tickets        int         NOT NULL,
  reverts        int         NOT NULL,
  regressions    int         NOT NULL,
  unscored       int         NOT NULL,
  closed_at      timestamptz NOT NULL DEFAULT now(),
  closed_by      bigint      REFERENCES users (id) ON DELETE SET NULL,  -- null: closed automatically
  PRIMARY KEY (workspace_id, month, closing, author_key)
);
-- A closing with no authors still marks the month closed.
CREATE TABLE period_closings (
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  month          date        NOT NULL,
  closing        int         NOT NULL,
  prompt_version text        NOT NULL,
  unscored       int         NOT NULL DEFAULT 0,  -- the month's deliveries left out, not scored
  closed_at      timestamptz NOT NULL DEFAULT now(),
  closed_by      bigint      REFERENCES users (id) ON DELETE SET NULL,
  PRIMARY KEY (workspace_id, month, closing)
);

-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['prompt_versions', 'score_runs', 'ticket_scores', 'ticket_score_authors', 'member_git_identities',
                             'period_snapshots', 'period_closings'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
            WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END $$;
-- +goose StatementEnd

-- +goose Down
DROP TABLE period_closings;
DROP TABLE period_snapshots;
DELETE FROM ticket_relations WHERE type = 'regression_of';
ALTER TABLE ticket_relations DROP COLUMN decided_by, DROP CONSTRAINT ticket_relations_type_check,
  ADD CONSTRAINT ticket_relations_type_check CHECK (type IN ('depends_on', 'conflicts'));
DROP TABLE member_git_identities;
DROP TABLE ticket_score_authors;
DROP TABLE ticket_scores;
DELETE FROM credit_ledger WHERE reason = 'score';
DROP INDEX credit_ledger_score_run_idx;
ALTER TABLE credit_ledger DROP COLUMN score_run_id, DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'document', 'refund', 'grant'));
DELETE FROM claude_calls WHERE score_run_id IS NOT NULL;
DROP INDEX claude_calls_score_run_idx;
ALTER TABLE claude_calls DROP CONSTRAINT claude_calls_owner_check, DROP COLUMN score_run_id,
  ADD CONSTRAINT claude_calls_owner_check CHECK ((run_id IS NULL) <> (document_run_id IS NULL));
DROP TABLE score_runs;
DROP TABLE prompt_versions;
