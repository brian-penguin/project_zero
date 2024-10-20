// This is the entry point for the application!
// Here we will initialize and start out application as well as pass in dependencies
// and probably anything we need to build out a default context
import app/router // TODO: write this
import gleam/erlang/process // How we are going to run this webserver
import mist
import wisp
import wisp/wisp_mist // This is the adapter for using wisp with mist

pub fn main() {
    wisp.configure_logger()

    // TODO: Generate this one time and load at the start so we don't change this each restart
    //      - There might be a like dotenv equivalent
    let secret_key_base = wisp.random_string(64)

    // START IT UPPPPPP
    let assert Ok(_) =
        wisp_mist.handler(router.handle_request, secret_key_base)
        |> mist.new
        |> mist.port(8000) // TODO -> Configurable with ENV
        |> mist.start_http

    // mist will start a new erlang process, so we need to sleep this one while it works concurrently
    process.sleep_forever()
}
