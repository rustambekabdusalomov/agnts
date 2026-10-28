-- +goose Up
-- Meetings: video calls of a workspace's members and the guests they let
-- in. LiveKit carries the media; these tables are who may join what, when
-- it was live, what was said and what came out of it. A meeting is a
-- reusable link; a session is one time it was live.

CREATE TABLE meetings (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  code          text        NOT NULL UNIQUE CHECK (code ~ '^[a-z]{10}$'), -- in public links, unique on the server
  title         text        NOT NULL DEFAULT '',
  description   text        NOT NULL DEFAULT '',
  host_id       bigint      REFERENCES users (id) ON DELETE SET NULL,
  kind          text        NOT NULL CHECK (kind IN ('instant', 'scheduled')),
  starts_at     timestamptz,                  -- scheduled only
  duration_min  integer     NOT NULL DEFAULT 30 CHECK (duration_min BETWEEN 5 AND 720),
  time_zone     text        NOT NULL DEFAULT 'UTC',
  access        text        NOT NULL DEFAULT 'workspace' CHECK (access IN ('workspace', 'invited')),
  guests        text        NOT NULL DEFAULT 'knock' CHECK (guests IN ('off', 'knock', 'open')),
  locked        boolean     NOT NULL DEFAULT false,
  auto_record   boolean     NOT NULL DEFAULT false,
  auto_notes    boolean     NOT NULL DEFAULT false,
  language      text        NOT NULL DEFAULT 'auto' CHECK (language IN ('auto', 'en', 'ru', 'uz')),
  ics_sequence  integer     NOT NULL DEFAULT 0,
  cancelled_at  timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  CHECK (kind = 'instant' OR starts_at IS NOT NULL)
);
CREATE INDEX meetings_upcoming_idx ON meetings (workspace_id, starts_at) WHERE cancelled_at IS NULL;
CREATE INDEX meetings_host_idx ON meetings (host_id);

CREATE TABLE meeting_cohosts (
  meeting_id   bigint NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  user_id      bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  PRIMARY KEY (meeting_id, user_id)
);

