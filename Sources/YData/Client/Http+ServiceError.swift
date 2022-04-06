import Foundation
import Vapor

public extension Http {
  struct ServiceError: Decodable {
    public let message: String
  }
}
