import app/context.{type Context}
import app/middleware.{middleware}
import app/pages
import app/pages/layout.{layout}
import app/routes/todo_items_routes.{
  todo_item_completion_handler, todo_item_handler, todo_items_handler,
}
import gleam/http.{Get}
import gleam/string
import lustre/element
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- middleware(req, ctx)

  wisp.log_info(string.inspect(req))

  case wisp.path_segments(req) {
    [] -> home_page(req, ctx)
    ["todos", id, "completion"] -> todo_item_completion_handler(req, ctx, id)
    ["todos", id] -> todo_item_handler(req, ctx, id)
    ["todos"] -> todo_items_handler(req, ctx)

    //TODO not sure these are necessary
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_content()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.content_too_large()
    ["bad-request"] -> wisp.bad_request("Request was not good")
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [pages.home()]
    |> layout
    |> element.to_document_string

  wisp.ok()
  |> wisp.html_body(html)
}
