import Fluent
import Foundation

protocol DatabaseServiceContext: ServiceContext {
  var database: Database { get }
}
