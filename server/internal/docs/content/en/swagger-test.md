# Swagger tests

A Swagger test checks an HTTP API against its Swagger/OpenAPI spec. You give agnts the spec, the base URL to test, the endpoints and, if the API needs one, a token. agnts plans the cases for each endpoint (the happy path, missing and invalid fields, no or wrong token, unknown ids, pagination edges), sends real requests and reports a verdict per case, with the request and response behind every one.

## Making one

New task → **Swagger test**.

- **Spec**: the spec's URL (`…/openapi.json`, `…/swagger.json`, `…/v3/api-docs`) or the URL of a Swagger UI, Springdoc or Redoc page: agnts finds the spec behind it. You can also upload the file. If the spec link needs a sign-in (it answers 401 or 403), tick **The spec link needs a sign-in**. Choose **Login and password** for a link that asks for them (the form opens this by itself when the link asks): they only open the link, and the agent's API requests use the token you give under Authentication. Or choose **Token** for a link that takes one; that token also becomes the API token unless you change it. Neither is stored: they go with the fetch to the spec's host only. Swagger 2.0 and OpenAPI 3.0/3.1, up to 5 MB, in one file (agnts never fetches other files a spec refers to).
- **Base URL**: where requests go. It starts as the spec's server, which is often production: check it. A host name or a bare IP, on any port.
- **What to test**: write which endpoints to test, and anything the test should know ("only the POST endpoints under /v1/orders; user 42 is a test account"). agnts tests only what you write: the run sees the whole spec, plans cases only for the endpoints you name, and reports nothing about the rest.
- **Pick endpoints (optional)**: nothing is ticked at first. Tick endpoints to test exactly those instead; **Suggested** ticks all but deprecated ones and GETs whose name suggests they change something (`logout`, `export`, `send`, `reset`, `sync` …), and the form says why each of those is left out. A test needs one of the two: the text, or ticked endpoints.
- **Authentication**: none, a bearer token, an API key in a header or the query, or basic auth. Use a **test account's** token, never a personal or production one.

## Read-only and write requests

Tests are **read-only** by default: only GET, HEAD and OPTIONS are sent. Read-only is not the same as harmless: some APIs change things on GET, and that is your call when you tick endpoints. Turning on write requests (POST, PUT, PATCH, DELETE) asks you to confirm the base URL is not production. With write requests on, agnts orders cases create → read → update → delete and deletes what it created.

## Accounts and firewalls

The "no token" and "wrong token" cases look like a login attack to a firewall. A run sends at most 3 of them, and stops when the API answers 429 three times or 401/403 to requests that carry the token. It may still lock the test account or get the caller blocked. Behind a Private network that caller is the workspace's VPN connection, which GitLab and other tests also use.

## Internal APIs

An API on a host from one of the workspace's Private network routes is reached through that network, like GitLab. Any other host must resolve to a public address: agnts refuses internal addresses for hosts that come from a ticket.

## The results

The **API results** tab lists the endpoints, failures first. Open a case to see the request and response that decided it, and copy it as curl (the token stays masked). agnts also checks every response against the spec's schema itself; those findings are marked **agnts check**. A verdict Claude reports without a logged request behind it is dropped. **Requests** lists every request the run sent.

- **pass** / **fail**: the case ran, and the response was right or wrong.
- **skipped**: not run by choice: write requests are off, data the API does not expose, a cap reached.
- **blocked**: could not run: the token expired, or an earlier request it depends on failed. A run where every case is blocked fails, with the reason.

**Create bug ticket** turns the failures into a Bug ticket (in the test's repository, if it has one). **Run again** repeats the test; a closed test runs again as a new ticket.

## Suites

**Save as suite** on a finished test keeps it to run again: by hand, every hour, every day or every Monday (at a UTC hour you pick), or after each deploy. Each run is a new Swagger test ticket. It reuses the plan of the suite's last run, so repeat runs cost far fewer turns, and it is compared with that run: the notification leads with the failures that are new since. A run does not start while the suite's last one is still going.

**Create deploy hook** gives a URL your deploy pipeline calls with `curl -X POST <url>` after each deploy. It is shown once; making a new one stops the old. The suite keeps its own copy of the token, sealed like a ticket's, until you replace it or delete the suite.

## The token

It is sealed when you save the form, never shown again, removed from everything agnts stores (logs, results, the report, live events), and deleted when the ticket closes. Inside the run only agnts-api, the client that sends the requests, reads it.

## Cost

One Claude (Sonnet) session of at most 60 turns, whatever model the workspace codes with: the token and API protections depend on agnts's in-run guard, which Codex runs do not have. Sending is one batch call at 5 requests a second (adjustable), at most 300 requests per run.
