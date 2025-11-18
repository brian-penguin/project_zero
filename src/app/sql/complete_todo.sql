UPDATE todo_items SET completed_at = NOW() WHERE id = $1;
