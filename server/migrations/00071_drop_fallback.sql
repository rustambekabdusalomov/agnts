-- +goose Up
-- The Muse fallback provider (Baseten, 00070) was removed: drop the
-- per-person limit on it and the Admin's choice of provider. Spend it made
-- stays in the ledger's history (platform:fallback, fcap:* accounts).
ALTER TABLE users DROP COLUMN IF EXISTS fallback_limit_set_at;
ALTER TABLE users DROP COLUMN IF EXISTS fallback_limit_set_by;
ALTER TABLE users DROP COLUMN IF EXISTS fallback_limit_monthly;
DELETE FROM system_settings WHERE key = 'muse_provider_mode';

-- +goose Down
ALTER TABLE users ADD COLUMN fallback_limit_monthly bigint CHECK (fallback_limit_monthly >= 0);
ALTER TABLE users ADD COLUMN fallback_limit_set_by  bigint REFERENCES users (id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN fallback_limit_set_at  timestamptz;
