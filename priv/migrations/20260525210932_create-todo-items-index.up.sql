BEGIN;
CREATE INDEX idx_todo_items_created_at ON todo_items (created_at);
CREATE INDEX idx_todo_items_updated_at ON todo_items (updated_at);
COMMIT;
