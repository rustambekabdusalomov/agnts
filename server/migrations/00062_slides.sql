-- +goose Up
-- Slide decks: a second kind of document, Markdown with --- between
-- slides. A deck made from a page remembers the page and the version its
-- current AI version was read from.
ALTER TABLE documents
  ADD COLUMN kind text NOT NULL DEFAULT 'page' CHECK (kind IN ('page', 'slides')),
  ADD COLUMN derived_from_id bigint REFERENCES documents (id) ON DELETE SET NULL,
  ADD COLUMN derived_from_version integer;
CREATE INDEX documents_derived_idx ON documents (derived_from_id) WHERE derived_from_id IS NOT NULL;

-- +goose Down
DROP INDEX documents_derived_idx;
ALTER TABLE documents
  DROP COLUMN derived_from_version,
  DROP COLUMN derived_from_id,
  DROP COLUMN kind;
