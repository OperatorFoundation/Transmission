import XCTest
@testable import Transmission

final class TransmissionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Transmission().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
