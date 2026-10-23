# agnts Slides — Plan

Oct 22, 2026 · v1, built (not yet tested by hand in the running app)

## Overview

A **slide deck** is a second kind of document. Pages (what Documents has today) are for the team: long, detailed, technical. Decks are for clients, managers and anyone who wants the short version: one idea per slide, few words, no code dumps. Developers can use them too; nothing stops anyone.

A deck is **not a separate entity**. It is a row in `documents` with `kind = 'slides'`, so it gets everything a page has without a second copy of the rules: `EffectiveAccess`, grants, workspace access, the viewer cap, public links and the secret scan, versions with 409 and restore, the trash, ticket links, hand-over when a member leaves, generations, spend and credits, per-person events, Markdown and PDF downloads with the export cache.

The main new path is **"Make slides" from a page**: agnts reads the page and writes a deck as a **new, separate document** that remembers what it was made from. The deck has its own sharing, so a client can get the public link to the deck while the team's page stays private.

## Rules

### Kind

- `kind` is `page` (default) or `slides`, chosen when the document is created and **never changed**. Turning a page into a deck is "Make slides", which makes a new document.
- Every existing rule applies to both kinds unchanged.

### The text of a deck

- Still Markdown, so versions, compare, the secret scan, the 200 KB limit and the `.md` download keep working.
- Slides are separated by a line that is exactly `---` (spaces around it allowed), outside code fences. Empty slides are dropped. This is the Marp convention, so the `.md` file opens in Marp and similar tools.
- **Speaker notes**: on a slide, a line `Notes:` (any case) starts the notes; everything after it on that slide is notes, not shown on the slide.
- One splitter rule, implemented three times and table-tested in each: `domain.SplitSlides` (Go, for the PDF), `slides.ts` (admin), `slides.dart` (mobile).
- **Layout** is chosen from the content, the same way everywhere:
  - a slide made only of headings and at most two short paragraphs is a **lead** slide (centered, large), like a title or a section break;
  - a slide with a lot of text gets a smaller font (`dense`, `denser`) by a weight of its lines and characters, so text fits without scripts. The PDF prints with scripts off, so this can't depend on measuring.
- There are no themes, images or positioned elements in v1: slides are Markdown on a clean 16:9 layout.

### Making slides

- **From a page** (new source kind `document`): needs **View** on the page. The source records the page's id and the version read (`documentVersion`, 0 meaning the current one, which the server pins when it queues the run).
  - Only pages can be the source of a `document` source; a deck can't be made from a deck. The `document` source only makes decks.
  - The page's **linked tickets** are linked to the deck too, as reports link their ticket.
  - **Regenerate** reads the page again at its **current** version, and checks the person's View access on the page again. A page that was deleted or that they can no longer open makes it fail with "the source document is gone".
- **From the other sources** (report, tickets, commits, pull requests, repository): a deck can be generated from any of them, with the same formats (status report, release notes, …) written as slides.
- **By hand**: Blank deck, edited in the textarea like a page.
- New format `presentation` ("Presentation of the document"), the default for the `document` source.
- The deck prompt: a title slide first (the title and one line of subtitle), then about 6–15 slides, one idea each, at most ~6 bullets of a few words, a summary or next steps at the end. Citations of tickets, shas and pull requests stay, short. Speaker notes for details that don't fit. No tables wider than 4 columns, no code blocks unless the audience is developers.
- Prompt version goes to `doc-2`.

### Where a deck came from

- The deck stores `derived_from_id` and `derived_from_version`: the page and the version its **current AI version** was made from (set when a `document` generation finishes).
- The deck page shows "Made from *Sprint 42 report* v7" with a link, and "The document has changed since (now v9) — Regenerate" when the page moved on. **Only when the reader can open the page**: otherwise nothing is shown, so the page's title doesn't leak.
- The page shows **"Slides made from this document"**: the decks with `derived_from_id` = the page **that the reader can open**.
- Nothing updates on its own, as with freshness today.
- Deleting the page doesn't delete its decks. When the page is purged, `derived_from_id` becomes NULL.

### Viewing and presenting

