#!/usr/bin/env python3
"""Demo data for the agnts admin panel, for website screenshots.

    python3 scripts/demo_seed.py <owner email> "<owner name>" > seed.sql

`make demo-db` runs it and loads the result into the agnts_demo database.
The owner is the Google account you sign in with. Everything else is a
made-up team ("Northwind Pay") with 90 days of history that improves over
time. Timestamps are relative to now, so re-seed before taking screenshots
on a later day.
"""

import datetime as dt
import json
import random
import sys

R = random.Random(20261021)
TZ = dt.timezone(dt.timedelta(hours=5))  # Asia/Tashkent
NOW = dt.datetime.now(TZ).replace(microsecond=0)
DAYS = 90
WS = 1

if len(sys.argv) != 3:
    sys.exit(__doc__)
OWNER_EMAIL, OWNER_NAME = sys.argv[1], sys.argv[2]

OPUS, SONNET, HAIKU = "claude-opus-5-5", "claude-sonnet-5-5", "claude-haiku-5-5"

# ---------------------------------------------------------------- SQL helpers


class Raw(str):
    """A literal SQL expression, inserted as is."""


def lit(v):
    if v is None:
        return "NULL"
    if isinstance(v, Raw):
        return v
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, dt.datetime):
        return "'" + v.isoformat() + "'"
    return "'" + str(v).replace("'", "''") + "'"


def J(obj):
    return Raw(lit(json.dumps(obj, ensure_ascii=False)) + "::jsonb")


def A(items, typ="text"):
    if not items:
        return Raw("'{}'::" + typ + "[]")
    return Raw("ARRAY[" + ",".join(lit(i) for i in items) + "]::" + typ + "[]")


OUT = []


def ins(table, rows):
    groups = {}
    for r in rows:
        groups.setdefault(tuple(r.keys()), []).append(r)
    for cols, rs in groups.items():
        for i in range(0, len(rs), 400):
            vals = ",\n".join("(" + ",".join(lit(r[c]) for c in cols) + ")" for r in rs[i:i + 400])
            over = " OVERRIDING SYSTEM VALUE" if "id" in cols else ""
            OUT.append(f"INSERT INTO {table} ({','.join(cols)}){over} VALUES\n{vals};")


def sha():
    return "%040x" % R.getrandbits(160)


def mins(a, b):
    return dt.timedelta(minutes=R.uniform(a, b))


def at_day(days_ago, hour_from=9, hour_to=19):
    d = (NOW - dt.timedelta(days=days_ago)).replace(hour=0, minute=0, second=0)
    return d + dt.timedelta(minutes=R.uniform(hour_from * 60, hour_to * 60))


# ---------------------------------------------------------------- people

owner_login = OWNER_EMAIL.split("@")[0].lower().replace(".", "")
PEOPLE = [
    # id, username, email, name, github login, role
    (1, owner_login, OWNER_EMAIL, OWNER_NAME, "rustambek", "owner"),
    (2, "dilnoza", "dilnoza.karimova@northwind.example", "Dilnoza Karimova", "dilnoza-k", "user"),
    (3, "aziz", "aziz.rakhimov@northwind.example", "Aziz Rakhimov", "aziz-r", "user"),
    (4, "madina", "madina.yusupova@northwind.example", "Madina Yusupova", "madina-y", "user"),
    (5, "sarah", "sarah.chen@northwind.example", "Sarah Chen", "schen", "user"),
    (6, "timur", "timur.alimov@northwind.example", "Timur Alimov", "timur-a", "viewer"),
]
DEVS = [1, 2, 3, 4, 5]
LOGIN = {p[0]: p[4] for p in PEOPLE}

ins("users", [dict(id=p[0], username=p[1], password_hash="", email=p[2], email_verified_at=NOW - dt.timedelta(days=120),
                   display_name=p[3], created_at=NOW - dt.timedelta(days=120 - p[0])) for p in PEOPLE])
ins("workspaces", [dict(id=WS, slug="northwind", name="Northwind Pay", owner_id=1, plan="base", slots=3, member_limit=10,
                        credits_balance=18450, paid_until=NOW + dt.timedelta(days=58), created_at=NOW - dt.timedelta(days=120))])
OUT.append(f"UPDATE users SET last_workspace_id = {WS};")
ins("memberships", [dict(workspace_id=WS, user_id=p[0], role=p[5], created_at=NOW - dt.timedelta(days=118 - p[0])) for p in PEOPLE])

# ---------------------------------------------------------------- repositories

GO_DIFF = """@@ -41,6 +41,18 @@ func (h *Handler) {fn}(w http.ResponseWriter, r *http.Request) {{
 	ctx := r.Context()
-	res, err := h.svc.{fn}(ctx, req)
+	key := r.Header.Get("Idempotency-Key")
+	if key == "" {{
+		writeError(w, http.StatusBadRequest, "idempotency_key_required")
+		return
+	}}
+	res, err := h.svc.{fn}(ctx, req, key)
 	if err != nil {{
+		h.log.Warn("{fn} failed", "err", err)
 		writeError(w, statusOf(err), err.Error())
 		return
 	}}"""
TS_DIFF = """@@ -18,7 +18,15 @@ export default defineComponent({{
   setup() {{
-    const rows = ref([])
+    const filters = reactive({{ status: 'all', from: null, to: null }})
+    const {{ data: rows, isLoading }} = useQuery({{
+      queryKey: ['{fn}', filters],
+      queryFn: () => api.{fn}(filters),
+    }})
+    watch(filters, () => router.replace({{ query: toQuery(filters) }}))
-    return {{ rows }}
+    return {{ rows, filters, isLoading }}
   }},"""
DART_DIFF = """@@ -27,6 +27,13 @@ class {fn}Screen extends StatelessWidget {{
   Widget build(BuildContext context) {{
+    final auth = context.watch<AuthState>();
+    if (auth.biometricsAvailable && !auth.unlocked) {{
+      return BiometricGate(onUnlocked: auth.unlock);
+    }}
     return Scaffold(
-      body: _body(context),
+      body: SafeArea(child: _body(context)),
     );"""

REPOS = [
    dict(id=1, name="payments-api", kind="jira", prefix="PAY", jira="PAY", plane="", stack="Go 1.24 · PostgreSQL 17 · Redis",
         build="go build ./...", lint="golangci-lint run", test="go test -race ./...", md="found", weight=34, pr=1180, diff=GO_DIFF,
         tools=[{"tool": "go", "version": "1.24.2", "source": "go.mod"}],
         files=["internal/payments/handler.go", "internal/payments/service.go", "internal/payments/service_test.go",
                "internal/refunds/refunds.go", "internal/webhooks/payme.go", "internal/webhooks/click.go",
                "internal/fees/fees.go", "internal/fees/fees_test.go", "migrations/0142_idempotency.sql", "internal/httpapi/errors.go"]),
    dict(id=2, name="web-dashboard", kind="plane", prefix="WEB", jira="", plane="WEB", stack="Vue 3 · TypeScript · Vite",
         build="npm run build", lint="npm run lint", test="npm test", md="found", weight=30, pr=842, diff=TS_DIFF,
         tools=[{"tool": "node", "version": "22.11", "source": ".nvmrc"}],
         files=["src/pages/TransactionsPage.vue", "src/components/RefundDialog.vue", "src/api/transactions.ts",
                "src/stores/session.ts", "src/i18n/uz.json", "src/components/charts/VolumeChart.vue",
                "src/pages/PayoutsPage.vue", "src/router/index.ts", "src/components/DataTable.vue"]),
    dict(id=3, name="mobile-app", kind="side", prefix="MOB", jira="", plane="", stack="Flutter 3.32 · Dart 3.8",
         build="flutter build apk --debug", lint="flutter analyze", test="flutter test", md="missing", weight=14, pr=377, diff=DART_DIFF,
         tools=[{"tool": "flutter", "version": "3.32.0", "source": "pubspec.yaml"}],
         files=["lib/screens/login_screen.dart", "lib/screens/balance_screen.dart", "lib/services/api_client.dart",
                "lib/widgets/amount_field.dart", "test/payment_flow_test.dart", "lib/screens/receipt_screen.dart"]),
    dict(id=4, name="notifications", kind="side", prefix="NTF", jira="", plane="", stack="Node.js 22 · TypeScript · BullMQ",
         build="npm run build", lint="npm run lint", test="npm test", md="found", weight=13, pr=264, diff=TS_DIFF,
         tools=[{"tool": "node", "version": "22.11", "source": "package.json"}],
         files=["src/channels/telegram.ts", "src/channels/sms.ts", "src/channels/email.ts", "src/queue/retry.ts",
                "src/templates/render.ts", "test/sms.test.ts"]),
    dict(id=5, name="ledger-service", kind="side", prefix="LED", jira="", plane="", stack="Go 1.24 · PostgreSQL 17",
         build="go build ./...", lint="golangci-lint run", test="go test ./...", md="missing", weight=9, pr=158, diff=GO_DIFF,
         tools=[{"tool": "go", "version": "1.24.2", "source": "go.mod"}],
         files=["internal/ledger/posting.go", "internal/ledger/posting_test.go", "internal/ledger/balance.go",
                "internal/reconcile/reconcile.go", "migrations/0031_snapshots.sql"]),
]
REPO = {r["id"]: r for r in REPOS}

