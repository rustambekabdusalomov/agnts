# Repositories

The code agnts can work in. Every run clones the repository into a fresh container on your server.

## Sources

Jira repositories take tickets from a Jira project. Side-project repositories take tasks you create in agnts.

## Checks

Build, lint and test commands run after coding. A ticket reaches your review only when they pass.

## CLAUDE.md

A file in the repository root that describes structure, conventions and test commands. Without it agnts spends more turns finding its way.

## Editing

Select a repository to change its clone URL, default branch or commands.

## Preview

Give a start command and port, and agnts can take screenshots of UI changes before you review them. The command runs inside the run container (install, build, start); agnts waits for the port to answer. UI files decide which changes get screenshots. The environment holds KEY=value lines such as a staging API URL; it is stored encrypted, shown only by name, and visible to the app and to agnts, so use staging credentials only. Add the hosts the app calls under Settings → Previews → Allowed hosts.
