import XCTest

@testable import YDataCore

final class optional_tests: XCTestCase {
  func testSuccessful() throws {
    var left = "left"

    XCTAssertEqual(left, "left")

    let right: String? = "right"

    left ?= right

    XCTAssertEqual(left, right)
  }
}
