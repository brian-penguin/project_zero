--- migration:up
CREATE TABLE IF NOT EXISTS todo_items (
    id uuid PRIMARY KEY DEFAULT uuidv7 (),
    title text NOT NULL,
    created_at timestamp NOT NULL DEFAULT NOW(),
    updated_at timestamp NOT NULL DEFAULT NOW(),
    completed_at timestamp
);
CREATE TRIGGER update_todo_items_updated_at
    BEFORE UPDATE ON todo_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column ();

--- migration:down
  DROP INDEX IF EXISTS idx_todo_items_created_at;
  DROP TABLE IF EXISTS todo_items;

--- migration:end
