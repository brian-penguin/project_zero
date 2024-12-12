import wisp.{type Request, type Response} //Okay cool, you can import types
import gleam/string_builder // https://hexdocs.pm/gleam_stdlib/gleam/string_builder.html optimized string lib for building strings for files
import gleam/http.{Get,Post}
import app/web

pub fn handle_request(req: Request) -> Response {
    use req <- web.middleware(req)

    // According to https://github.com/gleam-wisp/wisp/blob/main/examples/01-routing/src/app/router.gleam#L9
    // We don't have a special router abstraction for wisp and instead should use pattern matching as it's
    // faster, type safe, and no need to learn a DSL

    case wisp.path_segments(req){
        [] -> home_page(req)
        // matches "/comments"
        ["comments"] -> comments_page(req)
        // matches "/comments/:id"
        ["comments", id] -> comments_show_page(req, id)
        ["comment", id] -> comments_show_page(req, id)
        _ -> wisp.not_found()
    }
}

fn home_page(req: Request) -> Response {
    // https://tour.gleam.run/advanced-features/use/
    // It seems like use is kinda like using the let setup in clojure?
    // - it runs the require_method and assigns it to nothing here?
    use <- wisp.require_method(req, Get)

    let html = string_builder.from_string("Hello, World!")

    wisp.ok()
    |> wisp.html_body(html)
}

fn comments_page(req: Request) -> Response {
    case req.method {
        Get -> comments_index_page()
        Post -> create_comment(req)
        _ -> wisp.method_not_allowed([Get])
    }
}

//  -------------------------------------------- Faking this for now
fn comments_index_page() -> Response {
    let html = string_builder.from_string("Comments")
    wisp.ok()
    |> wisp.html_body(html)
}

fn comments_show_page(req: Request, id: String) -> Response {
    use <- wisp.require_method(req, Get)

    let html = string_builder.from_string("Comment with id " <> id)
    wisp.ok()
    |> wisp.html_body(html)
}

fn create_comment(_req: Request) -> Response {
    let html = string_builder.from_string("Created")
    wisp.html_body(wisp.created(), html)
}