- **Admin, deck page**: the slides one under the other as 16:9 frames, each with its notes under it; a **Present** button.
- **Present mode** (admin and the public page): fullscreen, one slide at a time. → / Space / PageDown / click next, ← / PageUp previous, Home / End, Esc leaves. Swipe on touch screens. A slide counter. Signed-in people can show the notes with N; the public page has no notes.
- **Editor**: the same textarea, with the preview drawn as slides.
- **Public page** `/d/<token>`: the slides and Present. No notes.
- **Mobile**: a deck reads as a column of 16:9 slides; "Present" opens a full-screen swipeable view. Making and editing decks is on the web, as for pages.

### Downloading

- **PDF**: 16:9 landscape (254 × 142.875 mm), one slide per page, the slide number in the corner, no notes. Same Chromium job, same cache. The print page says its layout (`<meta name="agnts-layout" content="slides">`) and the print script picks the page size from it.
- **Markdown**: the deck's text as is (slides, separators and notes), without the `# title` heading pages get, since the title slide is part of the deck. **The public `.md` download leaves the notes out**, as the public page does.

## Data

`migrations/00062_slides.sql`:

```sql
ALTER TABLE documents
  ADD COLUMN kind text NOT NULL DEFAULT 'page' CHECK (kind IN ('page', 'slides')),
  ADD COLUMN derived_from_id bigint REFERENCES documents (id) ON DELETE SET NULL,
  ADD COLUMN derived_from_version integer;
CREATE INDEX documents_derived_idx ON documents (derived_from_id) WHERE derived_from_id IS NOT NULL;
```

The source (`documents.source`, `document_runs.source`) gains `documentId` and `documentVersion`.

## Code

- `domain/document.go`: `DocumentKind`, `SourceDocument`, `TemplatePresentation`, `Document.Kind/DerivedFromID/DerivedFromVersion`, source validation.
- `domain/slides.go`: `SplitSlides`, `Slide{Body, Notes, Layout}`, `SlidesWithoutNotes`. Table-tested.
- `store/postgres/documents.go`: the new columns; `DocumentFilter.Kind` and `.DerivedFrom`; `FinishDocumentRun` sets `derived_from_*`; `PublicDocument` returns the kind.
- `documents/documents.go`: create with a kind; `document` source checks (View on the page, the page is a page, pin the version); `Regenerate` re-pins and re-checks; `View.From` (the source page as the reader may see it).
- `documents/export.go`: `PrintSlidesHTML`, Markdown file per kind, the public `.md` without notes.
- `orchestrator/documents.go`: `gatherDocument` for the `document` source (the page's version and its tickets), the slides guide in the prompt, `presentation` format.
- `orchestrator/document_pdf.mjs`: page size from the meta tag.
- API: `kind` on summaries, input and public documents; `derivedFrom` on documents; `kind` and `derivedFrom` filters on the list; `document` in the source's kinds with `documentId` and `documentVersion`; `presentation` in the formats.
- Admin: `SlideDeck.vue` (slides as frames), `PresentMode.vue`, `slides.ts`; the kind in the New drawer, the Document source with a page picker, "Make slides" on pages, "Slides made from this document", the kind filter and badge in the list; the public page.
- Mobile: kind badge, `slides.dart`, the deck view and present screen.
- Translations in `shared/i18n/{en,ru,uz}/documents.json` and `mdocuments.json`.

## Tests

- `SplitSlides`: separators, `---` inside a code fence, leading and trailing separators, empty slides, notes, lead and dense layouts. The same cases in `slides.ts` and `slides.dart`.
- Service: making slides from a page needs View on it (404 otherwise); a deck can't be the source; a page's tickets are linked; Regenerate re-pins the current version and fails once the page is gone; `From` is empty for someone who can't open the page; the kind can't be changed by a save.
- Store: `derived_from_*` is set when a `document` generation finishes; the `derivedFrom` list only returns what the reader can open.
- Export: a deck's PDF page is landscape with one section per slide and no notes; the public `.md` has no notes.

## Later

- Themes and workspace branding (logo, colours) on decks.
- Images in slides, from the document's own attachments.
- `.pptx` export.
- Presenter view on a second screen (current + next slide, timer).
- Keeping a deck in step with its page automatically.
