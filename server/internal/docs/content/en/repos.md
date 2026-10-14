# Repositories

The code agnts can work in. Every run clones the repository into a fresh container on your server.

## Sources

Jira repositories take tickets from a Jira project, Plane repositories take work items from a Plane project. Side-project repositories take tasks you create in agnts.

## Checks

Build, lint and test commands run after coding. A ticket reaches your review only when they pass.

## CLAUDE.md

A file in the repository root that describes structure, conventions and test commands. Without it agnts spends more turns finding its way.

## Editing

Select a repository to change its clone URL, default branch or commands.

## Preview

Give a start command and port, and agnts can take screenshots of UI changes before you review them. The command runs inside the run container (install, build, start); agnts waits for the port to answer. UI files decide which changes get screenshots. The environment holds KEY=value lines such as a staging API URL; it is stored encrypted, shown only by name, and visible to the app and to agnts, so use staging credentials only. Add the hosts the app calls under Settings → Previews → Allowed hosts.

## Toolchains

The language runtimes and build tools every run installs, such as go@1.24, node@20 or python@3.12. agnts detects them from the repository's files (mise.toml, .tool-versions, go.mod, .nvmrc, pyproject.toml, Cargo.toml, pom.xml, global.json, Gemfile and others) and keeps them in step as those files change. Detect reads the default branch again; Ask Claude also reads the README and CI files when the scan finds no commands. Edit the list by hand and detection leaves it alone. Each version is installed once and shared by every run; each repository keeps its own package cache between runs.

## Advanced

Runner image replaces the default image for this repository, for system libraries or SDKs toolchains cannot provide (Android, Flutter); build it on the server FROM agnts-runner. Memory raises the run container's memory for heavy builds. The build environment holds KEY=value lines such as private registry tokens; it is stored encrypted, shown only by name, and visible to Claude while it works, so use read-only tokens.

## Groups

A group is a named set of repositories that one task can change together, such as a backend and its web app. Give it instructions that say how the repositories fit together (contracts, which one changes first); every run of the group's tasks reads them. A task made from a group copies its repositories when it is created: editing the group later does not change it. The repositories share one run container, so they need the same runner image and no clashing versions of a tool; agnts refuses a group that cannot share one and warns about build variables both set. Archived repositories stay in their groups but are left out of new tasks.
