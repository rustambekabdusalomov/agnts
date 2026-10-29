-- +goose Up
-- A person's monthly credit limit, set by an Admin: runs on agnts's Muse
-- key stop once the person spent it this calendar month, whatever paid
-- (their free credits or the workspace's). 0 is no limit. The month's
-- room is a cap account in agnts-muse's ledger (cap:user:<id>:<YYYY-MM>).
ALTER TABLE users ADD COLUMN credit_limit_monthly bigint NOT NULL DEFAULT 0 CHECK (credit_limit_monthly >= 0);
ALTER TABLE users ADD COLUMN credit_limit_set_by  bigint REFERENCES users (id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN credit_limit_set_at  timestamptz;

-- +goose Down
ALTER TABLE users DROP COLUMN credit_limit_set_at;
ALTER TABLE users DROP COLUMN credit_limit_set_by;
ALTER TABLE users DROP COLUMN credit_limit_monthly;
