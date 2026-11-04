-- +goose Up
-- Files in the chats: a team chat message or an AI chat (Ask) question can
-- carry uploads. See plans/Chat files plan.md.

-- uploaded_by: who uploaded it, so only they can send or remove their
-- pending upload (viewers may upload now: they chat and ask too).
ALTER TABLE attachments
    ADD COLUMN uploaded_by          bigint REFERENCES users (id) ON DELETE SET NULL,
    ADD COLUMN chat_message_id      bigint REFERENCES chat_messages ON DELETE CASCADE,
    ADD COLUMN assistant_message_id bigint REFERENCES assistant_messages ON DELETE CASCADE;

ALTER TABLE attachments DROP CONSTRAINT attachments_purpose_check;
ALTER TABLE attachments DROP CONSTRAINT attachments_check;
ALTER TABLE attachments ADD CONSTRAINT attachments_purpose_check
    CHECK (purpose IN ('pending', 'ticket', 'answer', 'retry', 'feedback', 'chat', 'assistant'));
-- Exactly the owner its purpose names: none while pending, a chat or an
-- assistant message for those, a ticket otherwise.
ALTER TABLE attachments ADD CONSTRAINT attachments_owner_check CHECK (CASE purpose
    WHEN 'pending'   THEN ticket_id IS NULL AND chat_message_id IS NULL AND assistant_message_id IS NULL
    WHEN 'chat'      THEN ticket_id IS NULL AND chat_message_id IS NOT NULL AND assistant_message_id IS NULL
    WHEN 'assistant' THEN ticket_id IS NULL AND chat_message_id IS NULL AND assistant_message_id IS NOT NULL
    ELSE ticket_id IS NOT NULL AND chat_message_id IS NULL AND assistant_message_id IS NULL END);

CREATE INDEX attachments_chat_idx ON attachments (chat_message_id) WHERE chat_message_id IS NOT NULL;
CREATE INDEX attachments_assistant_idx ON attachments (assistant_message_id) WHERE assistant_message_id IS NOT NULL;

-- file_names: a message's file names, searched with its body, so
-- "@agnts where is the invoice CSV?" finds the message that brought it.
ALTER TABLE chat_messages ADD COLUMN file_names text NOT NULL DEFAULT '';
DROP INDEX chat_messages_search_idx;
ALTER TABLE chat_messages DROP COLUMN search;
ALTER TABLE chat_messages ADD COLUMN search tsvector
    GENERATED ALWAYS AS (to_tsvector('simple', body || ' ' || file_names)) STORED;
CREATE INDEX chat_messages_search_idx ON chat_messages USING gin (search);

-- +goose Down
DROP INDEX chat_messages_search_idx;
ALTER TABLE chat_messages DROP COLUMN search;
ALTER TABLE chat_messages ADD COLUMN search tsvector GENERATED ALWAYS AS (to_tsvector('simple', body)) STORED;
CREATE INDEX chat_messages_search_idx ON chat_messages USING gin (search);
ALTER TABLE chat_messages DROP COLUMN file_names;
DELETE FROM attachments WHERE purpose IN ('chat', 'assistant');
DROP INDEX attachments_assistant_idx;
DROP INDEX attachments_chat_idx;
ALTER TABLE attachments DROP CONSTRAINT attachments_owner_check;
ALTER TABLE attachments DROP CONSTRAINT attachments_purpose_check;
ALTER TABLE attachments ADD CONSTRAINT attachments_purpose_check
    CHECK (purpose IN ('pending', 'ticket', 'answer', 'retry', 'feedback'));
ALTER TABLE attachments ADD CONSTRAINT attachments_check CHECK ((purpose = 'pending') = (ticket_id IS NULL));
ALTER TABLE attachments
    DROP COLUMN assistant_message_id,
    DROP COLUMN chat_message_id,
    DROP COLUMN uploaded_by;
