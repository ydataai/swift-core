import Fluent
import Foundation
import Vapor

extension Request: DatabaseServiceContext {
  public var database: Database { db }
}
