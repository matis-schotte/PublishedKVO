import XCTest
@testable import PublishedKVO

final class PublishedKVOTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PublishedKVO().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
