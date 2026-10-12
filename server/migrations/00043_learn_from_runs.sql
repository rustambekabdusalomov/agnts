-- +goose Up
-- Reflections from runs: agnts reads what went wrong in a run (checks that
-- failed, a stuck stretch) and may suggest a tip for the repository.
ALTER TABLE reflections DROP CONSTRAINT reflections_source_check;
ALTER TABLE reflections ADD CONSTRAINT reflections_source_check CHECK (source IN ('changes', 'rejected', 'run'));

-- +goose Down
DELETE FROM reflections WHERE source = 'run';
ALTER TABLE reflections DROP CONSTRAINT reflections_source_check;
ALTER TABLE reflections ADD CONSTRAINT reflections_source_check CHECK (source IN ('changes', 'rejected'));
