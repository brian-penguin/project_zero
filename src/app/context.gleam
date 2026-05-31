import pog
import gleam/erlang/process

pub type DbPoolName = process.Name(pog.Message)

pub type Context {
  Context(static_directory: String, db_conn: pog.Connection)
}

