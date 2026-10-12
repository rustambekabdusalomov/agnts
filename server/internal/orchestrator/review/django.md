# Django review checklist

- Queries: no N+1 (use `select_related`/`prefetch_related`); no queries inside loops over querysets; `.exists()`/`.count()` where only that is needed; `update()`/`bulk_create` for batches.
- Migrations: one migration per change, generated, reversible where possible; data migrations use `apps.get_model`, not the model import; no destructive change without a deploy plan (add nullable column → backfill → enforce).
- Transactions: multi-step writes in `transaction.atomic()`; side effects (emails, tasks) in `transaction.on_commit`.
- Security: views check permissions (`login_required`, object-level checks); querysets filtered by the current user/tenant; no `raw()`/`extra()` with user input; `mark_safe` only on trusted strings; CSRF not disabled.
- Forms and serializers validate all input; DRF serializers declare `read_only_fields` for server-set values.
- Settings: no secrets in settings files; `DEBUG` stays off in production paths.
- Signals: avoided for core logic; no hidden queries in `save()` overrides.
- Celery: tasks idempotent, take IDs not model instances, have retries with backoff.
- Tests: `TestCase`/pytest-django with factories; assert queries with `assertNumQueries` where performance matters.
