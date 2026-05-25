import app/context.{type Context, Context}
import app/router
import app/server
import envoy
import gleam/erlang/process
import gleam/http
import gleeunit
import gleeunit/should
import pog
import wisp/simulate

pub fn main() {
  gleeunit.main()
}

fn test_db_config(name) -> pog.Config {
  let assert Ok(database_url) = envoy.get("TEST_DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(name, database_url)
  pog_config
}

fn start_db() -> context.DbPoolName {
  let db_pool_name = process.new_name("test_db")
  let assert Ok(_) =
    db_pool_name
    |> test_db_config()
    |> pog.pool_size(1)
    |> pog.start
  db_pool_name
}

fn with_context(test_case: fn(Context) -> t) -> t {
  let ctx =
    Context(
      static_directory: server.static_directory(),
      db_pool_name: start_db(),
    )

  test_case(ctx)
}

pub fn get_todo_items_test() {
  use ctx <- with_context
  let request = simulate.browser_request(http.Get, "/todos")
  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
}
