import app/models/todo_item.{type TodoItem, create_todo_item}
import app/web.{type Context, Context}
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option.{Some}
import wisp.{type Request, type Response}

// We don't HAVE to use an intermediate type on the way to parsing TodoItems
// but this might be nicer so we could potentially combine types together
type TodoItemsJson {
  TodoItemsJson(id: String, title: String, complete: Bool)
}

pub fn todo_items_middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  // This is where we will update our app context with our fetched items
  // and pass it to handle_request with our new context

  let parsed_todo_items = {
    // We are just using a cookie for storage right now but we will want to change this later to something else
    case wisp.get_cookie(req, "todo_items", wisp.PlainText) {
      Ok(json_string) -> {
        let decoder =
          dynamic.decode3(
            TodoItemsJson,
            dynamic.field("id", dynamic.string),
            dynamic.field("title", dynamic.string),
            dynamic.field("complete", dynamic.bool),
          )
          |> dynamic.list

        let result = json.decode(json_string, decoder)
        case result {
          Ok(todo_items) -> todo_items
          Error(_) -> []
        }
      }
      Error(_) -> []
    }
  }

  let todo_items = create_todo_items_from_json(parsed_todo_items)

  let ctx = Context(..ctx, todo_items: todo_items)
  handle_request(ctx)
}

fn create_todo_items_from_json(
  todo_items: List(TodoItemsJson),
) -> List(TodoItem) {
  todo_items
  |> list.map(fn(todo_item) {
    let TodoItemsJson(id, title, completed) = todo_item
    create_todo_item(Some(id), title, completed)
  })
}
