-- +goose Up
-- Swagger tests: a ticket kind that tests an HTTP API against its
-- Swagger/OpenAPI spec. swagger_tests holds what a ticket tests: the spec
-- (OpenAPI 3 JSON, the version the person picked), the base URL, the
-- ticked operations and how to authenticate. auth_sealed is the credential,
-- sealed with the server key (AAD swagger-test:<ticket id>); it is never
-- returned by the API and is deleted when the ticket closes.
ALTER TABLE tickets DROP CONSTRAINT tickets_kind_check,
    ADD CONSTRAINT tickets_kind_check CHECK (kind IN ('code', 'test', 'plan', 'analysis', 'bug', 'review', 'swaggertest'));

CREATE TABLE swagger_tests (
    ticket_id     bigint      PRIMARY KEY REFERENCES tickets (id) ON DELETE CASCADE,
    workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    spec_url      text        NOT NULL DEFAULT '',
    spec          jsonb       NOT NULL,
    base_url      text        NOT NULL,
    operations    jsonb       NOT NULL DEFAULT '[]',
    write_enabled boolean     NOT NULL DEFAULT false,
    auth_kind     text        NOT NULL DEFAULT 'none' CHECK (auth_kind IN ('none', 'bearer', 'header', 'query', 'basic')),
    auth_name     text        NOT NULL DEFAULT '',
    auth_sealed   bytea,
    secret_v      integer     NOT NULL DEFAULT 1,
    rate_limit    integer     NOT NULL DEFAULT 0,
    max_requests  integer     NOT NULL DEFAULT 0,
    suite_id      bigint,     -- the saved suite it ran for (00048 adds the reference)
    created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX swagger_tests_workspace_idx ON swagger_tests (workspace_id);

-- What each run found: the checked verdicts, the redacted request log
-- (capped at 2 MB) and the plan it sent.
CREATE TABLE swagger_test_results (
    run_id       bigint      PRIMARY KEY REFERENCES runs (id) ON DELETE CASCADE,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    ticket_id    bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    results      jsonb       NOT NULL,
    passed       integer     NOT NULL DEFAULT 0,
    failed       integer     NOT NULL DEFAULT 0,
    skipped      integer     NOT NULL DEFAULT 0,
    blocked      integer     NOT NULL DEFAULT 0,
    log          jsonb       NOT NULL DEFAULT '[]',
    plan         jsonb,
    created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX swagger_test_results_ticket_idx ON swagger_test_results (ticket_id, run_id DESC);
CREATE INDEX swagger_test_results_workspace_idx ON swagger_test_results (workspace_id);

ALTER TABLE swagger_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE swagger_tests FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON swagger_tests USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE swagger_test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE swagger_test_results FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON swagger_test_results USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- A closed ticket (done or rejected) keeps no credential: there is no
-- reason to hold one for a finished test. A rerun after that asks for a
-- new one.
-- +goose StatementBegin
CREATE FUNCTION swagger_tests_forget_auth() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE swagger_tests SET auth_sealed = NULL WHERE ticket_id = NEW.id AND auth_sealed IS NOT NULL;
    RETURN NEW;
END;
$$;
-- +goose StatementEnd
CREATE TRIGGER tickets_swagger_forget_auth AFTER UPDATE OF state ON tickets
    FOR EACH ROW WHEN (NEW.kind = 'swaggertest' AND NEW.state IN ('done', 'rejected') AND OLD.state IS DISTINCT FROM NEW.state)
    EXECUTE FUNCTION swagger_tests_forget_auth();

-- +goose Down
DROP TRIGGER tickets_swagger_forget_auth ON tickets;
DROP FUNCTION swagger_tests_forget_auth();
DROP TABLE swagger_test_results;
DROP TABLE swagger_tests;
DELETE FROM tickets WHERE kind = 'swaggertest';
ALTER TABLE tickets DROP CONSTRAINT tickets_kind_check,
    ADD CONSTRAINT tickets_kind_check CHECK (kind IN ('code', 'test', 'plan', 'analysis', 'bug', 'review'));
