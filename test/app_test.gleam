import app/router
import app/web.{type Context, Context}
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import project_zero
import wisp/testing

pub fn main() {
  gleeunit.main()
}

// TODO: What is this called?
// - I want to call this currying? partial application? Idk the difference?
fn with_context(testcase: fn(Context) -> tc) -> tc {
  let context =
    Context(static_directory: project_zero.static_directory(), todo_items: [])
  testcase(context)
}

// Happy Path for our Homepage
pub fn get_home_page_test() {
  use ctx <- with_context
  let request = testing.get("/", [])
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  let response_string =
    response
    |> testing.string_body

  assert string.contains(response_string, "Homepage")
}

// Test that we don't allow random posts
pub fn post_home_page_test() {
  use ctx <- with_context
  let request = testing.post("/", [], "random post body")
  let response = router.handle_request(request, ctx)

  assert response.status == 405
}

// Test that our 404 page works
pub fn page_not_found_test() {
  use ctx <- with_context
  let request = testing.get("/nothing-here", [])
  let response = router.handle_request(request, ctx)

  assert response.status == 404
}

pub fn get_stylesheet_test() {
  use ctx <- with_context
  let request = testing.get("/static/styles.css", [])
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/css; charset=utf-8"))
}

pub fn get_javascript_test() {
  use ctx <- with_context
  let request = testing.get("/static/main.js", [])
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/javascript; charset=utf-8"))
}
