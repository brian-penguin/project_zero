import app/server
import gleam/erlang/process
import mist/reload

// This is the adapter for using wisp with mist
pub fn main() {
  let assert Ok(_) = server.start(reload.wrap)

  // NOTE: mist will start a new erlang process, so we need to sleep this one while it works concurrently
  process.sleep_forever()
}
