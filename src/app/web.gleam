import wisp

// This is our middleware stack for everything that goes through our "web" request_handler function
// ---
/// The middleware stack that the request handler uses. The stack is itself a
/// middleware function!
///
/// Middleware wrap each other, so the request travels through the stack from
/// top to bottom until it reaches the request handler, at which point the
/// response travels back up through the stack.

pub fn middleware(
    req: wisp.Request, // I think we could import these types specifically if we wanted?
    handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
    // Permit browsers to simulate methods other than GET and POST using the
    // `_method` query parameter.
    let req = wisp.method_override(req)

    // Log information about the request and response.
    use <- wisp.log_request(req)

    // Return a default 500 response if the request handler crashes.
    use <- wisp.rescue_crashes

    // Rewrite HEAD requests to GET requests and return an empty body.
    use req <- wisp.handle_head(req)

    // Handle the request!
    handle_request(req)
}


