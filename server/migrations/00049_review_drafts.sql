-- +goose Up
-- Draft comments of pull request reviews. agnts's review writes its
-- comments here first; a person accepts, edits or dismisses each one, and
-- only the accepted ones are published on the git host. People can add
-- their own drafts to the same review.
CREATE TABLE review_drafts (
  id             bigserial   PRIMARY KEY,
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id      bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  repo_id        bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  number         integer     NOT NULL,
  kind           text        NOT NULL CHECK (kind IN ('summary', 'finding', 'comment')),
  key            text        NOT NULL,              -- FindingKey, 'summary', or a random key for a person's comment
  severity       text        NOT NULL DEFAULT '',
  category       text        NOT NULL DEFAULT '',
  title          text        NOT NULL DEFAULT '',
  confidence     real        NOT NULL DEFAULT 0,
  pass           text        NOT NULL DEFAULT '',
  path           text        NOT NULL DEFAULT '',
  line           integer     NOT NULL DEFAULT 0,
  head_sha       text        NOT NULL DEFAULT '',   -- the commit it is about
  base_sha       text        NOT NULL DEFAULT '',   -- with start_sha, the rest of that diff (GitLab positions)
  start_sha      text        NOT NULL DEFAULT '',
  body           text        NOT NULL,
  edited         boolean     NOT NULL DEFAULT false, -- a person changed body: re-reviews keep it
  state          text        NOT NULL DEFAULT 'draft'
                 CHECK (state IN ('draft', 'accepted', 'publishing', 'dismissed', 'published', 'outdated')),
  dismiss_reason text        NOT NULL DEFAULT '',
  error          text        NOT NULL DEFAULT '',   -- why the last publish of it failed
  post_id        bigint      REFERENCES pr_posts (id) ON DELETE SET NULL,
  noted          boolean     NOT NULL DEFAULT false, -- went into the reviewer notes
  author_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
  decided_by     bigint      REFERENCES users (id) ON DELETE SET NULL,
  decided_at     timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (ticket_id, kind, key)
);
CREATE INDEX review_drafts_pull_idx ON review_drafts (repo_id, number);
CREATE INDEX review_drafts_workspace_idx ON review_drafts (workspace_id);

ALTER TABLE review_drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_drafts FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON review_drafts USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- A review asked for from the pull request page finishes on approval and
-- never merges.
ALTER TABLE tickets DROP CONSTRAINT tickets_after_approve_check;
ALTER TABLE tickets ADD CONSTRAINT tickets_after_approve_check CHECK (after_approve IN ('pr', 'main', 'none'));

-- What a person did with agnts's draft comments teaches their profile.
ALTER TABLE reviewer_notes DROP CONSTRAINT reviewer_notes_kind_check;
ALTER TABLE reviewer_notes ADD CONSTRAINT reviewer_notes_kind_check
    CHECK (kind IN ('rereview', 'dismissed', 'manual', 'host_comment', 'draft'));

-- +goose Down
DELETE FROM reviewer_notes WHERE kind = 'draft';
ALTER TABLE reviewer_notes DROP CONSTRAINT reviewer_notes_kind_check;
ALTER TABLE reviewer_notes ADD CONSTRAINT reviewer_notes_kind_check
    CHECK (kind IN ('rereview', 'dismissed', 'manual', 'host_comment'));
UPDATE tickets SET after_approve = 'pr' WHERE after_approve = 'none';
ALTER TABLE tickets DROP CONSTRAINT tickets_after_approve_check;
ALTER TABLE tickets ADD CONSTRAINT tickets_after_approve_check CHECK (after_approve IN ('pr', 'main'));
DROP TABLE review_drafts;
