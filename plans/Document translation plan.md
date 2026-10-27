# agnts Document translation — Plan

Oct 27, 2026 · v1.0, built

## Overview

A document or slide deck can be read in another language, the same way a ticket can: a **Translate** picker on the document page and on the phone. Choosing a language shows the title and the text translated; "Original" goes back. The translation can also be downloaded as Markdown or PDF.

It reuses what tickets already have: the `translations` store (one row per text and language, keyed by the text's SHA-256), the `translate` prompt, and the one-run-per-subject-and-language singleflight. Since texts are stored by hash, a new version only sends the paragraphs that changed, and a text already translated for a ticket isn't sent again.

Decisions taken with the user (Oct 26):
- **The translated view is read-only for comments.** Highlights and the "Comment" popup are hidden; the comments panel stays readable and says "Switch to the original to comment".
- **Members only.** Anyone with View access or more (workspace viewers too, `x-viewer`) can translate. The public page and guests can't. Each new text uses the workspace's Claude plan.
- **Downloadable.** The download menu offers Markdown and PDF of the language being read.
- **Admin and phone ship together.**

## Rules

### What is translated

- The **title** and the **body** of a version, cut into **segments**, each translated on its own and stored by its hash:
  - A page: one segment per block. Blocks are split by blank lines, so a paragraph, a heading, a list or a table is one segment.
  - A deck: split into slides first (`domain.SplitSlides`), then each slide's body into blocks as above. Speaker notes are one segment per slide, without their `Notes:` marker.
- **Kept as written, never sent**: fenced code blocks, Marp front matter, the `---` lines between slides, the `Notes:` marker, blocks holding only an image, a link or a URL, and blank lines.
- The translated body is built back from the same pieces in the same order, with the original separators. So the same Markdown renderer, slide layout (`slideLayout` runs on the translated text) and PDF printer work on it unchanged.
- A segment Claude didn't return stays as written, so the page never shows less than the original (as with tickets).

### When it's translated

- On request: choosing a language asks the server, which answers from the store and translates whatever is missing in that request (about a minute for a long document the first time).
- One run per document, version and language at a time. A second request waits for the first. The run keeps going if the client gives up, so its work is stored anyway.
- **Batches**: the missing segments go to Claude in runs of up to 40 KB of text each, one after another, within the same request. A 200 KB document is about five runs the first time and a few seconds after that.
- The page remembers the language chosen for each document (`prefs.translations["doc:<id>"]`, beside the tickets' keys). A new version asks again; the previous translation stays on screen until the new one arrives.
- Reading an older version (the versions drawer) shows it as written. Translation is for the current version only in the UI. The API takes `version` for the download.
- Editing always shows the original. Opening the editor while translated switches the view back and keeps the language for after the save.
- Plan limit reached: `429 plan_limit` and the page shows "The Claude plan limit is reached; try again after it resets", as on tickets.
- A document agnts is writing for the first time (no version yet) answers `409` (`ErrBusy`). One being rewritten translates its current version.

### Downloads

- `GET /documents/{id}/download?format=md|pdf&version=&lang=`. Without `lang` it's the original, as today.
- With `lang`, the version's translation is built from the store, and any missing segments are translated first (the same call as above). In practice the menu only offers it once the translation is on screen, so it's already stored.
- **Markdown**: the translated title and body, file name `<title>.<lang>.md`.
- **PDF**: made and kept per version, format and language, like today's PDFs (first download `202` + `Retry-After`). `PrintHTML`/`PrintSlidesHTML` get the language for `<html lang>` and `dir="rtl"` for Arabic.
- While a language is chosen, the page's two download buttons fetch the translation and say so ("Markdown · Русский"). The versions drawer always downloads as written.

### Spend

- Each run is a `translate` call recorded like the ticket ones, with the document as its subject: `transcriptMeta{Purpose: translate, Subject: "document <id> <lang>"}`, no ticket. It shows under Usage with the other translations. No credits are charged, as with tickets.

## Data

`migrations/00065_document_translations.sql`:

```sql
-- A PDF is kept per version, format and language; '' is the original.
ALTER TABLE document_exports ADD COLUMN lang text NOT NULL DEFAULT '';
ALTER TABLE document_exports DROP CONSTRAINT document_exports_pkey,
  ADD PRIMARY KEY (document_id, version, format, lang);
```

Translated texts go in the existing `translations` table: nothing new. Its comment changes from "ticket texts" to "texts of tickets and documents". Translations aren't deleted with a document. Like the ticket ones, they're keyed by text and not by owner, and they don't say which document they came from.

## API

| Method | Path | Who |
|---|---|---|
| POST | `/documents/{id}/translate` | View (`x-viewer`); `{lang}`; answers `DocumentTranslation` |
| GET | `/documents/{id}/download` | View; gains `lang` |

`DocumentTranslation`: `{lang, version, title, body, complete}`. `body` is the rebuilt Markdown, ready for the same renderer. `complete` is false when some segments came back untranslated.

The answer is the whole translated body, not ticket-style `items`. A document has one text to render, not many components each looking up its own strings, and the PDF and Markdown downloads need the same rebuilt body on the server anyway.

Errors: `400` unknown language, `404` no access, `409` being written, `429 plan_limit`.

## Code

### Server

- `domain/translate.go` (new, beside `translation.go`): `Segment{Text string; Translate bool}`, `SegmentDocument(kind, body) []Segment`, `JoinSegments([]Segment, map[string]string) string`. Pure functions, used by the service and tested on their own.
- `orchestrator/translate.go`: pull out the store-then-Claude part of `Translate` into `TranslateTexts(ctx, subject, lang string, texts []string) (map[string]string, error)`. It handles singleflight on `subject+lang`, the 40 KB batches, and storing. `Translate` (tickets) calls it with `ticketTexts(v)`, so behaviour stays the same. `transcriptMeta` takes the subject, and `TicketKey` is set only for tickets.
- `orchestrator/prompts.go`: the `translate` prompt says "texts from a ticket or a document of a software team" and adds a rule: "a text is one Markdown block; return it as one block, never split or merge texts".
- `documents/translate.go` (new): `Translator` interface (`TranslateTexts`) in `Deps`, nil disables it. `Service.Translate(ctx, c, id, lang)` checks View access with `need`, refuses while a run is writing, segments the current version, asks the translator for the title and segments, and joins them. The subject is `document:<id>@<version>`.
- `documents/export.go`: `Download` and `file` take `lang`. `render` prints the translated body. The export store calls (`DocumentExport`, `StartDocumentExport`, `FinishDocumentExport`) gain `lang`.
- `store/postgres/documents.go`: the export queries with `lang`.
- `httpapi/documents.go`: `TranslateDocument`, the `lang` parameter on download, and `documentError` maps `ErrPlanLimit` to 429 and `orchestrator.ErrInvalid` to 400.
- `cmd/agnts/serve.go`: pass the orchestrator as `documents.Deps.Translator`.
- `shared/openapi/openapi.yaml`: the route, `DocumentTranslation`, `lang` on download, reusing `TranslationLanguage`. Regenerate the Go server, the admin's `schema.gen.ts` and the Dart client.

### Admin

- `composables/useTranslation.ts`: export the language list and the remembered-language helper (`useRememberedLang(prefKey)`), so tickets and documents share them. Add `useDocumentTranslation(id, version)`, a `useQuery` on `POST /documents/{id}/translate` with the same `placeholderData` trick.
- `pages/DocumentPage.vue`: the Translate `InputSelect` in the header (the UI language first, then the rest, as on `TicketPage.vue`), the "Translating…" note and the error. While translated, the page renders `translation.body` in `ReportView`/`SlideDeck` and `translation.title` in the header, and `CommentableText` gets `can-comment=false` and no threads. Present mode shows the translated deck.
- `components/documents/CommentsPanel.vue`: a `translated` prop that hides the composer and shows "Switch to the original to comment" with a button that does it.
- `components/documents/DownloadMenu.vue`: a `langLabel` prop naming the language on both buttons.
- i18n (`en`, `ru`, `uz` `documents.json`, shared with the phone): `translate`, `translateOriginal`, `translating`, `translateFailed`, `translatedNoComments`, `showOriginal`, `translatedIncomplete`.

### Phone

- `features/tickets/translation.dart`: the language picker and its remembered choice are reused as they are, keyed `doc:<id>` for a document; `TranslationStatus` takes any request state.
- `features/documents/document_screen.dart`: the Translate button in the top bar. While translated, it shows the translated title and body in the same Markdown and `slide_deck.dart` views, and Present shows the translated deck. The language is remembered per document in `shared_preferences` (`translate:doc:<id>`).
- `features/documents/document_download.dart`: the translated Markdown and PDF while a language is chosen.
- ARB strings generated from the shared dictionaries (`make gen-arb`).

## Tests

- `domain/translate_test.go`:
  - A page splits into blocks, with code fences, images and blank lines kept.
  - A deck keeps `---`, front matter and the `Notes:` marker, and translates the notes.
  - Join with every segment translated, with some missing (they stay as written), and with none.
  - Join then `SplitSlides` gives the same number of slides with notes in place.
  - A block repeated twice is sent once.
- `orchestrator/translate_test.go`:
  - Tickets behave as before.
  - `TranslateTexts` sends only missing texts, batches past 40 KB, and stores everything.
  - Two concurrent requests for the same subject and language make one run.
  - The plan limit is returned as `ErrPlanLimit`.
- `documents/translate_test.go`:
  - No access gives 404 and a workspace viewer can translate.
  - Refused while being written.
  - A new version sends only the changed blocks.
  - Translated Markdown download has the translated title and body.
  - The PDF is kept per language and the original's PDF is unaffected.
- API: the route is in `x-viewer`, `lang` on download is validated, and public routes have no translate.
- Not done: no admin unit test for the document translation composable; the page was checked by typecheck and lint only.

## Later

- Translation on the public page for guests, with a per-link switch and a rate limit.
- Side-by-side original and translation, with comments on the original column.
- Translating older versions in the versions drawer.
- Publishing a translation as its own document (a copy in the language, linked to the source like slides made from a page).
- Translating comments.
