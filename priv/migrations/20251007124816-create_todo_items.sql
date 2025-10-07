--- migration:up
BEGIN;
CREATE TABLE IF NOT EXISTS todo_items (
    id uuid PRIMARY KEY DEFAULT uuidv7 (),
    title text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW(),
    completed_at timestamptz
);
CREATE TRIGGER update_todo_items_updated_at
    BEFORE UPDATE ON todo_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column ();
CREATE INDEX idx_todo_items_created_at ON todo_items (created_at);
COMMIT;

--- migration:down
BEGIN;
DROP INDEX CONCURRENTLY IF EXISTS idx_todo_items_created_at;
DROP TABLE IF EXISTS todo_items;
COMMIT;

--- migration:end
