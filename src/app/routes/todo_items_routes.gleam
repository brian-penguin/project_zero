import app/models/todo_item
import app/pages
import app/pages/layout.{layout}
import app/sql
import app/web
import gleam/http.{Delete, Get, Post}
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lustre/element
import pog
import wisp.{type Request, type Response}
import youid/uuid

pub fn todo_items_handler(req: Request, ctx: web.Context) -> Response {
  case req.method {
    Get -> todo_items_page(req, ctx)
    Post -> create_todo_items(req, ctx)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

pub fn todo_item_handler(req: Request, ctx: web.Context, id: String) -> Response {
  case req.method {
    Get -> todo_items_page(req, ctx)
    Post -> create_todo_items(req, ctx)
    Delete -> delete_todo_item(req, ctx, id)
    _ -> wisp.method_not_allowed(allowed: [Get, Post, Delete])
  }
}

fn todo_items_page(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [pages.todos(fetch_todo_items(ctx))]
    |> layout
    |> element.to_document_string
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_todo_items(req: Request, ctx: web.Context) -> Response {
  use form <- wisp.require_form(req)
  let db = pog.named_connection(ctx.db_pool_name)

  let result = {
    use todo_item_title <- result.try(list.key_find(
      form.values,
      "todo_item_title",
    ))

    Ok(sql.create_todo(db, todo_item_title))
  }

  case result {
    Ok(_) -> {
      wisp.redirect("/todos")
    }
    Error(_) -> {
      wisp.bad_request("Invalid")
    }
  }
}

fn delete_todo_item(req: Request, ctx: web.Context, id: String) -> Response {
  let current_todo_items = ctx.todo_items

  let todo_items_json = {
    list.filter(current_todo_items, fn(todo_item) { todo_item.id != id })
    |> todo_items_to_json
  }

  wisp.redirect("/todos")
  |> wisp.set_cookie(
    req,
    "todo_items",
    todo_items_json,
    wisp.PlainText,
    60 * 60 * 24,
  )
}

// TODO Feels like it should be a serializer?
// Helper item for creating the json to store in our cookie
fn todo_items_to_json(items: List(todo_item.TodoItem)) -> String {
  "["
  <> items
  |> list.map(todo_item_to_json)
  |> string.join(",")
  <> "]"
}

fn todo_item_to_json(item: todo_item.TodoItem) -> String {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.bool(todo_item.todo_item_status_to_bool(item.status))),
  ])
  |> json.to_string
}

fn fetch_todo_items(ctx: web.Context) -> List(todo_item.TodoItem) {
  let db = pog.named_connection(ctx.db_pool_name)

  let assert Ok(pog.Returned(_rows_count, rows)) = sql.fetch_todos(db)
  list.map(rows, fn(row) {
    // TODO -> I want to keep the timestamps for the purposes of knowing "when was this completed"
    // But it definitely will need a little finessing

    // TODO timestampstz is not supported and was causing this to blow up.
    //- We can strip the tz stuff but I'm not sure how we want to handle it, maybe always coerce to iso8601?
    let id_str = uuid.to_string(row.id)

    todo_item.create_todo_item(option.Some(id_str), row.title, False)
  })
}
