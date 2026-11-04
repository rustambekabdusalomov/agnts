-- +goose Up
-- Facts about linked commits that performance reviews need (see
-- plans/Performance review plan.md): who wrote a commit (email), its
-- parents, when it reached the default branch, whether it is a merge or
-- a squash, the pull request it came through and what it reverts. Also
-- the commits agnts pushed, and when each ticket was delivered: tickets
-- have no state history to read that from later.
ALTER TABLE ticket_commits
  ADD COLUMN author_email  text        NOT NULL DEFAULT '',
  ADD COLUMN parents       text[]      NOT NULL DEFAULT '{}',
  ADD COLUMN on_default_at timestamptz,  -- when it was first seen on the default branch
  ADD COLUMN merge_kind    text        NOT NULL DEFAULT '' CHECK (merge_kind IN ('', 'merge', 'squash')),
  ADD COLUMN pr_number     int,          -- the pull request it reached the default branch through
  ADD COLUMN reverts       text        NOT NULL DEFAULT '';  -- the sha it reverts, if any
-- matched_on may now also hold 'pull_request': the commit's pull request
-- has the ticket's number in its branch or title.
CREATE INDEX ticket_commits_default_idx ON ticket_commits (ticket_id, on_default_at) WHERE on_default_at IS NOT NULL;

-- What the git host said about a default-branch commit's pull request,
-- once per commit: the lookup costs a request.
CREATE TABLE commit_pulls (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  sha          text        NOT NULL,
  pr_number    int,                    -- null: it came through no merged pull request
  pr_title     text        NOT NULL DEFAULT '',
  head_branch  text        NOT NULL DEFAULT '',
  squash       bool        NOT NULL DEFAULT false,
  looked_up_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (repo_id, sha)
);

-- The commits of a squashed pull request, read from the host: they earn
-- the shares, and may not be linked to the ticket themselves.
CREATE TABLE pull_request_commits (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  pr_number    int         NOT NULL,
  sha          text        NOT NULL,
  author       text        NOT NULL DEFAULT '',
  author_email text        NOT NULL DEFAULT '',
  author_login text        NOT NULL DEFAULT '',
  authored_at  timestamptz NOT NULL,
  parents      text[]      NOT NULL DEFAULT '{}',
  subject      text        NOT NULL DEFAULT '',
  PRIMARY KEY (repo_id, pr_number, sha)
);

-- Every commit agnts made and pushed, by sha: agnts may commit as a
-- person, so the author cannot tell.
CREATE TABLE agent_commits (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  sha          text        NOT NULL,
  ticket_id    bigint      REFERENCES tickets (id) ON DELETE SET NULL,
  pushed_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (repo_id, sha)
);

-- When a ticket reached done in agnts (null while it is not done), and
-- how its tracker issue was resolved.
ALTER TABLE tickets
  ADD COLUMN done_at            timestamptz,
  ADD COLUMN tracker_done_at    timestamptz,  -- resolved as done; cleared on reopen
  ADD COLUMN tracker_resolution text NOT NULL DEFAULT '';
-- Done tickets from before: the last change is the best guess.
UPDATE tickets SET done_at = updated_at WHERE state = 'done';

-- Each delivery of a ticket: done (in agnts or the tracker) with a linked
-- commit on a default branch. A reopen ends it; the next is delivery 2.
CREATE TABLE ticket_deliveries (
  workspace_id   bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id      bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery       int         NOT NULL,
  delivered_at   timestamptz NOT NULL,  -- when the last condition became true
  undelivered_at timestamptz,           -- set when the ticket was reopened
  PRIMARY KEY (ticket_id, delivery)
);
CREATE INDEX ticket_deliveries_period_idx ON ticket_deliveries (workspace_id, delivered_at);
CREATE UNIQUE INDEX ticket_deliveries_open_idx ON ticket_deliveries (ticket_id) WHERE undelivered_at IS NULL;

