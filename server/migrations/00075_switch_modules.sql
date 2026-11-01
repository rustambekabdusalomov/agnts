-- +goose Up
-- Switching modules (Settings.switchModules) is on for new workspaces;
-- the ones that saved their settings before keep waiting for the module
-- they chose until someone turns it on.
UPDATE settings SET value = value || '{"switchModules": false}'::jsonb
  WHERE key = 'runtime' AND NOT value ? 'switchModules';

-- +goose Down
UPDATE settings SET value = value - 'switchModules' WHERE key = 'runtime';
