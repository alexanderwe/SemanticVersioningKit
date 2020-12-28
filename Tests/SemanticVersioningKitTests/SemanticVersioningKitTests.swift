import XCTest
@testable import SemanticVersioningKit

final class SemanticVersioningKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SemanticVersioningKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
