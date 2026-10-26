-- +goose Up
-- Answers typed but not sent yet, saved as people type so closing the app
-- or the tab loses nothing. The draft is shared by everyone answering the
-- ticket, last write wins. draft_attachments lists pending uploads by id;
-- the pending-upload cleanup keeps those while a draft names them.
-- Answering a question clears its draft.
ALTER TABLE questions
  ADD COLUMN draft_answer      text        NOT NULL DEFAULT '',
  ADD COLUMN draft_note        text        NOT NULL DEFAULT '',
  ADD COLUMN draft_attachments jsonb       NOT NULL DEFAULT '[]',
  ADD COLUMN draft_at          timestamptz;

-- +goose Down
ALTER TABLE questions
  DROP COLUMN draft_at,
  DROP COLUMN draft_attachments,
  DROP COLUMN draft_note,
  DROP COLUMN draft_answer;
