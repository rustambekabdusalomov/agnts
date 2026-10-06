-- +goose Up
-- Previews: a side run that starts a repository's app and takes
-- screenshots for the reviewer. preview_cmd empty turns them off for the
-- repository. preview_env holds KEY=value lines for the app, sealed with
-- AGNTS_ENC_KEY; preview_env_names lists its variable names for the UI.
ALTER TABLE repositories
    ADD COLUMN preview_cmd        text    NOT NULL DEFAULT '',
    ADD COLUMN preview_port       integer NOT NULL DEFAULT 0,
    ADD COLUMN preview_ready_path text    NOT NULL DEFAULT '/',
    ADD COLUMN preview_routes     text[]  NOT NULL DEFAULT '{}',
    ADD COLUMN preview_ui_paths   text[]  NOT NULL DEFAULT '{}',
    ADD COLUMN preview_login      text    NOT NULL DEFAULT '',
    ADD COLUMN preview_env        bytea,
    ADD COLUMN preview_env_names  text[]  NOT NULL DEFAULT '{}';

-- preview_state is where the preview of the latest result stands, like
-- review_state. preview_compare has previews capture the default branch
-- too; the reviewer turns it on per ticket. feedback_shots are the
-- screenshots the reviewer pointed at in feedback ([{runId, shotId}]).
ALTER TABLE tickets
    ADD COLUMN preview_state   text    NOT NULL DEFAULT '',
    ADD COLUMN preview_compare boolean NOT NULL DEFAULT false,
    ADD COLUMN feedback_shots  jsonb   NOT NULL DEFAULT '[]';

-- +goose Down
ALTER TABLE tickets DROP COLUMN preview_state, DROP COLUMN preview_compare, DROP COLUMN feedback_shots;
ALTER TABLE repositories DROP COLUMN preview_cmd, DROP COLUMN preview_port, DROP COLUMN preview_ready_path,
    DROP COLUMN preview_routes, DROP COLUMN preview_ui_paths, DROP COLUMN preview_login, DROP COLUMN preview_env,
    DROP COLUMN preview_env_names;
