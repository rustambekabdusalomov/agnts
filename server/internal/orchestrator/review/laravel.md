# Laravel review checklist

- Eloquent: no N+1 (eager load with `with()`); mass assignment protected (`$fillable`/`$guarded`); queries scoped to the current user or tenant.
- Validation: Form Requests or `$request->validate()` for every input; `validated()` data used, not `all()`.
- Authorization: policies or gates for actions on models; route middleware for auth.
- Migrations: new files, reversible `down()`; no edits of applied migrations; indexes for new foreign keys and filters.
- Transactions: `DB::transaction` for multi-step writes; events and jobs dispatched after commit (`afterCommit`).
- Queues: jobs idempotent, small payloads (IDs), retries and timeouts set.
- Config: `config()` in code, `env()` only in config files.
- Tests: feature tests with `RefreshDatabase`; factories for data.
