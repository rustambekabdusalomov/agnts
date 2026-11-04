-- +goose Up
-- Security testing: scans of a repository with agnts's pinned scanners
-- and the agent, and the findings they keep across scans. See
-- plans/Security plan.md (phase 1a: repository scans).

-- security_scans is one scan of a repository at its default branch.
CREATE TABLE security_scans (
  id           bigserial   PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  trigger      text        NOT NULL CHECK (trigger IN ('manual', 'schedule', 'verify')),
  scope        jsonb       NOT NULL DEFAULT '{}', -- what it was asked to check (verify: the finding ids)
  ran          jsonb       NOT NULL DEFAULT '{}', -- what actually ran: tools, paths, history depth, the agent
  status       text        NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'done', 'failed', 'cancelled')),
  commit_sha   text        NOT NULL DEFAULT '',
  db_versions  jsonb       NOT NULL DEFAULT '{}',
  counts       jsonb       NOT NULL DEFAULT '{}',
  summary      text        NOT NULL DEFAULT '',
  rejected     jsonb       NOT NULL DEFAULT '[]', -- hits the agent judged false positives, for audit
  error        text        NOT NULL DEFAULT '',
  provider     text        NOT NULL DEFAULT '',   -- the agent's module (claude, muse)
  created_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  started_at   timestamptz,
  finished_at  timestamptz
);
CREATE INDEX security_scans_repo ON security_scans (repo_id, created_at DESC);
CREATE INDEX security_scans_pending ON security_scans (status, created_at) WHERE status IN ('pending', 'running');

-- security_findings is one weakness in a repository across scans,
-- identified by a fingerprint agnts computes (never the model's words).
CREATE TABLE security_findings (
  id             bigserial   PRIMARY KEY,
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id        bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  fingerprint    text        NOT NULL,
  severity       text        NOT NULL CHECK (severity IN ('critical', 'high', 'medium', 'low', 'info')),
  category       text        NOT NULL DEFAULT '',
  source         text        NOT NULL CHECK (source IN ('code', 'config', 'dependency', 'secret', 'history', 'agent', 'logs')),
  symbol         text        NOT NULL DEFAULT '',  -- the enclosing function, found by agnts
  data           jsonb       NOT NULL,             -- title, location, cwe, evidence, impact, fix, references; never a secret
  status         text        NOT NULL DEFAULT 'open'
                 CHECK (status IN ('open', 'fixing', 'verifying', 'fixed', 'dismissed', 'reopened')),
  dismiss_reason text        NOT NULL DEFAULT '' CHECK (dismiss_reason IN ('', 'false_positive', 'accepted_risk', 'wont_fix')),
  dismiss_note   text        NOT NULL DEFAULT '',
  dismissed_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  ticket_key     text        NOT NULL DEFAULT '',
  first_seen     timestamptz NOT NULL DEFAULT now(),
  last_seen      timestamptz NOT NULL DEFAULT now(),
  last_checked   timestamptz NOT NULL DEFAULT now(), -- the last scan that actually ran this finding's check
  last_scan_id   bigint      REFERENCES security_scans (id) ON DELETE SET NULL,
  updated_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (repo_id, fingerprint)
);
CREATE INDEX security_findings_active ON security_findings (workspace_id, status, severity);
CREATE INDEX security_findings_ticket ON security_findings (ticket_key) WHERE ticket_key <> '';

ALTER TABLE security_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_scans FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON security_scans USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE security_findings ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_findings FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON security_findings USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Tickets agnts opens to fix findings have their own source (SEC-12).
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git', 'ci', 'logs', 'security'));

-- +goose Down
DELETE FROM tickets WHERE source = 'security';
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git', 'ci', 'logs'));
DROP TABLE security_findings;
DROP TABLE security_scans;
