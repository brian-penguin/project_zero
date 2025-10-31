--- migration:up
CREATE INDEX idx_todo_items_created_at ON todo_items (created_at);

--- migration:down
DROP INDEX IF EXISTS idx_todo_items_created_at;

--- migration:end
