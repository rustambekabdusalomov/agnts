---
name: agnts-method-reuse-first
description: Use when you are about to write a helper, utility, wrapper, validator, formatter, parser, retry loop, HTTP client or other small abstraction. Shows how to find what the repository and its dependencies already provide before writing new code.
---

# Reuse first

Before writing a helper, assume the repository already has one. Duplicates are among the most common review findings, and the reviewer will know the existing one even if you do not.

## 1. Search the repository

- Search for the verb and the noun of what you need: `rg -n -i "retry"`, `rg -n "formatMoney|format_money|FormatAmount"`. Try a synonym or two (parse/decode, send/post, slug/permalink).
- Look in the usual homes: `util`, `utils`, `helpers`, `lib`, `common`, `shared`, `pkg`, `internal`, `core`, and the brief's list of shared code.
- Check tests too: a test helper you need may already exist next to the tests you are extending.

If you find one:

- Use it as it is when it fits.
- Extend it when it almost fits (a new option, a new case), keeping its existing callers working.
- If two or more near-duplicates exist, use the one most callers use. Do not add a third.

## 2. Check what is already installed

- The language's standard library often does it (string formatting, time zones, URL building, JSON, retries with backoff in some HTTP clients).
- Read the manifest (`go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `Gemfile`, `composer.json`, `pubspec.yaml`, `pom.xml` or `build.gradle`). A library already there is free to use.

## 3. Only then write it, or add a dependency

- Write the helper in the place where similar shared code lives, with a test, so the next person finds it.
- Add a new dependency only when neither the repository nor its current dependencies can do the job and the ticket's scope allows it. Prefer a small, maintained package with a permissive license.
- When you add one, say in your summary which package, its license and why the existing code could not do it. The person approving the change decides.

## Never

- Install global tools or edit lock files just to try something out.
- Copy code from a dependency into the repository instead of importing it.
- Write a general framework for a need you have once: write the specific function.
