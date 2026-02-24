--- migration:up:disable_transaction
CREATE INDEX CONCURRENTLY index_todo_items_updated_at ON todo_items (updated_at);

--- migration:down
DROP INDEX IF EXISTS index_todo_items_updated_at;

--- migration:end