TITLES = {
    1: ["Add idempotency keys to POST /payments", "Refund endpoint returns 500 on partial refunds",
        "Retry Payme webhooks with exponential backoff", "Support Click merchant callbacks v2",
        "Paginate GET /transactions with a cursor", "Audit log for manual balance adjustments",
        "Validate card expiry before tokenization", "Rate-limit OTP verification attempts",
        "Move fee calculation into a pure function with table tests", "Payout scheduler skips weekends in Asia/Tashkent",
        "Expose /healthz with database and queue checks", "Prometheus metrics for payment latency",
        "Fix double charge when the client retries after a timeout", "Currency rounding for UZS amounts over 1 billion",
        "Reconciliation report for daily settlements", "Deprecate v1 /charge behind a feature flag",
        "Store 3-D Secure results on the payment", "Make refunds idempotent per merchant reference",
        "Speed up merchant search with a trigram index", "Localized error messages (uz, ru, en)",
        "Handle Payme CheckPerformTransaction timeouts", "Merchant-level daily limits",
        "Encrypt stored card holder names", "Split the settlement job into per-merchant batches",
        "OpenAPI examples for payout endpoints", "Lower p95 latency of GET /balance under load",
        "Webhook signature check accepts expired timestamps", "Dry-run mode for the fee migration",
        "Backfill missing merchant categories", "Return Retry-After on 429 responses"],
    2: ["Transactions table: filter by status and date range", "Export transactions to CSV",
        "Dark mode for the merchant dashboard", "Refund dialog: show the fee breakdown before confirming",
        "Chart tooltips overflow on mobile", "Skeleton loaders on the overview page", "Payout calendar view",
        "Show API key last-used time on the developers page", "Localize the dashboard into Uzbek and Russian",
        "Two-factor setup flow with a QR code", "Logout does not clear the query cache", "Merchant onboarding checklist",
        "Search transactions by card last 4", "Keyboard shortcuts for the transactions list",
        "Better empty states on reports", "Date picker shifts the date by the timezone",
        "Team page: invite members by email", "Accessible focus styles across forms",
        "Webhook logs viewer with a retry button", "Settlement report download as PDF",
        "Replace moment.js with date-fns", "Lazy-load the analytics route", "Sticky table header on transactions",
        "Explain failed payment reasons in plain language"],
    3: ["Biometric login on Android", "Push notification when a payout lands", "Offline banner and retry for failed requests",
        "QR payment screen: torch toggle", "Keyboard covers the amount field on iOS", "Share sheet for transaction details",
        "Upgrade Flutter to 3.32 and fix deprecations", "Deep links to a single transaction",
        "Crash on Android 9 when opening receipts", "Pull to refresh on the balance screen",
        "Widget tests for the payment flow", "Remember the last used merchant terminal"],
    4: ["Telegram alerts for large payments", "Batch SMS sends through Eskiz", "Retry failed emails with a dead-letter queue",
        "Template previews for merchant emails", "Unsubscribe link in marketing emails", "Rate-limit SMS per phone number",
        "Move to Node 22 and native fetch", "Delivery metrics per channel", "Duplicate push on reconnect",
        "Quiet hours for non-critical notifications"],
    5: ["Double-entry check on every posting", "Daily balance snapshot job", "Rounding drift in multi-currency postings",
        "Ledger export for accountants", "Lock accounts during reconciliation",
        "Speed up balance queries with a materialized view", "Reject postings to closed accounts"],
}
GENERIC_VERBS = ["Refactor", "Add tests for", "Improve logging in", "Clean up", "Harden error handling in",
                 "Speed up", "Document", "Add tracing to", "Remove dead code from", "Tighten validation in"]
GENERIC_OBJ = {
    1: ["the payout scheduler", "merchant service", "the Payme webhook handler", "the fee module", "auth middleware",
        "the refunds service", "card tokenization", "the settlement job"],
    2: ["the transactions page", "the refund dialog", "the API client", "the session store", "the payouts page", "the router"],
    3: ["the login screen", "the API client", "the receipt screen", "the balance screen"],
    4: ["the SMS channel", "the retry queue", "template rendering", "the Telegram channel"],
    5: ["posting validation", "balance snapshots", "the reconciliation job"],
}
_pool = {k: R.sample(v, len(v)) for k, v in TITLES.items()}
_used = set()


def title_for(repo_id):
    if _pool[repo_id]:
        return _pool[repo_id].pop()
    for _ in range(50):
        t = f"{R.choice(GENERIC_VERBS)} {R.choice(GENERIC_OBJ[repo_id])}"
        if t not in _used:
            _used.add(t)
            return t
    return t


rows = []
for r in REPOS:
    rows.append(dict(id=r["id"], workspace_id=WS, name=r["name"], kind=r["kind"], provider="github",
                     clone_url=f"https://github.com/northwind-pay/{r['name']}.git", default_branch="main", stack=r["stack"],
                     build_cmd=r["build"], lint_cmd=r["lint"], test_cmd=r["test"], branch_prefix="agnts/",
                     jira_project=r["jira"], plane_project=r["plane"], task_prefix=r["prefix"], claude_md_status=r["md"],
                     toolchains=J(r["tools"]), toolchains_detected_at=NOW - dt.timedelta(days=30),
                     harness=J({"guardProfile": "standard", "coverage": {"enabled": True, "threshold": 70}, "acceptance": True}),
                     created_at=NOW - dt.timedelta(days=115 - r["id"]), updated_at=NOW - dt.timedelta(days=3)))
ins("repositories", rows)
ins("repository_groups", [dict(id=1, workspace_id=WS, name="Checkout", task_prefix="CHK",
                               description="Payment flow across the API, the dashboard and the app",
                               instructions="Ship API changes first; the dashboard and the app must keep working against the previous API version.",
                               created_at=NOW - dt.timedelta(days=60))])
ins("repository_group_members", [dict(workspace_id=WS, group_id=1, repo_id=1, role="backend", position=0),
                                 dict(workspace_id=WS, group_id=1, repo_id=2, role="frontend", position=1),
                                 dict(workspace_id=WS, group_id=1, repo_id=3, role="mobile", position=2)])
ins("integrations", [
    dict(workspace_id=WS, provider="github", connected=True, account="northwind-pay", checked_at=NOW - mins(5, 50)),
    dict(workspace_id=WS, provider="jira", connected=True, account="northwind.atlassian.net", checked_at=NOW - mins(5, 50)),
    dict(workspace_id=WS, provider="plane", connected=True, account="plane.northwind.example", checked_at=NOW - mins(5, 50)),
    dict(workspace_id=WS, provider="telegram", connected=True, account="@northwind_agnts_bot", checked_at=NOW - mins(5, 50)),
])

# ---------------------------------------------------------------- ticket builder

ids = {k: 0 for k in ["ticket", "run", "event", "call", "result", "question", "sugg"]}


def nid(k):
    ids[k] += 1
    return ids[k]


TICKETS, RUNS, EVENTS, CALLS, RESULTS, QUESTIONS, TREPOS = [], [], [], [], [], [], []
SEQ = {r["id"]: 0 for r in REPOS}
PR = {r["id"]: r["pr"] for r in REPOS}

