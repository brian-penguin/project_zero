import app/pages
import app/pages/layout.{layout}
import lustre/element
import wisp.{type Request, type Response}

// https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html
import app/web
import gleam/http.{Get, Post}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> home_page(req, ctx)
    ["todo_items"] -> todo_items_handler(req, ctx)

    // Handle Empty Responses -> These are configured by our global middleware
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request, _ctx: web.Context) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [pages.home()]
    |> layout
    |> element.to_document_string_tree

  wisp.ok()
  |> wisp.html_body(html)
}

fn todo_items_handler(req: Request, ctx: web.Context) -> Response {
  case req.method {
    Get -> todo_items_page(req, ctx)
    Post -> create_todo_items(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn todo_items_page(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [pages.todos(ctx.todo_items)]
    |> layout
    |> element.to_document_string_tree
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_todo_items(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, Post)

  let html =
    [pages.todos(ctx.todo_items)]
    |> layout
    |> element.to_document_string_tree
  wisp.ok()
  |> wisp.html_body(html)
}
