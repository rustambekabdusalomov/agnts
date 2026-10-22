-- +goose Up
-- Documents: Markdown pages of a workspace, written by people or by agnts
-- from tickets, commits, pull requests and repositories. A document is
-- private or public (a link anyone can read), shared with members as view
-- or edit, linked to any number of tickets, and keeps every version.
CREATE TABLE documents (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id     bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  title            text        NOT NULL,
  body             text        NOT NULL DEFAULT '',  -- the current version's, copied for reads
  version          integer     NOT NULL DEFAULT 0,   -- the current version; saves name the one they started from
  type             text        NOT NULL DEFAULT 'private' CHECK (type IN ('private', 'public')),
  public_token     text        UNIQUE,               -- set only while public
  workspace_access text        NOT NULL DEFAULT 'none' CHECK (workspace_access IN ('none', 'view', 'edit')),
  -- No ON DELETE: ownership moves to the workspace owner before a member
  -- leaves or an account goes, so a path that forgets fails here.
  owner_id         bigint      NOT NULL REFERENCES users (id),
  language         text        NOT NULL DEFAULT 'en',
  -- The latest generation's source, for the Regenerate form; NULL for a
  -- document people wrote. Each run keeps its own.
  source           jsonb,
  data_as_of       timestamptz,
  deleted_at       timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  CHECK ((type = 'public') = (public_token IS NOT NULL))
);
CREATE INDEX documents_ws_idx ON documents (workspace_id, updated_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX documents_owner_idx ON documents (owner_id);

-- A generation: what agnts gathered for it and how it ended.
CREATE TABLE document_runs (
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id    bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  requested_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  status         text        NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'writing', 'done', 'failed')),
  source         jsonb       NOT NULL,
  prompt_version text        NOT NULL DEFAULT '',
  error          text        NOT NULL DEFAULT '',
  -- The Claude account it ran on, and whether on credits.
  claude_connection_id bigint REFERENCES claude_connections (id) ON DELETE SET NULL,
  on_credits     boolean     NOT NULL DEFAULT false,
  started_at     timestamptz,
  finished_at    timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX document_runs_queue_idx ON document_runs (created_at) WHERE status = 'queued';
CREATE INDEX document_runs_doc_idx ON document_runs (document_id, created_at DESC);

CREATE TABLE document_versions (
  document_id  bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  version      integer     NOT NULL,
  title        text        NOT NULL,
  body         text        NOT NULL,
  source       text        NOT NULL CHECK (source IN ('human', 'ai', 'restore')),
  note         text        NOT NULL DEFAULT '',
  author_id    bigint      REFERENCES users (id) ON DELETE SET NULL,
  run_id       bigint      REFERENCES document_runs (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, version)
);

CREATE TABLE document_access (
  document_id  bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  user_id      bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  level        text        NOT NULL CHECK (level IN ('view', 'edit')),
  granted_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, user_id)
);
CREATE INDEX document_access_user_idx ON document_access (user_id);

CREATE TABLE document_tickets (
  document_id  bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  ticket_id    bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  linked_by    bigint      REFERENCES users (id) ON DELETE SET NULL,  -- NULL when agnts linked it
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, ticket_id)
);
CREATE INDEX document_tickets_ticket_idx ON document_tickets (ticket_id);

-- A PDF made from one version, kept because a version never changes.
CREATE TABLE document_exports (
  document_id  bigint      NOT NULL,
  version      integer     NOT NULL,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  format       text        NOT NULL CHECK (format IN ('pdf')),
  status       text        NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'failed')),
  data         bytea,
  size         integer     NOT NULL DEFAULT 0,
  error        text        NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, version, format),
  FOREIGN KEY (document_id, version) REFERENCES document_versions (document_id, version) ON DELETE CASCADE
);

-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['documents', 'document_runs', 'document_versions', 'document_access', 'document_tickets', 'document_exports'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
            WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END $$;
-- +goose StatementEnd

-- Spend of document runs: they have no ticket, so a call belongs to a
-- ticket's run or to a document run, never both.
ALTER TABLE claude_calls
  ALTER COLUMN run_id DROP NOT NULL,
  ALTER COLUMN ticket_id DROP NOT NULL,
  ADD COLUMN document_run_id bigint REFERENCES document_runs (id) ON DELETE CASCADE,
  ADD CONSTRAINT claude_calls_owner_check CHECK ((run_id IS NULL) <> (document_run_id IS NULL));
CREATE INDEX claude_calls_document_run_idx ON claude_calls (document_run_id) WHERE document_run_id IS NOT NULL;

ALTER TABLE credit_ledger
  ADD COLUMN document_run_id bigint REFERENCES document_runs (id) ON DELETE SET NULL,
  DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'document', 'refund', 'grant'));
CREATE UNIQUE INDEX credit_ledger_document_run_idx ON credit_ledger (document_run_id) WHERE reason = 'document';

-- +goose Down
DROP INDEX credit_ledger_document_run_idx;
DELETE FROM credit_ledger WHERE reason = 'document';
ALTER TABLE credit_ledger
  DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'refund', 'grant')),
  DROP COLUMN document_run_id;
DELETE FROM claude_calls WHERE document_run_id IS NOT NULL;
ALTER TABLE claude_calls
  DROP CONSTRAINT claude_calls_owner_check,
  DROP COLUMN document_run_id,
  ALTER COLUMN run_id SET NOT NULL,
  ALTER COLUMN ticket_id SET NOT NULL;
DROP TABLE document_exports;
DROP TABLE document_tickets;
DROP TABLE document_access;
DROP TABLE document_versions;
DROP TABLE document_runs;
DROP TABLE documents;
