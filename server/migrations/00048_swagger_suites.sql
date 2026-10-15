-- +goose Up
-- Saved Swagger test suites: a test kept to run again on a schedule or
-- after each deploy. Each run is a new Swagger test ticket (suite_id on its
-- swagger_tests row), compared with the suite's last run. auth_sealed is
-- the suite's own copy of the credential (AAD swagger-suite:<id>): closing a
-- run's ticket deletes that ticket's copy, not this one. hook_hash is the
-- sha256 of the deploy hook token, shown once.
CREATE TABLE swagger_suites (
    id            bigserial   PRIMARY KEY,
    workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    name          text        NOT NULL,
    spec_url      text        NOT NULL DEFAULT '',
    spec          jsonb       NOT NULL,
    base_url      text        NOT NULL,
    operations    jsonb       NOT NULL DEFAULT '[]',
    write_enabled boolean     NOT NULL DEFAULT false,
    auth_kind     text        NOT NULL DEFAULT 'none' CHECK (auth_kind IN ('none', 'bearer', 'header', 'query', 'basic')),
    auth_name     text        NOT NULL DEFAULT '',
    auth_sealed   bytea,
    rate_limit    integer     NOT NULL DEFAULT 0,
    max_requests  integer     NOT NULL DEFAULT 0,
    repo_id       bigint      REFERENCES repositories (id) ON DELETE SET NULL,
    notes         text        NOT NULL DEFAULT '',
    schedule      text        NOT NULL DEFAULT 'off' CHECK (schedule IN ('off', 'hourly', 'daily', 'weekly')),
    hour          integer     NOT NULL DEFAULT 6 CHECK (hour BETWEEN 0 AND 23),
    enabled       boolean     NOT NULL DEFAULT true,
    hook_hash     text        NOT NULL DEFAULT '',
    last_run_at   timestamptz,
    next_run_at   timestamptz,
    last_ticket   text        NOT NULL DEFAULT '',
    created_by    bigint      REFERENCES users (id) ON DELETE SET NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX swagger_suites_workspace_idx ON swagger_suites (workspace_id);
CREATE INDEX swagger_suites_due_idx ON swagger_suites (next_run_at) WHERE enabled AND schedule <> 'off';
CREATE UNIQUE INDEX swagger_suites_hook_idx ON swagger_suites (hook_hash) WHERE hook_hash <> '';
ALTER TABLE swagger_suites ENABLE ROW LEVEL SECURITY;
ALTER TABLE swagger_suites FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON swagger_suites USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

ALTER TABLE swagger_tests ADD CONSTRAINT swagger_tests_suite_fk FOREIGN KEY (suite_id) REFERENCES swagger_suites (id) ON DELETE SET NULL;
CREATE INDEX swagger_tests_suite_idx ON swagger_tests (suite_id) WHERE suite_id IS NOT NULL;

-- +goose Down
DROP INDEX swagger_tests_suite_idx;
ALTER TABLE swagger_tests DROP CONSTRAINT swagger_tests_suite_fk;
DROP TABLE swagger_suites;
