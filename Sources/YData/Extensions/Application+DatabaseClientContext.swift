import Fluent
import Foundation
import Vapor

extension Application: DatabaseClientContext {
  public var database: Database { db }
}
