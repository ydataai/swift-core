import XCTest

@testable import YData

final class temp_swift_packageTests: XCTestCase {
  func testSuccessful() throws {
    var left = "left"

    XCTAssertEqual(left, "left")

    let right: String? = "right"

    left ?= right

    XCTAssertEqual(left, right)
  }
}
