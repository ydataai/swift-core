import Foundation

public protocol ConfigurationError: Error {}

public protocol Configuration {
  associatedtype Error: ConfigurationError

  static func loadFromEnvironment() -> Result<Self, Error>

  static func loadFromEnvironment() throws -> Self
}

public extension Configuration {
  static func loadFromEnvironment() throws -> Self {
    let result: Result<Self, Error> = loadFromEnvironment()
    switch result {
    case .success(let success): return success
    case .failure(let error): throw error
    }
  }
}
