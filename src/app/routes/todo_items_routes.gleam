import app/models/todo_item
import app/pages
import app/pages/layout.{layout}
import app/sql
import app/web
import gleam/http.{Delete, Get, Post}
import gleam/list
import gleam/option
import gleam/result
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
  // - I think I want to have a put/patch in here somewhere which might mean overriding the form's _method
  case req.method {
    Get -> todo_items_page(req, ctx)
    Post -> create_todo_items(req, ctx)
    Delete -> delete_todo_item(req, ctx, id)
    _ -> wisp.method_not_allowed(allowed: [Get, Post, Delete])
  }
}

pub fn todo_item_completion_handler(
  req: Request,
  ctx: web.Context,
  id: String,
) -> Response {
  case req.method {
    Post -> create_todo_item_completion(req, ctx, id)
    _ -> wisp.method_not_allowed(allowed: [Post, Delete])
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

fn create_todo_item_completion(
  _req: Request,
  ctx: web.Context,
  id: String,
) -> Response {
  let db = pog.named_connection(ctx.db_pool_name)

  case uuid.from_string(id) {
    Ok(valid_id) -> {
      let _res = sql.complete_todo(db, valid_id)
      wisp.redirect("/todos")
    }
    Error(_) -> {
      wisp.bad_request("Invalid")
    }
  }
}

fn delete_todo_item(_req: Request, ctx: web.Context, id: String) -> Response {
  let db = pog.named_connection(ctx.db_pool_name)

  case uuid.from_string(id) {
    Ok(valid_id) -> {
      let _res = sql.delete_todo(db, valid_id)
      wisp.redirect("/todos")
    }
    Error(_) -> {
      wisp.bad_request("Invalid")
    }
  }
}

fn fetch_todo_items(ctx: web.Context) -> List(todo_item.TodoItem) {
  let db = pog.named_connection(ctx.db_pool_name)

  let assert Ok(pog.Returned(_rows_count, rows)) = sql.fetch_todos(db)
  list.map(rows, fn(row) {
    let id_str = uuid.to_string(row.id)

    todo_item.create_todo_item(option.Some(id_str), row.title, row.completed_at)
  })
}
