-- +goose Up
-- The chat gets a Code mode: a person picks repositories and asks for a
-- change, and the work runs as an ordinary ticket the conversation drives.
-- Chat-mode conversations are unchanged.
ALTER TABLE assistant_conversations ADD COLUMN mode text NOT NULL DEFAULT 'chat' CHECK (mode IN ('chat', 'code'));
-- The repositories new tickets work in: {"repo_id": 1} | {"repo_ids": [1, 2]} | {"group_id": 3}.
ALTER TABLE assistant_conversations ADD COLUMN repo_choice jsonb NOT NULL DEFAULT '{}';
ALTER TABLE assistant_conversations ADD COLUMN kind text NOT NULL DEFAULT ''; -- '' lets agnts pick
ALTER TABLE assistant_conversations ADD COLUMN quick boolean NOT NULL DEFAULT false; -- tickets skip checks

-- The tickets a Code conversation drives, oldest first. A ticket is in at
-- most one of a person's conversations at a time: attaching it elsewhere
-- detaches it here. Two people may each follow it in a chat of their own.
CREATE TABLE code_conversation_tickets (
  id              bigserial   PRIMARY KEY,
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  conversation_id bigint      NOT NULL REFERENCES assistant_conversations ON DELETE CASCADE,
  user_id         bigint      NOT NULL REFERENCES users ON DELETE CASCADE, -- the conversation's
  ticket_id       bigint      NOT NULL REFERENCES tickets ON DELETE CASCADE,
  attached_at     timestamptz NOT NULL DEFAULT now(),
  detached_at     timestamptz
);
CREATE UNIQUE INDEX code_conversation_tickets_live ON code_conversation_tickets (ticket_id, user_id) WHERE detached_at IS NULL;
CREATE INDEX code_conversation_tickets_conversation ON code_conversation_tickets (conversation_id, id);

ALTER TABLE code_conversation_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE code_conversation_tickets FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON code_conversation_tickets USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- What a Code message did, and to which ticket. Queued messages wait for
-- the ticket's running stage to end and become sent when they go to it
-- (failed, with the reason in error, when the ticket would not take them).
ALTER TABLE assistant_messages ADD COLUMN ticket_key text NOT NULL DEFAULT '';
ALTER TABLE assistant_messages ADD COLUMN routed text NOT NULL DEFAULT '' CHECK (routed IN
  ('', 'created', 'answered', 'changes', 'continued', 'retried', 'queued', 'sent', 'failed', 'steered'));
ALTER TABLE assistant_messages ADD COLUMN attachments bigint[] NOT NULL DEFAULT '{}';
CREATE INDEX assistant_messages_queued ON assistant_messages (ticket_key, id) WHERE routed = 'queued';

-- A Chat answer's offer to do a code change in Code mode.
ALTER TABLE assistant_messages ADD COLUMN handoff jsonb;

-- +goose Down
ALTER TABLE assistant_messages DROP COLUMN handoff;
DROP INDEX assistant_messages_queued;
ALTER TABLE assistant_messages DROP COLUMN attachments;
ALTER TABLE assistant_messages DROP COLUMN routed;
ALTER TABLE assistant_messages DROP COLUMN ticket_key;
DROP TABLE code_conversation_tickets;
DELETE FROM assistant_conversations WHERE mode = 'code';
ALTER TABLE assistant_conversations DROP COLUMN quick;
ALTER TABLE assistant_conversations DROP COLUMN kind;
ALTER TABLE assistant_conversations DROP COLUMN repo_choice;
ALTER TABLE assistant_conversations DROP COLUMN mode;
