# Integrations

The services agnts works with: Jira or Plane for tickets, and GitHub or GitLab for code. Each has its own page with connection status and options.

## Connecting

Paste an access token with the listed scopes. It's stored encrypted on your server and never shown again. Test connection checks it at any time.

## Permissions

Each git page shows which permissions the token has. Required ones must be granted for runs to work.

## Repository access

Turn a repository off to stop agnts from cloning or pushing to it, without removing it.

## Commits and pull requests

Who commits appear from, a Co-authored-by line, title format, draft mode, labels, reviewers and what happens after merge.

## Jira rules

Which projects are watched, the label, issue types and statuses agnts picks up, shown as the exact query it runs.

## Plane

Plane Cloud or your own Plane. Enter the API address (https://api.plane.so, or your Plane's address), the workspace slug from Plane's URL and a personal access token. In Plane, add a webhook (Workspace settings → Webhooks) with the URL shown here and the work item events, then paste the secret Plane shows. Link a repository to a Plane project by its identifier (WEB in WEB-123) and label work items agnts, or agnts-<kind>. Statuses you leave empty move to the first state of the matching group (started, completed, cancelled); "in review" moves only to a state you name. A sync every hour catches webhooks Plane did not deliver.

## Status updates and comments

How agnts moves tickets on your board and what it writes as comments.
