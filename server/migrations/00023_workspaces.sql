-- +goose Up
-- Workspaces: agnts becomes multi-tenant. A workspace is one project with
-- its own members, repositories, tickets, settings and integrations; what
-- was global before is now per workspace. An existing install becomes
-- workspace "default", owned by its oldest user.
--
-- Isolation is enforced in the database: every workspace table carries
-- workspace_id and a row-level security policy that only shows the rows of
-- the workspace the connection acts in (app.workspace_id, set by the
-- server for each request and run), or every row for system work
-- (app.workspace_id = 'all'). The server switches scoped connections to
-- the agnts_tenant role, which cannot bypass the policies even when the
-- login role is a superuser.

-- The workspace a connection acts in, or NULL.
-- +goose StatementBegin
CREATE FUNCTION agnts_ws() RETURNS bigint LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN current_setting('app.workspace_id', true) ~ '^[0-9]+$'
                THEN current_setting('app.workspace_id', true)::bigint END
$$;
-- +goose StatementEnd

-- Whether the connection does system work across workspaces.
-- +goose StatementBegin
CREATE FUNCTION agnts_all() RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT coalesce(current_setting('app.workspace_id', true) = 'all', false)
$$;
-- +goose StatementEnd

-- People: an email to register, verify and invite with; Admin is the
-- platform operator. A TOTP secret is optional now (2FA is turned on later).
ALTER TABLE users
    ADD COLUMN email             text,
    ADD COLUMN email_verified_at timestamptz,
    ADD COLUMN is_admin          boolean NOT NULL DEFAULT false,
    ADD COLUMN display_name      text    NOT NULL DEFAULT '',
    ADD COLUMN last_workspace_id bigint,
    ALTER COLUMN totp_secret_enc DROP NOT NULL;
CREATE UNIQUE INDEX users_email_idx ON users (lower(email)) WHERE email IS NOT NULL;
UPDATE users SET is_admin = true WHERE id = (SELECT min(id) FROM users);

