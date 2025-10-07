//// This module contains the code to run the sql queries defined in
//// `./src/app/sql`.
//// > 🐿️ This module was generated automatically using v4.4.2 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `fetch_todos` query
/// defined in `./src/app/sql/fetch_todos.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.4.2 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FetchTodosRow {
  FetchTodosRow(id: Uuid, title: String)
}

/// Runs the `fetch_todos` query
/// defined in `./src/app/sql/fetch_todos.sql`.
///
/// > 🐿️ This function was generated automatically using v4.4.2 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn fetch_todos(
  db: pog.Connection,
) -> Result(pog.Returned(FetchTodosRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use title <- decode.field(1, decode.string)
    decode.success(FetchTodosRow(id:, title:))
  }

  "SELECT
    id,
    title
FROM
    todo_items
ORDER BY
    created_at DESC
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "Uuid")
  }
}
