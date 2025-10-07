import app/router
import app/web.{type Context, Context}
import gleam/erlang/process
import gleam/http
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import project_zero
import wisp/simulate

pub fn main() {
  gleeunit.main()
}

// TODO: What is this called?
// - I want to call this currying? partial application? Idk the difference?
fn with_context(testcase: fn(Context) -> tc) -> tc {
  let db_process_name = process.new_name("test-db")
  let context =
    Context(
      static_directory: project_zero.static_directory(),
      todo_items: [],
      db_pool_name: db_process_name,
    )
  testcase(context)
}

// Happy Path for our Homepage
pub fn get_home_page_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/")
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  let response_string = simulate.read_body(response)
  assert string.contains(response_string, "Homepage")
}

// Test that we don't allow random posts
pub fn post_home_page_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Post, "/")
  let response = router.handle_request(request, ctx)

  assert response.status == 405
}

// Test that our 404 page works
pub fn page_not_found_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/nothing-lives-here")
  let response = router.handle_request(request, ctx)

  assert response.status == 404
}

pub fn get_stylesheet_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/static/styles.css")
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/css; charset=utf-8"))
}

pub fn get_javascript_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/static/main.js")
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/javascript; charset=utf-8"))
}