TOOLS = {
    "analyze": [("Read", "Read: {f}"), ("Grep", "Grep: {g}"), ("Glob", "Glob: **/*{ext}"), ("Read", "Read: {f}")],
    "code": [("Read", "Read: {f}"), ("Edit", "Edit: {f}"), ("Bash", "Bash: {test}"), ("Grep", "Grep: {g}"),
             ("Edit", "Edit: {f}"), ("Write", "Write: {f}"), ("Bash", "Bash: {lint}")],
}
GREPS = ["Idempotency", "func.*Refund", "useQuery", "retryPolicy", "writeError", "TODO", "settlement", "context.Context"]
TEXTS = {
    "analyze": ["The handler already validates the amount; the gap is in the service layer.",
                "There is an existing retry helper in internal/retry that fits here.",
                "Two call sites need the change; the tests cover one of them."],
    "code": ["Reusing the existing middleware instead of adding a new one.",
             "Tests pass locally; adding a regression test for the reported case.",
             "Kept the public API unchanged; the new parameter has a safe default.",
             "Following the pattern used in the payouts module."],
}
QUESTION_POOL = [
    ("Should partial refunds keep the original fee, or refund it proportionally?", ["Keep the fee", "Refund proportionally"]),
    ("Which error code should clients get for a reused idempotency key with a different body?", ["409 Conflict", "422 Unprocessable Entity"]),
    ("Do we keep the old endpoint working during the migration?", ["Yes, for 30 days", "No, switch at once"]),
    ("Where should the new setting live?", ["Merchant settings page", "Admin only"]),
    ("Which locales are required for the first release?", ["Uzbek and Russian", "Uzbek, Russian and English"]),
    ("Should this run for all merchants or behind a flag?", ["Behind a flag", "All merchants"]),
]
FEEDBACK = ["Please also cover the timeout path with a test.", "Rename the flag to match the other settings.",
            "Use the existing money type instead of float64.", "The empty state needs the illustration from Figma.",
            "Keep the old response field for one more release."]


