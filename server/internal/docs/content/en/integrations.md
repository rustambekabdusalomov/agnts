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

An issue goes to the repository linked to its project (Repositories → Jira project). To send one issue somewhere else, add the label repo:<name> with the repository's name in agnts, for example repo:web; case doesn't matter. It wins over the project's repository, so one Jira project can feed several repositories, and the project doesn't need a repository of its own. Adding or changing the label moves a ticket that hasn't started; once work starts, the ticket keeps its repository (change it on the ticket page while it is queued or failed). A name agnts doesn't know falls back to the project's repository, with a warning in the ticket's history. Several repo: labels make one ticket that changes all those repositories together (the first is the main one, one pull request per changed repository), and a group:<name> label sends it to a repository group's repositories; it wins over repo: labels.

With Only issues assigned to me on (the default), agnts takes a labelled issue only when it is assigned to the Jira account agnts connects with, and the query adds assignee = currentUser(). An issue assigned to someone else, or to nobody, makes no new ticket; a ticket agnts already has still gets that issue's updates. Turn it off to take every labelled issue.

## Plane

Plane Cloud or your own Plane. Enter the API address (https://api.plane.so, or your Plane's address), the workspace slug from Plane's URL and a personal access token. In Plane, add a webhook (Workspace settings → Webhooks) with the URL shown here and the work item events, then paste the secret Plane shows. Link a repository to a Plane project by its identifier (WEB in WEB-123) and label work items agnts, or agnts-<kind>. Statuses you leave empty move to the first state of the matching group (started, completed, cancelled); "in review" moves only to a state you name. A sync every hour catches webhooks Plane did not deliver.

To send one work item to another repository, add the label repo:<name> with the repository's name in agnts, for example repo:web; case doesn't matter. It wins over the project's repository, so one Plane project can feed several repositories. Sync and the hourly check read only projects linked to a repository, so keep the project linked to one. Adding or changing the label moves a ticket that hasn't started; once work starts, the ticket keeps its repository. A name agnts doesn't know falls back to the project's repository, with a warning in the ticket's history. Several repo: labels, or a group:<name> label, make one ticket in several repositories, as for Jira.

## Status updates and comments

How agnts moves tickets on your board and what it writes as comments.
