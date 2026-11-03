-- +goose Up
-- Team chat voice messages: the recording, kept to play back, and its
-- transcript, which becomes the message's text (links, search, @agnts).

-- audio on a message: {contentType, durationMs, transcript: pending, done,
-- none (no words heard) or failed, error}.
ALTER TABLE chat_messages ADD COLUMN audio jsonb;

-- chat_audio holds a voice message's recording as the browser made it
-- (WebM/Opus, MP4/AAC, Ogg), and the WAV Muse hears until it is heard.
CREATE TABLE chat_audio (
  message_id   bigint      PRIMARY KEY REFERENCES chat_messages ON DELETE CASCADE,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  content_type text        NOT NULL,
  data         bytea       NOT NULL,
  wav          bytea,
  created_at   timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE chat_audio ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_audio FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON chat_audio USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

ALTER TABLE chat_jobs DROP CONSTRAINT chat_jobs_kind_check;
ALTER TABLE chat_jobs ADD CONSTRAINT chat_jobs_kind_check
    CHECK (kind IN ('link', 'answer', 'code_answer', 'ticket', 'transcribe'));

-- +goose Down
DELETE FROM chat_jobs WHERE kind = 'transcribe';
ALTER TABLE chat_jobs DROP CONSTRAINT chat_jobs_kind_check;
ALTER TABLE chat_jobs ADD CONSTRAINT chat_jobs_kind_check
    CHECK (kind IN ('link', 'answer', 'code_answer', 'ticket'));
DROP TABLE chat_audio;
ALTER TABLE chat_messages DROP COLUMN audio;
