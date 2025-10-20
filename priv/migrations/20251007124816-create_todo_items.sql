--- migration:up
CREATE TABLE IF NOT EXISTS todo_items (
    id uuid PRIMARY KEY DEFAULT uuidv7 (),
    title text NOT NULL,
-- in a dream world these would be timstamptz to automatically handle the utc -> local time storage
--  BUT the POG library doesn't support that as of yet. We will have to hand manage time
    created_at timestamp NOT NULL DEFAULT NOW(),
    updated_at timestamp NOT NULL DEFAULT NOW(),
    completed_at timestamp
);
CREATE TRIGGER update_todo_items_updated_at
    BEFORE UPDATE ON todo_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column ();
CREATE INDEX idx_todo_items_created_at ON todo_items (created_at);

--- migration:down
DROP INDEX IF EXISTS idx_todo_items_created_at;
DROP TABLE IF EXISTS todo_items;

--- migration:end
