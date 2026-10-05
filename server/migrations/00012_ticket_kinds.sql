-- +goose Up
-- Tickets are no longer only code changes. kind says what the work
-- produces; kind_auto is true while hiro may pick the kind during
-- analysis (nobody chose one). Reports are Markdown in results.report and
-- reach the tracker only when the reviewer ticks post_report on approve.
-- Report tickets need no repository, so tasks without one take their
-- numbers from task_seq.
ALTER TABLE tickets
    ADD COLUMN kind text NOT NULL DEFAULT 'code' CHECK (kind IN ('code', 'test', 'plan', 'analysis', 'bug')),
    ADD COLUMN kind_auto boolean NOT NULL DEFAULT false,
    ADD COLUMN post_report boolean NOT NULL DEFAULT false;
ALTER TABLE results ADD COLUMN report text NOT NULL DEFAULT '';
CREATE SEQUENCE task_seq;

-- +goose Down
DROP SEQUENCE task_seq;
ALTER TABLE results DROP COLUMN report;
ALTER TABLE tickets DROP COLUMN post_report, DROP COLUMN kind_auto, DROP COLUMN kind;
