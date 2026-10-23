# agnts Document comments and viewers — Plan

Oct 23, 2026 · v1.1, built (signed-in readers join without a form; name first, Google optional)

## Overview

Three additions to documents and slide decks:

1. **Comments on selected text.** Select words on a page or a slide, write a comment. Others reply, and the thread is resolved when it's dealt with.
2. **Guests on public links.** Someone who opens a public link and isn't signed in to agnts types their name and enters; "Continue with Google" is offered below for those who want it. Someone signed in to agnts isn't asked: their account says who they are. Then they read, comment and reply like a member.
3. **Viewing now.** Everyone on a document sees who else has it open, members and guests.

Decisions taken with the user (Oct 23):
- On a public link, **guests see everything**: every comment with its author's name and everyone viewing now. Before a member comments on a public document, the composer says guests can read it.
- **View access is enough to comment**, as Google Docs' "commenter". Edit isn't needed. Workspace viewers can comment too.

## Rules

### Comments

- A **thread** starts on a selection: the quoted text, a little text before and after it (to tell repeated words apart), and for a deck the slide it's on. Replies have no selection.
- **Anchoring**: the quote is found again in the rendered text each time the document is shown, using the text before and after it when it appears more than once. When an edit removed the quote, the thread stays in the list marked "The text it was on has changed", with its quote shown, and highlights nothing.
- **Who can do what**:

| | Member with View or more | Guest on a public link |
|---|---|---|
| Read comments | yes | yes |
| Start a thread, reply | yes | yes |
| Edit or delete a comment | their own | their own |
| Resolve or reopen a thread | the thread's author, Edit access or more | their own threads |
| Delete any comment | the document's owner and the workspace owner | — |

- Deleting a thread's first comment deletes its replies.
- Resolved threads are hidden from the text and folded at the end of the list.
- Limits: 5,000 characters per comment, 1,000 for a quote, 200 open threads per document. Guests may post 10 comments a minute.
- Comments aren't versions: they don't change the text, the version or the PDF. They're kept when the text changes, and deleted with the document.
- A comment shows its author's name as it was when written, and "guest" for guests (with "via Google" when Google vouched for them).

### Guests

- Opening a public link while **signed in to agnts** joins at once as that account (its name and email, marked "signed in"). No form, no question (Oct 23: "just ask name from unauthorized users").
- Anyone else is asked **"Who are you?"**: a name (2–60 characters) and **Enter**. Below it, optionally, **Continue with Google**, which takes the name and email from Google. Nobody is required to authorize. Nothing is shown before that: the API doesn't return the text, comments or downloads of a public document without a guest.
- A guest records how they joined (`via`: `name`, `google`, `account`). Badges: "guest", "guest via Google", "signed in". One person signed in on the document page and on its public link counts as one viewer.
- A guest is a row of that document. Its secret token (32 random bytes, kept as a SHA-256 hash) lives in the browser's local storage for that link and goes with each request as `X-Guest-Token`. The guest stays the same person on later visits from that browser.
- A guest only works while the document is public. Turning it private, resetting the link, deleting it, or turning public documents off in Settings ends every guest's access at once, since the token of the link is checked first.
- Guests have no account and can't sign in anywhere else; Google sign-in here never creates an account.
- Members see guests marked "guest" on comments and in the viewer list, with their email when Google gave one.
- Name-only guests are not verified: anyone can type any name. The badge says "guest", and the Google ones say "via Google".

### Viewing now

- The document page, the deck page and the public page tell the server every 10 seconds that the person is still there, and once more when they leave. Whoever hasn't been heard from for 30 seconds is gone.
- The answer is the list of people viewing now (members by their name, guests by their name and badge), and when the comments last changed. The page refetches the comments when that moves, so guests see new comments within 10 seconds without the event stream. Members also get a `document_comments` event at once.
- The list is kept in the server's memory: there's one agnts server. With several servers it would need the database or Redis (Later).
- On a public document everyone on it, members and guests, is in the same list.

## Data

`migrations/00063_document_comments.sql`:

