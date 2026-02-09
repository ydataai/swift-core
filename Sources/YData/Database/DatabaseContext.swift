import Fluent
import Foundation

public protocol DatabaseContext: Sendable {
  var database: Database { get }
}
