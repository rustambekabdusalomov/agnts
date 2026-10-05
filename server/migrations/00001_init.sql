-- +goose Up

-- Auth. Single user in v1; the table exists so Usta can add more without
-- changing how sessions or devices reference their owner.
CREATE TABLE users (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username        text        NOT NULL UNIQUE,
    password_hash   text        NOT NULL,
    totp_secret_enc bytea       NOT NULL,
    -- Last accepted TOTP time step; a code is accepted only for a later step,
    -- so a sniffed code cannot be replayed.
    totp_last_step  bigint      NOT NULL DEFAULT 0,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sessions (
    token_hash bytea       PRIMARY KEY,
    user_id    bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    client     text        NOT NULL CHECK (client IN ('web', 'mobile')),
    user_agent text        NOT NULL DEFAULT '',
    ip         text        NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL
);
CREATE INDEX sessions_expires_at_idx ON sessions (expires_at);

-- Repositories hiro works on: Jira-linked work repos and side projects.
CREATE TABLE repositories (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           text        NOT NULL UNIQUE,
    kind           text        NOT NULL CHECK (kind IN ('jira', 'side')),
    provider       text        NOT NULL CHECK (provider IN ('github', 'gitlab')),
    clone_url      text        NOT NULL,
    default_branch text        NOT NULL DEFAULT 'main',
    stack          text        NOT NULL DEFAULT '',
    build_cmd      text        NOT NULL DEFAULT '',
    lint_cmd       text        NOT NULL DEFAULT '',
    test_cmd       text        NOT NULL DEFAULT '',
    branch_prefix  text        NOT NULL DEFAULT 'hiro/',
    claude_md      text        NOT NULL DEFAULT '',
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE tickets (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    key           text        NOT NULL UNIQUE,
    source        text        NOT NULL CHECK (source IN ('jira', 'local')),
    repo_id       bigint      REFERENCES repositories (id),
    title         text        NOT NULL,
    description   text        NOT NULL DEFAULT '',
    priority      text        NOT NULL DEFAULT 'medium',
    state         text        NOT NULL DEFAULT 'new' CHECK (state IN (
                      'new', 'analyzing', 'waiting_for_answers', 'coding', 'testing',
                      'waiting_for_review', 'pushing', 'done',
                      'rejected', 'failed', 'rate_limited')),
    revision      integer     NOT NULL DEFAULT 0,
    turns         integer     NOT NULL DEFAULT 0,
    models        jsonb       NOT NULL DEFAULT '{}',
    after_approve text        NOT NULL DEFAULT 'pr' CHECK (after_approve IN ('pr', 'main')),
    pr_number     integer,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX tickets_state_idx ON tickets (state);

CREATE TABLE questions (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id   bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    position    integer     NOT NULL,
    text        text        NOT NULL,
    options     jsonb       NOT NULL DEFAULT '[]',
    answer      text,
    note        text        NOT NULL DEFAULT '',
    answered_at timestamptz,
    created_at  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (ticket_id, position)
);

CREATE TABLE runs (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id    bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    stage        text        NOT NULL,
    model        text        NOT NULL,
    session_id   text        NOT NULL DEFAULT '',
    container_id text        NOT NULL DEFAULT '',
    started_at   timestamptz NOT NULL DEFAULT now(),
    finished_at  timestamptz,
    turns        integer     NOT NULL DEFAULT 0,
    exit_reason  text        NOT NULL DEFAULT ''
);
CREATE INDEX runs_ticket_id_idx ON runs (ticket_id, started_at);

CREATE TABLE results (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_id     bigint      NOT NULL UNIQUE REFERENCES runs (id) ON DELETE CASCADE,
    summary    jsonb       NOT NULL DEFAULT '{}',
    tests      jsonb       NOT NULL DEFAULT '{}',
    lint       text        NOT NULL DEFAULT '',
    files      jsonb       NOT NULL DEFAULT '[]',
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Append-only event log: history, Logs page, analytics, SSE and audit.
-- ticket_key has no foreign key so history outlives deleted tasks.
CREATE TABLE events (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_key  text,
    run_id      bigint      REFERENCES runs (id) ON DELETE SET NULL,
    step        text        NOT NULL DEFAULT '',
    type        text        NOT NULL,
    level       text        NOT NULL DEFAULT 'info' CHECK (level IN ('debug', 'info', 'warn', 'error')),
    origin      text        NOT NULL DEFAULT 'system' CHECK (origin IN ('system', 'web', 'mobile', 'mcp', 'telegram', 'webhook')),
    message     text        NOT NULL DEFAULT '',
    data        jsonb       NOT NULL DEFAULT '{}',
    duration_ms integer,
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX events_ticket_key_idx ON events (ticket_key, created_at);
CREATE INDEX events_created_at_idx ON events (created_at);
CREATE INDEX events_type_idx ON events (type, created_at);

CREATE TABLE integrations (
    provider   text        PRIMARY KEY CHECK (provider IN ('jira', 'github', 'gitlab', 'telegram', 'claude')),
    connected  boolean     NOT NULL DEFAULT false,
    token_enc  bytea,
    settings   jsonb       NOT NULL DEFAULT '{}',
    checked_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE usage_snapshots (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    five_hour  real,
    seven_day  real,
    resets_at  timestamptz,
    status     text        NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX usage_snapshots_created_at_idx ON usage_snapshots (created_at);

CREATE TABLE settings (
    key        text        PRIMARY KEY,
    value      jsonb       NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE devices (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    platform    text        NOT NULL CHECK (platform IN ('ios', 'android')),
    fcm_token   text        NOT NULL UNIQUE,
    app_version text        NOT NULL DEFAULT '',
    last_seen   timestamptz NOT NULL DEFAULT now(),
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- Maps Telegram messages hiro sent to the ticket they are about,
-- so a reply or button press lands on the right ticket.
CREATE TABLE telegram_messages (
    chat_id    bigint      NOT NULL,
    message_id bigint      NOT NULL,
    ticket_key text        NOT NULL,
    kind       text        NOT NULL CHECK (kind IN ('questions', 'review', 'confirm', 'notice')),
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (chat_id, message_id)
);

-- Two-step writes from MCP and Telegram: created first, executed on confirm.
CREATE TABLE pending_actions (
    id           text        PRIMARY KEY,
    origin       text        NOT NULL CHECK (origin IN ('mcp', 'telegram')),
    tool         text        NOT NULL,
    args         jsonb       NOT NULL DEFAULT '{}',
    summary      text        NOT NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    expires_at   timestamptz NOT NULL,
    confirmed_at timestamptz
);

-- Inbound webhook deduplication (Jira, GitHub, GitLab, Telegram).
CREATE TABLE webhook_deliveries (
    provider    text        NOT NULL,
    delivery_id text        NOT NULL,
    received_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (provider, delivery_id)
);

-- +goose Down
DROP TABLE webhook_deliveries;
DROP TABLE pending_actions;
DROP TABLE telegram_messages;
DROP TABLE devices;
DROP TABLE settings;
DROP TABLE usage_snapshots;
DROP TABLE integrations;
DROP TABLE events;
DROP TABLE results;
DROP TABLE runs;
DROP TABLE questions;
DROP TABLE tickets;
DROP TABLE repositories;
DROP TABLE sessions;
DROP TABLE users;
