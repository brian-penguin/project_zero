import app/context.{type Context, Context}
import app/router
import app/server
import gleam/http
import gleeunit/should
import test_database
import wisp/simulate
import gleam/string

fn with_context(test_case: fn(Context) -> t) -> t {
  let ctx =
    Context(
      static_directory: server.static_directory(),
      db_pool_name: test_database.db_pool_name(),
    )

  test_case(ctx)
}

pub fn get_todo_items_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/todos")
  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
  let response_string = simulate.read_body(response)
  assert string.contains(response_string, "Homepage")
}
