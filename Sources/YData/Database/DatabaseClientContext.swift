import Fluent
import Foundation

public protocol DatabaseClientContext {
  var database: Database { get }
}
