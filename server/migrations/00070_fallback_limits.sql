-- +goose Up
-- A person's monthly limit on the fallback Muse provider (Baseten), set by
-- an Admin: the credits their runs on agnts's key may spend there a
-- calendar month, whatever paid. NULL is the server's default
-- (AGNTS_MUSE_FALLBACK_USER_LIMIT), 0 is no limit. The month's room is a
-- cap account in agnts-muse's ledger (fcap:user:<id>:<YYYY-MM>) that only
-- spend on the fallback counts against.
ALTER TABLE users ADD COLUMN fallback_limit_monthly bigint CHECK (fallback_limit_monthly >= 0);
ALTER TABLE users ADD COLUMN fallback_limit_set_by  bigint REFERENCES users (id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN fallback_limit_set_at  timestamptz;

-- +goose Down
ALTER TABLE users DROP COLUMN fallback_limit_set_at;
ALTER TABLE users DROP COLUMN fallback_limit_set_by;
ALTER TABLE users DROP COLUMN fallback_limit_monthly;
