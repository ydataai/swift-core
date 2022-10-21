import Foundation

public protocol FabricError: Error, Codable, Equatable {
  var context: [String: String]? { get }
  var description: String { get }
  var httpCode: Int { get }
  var name: String { get }
  var returnValue: Int { get }
}

public extension FabricError {
  var name: String { "\(Self.self)" }
}

public extension FabricError {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.context == rhs.context
    && lhs.description == rhs.description
    && lhs.httpCode == rhs.httpCode
    && lhs.name == rhs.name
    && lhs.returnValue == rhs.returnValue
  }
}
