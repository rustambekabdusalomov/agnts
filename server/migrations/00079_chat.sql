-- +goose Up
-- Team chat: workspace channels where members talk and agnts posts cards
-- and answers. See plans/Team chat plan.md.

-- chat_channels are a workspace's rooms; every member sees every channel.
-- agents marks the one channel agnts posts its cards to (by default
-- #general, made with the first list).
CREATE TABLE chat_channels (
  id           bigserial   PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  name         text        NOT NULL CHECK (name ~ '^[a-z0-9][a-z0-9_-]{0,39}$'),
  topic        text        NOT NULL DEFAULT '',
  agents       boolean     NOT NULL DEFAULT false,
  created_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  archived_at  timestamptz,
  UNIQUE (workspace_id, name)
);
CREATE UNIQUE INDEX chat_channels_agents_idx ON chat_channels (workspace_id) WHERE agents;

-- chat_messages: a person's text, or agnts's card or text. client_msg_id
-- (made on the device) makes a resent message the same message.
CREATE TABLE chat_messages (
  id             bigserial   PRIMARY KEY,
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  channel_id     bigint      NOT NULL REFERENCES chat_channels ON DELETE CASCADE,
  reply_to       bigint      REFERENCES chat_messages ON DELETE SET NULL,
  author_user_id bigint      REFERENCES users (id) ON DELETE SET NULL,
  author_agent   text,
  kind           text        NOT NULL CHECK (kind IN ('text', 'agent_card', 'agent_text', 'system')),
  body           text        NOT NULL DEFAULT '' CHECK (length(body) <= 8000),
  card           jsonb,
  ai             jsonb,                               -- {provider, model, ms, cost_usd} on model output
  ticket_key     text,                                -- the ticket a card is about
  client_msg_id  uuid,
  created_at     timestamptz NOT NULL DEFAULT now(),
  edited_at      timestamptz,
  search         tsvector    GENERATED ALWAYS AS (to_tsvector('simple', body)) STORED
);
CREATE UNIQUE INDEX chat_messages_client_idx ON chat_messages (workspace_id, author_user_id, client_msg_id)
  WHERE client_msg_id IS NOT NULL;
CREATE INDEX chat_messages_channel_idx ON chat_messages (channel_id, id);
CREATE INDEX chat_messages_ticket_idx ON chat_messages (ticket_key, id) WHERE ticket_key IS NOT NULL;
CREATE INDEX chat_messages_search_idx ON chat_messages USING gin (search);

-- chat_refs link a message to what it is about. source: explicit (a key
-- or URL in the text), model (picked by the linker from candidates),
-- card (agnts's own card), removed (a member removed a wrong chip).
CREATE TABLE chat_refs (
  message_id   bigint      NOT NULL REFERENCES chat_messages ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ref_type     text        NOT NULL CHECK (ref_type IN ('ticket', 'pr', 'repo', 'finding')),
  ref_id       text        NOT NULL,
  source       text        NOT NULL CHECK (source IN ('explicit', 'model', 'card', 'removed')),
  confidence   real        NOT NULL DEFAULT 1,
  reason       text        NOT NULL DEFAULT '',
  ai           jsonb,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (message_id, ref_type, ref_id)
);
CREATE INDEX chat_refs_ref_idx ON chat_refs (workspace_id, ref_type, ref_id);

-- chat_jobs is the outbox of model work, committed with the message.
CREATE TABLE chat_jobs (
  id           bigserial   PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  message_id   bigint      NOT NULL REFERENCES chat_messages ON DELETE CASCADE,
  kind         text        NOT NULL CHECK (kind IN ('link', 'answer', 'code_answer', 'ticket')),
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL, -- who asked
  state        text        NOT NULL DEFAULT 'queued' CHECK (state IN ('queued', 'running', 'done', 'failed')),
  attempts     integer     NOT NULL DEFAULT 0,
  run_after    timestamptz NOT NULL DEFAULT now(),
  last_error   text        NOT NULL DEFAULT '',
  data         jsonb       NOT NULL DEFAULT '{}',
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX chat_jobs_queue_idx ON chat_jobs (run_after) WHERE state = 'queued';

-- chat_reads is where each person last read each channel.
CREATE TABLE chat_reads (
  user_id      bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  channel_id   bigint NOT NULL REFERENCES chat_channels ON DELETE CASCADE,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  last_read_id bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, channel_id)
);

-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['chat_channels', 'chat_messages', 'chat_refs', 'chat_jobs', 'chat_reads'] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
      WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
  END LOOP;
END $$;
-- +goose StatementEnd

ALTER TABLE events DROP CONSTRAINT events_origin_check;
ALTER TABLE events ADD CONSTRAINT events_origin_check
    CHECK (origin IN ('system', 'web', 'mobile', 'mcp', 'telegram', 'webhook', 'assistant', 'chat'));

-- +goose Down
UPDATE events SET origin = 'web' WHERE origin = 'chat';
ALTER TABLE events DROP CONSTRAINT events_origin_check;
ALTER TABLE events ADD CONSTRAINT events_origin_check
    CHECK (origin IN ('system', 'web', 'mobile', 'mcp', 'telegram', 'webhook', 'assistant'));
DROP TABLE chat_reads;
DROP TABLE chat_jobs;
DROP TABLE chat_refs;
DROP TABLE chat_messages;
DROP TABLE chat_channels;
