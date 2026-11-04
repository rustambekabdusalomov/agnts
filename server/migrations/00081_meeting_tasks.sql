-- +goose Up
-- Action items name the member who took them (matched from the name as
-- said), and become draft tickets on their own. See plans/Meeting tasks plan.md.
ALTER TABLE meeting_action_items
  ADD COLUMN who_user_id bigint  REFERENCES users (id) ON DELETE SET NULL, -- the member who takes it, NULL when unknown
  ADD COLUMN who_set_by  bigint  REFERENCES users (id) ON DELETE SET NULL, -- who picked the member by hand, NULL when matched
  ADD COLUMN speaker     text    NOT NULL DEFAULT '', -- who said the line, as the transcript names them
  ADD COLUMN drafted     boolean NOT NULL DEFAULT false; -- its draft ticket was made (deleting the ticket doesn't make another)

-- Recordings uploaded by a host: an ended session with no call, heard
-- from the file's sound only. people are the members the uploader said
-- are in it.
ALTER TABLE meeting_sessions
  ADD COLUMN uploaded boolean  NOT NULL DEFAULT false,
  ADD COLUMN people   bigint[] NOT NULL DEFAULT '{}';
ALTER TABLE meeting_media DROP CONSTRAINT meeting_media_kind_check;
ALTER TABLE meeting_media ADD CONSTRAINT meeting_media_kind_check CHECK (kind IN ('recording', 'audio-mixed', 'audio', 'upload'));

-- +goose Down
DELETE FROM meeting_media WHERE kind = 'upload';
ALTER TABLE meeting_media DROP CONSTRAINT meeting_media_kind_check;
ALTER TABLE meeting_media ADD CONSTRAINT meeting_media_kind_check CHECK (kind IN ('recording', 'audio-mixed', 'audio'));
ALTER TABLE meeting_sessions DROP COLUMN people, DROP COLUMN uploaded;
ALTER TABLE meeting_action_items DROP COLUMN drafted, DROP COLUMN speaker, DROP COLUMN who_set_by, DROP COLUMN who_user_id;
