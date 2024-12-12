import wisp.{type Request, type Response} //Okay cool, you can import types
import gleam/string_tree // https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html
import gleam/list
import gleam/result
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
        // matches "/comment<s>/new"
        ["comments", "new"] -> comments_new_page(req)
        ["comment", "new"] -> comments_new_page(req)
        // matches "/comment<s>/:id"
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

    let html = string_tree.from_string("Hello, World!")

    wisp.ok()
    |> wisp.html_body(html)
}

// We are using the /comments route both for showing index pages and creating new comments
fn comments_page(req: Request) -> Response {
    case req.method {
        Get -> comments_index_page()
        Post -> create_comment(req)
        _ -> wisp.method_not_allowed([Get])
    }
}

//  -------------------------------------------- Faking this for now
fn comments_index_page() -> Response {
    let html = string_tree.from_string("Comments")
    wisp.ok()
    |> wisp.html_body(html)
}

fn comments_show_page(req: Request, id: String) -> Response {
    use <- wisp.require_method(req, Get)

    let html = string_tree.from_string("Comment with id " <> id)
    wisp.ok()
    |> wisp.html_body(html)
}

fn comments_new_page(_req: Request) -> Response {
     let html = string_tree.from_string(
      "<form method='post'>
        <label>Title:
          <input type='text' name='title'>
        </label>
        <label>Comment:
          <input type='text' name='comment'>
        </label>
        <input type='submit' value='Submit'>
      </form>",
    )
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(req: Request) -> Response {
    use formdata <- wisp.require_form(req)

    let result = {
        use title <- result.try(list.key_find(formdata.values, "title"))
        use comment  <- result.try(list.key_find(formdata.values, "comment"))
        let comment_response_str =
            "This is your comment" <> wisp.escape_html(title) <> " - " <> wisp.escape_html(comment)
        Ok(comment_response_str)
    }

    case result {
        Ok(content) -> {
            wisp.ok()
            |> wisp.html_body(string_tree.from_string(content))
        }
        Error(_) -> {
            wisp.bad_request()
        }
    }
}


