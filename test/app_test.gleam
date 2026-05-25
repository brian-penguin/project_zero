import app/router
import gleam/http
import gleam/list
import gleam/string
import gleeunit/should
import test_context
import wisp/simulate

// Happy Path for our Homepage
pub fn get_home_page_test() {
  let ctx = test_context.get()
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
  let ctx = test_context.get()
  let request = simulate.browser_request(http.Post, "/")
  let response = router.handle_request(request, ctx)

  assert response.status == 405
}

// Test that our 404 page works
pub fn page_not_found_test() {
  let ctx = test_context.get()
  let request = simulate.browser_request(http.Get, "/nothing-lives-here")
  let response = router.handle_request(request, ctx)

  assert response.status == 404
}

pub fn get_stylesheet_test() {
  let ctx = test_context.get()
  let request = simulate.browser_request(http.Get, "/static/styles.css")
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/css; charset=utf-8"))
}

pub fn get_javascript_test() {
  let ctx = test_context.get()
  let request = simulate.browser_request(http.Get, "/static/main.js")
  let response = router.handle_request(request, ctx)

  assert response.status == 200

  assert response.headers
    |> list.contains(any: #("content-type", "text/javascript; charset=utf-8"))
}
