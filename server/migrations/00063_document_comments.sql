-- +goose Up
-- Comments on selected text of documents and slide decks, by members and
-- by guests of a public link: by the name they typed, as Google vouched
-- for them, or as the agnts account they were signed in with. A guest
-- belongs to one document; its secret token is kept as a hash.
CREATE TABLE document_guests (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id  bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  name         text        NOT NULL,
  email        text        NOT NULL DEFAULT '',  -- set when Google or an account vouched for them
  via          text        NOT NULL DEFAULT 'name' CHECK (via IN ('name', 'google', 'account')),
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,  -- via an account
  token_hash   bytea       NOT NULL UNIQUE,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX document_guests_doc_idx ON document_guests (document_id);

CREATE TABLE document_comments (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id     bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  parent_id       bigint      REFERENCES document_comments (id) ON DELETE CASCADE,  -- a reply
  author_user_id  bigint      REFERENCES users (id) ON DELETE SET NULL,
  author_guest_id bigint      REFERENCES document_guests (id) ON DELETE SET NULL,
  author_name     text        NOT NULL,             -- as it was when written
  body            text        NOT NULL,
  -- What a thread is on: the selected text, a little text around it, and
  -- for a deck the slide (from 0). Replies have none.
  quote           text        NOT NULL DEFAULT '',
  prefix          text        NOT NULL DEFAULT '',
  suffix          text        NOT NULL DEFAULT '',
  slide           integer,
  version         integer     NOT NULL,             -- the document's version when written
  resolved_at     timestamptz,
  resolved_by     text        NOT NULL DEFAULT '',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  CHECK (author_user_id IS NULL OR author_guest_id IS NULL)
);
CREATE INDEX document_comments_doc_idx ON document_comments (document_id, created_at);
CREATE INDEX document_comments_guest_idx ON document_comments (author_guest_id) WHERE author_guest_id IS NOT NULL;

-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['document_guests', 'document_comments'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
            WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END $$;
-- +goose StatementEnd

-- +goose Down
DROP TABLE document_comments;
DROP TABLE document_guests;