CREATE TABLE meeting_invitees (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  user_id      bigint      REFERENCES users (id) ON DELETE CASCADE,
  email        text        NOT NULL DEFAULT '',
  rsvp         text        NOT NULL DEFAULT 'none' CHECK (rsvp IN ('none', 'yes', 'no', 'maybe')),
  reminded_at  timestamptz,                  -- the reminder of the current start time was sent
  token_hash   bytea       UNIQUE,            -- email invitees: their personal link
  created_at   timestamptz NOT NULL DEFAULT now(),
  CHECK ((user_id IS NULL) <> (email = ''))
);
CREATE UNIQUE INDEX meeting_invitees_user_idx  ON meeting_invitees (meeting_id, user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX meeting_invitees_email_idx ON meeting_invitees (meeting_id, lower(email)) WHERE email <> '';
CREATE INDEX meeting_invitees_member_idx ON meeting_invitees (user_id) WHERE user_id IS NOT NULL;

CREATE TABLE meeting_sessions (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  room         text        NOT NULL DEFAULT '', -- the LiveKit room name, set from the id
  started_at   timestamptz NOT NULL DEFAULT now(),
  connected_at timestamptz,                  -- the first participant_joined; NULL ones are swept
  ended_at     timestamptz,
  guests_quiet boolean     NOT NULL DEFAULT false, -- guests can't chat or share their screen
  notes_on     boolean     NOT NULL DEFAULT false,
  notes_status text        NOT NULL DEFAULT 'none'
               CHECK (notes_status IN ('none', 'recording', 'queued', 'transcribing', 'writing', 'done', 'failed')),
  notes_error  text        NOT NULL DEFAULT '',
  notes_by     bigint      REFERENCES users (id) ON DELETE SET NULL, -- who turned notes on; their Muse account hears them
  document_id  bigint      REFERENCES documents (id) ON DELETE SET NULL -- the notes
);
-- At most one live session per meeting.
CREATE UNIQUE INDEX meeting_sessions_live_idx ON meeting_sessions (meeting_id) WHERE ended_at IS NULL;
CREATE INDEX meeting_sessions_meeting_idx ON meeting_sessions (meeting_id, started_at DESC);
CREATE INDEX meeting_sessions_notes_idx ON meeting_sessions (notes_status) WHERE notes_status IN ('queued', 'transcribing');

-- Guests, as document_guests: their secret is kept as a hash.
CREATE TABLE meeting_guests (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  name         text        NOT NULL,
  email        text        NOT NULL DEFAULT '',
  via          text        NOT NULL DEFAULT 'name' CHECK (via IN ('name', 'google', 'account', 'invite')),
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
  invitee_id   bigint      REFERENCES meeting_invitees (id) ON DELETE SET NULL, -- joined with an invitee's link
  token_hash   bytea       NOT NULL UNIQUE,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX meeting_guests_meeting_idx ON meeting_guests (meeting_id);

-- A seat is one person's right to be in one session, from one device:
-- what a join or an admitted knock hands out. The person's in-call
-- requests carry its secret. Removing someone ends all their seats.
CREATE TABLE meeting_seats (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  user_id      bigint      REFERENCES users (id) ON DELETE CASCADE,
  guest_id     bigint      REFERENCES meeting_guests (id) ON DELETE CASCADE,
  device       text        NOT NULL,          -- part of the LiveKit identity
  name         text        NOT NULL,
  knocked      boolean     NOT NULL DEFAULT false, -- came in through the waiting room
  token_hash   bytea       NOT NULL UNIQUE,
  removed_at   timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  CHECK ((user_id IS NULL) <> (guest_id IS NULL))
);
CREATE INDEX meeting_seats_session_idx ON meeting_seats (session_id);

CREATE TABLE meeting_knocks (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  user_id      bigint      REFERENCES users (id) ON DELETE CASCADE,
  guest_id     bigint      REFERENCES meeting_guests (id) ON DELETE CASCADE,
  device       text        NOT NULL,
  name         text        NOT NULL,
  state        text        NOT NULL DEFAULT 'waiting' CHECK (state IN ('waiting', 'admitted', 'denied', 'expired')),
  token_hash   bytea       NOT NULL UNIQUE,   -- the knocker polls with it
  seat_id      bigint      REFERENCES meeting_seats (id) ON DELETE SET NULL,
  decided_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  decided_at   timestamptz,
  CHECK ((user_id IS NULL) <> (guest_id IS NULL))
);
CREATE INDEX meeting_knocks_session_idx ON meeting_knocks (session_id, created_at);

-- Attendance, one row per connection, from LiveKit's participant_joined /
-- participant_left webhooks.
CREATE TABLE meeting_participants (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  identity     text        NOT NULL,          -- u<user id>-<device> or g<guest id>-<device>
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
  guest_id     bigint      REFERENCES meeting_guests (id) ON DELETE SET NULL,
  name         text        NOT NULL,          -- as it was in the call
  joined_at    timestamptz NOT NULL,
  left_at      timestamptz,
  UNIQUE (session_id, identity, joined_at)
);
CREATE INDEX meeting_participants_session_idx ON meeting_participants (session_id, joined_at);
CREATE INDEX meeting_participants_open_idx ON meeting_participants (session_id) WHERE left_at IS NULL;

CREATE TABLE meeting_messages (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
  guest_id     bigint      REFERENCES meeting_guests (id) ON DELETE SET NULL,
  name         text        NOT NULL,
  body         text        NOT NULL CHECK (length(body) <= 2000),
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX meeting_messages_session_idx ON meeting_messages (session_id, id);

-- Video recordings and the audio of notes, as LiveKit Egress writes them.
CREATE TABLE meeting_media (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  kind         text        NOT NULL CHECK (kind IN ('recording', 'audio-mixed', 'audio')),
  egress_id    text        NOT NULL UNIQUE,
  identity     text        NOT NULL DEFAULT '', -- audio (per speaker): whose microphone
  file         text        NOT NULL,          -- the file's name in the meetings directory
  bytes        bigint      NOT NULL DEFAULT 0,
  started_at   timestamptz NOT NULL DEFAULT now(),
  ended_at     timestamptz,
  status       text        NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ready', 'failed', 'expired', 'deleted')),
  started_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  error        text        NOT NULL DEFAULT ''
);
CREATE INDEX meeting_media_session_idx ON meeting_media (session_id, started_at);
CREATE INDEX meeting_media_active_idx ON meeting_media (status) WHERE status = 'active';

CREATE TABLE meeting_segments (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  identity     text        NOT NULL DEFAULT '', -- empty in mixed mode
  name         text        NOT NULL DEFAULT '',
  start_ms     integer     NOT NULL,           -- from the session's start
  end_ms       integer     NOT NULL,
  text         text        NOT NULL,
  search       tsvector    GENERATED ALWAYS AS (to_tsvector('simple', text)) STORED
);
CREATE INDEX meeting_segments_session_idx ON meeting_segments (session_id, start_ms);
CREATE INDEX meeting_segments_search_idx  ON meeting_segments USING gin (search);

CREATE TABLE meeting_action_items (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  position     integer     NOT NULL,          -- order in the notes
  text         text        NOT NULL,
  who          text        NOT NULL DEFAULT '', -- as said, not a user
  due          text        NOT NULL DEFAULT '', -- as said ("by Friday")
  at_ms        integer,                        -- the cited time
  quote        text        NOT NULL DEFAULT '',
  ticket_id    bigint      UNIQUE REFERENCES tickets (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX meeting_action_items_session_idx ON meeting_action_items (session_id, position);

-- Tickets discussed in or made from a meeting.
CREATE TABLE meeting_tickets (
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  ticket_id    bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  session_id   bigint      REFERENCES meeting_sessions (id) ON DELETE SET NULL,
  quote        text        NOT NULL DEFAULT '',
  created_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (meeting_id, ticket_id)
);
CREATE INDEX meeting_tickets_ticket_idx ON meeting_tickets (ticket_id);

-- LiveKit webhooks already handled. Webhooks are retried and can repeat;
-- rows older than a day are pruned. Event ids only: no workspace data.
CREATE TABLE livekit_events (
  id          text        PRIMARY KEY,
  received_at timestamptz NOT NULL DEFAULT now()
);

-- How long before a meeting a member is reminded; 0 turns reminders off.
ALTER TABLE users ADD COLUMN meeting_reminder_min integer NOT NULL DEFAULT 10 CHECK (meeting_reminder_min IN (0, 5, 10, 15));

-- +goose StatementBegin
DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['meetings', 'meeting_cohosts', 'meeting_invitees', 'meeting_sessions', 'meeting_guests', 'meeting_seats',
                             'meeting_knocks', 'meeting_participants', 'meeting_messages', 'meeting_media', 'meeting_segments',
                             'meeting_action_items', 'meeting_tickets'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('CREATE POLICY workspace_isolation ON %I USING (agnts_all() OR workspace_id = agnts_ws())
            WITH CHECK (agnts_all() OR workspace_id = agnts_ws())', t);
    END LOOP;
END $$;
-- +goose StatementEnd

-- +goose Down
ALTER TABLE users DROP COLUMN meeting_reminder_min;
DROP TABLE livekit_events;
DROP TABLE meeting_tickets;
DROP TABLE meeting_action_items;
DROP TABLE meeting_segments;
DROP TABLE meeting_media;
DROP TABLE meeting_messages;
DROP TABLE meeting_participants;
DROP TABLE meeting_knocks;
DROP TABLE meeting_seats;
DROP TABLE meeting_guests;
DROP TABLE meeting_sessions;
DROP TABLE meeting_invitees;
DROP TABLE meeting_cohosts;
DROP TABLE meetings;
