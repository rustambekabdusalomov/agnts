-- +goose Up
-- Commits on the git host whose branch or message has a ticket's number
-- (or key): people's commits as well as agnts's, from push webhooks and
-- from scans of the repository's history.
CREATE TABLE ticket_commits (
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id     bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  repo_id       bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  sha           text        NOT NULL,
  branch        text        NOT NULL DEFAULT '',  -- the branch it was first seen on
  subject       text        NOT NULL DEFAULT '',  -- the message's first line
  author        text        NOT NULL DEFAULT '',
  author_login  text        NOT NULL DEFAULT '',
  url           text        NOT NULL DEFAULT '',
  committed_at  timestamptz NOT NULL,
  matched_on    text[]      NOT NULL,             -- branch, message or both
  token         text        NOT NULL,             -- what matched, lower case (amanat-2288)
  created_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (ticket_id, repo_id, sha)
);
CREATE INDEX ticket_commits_ticket_idx ON ticket_commits (ticket_id, committed_at DESC);
CREATE INDEX ticket_commits_repo_sha_idx ON ticket_commits (repo_id, sha);
CREATE INDEX ticket_commits_workspace_idx ON ticket_commits (workspace_id);

ALTER TABLE ticket_commits ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_commits FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON ticket_commits USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Tickets are looked up by number and key, ignoring case.
CREATE INDEX tickets_lower_number_idx ON tickets (lower(ticket_number)) WHERE ticket_number <> '';
CREATE INDEX tickets_lower_key_idx ON tickets (lower(key));

-- +goose Down
DROP INDEX tickets_lower_key_idx;
DROP INDEX tickets_lower_number_idx;
DROP TABLE ticket_commits;
