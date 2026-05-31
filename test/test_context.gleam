import app/context.{type Context}
import app/server
import gleam/erlang/process
import pog
import test_database

// This should verify the DB conn pool is started
pub fn get() -> Context {
  let static_directory = server.static_directory()
  let db_pool_name = test_database.db_pool_name()
  let assert Ok(_) = process.named(db_pool_name)
  let db_conn = pog.named_connection(db_pool_name)

  context.Context(static_directory:, db_conn:)
}
