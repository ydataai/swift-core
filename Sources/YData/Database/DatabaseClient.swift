import Foundation

public protocol DatabaseClient: Sendable {
  associatedtype Context: DatabaseClientContext

  var context: Context { get }
}