class T:
    """One ticket and everything it leaves behind."""

    def __init__(self, repo_id, created, kind="code", source=None, title=None, by=None):
        self.id = nid("ticket")
        self.repo = REPO[repo_id] if repo_id else None
        SEQ[repo_id] += 1
        self.key = f"{self.repo['prefix']}-{SEQ[repo_id]}"
        self.source = source or {"jira": "jira", "plane": "plane"}.get(self.repo["kind"], "local")
        self.kind, self.title = kind, title or title_for(repo_id)
        self.by = by or R.choice(DEVS)
        self.created, self.t, self.state = created, created, "new"
        self.revision = self.turns = self.ci_fixes = 0
        self.pr = self.pr_url = None
        self.branch = self.head = ""
        self.merged_at = self.closed_at = None
        self.tr_state = "pending"
        self.files = 0
        self.extra = {}
        origin = {"jira": "webhook", "plane": "webhook", "ci": "system", "git": "webhook"}.get(self.source, R.choice(["web", "web", "mobile", "telegram"]))
        self.ev("ticket_created", origin=origin, msg=self.title, user=self.by if origin in ("web", "mobile", "telegram") else None)

    # events and states
    def ev(self, typ, step="", level="info", origin="system", msg="", data=None, run=None, user=None, dur=None, t=None):
        EVENTS.append(dict(ticket_key=self.key, run_id=run, step=step, type=typ, level=level, origin=origin, message=msg,
                           data=data or {}, duration_ms=dur, created_at=t or self.t, workspace_id=WS, user_id=user))

    def go(self, to, step="", origin="system", msg="", user=None):
        self.ev("state_changed", step=step, origin=origin, msg=msg, data={"from": self.state, "to": to}, user=user)
        self.state = to

    def wait(self, a, b):
        self.t += mins(a, b)

    # runs
    def run(self, stage, model, minutes, turns, exit="ok", live=False, pv="v14", harness=None, fix=0):
        rid = nid("run")
        start = self.t
        n_tools = {"analyze": 3, "code": 6, "review": 2, "learn": 1}.get(stage, 2)
        r = self.repo
        span = minutes / (n_tools + 1)
        for i in range(n_tools):
            self.t += dt.timedelta(minutes=span * R.uniform(0.6, 1.3))
            if live and self.t > NOW - dt.timedelta(minutes=1):
                break
            tool, fmt = R.choice(TOOLS.get(stage, TOOLS["analyze"]))
            msg = fmt.format(f=R.choice(r["files"]), g=R.choice(GREPS), ext=r["files"][0][r["files"][0].rfind("."):],
                             test=r["test"], lint=r["lint"])
            self.ev("claude_tool", step=stage, msg=msg, data={"tool": tool, "id": "toolu_%012x" % R.getrandbits(48)}, run=rid)
            if stage in TEXTS and R.random() < 0.35:
                self.ev("claude_text", step=stage, msg=R.choice(TEXTS[stage]), run=rid)
        if not live:
            self.t = start + dt.timedelta(minutes=minutes)
        run = dict(id=rid, ticket_id=self.id, stage=stage, model=model, session_id="%032x" % R.getrandbits(128),
                   started_at=start, finished_at=None if live else self.t, turns=turns, exit_reason="" if live else exit,
                   workspace_id=WS, prompt_version=pv, fix_attempts=fix, harness=J(harness or {}))
        RUNS.append(run)
        if not live:
            self.call(rid, stage, model, turns, minutes)
        return rid

    def call(self, rid, stage, model, turns, minutes):
        per_turn = {OPUS: 0.045, SONNET: 0.014, HAIKU: 0.003}[model]
        cost = round(max(turns, 1) * per_turn * R.uniform(0.7, 1.3), 6)
        price_in = {OPUS: 5e-6, SONNET: 3e-6, HAIKU: 1e-6}[model]
        inp = int(cost * 0.35 / price_in)
        CALLS.append(dict(id=nid("call"), run_id=rid, ticket_id=self.id, workspace_id=WS,
                          model_stage={"code": "coding"}.get(stage, stage), model=model, input_tokens=inp,
                          output_tokens=int(inp * R.uniform(0.04, 0.09)), cache_read_tokens=int(inp * R.uniform(3, 9)),
                          cache_write_tokens=int(inp * R.uniform(0.3, 0.8)), cost_usd=cost, turns=turns,
                          duration_ms=int(minutes * 60000), created_at=self.t))

    def result(self, rid, summary, tests=None, files=None, red=None, harness=None, report=""):
        RESULTS.append(dict(id=nid("result"), run_id=rid, workspace_id=WS, summary=J(summary), tests=J(tests or []),
                            files=J(files or []), red_flags=J(red or []), harness=J(harness or {}), report=report,
                            created_at=self.t))

    # lifecycle pieces
    def analyze(self, pv, ask=False, ask_wait=(15, 180), live=False):
        self.wait(*((0.5, 2) if live else (1, 25)))
        self.go("analyzing", "analyze", msg="picked up")
        rid = self.run("analyze", SONNET, R.uniform(2, 6), R.randint(4, 9), pv=pv, live=live)
        if live:
            return
        qs = R.sample(QUESTION_POOL, R.randint(1, 2)) if ask else []
        self.result(rid, {"summary": f"{self.title}: the change is contained in {self.repo['name']}.",
                          "plan": ["Find the code path and its tests", "Make the change behind the existing interfaces",
                                   "Add a regression test", "Run build, lint and tests"],
                          "kind": self.kind if self.kind in ("code", "bug", "test", "plan", "analysis") else "code",
                          "complexity": R.choice(["simple", "simple", "medium", "complex"]),
                          "questions": [{"text": q, "options": o, "multiple": False} for q, o in qs],
                          "acceptance": [{"id": "ac1", "criterion": "The reported case is covered by a test", "check": "test"},
                                         {"id": "ac2", "criterion": "Existing behaviour is unchanged for other callers", "check": "api"}]})
        if ask:
            self.go("waiting_for_answers", "analyze", msg=f"{len(qs)} question(s) for you")
            asked = self.t
            for i, (q, o) in enumerate(qs):
                qid = nid("question")
                QUESTIONS.append(dict(id=qid, ticket_id=self.id, position=i, text=q, options=o, answer=None,
                                      answered_at=None, created_at=asked, workspace_id=WS))
            self.qs = QUESTIONS[-len(qs):]
            return "asked"

    def answer(self, a, b):
        self.wait(a, b)
        for q in self.qs:
            q["answer"], q["answered_at"] = R.choice(q["options"]), self.t
        user = self.by
        self.ev("answered", origin=R.choice(["web", "mobile", "telegram"]), msg="answered", user=user,
                data={"from": "waiting_for_answers", "to": "coding"})
        self.state = "waiting_for_answers"
        self.go("coding", "code", origin="web", msg="answers received", user=user)

    def code(self, pv, p, fail=None, live=False, fix=0):
        if self.state != "coding":
            self.go("coding", "code", msg="writing code")
        turns = int(R.uniform(16, 42) * (1.15 - 0.35 * p))
        skills = p > 0.45
        harness = {"guard": {"warnings": R.randint(0, 3), "blocks": {"silenced_lint": 1} if R.random() < 0.1 else {}}}
        if skills:
            harness["methodSkills"] = R.sample(["reuse-first", "follow-existing-pattern", "house-style", "migrations"], 2)
            harness["skills"] = harness["methodSkills"][:1] + (["team:money-types"] if R.random() < 0.4 else [])
        model = OPUS if R.random() < 0.7 else SONNET
        exit = {"max_turns": "claude_error_max_turns", "stopped": "stopped", "rate_limited": "rate_limited"}.get(fail, "ok")
        rid = self.run("code", model, R.uniform(8, 32) * (1.1 - 0.3 * p), turns, exit=exit, live=live, pv=pv,
                       harness=harness, fix=fix)
        self.turns += turns
        return rid

    def checks(self, rid, ok=True):
        self.go("testing", "checks", msg="running checks")
        out = []
        for name, cmd in (("build", self.repo["build"]), ("lint", self.repo["lint"]), ("test", self.repo["test"])):
            ms = int(R.uniform(4, 60) * 1000)
            failed = not ok and name == "test"
            self.t += dt.timedelta(milliseconds=ms)
            c = {"name": name, "command": cmd, "exit_code": 1 if failed else 0, "duration_ms": ms}
            if failed:
                c["output"] = "--- FAIL: TestSettlementCutoff (0.02s)\n    settlement_test.go:88: want 2 batches, got 1"
            out.append(c)
            self.ev("check", step="checks", level="warn" if failed else "info",
                    msg=f"{name} failed (exit 1)" if failed else f"{name} passed",
                    data={"name": name, "command": cmd, "exit_code": c["exit_code"], "output": c.get("output", "")},
                    run=rid, dur=ms)
        return out

    def files_changed(self):
        fs = R.sample(self.repo["files"], min(len(self.repo["files"]), R.randint(2, 5)))
        fn = "".join(w.capitalize() for w in self.title.split()[:2] if w.isalpha()) or "Handle"
        res = [{"path": f, "add": R.randint(4, 120), "del": R.randint(0, 40), "diff": self.repo["diff"].format(fn=fn)} for f in fs]
        self.files = len(res)
        return res

    def ready(self, rid, checks, p):
        red = []
        if R.random() < 0.12:
            red = [{"kind": "todo", "path": R.choice(self.repo["files"]), "line": R.randint(10, 200), "text": "// TODO: handle the retry case"}]
            self.ev("red_flags", step="code", level="warn", msg="1 red flag", data={"count": 1}, run=rid)
        harness = {"coverage": {"covered": (c := R.randint(30, 60)), "total": (tot := c + R.randint(2, 14)),
                                "percent": round(100 * c / tot, 1), "threshold": 70}}
        if self.kind == "bug":
            harness["proof"] = {"status": "proven", "base": sha()[:12], "tests": [{
                "file": self.repo["files"][2], "name": "TestRegression", "command": self.repo["test"],
                "before": {"exit": 1, "output": "FAIL", "ms": 900}, "after": {"exit": 0, "output": "ok", "ms": 870},
                "status": "proven", "at": self.t.isoformat()}]}
        harness["acceptance"] = {"status": "ok", "summary": "All acceptance criteria are met.",
                                 "criteria": [{"id": "ac1", "criterion": "The reported case is covered by a test", "verdict": "pass",
                                               "evidence": "TestRegression fails on main and passes on the branch"},
                                              {"id": "ac2", "criterion": "Existing behaviour is unchanged for other callers",
                                               "verdict": "pass", "evidence": "The full test suite passes"}]}
        self.result(rid, {"summary": f"{self.title}: done, with a regression test.",
                          "notes": ["Reused the existing helpers; no new dependencies."], "deviations": [], "followUps": [],
                          "repro": [{"file": self.repo["files"][-1], "name": "TestRegression", "command": self.repo["test"]}]},
                    tests=checks, files=self.files_changed(), red=red, harness=harness)
        self.go("waiting_for_review", "code", msg="ready for your review")
        # agnts reviews its own change
        self.wait(1, 3)
        found = R.choices([0, 1, 2, 3], [5, 3, 2, 1])[0]
        counts = {"blocker": 0, "major": 1 if found > 2 else 0, "minor": min(found, 2), "nit": R.randint(0, 2)}
        rrid = self.run("review", SONNET, R.uniform(1, 3), R.randint(3, 8), pv="v14")
        self.ev("review_done", step="review", msg="self-review done", run=rrid,
                data={"verdict": "looks_good" if found < 2 else "has_concerns", "findings": found, "counts": counts,
                      "worst": "minor" if found else "", "revision": self.revision, "model": SONNET})
        self.ev("footprint_checked", step="review", data={"recall": round(R.uniform(0.82, 1.0), 2)}, run=rrid)

    def feedback(self, a, b):
        self.wait(a, b)
        user = self.by
        self.ev("feedback", origin="web", msg=R.choice(FEEDBACK), user=user, data={"revision": self.revision + 1})
        self.revision += 1
        self.go("coding", "code", origin="web", msg="changes requested", user=user)

    def approve_and_push(self, a, b):
        self.wait(a, b)
        self.go("pushing", "push", origin=R.choice(["web", "web", "mobile", "telegram"]), msg="approved", user=self.by)
        self.wait(0.3, 1.5)
        slug = "-".join(w.lower() for w in self.title.replace(":", "").split()[:4] if w.isalnum())
        self.branch, self.head = f"agnts/{self.key}-{slug}", sha()
        PR[self.repo["id"]] += R.randint(1, 3)
        self.pr = PR[self.repo["id"]]
        self.pr_url = f"https://github.com/northwind-pay/{self.repo['name']}/pull/{self.pr}"
        self.ev("pushed", step="push", data={"branch": self.branch, "sha": self.head, "repoId": self.repo["id"]})
        self.ev("pr_opened", step="push", msg=self.pr_url, data={"number": self.pr, "url": self.pr_url, "repoId": self.repo["id"]})
        self.go("done", "push", msg=f"PR #{self.pr} opened")
        self.tr_state = "pushed"
        if R.random() < 0.3:
            n = R.randint(1, 2)
            self.ev("lessons_found", step="learn", msg=f"{n} lesson(s)", data={"count": n})
        self.extra["learn_state"] = "done"

    def merge(self, a, b):
        t = self.t + mins(a, b)
        if t >= NOW:
            return
        if R.random() < 0.9:
            self.merged_at, self.tr_state = t, "merged"
            self.ev("pr_merged", origin="webhook", msg=f"PR #{self.pr} merged", data={"url": self.pr_url, "repoId": self.repo["id"]}, t=t)
        else:
            self.closed_at = t
            self.ev("pr_closed", origin="webhook", msg=f"PR #{self.pr} closed", data={"url": self.pr_url}, t=t)

    def save(self, **kw):
        last = max([e["created_at"] for e in EVENTS if e["ticket_key"] == self.key] or [self.t])
        row = dict(id=self.id, key=self.key, source=self.source, repo_id=self.repo["id"], title=self.title,
                   description=f"{self.title}.\n\nAcceptance criteria:\n- The reported case is covered by a test\n- No change for other callers",
                   priority=R.choice(["low", "medium", "medium", "high"]), state=self.state, revision=self.revision,
                   turns=self.turns, pr_number=self.pr, pr_url=self.pr_url or "", branch=self.branch, head_sha=self.head,
                   merged_at=self.merged_at, closed_at=self.closed_at, created_at=self.created, updated_at=last,
                   workspace_id=WS, member_id=self.by, created_by=self.by, kind=self.kind, ci_fixes=self.ci_fixes,
                   assignees=A([LOGIN[self.by]]), review_state="done" if self.state in ("done", "waiting_for_review") else "",
                   learn_state=self.extra.get("learn_state", ""), wait_reason="", queued_at=None, after_approve="pr")
        row.update(kw)
        TICKETS.append(row)
        TREPOS.append(dict(workspace_id=WS, ticket_id=self.id, repo_id=self.repo["id"], position=0, branch=self.branch,
                           head_sha=self.head, pr_number=self.pr, pr_url=self.pr_url or "", assignees=A([LOGIN[self.by]]),
                           merged_at=self.merged_at, closed_at=self.closed_at, files=self.files,
                           state="dropped" if self.state in ("rejected", "failed") else self.tr_state))
        return self


def pick_repo():
    return R.choices([r["id"] for r in REPOS], [r["weight"] for r in REPOS])[0]


def pick_kind():
    return R.choices(["code", "bug", "test", "plan", "analysis"], [68, 18, 7, 4, 3])[0]


def pv_for(days_ago):
    return "v12" if days_ago > 60 else "v13" if days_ago > 28 else "v14"


# ---------------------------------------------------------------- history


