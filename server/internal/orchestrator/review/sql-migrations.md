# Database migration checklist

- Applied migrations are never edited: a change is a new migration.
- Each migration can run on the production data size: no full-table rewrites or long locks on large tables (add columns nullable or with defaults the database can apply cheaply; build indexes concurrently where supported; backfill in batches).
- Old code keeps working with the new schema during the deploy (expand, then migrate, then contract): no drop or rename of a column the running code still reads.
- Down migrations (or a written rollback) exist and match the up migration.
- New foreign keys and frequently filtered columns have indexes; uniqueness is enforced by constraints, not only in code.
- Data migrations are idempotent and do not depend on application models that will change later.
- Defaults, NOT NULL and check constraints match what the code assumes.
- Generated schema files, ORM models and the migration agree.
