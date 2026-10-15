-- +goose Up
-- Pull request conversations. The git host keeps the comments; agnts
-- stores only what it posted itself, so a later review edits or answers
-- its comments instead of posting them again, and which reviewer threads
-- on its own pull requests it took as feedback.
CREATE TABLE pr_posts (
  id          bigserial   PRIMARY KEY,
  workspace_id bigint     NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id     bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  number      integer     NOT NULL,
  ticket_id   bigint      REFERENCES tickets (id) ON DELETE SET NULL,
  comment_id  text        NOT NULL,              -- the git host's comment, as agnts names it
  thread_id   text        NOT NULL DEFAULT '',
  kind        text        NOT NULL CHECK (kind IN ('summary', 'finding', 'reply', 'comment')),
  finding_key text        NOT NULL DEFAULT '',   -- which finding it carries (file and title)
  head_sha    text        NOT NULL DEFAULT '',   -- the commit it was written about
  resolved    boolean     NOT NULL DEFAULT false,
  posted_by   bigint      REFERENCES users (id) ON DELETE SET NULL, -- who asked for it in agnts
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (repo_id, number, comment_id)
);
CREATE INDEX pr_posts_pull_idx ON pr_posts (repo_id, number);
CREATE INDEX pr_posts_workspace_idx ON pr_posts (workspace_id);

-- Reviewer threads on agnts's pull requests that went back to the ticket.
CREATE TABLE pr_thread_feedback (
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id       bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  repo_id         bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  number          integer     NOT NULL,
  thread_id       text        NOT NULL,
  last_comment_id text        NOT NULL,          -- a newer comment makes the thread new again
  revision        integer     NOT NULL DEFAULT 0, -- the ticket revision that addresses it
  replied         boolean     NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (ticket_id, thread_id)
);
CREATE INDEX pr_thread_feedback_workspace_idx ON pr_thread_feedback (workspace_id);

ALTER TABLE pr_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pr_posts FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON pr_posts USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE pr_thread_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE pr_thread_feedback FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON pr_thread_feedback USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Comments a person writes on others' pull requests on the git host are
-- notes on how they review, like the ones written in agnts.
ALTER TABLE reviewer_notes DROP CONSTRAINT reviewer_notes_kind_check;
ALTER TABLE reviewer_notes ADD CONSTRAINT reviewer_notes_kind_check
    CHECK (kind IN ('rereview', 'dismissed', 'manual', 'host_comment'));

-- +goose Down
DELETE FROM reviewer_notes WHERE kind = 'host_comment';
ALTER TABLE reviewer_notes DROP CONSTRAINT reviewer_notes_kind_check;
ALTER TABLE reviewer_notes ADD CONSTRAINT reviewer_notes_kind_check CHECK (kind IN ('rereview', 'dismissed', 'manual'));
DROP TABLE pr_thread_feedback;
DROP TABLE pr_posts;
