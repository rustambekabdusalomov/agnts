# agnts Meetings — Plan

Oct 28, 2026 · v2, implemented (all phases)

> **Status.** Phases 1–4 are built and tested (server, admin, mobile, deploy). Where the build differs from the text below:
> - **Transcription** runs `muse voice transcribe` inside the runner image (ffmpeg splits the audio at silences into clips of up to 90 s), not a separate whisper.cpp transcriber service.
> - **In-call actions** (chat, hand, mute, admit, record, notes, end) go through public endpoints `/public/meetings/{code}/…` authorised by a per-join **seat** token (`X-Meeting-Seat`), so members and guests use the same calls.
> - **Workspace rules** (recording allowed, retention days, keep audio, max people) live in the workspace settings JSON (`settings.meetings`), not a separate table.
> - **Notes audio** defaults to `mixed` (one Ogg of the whole call); `per-speaker` (`AGNTS_MEET_NOTES_AUDIO`) is built but not yet validated on the server.
> - Meeting notifications are push and live events only; invitations and reminders go by email with an `.ics`.
> - Not verified end to end: real Muse transcription (needs the rebuilt runner image and Muse credentials), mobile calls on a device, TURN over TLS on 443 (not built).

## Overview

**Meetings** are video calls inside agnts, like Google Meet, for the members of a workspace and the guests they let in. A meeting has a short link (`agnts.uz/m/abc-defg-hij`), camera, microphone, screen sharing, chat and host controls. When the host turns on **notes**, agnts transcribes the call after it ends and **Muse writes the meeting notes** (summary, decisions, action items with owners) as an agnts **document**; an action item becomes a **ticket** with one click, so a decision made in a call goes straight to the agent that codes it.

agnts does not carry the audio and video itself. A self-hosted **LiveKit** server (open-source SFU) runs next to agnts in the same Compose stack and moves the media; **LiveKit Egress** records. agnts is the **control plane**: who may join which meeting, with what rights, when it starts and ends, what was said and what came out of it.

```
 browser / phone ──WebRTC media──▶ livekit (SFU) ──track & room egress──▶ /var/lib/agnts/meetings/…
       │                               │  ▲                                        │
       │ REST + SSE (join, chat,       │  │ server API (mute, remove,              │ files
       │ knock, admit, notes)          │  │ send data, start/stop egress)          ▼
       ▼                               ▼  │                                 transcriber (whisper.cpp)
     agnts ◀────── webhooks (joined, left, room finished, egress ended) ───────────┘
       │                                                                           │
       └──▶ PostgreSQL ◀── segments ───────────────────────────────────────────────┘
       └──▶ Muse (document generation, source = meeting) ──▶ document + tickets
```

**Goals**

- Instant and scheduled meetings with a reusable link; join from the admin panel, the public guest page and the mobile app.
- Camera, microphone, screen share, grid and speaker views, chat, raise hand, reactions.
- Host controls: mute, remove, lock, waiting room, co-hosts, end for everyone.
- Guests without an account, through a waiting room.
- Scheduling with invitations by email (`.ics`), reminders on the phone, in Telegram and in the app.
- Recording to a video file the attendees can watch.
- AI notes: transcript per speaker, then a Muse-written document with decisions and action items that become tickets.

**Out of scope for v1:** live captions, end-to-end encryption, dial-in by phone, breakout rooms, virtual backgrounds, recurring meetings, Google/Outlook calendar sync, screen sharing from the phone, more than one LiveKit node.

**Principles**

1. **agnts decides, LiveKit carries.** Every join goes through agnts, which signs a short-lived LiveKit token with exactly the rights that person has. LiveKit never sees an agnts session; agnts never touches a media packet.
2. **The webhook is the truth.** Who was in the call and for how long, when the room ended and which files exist come from LiveKit's signed webhooks, not from what a browser says.
3. **A meeting is a link; a session is one time it was live.** Chat, attendance, recordings, transcript and notes belong to a session. The link can be used again next week.
4. **Notes reuse Documents.** The notes are a document with a new source kind `meeting`, so access, versions, the secret scan, PDF export, credits and spend work without a second copy.
5. **Nothing is recorded without everyone seeing it.** Recording and notes show a banner to everyone in the call and to everyone who joins later.

## Rules

### Meetings and sessions

- A **meeting** belongs to a workspace and has a **code**: 10 lowercase letters shown as `abc-defg-hij`, unique across the server (it is in public links). The link is `/m/<code>`.
- **Instant meeting** ("New meeting → Start now"): created and joined at once.
- **Scheduled meeting**: a title, a start time with time zone, a duration (default 30 min), an optional description and invitees. It can be joined from 15 minutes before its start; the host can join at any time. After its scheduled end the link keeps working (people run over, or reuse it), as in Google Meet; it is only listed under Upcoming until its end.
- A **session** starts at the **first `Join`** of a meeting that has no live session: agnts creates the row, and the room name comes from it. It ends when:
  - LiveKit reports `room_finished` (the last person left and `departure_timeout`, 2 minutes, passed; or the host ended it for everyone), or
  - **nobody connected**: no `participant_joined` within 2 minutes of the session's creation (someone opened the lobby and closed the tab). A sweeper closes such sessions, so a meeting is never stuck with a live session nobody is in.
