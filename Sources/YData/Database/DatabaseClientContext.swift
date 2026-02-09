import Fluent
import Foundation

public protocol DatabaseClientContext: Sendable {
  var database: Database { get }
}
