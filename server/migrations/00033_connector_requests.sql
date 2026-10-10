-- +goose Up
-- Connector requests from the website's "Request a connector" form are kept
-- with the feedback, so the Admins read them in the same place. They come
-- from visitors without an account: no user, only the name and email given.
ALTER TABLE feedback ADD COLUMN kind text NOT NULL DEFAULT 'feedback' CHECK (kind IN ('feedback', 'connector'));

-- +goose Down
ALTER TABLE feedback DROP COLUMN kind;
