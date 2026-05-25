BEGIN;
DROP INDEX IF EXISTS idx_todo_items_created_at;
DROP INDEX IF EXISTS idx_todo_items_updated_at;
COMMIT;
