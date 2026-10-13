---
name: agnts-method-migrations
description: Use when creating or changing a database migration, or changing models or schema files that will need one. Shows how to change a schema without locking tables or breaking the code that is running during the deploy.
---

# Database migrations

## Rules

1. **Applied migrations are never edited.** Any change to a migration that may have run anywhere is a new migration.
2. **Schema and data changes are separate migrations.** DDL in one, backfills in another.
3. **Safe on production-sized tables.** A statement that is instant on the dev database can lock a large table for minutes.
4. **The running code keeps working during the deploy.** Old and new code run side by side for a while: expand the schema, migrate the code and data, contract later.
5. **Use the repository's tool and commands.** Create migrations the way the existing ones were created (a Makefile target or package script first), with the next number or timestamp in their sequence.

## PostgreSQL recipes

**Add a column.** Nullable, or with a constant default (instant since PostgreSQL 11). `NOT NULL` on an existing table needs a default, or a backfill first and the constraint after.

**Add an index to an existing table.** `CREATE INDEX CONCURRENTLY`, which cannot run inside a transaction. If the tool wraps each migration in one, use its opt-out (golang-migrate and goose: put it in its own migration, goose with `-- +goose NO TRANSACTION`; Rails: `disable_ddl_transaction!` and `algorithm: :concurrently`; Django: `AddIndexConcurrently` with `atomic = False`; Alembic: `postgresql_concurrently=True` in an `autocommit_block()`).

**Add a constraint or foreign key to an existing table.** Add it `NOT VALID`, then `VALIDATE CONSTRAINT` in a later migration; validation does not block writes.

**Rename a column or table.** Never in one step. Add the new column, write both, backfill, switch reads to the new one, then drop the old one in a later change, after the new code is deployed everywhere.

**Drop a column.** First stop the code from reading it (and, for ORMs that select all columns, mark it ignored), deploy, then drop it in a later change.

**Change a column's type.** Most type changes rewrite the table. Use the add-new-column path above unless the change is known to be free (for example `varchar(n)` to a larger `n` or to `text`).

**Backfill data.** In batches by primary key (`WHERE id > $last ORDER BY id LIMIT 1000`), idempotent so it can be re-run, and without importing application models that may change later; use plain SQL or a frozen copy.

## MySQL notes

- Prefer `ALGORITHM=INPLACE, LOCK=NONE` (or `INSTANT` for adding columns in 8.0) and let the statement fail rather than silently copy the table.
- DDL is not transactional: a migration that fails halfway stays half applied. Keep one DDL statement per migration where the tool allows it.

## Creating a migration

Use the repository's own command when it has one. Otherwise:

| Tool | Command |
| --- | --- |
| golang-migrate | `migrate create -ext sql -dir <dir> -seq <name>` |
| goose | `goose -dir <dir> create <name> sql` |
| Prisma | `npx prisma migrate dev --name <name>` (edit the SQL before applying when it is unsafe) |
| Drizzle | `npx drizzle-kit generate` |
| Django | `python manage.py makemigrations <app>` |
| Alembic | `alembic revision --autogenerate -m "<name>"`, then read and fix what it generated |
| Rails | `bin/rails generate migration <Name>` |
| Laravel | `php artisan make:migration <name>` |
| Flyway | a new `V<next>__<name>.sql` file in the migration directory |

## Before you finish

- The migration applies on the dev database the repository sets up, and the down step (or the written rollback) undoes it.
- Generated files the repository commits (schema dumps, ORM models, generated clients) match the migration.
- Your summary says what is unsafe to run on a large table, if anything, and which later change finishes an expand-contract sequence.
