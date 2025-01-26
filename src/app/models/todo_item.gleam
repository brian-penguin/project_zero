import gleam/option.{type Option}

pub type TodoItemStatus {
  Completed
  Incomplete
}

pub type TodoItem {
  TodoItem(id: String, title: String, status: TodoItemStatus)
}
