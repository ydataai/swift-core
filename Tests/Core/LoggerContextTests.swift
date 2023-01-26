import XCTest
import Logging

@testable import YDataCore

struct TestLoggerContext: LoggerContext {
  let logger: Logger = Logger(label: "ai.ydata.swift.core.tests")
}

struct TestLogger {
  let context: any LoggerContext
}

final class logger_tests: XCTestCase {
  func testSuccess() {
    let testLogger = TestLogger(context: TestLoggerContext())

    testLogger.context.logger.info("dummy test")
  }
}
