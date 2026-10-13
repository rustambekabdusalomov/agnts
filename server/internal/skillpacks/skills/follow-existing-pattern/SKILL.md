---
name: agnts-method-follow-existing-pattern
description: Use when the change adds one more of something the repository already has several of, such as an integration or provider, an API endpoint, a handler, a page, a CLI command, a background job or a migration. Shows how to build it in the shape the existing ones use and wire it everywhere they are wired.
---

# Follow the existing pattern

The new piece should look like it was always part of this code base. Its siblings are the specification; vendor docs and general practice come second.

## 1. Find the two closest siblings

- Search for the things of the same kind: `rg -l` for the registration call, the interface they implement, the route prefix, the directory they live in.
- Pick the two most similar to what the ticket asks for (same transport, same kind of data, same auth).
- When they differ in shape, check which is newer (`git log -1 --format=%cs -- <path>`). The newer one usually shows where the repository is heading; follow it unless the brief says otherwise.

## 2. Map what they have

Write down, for yourself, each of these that the siblings have:

- file layout and names
- configuration and its validation (env vars, settings structs, config files)
- auth and secrets handling
- error handling: which errors are returned, wrapped, logged, shown to users
- retries, timeouts, pagination, rate limits
- registration: routers, registries, dependency injection, menus, feature flags, OpenAPI or other contracts, i18n keys, permissions
- tests: where they live, what they cover, which fakes and fixtures they use
- docs, changelogs or examples the repository updates for each new one

## 3. Build it in the same layers

- Same layers, same names, same order. Do not add a layer the siblings do not have, and do not skip one they have.
- Wire every registration point from your list. A handler no router reaches, a provider no registry lists or a page no menu links is unfinished work.
- Write the tests the siblings have, in their style, with their fakes.

## 4. Things to avoid

- **A second architecture.** If the ticket truly needs a different shape (a streaming API among request/response ones), keep the parts that still apply and explain the difference in your design notes.
- **Copying bugs.** Reuse the structure, not the defects. If a sibling has a bug (an unchecked error, a missing timeout), do it right in the new one and mention the sibling's defect in your summary instead of fixing it outside the ticket's scope.
- **Copying dead code.** Leave out options, branches and TODOs the new piece does not need.

## Before you finish

Compare the new piece with its closest sibling, file by file. Every difference should be one the ticket asked for.
