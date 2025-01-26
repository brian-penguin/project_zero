import app/models/todo_item.{type TodoItem}
import gleam/list
import lustre/attribute.{autofocus, class, name, placeholder}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, input, span, svg}
import lustre/element/svg

pub fn root(todo_items: List(TodoItem)) -> Element(t) {
  div([class("todo-items-container")], [
    h1([class("font-gothic"), class("title")], [text("Todos")]),
    todo_item_elements(todo_items),
  ])
}

fn todo_item_elements(todo_items: List(TodoItem)) -> Element(t) {
  div([class("todo-items")], [
    todo_items_input(),
    div([class("todo-items__inner")], [
      div(
        [class("todo-items__list")],
        todo_items
          |> list.map(todo_item),
      ),
      todo_items_empty(),
    ]),
  ])
}

fn todo_items_input() -> Element(t) {
  form(
    [
      class("add-todo-item-input"),
      class("font-gothic"),
      attribute.method("POST"),
      attribute.action("/items/create"),
    ],
    [
      input([
        name("todo_title"),
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
      todo_item.Incomplete -> ""
    }
  }

  div([class("todo-item" <> completed_css_class)], [
    div([class("todo-item__inner")], [
      form(
        [
          attribute.method("POST"),
          // TODO BRIAN WTF IS THIS!, do we not like support patch/put natively?
          attribute.action(
            "/todo_items/" <> todo_item.id <> "/complete?_method=PATCH",
          ),
        ],
        [button([class("todo-item__button")], [svg_icon_checked()])],
      ),
      span([class("todo-item__title")], [svg_icon_checked()]),
    ]),
    form(
      [
        attribute.method("POST"),
        attribute.action("/todo_items/" <> todo_item.id <> "?_method=DELETE"),
      ],
      [button([class("todo__delete")], [svg_icon_delete()])],
    ),
  ])
}

fn todo_items_empty() -> Element(t) {
  div([class("todo-items__empty")], [])
}

fn svg_icon_checked() -> Element(t) {
  svg(
    [class("todo__checked-icon"), attribute.attribute("viewBox", "0 0 24 24")],
    [
      svg.path([
        attribute.attribute("fill", "currentColor"),
        attribute.attribute(
          "d",
          "M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z",
        ),
      ]),
    ],
  )
}

fn svg_icon_delete() -> Element(t) {
  svg(
    [class("todo__delete-icon"), attribute.attribute("viewBox", "0 0 24 24")],
    [
      svg.path([
        attribute.attribute("fill", "currentColor"),
        attribute.attribute(
          "d",
          "M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M9,8H11V17H9V8M13,8H15V17H13V8Z",
        ),
      ]),
    ],
  )
}
