-- +goose Up
-- Plane as a second tracker. plane_project is the Plane project identifier
-- (WEB in WEB-123) whose work items go to the repository. Jira keys, Plane
-- keys and task prefixes share one key space; admin checks that across
-- columns, the unique index within this one. A repository's kind is plane
-- when it names a Plane project and no Jira project.
ALTER TABLE repositories ADD COLUMN plane_project text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX repositories_plane_project_idx ON repositories (plane_project) WHERE plane_project <> '';

ALTER TABLE repositories DROP CONSTRAINT repositories_kind_check,
    ADD CONSTRAINT repositories_kind_check CHECK (kind IN ('jira', 'plane', 'side'));
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local'));
ALTER TABLE integrations DROP CONSTRAINT integrations_provider_check,
    ADD CONSTRAINT integrations_provider_check CHECK (provider IN ('jira', 'plane', 'github', 'gitlab', 'telegram', 'claude'));
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_source_check,
    ADD CONSTRAINT ticket_relations_source_check CHECK (source IN ('jira', 'plane', 'user', 'agnts', 'rule', 'git'));

-- +goose Down
DELETE FROM ticket_relations WHERE source = 'plane';
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_source_check,
    ADD CONSTRAINT ticket_relations_source_check CHECK (source IN ('jira', 'user', 'agnts', 'rule', 'git'));
DELETE FROM integrations WHERE provider = 'plane';
ALTER TABLE integrations DROP CONSTRAINT integrations_provider_check,
    ADD CONSTRAINT integrations_provider_check CHECK (provider IN ('jira', 'github', 'gitlab', 'telegram', 'claude'));
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'local'));
UPDATE repositories SET kind = 'side' WHERE kind = 'plane';
ALTER TABLE repositories DROP CONSTRAINT repositories_kind_check,
    ADD CONSTRAINT repositories_kind_check CHECK (kind IN ('jira', 'side'));
DROP INDEX repositories_plane_project_idx;
ALTER TABLE repositories DROP COLUMN plane_project;
