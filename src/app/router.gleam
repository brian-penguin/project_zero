import app/pages
import app/pages/layout.{layout}
import lustre/element
import wisp.{type Request, type Response}

// https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html
import app/web
import gleam/http.{Get}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> home_page(req, ctx)

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
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}
