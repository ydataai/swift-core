import Foundation
import Vapor

public extension Internal {
  struct ServiceError: Decodable {
    public let message: String
  }
}
