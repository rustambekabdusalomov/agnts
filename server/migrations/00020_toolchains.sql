-- +goose Up
-- Toolchains: the language runtimes and build tools a repository's runs
-- install through mise ([{tool, version, source, dir}]). Detected from the
-- repository unless toolchains_override says a person set them;
-- toolchain_notes explains what detection could not handle.
-- runner_image replaces the server's runner image for the repository and
-- memory_mb its container memory (0: server default). build_env holds
-- KEY=value lines (registry tokens) for every run, sealed with
-- AGNTS_ENC_KEY; build_env_names lists its variable names for the UI.
ALTER TABLE repositories
    ADD COLUMN toolchains             jsonb       NOT NULL DEFAULT '[]',
    ADD COLUMN toolchains_override    boolean     NOT NULL DEFAULT false,
    ADD COLUMN toolchains_detected_at timestamptz,
    ADD COLUMN toolchain_notes        text[]      NOT NULL DEFAULT '{}',
    ADD COLUMN runner_image           text        NOT NULL DEFAULT '',
    ADD COLUMN memory_mb              integer     NOT NULL DEFAULT 0,
    ADD COLUMN build_env              bytea,
    ADD COLUMN build_env_names        text[]      NOT NULL DEFAULT '{}';

-- +goose Down
ALTER TABLE repositories DROP COLUMN toolchains, DROP COLUMN toolchains_override, DROP COLUMN toolchains_detected_at,
    DROP COLUMN toolchain_notes, DROP COLUMN runner_image, DROP COLUMN memory_mb, DROP COLUMN build_env,
    DROP COLUMN build_env_names;
