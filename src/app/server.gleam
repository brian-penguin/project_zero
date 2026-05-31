// app/server.gleam
// The server exists in a separate module so we can use the erlang code reloading
// functionality and wrap our requests with it

import app/router
import app/context.{Context}
import envoy
import gleam/erlang/process
import gleam/int
import gleam/otp/static_supervisor
import gleam/result
import mist
import pog
import wisp
import wisp/wisp_mist

pub fn start(wrap_reload) {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")
  let db_pool_name = process.new_name("database")
  let db_pool_child = configure_db_pool_child(db_pool_name)
  let assert Ok(_) = start_application_supervisor(db_pool_child)

  let db_conn = pog.named_connection(db_pool_name)

  let ctx =
    Context(static_directory: static_directory(), db_conn: )

  let port_str = result.unwrap(envoy.get("PORT"), "8000")
  let assert Ok(port) = int.parse(port_str)

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp_mist.handler(secret_key_base)
    |> wrap_reload()
    |> mist.new
    |> mist.port(port)
    |> mist.start
}

pub fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(priv_directory) = wisp.priv_directory("project_zero")
  priv_directory <> "/static"
}

fn configure_db_pool_child(pool_name: process.Name(pog.Message)) {
  let assert Ok(pog_config) = read_db_connection_url(pool_name)

  pog_config
  |> pog.pool_size(6)
  |> pog.supervised
}

fn start_application_supervisor(db_pool_child) {
  static_supervisor.new(static_supervisor.RestForOne)
  |> static_supervisor.add(db_pool_child)
  |> static_supervisor.start
}

fn read_db_connection_url(
  name: process.Name(pog.Message),
) -> Result(pog.Config, Nil) {
  use database_url <- result.try(envoy.get("DATABASE_URL"))
  pog.url_config(name, database_url)
}
