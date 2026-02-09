import Foundation

public protocol ConfigurationError: Sendable, Error {}

public protocol Configuration: Sendable {
  associatedtype Error: ConfigurationError

  static func loadFromEnvironment() -> Result<Self, Error>
  static func loadFromEnvironment() throws -> Self

  static func loadFromEnvironment<C: Context>(context: C) -> Result<Self, Error>
  static func loadFromEnvironment<C: Context>(context: C) throws -> Self
}

public extension Configuration {
  static func loadFromEnvironment() -> Result<Self, Error> {
    return .failure(NotImplementedError() as! Self.Error)
  }

  static func loadFromEnvironment() throws -> Self {
    let result: Result<Self, Error> = loadFromEnvironment()
    switch result {
    case .success(let success): return success
    case .failure(let error): throw error
    }
  }

  static func loadFromEnvironment<C: Context>(context: C) -> Result<Self, Error> {
    loadFromEnvironment()
  }

  static func loadFromEnvironment<C: Context>(context: C) throws -> Self {
    try loadFromEnvironment()
  }
}

public struct NotImplementedError: ConfigurationError {}
