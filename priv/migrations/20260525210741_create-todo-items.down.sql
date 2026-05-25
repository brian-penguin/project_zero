BEGIN;

DROP INDEX IF EXISTS idx_todo_items_created_at;
DROP TABLE IF EXISTS todo_items;

COMMIT;


