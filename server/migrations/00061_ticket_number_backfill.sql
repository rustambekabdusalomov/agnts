-- +goose Up
-- Every ticket has a number people see: the team's own, else its key.
-- New tickets get their key when created without one; this gives the
-- older ones theirs. updated_at is left alone: nothing about the work
-- changed.
UPDATE tickets SET ticket_number = key WHERE ticket_number = '';

-- +goose Down
-- A number equal to the key reads the same as none (Ticket.Number).
UPDATE tickets SET ticket_number = '' WHERE ticket_number = key;
