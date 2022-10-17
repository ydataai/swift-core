import Foundation

public protocol FabricError: Error {
  var context: [AnyHashable: Any]? { get }
  var description: String { get }
  var httpCode: Int? { get }
  var name: String { get }
  var returnValue: Int { get }
}

public extension FabricError {
  var name: String { "\(Self.self)" }
}
