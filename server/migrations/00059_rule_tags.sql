-- +goose Up
-- What kind of lesson a learned rule is (reuse, layer, tests, style,
-- logic, other), so agnts can count which kinds it keeps getting wrong.
ALTER TABLE rules ADD COLUMN tag text NOT NULL DEFAULT '';

-- agnts also learns from what people changed before merging its work,
-- and from reverts of it.
ALTER TABLE reflections DROP CONSTRAINT reflections_source_check;
ALTER TABLE reflections ADD CONSTRAINT reflections_source_check CHECK (source IN ('changes', 'rejected', 'run', 'merged', 'reverted'));

-- +goose Down
DELETE FROM reflections WHERE source IN ('merged', 'reverted');
ALTER TABLE reflections DROP CONSTRAINT reflections_source_check;
ALTER TABLE reflections ADD CONSTRAINT reflections_source_check CHECK (source IN ('changes', 'rejected', 'run'));
ALTER TABLE rules DROP COLUMN tag;