def history_ticket(created, days_ago, compress=1.0):
    p = 1 - days_ago / DAYS  # 0 = three months ago, 1 = today
    repo = pick_repo()
    kind = pick_kind()
    snap = (dict(ids), {k: v for k, v in SEQ.items()}, dict(PR), len(TICKETS), len(RUNS), len(EVENTS), len(CALLS),
            len(RESULTS), len(QUESTIONS), len(TREPOS))
    t = T(repo, created, kind=kind)
    pv = pv_for(days_ago)
    ask = R.random() < 0.28 - 0.08 * p
    if t.analyze(pv, ask=ask) == "asked":
        t.answer(10 * compress, (240 - 170 * p) * compress)
    if kind in ("plan", "analysis"):
        rid = t.run("code", OPUS, R.uniform(5, 12), R.randint(8, 16), pv=pv)
        t.result(rid, {"summary": f"{t.title}: report ready."},
                 report=f"# {t.title}\n\n## Findings\n\n- The current flow touches three services.\n- Two of them already share a retry helper.\n\n## Recommendation\n\nStart with the API change, then the dashboard.")
        t.go("waiting_for_review", "code", msg="report ready")
        t.wait(20 * compress, 300 * compress)
        t.go("done", "", origin="web", msg="accepted", user=t.by)
        t.extra["learn_state"] = "done"
    else:
        first_try = R.random() < 0.6 + 0.27 * p
        rounds = 0 if first_try else R.choice([1, 1, 2])
        roll = R.random()
        fail = None
        if roll < 0.10 - 0.07 * p:
            fail = R.choice(["checks", "checks", "max_turns", "stopped"])
        rejected = fail is None and R.random() < 0.07 - 0.04 * p
        limited = R.random() < 0.06
        for rnd in range(rounds + 1):
            last = rnd == rounds
            if limited and rnd == 0:
                t.code(pv, p, fail="rate_limited")
                t.go("rate_limited", "code", msg="Claude limit reached; resumes at the reset")
                t.wait(40 * compress, 160 * compress)
            rid = t.code(pv, p, fail=fail if last and fail in ("max_turns", "stopped") else None,
                         fix=1 if fail == "checks" and last else 0)
            if last and fail == "max_turns":
                t.ev("error", step="code", level="error", msg="Claude stopped: maximum turns reached", run=rid)
                t.go("failed", "code", msg="stopped: too many turns")
                break
            if last and fail == "stopped":
                t.go("failed", "code", origin="web", msg="stopped by you", user=t.by)
                break
            checks = t.checks(rid, ok=not (last and fail == "checks"))
            if last and fail == "checks":
                t.go("failed", "checks", msg="checks failed after 2 fix attempts")
                break
            t.ready(rid, checks, p)
            if not last:
                t.feedback(15 * compress, 600 * compress)
        if t.state == "failed":
            # A person looked at it: most get a retry that works, the rest are closed.
            t.wait(20 * compress, 300 * compress)
            if R.random() < 0.75:
                t.go("coding", "code", origin="web", msg="retry", user=t.by)
                rid = t.code(pv, p)
                t.ready(rid, t.checks(rid), p)
            else:
                t.go("rejected", "", origin="web", msg="closed after failing", user=t.by)
        if t.state == "waiting_for_review":
            if rejected:
                t.wait(30 * compress, 600 * compress)
                t.go("rejected", "", origin="web", msg="rejected: not needed after the API change", user=t.by)
            else:
                t.approve_and_push(10 * compress, (900 - 600 * p) * compress)
                if t.state == "done":
                    t.merge(60, 1800 - 1000 * p)
    if t.t >= NOW - dt.timedelta(minutes=10) or max(e["created_at"] for e in EVENTS[snap[5]:]) >= NOW:
        # Did not finish before now: roll back and let the caller retry, faster.
        ids.clear(); ids.update(snap[0]); SEQ.clear(); SEQ.update(snap[1]); PR.clear(); PR.update(snap[2])
        for lst, n in ((TICKETS, snap[3]), (RUNS, snap[4]), (EVENTS, snap[5]), (CALLS, snap[6]), (RESULTS, snap[7]),
                       (QUESTIONS, snap[8]), (TREPOS, snap[9])):
            del lst[n:]
        if t.title in TITLES[repo]:
            _pool[repo].append(t.title)
        return None
    return t.save()


for days_ago in range(DAYS, 0, -1):
    p = 1 - days_ago / DAYS
    day = NOW - dt.timedelta(days=days_ago)
    weekend = day.weekday() >= 5
    n = max(0, round(R.gauss((1.1 + 3.2 * p) * (0.25 if weekend else 1.0), 0.8)))
    for _ in range(n):
        created = at_day(days_ago, 9, 19)
        for compress in (1.0, 0.4, 0.15, 0.05):
            if history_ticket(created, days_ago, compress):
                break

# today, finished already
for _ in range(4):
    created = NOW.replace(hour=8, minute=0, second=0) + mins(0, max(10, (NOW.hour - 9) * 60))
    if created < NOW - dt.timedelta(hours=1):
        for compress in (0.1, 0.05, 0.02):
            if history_ticket(created, 0.2, compress):
                break

# ---------------------------------------------------------------- open work, right now


def recent(hours):
    return NOW - dt.timedelta(hours=hours)


# Running: two coding, one analyzing (3 of 3 slots).
for repo, title, ago in ((1, "Add webhook replay endpoint for merchants", 0.6), (2, "Bulk refunds from the transactions table", 0.35)):
    t = T(repo, recent(ago + 0.4), title=title)
    t.analyze("v14")
    t.code("v14", 1.0, live=True)
    t.save()
t = T(4, recent(0.15), title="Fallback to SMS when Telegram delivery fails")
t.analyze("v14", live=True)
t.save()

# Waiting for review.
for repo, title, ago in ((1, "Expose settlement fees in GET /payouts/{id}", 5), (2, "Merchant switcher in the top bar", 2.5),
                         (5, "Idempotent postings by external reference", 26)):
    t = T(repo, recent(ago), kind="code" if repo != 5 else "bug", title=title)
    t.analyze("v14")
    rid = t.code("v14", 1.0)
    t.ready(rid, t.checks(rid), 1.0)
    t.save()

# Waiting for answers.
for repo, title, ago in ((1, "Partial captures for pre-authorized payments", 3), (3, "Pay by saved card on the checkout screen", 20)):
    t = T(repo, recent(ago), title=title)
    t.analyze("v14", ask=True)
    t.save()

# Failed: checks did not pass.
t = T(5, recent(7), kind="bug", title="Balance snapshot misses postings at 23:59:59")
t.analyze("v14")
rid = t.code("v14", 1.0, fix=2)
checks = t.checks(rid, ok=False)
t.go("failed", "checks", msg="checks failed after 2 fix attempts")
t.save()

# Queued.
for i, (repo, title) in enumerate(((2, "Show chargeback status on the payment page"), (1, "Weekly payout summary email data endpoint"),
                                   (4, "Per-merchant sender name for SMS"), (3, "Haptic feedback on successful payment"))):
    t = T(repo, recent(0.5 - i * 0.08), title=title)
    t.save(wait_reason="slots", queued_at=t.created)

# PR reviews (agnts reviewing teammates' pull requests).
REVIEWS = [(1, "aziz-r", "Move payout cutoff to merchant timezone", 1203, "has_concerns", 26),
           (2, "dilnoza-k", "Transactions: virtualized table for 10k rows", 861, "looks_good", 50),
           (1, "schen", "Refactor Click webhook signature verification", 1197, "has_concerns", 74),
           (4, "madina-y", "Telegram: inline buttons for approvals", 271, "looks_good", 4)]
