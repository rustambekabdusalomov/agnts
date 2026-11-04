-- +goose Up
-- Profile pictures. avatar_version counts changes (0: none), so a picture's
-- URL changes with it and browsers may keep each one.
ALTER TABLE users ADD COLUMN avatar_version bigint NOT NULL DEFAULT 0;

-- user_avatars holds the picture as uploaded (the browser makes it a
-- 256 px square first). Users are not a workspace's, so no row security.
CREATE TABLE user_avatars (
  user_id      bigint      PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  content_type text        NOT NULL,
  data         bytea       NOT NULL,
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE user_avatars;
ALTER TABLE users DROP COLUMN avatar_version;
