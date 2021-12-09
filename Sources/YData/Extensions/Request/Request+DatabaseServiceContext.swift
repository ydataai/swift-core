import Fluent
import Foundation
import Vapor

extension Request: DatabaseServiceContext {
  var database: Database { db }
}
