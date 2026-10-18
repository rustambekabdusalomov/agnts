-- +goose Up
-- The ticket's coding runs skip the build, lint and test checks (and the
-- proof and coverage that run tests), going to review on the code alone:
-- for a change whose checks cannot run in the container.
ALTER TABLE tickets ADD COLUMN skip_checks boolean NOT NULL DEFAULT false;

-- +goose Down
ALTER TABLE tickets DROP COLUMN skip_checks;
