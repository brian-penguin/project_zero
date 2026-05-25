// This is our middleware stack for everything that goes through our "web"
// request_handler function
// Middleware wrap each other, so the request travels through the stack from
// top to bottom until it reaches the request handler, at which point the
// response travels back up through the stack.
import wisp
import app/context.{type Context}

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
  // Add CSRF check
  use req <- wisp.csrf_known_header_protection(req)
  // Handle the request!
  handle_request(req)
}
