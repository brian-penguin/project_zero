import gleeunit
import gleeunit/should
import wisp/testing
import app/router

pub fn main() {
    gleeunit.main()
}

// Happy Path
pub fn get_home_page_test() {
    let request = testing.get("/", [])
    let response = router.handle_request(request)

    response.status
    |> should.equal(200)

    response.headers
    |> should.equal([#("content-type", "text/html; charset=utf-8")])

    response
    |> testing.string_body
    |> should.equal("Hello, World!")
}

// Test that we don't allow random posts
pub fn post_home_page_test() {
    let request = testing.post("/", [], "random post body")
    let response = router.handle_request(request)

    response.status
    |> should.equal(405)
}

// Test that our 404 page works
pub fn page_not_found_test() {
    let request = testing.get("/nothing-here", [])
    let response = router.handle_request(request)

    response.status
    |> should.equal(404)
}

// Lets try it out with Comments
pub fn get_comments_test() {
    let request = testing.get("/comments", [])
    let response = router.handle_request(request)

    response.status
    |> should.equal(200)
    // I'm not sure how to test that like html looks right?

}

pub fn get_comment_test() {
    let request = testing.get("/comments/123", [])
    let response = router.handle_request(request)

    response.status
    |> should.equal(200)
    response
    |> testing.string_body
    |> should.equal("Comment with id 123")
}

pub fn update_comment_test() {
    let request = testing.put("/comments/123", [], "hi")
    let response = router.handle_request(request)

    should.equal(response.status, 405)
}

pub fn delete_comment_test() {
    let request = testing.delete("/comments/123", [], "")
    let response = router.handle_request(request)

    should.equal(response.status, 405)
}