- A **reconciler** runs every minute: `ListRooms` and `ListParticipants` from LiveKit against the live sessions and open attendance rows, closing what LiveKit no longer has and adding what a lost webhook missed.
- The next join after a session ended starts a new session.
- A meeting can be **cancelled** (scheduled, not live) or **deleted** by its host or the workspace Owner. Deleting a meeting deletes its sessions, recordings, transcripts and chat; the notes documents stay (they are documents, with their own trash).
- One LiveKit room per session: `ws<workspace>-m<meeting>-s<session>`.

### Who can join

Each meeting has an **access** setting, chosen by the host:

| Access | Members of the workspace | Invited people | Guests (no account, or another workspace) |
| --- | --- | --- | --- |
| **Workspace** (default for instant) | join | join | knock |
| **Invited** (default for scheduled) | knock | join | knock |

And a **guests** setting: `off` (guests can't even knock), `knock` (default) or `open` (anyone with the link joins without waiting). `open` asks for confirmation and is turned back to `knock` when the session ends.

- **Invited by email**: each email invitee's invitation link carries a personal token (`/m/<code>?i=<token>`, kept as a hash). Joining with it counts as invited: they join without knocking, under the name they type, and are marked as that invitee. The token works only for that meeting and is revoked when they are removed from the invitees. Forwarded, it lets one more person in as that invitee; the host sees the invitee's email next to the name.
- **Knocking** puts the person in the **waiting room**. Hosts and co-hosts in the call see "Rustam wants to join" with Admit / Deny, and Admit all. No host in the call: the host is notified (push, Telegram) and anyone in the call who can admit (below) sees the knock.
- **Who can admit:** the host, co-hosts, and the workspace Owner when they are in the call. If none of them is in the call, the members who joined without knocking can admit, so a call doesn't get stuck.
- **Admitted once is admitted for the session**: someone admitted (or who was in the call) joins the same session again without knocking, after a dropped connection, a reload or on another device. Being removed undoes that.
- A knock waits up to 10 minutes, then expires. A denied guest can't knock again on the same session for 5 minutes.
- A **locked** meeting lets nobody new in, not even members; only hosts can unlock.
- **Max participants**: the workspace's limit (default 50, set per plan). The next person sees "This meeting is full".
- A guest types a name; "Continue with Google" fills it and marks the guest verified, as document guests do. A signed-in agnts user of another workspace joins as a guest with their account name, marked as such.

### Roles in the call

| Can | Host | Co-host | Member | Guest |
| --- | --- | --- | --- | --- |
| Camera, microphone, screen share, chat, raise hand, reactions | ✅ | ✅ | ✅ | ✅ (unless the host turned it off) |
| Admit / deny knocks | ✅ | ✅ | see above | — |
| Mute someone, stop someone's camera or screen share | ✅ | ✅ | — | — |
| Remove someone (they can't come back to this session) | ✅ | ✅ | — | — |
| Lock, turn guests chat / screen share off for everyone else | ✅ | ✅ | — | — |
| Start / stop recording and notes | ✅ | ✅ | — | — |
| Make / unmake co-hosts, end for everyone, change access | ✅ | — | — | — |

- The **host** is the person who created the meeting. They can hand it over to a member. When the host's account leaves the workspace or is deleted, the workspace Owner becomes the host (as documents move to the Owner).
- **One person, several devices**: each connection has its own LiveKit identity, `u<user id>-<device>` or `g<guest id>-<device>` (`device` a random id the browser or app keeps), and the person's id in its attributes. A laptop and a phone are two tiles of the same person; the people list groups them. Rights, removal and attendance are by person, not by identity: removing someone disconnects all their devices.
- **Muting** someone stops their microphone; only they can turn it back on (LiveKit can mute a track, not unmute it). The host can **ask** them to unmute.
- The rights are in the LiveKit token (`canPublish`, `canPublishSources`, `canPublishData`, `roomAdmin` is never given to clients). Host actions go through agnts, which checks the role and calls LiveKit's server API. When a role changes mid-call, agnts updates the participant's permissions in LiveKit at once.

### In the call

- **Lobby** before joining: camera preview, microphone level, device pickers, join muted / with camera off, name (guests). The choice of devices is remembered in the browser.
- **Layouts**: grid (up to 16 tiles per page, then pages), speaker (the active speaker large, others in a strip), and screen share (the share large). Pin a tile. Self view can be hidden.
- **Quality**: simulcast, adaptive stream and dynacast on, so each viewer only receives the sizes they show. Camera up to 720p; screen share up to 1080p at 15 fps (30 fps "for video" option). Audio: Opus with noise suppression and echo cancellation from the browser.
- **Chat**: messages are sent to agnts (`POST`), which stores them, runs the secret scan (a message with a token in it is refused, as in comments) and broadcasts them to the room with LiveKit's data API. Max 2,000 characters. Links are clickable; ticket keys (`PAY-123`) link to the ticket for members. Everyone who joins later sees the earlier messages of the session. After the call, the chat is readable by those who can open the session (below, as recordings); guests only see it during the call.
- **Raise hand** and **reactions** (👍 👏 😂 ❤️ 🎉 🤔): LiveKit participant attributes and data messages, not stored. Hands are listed in order raised; a host can lower someone's hand.
- **Reconnects**: LiveKit reconnects on its own. A dropped person whose connection is gone joins again without knocking while the session is live (see "Admitted once").
- **Leaving**: Leave, or (host) End for everyone, which tells LiveKit to delete the room.

### Recording

- The host or a co-host starts it; the meeting can also be set to "Record automatically". Recording needs the workspace setting **Allow recording** (on by default) and free space under the recordings quota.
- It is a **room composite** recording (LiveKit Egress renders the speaker layout in headless Chrome) to MP4, 720p, on the agnts data volume.
- While it runs, everyone sees a red "Recording" badge, and someone who joins sees "This meeting is being recorded" in the lobby before they join.
- Stopping, the session ending or the room emptying stops it. Several recordings in one session are several files.
- **Who can watch**: the people who were in the session (members, not guests), the meeting's invitees and host, and the workspace Owner. Recordings are streamed by agnts with Range requests; downloading needs the same rights.
- **Retention**: workspace setting, default 90 days, then the file is deleted (the row stays, marked expired). Owners can delete a recording at once.
- **Limits**: one composite recording at a time per workspace by default, a server-wide limit (`AGNTS_MEET_MAX_RECORDINGS`, default 2, since each takes 2–4 CPU). Over the limit, Start says "Recording isn't available right now".

### Notes (transcript and AI notes)

- **Notes** is a separate switch from recording: the host turns on "Take notes", or sets the meeting to take them automatically. The same banner rules apply ("agnts is taking notes").
- Notes can be turned off and on again in a session; the audio of every stretch they were on is used, and the notes are written **once, when the session ends**. Turning them off doesn't start the notes early.
- Notes are captured in one of two **modes** (a server setting, `AGNTS_MEET_NOTES_AUDIO`):
  - **`mixed`** (v1 default, phase 2): one **audio-only room composite** recording of the whole session, one Ogg file. One egress per session whatever the number of people, and one timeline, so times are right by construction. The transcript has no speaker names; Muse is told so and attributes only what the words make clear ("Rustam said he'd…").
  - **`per-speaker`** (phase 2b): **each person's microphone separately** (LiveKit track egress, audio only, Ogg/Opus). The speaker is known from the file, so the transcript has names without diarization. Segments get absolute times and are merged in time order. Two things must be proven on a running stack before this mode is turned on:
    - **Timing across mutes**: whether track egress writes silence while a microphone is muted. If it writes nothing, the file's timeline shrinks and every time after a mute drifts; then times are taken from the Ogg granule positions (the RTP clock) rather than the decoded duration, and a test call with mutes must show times within 1 s.
    - **Egress capacity**: Egress refuses a job when its CPU budget is used up, and with default costs a 4-CPU server refuses the fifth or sixth microphone. Track egress only remuxes, so `cpu_cost.track_cpu_cost` is lowered (e.g. 0.2); a 10-person test call must get all ten files. Until both pass, the server stays on `mixed`.
- When the session ends, a **transcription job** runs: each audio file is transcribed by **whisper.cpp** on the CPU with voice activity detection, so silence costs nothing.
- Language: the meeting's language setting (auto, English, Russian, Uzbek). Auto lets whisper detect per file.
- Then a **document generation** runs with source kind `meeting`: Muse reads the transcript, the chat, the title, description and attendees, and writes the notes in the `meeting-notes` format:
  - Summary (a few lines),
  - Decisions,
  - Action items: what, who (named when the transcript makes it clear), when if said,
  - Open questions,
  - each point cites the time it was said: `[12:34]`, a link that opens the recording (when there is one) or the transcript at that time.
- The notes document is a **private page** in the workspace, owned by the host (the workspace Owner when there is no host any more, since a document must have an owner), with **View** granted to the members who attended and the invitees. It is linked to the meeting, and the meeting to the tickets created from it.
- **Action items are rows, not text to parse later.** Muse returns the action items as structured output next to the Markdown; the server stores them in `meeting_action_items` (text, who as written, due as written, the cited time, the quote) and writes them into the document as a plain list. Editing the document doesn't change the rows; regenerating replaces the rows that have no ticket yet and keeps the ones that do.
- **Action item → ticket**: on the meeting's session page and next to the notes, each action item has "Create ticket": a task (with or without a repository, as tasks are today) with the item as the title and the context and quote as the description. The row keeps the ticket, so it can't be made twice. The ticket shows "From meeting *Sprint planning*, Oct 28" with a link. (Tickets have no agnts assignee today; who said they'd do it goes in the description. Assigning is later, with ticket assignees.)
- **Cost**: the Muse generation is charged as documents are (the host's or workspace's Muse connection, else credits). Transcription runs on the server and costs no credits; it is limited by a queue (`AGNTS_MEET_TRANSCRIBE_WORKERS`, default 1).
- A meeting longer than ~3 hours of speech is summarised in parts and the parts merged, so the prompt stays within the model's context.
- The **transcript** itself is kept with the session, readable by those who can read the notes, searchable, downloadable as `.txt` and `.vtt`. Retention: as recordings.
- Audio files are deleted when the transcript is done, unless the workspace keeps them ("Keep audio of notes", off by default).

### Usage

- Every workspace's meeting use is **counted**, even though v1 doesn't charge for it: participant-minutes (from attendance), recording minutes and bytes stored, transcribed minutes. They show on Usage next to runs, and the hosted product's plans can put limits on them (participant-minutes per month, storage) without a schema change.
- The counters come from the attendance and media rows, summed per workspace per day by the usage job; nothing is counted in the call's path.

### Scheduling and invitations

- Invitees are members (picked from the list) and email addresses.
- Each invitee gets an **email with an `.ics`** (`METHOD:REQUEST`, `UID:<code>@<domain>`, the link in `LOCATION` and the description), so it lands in Google Calendar, Outlook or Apple Calendar. A change sends an update (`SEQUENCE` + 1), a cancellation sends `METHOD:CANCEL`. Without SMTP configured, invitations are only in agnts.
- Members also see the meeting under **Meetings → Upcoming** and get a notification.
- **RSVP**: members answer Yes / No / Maybe in agnts; the host sees the answers. Email replies from calendars are not read in v1.
- **Reminders**: 10 minutes before (per person: off, 5, 10, 15 min), by push, Telegram and in the app, with a Join button. A live meeting a member is invited to but hasn't joined shows "Rustam is waiting for you".
- **Calling someone now**: in an instant meeting, "Invite" → a member rings on their phone (push) and in the app (a toast with Join / Decline) for 30 seconds.

### Where meetings show

- **Admin → Meetings**: Upcoming (scheduled, live first), Past (sessions with attendees, duration, recording, notes), New meeting (Start now / Schedule / Get a link to share).
- **Live** meetings of the workspace show a "Live · 4 people" badge with Join, on the dashboard as well.
- A **ticket** can link to meetings ("Discussed in"), and a meeting to tickets, both ways, as documents link tickets.
- **Assistant** and **MCP**: two read tools, `meetings_search` (meetings, decisions and action items the asker can read) and `meeting_transcript` (one session's transcript, if allowed), so the assistant can answer "what did we decide about the refund flow?", and a coding run on a ticket made from a meeting gets the cited quote in its context.

## Data

`migrations/00068_meetings.sql` (all tables with `workspace_id ... DEFAULT agnts_ws()` and row-level security, as the other workspace tables):

```sql
CREATE TABLE meetings (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  code          text        NOT NULL UNIQUE CHECK (code ~ '^[a-z]{10}$'),
  title         text        NOT NULL DEFAULT '',
  description   text        NOT NULL DEFAULT '',
  host_id       bigint      REFERENCES users (id) ON DELETE SET NULL,
  kind          text        NOT NULL CHECK (kind IN ('instant', 'scheduled')),
  starts_at     timestamptz,                  -- scheduled only
  duration_min  integer     CHECK (duration_min BETWEEN 5 AND 720),
  time_zone     text        NOT NULL DEFAULT 'UTC',
  access        text        NOT NULL DEFAULT 'workspace' CHECK (access IN ('workspace', 'invited')),
  guests        text        NOT NULL DEFAULT 'knock' CHECK (guests IN ('off', 'knock', 'open')),
  locked        boolean     NOT NULL DEFAULT false,
  auto_record   boolean     NOT NULL DEFAULT false,
  auto_notes    boolean     NOT NULL DEFAULT false,
  language      text        NOT NULL DEFAULT 'auto',
  ics_sequence  integer     NOT NULL DEFAULT 0,
  cancelled_at  timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX meetings_upcoming_idx ON meetings (workspace_id, starts_at) WHERE cancelled_at IS NULL;

CREATE TABLE meeting_cohosts (
  meeting_id bigint NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  user_id    bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
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
  reminded_at  timestamptz,
  token_hash   bytea       UNIQUE,            -- email invitees: their personal link
  CHECK ((user_id IS NULL) <> (email = ''))
);
CREATE UNIQUE INDEX meeting_invitees_user_idx  ON meeting_invitees (meeting_id, user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX meeting_invitees_email_idx ON meeting_invitees (meeting_id, lower(email)) WHERE email <> '';

CREATE TABLE meeting_sessions (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  room         text        NOT NULL UNIQUE,   -- the LiveKit room name
  started_at   timestamptz NOT NULL DEFAULT now(),
  ended_at     timestamptz,
  connected_at timestamptz,                  -- the first participant_joined; NULL ones are swept
  notes_on     boolean     NOT NULL DEFAULT false,
  notes_status text        NOT NULL DEFAULT 'none'
               CHECK (notes_status IN ('none', 'recording', 'queued', 'transcribing', 'writing', 'done', 'failed')),
  notes_error  text        NOT NULL DEFAULT '',
  document_id  bigint      REFERENCES documents (id) ON DELETE SET NULL  -- the notes
);
-- At most one live session per meeting.
CREATE UNIQUE INDEX meeting_sessions_live_idx ON meeting_sessions (meeting_id) WHERE ended_at IS NULL;

-- Guests, as document_guests: their secret is kept as a hash.
CREATE TABLE meeting_guests (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint      NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  name         text        NOT NULL,
  email        text        NOT NULL DEFAULT '',
  via          text        NOT NULL DEFAULT 'name' CHECK (via IN ('name', 'google', 'account')),
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
  token_hash   bytea       NOT NULL UNIQUE,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE meeting_knocks (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  user_id      bigint      REFERENCES users (id) ON DELETE CASCADE,
  guest_id     bigint      REFERENCES meeting_guests (id) ON DELETE CASCADE,
  state        text        NOT NULL DEFAULT 'waiting' CHECK (state IN ('waiting', 'admitted', 'denied', 'expired')),
  decided_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  decided_at   timestamptz,
  CHECK ((user_id IS NULL) <> (guest_id IS NULL))
);

-- Attendance, from LiveKit's participant_joined / participant_left webhooks.
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
  removed      boolean     NOT NULL DEFAULT false,
  -- One row per connection: a retried participant_joined finds it.
  UNIQUE (session_id, identity, joined_at)
);
CREATE INDEX meeting_participants_session_idx ON meeting_participants (session_id, joined_at);

-- LiveKit webhooks already handled. Webhooks are retried and can repeat;
-- rows older than a day are pruned.
CREATE TABLE livekit_events (
  id          text        PRIMARY KEY,      -- the webhook's event id
  received_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE meeting_messages (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  identity     text        NOT NULL,
  name         text        NOT NULL,
  body         text        NOT NULL CHECK (length(body) <= 2000),
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- Composite recordings (video) and per-microphone audio for notes.
CREATE TABLE meeting_media (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  kind         text        NOT NULL CHECK (kind IN ('recording', 'audio-mixed', 'audio')),
  egress_id    text        NOT NULL UNIQUE,
  identity     text        NOT NULL DEFAULT '', -- audio (per speaker): whose microphone
  path         text        NOT NULL DEFAULT '', -- under AGNTS_DATA_DIR/meetings
  bytes        bigint      NOT NULL DEFAULT 0,
  started_at   timestamptz NOT NULL DEFAULT now(),
  ended_at     timestamptz,
  status       text        NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ready', 'failed', 'expired', 'deleted')),
  started_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
  error        text        NOT NULL DEFAULT ''
);

CREATE TABLE meeting_segments (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  session_id   bigint      NOT NULL REFERENCES meeting_sessions (id) ON DELETE CASCADE,
  identity     text        NOT NULL DEFAULT '', -- empty in mixed mode
  name         text        NOT NULL DEFAULT '',
  start_ms     integer     NOT NULL,           -- from the session's start
  end_ms       integer     NOT NULL,
  text         text        NOT NULL,
  lang         text        NOT NULL DEFAULT '',
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

CREATE TABLE meeting_tickets (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  meeting_id   bigint NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
  ticket_id    bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  session_id   bigint REFERENCES meeting_sessions (id) ON DELETE SET NULL,
  quote        text   NOT NULL DEFAULT '',
  PRIMARY KEY (meeting_id, ticket_id)
);
```

- Workspace settings gain `meetings_allow_recording`, `meetings_retention_days` (90), `meetings_keep_audio` (false), `meetings_max_participants` (50), `meetings_storage_quota_bytes`.
- Users gain `meeting_reminder_min` (10, 0 = off).
- The document source gains `{kind: "meeting", sessionId}`; `TemplateMeetingNotes` is the default for it.
- The transcription queue is `meeting_sessions.notes_status = 'queued'`, picked with `FOR UPDATE SKIP LOCKED`, as other agnts queues.
- `notes_status` goes `none → recording` the first time notes are turned on, stays `recording` through off / on, and goes to `queued` when the session ends with at least one audio file.
- **Looking a meeting up by its code** (the guest page, the invitee link, a member of another workspace) happens before the workspace is known, so it runs in the system context, as `PublicDocument` does for public links, and everything after it is scoped to the workspace found. Only the code lookup and the LiveKit webhook (which finds the session by room name) run that way.
- `livekit_events` has no `workspace_id` and no row-level security: it holds only event ids.

## Code

Server (Clean Architecture, as the rest):

- `domain/meeting.go`: `Meeting`, `Session`, `Access`, `GuestMode`, `MeetingRole` (host, cohost, member, guest), `Rights` (what a role may do, one table, used by the token, the API and the UI), `MeetingCode` (generate, parse `abc-defg-hij`), `Segment`, `NotesStatus`. Table-tested.
- `livekit/` (adapter, no SDK dependency, as `google/` is hand-rolled):
  - `token.go`: the access token (HS256 JWT with the video grant: room, `canPublish`, `canPublishSources`, `canPublishData`, `canSubscribe`, `canUpdateOwnMetadata`, `hidden` for the recorder). TTL 10 minutes; LiveKit refreshes it while connected.
  - `client.go`: the Twirp server API calls agnts needs: `DeleteRoom`, `ListParticipants`, `RemoveParticipant`, `MutePublishedTrack`, `UpdateParticipant` (permissions, attributes), `SendData`, `StartRoomCompositeEgress`, `StartTrackEgress`, `StopEgress`.
  - `webhook.go`: verifies the `Authorization` JWT and the body's SHA-256, parses `room_started`, `room_finished`, `participant_joined`, `participant_left`, `track_published`, `egress_started`, `egress_ended`, with the event's id and time.
  - Tests against recorded requests and LiveKit's published examples.
- `meetings/` (use case):
  - `meetings.go`: create, schedule, update (bumps `ics_sequence` when the time changes), cancel, delete, list (upcoming, past, live), `Join` (decides join / knock / refuse from access, guests, lock, the cap, a removal; opens a session if none is live; returns a token and the LiveKit URL), host actions (mute, remove, lock, cohost, end, access), knocks (admit, deny, expire), chat (store, scan, broadcast).
  - `webhooks.go`: attendance, session end (closes the session, stops egress, queues notes), egress state, starting the notes audio egress (the mixed one when notes turn on; per microphone on `track_published` in per-speaker mode). Every event is handled once (`livekit_events`) and tolerates order: a `participant_left` before its `joined` creates the row closed, a second `room_finished` does nothing.
  - `sweep.go`: the unconnected-session sweeper and the reconciler against `ListRooms` / `ListParticipants`, every minute.
  - `recording.go`: start / stop with the workspace and server limits, the consent banner state (room metadata), playback authorization, retention sweep.
  - `notes.go`: the transcription worker (claims a session, transcribes each audio file through `Transcriber`, stores segments, starts the document generation), storing the action items when the generation finishes, the transcript as `.txt` / `.vtt`, action item → ticket.
  - `invites.go`: `.ics` building (RFC 5545, folded lines, escaped text), emails through `mail`, reminders (a ticker, `reminded_at`), "calling" pushes.
  - Ports it declares: `Store`, `LiveKit`, `Transcriber`, `Mailer`, `Notifier`, `Documents`, `Tickets`, `Clock`.
- `transcribe/`: `Transcriber` over the `transcriber` service's HTTP API (whisper.cpp's server: `POST /inference`, file + language + VAD, `verbose_json` with segments). The interface leaves room for another engine later.
- `store/postgres/meetings.go`: the tables above; attendance and segments as batches.
- `orchestrator/documents.go`: `gatherMeeting` (segments as `[mm:ss] Name: text`, or `[mm:ss] text` in mixed mode with a line saying speakers are unknown; the chat, the attendees, the title and description), the `meeting-notes` format and prompt (citations as `[mm:ss]`), the action items as a structured result beside the Markdown (a JSON file the run writes next to the document, validated by the server; a malformed one fails the generation rather than losing items), chunked summarising for long transcripts. Prompt version `doc-3`.
- `notify/`: meeting reminders, invitations, knocks while the host is away, "calling you", and "notes are ready", by push and Telegram, with Join buttons.
- `mcpserver/`: `meetings_search`, `meeting_transcript`, behind the same access checks.
- `httpapi/`: the endpoints below; `POST /webhooks/livekit`; the SSE stream carries `meeting.live`, `meeting.ended`, `meeting.knock`, `meeting.calling`, `meeting.notes` to the people concerned.
- `usage/`: the daily meeting counters per workspace.
- `config/`: `AGNTS_LIVEKIT_URL` (the public `wss://` URL clients use), `AGNTS_LIVEKIT_INTERNAL_URL` (`http://livekit:7880`), `AGNTS_LIVEKIT_API_KEY`, `AGNTS_LIVEKIT_API_SECRET`, `AGNTS_TRANSCRIBER_URL`, `AGNTS_MEET_MAX_RECORDINGS`, `AGNTS_MEET_TRANSCRIBE_WORKERS`, `AGNTS_MEET_NOTES_AUDIO` (`mixed` or `per-speaker`). Meetings are off (the menu hidden) when LiveKit isn't configured.

## API

Members (`/api/meetings…`, workspace-scoped):

| Method | Path | What |
| --- | --- | --- |
| `GET` | `/meetings?view=upcoming\|past\|live` | List |
| `POST` | `/meetings` | Create (instant or scheduled), with invitees |
| `GET` / `PATCH` / `DELETE` | `/meetings/{id}` | Read, update, delete |
| `POST` | `/meetings/{id}/cancel` | Cancel a scheduled meeting (sends `METHOD:CANCEL`) |
| `PUT` | `/meetings/{id}/rsvp` | Yes / No / Maybe |
| `POST` | `/meetings/by-code/{code}/join` | Join or knock: `{token, url, role}` or `{knockId}` |
| `GET` | `/meetings/knocks/{knockId}` | Long-poll a knock (25 s): waiting / admitted (with token) / denied |
| `POST` | `/meetings/{id}/knocks/{knockId}/{admit\|deny}` | Decide; `POST …/knocks/admit-all` |
| `POST` | `/meetings/{id}/participants/{identity}/{mute\|remove\|ask-unmute\|lower-hand}` | Host actions (`mute` takes `source`: microphone, camera, screen) |
| `POST` | `/meetings/{id}/{lock\|unlock\|end}` | Host actions |
| `PUT` / `DELETE` | `/meetings/{id}/cohosts/{userId}` | Co-hosts |
| `POST` | `/meetings/{id}/call` | Ring members now |
| `GET` / `POST` | `/meetings/{id}/sessions/{sid}/messages` | Chat |
| `POST` | `/meetings/{id}/{recording\|notes}/{start\|stop}` | Recording and notes |
| `GET` | `/meetings/{id}/sessions` / `/sessions/{sid}` | Past sessions: attendance, media, notes status |
| `GET` | `/meetings/{id}/sessions/{sid}/recordings/{mid}` | Stream (Range) or download a recording |
| `GET` | `/meetings/{id}/sessions/{sid}/transcript?format=json\|txt\|vtt` | Transcript |
| `POST` | `/meetings/{id}/sessions/{sid}/notes/regenerate` | Write the notes again |
| `GET` | `/meetings/{id}/sessions/{sid}/action-items` | Action items with their tickets |
| `POST` | `/meetings/{id}/sessions/{sid}/action-items/{itemId}/ticket` | Action item → ticket (409 when it has one) |

Public (`/api/public/meetings/{code}…`): `GET` (title, host name, whether it is live and whether guests may knock; nothing else), `POST /guest` (name or Google ID token, or an invitee token → guest cookie), `POST /join`, `GET /knocks/{knockId}`, `GET` / `POST /messages` (during the call only). Rate-limited per IP and per guest.

## Clients

### Admin (`apps/admin`)

- Dependency: `livekit-client` (pinned), no UI kit: the call UI is our own components, in the panel's style.
- `pages/MeetingsPage.vue`: Upcoming / Past / Live, New meeting (Start now, Schedule, Get a link).
- `pages/MeetingPage.vue`: a meeting's details, invitees and RSVPs, sessions with attendance, recordings player, transcript, notes link, tickets.
- `pages/MeetingRoomPage.vue` (`/m/:code`, also for guests, outside the panel's chrome): `MeetingLobby.vue` → `MeetingRoom.vue`.
  - `ParticipantTile.vue` (video, name, muted, speaking ring, hand, connection quality), `MeetingGrid.vue` (grid / speaker / share, paging), `MeetingControls.vue` (mic, camera, share, hand, reactions, chat, people, more, leave), `MeetingChat.vue`, `MeetingPeople.vue` (list, knocks, host actions), `MeetingBanner.vue` (recording / notes / locked).
  - `composables/useMeeting.ts`: the LiveKit `Room`, its events, devices, and the agnts calls; the only place that talks to LiveKit, so components stay plain.
- A global `IncomingCall.vue` toast for `meeting.calling` and the reminder, from the SSE stream.
- Caddy: `Permissions-Policy: camera=(self), microphone=(self), display-capture=(self)` on `/m/*` and the panel; CSP adds `media-src 'self' blob:` and the LiveKit `wss:` URL to `connect-src`.

### Mobile (`apps/mobile`)

- Dependency: `livekit_client` (Flutter).
- Meetings list (upcoming, live, past), join by code or link (deep link `/m/<code>`), the call screen (grid / speaker, mic, camera, flip, speaker / earpiece, hand, chat, people with host actions), watching a screen share. Notes and recordings open the document and the player.
- Push: reminders and "calling you" with Join. On Android, a foreground service keeps the call alive in the background; on iOS, background audio. CallKit / ConnectionService ringing is later.

### Translations

`shared/i18n/{en,ru,uz}/meetings.json` and `mmeetings.json`; the `.ics` and emails in the invitee's language when they are a member, the host's otherwise.

## Deploy

`deploy/docker-compose.yml` gains three services (and the CLI's installer generates the keys and opens the ports):

- **`livekit`** (`livekit/livekit-server`, pinned): config from `deploy/livekit.yaml` with keys from `.env`; `rtc.tcp_port: 7881`, `rtc.udp_port: 7882` (one UDP port for all media, easier on firewalls than a range), `use_external_ip: true`, built-in TURN on `3478/udp`; webhook to `http://agnts:8080/webhooks/livekit`; `room.departure_timeout: 120` (how long a room lives after the last person leaves; the default is 20 s), `room.empty_timeout: 120` (a room nobody joined), `room.max_participants` from the setting; Redis for Egress. Published ports: `7881/tcp`, `7882/udp`, `3478/udp`. Signaling goes through Caddy: `handle /rtc* { reverse_proxy livekit:7880 }`, so the client's `wss://<domain>` is the same origin and certificate.
- **`livekit-egress`** (`livekit/egress`, pinned): writes to the `agntsdata` volume under `meetings/` (mounted at the same path in agnts), `cap_add: SYS_ADMIN` as Egress needs for Chrome, CPU limited.
  - **Files agnts can read**: Egress runs as its own user. It runs with `user:` set to agnts's uid and gid (both images fixed to the same ids), `meetings/` is created by agnts with mode `0750`, and agnts checks on start that it can create and read a file there written by Egress's uid, failing loudly otherwise.
  - **Layout template served locally**: by default Egress's Chrome loads its recording layout from LiveKit's hosted site. `template_base` points to the templates built into the egress image (served by the egress container itself), so recording works without internet access and no meeting page is loaded from outside.
  - `cpu_cost.track_cpu_cost` lowered for per-speaker notes (see Notes); the composite and audio-composite costs stay at their defaults.
- **`redis`** (`redis:7-alpine`): only for LiveKit and Egress, on the internal network, not exposed.
- **`transcriber`** (whisper.cpp server, pinned, with the `ggml-small` multilingual model and the Silero VAD model baked into the image): internal only, CPU limited, `AGNTS_TRANSCRIBER_URL=http://transcriber:8090`.
- `.env.example`: `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `AGNTS_LIVEKIT_URL=wss://${AGNTS_DOMAIN}`.
- `deploy/Caddyfile` and `Caddyfile.cloud`: the `/rtc` route and the headers above.
- **Sizing** (in `deploy.md`): the SFU is cheap (a 4-CPU server carries a few 10-person calls); each composite recording takes 2–4 CPU and ~2 GB RAM; transcription of one hour of speech with `small` takes ~10–20 CPU-minutes. The server limits keep runs, recordings and transcription from starving each other.
- **Networks that block UDP** reach the SFU on TCP 7881; networks that also block that need TURN over TLS on 443, which is later (it needs a layer-4 split in front of Caddy).

## Security

- Tokens are minted per join, per room, with the person's rights; nobody gets `roomAdmin`. Removing someone also marks them removed (by person, all devices) so their next `join` is refused for that session.
- The LiveKit API secret only lives in agnts's and LiveKit's environment. Webhooks are verified (JWT + body hash), replay-limited by timestamp and handled once by event id.
- The by-code lookup in the system context returns only the meeting's id and workspace; the public `GET` shows nothing beyond title, host name and state.
- Guest and invitee secrets are hashed; guest cookies are scoped to `/m/` and `/api/public/meetings/`; knocks and guest creation are rate-limited.
- Recordings, audio and transcripts are served only by agnts after an access check, never from a static path. Files are under the workspace's folder (`meetings/<workspace>/<session>/`), paths are built from ids, never from input.
- Chat goes through the secret scan; chat and transcripts are workspace data under row-level security.
- Banners make recording and notes visible to all; the lobby says so before someone joins; the notes document lists the attendees.
- Deleting a workspace deletes its meeting files with it; deleting a user keeps the meetings they attended (attendance keeps the name as it was).

## Phases

Each phase works on its own and is shippable.

1. **Call core.** Compose services, `livekit` adapter (token, client, webhook), meetings and sessions with the sweeper and reconciler, device identities, `Join` for members, the lobby and room UI (grid, speaker, mic, camera, screen share, devices), instant meetings from Meetings. *Done when two members in two browsers on different networks talk and share a screen through `agnts.uz/m/<code>`, and a lobby closed without joining leaves no live session.*
2. **Notes with Muse (mixed audio).** The audio-only room composite egress, the transcriber service and worker, segments without speakers, `gatherMeeting` and `meeting-notes`, the notes document with grants, `meeting_action_items` and action item → ticket, the transcript view. *Done when a 10-minute call in English and one in Russian produce notes with cited times that match the recording within a few seconds, and a ticket made from an action item.*
   - 2b. **Per-speaker notes**: track egress per microphone, the two checks under Notes (timing across mutes, ten microphones on the target server), then `AGNTS_MEET_NOTES_AUDIO=per-speaker`. *Done when the same calls produce notes with correct speaker names.*
3. **Moderation and guests.** Roles and rights, host actions, lock, co-hosts, the waiting room with knocks (members and guests), the public guest page with Google, chat with the secret scan, raise hand and reactions.
4. **Scheduling.** Scheduled meetings, invitees, `.ics` emails and updates, RSVP, reminders, ringing, Upcoming, the dashboard's live badge, ticket ↔ meeting links.
5. **Recording.** Composite egress, limits and quota, the banner, the player with Range, retention sweep, downloads; timestamps in notes open the recording.
6. **Mobile and MCP.** The Flutter call screen and lists, pushes with Join, background audio; `meetings_search` and `meeting_transcript` for the assistant and runs.

For the hackathon demo, phases 1 and 2 are the story: a call, then Muse turning it into decisions and tickets that agnts then codes. Phase 2b and the rest come after Oct 30. Usage counters land with phase 1 (attendance) and grow with each phase.

## Tests

- `domain`: codes (generate, parse, reject), `Rights` for every role and setting, the join decision table (access × membership × invited × guests × locked × full × removed).
- `livekit`: token claims and expiry against LiveKit's format; webhook verification (good, wrong secret, changed body, old timestamp); client requests against recorded fixtures.
- `meetings`: join / knock / refuse; who can admit when the host is away; one live session per meeting under concurrent joins; a session nobody connected to is swept and the next join opens a new one; the reconciler closes a session LiveKit no longer has; session end from `room_finished` stops egress and queues notes; a repeated or out-of-order webhook changes nothing twice; two devices of one person are two connections and one person; an admitted person rejoins without knocking, a removed one (all devices) can't; an email invitee's token joins without knocking, a revoked one knocks; mute / remove refused for members; chat with a secret refused; `.ics` output (golden files, folding, escaping, `SEQUENCE`, `CANCEL`); reminders sent once.
- `notes`: segment merge across people and rejoins (absolute times, overlap), times from Ogg granule positions on a file with a muted stretch, `.vtt` output, a failed transcription marks the session failed with the reason and Regenerate retries, notes off and on in one session make one transcript, action items stored from the structured result (a malformed one fails), Regenerate keeps items that have tickets, a second "Create ticket" on an item is a 409.
- `store`: row-level security on every new table (another workspace's rows are invisible), the by-code lookup across workspaces, the transcript search, the queue claim with `SKIP LOCKED`, daily usage counters.
- `orchestrator`: the `meeting` source's prompt (golden), chunking above the limit.
- Admin: `useMeeting` against a fake `Room`; the lobby, controls and people panel with each role; the guest page's knock flow.
- End to end (manual checklist in `deploy.md`, and a Playwright run with fake media devices, `--use-fake-device-for-media-stream`): two members, a guest admitted, screen share, chat, recording, notes produced.

## Later

- Live captions (streaming transcription into the call) and live notes.
- End-to-end encrypted meetings (LiveKit E2EE), which turn off recording and notes.
- TURN over TLS on 443 for networks that block everything else.
- Recurring meetings; Google / Outlook calendar sync and reading RSVP replies.
- Breakout rooms, polls, a shared whiteboard, background blur.
- Screen sharing from the phone; CallKit and ConnectionService ringing.
- More than one LiveKit node (Redis is already there) and cloud storage for recordings.
- Joining a ticket's discussion as a call ("Talk about this ticket") with the ticket on screen and its notes linked back.

## Decisions to confirm

- **whisper.cpp `small` on the CPU** for transcription: free, private, good for English and Russian, weaker for Uzbek. The `Transcriber` interface allows a hosted speech-to-text engine later if Uzbek isn't good enough.
- **Hand-rolled LiveKit client** instead of `server-sdk-go`: about ten calls, keeps the dependency tree small, and matches `google/`. Switch if the calls grow.
- **Chat through agnts**, not LiveKit's own chat, so it is stored, scanned and readable after the call.
- **Notes off by default**; the host turns them on (or sets the meeting to). Recording off by default.
- **Mixed audio first, per-speaker after it is proven**: the demo gets right times and no speaker names, rather than names with times that may drift.
- **Ticket assignees** (an agnts member on a ticket) are not part of this plan; action items keep who said they'd do it as text until they exist.
