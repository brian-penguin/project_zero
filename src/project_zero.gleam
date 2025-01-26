// This is the entry point for the application!
// Here we will initialize and start out application as well as pass in dependencies
// and probably anything we need to build out a default context
import app/router
import app/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process

// How we are going to run this webserver
import mist
import wisp
import wisp/wisp_mist

// This is the adapter for using wisp with mist

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")

  let ctx = Context(static_directory: static_directory(), todo_items: [])

  // Partially apply the router.handle_request fn with our ctx
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    // TODO -> Configurable with ENV
    |> mist.start_http

  // NOTE: mist will start a new erlang process, so we need to sleep this one while it works concurrently
  process.sleep_forever()
}

pub fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(priv_directory) = wisp.priv_directory("project_zero")
  priv_directory <> "/static"
}
