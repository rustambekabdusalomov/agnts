-- +goose Up
-- File names are searched word by word: dots and dashes split them too, so
-- "csv" finds invoice_march.csv (the parser reads "march.csv" as one token).
UPDATE chat_messages m SET file_names = f.names
FROM (SELECT chat_message_id, string_agg(translate(name, '_.-', '   '), ' ' ORDER BY id) AS names
      FROM attachments WHERE chat_message_id IS NOT NULL GROUP BY chat_message_id) f
WHERE f.chat_message_id = m.id;

-- +goose Down
SELECT 1;
