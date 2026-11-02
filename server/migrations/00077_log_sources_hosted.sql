-- +goose Up
-- Hosted log services: Datadog, CloudWatch Logs and Splunk.
ALTER TABLE log_sources DROP CONSTRAINT log_sources_kind_check,
    ADD CONSTRAINT log_sources_kind_check CHECK (kind IN ('loki', 'elasticsearch', 'opensearch', 'graylog', 'datadog', 'cloudwatch', 'splunk', 'push'));

-- +goose Down
DELETE FROM log_sources WHERE kind IN ('datadog', 'cloudwatch', 'splunk');
ALTER TABLE log_sources DROP CONSTRAINT log_sources_kind_check,
    ADD CONSTRAINT log_sources_kind_check CHECK (kind IN ('loki', 'elasticsearch', 'opensearch', 'graylog', 'push'));
