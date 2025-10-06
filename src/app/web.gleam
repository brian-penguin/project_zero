import app/models/todo_item.{type TodoItem}
import gleam/bool
import gleam/string_tree
import wisp

pub type Context {
  // This type contains all the "Context" we need to perform a request
  // in the future it might also contain a database connection pool or cache key
  Context(static_directory: String, todo_items: List(TodoItem))
}

// This is our middleware stack for everything that goes through our "web" request_handler function
// ---
/// The middleware stack that the request handler uses. The stack is itself a
/// middleware function!
///
/// Middleware wrap each other, so the request travels through the stack from
/// top to bottom until it reaches the request handler, at which point the
/// response travels back up through the stack.
pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // Permit browsers to simulate methods other than GET and POST using the
  // `_method` query parameter.
  let req = wisp.method_override(req)

  // Serve those static assets from our Context
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  // See below, we want to use the
  use <- default_responses

  // Handle the request!
  handle_request(req)
}

pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()

  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      "<h1>Not Found</h1>"
      |> string_tree.from_string
      |> wisp.html_body(response, _)

    400 | 422 ->
      "<h1>Bad request</h1>"
      |> string_tree.from_string
      |> wisp.html_body(response, _)

    413 ->
      "<h1>Request entity too large</h1>"
      |> string_tree.from_string
      |> wisp.html_body(response, _)

    500 ->
      "<h1>Internal server error</h1>"
      |> string_tree.from_string
      |> wisp.html_body(response, _)

    _ -> response
  }
}
