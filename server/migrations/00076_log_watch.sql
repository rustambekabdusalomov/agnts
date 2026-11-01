-- +goose Up
-- Log watcher: agnts reads the logging systems people already run (Loki,
-- Elasticsearch, OpenSearch, Graylog) or takes logs pushed by their
-- shippers, and groups what it finds into findings by fingerprint.

-- log_sources is one logging system agnts reads, or one push token.
CREATE TABLE log_sources (
  id              bigserial   PRIMARY KEY,
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  name            text        NOT NULL,
  kind            text        NOT NULL CHECK (kind IN ('loki', 'elasticsearch', 'opensearch', 'graylog', 'push')),
  environment     text        NOT NULL DEFAULT 'production',
  address         text        NOT NULL DEFAULT '',
  auth            bytea,                             -- domain.LogAuth as JSON, sealed with AGNTS_ENC_KEY
  ca_pem          text        NOT NULL DEFAULT '',
  scope           jsonb       NOT NULL DEFAULT '{}', -- base selector, index pattern, streams
  fields          jsonb       NOT NULL DEFAULT '{}', -- message, timestamp, level, service, revision
  push_token_hash bytea       UNIQUE,                -- push only: sha256 of the token
  poll_seconds    integer     NOT NULL DEFAULT 15 CHECK (poll_seconds BETWEEN 5 AND 300),
  enabled         boolean     NOT NULL DEFAULT true,
  cursor          jsonb       NOT NULL DEFAULT '{}',
  status          text        NOT NULL DEFAULT 'new',
  last_error      text        NOT NULL DEFAULT '',
  last_read_at    timestamptz,
  gap_from        timestamptz,                       -- a range not read after a long outage
  gap_to          timestamptz,
  dropped         bigint      NOT NULL DEFAULT 0,    -- entries over the caps
  network_id      bigint,                            -- the private network last used, for display
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, name)
);

-- log_services are the services of a source agnts watches.
CREATE TABLE log_services (
  id           bigserial PRIMARY KEY,
  workspace_id bigint    NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  source_id    bigint    NOT NULL REFERENCES log_sources ON DELETE CASCADE,
  name         text      NOT NULL,
  selector     text      NOT NULL,                   -- LogQL matcher, ES term, Graylog stream/query
  group_id     bigint    REFERENCES repository_groups ON DELETE SET NULL,
  enabled      boolean   NOT NULL DEFAULT true,
  UNIQUE (source_id, name)
);

-- log_service_repos are the repositories a service runs on. None: its
-- findings are reported and never become tickets.
CREATE TABLE log_service_repos (
  service_id   bigint  NOT NULL REFERENCES log_services ON DELETE CASCADE,
  workspace_id bigint  NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint  NOT NULL REFERENCES repositories ON DELETE CASCADE,
  position     integer NOT NULL DEFAULT 0,
  PRIMARY KEY (service_id, repo_id)
);

-- log_keys holds each workspace's key for hashing secrets found in logs
-- (HMAC), sealed. A plain hash of a short password could be reversed.
CREATE TABLE log_keys (
  workspace_id bigint PRIMARY KEY DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  key          bytea  NOT NULL
);

-- log_findings groups entries with the same fingerprint for one set of
-- repositories (or one service without any), across sources.
CREATE TABLE log_findings (
  id            bigserial   PRIMARY KEY,
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  scope         text        NOT NULL,              -- repos:<sorted ids> or svc:<source id>/<service>
  service_id    bigint      REFERENCES log_services ON DELETE SET NULL,
  service       text        NOT NULL,
  repo_ids      bigint[]    NOT NULL DEFAULT '{}',
  category      text        NOT NULL,              -- error, security
  detector      text        NOT NULL,
  class         text        NOT NULL DEFAULT '',
  severity      text        NOT NULL DEFAULT 'medium',
  fingerprint   text        NOT NULL,
  title         text        NOT NULL,
  remediation   text        NOT NULL DEFAULT '',
  status        text        NOT NULL DEFAULT 'open',
  reason        text        NOT NULL DEFAULT '',
  count         bigint      NOT NULL DEFAULT 0,
  hour_count    integer     NOT NULL DEFAULT 0,
  hour_start    timestamptz NOT NULL DEFAULT now(),
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at  timestamptz NOT NULL DEFAULT now(),
  revision      text        NOT NULL DEFAULT '',
  route         text        NOT NULL DEFAULT '',
  bursts        jsonb       NOT NULL DEFAULT '[]', -- attack findings: burst times in the last 7 days
  secret_mask   text        NOT NULL DEFAULT '',   -- never the value
  secret_hmac   text        NOT NULL DEFAULT '',
  sample        bytea,                             -- redacted excerpt, sealed with AGNTS_ENC_KEY
  sample_at     timestamptz,
  occurrences   jsonb       NOT NULL DEFAULT '[]', -- the last 20 batches
  reported_at   timestamptz,
  ticket_key    text        NOT NULL DEFAULT '',
  fixed_sha     text        NOT NULL DEFAULT '',
  fixed_at      timestamptz,
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, scope, fingerprint)
);
CREATE INDEX log_findings_active ON log_findings (workspace_id, status, last_seen_at DESC);
CREATE INDEX log_findings_ticket ON log_findings (ticket_key) WHERE ticket_key <> '';

ALTER TABLE log_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_sources FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON log_sources USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE log_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_services FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON log_services USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE log_service_repos ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_service_repos FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON log_service_repos USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE log_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_keys FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON log_keys USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE log_findings ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_findings FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON log_findings USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Tickets agnts opens for what it finds in logs have their own source.
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git', 'ci', 'logs'));

-- +goose Down
DELETE FROM tickets WHERE source = 'logs';
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git', 'ci'));
DROP TABLE log_findings;
DROP TABLE log_keys;
DROP TABLE log_service_repos;
DROP TABLE log_services;
DROP TABLE log_sources;
