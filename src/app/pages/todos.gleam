import app/models/todo_item.{type TodoItem}
import gleam/list
import lustre/attribute.{autofocus, class, name, placeholder}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, input, span}

pub fn root(todo_items: List(TodoItem)) -> Element(t) {
  div([class("todo-items-page"), class("font-gothic")], [
    div([class("page-title-container")], [
      h1([class("font-gothic"), class("page-title")], [text("Todo")]),
    ]),
    todo_items_input(),
    todo_item_elements(todo_items),
  ])
}

fn todo_item_elements(todo_items: List(TodoItem)) -> Element(t) {
  div([class("todo-items")], [
    div([class("todo-items__inner")], [
      todo_items_list(todo_items),
      todo_items_empty(),
    ]),
  ])
}

fn todo_items_list(todo_items: List(TodoItem)) -> Element(t) {
  div(
    [],
    todo_items
      |> list.map(todo_item),
  )
}

fn todo_items_input() -> Element(t) {
  form(
    [
      class("add-todo-item-input"),
      attribute.method("POST"),
      attribute.action("/todos"),
    ],
    [
      input([
        name("todo_item_title"),
        class("add-todo-item-input__input"),
        placeholder("What do you need to do?"),
        autofocus(True),
      ]),
    ],
  )
}

fn todo_item(todo_item: TodoItem) -> Element(t) {
  let completed_css_class: String = {
    case todo_item.status {
      todo_item.Complete -> "todo-item__complete"
      todo_item.Incomplete -> "todo-item__incomplete"
    }
  }

  div([class("todo-item"), class(completed_css_class)], [
    span([class("todo-item__title")], [text(todo_item.title)]),
    form(
      [
        // NOTE: We do this because there's not a "native" patch or delete.
        // - Forms are almost always submitted by web-browsers as post requests
        // - See: https://github.com/gleam-wisp/wisp/blob/main/src/wisp.gleam#L743
        attribute.method("POST"),
        attribute.action(
          "/todos/" <> todo_item.id <> "/completion",
        ),
      ],
      [button([class("todo-item__button")], [text("Complete")])],
    ),
    form(
      [
        attribute.method("POST"),
        attribute.action("/todos/" <> todo_item.id <> "?_method=DELETE"),
      ],
      [button([class("todo-item__delete")], [text("Delete")])],
    ),
  ])
}

fn todo_items_empty() -> Element(t) {
  div([class("todo-items__empty")], [])
}
