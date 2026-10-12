-- +goose Up
-- Rules agnts-guard enforces while Claude works (enforce: {on, paths,
-- pattern, action, message}), rules delivered as skills Claude loads when
-- they apply, where a rule came from (pack:go, reflect, run), and the
-- confidence a learned lesson has earned. Run tips are a new kind.
ALTER TABLE rules ADD COLUMN enforce jsonb;
ALTER TABLE rules ADD COLUMN delivery text NOT NULL DEFAULT 'prompt' CHECK (delivery IN ('prompt', 'skill'));
ALTER TABLE rules ADD COLUMN skill_description text NOT NULL DEFAULT '';
ALTER TABLE rules ADD COLUMN source text NOT NULL DEFAULT '';
ALTER TABLE rules ADD COLUMN confidence real NOT NULL DEFAULT 0;
ALTER TABLE rules ADD COLUMN evidence int NOT NULL DEFAULT 0;
ALTER TABLE rules ADD COLUMN last_seen timestamptz;
ALTER TABLE rules DROP CONSTRAINT IF EXISTS rules_kind_check;
ALTER TABLE rules ADD CONSTRAINT rules_kind_check CHECK (kind IN ('rule', 'context', 'tip'));
CREATE INDEX rules_source_idx ON rules (source) WHERE source <> '';

-- +goose Down
DROP INDEX rules_source_idx;
DELETE FROM rules WHERE kind = 'tip';
ALTER TABLE rules DROP CONSTRAINT rules_kind_check;
ALTER TABLE rules ADD CONSTRAINT rules_kind_check CHECK (kind IN ('rule', 'context'));
ALTER TABLE rules DROP COLUMN last_seen;
ALTER TABLE rules DROP COLUMN evidence;
ALTER TABLE rules DROP COLUMN confidence;
ALTER TABLE rules DROP COLUMN source;
ALTER TABLE rules DROP COLUMN skill_description;
ALTER TABLE rules DROP COLUMN delivery;
ALTER TABLE rules DROP COLUMN enforce;
