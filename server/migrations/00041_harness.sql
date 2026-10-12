-- +goose Up
-- The harness: agnts-guard, the hooks inside every run, and the checks
-- around it (Harness plan.md). A repository's own guard and check
-- settings, and what agnts found in its agent files; what the guards
-- recorded during a run; what the harness checks found in a result.
ALTER TABLE repositories ADD COLUMN harness jsonb NOT NULL DEFAULT '{}';
ALTER TABLE runs ADD COLUMN harness jsonb NOT NULL DEFAULT '{}';
ALTER TABLE results ADD COLUMN harness jsonb NOT NULL DEFAULT '{}';

-- +goose Down
ALTER TABLE results DROP COLUMN harness;
ALTER TABLE runs DROP COLUMN harness;
ALTER TABLE repositories DROP COLUMN harness;
