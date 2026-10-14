-- +goose Up
-- Repository groups and tickets that span several repositories.
--
-- A group is a named set of repositories in a workspace (many to many). A
-- ticket created from a group copies its members into ticket_repos: the
-- group is a shortcut, never a live link, and group_id on the ticket is
-- kept for display and filtering only.
CREATE TABLE repository_groups (
    id           bigserial   PRIMARY KEY,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    name         text        NOT NULL,
    description  text        NOT NULL DEFAULT '',
    -- instructions say how the repositories fit together (contracts, the
    -- order of changes); they go into every prompt of the group's tickets.
    instructions text        NOT NULL DEFAULT '',
    task_prefix  text        NOT NULL DEFAULT '',
    task_seq     integer     NOT NULL DEFAULT 0,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX repository_groups_workspace_idx ON repository_groups (workspace_id);
CREATE UNIQUE INDEX repository_groups_name_idx ON repository_groups (workspace_id, lower(name));
CREATE UNIQUE INDEX repository_groups_prefix_idx ON repository_groups (workspace_id, task_prefix) WHERE task_prefix <> '';

CREATE TABLE repository_group_members (
    workspace_id bigint  NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    group_id     bigint  NOT NULL REFERENCES repository_groups (id) ON DELETE CASCADE,
    repo_id      bigint  NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
    role         text    NOT NULL DEFAULT '',   -- "backend", "web": a label for people and prompts
    position     integer NOT NULL DEFAULT 0,
    PRIMARY KEY (group_id, repo_id)
);
CREATE INDEX repository_group_members_repo_idx ON repository_group_members (repo_id);
CREATE INDEX repository_group_members_workspace_idx ON repository_group_members (workspace_id);

-- ticket_repos is the git side of a ticket, one row per repository it
-- works in. The ticket stays the unit of work (its state); the repository
-- is the unit of git (branch, commit, pull request, CI, merge). Position 0
-- is the primary repository, the one tickets.repo_id names. folder is
-- where the repository is in the run: '' for /workspace itself (a ticket
-- with one repository), else /workspace/<folder>.
CREATE TABLE ticket_repos (
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    ticket_id    bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    repo_id      bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
    position     integer     NOT NULL DEFAULT 0,
    folder       text        NOT NULL DEFAULT '',
    role         text        NOT NULL DEFAULT '',
    branch       text        NOT NULL DEFAULT '',
    head_sha     text        NOT NULL DEFAULT '',
    base_sha     text        NOT NULL DEFAULT '',
    pr_number    integer,
    pr_url       text        NOT NULL DEFAULT '',
    assignees    text[]      NOT NULL DEFAULT '{}',
    ci_fixes     integer     NOT NULL DEFAULT 0,
    merged_at    timestamptz,
    closed_at    timestamptz,
    -- pending: not committed yet; unchanged: the work did not change it
    -- (no pull request); pushed: its branch and pull request are up;
    -- merged; dropped: its pull request was closed without a merge.
    state        text        NOT NULL DEFAULT 'pending' CHECK (state IN ('pending', 'unchanged', 'pushed', 'merged', 'dropped')),
    push_error   text        NOT NULL DEFAULT '',
    files        integer     NOT NULL DEFAULT 0,  -- files the last commit changed against the default branch
    PRIMARY KEY (ticket_id, repo_id)
);
CREATE INDEX ticket_repos_repo_idx ON ticket_repos (repo_id);
CREATE INDEX ticket_repos_branch_idx ON ticket_repos (repo_id, branch) WHERE branch <> '';
CREATE INDEX ticket_repos_pr_idx ON ticket_repos (repo_id, pr_number) WHERE pr_number IS NOT NULL;
CREATE INDEX ticket_repos_pr_url_idx ON ticket_repos (pr_url) WHERE pr_url <> '';
CREATE INDEX ticket_repos_workspace_idx ON ticket_repos (workspace_id);

ALTER TABLE tickets ADD COLUMN group_id bigint REFERENCES repository_groups (id) ON DELETE SET NULL;
CREATE INDEX tickets_group_idx ON tickets (group_id) WHERE group_id IS NOT NULL;

-- Follow-up suggestions may name the repositories they are about.
ALTER TABLE ticket_suggestions ADD COLUMN repo_ids bigint[] NOT NULL DEFAULT '{}';
-- Reflections of a ticket in several repositories.
ALTER TABLE reflections ADD COLUMN repo_ids bigint[] NOT NULL DEFAULT '{}';

-- Every ticket with a repository gets its row, from its own columns.
INSERT INTO ticket_repos (workspace_id, ticket_id, repo_id, position, folder, branch, head_sha, base_sha, pr_number, pr_url,
                          assignees, ci_fixes, merged_at, closed_at, state)
SELECT workspace_id, id, repo_id, 0, '', branch, head_sha, base_sha, pr_number, pr_url, assignees, ci_fixes, merged_at, closed_at,
       CASE WHEN merged_at IS NOT NULL THEN 'merged' WHEN closed_at IS NOT NULL THEN 'dropped'
            WHEN pr_number IS NOT NULL OR (state = 'done' AND head_sha <> '') THEN 'pushed' ELSE 'pending' END
FROM tickets WHERE repo_id IS NOT NULL;

-- agnts_ticket_repos is a ticket's repositories as JSON, for loading them
-- with the ticket in one query. It runs as the caller: the policies apply.
-- +goose StatementBegin
CREATE FUNCTION agnts_ticket_repos(tid bigint) RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT coalesce(jsonb_agg(jsonb_build_object(
        'repoId', tr.repo_id, 'repoName', coalesce(r.name, ''), 'position', tr.position, 'folder', tr.folder, 'role', tr.role,
        'branch', tr.branch, 'headSha', tr.head_sha, 'baseSha', tr.base_sha, 'prNumber', tr.pr_number, 'prUrl', tr.pr_url,
        'assignees', tr.assignees, 'ciFixes', tr.ci_fixes, 'mergedAt', tr.merged_at, 'closedAt', tr.closed_at,
        'state', tr.state, 'pushError', tr.push_error, 'files', tr.files, 'archived', r.archived_at IS NOT NULL
    ) ORDER BY tr.position, tr.repo_id), '[]'::jsonb)
    FROM ticket_repos tr LEFT JOIN repositories r ON r.id = tr.repo_id
    WHERE tr.ticket_id = tid
$$;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE FUNCTION agnts_group_name(gid bigint) RETURNS text LANGUAGE sql STABLE AS $$
    SELECT coalesce((SELECT name FROM repository_groups WHERE id = gid), '')
$$;
-- +goose StatementEnd

-- A child row takes its parent's workspace: members their group's, ticket
-- repositories their ticket's.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION agnts_fill_ws() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    parent bigint;
BEGIN
    -- Each branch names only columns its tables have: plpgsql plans a
    -- statement the first time it runs, for the row type at hand.
    IF TG_TABLE_NAME IN ('runs', 'questions', 'claude_calls', 'ticket_suggestions', 'attachments', 'ticket_repos') THEN
        IF NEW.ticket_id IS NOT NULL THEN
            SELECT workspace_id INTO parent FROM tickets WHERE id = NEW.ticket_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'results' THEN
        SELECT workspace_id INTO parent FROM runs WHERE id = NEW.run_id;
    ELSIF TG_TABLE_NAME = 'repository_group_members' THEN
        SELECT workspace_id INTO parent FROM repository_groups WHERE id = NEW.group_id;
    ELSIF TG_TABLE_NAME IN ('lessons', 'rules', 'tickets') THEN
        IF NEW.repo_id IS NOT NULL THEN
            SELECT workspace_id INTO parent FROM repositories WHERE id = NEW.repo_id;
        END IF;
    END IF;
    IF parent IS NOT NULL THEN
        NEW.workspace_id := parent;
    ELSIF NEW.workspace_id IS NULL THEN
        NEW.workspace_id := agnts_ws();
    END IF;
    -- A foreign key ignores the policies: a group or ticket must not name
    -- another workspace's repository.
    IF TG_TABLE_NAME IN ('repository_group_members', 'ticket_repos') THEN
        IF NOT EXISTS (SELECT 1 FROM repositories WHERE id = NEW.repo_id AND workspace_id = NEW.workspace_id) THEN
            RAISE EXCEPTION 'repository % is not in workspace %', NEW.repo_id, NEW.workspace_id USING ERRCODE = '23503';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;
-- +goose StatementEnd

CREATE TRIGGER repository_group_members_fill_ws BEFORE INSERT OR UPDATE OF repo_id ON repository_group_members FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER ticket_repos_fill_ws BEFORE INSERT OR UPDATE OF repo_id ON ticket_repos FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();

ALTER TABLE repository_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE repository_groups FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON repository_groups USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE repository_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE repository_group_members FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON repository_group_members USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());
ALTER TABLE ticket_repos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_repos FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON ticket_repos USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TRIGGER ticket_repos_fill_ws ON ticket_repos;
DROP TRIGGER repository_group_members_fill_ws ON repository_group_members;
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION agnts_fill_ws() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    parent bigint;
BEGIN
    IF TG_TABLE_NAME IN ('runs', 'questions', 'claude_calls', 'ticket_suggestions', 'attachments') THEN
        IF NEW.ticket_id IS NOT NULL THEN
            SELECT workspace_id INTO parent FROM tickets WHERE id = NEW.ticket_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'results' THEN
        SELECT workspace_id INTO parent FROM runs WHERE id = NEW.run_id;
    ELSIF TG_TABLE_NAME IN ('lessons', 'rules', 'tickets') THEN
        IF NEW.repo_id IS NOT NULL THEN
            SELECT workspace_id INTO parent FROM repositories WHERE id = NEW.repo_id;
        END IF;
    END IF;
    IF parent IS NOT NULL THEN
        NEW.workspace_id := parent;
    ELSIF NEW.workspace_id IS NULL THEN
        NEW.workspace_id := agnts_ws();
    END IF;
    RETURN NEW;
END;
$$;
-- +goose StatementEnd
DROP FUNCTION agnts_group_name(bigint);
DROP FUNCTION agnts_ticket_repos(bigint);
ALTER TABLE reflections DROP COLUMN repo_ids;
ALTER TABLE ticket_suggestions DROP COLUMN repo_ids;
DROP INDEX tickets_group_idx;
ALTER TABLE tickets DROP COLUMN group_id;
DROP TABLE ticket_repos;
DROP TABLE repository_group_members;
DROP TABLE repository_groups;
