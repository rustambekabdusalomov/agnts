-- +goose Up
-- Each call records the module it ran on and the account that paid: a
-- run's stages can use different accounts (analysis on a member's own
-- Claude account, coding on the workspace's credits), and only the calls
-- on credits are charged. Calls from before take their run's account.
ALTER TABLE claude_calls
  ADD COLUMN provider      text    NOT NULL DEFAULT '',
  ADD COLUMN connection_id bigint  REFERENCES claude_connections (id) ON DELETE SET NULL,
  ADD COLUMN on_credits    boolean NOT NULL DEFAULT false;

UPDATE claude_calls c SET provider = CASE WHEN c.model LIKE 'muse:%' THEN 'muse' WHEN c.model LIKE 'codex:%' THEN 'codex' ELSE 'claude' END;
UPDATE claude_calls c SET connection_id = r.claude_connection_id, on_credits = r.on_credits
  FROM runs r WHERE r.id = c.run_id;
UPDATE claude_calls c SET connection_id = d.claude_connection_id, on_credits = d.on_credits
  FROM document_runs d WHERE d.id = c.document_run_id;

-- +goose Down
ALTER TABLE claude_calls DROP COLUMN provider, DROP COLUMN connection_id, DROP COLUMN on_credits;
