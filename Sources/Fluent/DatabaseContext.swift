import Fluent
import Foundation

public protocol DatabaseContext {
  var database: Database { get }
}
