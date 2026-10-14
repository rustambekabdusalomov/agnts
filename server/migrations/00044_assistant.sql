-- +goose Up
-- The assistant in the mobile app: a person asks about their workspace in
-- text and agnts answers from a read-only snapshot of it. A conversation
-- belongs to one person; nobody else in the workspace sees it.
CREATE TABLE assistant_conversations (
  id           bigserial   PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  user_id      bigint      NOT NULL REFERENCES users ON DELETE CASCADE,
  title        text        NOT NULL,             -- the first question, cut
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX assistant_conversations_user ON assistant_conversations (workspace_id, user_id, updated_at DESC);
CREATE INDEX assistant_conversations_updated ON assistant_conversations (updated_at);

-- assistant_messages are the questions and the answers, in order.
CREATE TABLE assistant_messages (
  id              bigserial   PRIMARY KEY,
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  conversation_id bigint      NOT NULL REFERENCES assistant_conversations ON DELETE CASCADE,
  role            text        NOT NULL CHECK (role IN ('user', 'assistant')),
  text            text        NOT NULL DEFAULT '',  -- Markdown for the screen
  speech          text        NOT NULL DEFAULT '',  -- 1-3 plain sentences (answers; for voice later)
  links           jsonb       NOT NULL DEFAULT '[]',
  status          text        NOT NULL DEFAULT 'done' CHECK (status IN ('pending', 'answering', 'done', 'failed')),
  error           text        NOT NULL DEFAULT '',
  lang            text        NOT NULL DEFAULT 'en',
  prompt_version  text        NOT NULL DEFAULT '',
  model           text        NOT NULL DEFAULT '',
  tokens          integer     NOT NULL DEFAULT 0,
  cost_usd        double precision NOT NULL DEFAULT 0,
  duration_ms     bigint      NOT NULL DEFAULT 0,
  timing          jsonb       NOT NULL DEFAULT '{}', -- start, snapshot and claude milliseconds
  files           text[]      NOT NULL DEFAULT '{}', -- the snapshot files the answer had
  rating          smallint    NOT NULL DEFAULT 0 CHECK (rating IN (-1, 0, 1)),
  rating_comment  text        NOT NULL DEFAULT '',
  rated_at        timestamptz,
  -- replay is the snapshot the answer was made from, sealed; it goes with
  -- the conversation. Only answers the person shared (with their rating)
  -- are replayed to try new prompts (`agnts eval assistant`).
  replay          bytea,
  shared          boolean     NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX assistant_messages_conversation ON assistant_messages (conversation_id, id);
CREATE INDEX assistant_messages_created ON assistant_messages (workspace_id, created_at) WHERE role = 'assistant';
CREATE INDEX assistant_messages_open ON assistant_messages (status) WHERE status IN ('pending', 'answering');

ALTER TABLE assistant_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE assistant_conversations FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON assistant_conversations USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE assistant_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE assistant_messages FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON assistant_messages USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE assistant_messages;
DROP TABLE assistant_conversations;
