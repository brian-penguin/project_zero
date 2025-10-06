import app/pages
import app/pages/layout.{layout}
import app/routes/todo_item_middleware.{todo_items_middleware}
import app/routes/todo_items_routes.{todo_item_handler, todo_items_handler}
import gleam/string
import lustre/element
import wisp.{type Request, type Response}

// https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html
import app/web
import gleam/http.{Get}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)
  use ctx <- todo_items_middleware(req, ctx)

  wisp.log_debug(string.inspect(req))

  case wisp.path_segments(req) {
    [] -> home_page(req, ctx)
    ["todos", id] -> todo_item_handler(req, ctx, id)
    ["todos"] -> todo_items_handler(req, ctx)

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
