---
name: agnts-method-house-style
description: Use before writing new code in a directory or layer you have not edited yet in this run, or when creating a new file. Shows how to read the conventions of the surrounding code and follow them.
---

# House style

Most of a repository's conventions are written nowhere: they are in the code next to yours. Read them before you write, so a reviewer cannot tell which lines a machine wrote.

## Read the neighbours

Open two or three files in the same directory or layer, preferring recently changed ones (`git log -5 --format=%cs --name-only -- <dir>`). Note:

1. **File anatomy.** The order inside a file: imports, constants, types, constructors, public functions, private helpers, exports. Where tests live and how they are named.
2. **Naming.** Files, types, functions, variables, flags, async and loading state, error values, test names. Abbreviations the code uses (`cfg` or `config`, `ctx`, `req`).
3. **Where cross-cutting code lives.** Error types, logging, formatting, validation, HTTP clients, middleware, shared UI components. Use those; do not write local copies.
4. **Error handling.** Returned or thrown, wrapped with context or not, logged where, shown to users how. Null and empty checks.

Also follow the formatter and linter configuration the repository has, and comment density: if the neighbours comment only the non-obvious, so do you.

## When the neighbours disagree

- Follow the majority in the nearest scope: the file over the directory, the directory over the package, the package over the repository.
- When it is an even split, follow the more recently changed code.
- Note the choice in your summary in one line (for example, "followed `errors.go` in this package, which wraps errors with `%w`; `legacy/` does not"). A person can turn it into a team rule.
- Team rules and the repository brief win over anything you infer here.

## Scope

- Do not restyle lines the ticket does not touch: no reformatting, renaming or reordering of existing code.
- Do not introduce a new library, pattern or style for something the neighbours already do one way.