-- One-time links sent by email: verify an address, reset a password.
CREATE TABLE user_tokens (
    token_hash bytea       PRIMARY KEY,
    user_id    bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    purpose    text        NOT NULL CHECK (purpose IN ('verify', 'reset')),
    email      text        NOT NULL DEFAULT '',
    expires_at timestamptz NOT NULL,
    used_at    timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX user_tokens_user_idx ON user_tokens (user_id, purpose);

CREATE TABLE workspaces (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug              text        NOT NULL UNIQUE,
    name              text        NOT NULL,
    -- NULL only for an install migrated before it had a user; the first
    -- user created takes it over.
    owner_id          bigint      REFERENCES users (id),
    plan              text        NOT NULL DEFAULT 'base',
    slots             integer     NOT NULL DEFAULT 1 CHECK (slots BETWEEN 1 AND 50),
    member_limit      integer     NOT NULL DEFAULT 5 CHECK (member_limit >= 0),
    claude_mode       text        NOT NULL DEFAULT 'shared' CHECK (claude_mode IN ('shared', 'member')),
    claude_fallback   boolean     NOT NULL DEFAULT false,
    default_member_id bigint      REFERENCES users (id) ON DELETE SET NULL,
    credits_balance   bigint      NOT NULL DEFAULT 0,
    -- Names the workspace's webhook URLs: /webhooks/<provider>/<hook_id>.
    hook_id           text        NOT NULL UNIQUE DEFAULT replace(gen_random_uuid()::text, '-', ''),
    -- Task numbers of tasks without a repository (was the task_seq sequence).
    task_seq          integer     NOT NULL DEFAULT 0,
    trial_ends_at     timestamptz,
    suspended_at      timestamptz,
    deleted_at        timestamptz,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE users ADD CONSTRAINT users_last_workspace_fkey
    FOREIGN KEY (last_workspace_id) REFERENCES workspaces (id) ON DELETE SET NULL;

CREATE TABLE memberships (
    workspace_id bigint      NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    user_id      bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role         text        NOT NULL DEFAULT 'user' CHECK (role IN ('owner', 'user')),
    created_at   timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (workspace_id, user_id)
);
CREATE UNIQUE INDEX memberships_one_owner_idx ON memberships (workspace_id) WHERE role = 'owner';
CREATE INDEX memberships_user_idx ON memberships (user_id);

CREATE TABLE invites (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint      NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    email        text        NOT NULL DEFAULT '',
    role         text        NOT NULL DEFAULT 'user' CHECK (role IN ('user')),
    token_hash   bytea       NOT NULL UNIQUE,
    invited_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
    expires_at   timestamptz NOT NULL,
    accepted_at  timestamptz,
    accepted_by  bigint      REFERENCES users (id) ON DELETE SET NULL,
    created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX invites_workspace_idx ON invites (workspace_id, created_at);

-- Settings that belong to the server, not a workspace (cursors of
-- background loops).
CREATE TABLE system_settings (
    key        text        PRIMARY KEY,
    value      jsonb       NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO system_settings (key, value, updated_at)
    SELECT key, value, updated_at FROM settings WHERE key LIKE 'cursor:%';
DELETE FROM settings WHERE key LIKE 'cursor:%';

-- The existing install becomes the default workspace.
INSERT INTO workspaces (slug, name, owner_id, slots, member_limit, plan)
SELECT 'default', 'Default', (SELECT min(id) FROM users),
       least(greatest(coalesce((SELECT (value->>'parallel')::int FROM settings WHERE key = 'runtime'), 1), 1), 50),
       0, 'self-hosted'
WHERE EXISTS (SELECT 1 FROM users) OR EXISTS (SELECT 1 FROM tickets) OR EXISTS (SELECT 1 FROM repositories)
   OR EXISTS (SELECT 1 FROM settings) OR EXISTS (SELECT 1 FROM integrations);
UPDATE workspaces SET task_seq = (SELECT last_value FROM task_seq) WHERE slug = 'default'
    AND (SELECT is_called FROM task_seq);
INSERT INTO memberships (workspace_id, user_id, role)
SELECT w.id, u.id, CASE WHEN u.id = w.owner_id THEN 'owner' ELSE 'user' END
FROM workspaces w CROSS JOIN users u WHERE w.slug = 'default';
UPDATE users SET last_workspace_id = (SELECT id FROM workspaces WHERE slug = 'default');
DROP SEQUENCE task_seq;

-- Fills workspace_id of a new row: a child row takes its parent's
-- workspace, anything else the workspace the connection acts in. SECURITY
-- DEFINER so the parent is found whatever the policies show; a child of
-- another workspace's ticket then fails the policy's WITH CHECK.
-- +goose StatementBegin
CREATE FUNCTION agnts_fill_ws() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    parent bigint;
BEGIN
    -- Each branch names only columns its tables have: plpgsql plans a
    -- statement the first time it runs, for the row type at hand.
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

-- workspace_id on every workspace table, filled with the default
-- workspace, then required. events keep NULL for server-wide events.
-- +goose StatementBegin
DO $$
DECLARE
    t   text;
    def bigint := (SELECT id FROM workspaces WHERE slug = 'default');
BEGIN
    FOREACH t IN ARRAY ARRAY['repositories', 'tickets', 'runs', 'results', 'questions', 'events', 'claude_calls',
        'attachments', 'rules', 'lessons', 'ticket_relations', 'ticket_suggestions', 'integrations', 'settings',
        'pending_actions', 'telegram_messages']
    LOOP
        EXECUTE format('ALTER TABLE %I ADD COLUMN workspace_id bigint REFERENCES workspaces (id) ON DELETE CASCADE', t);
        IF def IS NOT NULL THEN
            EXECUTE format('UPDATE %I SET workspace_id = %s', t, def);
        END IF;
        EXECUTE format('ALTER TABLE %I ALTER COLUMN workspace_id SET DEFAULT agnts_ws()', t);
        IF t <> 'events' THEN
            EXECUTE format('ALTER TABLE %I ALTER COLUMN workspace_id SET NOT NULL', t);
        END IF;
        EXECUTE format('CREATE INDEX %I ON %I (workspace_id)', t || '_workspace_idx', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

CREATE TRIGGER runs_fill_ws BEFORE INSERT ON runs FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER results_fill_ws BEFORE INSERT ON results FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER questions_fill_ws BEFORE INSERT ON questions FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER claude_calls_fill_ws BEFORE INSERT ON claude_calls FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER attachments_fill_ws BEFORE INSERT OR UPDATE OF ticket_id ON attachments FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER ticket_suggestions_fill_ws BEFORE INSERT ON ticket_suggestions FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER lessons_fill_ws BEFORE INSERT ON lessons FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER rules_fill_ws BEFORE INSERT ON rules FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();
CREATE TRIGGER tickets_fill_ws BEFORE INSERT ON tickets FOR EACH ROW EXECUTE FUNCTION agnts_fill_ws();

-- Keys, names and tracker projects are unique per workspace, not globally.
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_ticket_key_fkey,
    DROP CONSTRAINT ticket_relations_other_key_fkey,
    DROP CONSTRAINT ticket_relations_ticket_key_other_key_type_key;
ALTER TABLE tickets DROP CONSTRAINT tickets_key_key;
ALTER TABLE tickets ADD CONSTRAINT tickets_workspace_key_key UNIQUE (workspace_id, key);
ALTER TABLE ticket_relations
    ADD CONSTRAINT ticket_relations_ticket_key_fkey FOREIGN KEY (workspace_id, ticket_key)
        REFERENCES tickets (workspace_id, key) ON DELETE CASCADE,
    ADD CONSTRAINT ticket_relations_other_key_fkey FOREIGN KEY (workspace_id, other_key)
        REFERENCES tickets (workspace_id, key) ON DELETE CASCADE,
    ADD CONSTRAINT ticket_relations_pair_key UNIQUE (workspace_id, ticket_key, other_key, type);
DROP INDEX ticket_relations_other_idx;
CREATE INDEX ticket_relations_other_idx ON ticket_relations (workspace_id, other_key);
DROP INDEX tickets_parent_key_idx;
CREATE UNIQUE INDEX tickets_parent_key_idx ON tickets (workspace_id, parent_key) WHERE parent_key IS NOT NULL;
DROP INDEX tickets_follow_up_of_idx;
CREATE INDEX tickets_follow_up_of_idx ON tickets (workspace_id, follow_up_of) WHERE follow_up_of IS NOT NULL;
DROP INDEX events_ticket_key_idx;
CREATE INDEX events_ticket_key_idx ON events (workspace_id, ticket_key, created_at);
DROP INDEX lessons_ticket_idx;
CREATE INDEX lessons_ticket_idx ON lessons (workspace_id, ticket_key);

ALTER TABLE repositories DROP CONSTRAINT repositories_name_key;
ALTER TABLE repositories ADD CONSTRAINT repositories_workspace_name_key UNIQUE (workspace_id, name);
DROP INDEX repositories_jira_project_idx;
CREATE UNIQUE INDEX repositories_jira_project_idx ON repositories (workspace_id, jira_project) WHERE jira_project <> '';
DROP INDEX repositories_plane_project_idx;
CREATE UNIQUE INDEX repositories_plane_project_idx ON repositories (workspace_id, plane_project) WHERE plane_project <> '';

ALTER TABLE integrations DROP CONSTRAINT integrations_pkey;
ALTER TABLE integrations ADD PRIMARY KEY (workspace_id, provider);
ALTER TABLE settings DROP CONSTRAINT settings_pkey;
ALTER TABLE settings ADD PRIMARY KEY (workspace_id, key);

-- Who did what: the person behind an event (NULL for agnts itself).
ALTER TABLE events ADD COLUMN user_id bigint REFERENCES users (id) ON DELETE SET NULL;

-- Whose ticket it is (per-member Claude mode runs on that person's
-- account), who created it, and why it waits for a worker.
ALTER TABLE tickets
    ADD COLUMN member_id   bigint REFERENCES users (id) ON DELETE SET NULL,
    ADD COLUMN created_by  bigint REFERENCES users (id) ON DELETE SET NULL,
    ADD COLUMN queued_at   timestamptz,
    ADD COLUMN wait_reason text NOT NULL DEFAULT '' CHECK (wait_reason IN ('', 'blocked', 'slots', 'server', 'claude'));
CREATE INDEX tickets_queue_idx ON tickets (state, updated_at) WHERE state IN ('new', 'coding', 'pushing');

-- MCP connections act for one person in one workspace.
ALTER TABLE oauth_codes ADD COLUMN workspace_id bigint REFERENCES workspaces (id) ON DELETE CASCADE;
ALTER TABLE oauth_tokens ADD COLUMN workspace_id bigint REFERENCES workspaces (id) ON DELETE CASCADE;
UPDATE oauth_codes SET workspace_id = (SELECT id FROM workspaces WHERE slug = 'default');
UPDATE oauth_tokens SET workspace_id = (SELECT id FROM workspaces WHERE slug = 'default');

-- Row-level security on every workspace table.
-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['repositories', 'tickets', 'runs', 'results', 'questions', 'events', 'claude_calls',
        'attachments', 'rules', 'lessons', 'ticket_relations', 'ticket_suggestions', 'integrations', 'settings',
        'pending_actions', 'telegram_messages']
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws()) '
                       'WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

-- The role scoped connections switch to. Superusers bypass row-level
-- security, so the login role alone would not be held to the policies.
-- Creating a role needs CREATEROLE; without it the server warns at start
-- and relies on the policies holding for a non-superuser login role.
-- +goose StatementBegin
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'agnts_tenant') THEN
        BEGIN
            CREATE ROLE agnts_tenant NOLOGIN NOBYPASSRLS;
        EXCEPTION WHEN insufficient_privilege THEN
            RAISE NOTICE 'agnts_tenant role not created: %', SQLERRM;
            RETURN;
        END;
    END IF;
    EXECUTE format('GRANT agnts_tenant TO %I', current_user);
    GRANT USAGE ON SCHEMA public TO agnts_tenant;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO agnts_tenant;
    GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO agnts_tenant;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO agnts_tenant;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO agnts_tenant;
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'agnts_tenant grants incomplete: %', SQLERRM;
END;
$$;
-- +goose StatementEnd

-- +goose Down
-- Only an install that never had a second workspace can go back.
-- +goose StatementBegin
DO $$
BEGIN
    IF (SELECT count(*) FROM workspaces) > 1 THEN
        RAISE EXCEPTION 'cannot roll back: more than one workspace exists';
    END IF;
END;
$$;
-- +goose StatementEnd
-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['repositories', 'tickets', 'runs', 'results', 'questions', 'events', 'claude_calls',
        'attachments', 'rules', 'lessons', 'ticket_relations', 'ticket_suggestions', 'integrations', 'settings',
        'pending_actions', 'telegram_messages']
    LOOP
        EXECUTE format('DROP POLICY workspace_isolation ON %I', t);
        EXECUTE format('ALTER TABLE %I NO FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I DISABLE ROW LEVEL SECURITY', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd
ALTER TABLE oauth_tokens DROP COLUMN workspace_id;
ALTER TABLE oauth_codes DROP COLUMN workspace_id;
DROP INDEX tickets_queue_idx;
ALTER TABLE tickets DROP COLUMN wait_reason, DROP COLUMN queued_at, DROP COLUMN created_by, DROP COLUMN member_id;
ALTER TABLE events DROP COLUMN user_id;
ALTER TABLE settings DROP CONSTRAINT settings_pkey;
ALTER TABLE settings ADD PRIMARY KEY (key);
ALTER TABLE integrations DROP CONSTRAINT integrations_pkey;
ALTER TABLE integrations ADD PRIMARY KEY (provider);
DROP INDEX repositories_plane_project_idx;
CREATE UNIQUE INDEX repositories_plane_project_idx ON repositories (plane_project) WHERE plane_project <> '';
DROP INDEX repositories_jira_project_idx;
CREATE UNIQUE INDEX repositories_jira_project_idx ON repositories (jira_project) WHERE jira_project <> '';
ALTER TABLE repositories DROP CONSTRAINT repositories_workspace_name_key;
ALTER TABLE repositories ADD CONSTRAINT repositories_name_key UNIQUE (name);
DROP INDEX lessons_ticket_idx;
CREATE INDEX lessons_ticket_idx ON lessons (ticket_key);
DROP INDEX events_ticket_key_idx;
CREATE INDEX events_ticket_key_idx ON events (ticket_key, created_at);
DROP INDEX tickets_follow_up_of_idx;
CREATE INDEX tickets_follow_up_of_idx ON tickets (follow_up_of) WHERE follow_up_of IS NOT NULL;
DROP INDEX tickets_parent_key_idx;
CREATE UNIQUE INDEX tickets_parent_key_idx ON tickets (parent_key) WHERE parent_key IS NOT NULL;
DROP INDEX ticket_relations_other_idx;
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_ticket_key_fkey,
    DROP CONSTRAINT ticket_relations_other_key_fkey, DROP CONSTRAINT ticket_relations_pair_key;
ALTER TABLE tickets DROP CONSTRAINT tickets_workspace_key_key;
ALTER TABLE tickets ADD CONSTRAINT tickets_key_key UNIQUE (key);
ALTER TABLE ticket_relations
    ADD CONSTRAINT ticket_relations_ticket_key_fkey FOREIGN KEY (ticket_key) REFERENCES tickets (key) ON DELETE CASCADE,
    ADD CONSTRAINT ticket_relations_other_key_fkey FOREIGN KEY (other_key) REFERENCES tickets (key) ON DELETE CASCADE,
    ADD CONSTRAINT ticket_relations_ticket_key_other_key_type_key UNIQUE (ticket_key, other_key, type);
CREATE INDEX ticket_relations_other_idx ON ticket_relations (other_key);
DROP TRIGGER tickets_fill_ws ON tickets;
DROP TRIGGER rules_fill_ws ON rules;
DROP TRIGGER lessons_fill_ws ON lessons;
DROP TRIGGER ticket_suggestions_fill_ws ON ticket_suggestions;
DROP TRIGGER attachments_fill_ws ON attachments;
DROP TRIGGER claude_calls_fill_ws ON claude_calls;
DROP TRIGGER questions_fill_ws ON questions;
DROP TRIGGER results_fill_ws ON results;
DROP TRIGGER runs_fill_ws ON runs;
DROP FUNCTION agnts_fill_ws();
-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['repositories', 'tickets', 'runs', 'results', 'questions', 'events', 'claude_calls',
        'attachments', 'rules', 'lessons', 'ticket_relations', 'ticket_suggestions', 'integrations', 'settings',
        'pending_actions', 'telegram_messages']
    LOOP
        EXECUTE format('ALTER TABLE %I DROP COLUMN workspace_id', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd
CREATE SEQUENCE task_seq;
SELECT setval('task_seq', greatest((SELECT max(task_seq) FROM workspaces), 1));
INSERT INTO settings (key, value, updated_at) SELECT key, value, updated_at FROM system_settings;
DROP TABLE system_settings;
ALTER TABLE users DROP CONSTRAINT users_last_workspace_fkey;
DROP TABLE invites;
DROP TABLE memberships;
DROP TABLE workspaces;
DROP TABLE user_tokens;
DROP INDEX users_email_idx;
ALTER TABLE users DROP COLUMN last_workspace_id, DROP COLUMN display_name, DROP COLUMN is_admin,
    DROP COLUMN email_verified_at, DROP COLUMN email;
DROP FUNCTION agnts_all();
DROP FUNCTION agnts_ws();
