import wisp.{type Request, type Response} //Okay cool, you can import types
import gleam/string_builder // https://hexdocs.pm/gleam_stdlib/gleam/string_builder.html optimized string lib for building strings for files
import app/web

// OKAY BRIAN so here's where we add that function from app.gleam

pub fn handle_request(req: Request) -> Response {
    // Huck in some middlewares (I bet this is composable)
    use _req <- web.middleware(req)

    // Using a string for now before we learn how to use templates
    let response_body = string_builder.from_string("Hello, World!")

    // Let wisp do the heavy lifting returning html and 200
    // - ? Can we change the response type in the handler? Is it a middleware?
    wisp.html_response(response_body, 200)
}
