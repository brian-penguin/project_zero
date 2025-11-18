import gleam/option.{type Option, Some, None}
import wisp
import gleam/time/timestamp

pub type TodoItemStatus {
  Complete
  Incomplete
}

pub type TodoItem {
  TodoItem(id: String, title: String, status: TodoItemStatus)
}

pub fn create_todo_item(
  id: Option(String),
  title: String,
  completed_at: Option(timestamp.Timestamp),
) -> TodoItem {
  let id = option.unwrap(id, wisp.random_string(64))

  case completed_at {
    Some(_) -> TodoItem(id, title, Complete)
    None() -> TodoItem(id, title, Incomplete)
  }
}

pub fn toggle_todo_item_status(todo_item: TodoItem) -> TodoItem {
  let new_status = case todo_item.status {
    Complete -> Incomplete
    Incomplete -> Complete
  }

  // OOH destructuring!
  TodoItem(..todo_item, status: new_status)
}

pub fn todo_item_status_to_bool(status: TodoItemStatus) -> Bool {
  case status {
    Complete -> True
    Incomplete -> False
  }
}
