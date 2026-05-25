import gleam/erlang/process
import pog

pub type DbPoolName =
  process.Name(pog.Message)

pub type Context {
  Context(static_directory: String, db_pool_name: DbPoolName)
  TestContext(static_directory: String, db_conn: pog.Connection)
}

pub fn db_conn(ctx: Context) -> pog.Connection {
  case ctx {
      Context(_, db_pool_name) -> pog.named_connection(db_pool_name)
      TestContext(_, db_conn) -> db_conn
    }
}
