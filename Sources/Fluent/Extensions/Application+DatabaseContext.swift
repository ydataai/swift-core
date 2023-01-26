import Fluent
import Foundation
import Vapor

extension Application: DatabaseContext {
  public var database: Database { db }
}
