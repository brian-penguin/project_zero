import gleeunit
import gleeunit/should
import test_database

pub fn main() {
  test_database.start()
  gleeunit.main()
}

pub fn hello_world_test() {
  1
  |> should.equal(1)
}
