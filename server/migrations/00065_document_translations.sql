-- +goose Up
-- A document's PDF is kept per version, format and language: '' is the
-- version as written, a language code its translation. Translated texts
-- themselves live in translations, with the tickets' ones.
ALTER TABLE document_exports ADD COLUMN lang text NOT NULL DEFAULT '';
ALTER TABLE document_exports DROP CONSTRAINT document_exports_pkey,
  ADD PRIMARY KEY (document_id, version, format, lang);

-- +goose Down
DELETE FROM document_exports WHERE lang <> '';
ALTER TABLE document_exports DROP CONSTRAINT document_exports_pkey,
  ADD PRIMARY KEY (document_id, version, format);
ALTER TABLE document_exports DROP COLUMN lang;
