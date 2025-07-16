import app/models/todo_item.{type TodoItem}
import app/pages/home
import app/pages/todos

pub fn home() {
  home.root()
}

pub fn todos(todo_items: List(TodoItem)) {
  todos.root(todo_items)
}
