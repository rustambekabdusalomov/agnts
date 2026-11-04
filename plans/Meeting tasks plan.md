# agnts Meeting tasks — Plan

Nov 4, 2026 · v1, implemented (server and admin panel)

> **Status.** A and B are built and tested on the server and in the admin panel. Mobile is left for later: it keeps the one-click "Create ticket", and its ARB dictionaries were not regenerated (`make gen-dart gen-arb` brings the new fields and strings when mobile is done). Where the build differs from the text below:
> - **A member picked by hand** is recorded (`who_set_by`); a later match never replaces it, and a rewrite keeps its draft.
> - **Untouched drafts are dropped when the rewrite is asked for** (`RegenerateNotes`), not when it ends: their items forget they were drafted, so if the rewrite fails the old items are drafted again. A draft deleted by hand is not made again (`drafted`).
> - **The sound step streams the upload onto the box's disk** (`ai.StreamWriter`, Docker's archive API) instead of mounting it; ffmpeg keeps the first audio track (`-map 0:a:0`). A file with no audio fails its notes with "the recording has no sound".
> - **An upload's people** can read its session and notes and are the near candidates for matching; the session's length is set from its sound once heard.
> - Not verified end to end on a server: a real upload heard by Muse (needs the rebuilt run image with ffmpeg, as notes already do, and Muse reachable from prod).

## Overview

When someone takes a task in a meeting ("I'll fix the login page by Friday — Aziza"), the notes generation already writes it as an **action item** with the person's name as it was said. Today that is where it stops: someone clicks each item to make a ticket, and the ticket belongs to nobody.

This plan closes the loop and adds a second way in:

- **A. Draft tickets on the right member.** Every action item becomes a **draft ticket** (held: nothing runs until someone starts it) as soon as the notes are written, assigned to the **workspace member** who took it.
- **B. Uploaded recordings.** A host can upload a recording of a meeting held elsewhere (a video or audio file). agnts keeps **only its sound**, hears it like a call's audio, and writes the same notes, action items and drafts. For now only what people said is analysed: the picture is thrown away before anything reads it.

## A. Draft tickets on the right member

### Who took the task

- The notes generation writes, per action item, `who` (the person, as named) and a new `speaker` (who said the line where the task was taken, as the transcript names them). `speaker` is asked for only when the transcript says who spoke (notes per speaker); with everyone's audio together it is left out, since it would be a guess.
- The server matches `who` (else `speaker`, when `who` is "I", "me", "men", "я" or empty) to an account:
  1. the **people of the session**: attendees who are members, the meeting's invitees with an account, its host and co-hosts, and for an uploaded recording the people the uploader said are in it;
  2. else **the whole workspace**, but only when exactly one member matches.
- Matching compares names folded the same way: lower case, accents and apostrophes (oʻ, gʻ, ʼ) dropped, **Cyrillic written in Latin** (Азиза → aziza, Шохрух → shohruh), so a name Muse wrote in either alphabet matches. A spoken name matches a member when it equals the full name, the first name, or a word of the full name, or is one edit away from one of those for names of five letters or more.
- No match, or two people match: the item stays **unassigned** and keeps the name as said.
- The match is stored on the item (`who_user_id`); the session page can change it.

### The draft ticket

- When a notes generation ends **done**, each new action item becomes a ticket: title the item's text, description what / who / when / the quote with its time / a link to the notes (as the button makes today), `Start: queue` so it is **held**, linked to the meeting.
- The matched member becomes the ticket's **member** (`SetMember`). In per-member Claude mode that is whose account its runs use; the ticket is held, so nothing runs on it until someone starts it, and its history says it was "assigned from the meeting".
- The ticket's creator is the person who turned the notes on (else the host); its origin is `system`.
- The workspace setting `meetings.draftTickets` (on by default) turns this off; the button stays for each item either way.

### Notes written again

- Today a rewrite keeps the items that have a ticket only when their text matches the new item exactly, and adds the rest: every rewrite would add a second set of drafts.
- Instead, before the new items are stored, drafts **nobody touched** (still held and new, not edited since they were made) are deleted with their items; items whose ticket someone has worked on stay, and a new item with the same quote or the same time (within 30 s) as a kept one is dropped.

### Admin panel

- Each action item shows its ticket, its member (or "unassigned · as said: X"), and a member picker to change it; changing it changes the ticket's member too.

## B. Uploaded recordings

### Upload

- `POST /meetings/{meetingId}/uploads`, multipart: `file`, `startedAt` (optional, when the meeting happened), `people` (member ids in the recording, optional). Hosts only. Video (mp4, mov, webm, mkv) or audio (ogg, opus, m4a, mp3, wav), up to 2 GB (`AGNTS_MEET_MAX_UPLOAD_MB`).
- The file is streamed to the meetings directory, never held in memory, and a session is made for it: **ended**, marked `uploaded`, no room, no attendance, notes on, with the file as its audio (`upload` media). It goes into the same notes queue as a call.

### Only the sound

- The server image has no ffmpeg, and hearing reads its whole input into memory. So the upload first goes through a small **audio step**: a short-lived box from the run image gets the file streamed onto its disk and runs `ffmpeg -map 0:a:0 -vn -ac 1 -c:a libopus -b:a 24k` into an Ogg (about 11 MB an hour). The picture never leaves that box.
- The video is deleted as soon as the Ogg is written; then the Ogg is heard like a call's mixed audio, and removed after hearing unless the workspace keeps audio.
- With one mixed track the transcript does not say who spoke; the people the uploader picked go to the notes as "who is in the recording" and are the first candidates for matching.

### Admin panel

- "Upload recording" on the meeting page: the file, when it happened, who is in it; a progress bar, then the session with its notes status (Transcribing → Writing → Done) as for a call.

## Data

- `meeting_action_items`: `who_user_id bigint REFERENCES users ON DELETE SET NULL`, `speaker text`.
- `meeting_sessions`: `uploaded boolean NOT NULL DEFAULT false`, `people bigint[] NOT NULL DEFAULT '{}'`.
- `meeting_media.kind`: new `upload`.

## Not now

- Mobile: shows the drafts as tickets but has no member picker or upload.
- Anything from the picture (slides, screen shares, faces): only the sound is analysed.
- Recognising people by their voice.
