import app/router
import app/sql
import gleam/http
import gleam/list
import gleam/string
import gleeunit/should
import pog
import test_context
import test_database
import wisp/simulate
import youid/uuid

// GET /todos
pub fn get_todo_items_index_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let assert Ok(_todo_item) = sql.create_todo(ctx.db_conn, "Hello World")

  let request = simulate.browser_request(http.Get, "/todos")
  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
  let response_string = simulate.read_body(response)
  assert string.contains(response_string, "Hello World")
}

// GET /todo
// NOTE this isn't a real route we can get to?
pub fn get_todo_item_index_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let assert Ok(pog.Returned(_row_count, rows)) =
    sql.create_todo(ctx.db_conn, "Hello World")

  let _id = case list.first(rows) {
    Ok(row) -> uuid.to_string(row.id)
    Error(_) -> ""
  }

  let request = simulate.browser_request(http.Get, "/todo")
  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
  let response_string = simulate.read_body(response)
  assert string.contains(response_string, "Hello World")
}