DRAFTS = []
for repo, author, title, number, verdict, ago in REVIEWS:
    t = T(repo, recent(ago), kind="review", source="git", title=title, by=1)
    t.pr, t.pr_url = number, f"https://github.com/northwind-pay/{REPO[repo]['name']}/pull/{number}"
    t.wait(1, 4)
    t.go("analyzing", "review", msg="reviewing the pull request")
    rid = t.run("review", SONNET, R.uniform(3, 7), R.randint(6, 14))
    findings = [] if verdict == "looks_good" else [
        {"severity": "major", "category": "correctness", "file": REPO[repo]["files"][1], "line": 88,
         "title": "Cutoff uses server time, not the merchant's timezone", "detail": "time.Now() is UTC on the servers.",
         "suggestion": "Pass the merchant location into cutoffFor().", "confidence": 0.86, "pass": "failures"},
        {"severity": "minor", "category": "tests", "file": REPO[repo]["files"][2], "line": 40,
         "title": "No test for the DST-free Asia/Tashkent case", "detail": "", "suggestion": "Add a table case.", "confidence": 0.7, "pass": "tests"}]
    t.result(rid, {"revision": 1, "model": SONNET, "modelReason": "auto: medium", "verdict": verdict,
                   "summary": "Clean change overall." if not findings else "One real bug and a missing test.",
                   "strengths": ["Small, focused diff", "Good naming"], "findings": findings})
    t.ev("review_done", step="review", run=rid, data={"verdict": verdict, "findings": len(findings),
                                                      "counts": {"blocker": 0, "major": 1 if findings else 0, "minor": 1 if findings else 0},
                                                      "worst": "major" if findings else "", "revision": 1, "model": SONNET})
    state = "waiting_for_review" if ago < 10 else "done"
    t.go(state, "review", msg="review ready" if state == "waiting_for_review" else "review published")
    for i, f in enumerate([{"kind": "summary", "severity": "", "title": "Summary", "body": "One real bug and a missing test." if findings else "Looks good to merge."}] + findings):
        DRAFTS.append(dict(workspace_id=WS, ticket_id=t.id, repo_id=repo, number=number, kind=f.get("kind", "finding"),
                           key=f"k{t.id}-{i}", severity=f["severity"], category=f.get("category", ""), title=f["title"],
                           confidence=f.get("confidence", 0), pass_=f.get("pass", ""), path=f.get("file", ""), line=f.get("line", 0),
                           body=f.get("body") or f"{f['detail']} {f['suggestion']}".strip(),
                           state="draft" if state == "waiting_for_review" else "published", author_id=1,
                           created_at=t.t, updated_at=t.t))
    t.save(pull_request=J({"number": number, "url": t.pr_url, "title": title, "author": author, "headRef": "feat/" + str(number),
                           "headSha": sha(), "baseRef": "main", "fetchRef": f"refs/pull/{number}/head", "draft": False,
                           "state": "open", "login": "rustambek", "why": "review_requested", "updatedAt": t.t.isoformat()}),
           review_state="done")
for d in DRAFTS:
    d["pass"] = d.pop("pass_")

# ---------------------------------------------------------------- CI failures

CI = [
    (1, "test", "TestSettlementCutoff", "flaky", "flaky", 9, 6, 20, None, ""),
    (1, "lint", "golangci-lint: unused parameter in fees.Calculate", "code", "fixed", 2, 0, 12, 11, "auto"),
    (2, "e2e", "checkout.spec.ts: refund dialog never closes", "test", "fixing", 3, 0, 1, None, "auto"),
    (2, "build", "vite build: cannot resolve 'date-fns/locale/uz'", "dependency", "fixed", 4, 0, 33, 32, "auto"),
    (3, "test", "payment_flow_test.dart: golden mismatch on Pixel 7", "test", "open", 2, 0, 0.3, None, ""),
    (4, "test", "sms.test.ts: Eskiz sandbox returns 503", "infra", "infra", 5, 0, 6, None, ""),
    (5, "test", "TestBalanceSnapshot fails at day boundary", "code", "triage", 1, 0, 0.3, None, ""),
    (1, "deploy-staging", "Migration 0142 times out on staging", "config", "resolved", 1, 0, 44, 43, ""),
    (2, "unit", "VolumeChart.spec.ts: snapshot out of date", "test", "fixed", 2, 0, 18, 18, "auto"),
    (1, "test", "TestPaymeWebhookRetry is flaky under -race", "flaky", "flaky", 7, 4, 52, None, ""),
]
CIROWS = []
for i, (repo, job, title, cls, status, count, flaky, first_d, fixed_d, auto) in enumerate(CI, 1):
    first = NOW - dt.timedelta(days=first_d)
    last = NOW - dt.timedelta(days=max(0.05, (fixed_d or first_d * 0.2) - 0.3)) if fixed_d else NOW - dt.timedelta(hours=R.uniform(1, 30))
    last = max(last, first)
    key = ""
    if auto:
        t = T(repo, first + dt.timedelta(minutes=8), kind="bug", source="ci", title=f"CI: {title}", by=1)
        t.analyze("v14")
        rid = t.code("v14", 1.0)
        t.ready(rid, t.checks(rid), 1.0)
        if status == "fixing":
            pass
        else:
            t.approve_and_push(5, 60)
            if t.state == "done":
                t.merge(30, 120)
        t.ci_fixes = 1
        t.save()
        key = t.key
    occ = [{"runId": 9100000 + i * 100 + k, "url": f"https://github.com/northwind-pay/{REPO[repo]['name']}/actions/runs/{9100000 + i * 100 + k}",
            "sha": sha()[:12], "job": job, "at": (first + (last - first) * k / max(1, count - 1)).isoformat(), "flaky": k < flaky}
           for k in range(min(count, 20))]
    CIROWS.append(dict(id=i, workspace_id=WS, repo_id=repo, branch="main", workflow="ci", job=job, fingerprint="%016x" % R.getrandbits(64),
                       class_=cls, title=title, status=status, count=count, flaky_count=flaky, first_seen_at=first, last_seen_at=last,
                       first_sha=sha()[:12], last_sha=sha()[:12], occurrences=J(occ), ticket_key=key,
                       fixed_sha=sha()[:12] if fixed_d else "", fixed_at=NOW - dt.timedelta(days=fixed_d) if fixed_d else None,
                       updated_at=last))
for c in CIROWS:
    c["class"] = c.pop("class_")

# ---------------------------------------------------------------- write tickets and their trail

EVENTS.sort(key=lambda e: e["created_at"])
for i, e in enumerate(EVENTS, 1):
    e["id"] = i
    e["data"] = J(e["data"])
ins("tickets", TICKETS)
ins("ticket_repos", TREPOS)
ins("runs", RUNS)
ins("results", RESULTS)
ins("claude_calls", CALLS)
ins("questions", [dict(q, options=J(q["options"])) for q in QUESTIONS])
ins("events", EVENTS)
ins("review_drafts", DRAFTS)
ins("ci_failures", CIROWS)
ins("ci_watches", [dict(repo_id=r, workspace_id=WS, config=J({"enabled": True, "branches": ["main"], "ignore": ["*deploy*", "*release*"],
                                                                  "prs": "comment", "autoFix": True})) for r in (1, 2, 4, 5)])
for r in REPOS:
    OUT.append(f"UPDATE repositories SET task_seq = {SEQ[r['id']]} WHERE id = {r['id']};")

done_keys = [t["key"] for t in TICKETS if t["state"] == "done" and t["kind"] != "review"]

# ---------------------------------------------------------------- learning: lessons, rules, reflections, follow-ups

LESSONS = [
    (1, "idempotency-keys", "Idempotency keys make retries safe", "pattern", "intermediate",
     "Store the request hash with the key and replay the first response instead of running the handler twice."),
    (1, "money-as-integers", "Keep money in integer minor units", "pattern", "beginner",
     "float64 loses tiynlar on large UZS amounts; the money package stores int64 minor units."),
    (1, "context-timeouts", "Pass deadlines with context, not time.Sleep", "language", "intermediate",
     "A context deadline stops the whole call chain; sleeping in a handler only delays the failure."),
    (1, "advisory-locks", "Postgres advisory locks for single-runner jobs", "architecture", "advanced",
     "pg_try_advisory_lock lets only one replica run the settlement job without a separate lock service."),
    (1, "table-tests", "Table-driven tests for fee rules", "testing", "beginner",
     "One test function, one row per merchant tier: new tiers are a one-line change."),
    (1, "webhook-signatures", "Check webhook timestamps, not only signatures", "security", "intermediate",
     "A valid signature on an old payload is a replay; reject anything older than five minutes."),
    (2, "vue-query-keys", "Query keys must include every filter", "library", "intermediate",
     "If a filter is not in the key, vue-query serves the cached page for the old filter."),
    (2, "intl-dates", "Format dates with Intl, in the merchant's timezone", "language", "beginner",
     "new Date() renders in the browser's zone; Intl.DateTimeFormat takes an explicit timeZone."),
    (2, "virtual-lists", "Virtualize long tables", "performance", "intermediate",
     "Rendering 10k rows blocks the main thread; only the visible rows need DOM nodes."),
    (3, "flutter-safearea", "SafeArea and the iOS keyboard", "library", "beginner",
     "Wrap forms in SafeArea and let Scaffold resize for the keyboard instead of fixed paddings."),
    (3, "golden-tests", "Pin fonts in golden tests", "testing", "intermediate",
     "Golden images differ across machines unless the test loads the same font files."),
    (4, "dead-letter-queues", "Dead-letter queues for failed sends", "architecture", "intermediate",
     "After N retries a message moves aside instead of blocking the queue; a person can replay it."),
    (4, "rate-limits-per-key", "Rate-limit per phone number, not globally", "security", "beginner",
     "A global limit lets one abuser block everyone; a per-key bucket isolates them."),
    (5, "double-entry", "Every posting balances to zero", "algorithm", "beginner",
     "Debits and credits in one transaction must sum to zero; check it before commit."),
    (5, "materialized-views", "Refresh materialized views concurrently", "performance", "advanced",
     "REFRESH ... CONCURRENTLY needs a unique index but does not block readers."),
    (1, "errgroup", "errgroup for parallel calls that fail together", "library", "intermediate",
     "errgroup cancels the other calls when one fails, so the handler returns early."),
]
rows = []
for i, (repo, slug, title, cat, lvl, summary) in enumerate(LESSONS, 1):
    created = NOW - dt.timedelta(days=R.uniform(1, 80))
    rows.append(dict(id=i, workspace_id=WS, repo_id=repo, ticket_key=R.choice([k for k in done_keys if k.startswith(REPO[repo]["prefix"])] or done_keys),
                     slug=slug, title=title, category=cat, level=lvl, summary=summary,
                     explanation=summary + "\n\nIn this repository the pattern shows up wherever money or retries are involved.",
                     why_here=f"agnts used it while working in {REPO[repo]['name']}.",
                     refs=J([{"path": REPO[repo]["files"][0], "line": R.randint(10, 120), "note": "where it is used"}]),
                     quiz=J([{"question": f"What does this lesson protect against? ({title})",
                              "options": ["Repeating side effects or wrong results", "Slower builds", "Larger bundles"],
                              "answer": 0, "explanation": summary}]),
                     reading=J([{"title": "Background reading", "url": "https://go.dev/doc/effective_go" if repo in (1, 5) else "https://developer.mozilla.org/"}]),
                     learned_at=created + dt.timedelta(days=R.uniform(0.2, 4)) if i % 3 != 0 else None, created_at=created))
