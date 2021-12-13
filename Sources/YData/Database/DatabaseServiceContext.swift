import Fluent
import Foundation

public protocol DatabaseServiceContext: ServiceContext {
  var database: Database { get }
}
