-- +goose Up
-- Translations of ticket texts (titles, descriptions and what agnts wrote),
-- one row per text and language. Keyed by the text's SHA-256 rather than
-- the ticket, so a text is translated once wherever it appears and a new
-- revision only sends the texts that changed.
CREATE TABLE translations (
    source_hash text        NOT NULL,
    lang        text        NOT NULL,
    text        text        NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (source_hash, lang)
);

-- +goose Down
DROP TABLE translations;