ins("lessons", rows)

RULES = [
    (1, "Money is never a float", "Use the money package (int64 minor units) for every amount. Never float64.", "ready", "rule", "", 0, 0, "prompt"),
    (1, "Migrations are additive", "Never drop or rename a column in the same release that stops using it.", "ready", "rule", "", 0, 0, "prompt"),
    (None, "Conventional commit messages", "feat:, fix:, chore: prefixes; the ticket key in the body.", "ready", "rule", "", 0, 0, "prompt"),
    (2, "All user-facing strings go through i18n", "No literal text in templates; add keys to uz, ru and en.", "ready", "rule", "", 0, 0, "skill"),
    (1, "Webhook handlers return 200 fast", "Acknowledge first, process on the queue; providers retry on slow responses.", "ready", "context", "pack:go", 0, 0, "prompt"),
    (None, "Run the race detector for concurrency changes", "When a change touches goroutines or channels, run go test -race.", "suggested", "tip", "reflect", 0.86, 6, "prompt"),
    (2, "Prefer existing DataTable over new tables", "Three PRs this month added one-off tables; DataTable already has sorting and paging.", "suggested", "rule", "reflect", 0.78, 4, "prompt"),
    (3, "Widget tests for every new screen", "Reviewers asked for widget tests on four screens in a row.", "suggested", "rule", "reflect", 0.71, 4, "prompt"),
    (4, "Queue names", "Which naming should queues follow?", "questions", "rule", "", 0, 0, "prompt"),
    (5, "Postings are append-only", "Corrections are new reversing postings; never UPDATE a posting.", "ready", "rule", "", 0, 0, "prompt"),
]
rows = []
for i, (repo, title, body, status, kind, src, conf, evid, delivery) in enumerate(RULES, 1):
    created = NOW - dt.timedelta(days=R.uniform(2, 85))
    rows.append(dict(id=i, workspace_id=WS, repo_id=repo, title=title, body=body, status=status, kind=kind, source=src,
                     confidence=conf, evidence=evid, delivery=delivery, enabled=status == "ready",
                     interpretation=body if status == "ready" else "", analyzed_at=created if status == "ready" else None,
                     questions=J([{"text": "Should queue names include the environment?", "options": ["notify.prod.sms", "sms (environment from config)"], "round": 1}]
                                 if status == "questions" else []),
                     source_ticket=R.choice(done_keys) if src == "reflect" else "", last_seen=NOW - dt.timedelta(days=R.uniform(0, 5)) if src == "reflect" else None,
                     reason="Seen in review feedback on several tickets." if src == "reflect" else "",
                     skill_description="Use when adding user-facing text." if delivery == "skill" else "",
                     enforce=J({"on": "diff", "paths": ["**/*.go"], "pattern": "float64", "action": "warn", "message": "Use money.Amount"}) if i == 1 else None,
                     created_at=created, updated_at=created))
ins("rules", rows)

ins("reflections", [dict(id=i, workspace_id=WS, ticket_key=R.choice(done_keys), repo_id=pick_repo(),
                         source=R.choice(["changes", "changes", "run", "rejected"]), feedback=R.choice(FEEDBACK), status="done",
                         suggested=R.choice([0, 1, 1, 2]), created_at=(c := NOW - dt.timedelta(days=R.uniform(1, 85))), updated_at=c)
                    for i in range(1, 19)])

SUGG = [("Add an index on payments(merchant_id, created_at)", "gap"), ("Cover the refund timeout path with a test", "unfinished"),
        ("Split the settlement job before adding new currencies", "prerequisite"), ("Extract a shared DateRange picker", "split"),
        ("Remove the v1 /charge endpoint after the flag is on for 30 days", "unfinished"), ("Document the webhook retry policy", "gap"),
        ("Add the Russian translations missing on the payouts page", "gap"), ("Add a load test for GET /balance", "gap")]
rows = []
done_tickets = [t for t in TICKETS if t["state"] == "done" and t["kind"] == "code"]
for i, (title, typ) in enumerate(SUGG, 1):
    tk = R.choice(done_tickets[-60:])
    status = "open" if i <= 3 else R.choice(["accepted", "accepted", "dismissed"])
    rows.append(dict(id=i, workspace_id=WS, ticket_id=tk["id"], source=R.choice(["work", "review", "analyze"]), type=typ,
                     title=title, description="", serves=tk["title"], kind="code", priority=R.choice(["low", "medium", "high"]),
                     status=status, decided_at=None if status == "open" else NOW - dt.timedelta(days=R.uniform(0, 20)),
                     created_at=NOW - dt.timedelta(days=R.uniform(0.5, 25)), repo_ids=A([tk["repo_id"]], "bigint")))
ins("ticket_suggestions", rows)

ins("reviewer_profiles", [
    dict(workspace_id=WS, login="dilnoza-k", notes=7, learned_through=6, updated_at=NOW - dt.timedelta(days=2),
         body="- Wants every user-facing string in i18n files.\n- Asks for screenshots in UI PRs.\n- Prefers composables over mixins."),
    dict(workspace_id=WS, login="aziz-r", notes=9, learned_through=9, updated_at=NOW - dt.timedelta(days=1),
         body="- Blocks float money anywhere.\n- Wants a regression test for every bug fix.\n- Reads migrations first."),
    dict(workspace_id=WS, login="schen", notes=4, learned_through=3, updated_at=NOW - dt.timedelta(days=5),
         body="- Cares about error messages clients see.\n- Asks for OpenAPI updates with API changes."),
])
NOTES = [("aziz-r", "rereview", "Asked again for the timeout test after the second revision."),
         ("dilnoza-k", "dismissed", "Dismissed the nit about prop naming: team style allows it."),
         ("aziz-r", "manual", "Prefers errors.Is over string matching."), ("schen", "manual", "Wants examples in OpenAPI for new fields."),
         ("dilnoza-k", "host_comment", "Requested a screenshot of the dark theme."), ("aziz-r", "rereview", "Migration should be split in two."),
         ("schen", "dismissed", "Dismissed: the extra log line is intended."), ("dilnoza-k", "manual", "Use the shared DataTable.")]
ins("reviewer_notes", [dict(id=i, workspace_id=WS, login=l, kind=k, note=n, repo_id=1 if l != "dilnoza-k" else 2,
                            ticket_key=R.choice(done_keys), created_at=NOW - dt.timedelta(days=R.uniform(0.5, 40)))
                       for i, (l, k, n) in enumerate(NOTES, 1)])

