-- +goose Up
-- The order a person puts their modules in, the first being their default
-- module. It only orders the modules an Admin lets them use (users.modules
-- or the general default); NULL keeps the Admin's order.
ALTER TABLE users ADD COLUMN module_order text[] CHECK (module_order <@ ARRAY['muse', 'claude', 'codex']::text[]);

-- +goose Down
ALTER TABLE users DROP COLUMN module_order;
