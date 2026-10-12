# Repository

One repository's branches, commits and pipelines, so you can see what agnts changed and whether it passed.

## Branches

agnts creates its own branch for every ticket, like agnts/pay-214, and never commits to the default branch. Each branch shows its latest commit, how far ahead or behind it is, and its checks. Click a agnts branch to open its ticket.

## Commits

All recent commits grouped by day. agnts's commits start with the ticket key and list you as co-author.

## Pipelines

Every pipeline run with its stages: build, test, lint and deploys. Click a run to see stage times and the failure output.

## Environments

Which commit is on staging and production. Deploying to production waits for you: press Deploy on the stage.

## Guardrails

The repository's own guard profile (empty follows Settings), paths where example credentials are expected, the quick checks run on each edited file (derived from the toolchains unless you set them), **Coverage** of changed lines with a threshold, the **Acceptance check** of a ticket's criteria in the running app after the preview, and what agnts found in the repository's instructions for AI agents (CLAUDE.md, AGENTS.md, .claude/). agnts never runs a repository's own hooks or MCP servers.

## Settings

Edit settings changes the clone URL, default branch and the build, lint and test commands.
