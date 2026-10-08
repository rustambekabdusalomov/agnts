-- +goose Up
-- Which version of agnts's prompts a run used, and how many times the
-- coding run sent failing checks back to Claude: the Analytics page compares
-- the quality of the work per prompt version.
ALTER TABLE runs ADD COLUMN prompt_version text NOT NULL DEFAULT '';
ALTER TABLE runs ADD COLUMN fix_attempts integer NOT NULL DEFAULT 0;
CREATE INDEX runs_code_started_idx ON runs (started_at) WHERE stage = 'code';

-- +goose Down
DROP INDEX runs_code_started_idx;
ALTER TABLE runs DROP COLUMN fix_attempts;
ALTER TABLE runs DROP COLUMN prompt_version;
