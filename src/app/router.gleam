import gleam/string_tree
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

  let html = string_tree.from_string(base_app_html)

  wisp.ok()
  |> wisp.html_body(html)
}

const base_app_html = "<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"utf-8\">
    <title>Project Zero</title>
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <link rel=\"stylesheet\" href=\"/static/styles.css\">
  </head>
  <body>
    <div id=\"app\">
        <span class=\"title\"> Hello, World! </span>
    </div>
    <script src=\"/static/main.js\"></script>
  </body>
</html>
"
