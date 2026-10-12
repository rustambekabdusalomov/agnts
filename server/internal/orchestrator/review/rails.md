# Rails review checklist

- ActiveRecord: no N+1 (`includes`/`preload`); `find_each` for batches; validations backed by DB constraints for uniqueness and presence.
- Strong parameters: permitted attributes explicit; no `permit!`.
- Authorization: every controller action checks access to the record (Pundit/CanCanCan or explicit scoping to `current_user`).
- Migrations: reversible; safe for large tables (no long locks: add index concurrently, backfill in batches); no edits of applied migrations.
- Callbacks: no network calls or heavy work in model callbacks; side effects after commit (`after_commit`).
- Jobs: idempotent, take IDs, have retries.
- Security: no `html_safe`/`raw` on user data; CSRF protection on; mass assignment protected.
- Tests: request/system specs for behaviour; fixtures or factories kept small.