-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['commit_pulls', 'pull_request_commits', 'agent_commits', 'ticket_deliveries'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
            WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END $$;
-- +goose StatementEnd

-- done_at follows the state.
-- +goose StatementBegin
CREATE FUNCTION agnts_ticket_done_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.state = 'done' AND (TG_OP = 'INSERT' OR OLD.state IS DISTINCT FROM 'done') THEN
        NEW.done_at := now();
    ELSIF NEW.state <> 'done' THEN
        NEW.done_at := NULL;
    END IF;
    RETURN NEW;
END;
$$;
-- +goose StatementEnd
CREATE TRIGGER tickets_done_at BEFORE INSERT OR UPDATE OF state ON tickets
    FOR EACH ROW EXECUTE FUNCTION agnts_ticket_done_at();

-- agnts_check_delivery records a ticket's next delivery when it became
-- delivered, and ends the open one when it is no longer done. Delivered:
-- done in agnts or resolved as done in the tracker, never rejected, not a
-- review, and at least one linked commit on a default branch. The date is
-- when the last of these became true. SECURITY DEFINER: background loops
-- act with a system scope, and the rows take the ticket's workspace.
-- +goose StatementBegin
CREATE FUNCTION agnts_check_delivery(tid bigint) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    t        tickets%ROWTYPE;
    open_n   int;
    closed   timestamptz;
    on_dflt  timestamptz;
    last_end timestamptz;
    next_n   int;
BEGIN
    SELECT * INTO t FROM tickets WHERE id = tid;
    IF NOT FOUND THEN
        RETURN;
    END IF;
    closed := LEAST(CASE WHEN t.state = 'done' THEN coalesce(t.done_at, t.updated_at) END, t.tracker_done_at);
    IF t.state = 'rejected' OR t.kind IN ('review', 'swaggertest') OR t.source = 'git' THEN
        closed := NULL;
    END IF;
    SELECT delivery INTO open_n FROM ticket_deliveries WHERE ticket_id = tid AND undelivered_at IS NULL;
    IF open_n IS NOT NULL THEN
        IF closed IS NULL THEN
            UPDATE ticket_deliveries SET undelivered_at = now() WHERE ticket_id = tid AND delivery = open_n;
        END IF;
        RETURN;
    END IF;
    IF closed IS NULL THEN
        RETURN;
    END IF;
    SELECT min(on_default_at) INTO on_dflt FROM ticket_commits WHERE ticket_id = tid AND on_default_at IS NOT NULL;
    IF on_dflt IS NULL THEN
        RETURN;
    END IF;
    SELECT max(delivery), max(undelivered_at) INTO next_n, last_end FROM ticket_deliveries WHERE ticket_id = tid;
    INSERT INTO ticket_deliveries (workspace_id, ticket_id, delivery, delivered_at)
    VALUES (t.workspace_id, tid, coalesce(next_n, 0) + 1, GREATEST(closed, on_dflt, last_end));
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE FUNCTION agnts_ticket_delivery() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    PERFORM agnts_check_delivery(NEW.id);
    RETURN NULL;
END;
$$;
-- +goose StatementEnd
CREATE TRIGGER tickets_delivery AFTER INSERT OR UPDATE OF state, tracker_done_at, kind ON tickets
    FOR EACH ROW EXECUTE FUNCTION agnts_ticket_delivery();

-- +goose StatementBegin
CREATE FUNCTION agnts_commit_delivery() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.on_default_at IS NOT NULL THEN
        PERFORM agnts_check_delivery(NEW.ticket_id);
    END IF;
    RETURN NULL;
END;
$$;
-- +goose StatementEnd
CREATE TRIGGER ticket_commits_delivery AFTER INSERT OR UPDATE OF on_default_at ON ticket_commits
    FOR EACH ROW EXECUTE FUNCTION agnts_commit_delivery();

-- +goose Down
DROP TRIGGER ticket_commits_delivery ON ticket_commits;
DROP FUNCTION agnts_commit_delivery();
DROP TRIGGER tickets_delivery ON tickets;
DROP FUNCTION agnts_ticket_delivery();
DROP FUNCTION agnts_check_delivery(bigint);
DROP TRIGGER tickets_done_at ON tickets;
DROP FUNCTION agnts_ticket_done_at();
DROP TABLE ticket_deliveries;
ALTER TABLE tickets DROP COLUMN done_at, DROP COLUMN tracker_done_at, DROP COLUMN tracker_resolution;
DROP TABLE agent_commits;
DROP TABLE pull_request_commits;
DROP TABLE commit_pulls;
DROP INDEX ticket_commits_default_idx;
ALTER TABLE ticket_commits
  DROP COLUMN author_email, DROP COLUMN parents, DROP COLUMN on_default_at,
  DROP COLUMN merge_kind, DROP COLUMN pr_number, DROP COLUMN reverts;
