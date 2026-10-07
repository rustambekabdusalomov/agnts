-- +goose Up
-- Multiple-choice questions: the analysis says when several options may
-- apply together. The answer then lists the chosen options, one per line.
ALTER TABLE questions ADD COLUMN multiple boolean NOT NULL DEFAULT false;

-- Files people attach: to a task's description, to an answer, to a
-- retry note, or to review feedback (requested changes). An upload is pending until the action that uses it links it;
-- pending uploads nobody used are deleted after a day. The bytes live here,
-- so the nightly database backup keeps them.
CREATE TABLE attachments (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id    bigint      REFERENCES tickets (id) ON DELETE CASCADE,
    question_id  bigint      REFERENCES questions (id) ON DELETE CASCADE,
    purpose      text        NOT NULL DEFAULT 'pending' CHECK (purpose IN ('pending', 'ticket', 'answer', 'retry', 'feedback')),
    name         text        NOT NULL,
    content_type text        NOT NULL,
    size         bigint      NOT NULL,
    data         bytea       NOT NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    CHECK ((purpose = 'pending') = (ticket_id IS NULL)),
    CHECK ((purpose = 'answer') = (question_id IS NOT NULL))
);
CREATE INDEX attachments_ticket_idx ON attachments (ticket_id) WHERE ticket_id IS NOT NULL;
CREATE INDEX attachments_pending_idx ON attachments (created_at) WHERE purpose = 'pending';

-- Files a retry note or review feedback brought, for the next coding run
-- (like feedback_shots).
ALTER TABLE tickets ADD COLUMN feedback_files jsonb NOT NULL DEFAULT '[]';

-- +goose Down
ALTER TABLE tickets DROP COLUMN feedback_files;
DROP TABLE attachments;
ALTER TABLE questions DROP COLUMN multiple;