ins("repo_briefs", [
    dict(repo_id=1, workspace_id=WS, status="idle", revision=4, surveyed_at=NOW - dt.timedelta(days=3), approved_at=NOW - dt.timedelta(days=3),
         body="## Architecture\n\nHTTP handlers in `internal/httpapi` call services in `internal/<domain>`. Postgres via pgx; Redis only for rate limits.\n\n"
              "## Recipes\n\n- New endpoint: add it to `openapi.yaml`, run `make gen`, implement the generated interface.\n- New migration: `migrations/NNNN_name.sql`, additive only.\n\n"
              "## Conventions\n\n- Money is `money.Amount` (int64 tiyin).\n- Errors wrap with `%w`; handlers map them in `statusOf`.\n\n"
              "## Pitfalls\n\n- The settlement job runs in Asia/Tashkent time.\n- Payme retries webhooks for 12 hours; handlers must be idempotent."),
    dict(repo_id=2, workspace_id=WS, status="idle", revision=2, surveyed_at=NOW - dt.timedelta(days=9), approved_at=NOW - dt.timedelta(days=8),
         body="## Architecture\n\nVue 3 with `<script setup>`, vue-query for server state, Pinia only for the session.\n\n"
              "## Conventions\n\n- Strings in `src/i18n/{uz,ru,en}.json`.\n- Tables use `DataTable.vue`.\n\n## Pitfalls\n\n- Dates must be formatted in the merchant's timezone."),
])

# ---------------------------------------------------------------- assistant

CONVS = [
    ("What is blocking the checkout release?", [
        ("user", "What is blocking the checkout release?"),
        ("assistant", "Two things. PAY tickets waiting for your answers: partial captures need a decision on the fee. "
                      "And CI on mobile-app has a golden test mismatch since this morning. Everything else in the Checkout group is merged.",
         [{"kind": "ticket", "key": "PAY-1"}, {"kind": "ci", "id": 5}])]),
    ("How did we do this week?", [
        ("user", "How did we do this week compared to last week?"),
        ("assistant", "Better on every line: more tickets pushed, a higher first-try rate, and shorter waits for review. "
                      "Most of the gain is in payments-api, where the new team rule about money types removed a whole class of review comments.", [])]),
    ("Flaky tests", [
        ("user", "Which tests are flaky right now?"),
        ("assistant", "TestSettlementCutoff (6 flaky runs in 20 days) and TestPaymeWebhookRetry under -race (4). "
                      "Both are in payments-api and both depend on wall-clock time. I can open a ticket to inject a clock.",
         [{"kind": "ci", "id": 1}, {"kind": "ci", "id": 10}]),
        ("user", "Yes, open it for the settlement one."),
        ("assistant", "Done: queued a ticket to inject a clock into the settlement job and make TestSettlementCutoff deterministic.", [])]),
    ("Explain idempotency keys", [
        ("user", "Explain how idempotency keys work in payments-api."),
        ("assistant", "The handler hashes the request body and stores it with the key. A repeated key with the same hash replays the stored "
                      "response; a different hash returns 409. There is a lesson on it from last month.", [{"kind": "lesson", "id": 1}])]),
]
conv_rows, msg_rows, mid = [], [], 0
for i, (title, msgs) in enumerate(CONVS, 1):
    t = NOW - dt.timedelta(days=[0.1, 1.5, 3, 8][i - 1])
    conv_rows.append(dict(id=i, workspace_id=WS, user_id=1, title=title, created_at=t, updated_at=t + dt.timedelta(minutes=2 * len(msgs))))
    for m in msgs:
        mid += 1
        t += dt.timedelta(seconds=R.uniform(20, 90))
        ai = m[0] == "assistant"
        msg_rows.append(dict(id=mid, workspace_id=WS, conversation_id=i, role=m[0], text=m[1], links=J(m[2] if ai else []),
                             status="done", model=SONNET if ai else "", tokens=R.randint(2500, 9000) if ai else 0,
                             cost_usd=round(R.uniform(0.01, 0.05), 4) if ai else 0, duration_ms=R.randint(4000, 12000) if ai else 0,
                             rating=1 if ai and R.random() < 0.5 else 0, created_at=t))
ins("assistant_conversations", conv_rows)
ins("assistant_messages", msg_rows)

# ---------------------------------------------------------------- usage, billing, API tests

snaps = []
t = NOW - dt.timedelta(days=DAYS)
while t < NOW - dt.timedelta(minutes=20):
    load = 0.15 + 0.55 * (1 - (NOW - t).days / DAYS) * (0.4 if t.weekday() >= 5 else 1) * (0.3 if t.hour < 8 or t.hour > 20 else 1)
    five = min(0.97, max(0.02, R.gauss(load, 0.12)))
    snaps.append(dict(five_hour=round(five, 3), seven_day=round(min(0.95, 0.2 + 0.5 * load + R.uniform(0, 0.1)), 3),
                      resets_at=t + dt.timedelta(hours=R.uniform(0.5, 5)), seven_day_resets_at=t + dt.timedelta(days=R.uniform(1, 7)),
                      status="allowed", created_at=t, raw=J({})))
    t += dt.timedelta(hours=2)
snaps.append(dict(five_hour=0.38, seven_day=0.54, resets_at=NOW + dt.timedelta(hours=2, minutes=14),
                  seven_day_resets_at=NOW + dt.timedelta(days=3, hours=5), status="allowed", created_at=NOW - dt.timedelta(minutes=4),
                  raw=J({"type": "rate_limit_event", "rate_limit_info": {"status": "allowed", "rateLimitType": "five_hour", "utilization": 0.38}})))
ins("usage_snapshots", snaps)

ins("payments", [dict(id=i, workspace_id=WS, provider=pv, amount_uzs=amt * 1000, credits=amt * 10, state="paid", provider_txn="%024x" % R.getrandbits(96),
                      created_by=1, created_at=(c := NOW - dt.timedelta(days=d)), performed_at=c)
                 for i, (pv, amt, d) in enumerate((("payme", 1200, 84), ("click", 1200, 55), ("payme", 2500, 21)), 1)])
ins("credit_ledger", [dict(id=i, workspace_id=WS, amount=amt * 10, reason="purchase", payment_id=i, created_by=1,
                           created_at=NOW - dt.timedelta(days=d))
                      for i, (amt, d) in enumerate(((1200, 84), (1200, 55), (2500, 21)), 1)] +
      [dict(id=4, workspace_id=WS, amount=5000, reason="grant", note="Welcome credits", created_by=None, created_at=NOW - dt.timedelta(days=118), payment_id=None)])

SPEC = {"openapi": "3.0.3", "info": {"title": "Northwind Payments API", "version": "2.4.0"},
        "paths": {"/payments": {"get": {"operationId": "listPayments", "responses": {"200": {"description": "ok"}}},
                                "post": {"operationId": "createPayment", "responses": {"201": {"description": "created"}}}},
                  "/payments/{id}": {"get": {"operationId": "getPayment", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}],
                                             "responses": {"200": {"description": "ok"}}}},
                  "/payouts": {"get": {"operationId": "listPayouts", "responses": {"200": {"description": "ok"}}}},
                  "/balance": {"get": {"operationId": "getBalance", "responses": {"200": {"description": "ok"}}}}}}
ins("swagger_suites", [dict(id=1, workspace_id=WS, name="Payments API (sandbox)", spec_url="https://sandbox.northwind.example/openapi.yaml",
                            spec=J(SPEC), base_url="https://sandbox.northwind.example", operations=J(["listPayments", "getPayment", "listPayouts", "getBalance"]),
                            repo_id=1, schedule="daily", hour=6, enabled=True, last_run_at=NOW.replace(hour=6, minute=2),
                            next_run_at=NOW.replace(hour=6, minute=0) + dt.timedelta(days=1), created_by=1, created_at=NOW - dt.timedelta(days=40))])

# ---------------------------------------------------------------- output

print("-- Generated by scripts/demo_seed.py at", NOW.isoformat())
print("BEGIN;")
print("SET LOCAL app.workspace_id = 'all';")
print("\n".join(OUT))
print("""DO $$
DECLARE r record; seq text;
BEGIN
  FOR r IN SELECT table_name FROM information_schema.columns
           WHERE table_schema = 'public' AND column_name = 'id' AND data_type = 'bigint' LOOP
    seq := pg_get_serial_sequence('public.' || r.table_name, 'id');
    IF seq IS NOT NULL THEN
      EXECUTE format('SELECT setval(%L, COALESCE((SELECT max(id) FROM public.%I), 0) + 1, false)', seq, r.table_name);
    END IF;
  END LOOP;
END $$;""")
print("COMMIT;")
print(f"-- {len(TICKETS)} tickets, {len(RUNS)} runs, {len(EVENTS)} events", file=sys.stderr)
