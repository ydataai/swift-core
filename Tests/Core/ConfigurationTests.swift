import XCTest

@testable import YDataCore

final class configuration_tests: XCTestCase {
  func testLoadSuccessful() throws {
    struct TestConfiguration: Configuration {
      let loaded: Bool

      static func loadFromEnvironment() -> Result<TestConfiguration, Error> {
        return .success(.init(loaded: true))
      }

      enum Error: ConfigurationError {}
    }

    do {
      let config: TestConfiguration = try TestConfiguration.loadFromEnvironment()
      XCTAssertTrue(config.loaded)
    } catch {
      XCTFail("failed with error \(error)")
    }
  }

  func testLoadFailed() throws {
    struct TestConfiguration: Configuration {
      let loaded: Bool

      static func loadFromEnvironment() -> Result<TestConfiguration, Error> {
        return .failure(.noEnvironment)
      }

      enum Error: ConfigurationError {
        case noEnvironment
      }
    }

    do {
      let _: TestConfiguration = try TestConfiguration.loadFromEnvironment()
      XCTFail("should have failed")
    } catch let error as TestConfiguration.Error {
      XCTAssertEqual(error, TestConfiguration.Error.noEnvironment)
    } catch {
      XCTFail("failed with error \(error)")
    }
  }
}