```sql
CREATE TABLE document_guests (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id  bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  name         text        NOT NULL,
  email        text        NOT NULL DEFAULT '',     -- set when Google or an account vouched for them
  via          text        NOT NULL DEFAULT 'name' CHECK (via IN ('name', 'google', 'account')),
  user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,  -- via an account
  token_hash   bytea       NOT NULL UNIQUE,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE document_comments (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id     bigint      NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  parent_id       bigint      REFERENCES document_comments (id) ON DELETE CASCADE,  -- a reply
  author_user_id  bigint      REFERENCES users (id) ON DELETE SET NULL,
  author_guest_id bigint      REFERENCES document_guests (id) ON DELETE SET NULL,
  author_name     text        NOT NULL,
  body            text        NOT NULL,
  quote           text        NOT NULL DEFAULT '',
  prefix          text        NOT NULL DEFAULT '',
  suffix          text        NOT NULL DEFAULT '',
  slide           integer,                              -- a deck's slide, from 0
  version         integer     NOT NULL,                 -- the document's version when written
  resolved_at     timestamptz,
  resolved_by     text        NOT NULL DEFAULT '',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  CHECK (author_user_id IS NULL OR author_guest_id IS NULL)
);
CREATE INDEX document_comments_doc_idx ON document_comments (document_id, created_at);
```

Both with the workspace isolation policy. Guest lookups by token run as system work, then act in the document's workspace.

## API

| Method | Path | Who |
|---|---|---|
| GET | `/documents/{id}/comments` | View |
| POST | `/documents/{id}/comments` | View (`x-viewer`) |
| PATCH | `/documents/{id}/comments/{cid}` | body: author; resolved: see the table |
| DELETE | `/documents/{id}/comments/{cid}` | author, document owner |
| POST | `/documents/{id}/presence` | View; `{leaving}`; answers viewers and `commentsAt` |
| GET | `/public/documents/{token}/info` | anyone: kind, title, whether Google is on (its client id) |
| POST | `/public/documents/{token}/guest` | `{name}`, `{googleCredential}`, or `{}` with an agnts session; answers the guest and its token |
| GET | `/public/documents/{token}` | now needs `X-Guest-Token` |
| GET | `/public/documents/{token}/download` | now needs `X-Guest-Token` |
| GET, POST | `/public/documents/{token}/comments` | guest |
| PATCH, DELETE | `/public/documents/{token}/comments/{cid}` | guest, their own |
| POST | `/public/documents/{token}/presence` | guest |

All public routes keep the per-address rate limit, `noindex` and `no-referrer`.

## Code

- `domain/comment.go`: `DocumentComment`, `DocumentGuest`, `Viewer`, limits, `CleanComment`, `CleanGuestName`, `GuestToken` and its hash.
- `store/postgres/document_comments.go`: comments and guests.
- `documents/comments.go`: the rules above for members and guests; `documents/presence.go`: the in-memory list.
- `httpapi/document_comments.go`; the guest token is read by the public handlers.
- Admin: `anchors.ts` (selection → anchor, anchor → range, highlights) with tests; `CommentsPanel.vue`, `ViewersBar.vue`, `useComments.ts`; the document page, the deck view and the public page with its "Who are you?" gate (`GuestGate.vue`, using Google's button in callback mode).

## Tests

- Domain: names and bodies cleaned and limited; tokens hashed.
- Service: View can comment, no access is 404; a viewer can comment; only the author edits; resolve rules; the owner deletes anything; guests only on a public document, and not after it goes private or its link is reset; guests edit only their own; the rate limit.
- Presence: joins, refreshes, leaves, expires after 30 seconds; a guest and a member on the same document.
- API: the public text needs a guest; the info route needs none and returns no text.
- `anchors.ts`: finds a quote, uses the text around it for a repeated quote, reports a missing one.

## Later

- Comments and viewers on the phone (read and reply).
- Email or push to the document's owner on new comments and replies; @mentions.
- Suggestions (proposed text changes) on top of comments.
- Presence across several servers.
- A per-document switch for guest comments.
