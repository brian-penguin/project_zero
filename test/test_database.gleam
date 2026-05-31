import app/context
import envoy
import pog

const test_db_pool_name = "test_db_pool"

// This is a work around, pog always wants EXACTLY the same name
// But when we call Process.new_name we will get a uniq name even
// if we give it the same string.
// This way we can reuse the connection across tests and run them in transactions
@external(erlang, "erlang", "binary_to_atom")
fn binary_to_atom(name: String) -> context.DbPoolName

pub fn db_pool_name() -> context.DbPoolName {
  binary_to_atom(test_db_pool_name)
}

// This lets us start the pool once at test start time and then use
// TestContext.get() to grab a context with a live db connection
pub fn start() -> context.DbPoolName {
  let assert Ok(_) =
    db_pool_name()
    |> test_db_config()
    |> pog.pool_size(1)
    |> pog.start

  db_pool_name()
}

// NEAT lil trick, run all the requests in a transaction!
// This should help with test db isolation
pub fn with_rollback(
  ctx: context.Context,
  next: fn(context.Context) -> Nil,
) -> Nil {
  let _ =
    pog.transaction(ctx.db_conn, fn(db_conn) {
      next(context.Context(static_directory: ctx.static_directory, db_conn:))
      Error("roll it back")
    })
  Nil
}

fn test_db_config(name) -> pog.Config {
  let assert Ok(database_url) = envoy.get("TEST_DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(name, database_url)
  pog_config
}
