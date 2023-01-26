import XCTest
import NIOCore
import NIO
import Logging

@testable import YDataClient

struct TestClientContext: ClientContext {
  let eventLoop: EventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
  let logger: Logger = Logger(label: "ai.ydata.swift.core.tests")
}

struct TestClient: Client {
  let context: any ClientContext
}

final class client_tests: XCTestCase {
  func testSuccess() {
    let client = TestClient(context: TestClientContext())

    do {
      let result = try client.context.eventLoop.submit {
        "Test from eventloop"
      }.wait()

      client.context.logger.info("\(result)")

      XCTAssertEqual(result, "Test from eventloop")
    } catch {
      client.context.logger.error("failed with error \(error)")
      XCTFail("failed with error \(error)")
    }
  }
}
